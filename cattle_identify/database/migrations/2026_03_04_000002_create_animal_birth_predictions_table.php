<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('animal_birth_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('cow_id')->nullable()->constrained('cows')->onDelete('set null');
            $table->json('features');                     // input feature array
            $table->float('estimated_days_to_birth');     // model output
            $table->string('will_birth_in_2_days');       // "Yes" / "No"
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animal_birth_predictions');
    }
};
