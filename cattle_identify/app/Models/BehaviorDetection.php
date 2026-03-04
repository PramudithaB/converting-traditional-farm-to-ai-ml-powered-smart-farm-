<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BehaviorDetection extends Model
{
    protected $fillable = [
        'user_id',
        'cow_id',
        'detection_type',
        'behavior',
        'confidence',
        'details',
    ];

    protected $casts = [
        'details' => 'array',
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
