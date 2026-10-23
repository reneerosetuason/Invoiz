"""Create copies with changes confined to Actual Result and Remarks cells."""
from pathlib import Path
from zipfile import ZipFile
from xml.sax.saxutils import escape
import json
import re
import sys
import xml.etree.ElementTree as ET

sys.stdout.reconfigure(encoding='utf-8')
BASE = Path(__file__).resolve().parent
SOURCE = Path(r'C:\Users\LENOVO\Downloads')
NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
REVIEWS = {entry['id']: entry for entry in json.loads((BASE / 'review_evidence.json').read_text(encoding='utf-8'))}
BOOKS = [
    ('Mobile_Blackbox_Test_Cases_Account_Creation-Buyer (1).xlsx', 'Invoiz_Buyer_Account_Creation_Answers.xlsx', 42),
    ('Mobile_Blackbox_Test_Cases_Buyer_Modules (1).xlsx', 'Invoiz_Buyer_Modules_Answers.xlsx', 131),
]


def cell_pattern(address):
    return re.compile(r'<c\b(?=[^>]*\br="' + re.escape(address) + r'")([^>]*?)(?:/>|>.*?</c>)', re.S)


def write_answer(xml, address, answer):
    pattern = cell_pattern(address)
    existing = pattern.search(xml)
    assert existing is not None, f'Missing answer cell: {address}'
    old_cell = ET.fromstring(existing.group().replace('<c ', '<c xmlns="' + NS['s'] + '" ', 1))
    assert old_cell.find('s:f', NS) is None, f'Answer cell has formula: {address}'
    assert not ''.join(old_cell.itertext()).strip(), f'Answer cell is already filled: {address}'
    attrs = re.sub(r'\s+t="[^"]*"', '', existing.group(1))
    new_cell = f'<c{attrs} t="inlineStr"><is><t xml:space="preserve">{escape(answer)}</t></is></c>'
    return xml[:existing.start()] + new_cell + xml[existing.end():]


def read_value(cell, strings):
    value = cell.find('s:v', NS)
    if cell.attrib.get('t') == 's' and value is not None:
        return strings[int(value.text)]
    if cell.attrib.get('t') == 'inlineStr':
        return ''.join(t.text or '' for t in cell.iter('{' + NS['s'] + '}t'))
    return value.text if value is not None else ''


def make_workbooks():
    reports = []
    used = set()
    for source_name, output_name, expected_count in BOOKS:
        source = SOURCE / source_name
        target = BASE / output_name
        changes = {}
        counts = {}
        edited_addresses = {}
        with ZipFile(source) as original:
            strings = []
            if 'xl/sharedStrings.xml' in original.namelist():
                strings = [''.join(t.text or '' for t in item.iter('{' + NS['s'] + '}t')) for item in ET.fromstring(original.read('xl/sharedStrings.xml'))]
            for path in original.namelist():
                if not re.fullmatch(r'xl/worksheets/sheet\d+\.xml', path):
                    continue
                raw = original.read(path).decode('utf-8')
                tree = ET.fromstring(raw)
                header = tree.find('s:sheetData/s:row', NS)
                first_cell = header.find('s:c', NS) if header is not None else None
                if first_cell is None or read_value(first_cell, strings) != 'Test Case ID':
                    continue
                changed = raw
                addresses = []
                count = 0
                for row in tree.findall('s:sheetData/s:row', NS)[1:]:
                    cell = row.find(f's:c[@r="A{row.attrib["r"]}"]', NS)
                    if cell is None:
                        continue
                    case_id = read_value(cell, strings)
                    if case_id not in REVIEWS:
                        continue
                    entry = REVIEWS[case_id]
                    assert case_id not in used, case_id
                    used.add(case_id)
                    values = {
                        f'K{row.attrib["r"]}': entry['answer'],
                        f'M{row.attrib["r"]}': f'Source review only; not tested on a phone. Finding: {entry["review_finding"].lower()}.',
                    }
                    for address, value in values.items():
                        changed = write_answer(changed, address, value)
                        addresses.append(address)
                    count += 1
                if count:
                    # Removing the permitted cells must leave identical XML, including formatting.
                    before = raw
                    after = changed
                    for address in addresses:
                        before = cell_pattern(address).sub(f'<ANSWER_CELL_{address}/>', before, count=1)
                        after = cell_pattern(address).sub(f'<ANSWER_CELL_{address}/>', after, count=1)
                    assert before == after, f'Unexpected worksheet change: {path}'
                    changes[path] = changed.encode('utf-8')
                    counts[path] = count
                    edited_addresses[path] = addresses
            assert sum(counts.values()) == expected_count, counts
            with ZipFile(target, 'w') as answered:
                answered.comment = original.comment
                for info in original.infolist():
                    answered.writestr(info, changes.get(info.filename, original.read(info.filename)))

        with ZipFile(source) as original, ZipFile(target) as answered:
            assert original.namelist() == answered.namelist()
            assert answered.testzip() is None
            for path in original.namelist():
                if path not in changes:
                    assert original.read(path) == answered.read(path), path
                if path.endswith('.xml'):
                    ET.fromstring(answered.read(path))
            for path, addresses in edited_addresses.items():
                old = ET.fromstring(original.read(path))
                new = ET.fromstring(answered.read(path))
                old_cells = {c.attrib['r']: c for c in old.findall('s:sheetData/s:row/s:c', NS)}
                new_cells = {c.attrib['r']: c for c in new.findall('s:sheetData/s:row/s:c', NS)}
                assert old_cells.keys() == new_cells.keys()
                for address in old_cells:
                    if address not in addresses:
                        assert ET.tostring(old_cells[address]) == ET.tostring(new_cells[address]), (path, address)
                    else:
                        assert old_cells[address].attrib.get('s') == new_cells[address].attrib.get('s')
        report = {'file': str(target), 'cases_answered': expected_count, 'columns_edited': ['K (Actual Result)', 'M (Remarks)'], 'all_other_content_and_formatting': 'unchanged', 'validation': 'passed'}
        reports.append(report)
        print(json.dumps(report, ensure_ascii=False))
    assert used == REVIEWS.keys()
    (BASE / 'answers_only_validation.json').write_text(json.dumps(reports, ensure_ascii=False, indent=2), encoding='utf-8')


if __name__ == '__main__':
    make_workbooks()
