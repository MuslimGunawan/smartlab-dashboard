<?php

namespace Database\Seeders;

use App\Models\Lab;
use App\Models\PairingCode;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Super Admin
        $superAdmin = User::updateOrCreate(
            ['email' => 'admin@unimal.ac.id'],
            [
                'name' => 'Kepala Lab TI Unimal',
                'password' => Hash::make('password123'),
                'role' => 'super_admin',
            ]
        );

        // 2. ASLAB
        $aslab = User::updateOrCreate(
            ['email' => 'aslab@unimal.ac.id'],
            [
                'name' => 'Asisten Lab TI',
                'password' => Hash::make('password123'),
                'role' => 'aslab',
            ]
        );

        // 3. Initial Labs
        $labRpl = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Rekayasa Perangkat Lunak (RPL)'],
            [
                'lokasi' => 'Gedung TI Lt. 2, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum pemrograman, rekayasa web, dan basis data.',
            ]
        );

        $labJarkom = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Jaringan & Sistem Komputer'],
            [
                'lokasi' => 'Gedung TI Lt. 3, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum jaringan komputer, sistem operasi, dan keamanan siber.',
            ]
        );

        // Pivot user_lab
        $aslab->labs()->syncWithoutDetaching([$labRpl->id, $labJarkom->id]);
        $superAdmin->labs()->syncWithoutDetaching([$labRpl->id, $labJarkom->id]);

        // 4. Initial Active Pairing Code
        PairingCode::create([
            'code' => 'UNM-' . strtoupper(Str::random(6)),
            'lab_id' => $labRpl->id,
            'is_used' => false,
            'expired_at' => now()->addDays(7),
        ]);
    }
}
