<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cow_feeds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cow_id')->constrained('cows')->onDelete('cascade');
            $table->float('cow_weight_kg');   // weight used for prediction
            $table->float('milk_yield_l');    // milk yield used
            $table->string('activity');       // activity used (e.g. "Low", "High")
            $table->float('daily_feed_kg');   // result from Python
            $table->date('date');             // date for which this feed is recorded
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cow_feeds');
    }
};