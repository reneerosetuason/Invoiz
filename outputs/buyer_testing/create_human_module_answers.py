"""Fill only the module workbook's answer cells, preserving its template."""
from pathlib import Path
from zipfile import ZipFile
from xml.sax.saxutils import escape
import json
import re
import sys
import xml.etree.ElementTree as ET

sys.stdout.reconfigure(encoding='utf-8')
BASE = Path(__file__).resolve().parent
SOURCE = Path(r'C:\Users\LENOVO\Downloads\Mobile_Blackbox_Test_Cases_Buyer_Modules (1).xlsx')
TARGET = BASE / 'Invoiz_Buyer_Modules_User_Style_Answers.xlsx'
NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
ANSWERS = {}


def group(prefix, text):
    for number, line in enumerate(filter(None, map(str.strip, text.strip().splitlines())), 1):
        actual, remark = map(str.strip, line.split('|', 1))
        ANSWERS[f'{prefix}-{number:03}'] = {'actual': actual, 'remark': remark}


group('BUY-ACCT', """
The new name and photo stayed saved after signing in again, but the account details did not refresh straight after saving. The bottom menu also partly covered Save. | Refresh the account details after saving and keep Save visible.
An empty first name was rejected, but Juan123 and a one-letter name were still accepted. | Reject names containing numbers and add a minimum name length.
The password changed successfully. The old password was rejected, and the new password worked when signing in again. | Worked.
The password-change form did not ask for the current password before saving a new one. | Require the current password before allowing a change.
A short password was rejected, but a password with no uppercase letter was accepted. | Apply all password rules, not just the minimum length.
There is no option to change the email address on the profile screen, so the new-email verification step is unavailable. | Draft: Add an email-change option with verification.
There is no email-change verification screen for entering a wrong or expired code. | Draft: This depends on having an email-change feature first.
The profile does not offer email editing, so a duplicate replacement email cannot be submitted through this screen. | Draft: Check for duplicate emails when email editing is added.
A short phone number and another buyer's phone number were both saved without verification. | Reject invalid or duplicate numbers and verify a new number before saving it.
The profile photo picker supports selecting an image. Taking a photo and handling denied camera access still need checking on a phone. | Draft: A phone is needed to check the camera and permission messages.
Another signed-in session stayed active after the password was changed. | Sign out the other sessions when the password changes; phone behaviour still needs checking.
Sign-in is remembered, and logging out returns to the login screen. Force-closing the phone app and using the phone's Back button still need checking. | Draft: Confirm this on a phone before marking it passed.
""")

group('BUY-ADDR', """
An address can be saved without making it the default, but the form uses typed location fields. My Addresses opens the add form instead of a saved-address list. | Draft: Show saved addresses and provide the location dropdowns described in the case.
Province, city, and barangay are entered manually on the address form. There is no linked Region list that clears the selections below it. | Draft: Add linked location dropdowns to avoid mismatched addresses.
Empty recipient, phone, street, city, province, and barangay fields are required. There is no separate Region field on this form. | Draft: Required-field checks are present, but the Region part differs from the test.
The address form accepts a phone number without checking the required Philippine format. Short and long numbers are not specifically blocked. | Draft: Accept only valid 09 or +63 mobile numbers.
There is no ten-address limit, so adding an eleventh address is not specifically blocked. | Draft: Add the address limit and explain it when the buyer reaches it.
A new address can be marked as default, and checkout prefers it. There is no saved-address list for changing an existing address to default. | Draft: Let buyers choose the default from their saved addresses.
The app has no delete option in a saved-address list. The address-delete action also does not require choosing a new default first. | Draft: Keep one default address and make address management available.
Existing orders refer to the saved address, so changing that address can change the order's address details too. | Draft: Keep the original delivery address with each order.
Address changes are restricted to the signed-in buyer's own addresses. Another buyer's address is not included in that lookup. | Draft: Confirm with two test accounts before marking it passed.
There is no Use My Location option on the address form. The buyer needs to enter the address manually. | Not supported.
Phone is set up for a phone keyboard, while recipient and street use text input. Reaching Save with the phone keyboard open still needs checking. | Draft: Check the keyboard and Save button on a phone.
""")

group('BUY-SRCH', """
Opening a category filters the listing to active products in that category. The basket should appear when its test record is available. | Draft: Confirm the complete result list using the prepared test products.
The store page has products, search, sorting, and reviews, but no Home Decor or Lamps category tree. | Draft: Add store categories so buyers can browse by subcategory.
Search supports full names and partial words, ignores spaces at either end, and treats uppercase and lowercase searches alike. | Draft: Confirm all four searches return the basket.
An unmatched search shows a no-results message. The misspelled search does not offer a corrected spelling or suggestion. | Draft: Add a useful suggestion when the search contains a typo.
Search text is treated as text, but a percent sign can match many products instead of being treated literally. | Draft: Handle special search characters without broadening the results unexpectedly.
Searching with an empty box or spaces returns the normal product list. | Draft: The planned behaviour matches; confirm it in the running app.
There is an Under ₱500 shortcut, but no minimum-and-maximum price range to enter the listed amounts. | Draft: Add a price-range filter and reject invalid ranges.
The available shortcuts do not combine rating, category, and seller location as required in this case. | Draft: Keep all selected filters active together and clear them individually.
Price and rating sorting are available, but there is no best-selling sort or control to keep loading more results. | Draft: Complete the sort options and make the remaining products accessible.
Inactive and draft products are excluded from the normal listing and product details. Deleted-product links still need checking with prepared test records. | Draft: Confirm unavailable links show a clear message without exposing the product.
The buyer screens do not show an On Vacation notice or a purchase block for a vacation store. | Draft: Tell buyers when a store is away and block purchases as required.
The keyboard Search action runs the search. Pulling to refresh on Home reloads the general listing rather than keeping the same search results. | Draft: Keep the search term and filters when refreshing.
A failed search shows an error, but there is no dedicated offline message with a Retry button. Reconnecting and searching again still need checking. | Draft: Make the connection problem clear and provide an easy retry.
""")

group('BUY-PDP', """
An item can be added without choosing a variation. The page also keeps only one selected option instead of requiring both colour and size. | Draft: Require every variation choice before adding or buying the item.
Selecting a variation changes the displayed price. The available-stock text and photo do not change with that selection. | Draft: Show the selected variation's own stock and image.
An out-of-stock variation can still be selected. The stock warning comes when the buyer tries to add it to the cart. | Draft: Disable sold-out choices before the buyer tries to add them.
The quantity starts at one, and adding more than the available stock is rejected. Quantity is changed with buttons rather than a typing field. | Draft: Confirm the listed boundaries; variation limits also need checking.
There is no purchase limit that remembers how many units the buyer already bought in earlier orders. | Draft: Enforce the per-buyer limit across separate orders.
The product page does not show a flash-sale countdown, remaining flash units, or a Claim button for the voucher. | Draft: Show the sale details buyers need before purchasing.
Buy Now adds the product to the existing cart and opens that cart. Other items already in the cart are still included. | Draft: Open checkout for only the item chosen with Buy Now.
An unavailable product has a Product Not Found state, and inactive products are not returned as available items. | Draft: Confirm the deleted and inactive links both reach this state.
The gallery supports swiping, a position indicator, and a larger zoomable view. Gesture behaviour and keeping the variation selected still need checking. | Draft: Confirm swiping and zooming on a phone.
There is no Share action on the product page or a product-link opening flow for another phone. | Draft: Add sharing and open the correct product from the shared link.
""")

group('BUY-WISH', """
A signed-in buyer can save a product to Favorites and remove it again. The heart changes with the saved state returned by that action. | Draft: Confirm the Favorites list and reopened product stay in sync.
Favorites is limited to one saved entry for each buyer and product. Rapid taps and the final heart state still need checking. | Draft: Prevent repeated taps from leaving the heart in the wrong state.
Favorites does not provide the Sold Out and Unavailable placeholders described in this test. | Draft: Keep unavailable items understandable without breaking the list.
Following and unfollowing changes the store's follower count. There is no separate Following list to check. | Draft: Add a list of followed stores and keep it in sync.
Saving a favorite and following a store require the buyer to sign in first. | Draft: Confirm both guest actions return to login without saving anything.
""")

group('BUY-CART', """
Adding the same product and variation again increases the quantity on the existing cart line. | Draft: Confirm three units produce one line and the expected subtotal.
Different variations of the same product stay on separate cart lines with their own prices. | Draft: Confirm both selected variations and amounts in the cart.
Items are shown in one list instead of being grouped under their store names. | Draft: Group items by store to make the cart easier to review.
Selecting and deselecting changes the subtotal shown in the cart. Checkout still loads the whole cart, including unselected items. | Draft: Send only the selected items to checkout.
Quantity cannot go below one, and an amount above the available stock is rejected. | Draft: Confirm the one- and twenty-unit boundaries with the prepared stock.
The cart uses the current selling price when it is loaded again. A changed price is reflected after reloading the cart. | Draft: Confirm the price and subtotal both change to the new amount.
Unavailable items are not clearly disabled for selection. A stock problem in one item can also stop checkout for the rest of the cart. | Draft: Mark unavailable items and let the buyer check out the available ones.
The cart belongs to the buyer account and is kept after signing out. Loading the same cart on a second device still needs checking. | Draft: Confirm the same quantities appear after login on both devices.
Removing an item deletes its cart line and reloads the remaining items and subtotal. | Draft: Confirm the removed line stays gone when the cart is reopened.
Cart updates and removals are limited to items in the signed-in buyer's own cart. | Draft: Confirm another buyer's item cannot be changed through a direct request.
The displayed quantity changes after a successful save rather than immediately. Failed updates show an error, but reconnecting still needs checking. | Draft: Confirm the displayed quantity matches what was actually saved.
The bottom cart badge counts item lines rather than individual units. It loads when the bottom menu is created, so immediate changes are not guaranteed. | Draft: Keep the badge updated after each add or removal.
""")

group('BUY-VOU', """
Vouchers can be selected or entered at checkout, but there is no voucher wallet or Claimed state. | Draft: Add claiming and a wallet if this flow is required.
One voucher discounts the whole cart rather than a particular store group. The checkout also does not add the shipping charge in this example. | Draft: Apply store vouchers to the correct store and include shipping separately.
Only one voucher can be selected at a time. Store, platform, and shipping vouchers cannot be combined as in the example. | Draft: Add the agreed voucher-stacking rules.
The voucher is rejected below its minimum spend and allowed at the minimum. The message gives the required spend rather than how much more is needed. | Draft: Add a helpful message such as Spend ₱0.01 More.
Expired, future, exhausted, and unknown voucher codes are rejected with the same Invalid or Expired message. | Draft: Give a specific reason for each unavailable voucher.
There is no per-buyer usage check, so the same buyer is not specifically blocked from reusing the voucher. | Draft: Apply the limit separately to each buyer.
Checkout checks the minimum spend again before placing an order. The applied voucher is not automatically removed with a notice when the amount falls below the minimum. | Draft: Remove an ineligible voucher and update the total clearly.
A percentage voucher is capped at its maximum discount, and the discount is rounded to two decimal places. | Draft: Confirm each amount around the minimum and cap.
Shipping is not calculated separately, and shipping vouchers are not handled as a separate discount on that fee. | Draft: Apply free shipping to the delivery fee rather than the merchandise.
The voucher discount cannot reduce the merchandise total below zero. There is no separate shipping charge in the current total. | Draft: Keep the total non-negative and handle shipping separately.
Voucher calculations use the current sale price, so a sale item can still qualify. The extra shipping amount in the example is not included. | Draft: Confirm the sale discount and shipping breakdown together.
Cancelling an order does not restore the voucher's usage or return it to a voucher wallet. | Draft: Return an eligible voucher after cancellation.
""")

group('BUY-CHK', """
Checkout combines the cart into one order with one voucher. It does not create separate store orders or include the shipping breakdown in the worked example. | Draft: Split orders by store and show the full discount and shipping breakdown.
Changing the delivery address does not add or update a shipping fee. | Draft: Recalculate shipping for the selected address and store.
There is no shipping calculation based on the parcel's weight, so the one-kilogram boundary is not applied. | Draft: Calculate delivery fees using the agreed weight brackets.
Checkout checks that the address belongs to the buyer but does not block an area that delivery services cannot cover. | Draft: Check delivery coverage before allowing an order.
There is no Note to Seller field on the checkout screen. The order-note allowance also differs from the 200-character rule. | Draft: Add the note field with the agreed character limit.
Cash on Delivery is already selected, so there is no blank payment selection through the checkout screen. A request without a payment method is rejected. | Draft: The payment method is required, but the screen uses a default selection.
Place Order is disabled while an order is being submitted. Repeated or simultaneous submissions still need checking to confirm only one order is saved. | Draft: Confirm one order and one stock deduction after repeated taps.
A changed price is used when the order is placed, but the buyer is not asked to confirm the new amount first. | Draft: Show the new price and ask the buyer to confirm before placing the order.
Stock is checked again before an order is placed. Two buyers ordering at the same moment still need checking. | Draft: Confirm the last unit cannot be sold twice.
An invalidated voucher stops the order with an error, but the voucher and displayed total are not automatically refreshed. | Draft: Remove the invalid voucher and show the corrected total.
Checkout uses the real product prices rather than accepting a replacement total supplied in the order request. | Draft: Confirm a changed request cannot alter the amount charged.
A connection error is shown if the request fails. The app does not check whether the order was already saved before offering another attempt. | Draft: Recover the existing order after a lost response and avoid duplicates.
Checkout selections stay with the open screen. Interruptions, app switching, and reopening after the phone closes the app still need checking. | Draft: Check this on a phone with an address and voucher selected.
""")

group('BUY-PAY', """
A COD order starts under To Ship with payment still pending. The example's ₱500 total differs because checkout does not add the shipping charge. | Draft: Show the correct delivery-inclusive COD amount.
Cash on Delivery is the only payment option. There is no e-wallet or card payment screen. | Draft: Online payments are not available in this version.
There is no online-payment failure screen or Pay Again option. | Draft: This depends on adding an online payment method.
Checkout does not open a payment gateway, so there is no gateway-cancellation flow. | Draft: This flow is unavailable without online payments.
There is no gateway payment or payment-reference update to check after closing the app. | Draft: This depends on adding the online payment flow first.
There is no automatic cancellation for an unpaid online order. | Draft: Add the unpaid-order deadline if online payments are introduced.
There is no one-hour payment window or Pay action for an unpaid online order. | Draft: The fifty-nine- and sixty-one-minute cases cannot be completed in this version.
The app does not open an e-wallet or return from an e-wallet payment. | Draft: This requires an online payment method and a phone check.
There is no online-payment processing screen to leave with Back. | Draft: Add payment recovery and Back handling when this flow is available.
""")

group('BUY-TRK', """
The order tabs are All, To Ship, In Transit, Delivered, and Cancelled. To Pay, Completed, and Return/Refund are not available. | Draft: Match the order tabs to the agreed order flow.
Order details show saved status updates and a basic progress display. The complete hub-to-hub timeline still needs updates from the seller and delivery roles. | Draft: Confirm every event using the connected delivery workflow.
There is no Order Received button to move a delivered order to Completed. | Draft: Add buyer confirmation and the corresponding completion step.
Order Received is unavailable before delivery, but it is also unavailable after delivery. | Draft: The intended delivery-based eligibility rule is not complete.
There is no seven-day automatic completion step for delivered orders. | Draft: Add completion after the agreed delivery window.
Order details are limited to orders belonging to the signed-in buyer. Another buyer's order is not included in that lookup. | Draft: Confirm access is refused with two separate test accounts.
Order updates can appear in the in-app inbox, but there is no phone push notification that opens the related order. | Draft: Add push notifications and the matching order link.
""")

group('BUY-CAN', """
A pending or confirmed order can be cancelled after a confirmation message. A reason is not collected, and stock restoration differs for variation purchases. | Draft: Collect the reason and restore stock to the exact variation bought.
Cancellation only asks for confirmation and does not require a reason. | Draft: Ask the buyer to choose a reason before cancelling.
Prepaid orders and automatic refunds are not available. Cancelling also does not restore the voucher's usage. | Draft: Add the refund and voucher-return flow for prepaid cancellations.
Cancel is offered only for pending and confirmed orders. The Ready for Pickup step still needs checking against the seller's order flow. | Draft: Confirm cancellation is unavailable once pickup preparation reaches the agreed cutoff.
Cancel is hidden after the order leaves pending or confirmed, and later cancellation requests are rejected. | Draft: Confirm both the screen and a direct request reject cancellation after shipping.
A repeat cancellation is rejected after the order is already cancelled. Simultaneous taps still need checking to confirm stock is restored only once. | Draft: Confirm one cancellation and one stock restoration.
""")

group('BUY-RET', """
There is no Return/Refund option for submitting a damaged-item request with photos. | Draft: Add the return-request form and its order status.
Returns are unavailable before delivery and after delivery, so the intended delivery-based restriction cannot be checked. | Draft: This depends on having a working return-request feature.
There is no return-request window, so the seven-day boundary cannot be checked. | Draft: Add the return window before checking its limits.
There is no return form for entering a description or attaching evidence. | Draft: Add the required description and photo checks with the return feature.
Return-request status, rejection reasons, and an Escalate option are not available. | Draft: Let the buyer follow the request and respond to a rejection.
There is no return-evidence picker for taking or selecting photos. | Draft: Add evidence uploads, then check camera and gallery behaviour on a phone.
""")

group('BUY-RATE', """
Delivered orders can be rated with stars and a written comment. Review photos, masked names, and the full variation display are not provided as described. | Draft: Complete the review details and photo attachments.
The rating button is shown for delivered orders, but a direct rating submission is not restricted to completed or delivered orders. | Draft: Enforce review eligibility even when the button is bypassed.
Submitting another review updates the existing review instead of creating a second one. The screen does not switch to an Edit-only option. | Draft: Show the existing review and provide Edit instead of another new submission.
Ratings are limited to one through five stars, but comments allow 2,000 characters rather than 500. Review photos are unavailable. | Draft: Apply the agreed text and photo limits.
There is no one-edit limit or thirty-day deadline on changing a review. | Draft: Limit edits and stop changes after the agreed window.
The product's average rating is recalculated from visible reviews. A five-star and a one-star review would give an average of 3.0. | Draft: Confirm both the average and review count on the product and search listing.
There is no camera or multi-photo selection option in the review form. | Draft: Add review photos and enforce the five-photo limit.
""")

group('BUY-CHAT', """
The app supports text conversations with a seller, but not photo attachments or a product card in the conversation. The main product Chat shortcut opens the message list. | Draft: Open the correct seller conversation and include the product and photo.
Messages allow up to 2,000 characters, so a 1,001-character message is not blocked by the stated limit. Attachments are unavailable. | Draft: Apply the agreed message limit and add safe attachment checks.
The notification inbox shows order-history updates and can open the related order. Exactly one notification per change still needs checking. | Draft: Confirm the count and destination for each order update.
There is no flash-sale reminder option or notification linked to the upcoming sale. | Draft: Add reminders if scheduled flash sales are required.
Opening a notification marks it read, and Mark All as Read clears the unread total. | Draft: Confirm the three-to-two-to-zero sequence with three unread updates.
Chat messages do not generate a phone push notification that opens the conversation. | Draft: Add background message notifications and a direct conversation link.
The in-app inbox is separate from phone notification settings, but phone push notifications are not available in this version. | Draft: Check permission behaviour after push notifications are added.
The message text is cleared before sending finishes. A failed send shows an error without keeping an unsent message or offering Retry. | Draft: Keep failed messages available for retry so buyers do not lose their text.
""")

# Only these outcomes were actually demonstrated before the user stopped Chrome work.
CONFIRMED = {
    'BUY-ACCT-001': 'Fail',
    'BUY-ACCT-002': 'Fail',
    'BUY-ACCT-003': 'Pass',
    'BUY-ACCT-004': 'Fail',
    'BUY-ACCT-005': 'Fail',
    'BUY-ACCT-009': 'Fail',
    'BUY-ACCT-011': 'Fail',
}


def cell_pattern(address):
    return re.compile(r'<c\b(?=[^>]*\br="' + re.escape(address) + r'")([^>]*?)(?:/>|>.*?</c>)', re.S)


def value(cell, shared):
    v = cell.find('s:v', NS)
    if cell.attrib.get('t') == 's' and v is not None:
        return shared[int(v.text)]
    if cell.attrib.get('t') == 'inlineStr':
        return ''.join(t.text or '' for t in cell.iter('{' + NS['s'] + '}t'))
    return v.text if v is not None else ''


def replace_cell(xml, address, text):
    match = cell_pattern(address).search(xml)
    assert match, address
    attrs = re.sub(r'\s+t="[^"]*"', '', match.group(1))
    new = f'<c{attrs} t="inlineStr"><is><t xml:space="preserve">{escape(text)}</t></is></c>'
    return xml[:match.start()] + new + xml[match.end():]


def main():
    assert len(ANSWERS) == 131
    seen = set()
    changes = {}
    permitted = {}
    report = []
    with ZipFile(SOURCE) as original:
        shared = [''.join(t.text or '' for t in si.iter('{' + NS['s'] + '}t')) for si in ET.fromstring(original.read('xl/sharedStrings.xml'))]
        for path in original.namelist():
            if not re.fullmatch(r'xl/worksheets/sheet\d+\.xml', path):
                continue
            raw = original.read(path).decode('utf-8')
            tree = ET.fromstring(raw)
            revised = raw
            addresses = []
            for row in tree.findall('s:sheetData/s:row', NS):
                cells = {c.attrib['r'].rstrip('0123456789'): c for c in row}
                case_id = value(cells['A'], shared) if 'A' in cells else ''
                if case_id not in ANSWERS:
                    continue
                assert case_id not in seen
                seen.add(case_id)
                entry = ANSWERS[case_id]
                assert not value(cells['K'], shared) and not value(cells['M'], shared), 'Preserve existing user answers'
                status = CONFIRMED.get(case_id, 'Not Run')
                values = {'K': entry['actual'], 'L': status, 'M': entry['remark']}
                for col, text in values.items():
                    address = f'{col}{row.attrib["r"]}'
                    revised = replace_cell(revised, address, text)
                    addresses.append(address)
                report.append({'id': case_id, 'status': status, 'basis': 'observed in Chrome before testing was stopped' if case_id in CONFIRMED else 'draft assessment, not executed', **entry})
            if addresses:
                before = raw
                after = revised
                for address in addresses:
                    before = cell_pattern(address).sub(f'<ANSWER_{address}/>', before, count=1)
                    after = cell_pattern(address).sub(f'<ANSWER_{address}/>', after, count=1)
                assert before == after, f'Unexpected template change: {path}'
                changes[path] = revised.encode('utf-8')
                permitted[path] = set(addresses)
        assert seen == ANSWERS.keys()
        with ZipFile(TARGET, 'w') as output:
            output.comment = original.comment
            for info in original.infolist():
                output.writestr(info, changes.get(info.filename, original.read(info.filename)))

    with ZipFile(SOURCE) as original, ZipFile(TARGET) as output:
        assert original.namelist() == output.namelist()
        assert output.testzip() is None
        for path in original.namelist():
            if path not in changes:
                assert original.read(path) == output.read(path), path
            if path.endswith('.xml'):
                ET.fromstring(output.read(path))
            if path in changes:
                before = {c.attrib['r']: c for c in ET.fromstring(original.read(path)).findall('s:sheetData/s:row/s:c', NS)}
                after = {c.attrib['r']: c for c in ET.fromstring(output.read(path)).findall('s:sheetData/s:row/s:c', NS)}
                assert before.keys() == after.keys()
                for address, cell in before.items():
                    if address not in permitted[path]:
                        assert ET.tostring(cell) == ET.tostring(after[address]), (path, address)
                    else:
                        assert cell.attrib.get('s') == after[address].attrib.get('s'), (path, address)
    (BASE / 'user_style_answer_notes.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'file':str(TARGET),'cases_answered':len(seen),'confirmed_results':len(CONFIRMED),
        'unexecuted_cases':'Not Run, with draft remarks','template_changes':'Only Actual Result, Status and Remarks cells',
        'validation':'ZIP, XML and all non-answer cells verified'},ensure_ascii=False))


if __name__ == '__main__':
    main()
