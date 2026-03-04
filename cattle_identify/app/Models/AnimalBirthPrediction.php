<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnimalBirthPrediction extends Model
{
    protected $fillable = [
        'user_id',
        'cow_id',
        'features',
        'estimated_days_to_birth',
        'will_birth_in_2_days',
    ];

    protected $casts = [
        'features' => 'array',
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
