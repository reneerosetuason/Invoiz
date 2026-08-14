<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    protected $fillable = ['name', 'description', 'image', 'status'];

    protected function casts(): array
    {
        return ['status' => 'string'];
    }

    public function products()
    {
        return $this->hasMany(Product::class, 'category_id');
    }
}