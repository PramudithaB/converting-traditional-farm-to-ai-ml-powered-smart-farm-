<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('milk_market_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->float('current_price');                // LKR per litre
            $table->float('monthly_milk_litres');
            $table->float('fat_percentage');
            $table->float('snf_percentage');
            $table->integer('disease_stage');
            $table->integer('feed_quality');
            $table->integer('lactation_month');
            $table->integer('month');
            $table->float('predicted_price_change');       // model output
            $table->float('predicted_next_price');
            $table->float('predicted_next_income');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('milk_market_predictions');
    }
};
