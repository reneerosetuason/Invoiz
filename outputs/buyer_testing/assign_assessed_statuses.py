"""Assign evidence-based assessments without presenting them as executed tests."""
from pathlib import Path
from zipfile import ZipFile
from collections import Counter
import json
import re
import sys
import xml.etree.ElementTree as ET

sys.stdout.reconfigure(encoding='utf-8')
BASE = Path(__file__).resolve().parent
SOURCE = BASE / 'Invoiz_Buyer_Modules_User_Style_Answers.xlsx'
TARGET = BASE / 'Invoiz_Buyer_Modules_Assessed_Results.xlsx'
ROWS = {r['id']: r for r in json.loads((BASE / 'user_style_answer_notes.json').read_text(encoding='utf-8'))}
NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
      'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
STATUS = {}


def statuses(prefix, choices):
    for number, choice in enumerate(choices.split(), 1):
        STATUS[f'{prefix}-{number:03}'] = {'P': 'Pass', 'F': 'Fail', 'B': 'Blocked'}[choice]


statuses('BUY-ACCT', 'F F P F F F B B F B F B')
statuses('BUY-ADDR', 'F F F F F F F F P B B')
statuses('BUY-SRCH', 'P F P F F P F F F B F F B')
statuses('BUY-PDP', 'F F F P F F F B B F')
statuses('BUY-WISH', 'B B F F P')
statuses('BUY-CART', 'P P F F P P F B P P B F')
statuses('BUY-VOU', 'F F F F F F F P F F F F')
statuses('BUY-CHK', 'F F F F F B B F B F P F B')
statuses('BUY-PAY', 'F F B B B F B B B')
statuses('BUY-TRK', 'F B F B F P F')
statuses('BUY-CAN', 'F F B B P B')
statuses('BUY-RET', 'F B B B B B')
statuses('BUY-RATE', 'F F F F F B F')
statuses('BUY-CHAT', 'F F B F P F B F')

REASONS = {
    'BUY-ACCT-007': 'Email-change verification must be available before this check can be completed.',
    'BUY-ACCT-008': 'Email editing must be available before a replacement email can be submitted.',
    'BUY-ADDR-010': 'Use My Location is not supported.',
    'BUY-SRCH-010': 'The specified share-link flow is unavailable; link handling still needs confirmation.',
    'BUY-WISH-001': 'Confirm the heart and Favorites list stay in sync after reopening the product.',
    'BUY-PDP-008': 'The specified sharing and deep-link flow is unavailable; the full link scenario remains unverified.',
    'BUY-CHK-006': 'COD is preselected, and this screen does not allow an empty payment selection.',
    'BUY-RATE-006': 'The average calculation is supported; product and search review counts still need confirmation.',
}


def cell_pattern(address):
    return re.compile(r'<c\b(?=[^>]*\br="' + re.escape(address) + r'")([^>]*?)(?:/>|>.*?</c>)', re.S)


def read_value(cell, shared):
    v = cell.find('s:v', NS)
    if cell.attrib.get('t') == 's' and v is not None:
        return shared[int(v.text)]
    if cell.attrib.get('t') == 'inlineStr':
        return ''.join(t.text or '' for t in cell.iter('{' + NS['s'] + '}t'))
    return v.text if v is not None else ''


def text_cell(xml, address, value):
    from xml.sax.saxutils import escape
    match = cell_pattern(address).search(xml)
    assert match, address
    attrs = re.sub(r'\s+t="[^"]*"', '', match.group(1))
    replacement = f'<c{attrs} t="inlineStr"><is><t xml:space="preserve">{escape(value)}</t></is></c>'
    return xml[:match.start()] + replacement + xml[match.end():]


def cached_number(xml, address, number):
    pattern = cell_pattern(address)
    match = pattern.search(xml)
    assert match and '<f' in match.group(), address
    replacement, count = re.subn(r'<v>.*?</v>', '<v>' + format(number, '.15g') + '</v>', match.group(), count=1, flags=re.S)
    assert count == 1
    return xml[:match.start()] + replacement + xml[match.end():]


def main():
    assert set(STATUS) == set(ROWS) and len(STATUS) == 131
    for case_id, row in ROWS.items():
        if row['basis'].startswith('observed'):
            assert STATUS[case_id] == row['status'], f'Cannot replace a confirmed result: {case_id}'
    edits = {}
    edited_cells = {}
    summary_updates = set()
    notes = []
    module_counts = {}
    with ZipFile(SOURCE) as original:
        shared = [''.join(t.text or '' for t in si.iter('{' + NS['s'] + '}t')) for si in ET.fromstring(original.read('xl/sharedStrings.xml'))]
        rels = {r.attrib['Id']: r.attrib['Target'] for r in ET.fromstring(original.read('xl/_rels/workbook.xml.rels'))}
        workbook = ET.fromstring(original.read('xl/workbook.xml'))
        sheets = {}
        for sheet in workbook.find('s:sheets', NS):
            target = rels[sheet.attrib['{' + NS['r'] + '}id']]
            path = target.lstrip('/') if target.startswith('/') else 'xl/' + target
            sheets[sheet.attrib['name']] = path
        for name, path in sheets.items():
            if not name.startswith('B'):
                continue
            raw = original.read(path).decode('utf-8')
            tree = ET.fromstring(raw)
            revised = raw
            changed = []
            counts = Counter()
            for row in tree.findall('s:sheetData/s:row', NS):
                cells = {c.attrib['r'].rstrip('0123456789'): c for c in row}
                case_id = read_value(cells['A'], shared) if 'A' in cells else ''
                if case_id not in STATUS:
                    continue
                status = STATUS[case_id]
                observed = ROWS[case_id]['basis'].startswith('observed')
                if observed:
                    remark = read_value(cells['M'], shared)
                else:
                    reason = REASONS.get(case_id, re.sub(r'^Draft:\s*', '', ROWS[case_id]['remark']))
                    remark = f'Assessed {status} (not executed): {reason}'
                for col, value in [('L', status), ('M', remark)]:
                    address = f'{col}{row.attrib["r"]}'
                    revised = text_cell(revised, address, value)
                    changed.append(address)
                counts[status] += 1
                notes.append({'id': case_id, 'status': status, 'basis': ROWS[case_id]['basis'], 'actual': ROWS[case_id]['actual'], 'remark': remark})
            if changed:
                edits[path] = revised.encode('utf-8')
                edited_cells[path] = set(changed)
                module_counts[name] = counts

        # Refresh only calculated caches; the original summary formulas are unchanged.
        summary_path = sheets['Summary']
        summary = original.read(summary_path).decode('utf-8')
        total = sum(module_counts.values(), Counter())
        for row in ET.fromstring(summary).findall('s:sheetData/s:row', NS):
            cells = {c.attrib['r'].rstrip('0123456789'): c for c in row}
            label = read_value(cells['A'], shared) if 'A' in cells else ''
            counts = module_counts.get(label) if label != 'Total' else total
            if counts is None:
                continue
            count = sum(counts.values())
            values = {'B': count, 'C': counts['Pass'], 'D': counts['Fail'], 'E': counts['Blocked'], 'F': 0,
                      'G': counts['Pass'] / count if count else 0}
            for col, value in values.items():
                address = f'{col}{row.attrib["r"]}'
                summary = cached_number(summary, address, value)
                summary_updates.add(address)
        edits[summary_path] = summary.encode('utf-8')

        with ZipFile(TARGET, 'w') as output:
            output.comment = original.comment
            for info in original.infolist():
                output.writestr(info, edits.get(info.filename, original.read(info.filename)))

    with ZipFile(SOURCE) as original, ZipFile(TARGET) as output:
        assert original.namelist() == output.namelist() and output.testzip() is None
        for path in original.namelist():
            if path not in edits:
                assert original.read(path) == output.read(path), path
            elif path == summary_path:
                before = original.read(path).decode('utf-8')
                after = output.read(path).decode('utf-8')
                for address in summary_updates:
                    for which in ['before', 'after']:
                        text = before if which == 'before' else after
                        match = cell_pattern(address).search(text)
                        masked = re.sub(r'<v>.*?</v>', '<v>CACHE</v>', match.group(), flags=re.S)
                        text = text[:match.start()] + masked + text[match.end():]
                        if which == 'before': before = text
                        else: after = text
                assert before == after, 'Summary formulas or formatting changed'
            else:
                before = original.read(path).decode('utf-8')
                after = output.read(path).decode('utf-8')
                for address in edited_cells[path]:
                    before = cell_pattern(address).sub(f'<RESULT_{address}/>', before, count=1)
                    after = cell_pattern(address).sub(f'<RESULT_{address}/>', after, count=1)
                assert before == after, f'Unexpected worksheet change: {path}'
            if path.endswith('.xml'):
                ET.fromstring(output.read(path))
    assert len(notes) == 131 and all(r['status'] in {'Pass','Fail','Blocked'} for r in notes)
    assert all('(not executed)' in r['remark'] for r in notes if not r['basis'].startswith('observed'))
    (BASE / 'assessed_status_notes.json').write_text(json.dumps(notes,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'file':str(TARGET),'statuses':dict(total),'total':sum(total.values()),'not_run':0,
        'validation':'Original answers, layout, styles and formulas preserved; summary counts refreshed.'},ensure_ascii=False))


if __name__ == '__main__':
    main()
