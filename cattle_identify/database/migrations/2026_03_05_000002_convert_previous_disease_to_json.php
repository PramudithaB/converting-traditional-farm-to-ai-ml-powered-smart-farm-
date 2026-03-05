<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Convert existing string values to JSON arrays.
        // Only rows that are not already a JSON array get wrapped.
        DB::statement(
            'UPDATE cows SET previous_disease = JSON_ARRAY(previous_disease) WHERE previous_disease IS NOT NULL AND previous_disease NOT LIKE \'[%\''
        );

        // Change the column type to JSON.
        DB::statement('ALTER TABLE cows MODIFY COLUMN previous_disease JSON NULL');
    }

    public function down(): void
    {
        // Extract the first element of the JSON array back to a plain VARCHAR.
        DB::statement(
            'UPDATE cows SET previous_disease = JSON_UNQUOTE(JSON_EXTRACT(previous_disease, \'$[0]\')) WHERE previous_disease IS NOT NULL'
        );

        DB::statement('ALTER TABLE cows MODIFY COLUMN previous_disease VARCHAR(255) NULL DEFAULT \'None\'');
    }
};
