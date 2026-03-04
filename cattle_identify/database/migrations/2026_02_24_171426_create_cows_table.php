<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cows', function (Blueprint $table) {
            $table->id();
            $table->string('cow_id')->unique();      // business ID
            $table->string('name');
            $table->string('breed')->nullable();
            $table->unsignedInteger('lactation_month')->nullable();
            $table->string('image_path')->nullable();
            $table->text('embedding')->nullable();   // e.g. JSON or serialized vector
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cows');
    }
};