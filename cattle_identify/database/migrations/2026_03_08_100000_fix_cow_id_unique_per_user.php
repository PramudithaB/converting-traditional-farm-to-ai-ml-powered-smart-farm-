<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            // Drop the global unique index on cow_id
            $table->dropUnique('cows_cow_id_unique');

            // Add composite unique: same user cannot have duplicate cow_id,
            // but different users can independently have COW-001, COW-002, etc.
            $table->unique(['user_id', 'cow_id'], 'cows_user_cow_id_unique');
        });
    }

    public function down(): void
    {
        Schema::table('cows', function (Blueprint $table) {
            $table->dropUnique('cows_user_cow_id_unique');
            $table->unique('cow_id', 'cows_cow_id_unique');
        });
    }
};
