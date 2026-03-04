<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CowIdentification extends Model
{
    protected $fillable = [
        'user_id',
        'image_path',
        'matched_cow_id',
        'similarity_score',
        'match_found',
        'all_scores',
    ];

    protected $casts = [
        'match_found' => 'boolean',
        'all_scores' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function matchedCow()
    {
        return $this->belongsTo(Cow::class, 'matched_cow_id');
    }
}
