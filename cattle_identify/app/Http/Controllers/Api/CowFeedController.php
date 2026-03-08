<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cow;
use App\Models\CowFeed;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CowFeedController extends Controller
{
    /**
     * POST /api/cows/{cow}/feed
     * Calculate and save daily feed for a cow
     */
       public function storeFromImage(Request $request, Cow $cow)
    {
        $data = $request->validate([
            'image'       => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
            'milk_yield'  => 'required|numeric|min:0',    // L/day
            'activity'    => 'required|string|max:255',   // e.g. "Low", "Medium", "High"
            'age'         => 'nullable|numeric|min:0',    // months; optional if birthdate present
            'date'        => 'nullable|date',
        ]);

        // 1) Determine age in months
        $ageMonths = $data['age'] ?? null;

        if ($ageMonths === null && $cow->birthdate) {
            $birthdate = Carbon::parse($cow->birthdate);
            $ageMonths = $birthdate->diffInMonths(Carbon::today());
        }

        if ($ageMonths === null) {
            return response()->json([
                'message' => 'Age is required (no birthdate on cow and no age provided).',
            ], 422);
        }

        // For Python: breed must match allowed classes, formatted properly
        $breed = $cow->breed ?? '';
        if ($breed === '') {
            return response()->json([
                'message' => 'Cow breed is required in the database for image-based prediction.',
            ], 422);
        }

        $uploadedFile = $request->file('image');

        // 2) Call Python /predict with multipart/form-data
        try {
            $pythonResponse = Http::asMultipart()
                ->attach(
                    'image',
                    file_get_contents($uploadedFile->getRealPath()),
                    $uploadedFile->getClientOriginalName()
                )
                ->post('http://127.0.0.1:5000/predict', [
                    // form fields (not files) go here
                    'breed'      => $breed,
                    'age'        => $ageMonths,               // months
                    'milk_yield' => $data['milk_yield'],
                    'activity'   => $data['activity'],
                ]);

            if (! $pythonResponse->successful()) {
                return response()->json([
                    'message' => 'Failed to get daily feed from Python image service.',
                    'error'   => $pythonResponse->body(),
                ], 502);
            }

            $json = $pythonResponse->json();

            // Expecting: {"mode":"image","cow_weight_kg":..,"daily_feed_kg":..}
            $cowWeightKg  = $json['cow_weight_kg'] ?? null;
            $dailyFeedKg  = $json['daily_feed_kg'] ?? null;

            if ($cowWeightKg === null || $dailyFeedKg === null) {
                return response()->json([
                    'message'  => 'Python image service did not return expected fields.',
                    'response' => $json,
                ], 502);
            }
        } catch (\Throwable $e) {
            Log::error('Error calling Python image feed prediction service', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Error calling image-based feed prediction service.',
                'error'   => $e->getMessage(),
            ], 502);
        }

        // 3) Save to cow_feeds table
        $feedDate = $data['date'] ?? Carbon::today()->toDateString();
    
        $cowFeed = CowFeed::create([
            'user_id'       => $request->user()->id,
            'cow_id'        => $cow->id,
            'cow_weight_kg' => $cowWeightKg,
            'milk_yield_l'  => $data['milk_yield'],
            'activity'      => $data['activity'],
            'daily_feed_kg' => $dailyFeedKg,
            'date'          => $feedDate,
        ]);

        return response()->json([
            'message'    => 'Daily feed (image-based) calculated and saved successfully.',
            'cow_feed'   => $cowFeed,
        ], 201);
    }
    public function store(Request $request, Cow $cow)
    {
        $data = $request->validate([
            'weight'      => 'required|numeric|min:0',  // kg
            'milk_yield'  => 'required|numeric|min:0',  // L/day
            'activity'    => 'required|string|max:255', // e.g., "Low", "Medium", "High"
            'age'         => 'nullable|numeric|min:0',  // months; optional if we can derive from birthdate
            'date'        => 'nullable|date',          // default today
        ]);

        // 1) Determine age in months
        $ageMonths = $data['age'] ?? null;

        if ($ageMonths === null && $cow->birthdate) {
            // derive from birthdate
            $birthdate   = Carbon::parse($cow->birthdate);
            $ageMonths   = $birthdate->diffInMonths(Carbon::today());
        }

        if ($ageMonths === null) {
            return response()->json([
                'message' => 'Age is required (no birthdate on cow and no age provided).',
            ], 422);
        }

        // 2) Prepare request body for Python API
        $payload = [
            'breed'      => $cow->breed ?? '',       // make sure this matches allowed classes
            'age'        => $ageMonths,
            'weight'     => $data['weight'],
            'milk_yield' => $data['milk_yield'],
            'activity'   => $data['activity'],
        ];

        try {
            $pythonResponse = Http::post('http://127.0.0.1:5000/predict_manual', $payload);

            if (! $pythonResponse->successful()) {
                return response()->json([
                    'message' => 'Failed to get daily feed from Python service.',
                    'error'   => $pythonResponse->body(),
                ], 502);
            }

            $json = $pythonResponse->json();

            // Expecting: {"mode":"manual","cow_weight_kg":..,"daily_feed_kg":..}
            $dailyFeedKg = $json['daily_feed_kg'] ?? null;

            if ($dailyFeedKg === null) {
                return response()->json([
                    'message' => 'Python service did not return daily_feed_kg.',
                    'response'=> $json,
                ], 502);
            }
        } catch (\Throwable $e) {
            Log::error('Error calling Python feed prediction service', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Error calling feed prediction service.',
                'error'   => $e->getMessage(),
            ], 502);
        }

        // 3) Save to cow_feeds table
        $feedDate = $data['date'] ?? Carbon::today()->toDateString();

        $cowFeed = CowFeed::create([
            'user_id'       => $request->user()->id,
            'cow_id'        => $cow->id,
            'cow_weight_kg' => $data['weight'],
            'milk_yield_l'  => $data['milk_yield'],
            'activity'      => $data['activity'],
            'daily_feed_kg' => $dailyFeedKg,
            'date'          => $feedDate,
        ]);

        return response()->json([
            'message'    => 'Daily feed calculated and saved successfully.',
            'cow_feed'   => $cowFeed,
        ], 201);
    }

    
    /**
     * GET /api/cows/{cow}/feed
     * List feed records for a cow
     */
    public function index(Request $request, Cow $cow)
    {
        abort_if($cow->user_id !== $request->user()->id, 403, 'Forbidden');
        $feeds = $cow->feeds()->orderByDesc('date')->get();

        return response()->json($feeds);
    }
}