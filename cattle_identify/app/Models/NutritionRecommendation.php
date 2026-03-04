<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NutritionRecommendation extends Model
{
    protected $fillable = [
        'user_id',
        'cow_id',
        'input_data',
        'dry_matter_intake_kg',
        'calcium_g_per_day',
        'phosphorus_g_per_day',
    ];

    protected $casts = [
        'input_data' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function cow()
    {
        return $this->belongsTo(Cow::class);
    }
}
