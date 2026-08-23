<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add per-store theme fields so each seller account can brand its store.
     */
    public function up(): void
    {
        Schema::table('sellers', function (Blueprint $table) {
            $table->string('primary_color', 7)->nullable()->default('#16697A')->after('line_of_business');
            $table->string('accent_color', 7)->nullable()->default('#F0A202')->after('primary_color');
            $table->string('logo', 255)->nullable()->after('accent_color');
        });
    }

    public function down(): void
    {
        Schema::table('sellers', function (Blueprint $table) {
            $table->dropColumn(['primary_color', 'accent_color', 'logo']);
        });
    }
};