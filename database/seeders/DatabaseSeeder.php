<?php

namespace Database\Seeders;

use App\Models\BlocklistApp;
use App\Models\KioskSetting;
use App\Models\Lab;
use App\Models\PairingCode;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with clean, official production data.
     */
    public function run(): void
    {
        // 1. Super Admin (Kepala Laboratorium)
        $superAdmin = User::updateOrCreate(
            ['email' => 'admin@unimal.ac.id'],
            [
                'name' => 'Kepala Lab TI Unimal',
                'password' => Hash::make('password123'),
                'role' => 'super_admin',
            ]
        );

        // 2. ASLAB Senior (Koordinator)
        $aslabSenior = User::updateOrCreate(
            ['email' => 'aslab@unimal.ac.id'],
            [
                'name' => 'Koordinator Asisten Lab',
                'password' => Hash::make('password123'),
                'role' => 'aslab_senior',
            ]
        );

        // 3. ASLAB Junior (Asisten Praktikum)
        $aslabJunior = User::updateOrCreate(
            ['email' => 'junior@unimal.ac.id'],
            [
                'name' => 'Asisten Praktikum (Junior)',
                'password' => Hash::make('password123'),
                'role' => 'aslab_junior',
            ]
        );

        // 4. Laboratorium Resmi Teknik Informatika Unimal
        $labRpl = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Rekayasa Perangkat Lunak (RPL)'],
            [
                'lokasi' => 'Gedung TI Lt. 2, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum pemrograman berorientasi objek, rekayasa web, dan basis data.',
            ]
        );

        $labJarkom = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Jaringan & Sistem Komputer'],
            [
                'lokasi' => 'Gedung TI Lt. 3, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum jaringan komputer, administrasi server, sistem operasi, dan keamanan siber.',
            ]
        );

        $labMultimedia = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Multimedia & Komputasi Visual'],
            [
                'lokasi' => 'Gedung TI Lt. 2, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum grafika komputer, animasi 3D, pengolahan citra digital, dan UI/UX design.',
            ]
        );

        $labAi = Lab::updateOrCreate(
            ['nama_lab' => 'Lab Kecerdasan Buatan & Data Science'],
            [
                'lokasi' => 'Gedung TI Lt. 3, Kampus Bukit Indah',
                'deskripsi' => 'Laboratorium untuk praktikum machine learning, data mining, pemrosesan bahasa alami, dan komputasi cerdas.',
            ]
        );

        // Tugaskan seluruh lab ke Super Admin & Koordinator
        $allLabIds = [$labRpl->id, $labJarkom->id, $labMultimedia->id, $labAi->id];
        $superAdmin->labs()->sync($allLabIds);
        $aslabSenior->labs()->sync($allLabIds);
        $aslabJunior->labs()->sync([$labRpl->id, $labJarkom->id]);

        // 5. Kode Pairing Aktif Awal per Lab
        foreach ([$labRpl, $labJarkom, $labMultimedia, $labAi] as $lab) {
            PairingCode::updateOrCreate(
                ['code' => 'UNM-' . strtoupper(substr(str_replace(' ', '', $lab->nama_lab), 3, 3)) . '01'],
                [
                    'lab_id' => $lab->id,
                    'is_used' => false,
                    'expired_at' => now()->addMonths(3),
                ]
            );
        }

        // 6. Blocklist Resmi Aplikasi & Game Terlarang (PRD Bab 17)
        $blocklist = [
            ['process_name' => 'valorant.exe', 'keterangan' => 'Game FPS Online (Riot Games)'],
            ['process_name' => 'genshinimpact.exe', 'keterangan' => 'Game RPG Online (HoYoverse)'],
            ['process_name' => 'steam.exe', 'keterangan' => 'Platform Distribusi Game Steam'],
            ['process_name' => 'dota2.exe', 'keterangan' => 'Game MOBA Online DOTA 2'],
            ['process_name' => 'robloxplayerbeta.exe', 'keterangan' => 'Platform Game Roblox'],
            ['process_name' => 'pointblank.exe', 'keterangan' => 'Game FPS Online Point Blank'],
            ['process_name' => 'dnplayer.exe', 'keterangan' => 'Emulator Android LDPlayer'],
            ['process_name' => 'nox.exe', 'keterangan' => 'Emulator Android NoxPlayer'],
            ['process_name' => 'cheatengine.exe', 'keterangan' => 'Software Hacking & Memory Editor'],
        ];

        foreach ($blocklist as $b) {
            BlocklistApp::updateOrCreate(
                ['process_name' => $b['process_name']],
                [
                    'keterangan' => $b['keterangan'],
                    'dibuat_oleh' => $superAdmin->id,
                    'aktif' => true,
                ]
            );
        }

        // 7. Pengaturan Sistem Awal
        Setting::set('lab_head_name', 'Dahlan Abdullah, S.T., M.Kom.', 'report');
        Setting::set('aslab_coordinator_name', 'Muslim Gunawan', 'report');
        Setting::set('notify_issues_enabled', '1', 'notification');
        Setting::set('notify_violations_enabled', '1', 'notification');
        Setting::set('notify_software_enabled', '1', 'notification');
    }
}
