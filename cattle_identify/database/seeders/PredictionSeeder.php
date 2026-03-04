<?php

namespace Database\Seeders;

use App\Models\AnimalBirthPrediction;
use App\Models\BehaviorDetection;
use App\Models\CowIdentification;
use App\Models\DiseaseDetection;
use App\Models\EggHatchPrediction;
use App\Models\MilkMarketPrediction;
use App\Models\NutritionRecommendation;
use Illuminate\Database\Seeder;

class PredictionSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedAnimalBirth();
        $this->seedDiseaseDetections();
        $this->seedBehaviorDetections();
        $this->seedEggHatch();
        $this->seedMilkMarket();
        $this->seedNutrition();
        $this->seedCowIdentifications();
    }

    // ─── Animal Birth ─────────────────────────────────────────────────────────

    private function seedAnimalBirth(): void
    {
        $records = [
            [
                'user_id'                => 1,
                'cow_id'                 => 2, // Daisy - pregnant
                'features'               => [101.5, 1198, 268, 5.2, 6.8],
                'estimated_days_to_birth' => 1.6,
                'will_birth_in_2_days'   => 'Yes',
                'created_at'             => now()->subDays(3),
            ],
            [
                'user_id'                => 1,
                'cow_id'                 => 1, // Bella - not yet
                'features'               => [100.2, 1180, 240, 4.8, 5.1],
                'estimated_days_to_birth' => 14.2,
                'will_birth_in_2_days'   => 'No',
                'created_at'             => now()->subDays(5),
            ],
            [
                'user_id'                => 2,
                'cow_id'                 => 5, // Lila - very close
                'features'               => [102.1, 1220, 274, 5.5, 7.3],
                'estimated_days_to_birth' => 0.5,
                'will_birth_in_2_days'   => 'Yes',
                'created_at'             => now()->subDays(1),
            ],
            [
                'user_id'                => 2,
                'cow_id'                 => 6, // Mango
                'features'               => [99.8, 1160, 230, 4.5, 4.9],
                'estimated_days_to_birth' => 22.0,
                'will_birth_in_2_days'   => 'No',
                'created_at'             => now()->subDays(2),
            ],
            [
                'user_id'                => 3,
                'cow_id'                 => 8, // Lotus
                'features'               => [101.0, 1205, 262, 5.1, 6.5],
                'estimated_days_to_birth' => 3.8,
                'will_birth_in_2_days'   => 'No',
                'created_at'             => now()->subDay(),
            ],
        ];

        foreach ($records as $r) {
            AnimalBirthPrediction::create($r);
        }
    }

    // ─── Disease Detection ────────────────────────────────────────────────────

    private function seedDiseaseDetections(): void
    {
        $records = [
            [
                'user_id'         => 1,
                'cow_id'          => 4, // Molly - sick
                'image_path'      => null,
                'model_used'      => 'densenet',
                'disease_name'    => 'Mastitis',
                'confidence'      => 0.91,
                'all_predictions' => ['Mastitis' => 0.91, 'Healthy' => 0.06, 'FMD' => 0.03],
                'severity'        => ['level' => 'Moderate', 'score' => 6, 'urgent' => true],
                'treatment'       => ['primary' => 'Intramammary antibiotics', 'secondary' => 'Rest & increased milking frequency', 'duration_days' => 5],
                'created_at'      => now()->subDays(4),
            ],
            [
                'user_id'         => 1,
                'cow_id'          => 1, // Bella - healthy
                'image_path'      => null,
                'model_used'      => 'densenet',
                'disease_name'    => 'Healthy',
                'confidence'      => 0.95,
                'all_predictions' => ['Healthy' => 0.95, 'Mastitis' => 0.03, 'FMD' => 0.02],
                'severity'        => null,
                'treatment'       => null,
                'created_at'      => now()->subDays(2),
            ],
            [
                'user_id'         => 2,
                'cow_id'          => 7, // Pearl - FMD suspected
                'image_path'      => null,
                'model_used'      => 'yolo+densenet',
                'disease_name'    => 'Foot and Mouth Disease',
                'confidence'      => 0.78,
                'all_predictions' => ['Foot and Mouth Disease' => 0.78, 'Healthy' => 0.14, 'Mastitis' => 0.08],
                'severity'        => ['level' => 'High', 'score' => 8, 'urgent' => true],
                'treatment'       => ['primary' => 'Isolate immediately', 'secondary' => 'Antiviral treatment, wound care', 'duration_days' => 14],
                'created_at'      => now()->subDays(1),
            ],
            [
                'user_id'         => 3,
                'cow_id'          => 9, // Amber - lumpy skin
                'image_path'      => null,
                'model_used'      => 'densenet',
                'disease_name'    => 'Lumpy Skin Disease',
                'confidence'      => 0.84,
                'all_predictions' => ['Lumpy Skin Disease' => 0.84, 'Healthy' => 0.10, 'BRD' => 0.06],
                'severity'        => ['level' => 'High', 'score' => 7, 'urgent' => true],
                'treatment'       => ['primary' => 'Vaccination, anti-inflammatory', 'secondary' => 'Topical wound treatment', 'duration_days' => 10],
                'created_at'      => now()->subDays(3),
            ],
            [
                'user_id'         => 3,
                'cow_id'          => 8, // Lotus - healthy check
                'image_path'      => null,
                'model_used'      => 'densenet',
                'disease_name'    => 'Healthy',
                'confidence'      => 0.97,
                'all_predictions' => ['Healthy' => 0.97, 'Mastitis' => 0.02, 'BRD' => 0.01],
                'severity'        => null,
                'treatment'       => null,
                'created_at'      => now(),
            ],
        ];

        foreach ($records as $r) {
            DiseaseDetection::create($r);
        }
    }

    // ─── Behavior Detection ───────────────────────────────────────────────────

    private function seedBehaviorDetections(): void
    {
        $records = [
            [
                'user_id'        => 1,
                'cow_id'         => 1,
                'detection_type' => 'video',
                'behavior'       => 'Eating',
                'confidence'     => 0.88,
                'details'        => ['count' => 3, 'behaviors' => [['behavior' => 'Eating', 'confidence' => 0.88], ['behavior' => 'Standing', 'confidence' => 0.75]]],
                'created_at'     => now()->subHours(3),
            ],
            [
                'user_id'        => 1,
                'cow_id'         => 2,
                'detection_type' => 'snapshot',
                'behavior'       => 'Lying',
                'confidence'     => 0.92,
                'details'        => ['eating_time' => 3.5, 'lying_time' => 5.0, 'steps' => 80, 'rumination_time' => 2.0, 'temperature' => 38.5, 'alert' => 'Normal behavior'],
                'created_at'     => now()->subHours(6),
            ],
            [
                'user_id'        => 1,
                'cow_id'         => 4, // Molly - sick behavior
                'detection_type' => 'snapshot',
                'behavior'       => 'Restless',
                'confidence'     => 0.80,
                'details'        => ['eating_time' => 1.2, 'lying_time' => 2.0, 'steps' => 320, 'rumination_time' => 0.5, 'temperature' => 39.8, 'alert' => 'Possible illness - reduced eating'],
                'created_at'     => now()->subDays(1),
            ],
            [
                'user_id'        => 2,
                'cow_id'         => 5,
                'detection_type' => 'video',
                'behavior'       => 'Eating',
                'confidence'     => 0.85,
                'details'        => ['count' => 2, 'behaviors' => [['behavior' => 'Eating', 'confidence' => 0.85]]],
                'created_at'     => now()->subHours(2),
            ],
            [
                'user_id'        => 2,
                'cow_id'         => 6,
                'detection_type' => 'snapshot',
                'behavior'       => 'Ruminating',
                'confidence'     => 0.90,
                'details'        => ['eating_time' => 4.0, 'lying_time' => 4.5, 'steps' => 100, 'rumination_time' => 3.5, 'temperature' => 38.4, 'alert' => 'Healthy - good rumination'],
                'created_at'     => now()->subHours(1),
            ],
            [
                'user_id'        => 3,
                'cow_id'         => 9,
                'detection_type' => 'video',
                'behavior'       => 'Lame Walking',
                'confidence'     => 0.76,
                'details'        => ['count' => 1, 'behaviors' => [['behavior' => 'Lame Walking', 'confidence' => 0.76]], 'alert' => 'Possible hoof issue'],
                'created_at'     => now()->subDays(2),
            ],
        ];

        foreach ($records as $r) {
            BehaviorDetection::create($r);
        }
    }

    // ─── Egg Hatch Predictions ────────────────────────────────────────────────

    private function seedEggHatch(): void
    {
        $records = [
            [
                'user_id'               => 1,
                'temperature'           => 37.5,
                'humidity'              => 60.0,
                'egg_weight'            => 62.0,
                'egg_turning_frequency' => 4,
                'incubation_duration'   => 18,
                'hatch_probability'     => 0.87,
                'predicted_class'       => 1,
                'created_at'            => now()->subDays(5),
            ],
            [
                'user_id'               => 1,
                'temperature'           => 38.0,
                'humidity'              => 55.0,
                'egg_weight'            => 58.0,
                'egg_turning_frequency' => 3,
                'incubation_duration'   => 20,
                'hatch_probability'     => 0.72,
                'predicted_class'       => 1,
                'created_at'            => now()->subDays(3),
            ],
            [
                'user_id'               => 2,
                'temperature'           => 36.8,
                'humidity'              => 65.0,
                'egg_weight'            => 55.0,
                'egg_turning_frequency' => 2,
                'incubation_duration'   => 15,
                'hatch_probability'     => 0.45,
                'predicted_class'       => 0,
                'created_at'            => now()->subDays(2),
            ],
            [
                'user_id'               => 2,
                'temperature'           => 37.6,
                'humidity'              => 62.0,
                'egg_weight'            => 63.5,
                'egg_turning_frequency' => 5,
                'incubation_duration'   => 19,
                'hatch_probability'     => 0.91,
                'predicted_class'       => 1,
                'created_at'            => now()->subDay(),
            ],
            [
                'user_id'               => 3,
                'temperature'           => 37.2,
                'humidity'              => 58.0,
                'egg_weight'            => 60.0,
                'egg_turning_frequency' => 4,
                'incubation_duration'   => 18,
                'hatch_probability'     => 0.82,
                'predicted_class'       => 1,
                'created_at'            => now(),
            ],
            [
                'user_id'               => 1,
                'temperature'           => 39.1,
                'humidity'              => 45.0,
                'egg_weight'            => 50.0,
                'egg_turning_frequency' => 1,
                'incubation_duration'   => 10,
                'hatch_probability'     => 0.18,
                'predicted_class'       => 0,
                'created_at'            => now()->subDays(7),
            ],
        ];

        foreach ($records as $r) {
            EggHatchPrediction::create($r);
        }
    }

    // ─── Milk Market Predictions ──────────────────────────────────────────────

    private function seedMilkMarket(): void
    {
        $records = [
            [
                'user_id'               => 1,
                'current_price'         => 55.0,
                'monthly_milk_litres'   => 1200,
                'fat_percentage'        => 4.2,
                'snf_percentage'        => 8.6,
                'disease_stage'         => 0,
                'feed_quality'          => 5,
                'lactation_month'       => 4,
                'month'                 => 1,
                'predicted_price_change' => 2.8,
                'predicted_next_price'  => 57.8,
                'predicted_next_income' => 69360.0,
                'created_at'            => now()->subDays(30),
            ],
            [
                'user_id'               => 1,
                'current_price'         => 57.8,
                'monthly_milk_litres'   => 1180,
                'fat_percentage'        => 4.1,
                'snf_percentage'        => 8.5,
                'disease_stage'         => 0,
                'feed_quality'          => 4,
                'lactation_month'       => 5,
                'month'                 => 2,
                'predicted_price_change' => -1.2,
                'predicted_next_price'  => 56.6,
                'predicted_next_income' => 66788.0,
                'created_at'            => now()->subDays(2),
            ],
            [
                'user_id'               => 2,
                'current_price'         => 52.0,
                'monthly_milk_litres'   => 950,
                'fat_percentage'        => 4.5,
                'snf_percentage'        => 8.8,
                'disease_stage'         => 0,
                'feed_quality'          => 5,
                'lactation_month'       => 2,
                'month'                 => 2,
                'predicted_price_change' => 3.5,
                'predicted_next_price'  => 55.5,
                'predicted_next_income' => 52725.0,
                'created_at'            => now()->subDays(5),
            ],
            [
                'user_id'               => 2,
                'current_price'         => 55.5,
                'monthly_milk_litres'   => 980,
                'fat_percentage'        => 4.4,
                'snf_percentage'        => 8.7,
                'disease_stage'         => 1,
                'feed_quality'          => 4,
                'lactation_month'       => 3,
                'month'                 => 3,
                'predicted_price_change' => -2.0,
                'predicted_next_price'  => 53.5,
                'predicted_next_income' => 52430.0,
                'created_at'            => now()->subDay(),
            ],
            [
                'user_id'               => 3,
                'current_price'         => 50.0,
                'monthly_milk_litres'   => 800,
                'fat_percentage'        => 3.9,
                'snf_percentage'        => 8.3,
                'disease_stage'         => 2,
                'feed_quality'          => 3,
                'lactation_month'       => 9,
                'month'                 => 3,
                'predicted_price_change' => -4.5,
                'predicted_next_price'  => 45.5,
                'predicted_next_income' => 36400.0,
                'created_at'            => now(),
            ],
        ];

        foreach ($records as $r) {
            MilkMarketPrediction::create($r);
        }
    }

    // ─── Nutrition Recommendations ────────────────────────────────────────────

    private function seedNutrition(): void
    {
        $records = [
            [
                'user_id'              => 1,
                'cow_id'               => 1,
                'input_data'           => [
                    'Age_Months' => 60, 'Weight_kg' => 520, 'Breed' => 'Holstein',
                    'Milk_Yield_L_per_day' => 28, 'Health_Status' => 'Healthy',
                    'Disease' => 'None', 'Body_Condition_Score' => 3.0,
                    'Location' => 'Farm', 'Energy_MJ_per_day' => 135, 'Crude_Protein_g_per_day' => 1800,
                ],
                'dry_matter_intake_kg' => 20.5,
                'calcium_g_per_day'    => 76.0,
                'phosphorus_g_per_day' => 58.0,
                'created_at'           => now()->subDays(3),
            ],
            [
                'user_id'              => 1,
                'cow_id'               => 2,
                'input_data'           => [
                    'Age_Months' => 68, 'Weight_kg' => 420, 'Breed' => 'Jersey',
                    'Milk_Yield_L_per_day' => 20, 'Health_Status' => 'Healthy',
                    'Disease' => 'None', 'Body_Condition_Score' => 3.5,
                    'Location' => 'Farm', 'Energy_MJ_per_day' => 110, 'Crude_Protein_g_per_day' => 1500,
                ],
                'dry_matter_intake_kg' => 16.8,
                'calcium_g_per_day'    => 62.0,
                'phosphorus_g_per_day' => 48.0,
                'created_at'           => now()->subDays(3),
            ],
            [
                'user_id'              => 1,
                'cow_id'               => 4, // Molly - diseased, needs adjusted nutrition
                'input_data'           => [
                    'Age_Months' => 82, 'Weight_kg' => 450, 'Breed' => 'Ayrshire',
                    'Milk_Yield_L_per_day' => 15, 'Health_Status' => 'Sick',
                    'Disease' => 'Mastitis', 'Body_Condition_Score' => 2.5,
                    'Location' => 'Farm', 'Energy_MJ_per_day' => 95, 'Crude_Protein_g_per_day' => 1300,
                ],
                'dry_matter_intake_kg' => 14.2,
                'calcium_g_per_day'    => 55.0,
                'phosphorus_g_per_day' => 42.0,
                'created_at'           => now()->subDays(1),
            ],
            [
                'user_id'              => 2,
                'cow_id'               => 5,
                'input_data'           => [
                    'Age_Months' => 36, 'Weight_kg' => 490, 'Breed' => 'Holstein',
                    'Milk_Yield_L_per_day' => 25, 'Health_Status' => 'Healthy',
                    'Disease' => 'None', 'Body_Condition_Score' => 3.0,
                    'Location' => 'Farm', 'Energy_MJ_per_day' => 125, 'Crude_Protein_g_per_day' => 1700,
                ],
                'dry_matter_intake_kg' => 19.5,
                'calcium_g_per_day'    => 70.0,
                'phosphorus_g_per_day' => 53.0,
                'created_at'           => now()->subDays(2),
            ],
            [
                'user_id'              => 3,
                'cow_id'               => 9, // Amber - old, low production
                'input_data'           => [
                    'Age_Months' => 91, 'Weight_kg' => 530, 'Breed' => 'Holstein',
                    'Milk_Yield_L_per_day' => 10, 'Health_Status' => 'Sick',
                    'Disease' => 'Lumpy Skin Disease', 'Body_Condition_Score' => 2.0,
                    'Location' => 'Farm', 'Energy_MJ_per_day' => 85, 'Crude_Protein_g_per_day' => 1100,
                ],
                'dry_matter_intake_kg' => 13.0,
                'calcium_g_per_day'    => 48.0,
                'phosphorus_g_per_day' => 38.0,
                'created_at'           => now(),
            ],
        ];

        foreach ($records as $r) {
            NutritionRecommendation::create($r);
        }
    }

    // ─── Cow Identification ───────────────────────────────────────────────────

    private function seedCowIdentifications(): void
    {
        $records = [
            [
                'user_id'          => 1,
                'image_path'       => null,
                'matched_cow_id'   => 1,
                'similarity_score' => 0.94,
                'match_found'      => true,
                'all_scores'       => ['COW-001' => 0.94, 'COW-002' => 0.31, 'COW-003' => 0.18],
                'created_at'       => now()->subDays(2),
            ],
            [
                'user_id'          => 1,
                'image_path'       => null,
                'matched_cow_id'   => 2,
                'similarity_score' => 0.88,
                'match_found'      => true,
                'all_scores'       => ['COW-001' => 0.22, 'COW-002' => 0.88, 'COW-003' => 0.42],
                'created_at'       => now()->subDay(),
            ],
            [
                'user_id'          => 1,
                'image_path'       => null,
                'matched_cow_id'   => null,
                'similarity_score' => 0.38,
                'match_found'      => false,
                'all_scores'       => ['COW-001' => 0.38, 'COW-002' => 0.29, 'COW-003' => 0.21],
                'created_at'       => now()->subHours(5),
            ],
            [
                'user_id'          => 2,
                'image_path'       => null,
                'matched_cow_id'   => 5,
                'similarity_score' => 0.91,
                'match_found'      => true,
                'all_scores'       => ['COW-005' => 0.91, 'COW-006' => 0.33, 'COW-007' => 0.15],
                'created_at'       => now()->subDays(3),
            ],
            [
                'user_id'          => 3,
                'image_path'       => null,
                'matched_cow_id'   => 8,
                'similarity_score' => 0.86,
                'match_found'      => true,
                'all_scores'       => ['COW-008' => 0.86, 'COW-009' => 0.45],
                'created_at'       => now(),
            ],
        ];

        foreach ($records as $r) {
            CowIdentification::create($r);
        }
    }
}
