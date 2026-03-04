<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('disease_detections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('cow_id')->nullable()->constrained('cows')->onDelete('set null');
            $table->string('image_path')->nullable();
            $table->string('model_used');                  // "densenet", "yolo", "both"
            $table->string('disease_name');                 // predicted disease
            $table->float('confidence');                    // top confidence score
            $table->json('all_predictions')->nullable();    // full prediction scores
            $table->json('severity')->nullable();           // severity analysis result
            $table->json('treatment')->nullable();          // treatment recommendation
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('disease_detections');
    }
};
