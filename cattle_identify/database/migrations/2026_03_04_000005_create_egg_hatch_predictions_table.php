<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('egg_hatch_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->float('temperature');
            $table->float('humidity');
            $table->float('egg_weight');
            $table->integer('egg_turning_frequency');
            $table->integer('incubation_duration');
            $table->float('hatch_probability');            // model output 0-1
            $table->tinyInteger('predicted_class');         // 0 or 1
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('egg_hatch_predictions');
    }
};
