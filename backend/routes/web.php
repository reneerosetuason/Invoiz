<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/img/{path}', function (string $path) {
    $file = storage_path('app/public/' . $path);
    if (! file_exists($file) || ! is_file($file)) {
        abort(404);
    }
    return response()->file($file, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Cache-Control' => 'public, max-age=86400',
    ]);
})->where('path', '.*');
