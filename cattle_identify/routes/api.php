<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CowController;
use App\Http\Controllers\Api\CowFeedController;
use App\Http\Controllers\Api\PredictionController;

// ─── Auth (public) ───
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ─── Cow CRUD ───
Route::get('/cows', [CowController::class, 'index']);
Route::post('/cows', [CowController::class, 'store']);
Route::get('/cows/public', [CowController::class, 'indexWithoutEmbedding']);
Route::post('/cows/identify', [CowController::class, 'identify']);
Route::get('/cows/{cow}/profile', [CowController::class, 'profile']);
Route::get('/cows/{cow}/nutrition/latest', [CowController::class, 'latestNutrition']);
Route::get('/cows/{cow}', [CowController::class, 'show']);
Route::put('/cows/{cow}', [CowController::class, 'update']);
Route::delete('/cows/{cow}', [CowController::class, 'destroy']);

// ─── Cow Feed ───
Route::get('/cows/{cow}/feed', [CowFeedController::class, 'index']);
Route::post('/cows/{cow}/feed', [CowFeedController::class, 'store']);
Route::post('/cows/{cow}/feed-from-image', [CowFeedController::class, 'storeFromImage']);

// ─── Prediction History (store & list) ───
Route::post('/predictions/animal-birth', [PredictionController::class, 'storeAnimalBirth']);
Route::get('/predictions/animal-birth', [PredictionController::class, 'indexAnimalBirth']);

Route::post('/predictions/disease', [PredictionController::class, 'storeDiseaseDetection']);
Route::get('/predictions/disease', [PredictionController::class, 'indexDiseaseDetection']);

Route::post('/predictions/behavior', [PredictionController::class, 'storeBehaviorDetection']);
Route::get('/predictions/behavior', [PredictionController::class, 'indexBehaviorDetection']);

Route::post('/predictions/egg-hatch', [PredictionController::class, 'storeEggHatch']);
Route::get('/predictions/egg-hatch', [PredictionController::class, 'indexEggHatch']);

Route::post('/predictions/milk-market', [PredictionController::class, 'storeMilkMarket']);
Route::get('/predictions/milk-market', [PredictionController::class, 'indexMilkMarket']);

Route::post('/predictions/nutrition', [PredictionController::class, 'storeNutrition']);
Route::get('/predictions/nutrition', [PredictionController::class, 'indexNutrition']);

Route::post('/predictions/cow-identification', [PredictionController::class, 'storeCowIdentification']);
Route::get('/predictions/cow-identification', [PredictionController::class, 'indexCowIdentification']);

// ─── Protected routes (require token) ───
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/me', function (Request $request) {
        return $request->user();
    });
});