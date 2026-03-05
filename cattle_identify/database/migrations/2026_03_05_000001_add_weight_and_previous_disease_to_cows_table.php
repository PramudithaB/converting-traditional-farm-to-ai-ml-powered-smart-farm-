<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            $table->decimal('weight', 8, 2)->nullable()->after('lactation_month');
            $table->string('previous_disease')->nullable()->default('None')->after('weight');
        });
    }

    public function down(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            $table->dropColumn(['weight', 'previous_disease']);
        });
    }
};
