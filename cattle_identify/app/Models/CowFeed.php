<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CowFeed extends Model
{
    protected $fillable = [
        'cow_id',
        'cow_weight_kg',
        'milk_yield_l',
        'activity',
        'daily_feed_kg',
        'date',
    ];

    public function cow()
    {
        return $this->belongsTo(Cow::class);
    }
}