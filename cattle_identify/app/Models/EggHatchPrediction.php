<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EggHatchPrediction extends Model
{
    protected $fillable = [
        'user_id',
        'temperature',
        'humidity',
        'egg_weight',
        'egg_turning_frequency',
        'incubation_duration',
        'hatch_probability',
        'predicted_class',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
