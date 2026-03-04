<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     * Order matters: Users → Cows → Feeds → Predictions
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            CowSeeder::class,
            CowFeedSeeder::class,
            PredictionSeeder::class,
        ]);
    }
}
