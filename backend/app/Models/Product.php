<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'seller_id',
        'category_id',
        'name',
        'description',
        'brand',
        'model',
        'sku',
        'material',
        'dimensions',
        'weight',
        'warranty',
        'origin',
        'price',
        'compare_at_price',
        'stock',
        'image',
        'rating',
        'status',
    ];

    protected $appends = ['discount_percent'];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'compare_at_price' => 'decimal:2',
            'rating' => 'decimal:1',
            'status' => 'string',
        ];
    }

    /**
     * Whole-number discount, e.g. 25 for "−25%". 0 when not on sale.
     */
    public function getDiscountPercentAttribute(): int
    {
        $compare = (float) ($this->compare_at_price ?? 0);
        $price = (float) ($this->price ?? 0);
        if ($compare <= 0 || $price >= $compare) return 0;
        return (int) round(($compare - $price) / $compare * 100);
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_id');
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class, 'product_id')->where('status', 'active');
    }

    public function images()
    {
        return $this->hasMany(ProductImage::class, 'product_id')
            ->orderBy('sort_order')
            ->orderBy('id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'product_id')->where('status', 'visible');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class, 'product_id');
    }
}