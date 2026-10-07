<?php

namespace App\Http\Controllers;

use Illuminate\View\View;

class GuideController extends Controller
{
    /**
     * Halaman Utama Indeks Panduan & SOP Lab (Publik)
     */
    public function index(): View
    {
        $guides = [
            [
                'title' => 'SOP & Manual Pengoperasian UPS 10kVA',
                'slug' => 'ups',
                'category' => 'Kelistrikan & Infrastruktur',
                'description' => 'Petunjuk keselamatan kelistrikan, tata cara start-up, shut-down, pembebanan harian, dan perawatan berkala sistem Online UPS 10kVA Laboratorium.',
                'badge' => 'Kritikal K3',
                'icon' => 'zap',
            ],
            [
                'title' => 'Tata Tertib Penggunaan Komputer Lab',
                'slug' => 'komputer',
                'category' => 'Operasional Lab',
                'description' => 'Pedoman penggunaan PC laboratorium bagi mahasiswa praktikan, tata cara login, larangan instalasi game, serta penanganan file tugas.',
                'badge' => 'Umum',
                'icon' => 'monitor',
            ],
            [
                'title' => 'Panduan Pelaporan Kendala Meja / PC',
                'slug' => 'lapor-kendala',
                'category' => 'Maintenance',
                'description' => 'Cara melaporkan kerusakan hardware atau software komputer lab via scan QR Meja agar segera ditangani tim ASLAB.',
                'badge' => 'Pelayanan',
                'icon' => 'alert-circle',
            ],
            [
                'title' => 'Standarisasi Software & Otomasi Lab',
                'slug' => 'software',
                'category' => 'Software & Otomasi',
                'description' => 'Daftar 14 software kurikulum praktikum (Delphi, Cisco, Visual Studio, Proteus, VS Code, Android Studio, Python, JDK, VirtualBox, NetBeans, QGIS, Arduino IDE, XAMPP, Laragon) & script otomasi USB.',
                'badge' => '14 Software Standar',
                'icon' => 'code',
            ],
            [
                'title' => 'Panduan Perakitan & Crimping Kabel LAN UTP (3D)',
                'slug' => 'kabel-lan',
                'category' => 'Jaringan & Hardware',
                'description' => 'Tutorial interaktif perakitan kabel LAN RJ-45, urutan standar warna T568A & T568B (Straight-Through vs Crossover), visualisasi 3D interaktif yang dapat diputar, serta tester pinout.',
                'badge' => '3D Interaktif',
                'icon' => 'network',
            ],
        ];

        return view('guides.index', compact('guides'));
    }

    /**
     * Modul Panduan Detail: Manual UPS 10kVA
     */
    public function ups(): View
    {
        return view('guides.ups');
    }

    /**
     * Panduan Komputer Lab (Umum)
     */
    public function komputer(): View
    {
        return view('guides.komputer');
    }

    /**
     * Panduan Pelaporan Kendala Meja / PC
     */
    public function laporKendala(): View
    {
        return view('guides.lapor-kendala');
    }

    /**
     * Panduan Standarisasi Software & Script Otomasi Instalasi
     */
    public function software(): View
    {
        return view('guides.software');
    }

    /**
     * Panduan Perakitan Kabel LAN UTP dengan Visualisasi 3D Interaktif
     */
    public function kabelLan(): View
    {
        return view('guides.kabel-lan');
    }

    /**
     * Unduh Script Otomasi PowerShell
     */
    public function downloadScript()
    {
        $path = public_path('scripts/install-lab-software.ps1');
        if (!file_exists($path)) {
            abort(404, 'Script instalasi tidak ditemukan.');
        }

        return response()->download($path, 'install-lab-software.ps1', [
            'Content-Type' => 'text/plain; charset=utf-8',
        ]);
    }

    /**
     * Unduh Runner Batch (.bat)
     */
    public function downloadBat()
    {
        $path = public_path('scripts/jalankan-instalasi.bat');
        if (!file_exists($path)) {
            abort(404, 'Runner batch tidak ditemukan.');
        }

        return response()->download($path, 'jalankan-instalasi.bat', [
            'Content-Type' => 'application/x-bat',
        ]);
    }
}
