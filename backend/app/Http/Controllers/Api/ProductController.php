<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query()
            ->with(['category', 'variants'])
            ->where('status', 'active');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->integer('category_id'));
        }

        if ($request->has('search') && $request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->input('search').'%')
                    ->orWhere('description', 'like', '%'.$request->input('search').'%');
            });
        }

        if ($request->has('sort')) {
            switch ($request->input('sort')) {
                case 'price_asc':
                    $query->orderBy('price', 'asc');
                    break;
                case 'price_desc':
                    $query->orderBy('price', 'desc');
                    break;
                case 'rating':
                    $query->orderByDesc('rating');
                    break;
                default:
                    $query->latest();
            }
        } else {
            $query->latest();
        }

        $products = $query->paginate($request->integer('per_page', 12));

        return response()->json($products);
    }

    public function show(Request $request, $id)
    {
        $product = Product::with(['category', 'seller', 'variants', 'reviews.buyer'])
            ->where('status', 'active')
            ->findOrFail($id);

        // Attach whether the logged-in buyer (if any) has this product in favorites.
        $product->is_favorited = false;
        if ($request->user()) {
            $product->is_favorited = $product->favorites()
                ->where('buyer_id', $request->user()->id)
                ->exists();
        }

        return response()->json(['product' => $product]);
    }
}