<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MilkMarketPrediction extends Model
{
    protected $fillable = [
        'user_id',
        'current_price',
        'monthly_milk_litres',
        'fat_percentage',
        'snf_percentage',
        'disease_stage',
        'feed_quality',
        'lactation_month',
        'month',
        'predicted_price_change',
        'predicted_next_price',
        'predicted_next_income',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
