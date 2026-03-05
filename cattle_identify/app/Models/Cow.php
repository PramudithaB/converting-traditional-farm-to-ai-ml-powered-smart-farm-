<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cow extends Model
{
    protected $fillable = [
        'user_id',
        'cow_id',
        'name',
        'breed',
        'lactation_month',
        'weight',
        'previous_disease',
        'image_path',
        'birthdate',
        'embedding',
    ];

    protected $hidden = [
        'embedding',
    ];

    protected $casts = [
        'previous_disease' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function feeds()
    {
        return $this->hasMany(CowFeed::class);
    }

    public function identifications()
    {
        return $this->hasMany(CowIdentification::class, 'matched_cow_id');
    }

    public function diseaseDetections()
    {
        return $this->hasMany(DiseaseDetection::class);
    }

    public function birthPredictions()
    {
        return $this->hasMany(AnimalBirthPrediction::class);
    }

    public function behaviorDetections()
    {
        return $this->hasMany(BehaviorDetection::class);
    }

    public function nutritionRecommendations()
    {
        return $this->hasMany(NutritionRecommendation::class);
    }
}