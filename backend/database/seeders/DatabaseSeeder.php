<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
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
                'brand' => 'BasicWear', 'model' => 'BW-T100', 'sku' => 'TSH-WHT-199',
                'material' => '100% Cotton', 'dimensions' => 'M 50x70 cm',
                'weight' => '180 g', 'warranty' => 'No Warranty', 'origin' => 'Philippines',
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
                'brand' => 'SoundPeak', 'model' => 'SP-EB24', 'sku' => 'EAR-BT-899',
                'material' => 'ABS + Silicone', 'dimensions' => 'Case 6 x 4.5 x 2.5 cm',
                'weight' => '48 g', 'warranty' => '6 months', 'origin' => 'China',
                'variants' => [['Color', 'Black'], ['Color', 'White']],
            ],
            [
                'name' => 'Stainless Water Bottle 750ml',
                'category' => 'Home & Living',
                'description' => 'Insulated steel bottle keeps drinks cold/hot for hours.',
                'price' => 349.00, 'stock' => 80,
                'brand' => 'Hydra', 'model' => 'HY-750', 'sku' => 'BTL-STL-349',
                'material' => 'Stainless Steel', 'dimensions' => '26 x 7 cm',
                'weight' => '340 g', 'warranty' => 'No Warranty', 'origin' => 'China',
                'variants' => [['Color', 'Silver'], ['Color', 'Matte Black'], ['Color', 'Rose Gold']],
            ],
            [
                'name' => 'Moisturizing Facial Serum',
                'category' => 'Beauty & Health',
                'description' => 'Vitamin C serum for glowing, hydrated skin.',
                'price' => 450.00, 'stock' => 60,
                'brand' => 'GlowLab', 'model' => 'GL-C30', 'sku' => 'SRM-C30-450',
                'material' => 'Vitamin C + Hyaluronic Acid', 'dimensions' => 'Bottle 11 x 3.5 cm',
                'weight' => '70 g', 'warranty' => 'No Warranty', 'origin' => 'Korea',
                'variants' => [['Size', '30ml'], ['Size', '50ml']],
            ],
            [
                'name' => 'Yoga Mat Non-Slip',
                'category' => 'Sports & Outdoors',
                'description' => 'Eco-friendly TPE yoga mat with carry strap.',
                'price' => 599.00, 'stock' => 40,
                'brand' => 'FlexFit', 'model' => 'FF-TPE', 'sku' => 'YGA-TPE-599',
                'material' => 'TPE Foam', 'dimensions' => '183 x 61 x 0.6 cm',
                'weight' => '900 g', 'warranty' => 'No Warranty', 'origin' => 'China',
                'variants' => [['Color', 'Purple'], ['Color', 'Green'], ['Color', 'Blue']],
            ],
            [
                'name' => 'Building Blocks Set 500pcs',
                'category' => 'Toys & Hobbies',
                'description' => 'Colorful building bricks for endless creative play.',
                'price' => 750.00, 'stock' => 30,
                'brand' => 'BuildPlay', 'model' => 'BP-500', 'sku' => 'BLK-500-750',
                'material' => 'ABS Plastic', 'dimensions' => 'Box 30 x 22 x 12 cm',
                'weight' => '1.2 kg', 'warranty' => 'No Warranty', 'origin' => 'China',
                'variants' => [],
            ],
            [
                'name' => 'Instant Coffee 100g',
                'category' => 'Groceries',
                'description' => 'Rich and aromatic 3-in-1 instant coffee.',
                'price' => 120.00, 'stock' => 200,
                'brand' => 'BrewNest', 'model' => 'BN-100', 'sku' => 'COF-100-120',
                'material' => 'Roasted coffee, creamer, sugar', 'dimensions' => 'Pouch 16 x 10 cm',
                'weight' => '100 g', 'warranty' => 'No Warranty', 'origin' => 'Philippines',
                'variants' => [['Size', '100g'], ['Size', '250g']],
            ],
            [
                'name' => 'Bestseller Hardbound Novel',
                'category' => 'Books',
                'description' => 'A gripping hardbound fiction novel.',
                'price' => 499.00, 'stock' => 25,
                'brand' => 'PaperTrail Books', 'model' => 'PT-2301', 'sku' => 'BOK-HB-499',
                'material' => 'Paper, Hardcover', 'dimensions' => '23 x 15 x 3 cm',
                'weight' => '450 g', 'warranty' => 'No Warranty', 'origin' => 'Philippines',
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
                    'brand'       => $p['brand'],
                    'model'       => $p['model'],
                    'sku'         => $p['sku'],
                    'material'    => $p['material'],
                    'dimensions'  => $p['dimensions'],
                    'weight'      => $p['weight'],
                    'warranty'    => $p['warranty'],
                    'origin'      => $p['origin'],
                    'price'       => $p['price'],
                    'stock'       => $p['stock'],
                    'status'      => 'active',
                ]
            );

            // Cover image + gallery (3 photos per product).
            $firstId = $product->id;
            $product->update(['image' => "products/p{$firstId}_1.png"]);
            ProductImage::where('product_id', $product->id)->delete();
            for ($i = 1; $i <= 3; $i++) {
                ProductImage::create([
                    'product_id'  => $product->id,
                    'image_path'  => "products/p{$firstId}_$i.png",
                    'sort_order'  => $i,
                ]);
            }

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