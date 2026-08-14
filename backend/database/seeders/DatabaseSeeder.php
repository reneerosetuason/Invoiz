<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use App\Models\Voucher;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with generic demo data.
     */
    public function run(): void
    {
        // Demo seller (required because products reference seller_id).
        $seller = User::updateOrCreate(
            ['email' => 'seller@invoiz.test'],
            [
                'last_name'       => 'Invoiz',
                'first_name'      => 'Demo Seller',
                'sex'             => 'other',
                'password'        => Hash::make('password'),
                'phone'           => '09170000000',
                'birthday'        => '1990-01-01',
                'age'             => 36,
                'approval_status' => 'approved',
                'role'            => 'seller',
                'status'          => 'active',
            ]
        );

        // Generic categories (NOT baby-products only).
        $categories = [
            ['name' => 'Fashion',          'description' => 'Apparel, shoes, bags and accessories'],
            ['name' => 'Electronics',      'description' => 'Gadgets, phones, and accessories'],
            ['name' => 'Home & Living',    'description' => 'Furniture, kitchen, and home decor'],
            ['name' => 'Beauty & Health',  'description' => 'Skincare, makeup, and wellness'],
            ['name' => 'Sports & Outdoors','description' => 'Fitness, camping, and sports gear'],
            ['name' => 'Toys & Hobbies',   'description' => 'Toys, collectibles, and games'],
            ['name' => 'Groceries',        'description' => 'Food, snacks, and daily essentials'],
            ['name' => 'Books',            'description' => 'Books, magazines, and stationery'],
        ];

        foreach ($categories as $cat) {
            Category::updateOrCreate(['name' => $cat['name']], $cat);
        }

        $catId = fn (string $name) => Category::where('name', $name)->value('id');

        $products = [
            [
                'name' => 'Classic White T-Shirt',
                'category' => 'Fashion',
                'description' => 'Premium cotton casual tee. Available in multiple colors and sizes.',
                'price' => 199.00, 'stock' => 100,
                'variants' => [
                    ['Color', 'White'], ['Color', 'Black'], ['Color', 'Navy'],
                    ['Size', 'S'], ['Size', 'M'], ['Size', 'L'], ['Size', 'XL'],
                ],
            ],
            [
                'name' => 'Wireless Bluetooth Earbuds',
                'category' => 'Electronics',
                'description' => 'True wireless earbuds with charging case and 24hr battery.',
                'price' => 899.00, 'stock' => 50,
                'variants' => [['Color', 'Black'], ['Color', 'White']],
            ],
            [
                'name' => 'Stainless Water Bottle 750ml',
                'category' => 'Home & Living',
                'description' => 'Insulated steel bottle keeps drinks cold/hot for hours.',
                'price' => 349.00, 'stock' => 80,
                'variants' => [['Color', 'Silver'], ['Color', 'Matte Black'], ['Color', 'Rose Gold']],
            ],
            [
                'name' => 'Moisturizing Facial Serum',
                'category' => 'Beauty & Health',
                'description' => 'Vitamin C serum for glowing, hydrated skin.',
                'price' => 450.00, 'stock' => 60,
                'variants' => [['Size', '30ml'], ['Size', '50ml']],
            ],
            [
                'name' => 'Yoga Mat Non-Slip',
                'category' => 'Sports & Outdoors',
                'description' => 'Eco-friendly TPE yoga mat with carry strap.',
                'price' => 599.00, 'stock' => 40,
                'variants' => [['Color', 'Purple'], ['Color', 'Green'], ['Color', 'Blue']],
            ],
            [
                'name' => 'Building Blocks Set 500pcs',
                'category' => 'Toys & Hobbies',
                'description' => 'Colorful building bricks for endless creative play.',
                'price' => 750.00, 'stock' => 30,
                'variants' => [],
            ],
            [
                'name' => 'Instant Coffee 100g',
                'category' => 'Groceries',
                'description' => 'Rich and aromatic 3-in-1 instant coffee.',
                'price' => 120.00, 'stock' => 200,
                'variants' => [['Size', '100g'], ['Size', '250g']],
            ],
            [
                'name' => 'Bestseller Hardbound Novel',
                'category' => 'Books',
                'description' => 'A gripping hardbound fiction novel.',
                'price' => 499.00, 'stock' => 25,
                'variants' => [],
            ],
        ];

        foreach ($products as $p) {
            $product = Product::updateOrCreate(
                ['name' => $p['name']],
                [
                    'seller_id'   => $seller->id,
                    'category_id' => $catId($p['category']),
                    'description' => $p['description'],
                    'price'       => $p['price'],
                    'stock'       => $p['stock'],
                    'status'      => 'active',
                ]
            );

            foreach ($p['variants'] as [$type, $value]) {
                ProductVariant::updateOrCreate(
                    [
                        'product_id'    => $product->id,
                        'variant_type'  => $type,
                        'variant_value' => $value,
                    ],
                    [
                        'price_adjustment' => 0.00,
                        'stock'            => $product->stock,
                        'status'           => 'active',
                    ]
                );
            }
        }

        // Demo vouchers.
        $vouchers = [
            ['code' => 'WELCOME10', 'name' => 'Welcome Voucher', 'description' => 'P100 off any order',
             'discount_type' => 'fixed', 'discount_value' => 100.00, 'min_spend' => 500.00],
            ['code' => 'SAVE15', 'name' => 'Save 15%', 'description' => '15% off up to P150',
             'discount_type' => 'percent', 'discount_value' => 15.00, 'min_spend' => 1000.00, 'max_discount' => 150.00],
            ['code' => 'FREESHIP', 'name' => 'Free Delivery', 'description' => 'P50 off any order',
             'discount_type' => 'fixed', 'discount_value' => 50.00, 'min_spend' => 300.00],
        ];

        foreach ($vouchers as $v) {
            Voucher::updateOrCreate(['code' => $v['code']], [...$v, 'status' => 'active']);
        }

        $this->command->info('Database seeded with demo seller, categories, products, variants, and vouchers.');
    }
}