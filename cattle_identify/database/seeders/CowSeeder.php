<?php

namespace Database\Seeders;

use App\Models\Cow;
use Illuminate\Database\Seeder;

class CowSeeder extends Seeder
{
    public function run(): void
    {
        $cows = [
            // User 1 cows
            [
                'user_id'         => 1,
                'cow_id'          => 'COW-001',
                'name'            => 'Bella',
                'breed'           => 'Holstein',
                'lactation_month' => 4,
                'birthdate'       => '2021-03-15',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 1,
                'cow_id'          => 'COW-002',
                'name'            => 'Daisy',
                'breed'           => 'Jersey',
                'lactation_month' => 7,
                'birthdate'       => '2020-07-20',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 1,
                'cow_id'          => 'COW-003',
                'name'            => 'Rosie',
                'breed'           => 'Friesian',
                'lactation_month' => 2,
                'birthdate'       => '2022-11-10',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 1,
                'cow_id'          => 'COW-004',
                'name'            => 'Molly',
                'breed'           => 'Ayrshire',
                'lactation_month' => 9,
                'birthdate'       => '2019-05-03',
                'image_path'      => null,
                'embedding'       => null,
            ],
            // User 2 cows
            [
                'user_id'         => 2,
                'cow_id'          => 'COW-005',
                'name'            => 'Lila',
                'breed'           => 'Holstein',
                'lactation_month' => 1,
                'birthdate'       => '2023-02-28',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 2,
                'cow_id'          => 'COW-006',
                'name'            => 'Mango',
                'breed'           => 'Jersey',
                'lactation_month' => 5,
                'birthdate'       => '2021-09-14',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 2,
                'cow_id'          => 'COW-007',
                'name'            => 'Pearl',
                'breed'           => 'Brown Swiss',
                'lactation_month' => 3,
                'birthdate'       => '2022-04-22',
                'image_path'      => null,
                'embedding'       => null,
            ],
            // User 3 cows
            [
                'user_id'         => 3,
                'cow_id'          => 'COW-008',
                'name'            => 'Lotus',
                'breed'           => 'Friesian',
                'lactation_month' => 6,
                'birthdate'       => '2020-12-01',
                'image_path'      => null,
                'embedding'       => null,
            ],
            [
                'user_id'         => 3,
                'cow_id'          => 'COW-009',
                'name'            => 'Amber',
                'breed'           => 'Holstein',
                'lactation_month' => 10,
                'birthdate'       => '2018-08-17',
                'image_path'      => null,
                'embedding'       => null,
            ],
        ];

        foreach ($cows as $cow) {
            Cow::create($cow);
        }
    }
}
