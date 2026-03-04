<?php

namespace Database\Seeders;

use App\Models\CowFeed;
use Illuminate\Database\Seeder;

class CowFeedSeeder extends Seeder
{
    public function run(): void
    {
        // Feed records for the past 7 days per cow
        // cow_id (FK to cows.id) maps: COW-001=1, COW-002=2 ... COW-009=9
        $records = [
            // Bella (id=1) - Holstein, heavy milker
            ['cow_id' => 1, 'cow_weight_kg' => 520, 'milk_yield_l' => 28, 'activity' => 'High',   'daily_feed_kg' => 22.4, 'date' => '2026-02-26'],
            ['cow_id' => 1, 'cow_weight_kg' => 521, 'milk_yield_l' => 27, 'activity' => 'Medium', 'daily_feed_kg' => 21.8, 'date' => '2026-02-27'],
            ['cow_id' => 1, 'cow_weight_kg' => 520, 'milk_yield_l' => 29, 'activity' => 'High',   'daily_feed_kg' => 22.6, 'date' => '2026-02-28'],
            ['cow_id' => 1, 'cow_weight_kg' => 522, 'milk_yield_l' => 26, 'activity' => 'Low',    'daily_feed_kg' => 20.5, 'date' => '2026-03-01'],
            ['cow_id' => 1, 'cow_weight_kg' => 520, 'milk_yield_l' => 28, 'activity' => 'Medium', 'daily_feed_kg' => 21.9, 'date' => '2026-03-02'],
            ['cow_id' => 1, 'cow_weight_kg' => 519, 'milk_yield_l' => 27, 'activity' => 'Medium', 'daily_feed_kg' => 21.7, 'date' => '2026-03-03'],
            ['cow_id' => 1, 'cow_weight_kg' => 521, 'milk_yield_l' => 28, 'activity' => 'High',   'daily_feed_kg' => 22.3, 'date' => '2026-03-04'],

            // Daisy (id=2) - Jersey
            ['cow_id' => 2, 'cow_weight_kg' => 420, 'milk_yield_l' => 20, 'activity' => 'Medium', 'daily_feed_kg' => 17.5, 'date' => '2026-02-26'],
            ['cow_id' => 2, 'cow_weight_kg' => 421, 'milk_yield_l' => 19, 'activity' => 'Low',    'daily_feed_kg' => 16.8, 'date' => '2026-02-27'],
            ['cow_id' => 2, 'cow_weight_kg' => 420, 'milk_yield_l' => 21, 'activity' => 'Medium', 'daily_feed_kg' => 17.8, 'date' => '2026-02-28'],
            ['cow_id' => 2, 'cow_weight_kg' => 419, 'milk_yield_l' => 20, 'activity' => 'Medium', 'daily_feed_kg' => 17.4, 'date' => '2026-03-01'],
            ['cow_id' => 2, 'cow_weight_kg' => 420, 'milk_yield_l' => 22, 'activity' => 'High',   'daily_feed_kg' => 18.2, 'date' => '2026-03-02'],
            ['cow_id' => 2, 'cow_weight_kg' => 421, 'milk_yield_l' => 20, 'activity' => 'Medium', 'daily_feed_kg' => 17.6, 'date' => '2026-03-03'],
            ['cow_id' => 2, 'cow_weight_kg' => 420, 'milk_yield_l' => 21, 'activity' => 'Medium', 'daily_feed_kg' => 17.9, 'date' => '2026-03-04'],

            // Rosie (id=3) - Friesian
            ['cow_id' => 3, 'cow_weight_kg' => 480, 'milk_yield_l' => 23, 'activity' => 'Medium', 'daily_feed_kg' => 19.2, 'date' => '2026-03-01'],
            ['cow_id' => 3, 'cow_weight_kg' => 481, 'milk_yield_l' => 24, 'activity' => 'High',   'daily_feed_kg' => 19.8, 'date' => '2026-03-02'],
            ['cow_id' => 3, 'cow_weight_kg' => 480, 'milk_yield_l' => 22, 'activity' => 'Medium', 'daily_feed_kg' => 18.9, 'date' => '2026-03-03'],
            ['cow_id' => 3, 'cow_weight_kg' => 479, 'milk_yield_l' => 23, 'activity' => 'Medium', 'daily_feed_kg' => 19.1, 'date' => '2026-03-04'],

            // Molly (id=4) - Ayrshire, older
            ['cow_id' => 4, 'cow_weight_kg' => 450, 'milk_yield_l' => 15, 'activity' => 'Low',    'daily_feed_kg' => 15.5, 'date' => '2026-03-02'],
            ['cow_id' => 4, 'cow_weight_kg' => 450, 'milk_yield_l' => 16, 'activity' => 'Low',    'daily_feed_kg' => 15.8, 'date' => '2026-03-03'],
            ['cow_id' => 4, 'cow_weight_kg' => 451, 'milk_yield_l' => 15, 'activity' => 'Low',    'daily_feed_kg' => 15.5, 'date' => '2026-03-04'],

            // Lila (id=5) - Holstein, early lactation
            ['cow_id' => 5, 'cow_weight_kg' => 490, 'milk_yield_l' => 25, 'activity' => 'High',   'daily_feed_kg' => 20.9, 'date' => '2026-03-03'],
            ['cow_id' => 5, 'cow_weight_kg' => 491, 'milk_yield_l' => 26, 'activity' => 'High',   'daily_feed_kg' => 21.4, 'date' => '2026-03-04'],

            // Mango (id=6) - Jersey
            ['cow_id' => 6, 'cow_weight_kg' => 415, 'milk_yield_l' => 18, 'activity' => 'Medium', 'daily_feed_kg' => 16.2, 'date' => '2026-03-03'],
            ['cow_id' => 6, 'cow_weight_kg' => 416, 'milk_yield_l' => 19, 'activity' => 'Medium', 'daily_feed_kg' => 16.7, 'date' => '2026-03-04'],

            // Pearl (id=7)
            ['cow_id' => 7, 'cow_weight_kg' => 460, 'milk_yield_l' => 20, 'activity' => 'Medium', 'daily_feed_kg' => 17.8, 'date' => '2026-03-04'],

            // Lotus (id=8)
            ['cow_id' => 8, 'cow_weight_kg' => 500, 'milk_yield_l' => 24, 'activity' => 'High',   'daily_feed_kg' => 20.5, 'date' => '2026-03-04'],

            // Amber (id=9) - oldest, reduced lactation
            ['cow_id' => 9, 'cow_weight_kg' => 530, 'milk_yield_l' => 10, 'activity' => 'Low',    'daily_feed_kg' => 14.2, 'date' => '2026-03-04'],
        ];

        foreach ($records as $record) {
            CowFeed::create($record);
        }
    }
}
