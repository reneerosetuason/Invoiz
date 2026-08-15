<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Seller extends Model
{
    protected $fillable = [
        'user_id',
        'business_name',
        'line_of_business',
        'id_image',
        'business_permit',
        'approval_status',
        'status',
    ];

    protected $casts = [
        'user_id' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class, 'seller_id');
    }

    public function isApproved(): bool
    {
        return $this->approval_status === 'approved' && $this->status === 'active';
    }
}