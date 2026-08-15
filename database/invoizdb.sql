-- =====================================================================
-- INVOIZDB - E-Commerce Database Schema
-- ---------------------------------------------------------------------
-- Base file : tinybasketdp.sql (from the old baby-products project)
-- Database : renamed from `tinybasket` to `invoizdb`
--
-- CHANGES MADE (each is also marked inline with "-- CHANGE:"):
--   1. Database renamed tinybasket -> invoizdb
--   2. Added `product_variants` table  -> lets a product have variations
--      (color, size, etc.) so the buyer can "choose variations".
--   3. Added `vouchers` + `order_vouchers` -> support vouchers/discounts
--      at checkout ("apply vouchers and discounts").
--   4. Added `conversations` + `messages` -> Chat / Messaging feature.
--   5. Added `favorites` (wishlist) table -> extra e-commerce nicety.
--   6. Added `order_status_histories` -> track "to ship / in transit /
--      out for delivery / delivered" status timeline for the buyer.
--   7. Removed the "baby products only" restriction - categories are
--      now generic so ANY product can be sold (the app will seed its own
--      generic categories, e.g. Fashion, Electronics, Home, etc.).
--   8. products.seller_id kept, but the seed script creates a demo
--      seller account so guest/buyer flows work without a seller UI.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS invoizdb            -- CHANGE: was `tinybasket`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE invoizdb;


-- =========================================================
-- 1. USERS  (guest = no row needed; buyer = row with role='buyer')
-- =========================================================
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_initial VARCHAR(10) NULL,
    sex ENUM('male', 'female', 'other') NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    phone VARCHAR(30) NOT NULL,
    birthday DATE NOT NULL,
    age INT UNSIGNED NOT NULL,

    province VARCHAR(100) NULL,
    municipality VARCHAR(100) NULL,
    barangay VARCHAR(100) NULL,
    address_line VARCHAR(255) NULL,
    id_image VARCHAR(255) NULL,

    approval_status ENUM('pending', 'approved', 'rejected')
        NOT NULL DEFAULT 'pending',

    role ENUM('admin', 'seller', 'buyer', 'rider')
        NOT NULL DEFAULT 'buyer',

    status ENUM('active', 'inactive', 'suspended')
        NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);


-- CHANGE: NEW table for the seller application.
-- One identity (users) can act as BOTH buyer and seller: the buyer's
-- personal info lives in `users`, and this row adds the seller side of
-- that same account (business info + seller approval).
CREATE TABLE sellers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    business_name VARCHAR(150) NOT NULL,
    line_of_business VARCHAR(100) NOT NULL,

    id_image VARCHAR(255) NULL,
    business_permit VARCHAR(255) NULL,

    approval_status ENUM('pending', 'approved', 'rejected')
        NOT NULL DEFAULT 'pending',
    status ENUM('active', 'inactive')
        NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT sellers_user_id_foreign
        FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE CASCADE
);


-- =========================================================
-- 2. CATEGORIES
-- =========================================================
CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    image VARCHAR(255) NULL,

    status ENUM('active', 'inactive')
        NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);


-- =========================================================
-- 3. PRODUCTS
-- =========================================================
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    seller_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,

    name VARCHAR(150) NOT NULL,
    description TEXT NULL,

    -- CHANGE: extra product details (Shopee-style specs)
    brand VARCHAR(100) NULL,
    model VARCHAR(100) NULL,
    sku VARCHAR(100) NULL,
    material VARCHAR(100) NULL,
    dimensions VARCHAR(100) NULL,
    weight VARCHAR(50) NULL,
    warranty VARCHAR(100) NULL,
    origin VARCHAR(100) NULL,

    price DECIMAL(10,2) NOT NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,

    image VARCHAR(255) NULL,
    rating DECIMAL(2,1) NULL DEFAULT NULL,          -- CHANGE: cached avg rating for product cards

    status ENUM('active', 'inactive', 'out_of_stock')
        NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_product_price
        CHECK (price >= 0)
);


-- =========================================================
-- 3b. PRODUCT VARIANTS        -- CHANGE: NEW TABLE
--      Lets buyers choose variations (color, size, etc.)
-- =========================================================
CREATE TABLE product_variants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    product_id BIGINT UNSIGNED NOT NULL,

    variant_type VARCHAR(50) NOT NULL,   -- e.g. 'Color', 'Size'
    variant_value VARCHAR(100) NOT NULL, -- e.g. 'Red', 'Large'

    price_adjustment DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- +/- vs base price
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    image VARCHAR(255) NULL,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_variants_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 3c. PRODUCT IMAGES  -- CHANGE: NEW TABLE
--     Multiple gallery photos per product (Shopee-style).
-- =========================================================
CREATE TABLE product_images (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    product_id BIGINT UNSIGNED NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    sort_order INT UNSIGNED NOT NULL DEFAULT 0,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_images_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 4. ADDRESSES
-- =========================================================
CREATE TABLE addresses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,

    recipient_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) NOT NULL,

    address_line VARCHAR(255) NOT NULL,
    barangay VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,

    postal_code VARCHAR(20) NULL,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_addresses_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 5. CARTS
-- =========================================================
CREATE TABLE carts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL UNIQUE,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_carts_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 6. CART ITEMS
-- =========================================================
CREATE TABLE cart_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    cart_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,

    variant_id BIGINT UNSIGNED NULL,                 -- CHANGE: chosen variation (nullable)
    quantity INT UNSIGNED NOT NULL DEFAULT 1,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_cart_items_cart
        FOREIGN KEY (cart_id)
        REFERENCES carts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_cart_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_cart_items_variant
        FOREIGN KEY (variant_id)                     -- CHANGE: NEW FK
        REFERENCES product_variants(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT uq_cart_product
        UNIQUE (cart_id, product_id, variant_id),    -- CHANGE: unique now includes variant

    CONSTRAINT chk_cart_quantity
        CHECK (quantity > 0)
);


-- =========================================================
-- 7. ORDERS
-- =========================================================
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,
    address_id BIGINT UNSIGNED NOT NULL,

    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    status ENUM(
        'pending',
        'confirmed',
        'processing',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered',
        'cancelled'
    ) NOT NULL DEFAULT 'pending',

    notes TEXT NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_order_total
        CHECK (total_amount >= 0)
);


-- =========================================================
-- 8. ORDER ITEMS
-- =========================================================
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    seller_id BIGINT UNSIGNED NOT NULL,

    product_name VARCHAR(150) NOT NULL,
    variant_label VARCHAR(150) NULL,                 -- CHANGE: snapshot of chosen variation, e.g. "Color: Red"
    quantity INT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(10,2)
        GENERATED ALWAYS AS (quantity * price) STORED,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_item_price
        CHECK (price >= 0)
);


-- =========================================================
-- 9. PAYMENTS   (Cash on Delivery only for now)
-- =========================================================
CREATE TABLE payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT UNSIGNED NOT NULL UNIQUE,

    method ENUM(
        'cash_on_delivery',
        'gcash',
        'bank_transfer'
    ) NOT NULL,

    status ENUM(
        'pending',
        'paid',
        'failed',
        'refunded'
    ) NOT NULL DEFAULT 'pending',

    amount DECIMAL(10,2) NOT NULL,

    reference_number VARCHAR(100) NULL,

    paid_at TIMESTAMP NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0)
);


-- =========================================================
-- 10. VOUCHERS              -- CHANGE: NEW TABLE
--     Checkout "apply vouchers and discounts"
-- =========================================================
CREATE TABLE vouchers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,

    discount_type ENUM('fixed', 'percent') NOT NULL DEFAULT 'fixed',
    discount_value DECIMAL(10,2) NOT NULL,

    min_spend DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    max_discount DECIMAL(10,2) NULL,          -- cap for percent vouchers

    valid_from DATE NULL,
    valid_until DATE NULL,

    usage_limit INT UNSIGNED NULL,
    used_count INT UNSIGNED NOT NULL DEFAULT 0,

    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_voucher_value
        CHECK (discount_value >= 0)
);


-- =========================================================
-- 10b. ORDER VOUCHERS        -- CHANGE: NEW TABLE
--      Records which voucher was applied to an order
-- =========================================================
CREATE TABLE order_vouchers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT UNSIGNED NOT NULL,
    voucher_id BIGINT UNSIGNED NOT NULL,

    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_vouchers_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_vouchers_voucher
        FOREIGN KEY (voucher_id)
        REFERENCES vouchers(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- =========================================================
-- 11. ORDER STATUS HISTORY   -- CHANGE: NEW TABLE
--     Timeline for "to ship / in transit / out for delivery / delivered"
-- =========================================================
CREATE TABLE order_status_histories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT UNSIGNED NOT NULL,

    from_status VARCHAR(50) NULL,
    to_status VARCHAR(50) NOT NULL,
    note VARCHAR(255) NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_status_histories_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 12. DELIVERIES
-- =========================================================
CREATE TABLE deliveries (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT UNSIGNED NOT NULL UNIQUE,
    rider_id BIGINT UNSIGNED NULL,

    status ENUM(
        'waiting_for_rider',
        'assigned',
        'picked_up',
        'out_for_delivery',
        'delivered',
        'failed'
    ) NOT NULL DEFAULT 'waiting_for_rider',

    assigned_at TIMESTAMP NULL,
    picked_up_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,

    delivery_notes TEXT NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_deliveries_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_deliveries_rider
        FOREIGN KEY (rider_id)
        REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- =========================================================
-- 13. REVIEWS  (rate / feedback after delivery)
-- =========================================================
CREATE TABLE reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,

    rating TINYINT UNSIGNED NOT NULL,
    comment TEXT NULL,

    status ENUM('visible', 'hidden')
        NOT NULL DEFAULT 'visible',

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reviews_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_reviews_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5),

    CONSTRAINT uq_buyer_product_order
        UNIQUE (buyer_id, product_id, order_id)
);


-- =========================================================
-- 14. CONVERSATIONS          -- CHANGE: NEW TABLE
--     Chat / Messaging (buyer <-> store support)
-- =========================================================
CREATE TABLE conversations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,
    subject VARCHAR(150) NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversations_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 15. MESSAGES              -- CHANGE: NEW TABLE
-- =========================================================
CREATE TABLE messages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    conversation_id BIGINT UNSIGNED NOT NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    body TEXT NOT NULL,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_messages_sender
        FOREIGN KEY (sender_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================================================
-- 16. FAVORITES (wishlist)  -- CHANGE: NEW TABLE
-- =========================================================
CREATE TABLE favorites (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_favorites_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_favorites_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_favorite_buyer_product
        UNIQUE (buyer_id, product_id)
);


-- =========================================================
-- 16b. STORE FOLLOWS  -- CHANGE: NEW TABLE
--      Buyers can follow a seller's store (Shopee-style).
-- =========================================================
CREATE TABLE store_follows (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    buyer_id BIGINT UNSIGNED NOT NULL,
    seller_id BIGINT UNSIGNED NOT NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_store_follows_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_store_follows_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_store_follow_buyer_seller
        UNIQUE (buyer_id, seller_id)
);


-- =========================================================
-- 17. LARAVEL FRAMEWORK TABLES   -- CHANGE: NEW TABLES
--     Needed by the Laravel backend (sessions, cache, jobs,
--     password resets, Sanctum API tokens). Added so the
--     .sql file stays the single source of truth.
-- =========================================================

CREATE TABLE password_reset_tokens (
    email VARCHAR(150) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL
);

CREATE TABLE sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE cache (
    `key` VARCHAR(255) PRIMARY KEY,
    value MEDIUMTEXT NOT NULL,
    expiration INT NOT NULL
);

CREATE TABLE cache_locks (
    `key` VARCHAR(255) PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    expiration INT NOT NULL
);

CREATE TABLE jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    queue VARCHAR(255) NOT NULL,
    payload LONGTEXT NOT NULL,
    attempts TINYINT UNSIGNED NOT NULL,
    reserved_at INT UNSIGNED NULL,
    available_at INT UNSIGNED NOT NULL,
    created_at INT UNSIGNED NOT NULL
);

CREATE TABLE job_batches (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    total_jobs INT NOT NULL,
    pending_jobs INT NOT NULL,
    failed_jobs INT NOT NULL,
    failed_job_ids LONGTEXT NOT NULL,
    options MEDIUMTEXT NULL,
    cancelled_at INT NULL,
    created_at INT NOT NULL,
    finished_at INT NULL
);

CREATE TABLE failed_jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(255) NOT NULL UNIQUE,
    connection TEXT NOT NULL,
    queue TEXT NOT NULL,
    payload LONGTEXT NOT NULL,
    exception LONGTEXT NOT NULL,
    failed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE personal_access_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    abilities TEXT NULL,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_tokenable (tokenable_type, tokenable_id)
);
