<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DiseaseDetection extends Model
{
    protected $fillable = [
        'user_id',
        'cow_id',
        'image_path',
        'model_used',
        'disease_name',
        'confidence',
        'all_predictions',
        'severity',
        'treatment',
    ];

    protected $casts = [
        'all_predictions' => 'array',
        'severity' => 'array',
        'treatment' => 'array',
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
