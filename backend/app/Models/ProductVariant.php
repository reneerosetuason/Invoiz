<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    protected $fillable = [
        'product_id',
        'variant_type',
        'variant_value',
        'price_adjustment',
        'stock',
        'image',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'price_adjustment' => 'decimal:2',
            'status' => 'string',
        ];
    }

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}