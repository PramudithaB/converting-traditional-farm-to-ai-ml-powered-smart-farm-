<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name'              => 'Deshan Farmer',
            'email'             => 'deshan@smartfarm.com',
            'password'          => Hash::make('password123'),
            'email_verified_at' => now(),
        ]);

        User::create([
            'name'              => 'Nimal Perera',
            'email'             => 'nimal@smartfarm.com',
            'password'          => Hash::make('password123'),
            'email_verified_at' => now(),
        ]);

        User::create([
            'name'              => 'Sunil Jayawardena',
            'email'             => 'sunil@smartfarm.com',
            'password'          => Hash::make('password123'),
            'email_verified_at' => now(),
        ]);
    }
}
