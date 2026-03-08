<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnimalBirthPrediction;
use App\Models\BehaviorDetection;
use App\Models\CowIdentification;
use App\Models\DiseaseDetection;
use App\Models\EggHatchPrediction;
use App\Models\MilkMarketPrediction;
use App\Models\NutritionRecommendation;
use Illuminate\Http\Request;

class PredictionController extends Controller
{
    // ─── Animal Birth ───
    public function storeAnimalBirth(Request $request)
    {
        $data = $request->validate([
            'cow_id'                  => 'nullable|exists:cows,id',
            'features'                => 'required|array',
            'estimated_days_to_birth' => 'required|numeric',
            'will_birth_in_2_days'    => 'required|string',
        ]);

        $record = AnimalBirthPrediction::create([
            'user_id'                  => $request->user()?->id,
            'cow_id'                   => $data['cow_id'] ?? null,
            'features'                 => $data['features'],
            'estimated_days_to_birth'  => $data['estimated_days_to_birth'],
            'will_birth_in_2_days'     => $data['will_birth_in_2_days'],
        ]);

        return response()->json($record, 201);
    }

    public function indexAnimalBirth(Request $request)
    {
        return response()->json(
            AnimalBirthPrediction::where('user_id', $request->user()?->id)
                ->with(['cow:id,cow_id,name'])
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Disease Detection ───
    public function storeDiseaseDetection(Request $request)
    {
        $data = $request->validate([
            'cow_id'           => 'nullable|exists:cows,id',
            'image_path'       => 'nullable|string',
            'model_used'       => 'required|string',
            'disease_name'     => 'required|string',
            'confidence'       => 'required|numeric',
            'all_predictions'  => 'nullable|array',
            'severity'         => 'nullable|array',
            'treatment'        => 'nullable|array',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = DiseaseDetection::create($data);
        return response()->json($record, 201);
    }

    public function indexDiseaseDetection(Request $request)
    {
        return response()->json(
            DiseaseDetection::where('user_id', $request->user()?->id)
                ->with(['cow:id,cow_id,name'])
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Behavior Detection ───
    public function storeBehaviorDetection(Request $request)
    {
        $data = $request->validate([
            'cow_id'          => 'nullable|exists:cows,id',
            'detection_type'  => 'required|string',
            'behavior'        => 'nullable|string',
            'confidence'      => 'nullable|numeric',
            'details'         => 'nullable|array',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = BehaviorDetection::create($data);
        return response()->json($record, 201);
    }

    public function indexBehaviorDetection(Request $request)
    {
        return response()->json(
            BehaviorDetection::where('user_id', $request->user()?->id)
                ->with(['cow:id,cow_id,name'])
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Egg Hatch ───
    public function storeEggHatch(Request $request)
    {
        $data = $request->validate([
            'temperature'             => 'required|numeric',
            'humidity'                => 'required|numeric',
            'egg_weight'              => 'required|numeric',
            'egg_turning_frequency'   => 'required|integer',
            'incubation_duration'     => 'required|integer',
            'hatch_probability'       => 'required|numeric',
            'predicted_class'         => 'required|integer',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = EggHatchPrediction::create($data);
        return response()->json($record, 201);
    }

    public function indexEggHatch(Request $request)
    {
        return response()->json(
            EggHatchPrediction::where('user_id', $request->user()?->id)
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Milk Market ───
    public function storeMilkMarket(Request $request)
    {
        $data = $request->validate([
            'current_price'            => 'required|numeric',
            'monthly_milk_litres'      => 'required|numeric',
            'fat_percentage'           => 'required|numeric',
            'snf_percentage'           => 'required|numeric',
            'disease_stage'            => 'required|integer',
            'feed_quality'             => 'required|integer',
            'lactation_month'          => 'required|integer',
            'month'                    => 'required|integer',
            'predicted_price_change'   => 'required|numeric',
            'predicted_next_price'     => 'required|numeric',
            'predicted_next_income'    => 'required|numeric',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = MilkMarketPrediction::create($data);
        return response()->json($record, 201);
    }

    public function indexMilkMarket(Request $request)
    {
        return response()->json(
            MilkMarketPrediction::where('user_id', $request->user()?->id)
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Nutrition ───
    public function storeNutrition(Request $request)
    {
        $data = $request->validate([
            'cow_id'                => 'nullable|exists:cows,id',
            'input_data'            => 'required|array',
            'dry_matter_intake_kg'  => 'required|numeric',
            'calcium_g_per_day'     => 'required|numeric',
            'phosphorus_g_per_day'  => 'required|numeric',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = NutritionRecommendation::create($data);
        return response()->json($record, 201);
    }

    public function indexNutrition(Request $request)
    {
        return response()->json(
            NutritionRecommendation::where('user_id', $request->user()?->id)
                ->orderByDesc('created_at')->get()
        );
    }

    // ─── Cow Identification ───
    public function storeCowIdentification(Request $request)
    {
        $data = $request->validate([
            'image_path'       => 'nullable|string',
            'matched_cow_id'   => 'nullable|exists:cows,id',
            'similarity_score' => 'nullable|numeric',
            'match_found'      => 'required|boolean',
            'all_scores'       => 'nullable|array',
        ]);

        $data['user_id'] = $request->user()?->id;

        $record = CowIdentification::create($data);
        return response()->json($record, 201);
    }

    public function indexCowIdentification(Request $request)
    {
        return response()->json(
            CowIdentification::where('user_id', $request->user()?->id)
                ->with('matchedCow:id,cow_id,name,breed')
                ->orderByDesc('created_at')->get()
        );
    }
}
