<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('behavior_detections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('cow_id')->nullable()->constrained('cows')->onDelete('set null');
            $table->string('detection_type');              // "snapshot", "video", "analysis"
            $table->string('behavior')->nullable();        // detected behavior class
            $table->float('confidence')->nullable();       // confidence score
            $table->json('details')->nullable();           // full analysis response
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('behavior_detections');
    }
};
