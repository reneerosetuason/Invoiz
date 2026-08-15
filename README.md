# Invoiz — E-Commerce App

A Shopee-style e-commerce application built with:

- **Frontend:** Flutter / Dart (`frontend/`)
- **Backend:** Laravel 13 / PHP (`backend/`)
- **Database:** MySQL / MariaDB (`invoizdb`)

**Roles implemented:** Guest (browse only), Buyer (shop, cart, order, chat), and
**Buyer + Seller** (one account, two sides — switch between them anytime).

> Guests can freely browse products and categories. To add to cart, place
> orders, chat, or manage an account, a user must **log in first** as an
> **approved buyer**. New buyer registrations are **pending** until an
> administrator approves them. A buyer can also **apply to become a seller**
> from the sidebar; once approved, the same login can act as a buyer or a
> seller and switch between the two from the sidebar menu.

---

## 1. Requirements

| Tool      | Version tested   | Notes |
|-----------|------------------|-------|
| PHP       | 8.5 (CLI)        | `php --version` |
| Composer  | 2.x              | `composer --version` |
| MySQL     | MariaDB 10.4+    | via XAMPP or standalone |
| Flutter   | 3.35 / Dart 3.9  | `flutter --version` |
| Chrome    | any              | for `flutter run -d chrome` |

Make sure **XAMPP / MySQL is running** (port 3306) and that `php` and
`composer` are on your `PATH`.

---

## 2. Project Structure

```
Invoiz/
├── database/
│   └── invoizdb.sql          # Full DB schema (single source of truth)
├── backend/                  # Laravel API
│   ├── app/Http/Controllers/Api/   # All API controllers
│   ├── app/Models/                  # Eloquent models
│   ├── routes/api.php               # API routes
│   └── .env                         # DB credentials (root / admin)
├── frontend/                 # Flutter app
│   ├── lib/
│   │   ├── main.dart               # App entry
│   │   ├── config.dart             # API base URL + PSGC address API
│   │   ├── theme.dart              # Shopee-style theme
│   │   ├── models/                 # Data models
│   │   ├── services/               # HTTP + auth services
│   │   ├── widgets/
│   │   │   └── main_layout.dart    # SINGLE FILE: navbar + sidebar shell
│   │   └── screens/                # All pages
│   └── pubspec.yaml
└── README.md
```

### Single-file navbar/sidebar

`frontend/lib/widgets/main_layout.dart` is the **one shared shell** used by
every screen. It provides the Shopee-style top bar (search, cart) and the left
drawer (Home, Favorites, My Cart, My Orders, Messages, Account, Logout). Every
page simply wraps its content in `MainLayout(child: ...)`.

---

## 3. Database Setup

The schema file is `database/invoizdb.sql`. It was **adapted** from the old
`tinybasketdp.sql`; every change is marked inline with `-- CHANGE:` comments
(e.g. added `product_variants`, `vouchers`, `order_vouchers`,
`order_status_histories`, `conversations`, `messages`, `favorites`, renamed
database to `invoizdb`, and removed the "baby products only" restriction).

Import it (drops & recreates `invoizdb`):

```bash
mysql -u root -padmin < database/invoizdb.sql
```

> Default DB credentials used by the app: **user `root` / password `admin`**.
> If yours differ, update `backend/.env`.

---

## 4. Backend (Laravel API)

```bash
cd backend
composer install            # first time only (installs vendor/)
php artisan storage:link    # link public/storage for uploaded files
php artisan db:seed         # demo seller, categories, products, vouchers
php artisan serve --host=127.0.0.1 --port=8000
```

The API runs at `http://127.0.0.1:8000/api`.

**Seed data:** 8 generic categories (Fashion, Electronics, Home & Living, etc.),
8 sample products with color/size variants, a demo seller account, and 3 vouchers
(`WELCOME10`, `SAVE15`, `FREESHIP`).

**Guest endpoints (no login):** `GET /api/categories`, `GET /api/products`,
`GET /api/products/{id}`.

**Auth:** `POST /api/register`, `POST /api/login`, `POST /api/logout`,
`GET /api/me`, `PUT /api/profile`.

**Buyer endpoints (bearer token):** cart (`/api/cart`), addresses
(`/api/addresses`), vouchers (`/api/vouchers`), orders
(`/api/orders/checkout`), chat (`/api/conversations`), favorites
(`/api/favorites`).

**Seller endpoints (bearer token):** `POST /api/seller/apply`,
`GET /api/seller/status`, `GET /api/seller/me`. The seller application adds a
`sellers` row to the **same** `users` identity — personal info already lives on
the buyer account; the application only collects the business details
(business name, line of business, valid ID, business permit). It is **pending**
until an administrator approves it.

**Seller flow:**
1. Log in as an approved buyer → sidebar → **Apply as Seller**.
2. Fill in business name, line of business (from categories), upload a valid ID
   and a business permit, submit (status becomes `pending`).
3. Admin approves (`UPDATE sellers SET approval_status='approved' WHERE user_id=...;`).
4. Next login shows the **Continue as Buyer / Continue as Seller** picker.
   The sidebar also gets **Switch to Seller / Switch to Buyer**.
5. The seller center is currently a placeholder (full store management is
   built separately).

---

## 5. Frontend (Flutter)

### 5a. Run in Chrome (web) — easiest

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

> If the API base URL differs, edit `frontend/lib/config.dart`
> (`AppConfig.apiBaseUrl`). For a physical phone use your LAN IP, e.g.
> `http://192.168.x.x:8000/api`. Product images resolve against the same
> host automatically (via `AppConfig.storageUrl`), so they work on devices
> too — no separate image URL to change.

### 5b. Run on Android

```bash
cd frontend
flutter pub get
flutter run
```

### 5c. Build a release web bundle

```bash
cd frontend
flutter build web --release
# serve build/web with any static server
```

---

## 5d. Buyer experience extras

- **Order progress bar** — order detail shows a visual
  Placed → Confirmed → On the way → Delivered stepper (cancelled orders show a
  red notice instead).
- **"X sold" badges** — product cards and detail pages show how many units were
  actually sold (computed from non-cancelled order items).
- **Recently Viewed** — a horizontal row on Home with the last products you
  opened (stored locally; a history icon clears it).
- **Best-for-you voucher** — in Checkout a highlighted suggestion computes which
  voucher saves the most for your cart and applies it in one tap.
- **Notifications inbox** — the bell in the navbar (badge shows unread count)
  opens a list of order status updates and review acknowledgements
  (`GET /api/notifications`).
- **Dark mode** — sidebar toggle at the bottom switches the whole app to a dark
  palette; your choice is remembered between sessions.

### 5e. Seller store page (buyer view)

Every product card shows a **Sold by <Store>** link, and the product page has a
**Visit Store** button — both open the seller's storefront:

- **Header** — store banner with logo/name, verified badge, and line of business.
- **Stats row** — Rating, Followers, Products, and total units Sold.
- **Follow / Following** — tap to follow (or unfollow) the store; follower counts
  update live (`GET /api/stores/{seller}/follow`).
- **Products tab** — in-store **search bar + sort** (Newest / Price / Rating).
- **Reviews tab** — overall store rating with a **5→1 star breakdown bar** and
  the list of buyer reviews across all of the store's products
  (`GET /api/stores/{seller}/reviews`).
- **Chat** — one tap opens a conversation with the seller.

Public store endpoint: `GET /api/stores/{seller}` returns the store profile
(stats, `is_following` when a buyer is logged in, rating breakdown) plus a
paginated product list.

### 5f. Product gallery & specifications

- **Image gallery** — the product page shows a **swipeable photo gallery**
  (up to 3 photos, `product_images` table) with a `1/3` counter, tappable
  thumbnails, and a **full-screen zoomable viewer** (tap the photo to open).
  The backend attaches a `gallery` array to `GET /api/products/{id}`.
- **Specifications** — products now carry rich details rendered in a spec
  table on the product page: **Brand, Model, SKU, Material, Dimensions,
  Weight, Warranty, Origin** plus the category. Stored as columns on
  `products`; seeded for all 8 demo products.

---

## 6. App Walkthrough (Guest vs Buyer)

1. **Splash → Login.** Choose **Continue as Guest** to browse, or log in.
2. **Guest:** can view categories, search, open product details, and see
   reviews — but tapping *Add to Cart / Buy Now / Favorites* prompts a login.
3. **Register (Buyer):** Last name, First name, Middle initial, Sex, E-mail,
   Contact no., Birthday (Age auto-computed), Address via **PSGC API**
   dropdowns (Province → Municipality → Barangay) + manual street/house,
   and **Upload ID**. After submitting you must **wait for administrator
   approval**.
4. **Login:** only works when `approval_status = approved`. Pending/rejected
   accounts get a clear message.
5. **Main menu (navbar + sidebar):**
   - **Categories** — dropdown/filter chips
   - **Search** — product list, details, quantity, variations (color/size),
     Add to Cart
   - **My Cart** — select items, edit qty, remove → checkout
   - **Checkout** — choose address, apply **voucher**, **Cash on Delivery**,
     place order
   - **My Orders** — tabs (All / To Ship / In Transit / Delivered / Cancelled),
     order detail with timeline, cancel, and **Rate & Feedback**
   - **Messages** — start conversations with Invoiz support
   - **Account** — profile, edit profile, addresses, logout
   - **Sell** — Apply as Seller (business info + ID + business permit), Seller
     Center (placeholder), and **Switch to Seller / Switch to Buyer**

---

## 7. Test Accounts

| Role  | E-mail               | Password    | Status |
|-------|----------------------|-------------|--------|
| Seller (demo) | `seller@invoiz.test` | `password` | approved |
| Buyer (demo)  | `juan@test.com`      | `password123` | approved |

For a **buyer**, register a new account in the app. By default it will be
`pending`. To approve it quickly for testing:

```bash
mysql -u root -padmin invoizdb -e "UPDATE users SET approval_status='approved' WHERE email='your@email.com';"
```

To test the **buyer + seller** flow with the same account, apply as a seller in
the app (sidebar → Apply as Seller), then approve the seller side:

```bash
mysql -u root -padmin invoizdb -e "UPDATE sellers SET approval_status='approved' WHERE user_id=<the user id>;"
```

> In a full system, an admin panel would approve accounts and e-mail the user.
> Since only Guest + Buyer were requested, approval is done directly in the DB
> for now (and the pending note is shown in the app).

---

## 8. Payment

Only **Cash on Delivery (COD)** is implemented, per your request. The
`payments` table still supports `gcash` / `bank_transfer` enum values for
future expansion, but the UI only offers COD.

---

## 9. Troubleshooting

- **`Access denied for user 'root'`** — fix `backend/.env` DB credentials.
- **API not reachable from the web app** — confirm the backend is running on
  port 8000 and `config.dart` points to the right host. CORS is configured to
  allow all origins for `api/*`.
- **Uploaded files 404** — run `php artisan storage:link` (or they are stored
  under `storage/app/private`).
- **PSGC address dropdowns empty** — needs internet access to
  `https://psgc.gitlab.io/api`. The rest of the app still works without it.
- **Port conflicts** — change ports in `backend/.env` (`APP_URL`) and
  `frontend/lib/config.dart`.