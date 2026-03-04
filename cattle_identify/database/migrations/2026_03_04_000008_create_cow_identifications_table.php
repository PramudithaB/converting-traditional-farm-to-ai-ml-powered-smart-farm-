<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cow_identifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('image_path')->nullable();       // uploaded query image
            $table->foreignId('matched_cow_id')->nullable()->constrained('cows')->onDelete('set null');
            $table->float('similarity_score')->nullable();  // cosine similarity
            $table->boolean('match_found')->default(false);
            $table->json('all_scores')->nullable();         // all comparison scores
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cow_identifications');
    }
};
