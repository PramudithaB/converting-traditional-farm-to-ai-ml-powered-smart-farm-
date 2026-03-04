<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutrition_recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('cow_id')->nullable()->constrained('cows')->onDelete('set null');
            $table->json('input_data');                     // all input fields
            $table->float('dry_matter_intake_kg');          // model output
            $table->float('calcium_g_per_day');
            $table->float('phosphorus_g_per_day');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutrition_recommendations');
    }
};
