"""Fill review copies without changing the original XLSX formulas or assets."""
from pathlib import Path
from zipfile import ZipFile
from xml.sax.saxutils import escape
import json
import math
import re
import sys
import textwrap
import xml.etree.ElementTree as ET

sys.stdout.reconfigure(encoding='utf-8')
OUT = Path(__file__).resolve().parent
INVENTORY = json.loads((OUT / 'workbook_inventory.json').read_text(encoding='utf-8'))
SOURCE = Path(r'C:\Users\LENOVO\Downloads')
NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
ANSWERS = {}


def group(prefix, text):
    lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
    for number, line in enumerate(lines, 1):
        finding, answer = line.split('|', 1)
        ANSWERS[f'{prefix}-{number:03}'] = (finding.strip(), answer.strip())


group('TC-BUY', """
Partial | The registration flow leads to email verification, but Invoiz also asks for sex and a complete province, municipality, and barangay address. The account stays pending until an admin approves it.
Partial | Empty name, email, phone, sex, and password fields have required checks. Birthday and address use separate messages, so they are not all highlighted together.
Partial | Required fields are checked before submission, and entered values stay in the form. Birthday uses a separate message rather than an error directly below the field.
Gap | The current name checks do not reject numbers or symbols, so names like Juan123 are not specifically blocked.
Supported | The name fields allow accented letters and punctuation, including Niño and Peñaflor-O'Hara. Saving the exact spelling still needs a live registration check.
Gap | Invoiz allows names up to 100 characters and has no two-character minimum. The workbook's one- and 51-character rejection rules are not implemented.
Gap | The app calculates age but does not require buyers to be 18. Use dates relative to the actual test day when checking this boundary.
Supported | The date picker excludes future birthdays, and the server also requires a date before today. The date labelled tomorrow in the workbook should be checked against the actual test day.
Partial | The app checks for an @ sign, and the server applies a stricter email check. The exact messages and all five examples still need a live test.
Supported | Registration checks whether the email is already used and rejects a duplicate. This needs an existing test account to confirm the message on the phone.
Supported | The supplied database schema treats email addresses without regard to letter case, so the uppercase address should count as a duplicate. The running database still needs checking.
Supported | Spaces at the start and end of the email are removed before registration is sent.
Gap | Phone numbers are checked as required text, without a Philippine mobile-number format rule. The invalid examples are not specifically rejected for their format.
Gap | There is no 11-digit phone-number rule in the current form or server checks. Both shorter and longer numbers can pass those checks.
Gap | The current registration checks do not require a unique phone number, so an existing number is not blocked on that basis.
Gap | Invoiz does not normalise +63 and 09 phone numbers or check whether they belong to an existing account.
Supported | The server requires at least eight password characters. The seven-character example should be rejected, while the eight-character example meets the length rule.
Gap | Passwords only need eight characters and a matching confirmation. Uppercase letters, lowercase letters, numbers, and symbols are not all required.
Supported | A different confirmation password is blocked with a passwords-do-not-match message.
Partial | Passwords are hidden while typing. The registration form does not include an eye icon to reveal and hide them.
Missing | I couldn't find a Terms and Privacy checkbox on the registration screen. Submitting does not depend on accepting those terms.
Needs live check | Register is disabled while a request is running, and email addresses must be unique. Repeated taps still need testing to confirm only one account and one email are created.
Gap | A correct code verifies the email and returns the buyer to login. It does not approve the account; admin approval is still needed.
Supported | A wrong code returns a clear error and leaves the email unverified. Five wrong attempts lock that code until a new one is requested.
Partial | The OTP field accepts six digits, filters out letters, and blocks a blank or short code. Pasting a longer value is limited to six digits rather than necessarily showing an error.
Gap | Invoiz codes last 10 minutes, so a code entered just after five minutes has not expired yet.
Supported | Resending replaces the previous unused code, and another resend is limited to once a minute. Actual email delivery still needs checking.
Supported | Login is refused until the email is verified, and the response tells the buyer to verify it first.
Gap | A newly verified buyer still cannot log in while approval is pending. The test needs an admin-approved account before expecting the home screen.
Needs access test | This project provides buyer screens and seller-application endpoints, rather than all the dashboards listed here. The listed role links and direct requests need separate access checks; login protection alone does not prove role isolation.
Partial | Email, phone, and OTP fields request suitable keyboards. Name capitalisation and password suggestion settings are not explicitly configured, so the full case needs a phone check.
Device check | The form scrolls and Android is set to resize around the keyboard. Visibility of every field, error, and Register button still needs checking on a phone.
Device check | Typed values are held while the registration screen stays alive. Returning after a call, lock, or app switch needs testing, especially if the phone closes the app in the background.
Device check | No portrait-only lock is declared, and form values are kept in screen state. Rotation and error-message layout still need checking on a phone.
Partial | A failed registration request shows a connection message and leaves the form values available. Reconnecting and confirming a single saved account still needs a live test.
Needs live check | A connection error is handled, but there is no recovery step to check whether the first registration already succeeded. A dropped response could leave the buyer needing to log in to continue verification.
Partial | The OTP uses one field that accepts pasted digits. A valid code verifies the email, but the account still needs admin approval.
Gap | The OTP screen has a resend cooldown, rather than a code-expiry countdown. Codes expire after 10 minutes, so the five-minute behaviour in this case does not match Invoiz.
Gap | Leaving the registration form does not ask to discard typed information. Login can send an unverified buyer back to email verification, but Back behaviour still needs a phone check.
Device check | The form is scrollable, but that alone does not confirm readability at the largest font size. A small-screen phone check is still needed.
Needs live check | Invoiz saves the login session and reloads it when the app starts. Closing the app and restarting a phone still need testing to confirm the correct buyer stays signed in.
Needs live check | Logout removes the saved session and clears the navigation stack to login. Pressing Back and reopening the app still need a phone check.
""")

group('BUY-ACCT', """
Supported | The profile form supports saving a new name and gallery photo, then refreshing the buyer's details. The photo and name still need checking after re-login.
Gap | Blank names are checked, but one-character names and names containing numbers are not specifically blocked. Profile uploads also have no explicit five-megabyte or image-content validation in the controller.
Partial | A new password can be saved from Edit Profile with a matching confirmation. There is no current-password field, so the exact flow in this case is different.
Gap | The password-change form does not ask for the old password, and the server does not check it before updating the password.
Gap | Invoiz checks the eight-character minimum and matching confirmation. It does not enforce all character types or reject reusing the old password.
Missing | Email is not an editable profile field, and I couldn't find an email-change verification flow.
Missing | There is no email-change OTP process to try with a wrong or expired code. The registration OTP process is a separate feature.
Missing | Changing the login email is not available in the current buyer profile. Duplicate-email checks exist for registration instead.
Gap | Phone numbers can be edited directly in the profile. There is no phone OTP, unique-number check, or Philippine-number format check in that update.
Partial | Profile photos can be selected from the gallery. There is no Take Photo choice or custom camera-permission recovery flow on this screen.
Gap | Changing a password does not revoke the account's other login tokens. Signing out another phone after the change is not implemented in this update.
Needs live check | The app saves the login session and clears navigation to login on logout. Closing, reopening, and pressing Back still need testing on a phone.
""")

group('BUY-ADDR', """
Partial | A new address can be added and left unmarked as default. The current address form uses typed place names, and the account menu opens Add Address rather than an address-book list.
Gap | The shipping-address form uses text fields for province, city, and barangay. The linked dropdowns belong to registration, so this address-book cascade is not available.
Partial | Recipient, phone, street, barangay, city, and province have required checks. There is no Region field in this form.
Gap | The address form checks that a phone value is present but does not enforce the two Philippine mobile formats. Short and long numbers are not specifically rejected for their length.
Gap | I couldn't find a ten-address limit in the address controller. The eleventh address is not specifically blocked by that rule.
Partial | A newly added address can be marked default, and checkout prefers the default address. The app has no address-book screen for selecting and changing an existing default.
Gap | The delete endpoint does not protect the default address or select a replacement. A database restriction may block deleting an address used by an order, but it does not enforce the default-address rule.
Gap | An order links to the saved address instead of keeping a separate address copy. Editing that address could change the order's address details, while deleting a referenced address is restricted by the supplied schema.
Supported | Address updates and deletions are restricted to the signed-in buyer's records. There is no public endpoint for viewing another buyer's address.
Missing | I couldn't find a Use My Location option or location lookup in the shipping-address form. Addresses are entered manually.
Device check | Phone uses a phone keyboard, while recipient and street use text fields in a scrollable form. Reaching Save with the keyboard open still needs a phone check.
""")

group('BUY-SRCH', """
Supported | Category browsing filters active products by their category. The named sample product and complete result list need checking with the workbook's test data loaded.
Missing | The store page offers products, search, sorting, and reviews. The seller-defined category tree described in this case is not available.
Supported | Searches use product names and descriptions, and the app trims outer spaces. The supplied database uses case-insensitive text matching, so the named test product needs checking in that database.
Partial | An unmatched search has a no-results state. There is no spelling correction or Did You Mean suggestion for the typo.
Partial | Search values are passed as query values, and product text is shown as plain text. Percent signs are not escaped as literal search characters, so searching % can match many products.
Supported | An empty search returns the normal listing instead of submitting a special empty-result search.
Missing | There is an Under ₱500 shortcut, but no editable minimum-and-maximum price range. The requested boundary values cannot be entered through the current filters.
Gap | The Home shortcuts filter the original loaded product list rather than combining every active search and category filter. The full combined-filter result is not guaranteed.
Partial | Price, rating, and discount sorting are available. The screens load a fixed first page and do not implement loading further pages while scrolling.
Partial | Product listings and detail requests filter for active products. Opening the listed links and confirming the unavailable screen still needs a live test.
Missing | I couldn't find a vacation-store flag or an On Vacation purchase block in the buyer app.
Partial | The keyboard Search action is connected, and Home has pull to refresh. Home refresh reloads the general list, so it does not preserve the same filtered search results.
Needs live check | Failed searches show an error message, but the app has no dedicated offline search or retry state. Airplane-mode recovery needs testing with the named product available.
""")

group('BUY-PDP', """
Gap | A buyer can submit without selecting a variant, and the page stores only one selected variant at a time. It does not require both colour and size selections as described.
Partial | Choosing a variant changes the displayed price. The stock text and gallery do not switch to that variant's stock and image.
Gap | Variant chips are still selectable when their stock is zero. The server checks stock when adding the item instead of disabling the choice.
Partial | Quantity buttons keep the number at one or above, and the server rejects quantities beyond available stock. The page uses product stock for its upper limit rather than the selected variant's stock.
Missing | I couldn't find a per-buyer purchase limit that carries across previous orders. Quantity checks only compare against available stock.
Gap | Sale listings support comparison prices, but the detail page has no flash-sale countdown, remaining flash allocation, or voucher Claim button.
Gap | Buy Now adds the item to the shared cart and opens that cart. It does not start a checkout containing only the selected product.
Supported | A failed product lookup has a Product Not Found state, and inactive products are excluded by the API. The unavailable-link flow still needs checking in the app.
Needs live check | The product gallery supports swiping, a position indicator, and a full-screen zoom viewer. Image quality and keeping the selection after closing the viewer still need a phone check.
Missing | The product page has no share action, and no product-link handler is declared in the Android manifest. This cross-phone sharing flow is not implemented.
""")

group('BUY-WISH', """
Supported | A signed-in buyer can toggle a product in Favorites and remove it from the list. The heart is updated from the toggle response; reopening the product still needs a live check.
Needs live check | The database allows only one favorite per buyer and product. Rapid taps are not disabled, so the final heart state and any request errors still need checking.
Gap | Favorites do not provide the described Sold Out and Unavailable placeholders. A missing product is also not handled when the list reads its saved items.
Partial | Follow and Unfollow update the store's follower count. There is no separate Following list in the current buyer screens.
Supported | Saving favorites and following a store require login in the app and authenticated API access.
""")

group('BUY-CART', """
Supported | Adding the same product and variant again increases the existing cart line's quantity. The exact subtotal depends on the product and variant prices in the test database.
Supported | Different variant IDs are saved as separate cart lines, each with its own price adjustment.
Missing | The cart shows a flat list of items. It does not group them under store headings.
Gap | Selecting items changes the subtotal shown in the cart. Checkout reloads the whole cart, so unselected items are included too.
Supported | Quantity cannot go below one through the cart buttons, and the server rejects an amount above stock. The 20-unit boundary needs a product with exactly 20 units available.
Supported | Cart prices are recalculated from the current product price and variant adjustment when the cart is loaded. The screen needs reloading to see a seller's price change.
Gap | Cart items are not disabled based on product availability. Checkout checks stock for the whole cart, and missing product records are not handled as unavailable placeholders.
Supported | Cart items are saved against the buyer account on the server. The same cart should load after login on another device, but that still needs a two-device test.
Supported | Removing an item deletes that buyer's cart line and reloads the cart so the subtotal can be recalculated.
Supported | Cart updates and deletions look up the item inside the signed-in buyer's cart. Another buyer's line is excluded from that lookup.
Needs live check | The displayed quantity changes only after the update succeeds and the cart reloads. A failed request shows an error; recovery after reconnecting still needs a phone check.
Partial | The bottom badge counts cart lines, not individual units. It loads when the navigation bar is created, so immediate updates after every cart change are not guaranteed.
""")

group('BUY-VOU', """
Missing | Vouchers are listed for selection or code entry, but there is no claimable voucher wallet or Claimed state.
Gap | A single voucher discounts the whole cart subtotal. There is no store-specific discount group or shipping fee in this checkout.
Gap | Checkout accepts only one voucher code. Store, platform, and shipping vouchers cannot be stacked as in the worked example.
Partial | Voucher validation rejects a subtotal below the minimum and accepts it at the minimum. The message states the required spend rather than calculating Spend ₱0.01 More.
Partial | Expired, future, exhausted, and unknown codes are rejected. They share an Invalid or Expired Voucher message instead of separate explanations.
Missing | Voucher usage is tracked globally, without a per-buyer redemption limit. The Already Used rule in this case is not implemented.
Partial | Checkout rechecks the voucher against the current subtotal before placing an order. There is no automatic removal notice when the cart falls below the minimum.
Supported | Percentage discounts use the voucher's maximum discount and are rounded to two decimal places. The stated amounts need matching voucher and product records to verify live.
Missing | There is no separate shipping charge or shipping-voucher type in the current checkout. A code named FREESHIP does not by itself add that feature.
Partial | The server caps a discount at the cart subtotal so the merchandise total cannot go below zero. Separate shipping charges are not implemented.
Partial | Vouchers are calculated from the current selling price rather than the comparison price. The workbook's extra shipping charge is not part of Invoiz's total.
Gap | Cancellation does not return a voucher or reduce its used count. There is also no buyer voucher wallet to restore it to.
""")

group('BUY-CHK', """
Gap | Invoiz creates one order for the whole cart and accepts one voucher. It does not split orders by store or include the shipping charges and stacked discounts in this example.
Missing | Changing the selected address does not calculate a shipping fee. The current total is the cart subtotal minus one voucher discount.
Missing | I couldn't find weight-based shipping calculations in checkout. The one-kilogram boundary is not applied.
Missing | Checkout checks that the address belongs to the buyer, but it does not check whether a delivery area is serviceable.
Gap | The buyer checkout has no Note to Seller field. The API allows notes up to 1,000 characters rather than the workbook's 200-character rule.
Partial | COD is selected by default, so the buyer cannot leave the payment method blank through this screen. A direct request without a method is rejected by the server.
Needs live check | Place Order is disabled while a request runs, and a successful checkout clears the cart. There is no server request key to guarantee the same order under simultaneous duplicate requests.
Gap | Checkout recalculates the latest price on the server but does not ask the buyer to confirm a price change. The saved total can therefore differ from the earlier displayed summary.
Partial | Stock is checked again before the order is saved. The check happens outside the transaction without a stock lock, so simultaneous purchases still need testing.
Partial | The server rejects a voucher that is no longer active and shows an error. The app does not automatically remove it and refresh the displayed total.
Supported | Checkout builds prices and totals from server-side product records. A submitted replacement total is not used in that calculation.
Needs live check | Connection errors are shown, but checkout does not look up a possibly saved order after a lost response. A dropped connection needs testing to confirm the order and stock change happen only once.
Device check | Address, voucher, and COD selections stay in screen state while checkout remains open. Calls, app switching, and recovery after the phone closes the app need a device test.
""")

group('BUY-PAY', """
Partial | A COD checkout creates a pending order shown under To Ship, with payment still pending. The stated ₱500 total is not reproduced automatically because this app adds no shipping fee.
Missing | Checkout only supports Cash on Delivery. There is no e-wallet or card gateway flow to test.
Missing | There is no online payment failure state or Pay Again action in this buyer app.
Missing | No payment gateway is opened, so there is no gateway cancellation or return flow.
Missing | Online payment callbacks and gateway references are not implemented. Closing the app during that flow cannot be tested here.
Missing | I couldn't find an unpaid-payment auto-cancel process. Current checkout creates COD orders rather than unpaid online orders.
Missing | There is no one-hour payment deadline or gateway payment flow, so the 59- and 61-minute boundary is not implemented.
Missing | The app does not open an external e-wallet or handle a payment return link. Only COD is available.
Missing | There is no gateway-processing screen or Back-handling flow for online payments in this app.
""")

group('BUY-TRK', """
Gap | The buyer tabs are All, To Ship, In Transit, Delivered, and Cancelled. They do not include To Pay, Completed, or Return/Refund as listed in this test.
Partial | Order details show saved status-history entries and a basic progress indicator. The complete hub, courier, and handover flow needs connected seller and logistics updates that were not tested.
Missing | There is no Order Received button or buyer completion endpoint. Seller earnings becoming available is not handled by this buyer flow.
Partial | Order Received is absent at every stage, including before delivery. That does not confirm the intended delivery-to-completion feature, which is missing altogether.
Missing | I couldn't find a seven-day automatic completion process in the supplied buyer backend.
Supported | Order details are looked up using both the order ID and the signed-in buyer's ID. Another buyer's order is excluded from that lookup.
Missing | Order updates appear in the in-app inbox, but push notifications and notification links into order tracking are not implemented.
""")

group('BUY-CAN', """
Partial | A pending or confirmed COD order can be cancelled after a confirmation prompt. There is no cancellation-reason field, and variant purchases restore product stock rather than the selected variant's stock.
Gap | Cancellation only asks for confirmation. A reason is not requested or required by the API.
Missing | Prepaid checkout and automatic refunds are not available. Cancellation also does not restore voucher usage.
Partial | Cancel is limited to pending and confirmed orders in both the screen and API. The seller's Ready for Pickup status needs checking against those actual status values.
Supported | The Cancel button is hidden once an order leaves pending or confirmed, and the API rejects cancellation for later statuses.
Needs live check | A later repeat request is refused once the order is cancelled. The cancellation and stock restoration are not locked together, so simultaneous taps still need testing.
""")

group('BUY-RET', """
Missing | I couldn't find a Return/Refund request screen or endpoint in this buyer app. A damaged-item request with photo evidence cannot be submitted here.
Missing | Returns are unavailable throughout the current app, including before delivery. This does not demonstrate a working delivery-based eligibility rule.
Missing | There is no return window or return-request flow, so the seven-day boundary is not enforced here.
Missing | Return descriptions and evidence uploads are not implemented, so their required fields and limits cannot be checked.
Missing | The app has no return-request tracking, seller rejection details, or Escalate option.
Missing | There is no return-evidence screen with camera or gallery attachments. This two-photo submission flow is not available.
""")

group('BUY-RATE', """
Partial | Delivered orders have a star-rating and optional feedback form. It does not accept review photos or provide the complete masked-name and variant display described here.
Gap | The screen offers rating for delivered orders, but the API does not require delivery or completion before saving a review. Owning the order and its product is enough for that request.
Gap | Another submission updates the same buyer, product, and order review instead of adding a duplicate. The app does not switch to an Edit-only flow or refuse the second submission.
Gap | The server accepts ratings from one to five and comments up to 2,000 characters. Review photos and the workbook's 500-character limit are not implemented.
Gap | There is no one-edit limit or 30-day review deadline. Submitting again can keep updating the existing review.
Supported | Saving a review recalculates the product's average from visible reviews and rounds it to one decimal place. Two reviews of five and one stars would give 3.0; the visible count still needs checking.
Missing | The review form has no photo picker or camera action, so the five-photo selection flow is not available.
""")

group('BUY-CHAT', """
Partial | Seller-linked text conversations are supported, but photos and product cards are not attached to messages. The product page's main Chat shortcut also opens the general message list.
Gap | Chat messages can contain up to 2,000 characters, so a 1,001-character message is not rejected by that rule. File attachments are not supported.
Partial | The inbox builds order notifications from the buyer's saved status history and opens the related order. Exactly one entry per external status change still needs a live integration check.
Missing | I couldn't find a flash-sale reminder or reminder subscription in this buyer app.
Supported | Opening a notification marks it read, and Mark All as Read clears the inbox's unread total. The 3-to-2-to-0 sequence still needs checking with three unread entries.
Missing | Chat has no background push-notification service or notification link that opens a conversation.
Partial | The in-app notification list is separate from phone push permissions. This app has no push service, so turning notifications off does not test a working push-permission flow.
Gap | Sending clears the text before the request succeeds, and a failure only shows an error. There is no saved unsent message, retry action, or automatic resend.
""")

MOBILE_RULES = {
    'M1': 'This review uses the Flutter buyer source, version 1.0.0+1; no installed mobile build or device session was tested.',
    'M2': 'Email, phone, and OTP keyboard types are configured where used. Other keyboard behaviour and keeping controls visible need a phone test.',
    'M3': 'The OTP is one six-digit numeric field. Codes last 10 minutes; the screen only counts down the 60-second resend cooldown.',
    'M4': 'Forms keep values in screen state, but there is no saved draft for process termination. Calls, rotation, locking, and app switching need a phone test.',
    'M5': 'Requests are sent online with error messages; offline actions are not queued. Dedicated retry and recovery for a lost server response are not implemented.',
    'M6': 'The profile uses a gallery picker. Custom camera, location, and push-permission recovery flows are not implemented; native permission behaviour needs a device test.',
    'M7': 'Profile and ID images are picked from the gallery. The buyer form does not offer camera or PDF selection, and upload controllers have no explicit five-megabyte limit.',
    'M8': 'Forms do not ask before discarding typed values. Logout clears navigation to login; system Back and swipe behaviour still need testing.',
    'M9': 'Login tokens and buyer details are saved locally and restored on startup. Password updates do not revoke other login tokens.',
    'M10': 'In-app order and review notifications are implemented. Background push notifications and push links are not.',
    'M11': 'Owner checks exist on buyer records, but the Android manifest has no product-link handler. Cross-role and direct-request behaviour was not executed.',
    'M12': 'The current app uses its light theme. Large fonts, small screens, keyboard overlap, and rotation still need checking on devices.',
    'M13': 'Rider location and online status belong to a rider application and are outside this buyer review.',
    'M14': 'Live barcode scanning and proof-of-delivery photos belong to other roles and are outside this buyer review.',
}

ACCOUNT_RULES = {
    'A1': 'Buyer registration also asks for sex, birthday, province, municipality, and barangay. It has no Terms checkbox or buyer ID-upload control.',
    'A2': 'Names are required text up to 100 characters, with no two-character minimum or letters-only restriction.',
    'A3': 'Email is validated and unique in the users table; the app trims outer spaces. The supplied schema compares emails without regard to letter case.',
    'A4': 'Phone is required text up to 30 characters. There is no Philippine format, uniqueness, or +63-to-09 normalisation rule.',
    'A5': 'The server requires eight characters and matching confirmation, without character-complexity requirements.',
    'A6': 'Birthday must be before today, but there is no minimum age of 18. Age is calculated for display and storage.',
    'A7': 'Registration links Province, Municipality, and Barangay dropdowns. Shipping addresses use manual text fields, with an optional postal code.',
    'A8': 'The buyer registration form does not collect a TIN. Seller and logistics tax rules were not assessed.',
    'A9': 'A six-digit email code lasts 10 minutes; resend replaces unused codes and is limited to once per 60 seconds. Five wrong attempts lock that code.',
    'A10': 'The buyer registration screen has no upload control. Profile uploads use gallery images and have no explicit type or five-megabyte validation in the controller.',
    'A11': 'Seller document requirements belong to the seller application flow and were not assessed as buyer registration requirements.',
    'A12': 'Registration creates a pending buyer with an unverified email. OTP verifies the email; login still requires admin approval and active account status.',
    'A13': 'Rider account creation and activation are outside the supplied buyer flow.',
    'A14': 'These business identifiers are not collected by buyer registration; their uniqueness was not assessed.',
    'A15': 'Buyer registration does not collect a driver licence. Rider and courier licence checks are outside this review.',
    'A16': 'Buyer record endpoints check ownership and use authenticated access. Full cross-role isolation needs separate testing; the API group has no explicit buyer-role middleware.',
    'A17': 'Courier account creation and activation are outside the supplied buyer flow.',
    'A18': 'Courier licence and vehicle rules are outside the supplied buyer flow.',
}

MODULE_RULES = {
    'A1': 'The workbook accounts and product fixtures were not created or reset. This is a source review rather than a live test using those accounts.',
    'A2': 'Checkout accepts one voucher code for the entire cart. There is no store, platform, and shipping voucher stack.',
    'A3': 'Checkout deducts stock when an order is placed. Cancellation restores product stock even for a variant purchase, and concurrent stock checks are not locked.',
    'A4': 'Voucher spend uses the current selling price plus any variant price adjustment. Comparison prices are not charged.',
    'A5': 'Comparison-price sale listings exist, but timed flash sales, flash allocations, and mixed-price overflow lines are not implemented.',
    'A6': 'Buyer cancellation is allowed for pending and confirmed orders. Online-payment deadlines and unpaid auto-cancellation are not implemented.',
    'A7': 'The detail page stores one selected variant ID, even when options are displayed in groups. The buyer store page has no custom category tree.',
    'A8': 'There is one order-level voucher discount, without voucher funding attribution, store splitting, or refund allocation.',
    'A9': 'Buyer totals are rounded to two decimal places. Seller commissions and earnings are not calculated by this buyer checkout.',
    'A10': 'Buyer tabs are All, To Ship, In Transit, Delivered, and Cancelled. Progress shows Placed, Confirmed, On the Way, and Delivered.',
    'A11': 'There is no Order Received action, automatic completion process, or return-request window in the supplied buyer code.',
    'A12': 'Reviews accept one to five stars and up to 2,000 comment characters, without photos. The API checks order ownership and product membership but has no completion, age, or edit-count gate.',
    'A13': 'Failed-delivery attempt limits and Return to Sender are logistics features outside this buyer review.',
    'A14': 'Rider job acceptance and assignment rules are outside this buyer review.',
    'A15': 'Seller earnings and payouts are outside this buyer application flow.',
    'A16': 'Profile images are uploaded from the gallery without explicit type or five-megabyte validation in the controller. Reviews and chat have no image attachments.',
    'A17': 'Cart quantities must be whole numbers of at least one and cannot exceed available stock. Per-buyer lifetime limits are not implemented.',
    'A18': 'The buyer app has no vacation-store purchase block. Store verification and seller approval should be checked separately against the seller implementation.',
    'A19': 'Active-only filters exist on product listings and detail requests. Favorites and cart do not provide robust missing-product placeholders.',
    'A20': 'Checkout does not add shipping fees or calculate rates from address, store, or weight.',
    'A21': 'Cancelling an order does not reduce voucher usage or return a voucher to a buyer wallet.',
    'A22': 'Buyer record endpoints use authentication and ownership checks. No 30-minute inactivity logout is implemented in the buyer flow, and cross-role access was not executed.',
    'A23': 'The inbox reads the buyer\'s order history and review acknowledgements. There is no mobile push integration.',
    'A24': 'COD remittance and reconciliation belong to logistics roles and are outside this buyer review.',
    'A25': 'Chat accepts up to 2,000 characters and API order notes up to 1,000, although checkout has no note field. Cancellation asks for confirmation without a reason.',
    'A26': 'Voucher entry is required text up to 50 characters and is not forced to uppercase. The supplied schema compares voucher codes without regard to letter case.',
    'A27': 'There is no claimable buyer voucher wallet. Seller voucher-editing rules were not assessed.',
    'A28': 'The buyer sees price and comparison-price fields. Timed sale creation, overlap rules, and End Now controls are outside this implementation.',
    'A29': 'A five-unit stock-crossing alert was not found in the buyer notification flow.',
    'A30': 'No ten-address cap or default-delete safeguard is implemented. Orders reference the address record instead of storing a snapshot; the app exposes Add Address without a management list.',
    'A31': 'Return requests, evidence uploads, disputes, and refund processing are not implemented in this buyer app.',
    'A32': 'The buyer app has no displayed delivery OTP. Proof-of-delivery capture and retry locking belong to other roles and were not assessed.',
    'A33': 'Rider pay is outside this buyer application flow.',
    'A34': 'Dispatch and rider reassignment are outside this buyer application flow.',
    'A35': 'Order status history exists, but the cross-role immutable audit system described here was not verified.',
    'A36': 'Report export is not part of the buyer screens reviewed.',
    'A37': 'Some submit buttons are disabled while busy. There is no general server-side request key or locking that guarantees every duplicate action is processed once.',
    'A38': 'The full hub-to-hub courier workflow is outside the supplied buyer screens and was not tested.',
    'A39': 'Courier eligibility, vehicle capacity, and location checks are outside this buyer review.',
    'A40': 'Seal checks and parcel handover discrepancies are outside this buyer review.',
    'A41': 'Courier pay, delay reporting, and trip reassignment are outside this buyer review.',
}

EVIDENCE = {
    'Buyer': ['frontend/lib/screens/register_screen.dart', 'frontend/lib/screens/verify_email_screen.dart', 'backend/app/Http/Controllers/Api/AuthController.php'],
    'B1 Account': ['frontend/lib/screens/profile_screen.dart', 'backend/app/Http/Controllers/Api/AuthController.php'],
    'B2 Address Book': ['frontend/lib/screens/add_address_screen.dart', 'backend/app/Http/Controllers/Api/AddressController.php'],
    'B3 Browse & Search': ['frontend/lib/screens/home_screen.dart', 'frontend/lib/screens/product_list_screen.dart', 'backend/app/Http/Controllers/Api/ProductController.php'],
    'B4 Product Detail': ['frontend/lib/screens/product_detail_screen.dart', 'backend/app/Http/Controllers/Api/CartController.php'],
    'B5 Wishlist & Follow': ['frontend/lib/screens/favorites_screen.dart', 'frontend/lib/screens/seller_store_screen.dart', 'backend/app/Http/Controllers/Api/FavoriteController.php', 'backend/app/Http/Controllers/Api/StoreController.php'],
    'B6 Cart': ['frontend/lib/screens/cart_screen.dart', 'frontend/lib/screens/checkout_screen.dart', 'backend/app/Http/Controllers/Api/CartController.php'],
    'B7 Vouchers': ['frontend/lib/screens/checkout_screen.dart', 'backend/app/Http/Controllers/Api/VoucherController.php', 'backend/app/Models/Voucher.php', 'backend/app/Http/Controllers/Api/OrderController.php'],
    'B8 Checkout': ['frontend/lib/screens/checkout_screen.dart', 'backend/app/Http/Controllers/Api/OrderController.php'],
    'B9 Payment': ['frontend/lib/screens/checkout_screen.dart', 'backend/app/Http/Controllers/Api/OrderController.php', 'backend/routes/api.php'],
    'B10 Order Tracking': ['frontend/lib/screens/orders_screen.dart', 'frontend/lib/screens/order_detail_screen.dart', 'backend/app/Http/Controllers/Api/OrderController.php'],
    'B11 Cancellation': ['frontend/lib/screens/order_detail_screen.dart', 'backend/app/Http/Controllers/Api/OrderController.php'],
    'B12 Return & Refund': ['backend/routes/api.php', 'frontend/lib/screens/order_detail_screen.dart'],
    'B13 Ratings & Reviews': ['frontend/lib/screens/order_detail_screen.dart', 'backend/app/Http/Controllers/Api/OrderController.php'],
    'B14 Chat & Notifs': ['frontend/lib/screens/chat_screen.dart', 'frontend/lib/screens/notifications_screen.dart', 'backend/app/Http/Controllers/Api/ChatController.php', 'backend/app/Http/Controllers/Api/NotificationController.php'],
}

SPECIAL_EVIDENCE = {
    'TC-BUY-011': ['database/invoizdb.sql'],
    'TC-BUY-030': ['backend/routes/api.php', 'frontend/android/app/src/main/AndroidManifest.xml'],
    'TC-BUY-041': ['frontend/lib/services/auth_service.dart', 'frontend/lib/main.dart'],
    'TC-BUY-042': ['frontend/lib/services/auth_service.dart', 'frontend/lib/screens/account_screen.dart'],
    'BUY-ACCT-011': ['backend/app/Http/Controllers/Api/AuthController.php'],
    'BUY-ACCT-012': ['frontend/lib/services/auth_service.dart', 'frontend/lib/screens/account_screen.dart'],
    'BUY-ADDR-008': ['backend/app/Models/Order.php', 'database/invoizdb.sql'],
    'BUY-SRCH-003': ['database/invoizdb.sql', 'backend/app/Http/Controllers/Api/ProductController.php'],
    'BUY-PDP-010': ['frontend/android/app/src/main/AndroidManifest.xml', 'frontend/lib/screens/product_detail_screen.dart'],
    'BUY-WISH-002': ['database/invoizdb.sql', 'backend/app/Http/Controllers/Api/FavoriteController.php'],
    'BUY-CART-012': ['frontend/lib/widgets/main_layout.dart'],
    'BUY-TRK-007': ['frontend/pubspec.yaml', 'frontend/lib/screens/notifications_screen.dart'],
    'BUY-CHAT-006': ['frontend/pubspec.yaml', 'frontend/lib/screens/chat_screen.dart'],
}


def set_cell(xml, address, value, fallback_style=None):
    """Replace just one cell's XML, retaining all surrounding namespaces/markup."""
    pattern = re.compile(r'<c\b(?=[^>]*\br="' + re.escape(address) + r'")([^>]*?)(?:/>|>.*?</c>)', re.S)
    existing = pattern.search(xml)
    if existing:
        attrs = existing.group(1)
        attrs = re.sub(r'\s+t="[^"]*"', '', attrs)
    else:
        attrs = f' r="{address}"' + (f' s="{fallback_style}"' if fallback_style is not None else '')
    cell = f'<c{attrs} t="inlineStr"><is><t xml:space="preserve">{escape(value)}</t></is></c>'
    if existing:
        return xml[:existing.start()] + cell + xml[existing.end():]
    row_number = re.search(r'\d+$', address).group()
    row_pattern = re.compile(r'(<row\b(?=[^>]*\br="' + row_number + r'")[^>]*>)(.*?)(</row>)', re.S)
    match = row_pattern.search(xml)
    if not match:
        raise ValueError(f'Missing row for {address}')
    # All new cells in this task are after the existing cells in their row.
    return xml[:match.start()] + match.group(1) + match.group(2) + cell + match.group(3) + xml[match.end():]


def row_height(xml, number, height):
    pattern = re.compile(r'<row\b(?=[^>]*\br="' + str(number) + r'")[^>]*>')
    def replace(match):
        tag = re.sub(r'\s+(?:ht|customHeight)="[^"]*"', '', match.group())
        return tag[:-1] + f' ht="{height:.2f}" customHeight="true">'
    return pattern.sub(replace, xml, count=1)


def add_merges(xml, ranges):
    match = re.search(r'<mergeCells\b[^>]*>(.*?)</mergeCells>', xml, re.S)
    if match:
        merged = re.findall(r'<mergeCell\b[^>]*ref="([^"]+)"[^>]*/>', match.group(1))
        merged.extend(x for x in ranges if x not in merged)
        replacement = '<mergeCells count="' + str(len(merged)) + '">' + ''.join(f'<mergeCell ref="{r}"/>' for r in merged) + '</mergeCells>'
        return xml[:match.start()] + replacement + xml[match.end():]
    raise ValueError('Expected existing mergeCells on Summary')


def actual_rows(sheet):
    return [r for r in sheet['rows'] if re.fullmatch(r'(?:TC-BUY|BUY-[A-Z]+)-\d{3}', r['cells'].get('A', ''))]


def fit_filled_rows(xml, columns, numbers):
    root = ET.fromstring(xml)
    widths = {}
    for col in root.findall('s:cols/s:col', NS):
        for number in range(int(col.attrib['min']), int(col.attrib['max']) + 1):
            widths[number] = float(col.attrib['width'])
    for number in numbers:
        row = root.find(f's:sheetData/s:row[@r="{number}"]', NS)
        needed = float(row.attrib.get('ht', '15'))
        for column in columns:
            cell = row.find(f's:c[@r="{column}{number}"]', NS)
            if cell is None:
                continue
            text = ''.join(t.text or '' for t in cell.iter('{' + NS['s'] + '}t'))
            col_number = sum((ord(c) - 64) * 26 ** i for i, c in enumerate(reversed(column)))
            wrap_width = max(10, int(widths.get(col_number, 50) * .90))
            lines = sum(max(1, len(textwrap.wrap(line, wrap_width))) for line in text.splitlines())
            needed = max(needed, lines * 14 + 10)
        xml = row_height(xml, number, min(409, needed))
    return xml


def fill():
    expected_ids = {r['cells']['A'] for b in INVENTORY for s in b['sheets'] if s['name'] in EVIDENCE for r in actual_rows(s)}
    assert set(ANSWERS) == expected_ids, (expected_ids - set(ANSWERS), set(ANSWERS) - expected_ids)
    assert len(expected_ids) == 173
    for paths in [*EVIDENCE.values(), *SPECIAL_EVIDENCE.values()]:
        for path in paths:
            assert Path(path).is_file(), path
    outputs = []
    assessments = []
    for bi, book in enumerate(INVENTORY):
        changes = {}
        rules = {**(ACCOUNT_RULES if bi == 0 else MODULE_RULES), **MOBILE_RULES}
        with ZipFile(SOURCE / book['name']) as original:
            for sheet in book['sheets']:
                if sheet['name'] not in EVIDENCE and sheet['name'] not in ('Summary', 'Assumptions'):
                    continue
                xml = original.read(sheet['path']).decode('utf-8')
                if sheet['name'] == 'Summary':
                    values = {
                        'A2': 'Source-based buyer app review. No phone or live API tests were performed; all execution statuses remain Not Run.',
                        'B5': 'Invoiz buyer app — source-based assessment',
                        'B6': '1.0.0+1 from pubspec.yaml; installed build not checked',
                        'B7': 'No phone/emulator or network session tested',
                        'B8': 'Codex — source review only',
                        'B9': '23 October 2026 — review date, not a device test date',
                    }
                    for address, value in values.items():
                        xml = set_cell(xml, address, value)
                    xml = add_merges(xml, ['A2:G2'] + [f'B{r}:G{r}' for r in range(5, 10)])
                    xml = row_height(xml, 2, 36)
                    for r in range(5, 10):
                        xml = row_height(xml, r, 36 if r != 7 else 48)
                elif sheet['name'] == 'Assumptions':
                    for r in sheet['rows']:
                        ref = r['cells'].get('A', '')
                        if re.fullmatch(r'[AM]\d+', ref):
                            assert ref in rules, ref
                            xml = set_cell(xml, f'D{r["row"]}', rules[ref])
                            root = ET.fromstring(xml)
                            old_row = root.find(f's:sheetData/s:row[@r="{r["row"]}"]', NS)
                            height = float(old_row.attrib.get('ht', '15'))
                            xml = row_height(xml, r['row'], max(height, 72))
                    xml = fit_filled_rows(xml, ['D'], [r['row'] for r in sheet['rows'] if re.fullmatch(r'[AM]\d+', r['cells'].get('A', ''))])
                else:
                    for r in actual_rows(sheet):
                        case_id = r['cells']['A']
                        finding, answer = ANSWERS[case_id]
                        paths = SPECIAL_EVIDENCE.get(case_id, EVIDENCE[sheet['name']])
                        short_sources = ', '.join(Path(p).name for p in paths)
                        remark = f'{finding} in source review; not executed. See {short_sources}.'
                        xml = set_cell(xml, f'K{r["row"]}', answer)
                        xml = set_cell(xml, f'L{r["row"]}', 'Not Run')
                        xml = set_cell(xml, f'M{r["row"]}', remark)
                        assessments.append({'id': case_id, 'sheet': sheet['name'], 'review_finding': finding, 'answer': answer, 'sources': paths})
                    xml = fit_filled_rows(xml, ['K', 'M'], [r['row'] for r in actual_rows(sheet)])
                changes[sheet['path']] = xml.encode('utf-8')
            filename = 'Invoiz_Buyer_Account_Creation_Reviewed.xlsx' if bi == 0 else 'Invoiz_Buyer_Modules_Reviewed.xlsx'
            target = OUT / filename
            with ZipFile(target, 'w') as reviewed:
                for info in original.infolist():
                    reviewed.writestr(info, changes.get(info.filename, original.read(info.filename)))
            outputs.append(target)
    (OUT / 'review_evidence.json').write_text(json.dumps(assessments, ensure_ascii=False, indent=2), encoding='utf-8')
    (OUT / 'READ_ME.txt').write_text(
        'INVOIZ BUYER APP — SOURCE-BASED REVIEW\n'
        'Review date: 23 October 2026 (Asia/Shanghai).\n'
        'Declared frontend version: 1.0.0+1.\n\n'
        'Both workbooks contain short answers based on the supplied Flutter and Laravel source. '
        'Actual Result cells describe what the implementation supports, not actions observed on a phone. '
        'Remarks identify source-review findings and relevant files. These are not executed Pass/Fail results.\n\n'
        'All 173 execution statuses remain Not Run: 42 account-creation cases and 131 buyer-module cases. '
        'No mobile build, physical phone, emulator, live API, email delivery, payment, or external-role integration was tested. '
        'The workbook fixture accounts, products, and vouchers were not created. '
        'An absent feature is labelled Missing or Gap in Remarks rather than falsely marked as a passed negative test.\n\n'
        'Assumptions column D records actual implementation differences and scope limits. '
        'Existing scenarios, expected results, test data, formulas, and workbook assets were preserved. '
        'Original files in Downloads and existing app source changes were left untouched. '
        'Use live test evidence before changing an execution status to Pass or Fail. '
        'Keep date-boundary data relative to the real test date; original date formulas remain intact.\n\n'
        'Source paths for every case are available in review_evidence.json. '
        'No backend .env values or private user records were used in the answers.\n', encoding='utf-8')
    return outputs


if __name__ == '__main__':
    for output in fill():
        print(output)
