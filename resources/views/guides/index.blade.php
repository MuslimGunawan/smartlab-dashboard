<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pusat Panduan & SOP — Lab TI Unimal</title>
    
    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ asset('favicon.png') }}">
    <link rel="apple-touch-icon" href="{{ asset('apple-touch-icon.png') }}">
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #006830;
            --unimal-green-light: #e6f7ee;
            --unimal-gold: #E2A313;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-500: #64748b;
            --gray-700: #334155;
            --gray-900: #0f172a;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
        }

        body {
            background-color: var(--gray-50);
            color: var(--gray-900);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        header.sub-header {
            background: #ffffff;
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--gray-700);
            font-size: 13.5px;
            font-weight: 700;
        }

        .back-link:hover {
            color: var(--unimal-green);
        }

        .container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 24px;
            width: 100%;
        }

        .page-intro {
            margin-bottom: 32px;
        }

        .page-intro h2 {
            font-size: 30px;
            font-weight: 800;
            color: var(--gray-900);
            letter-spacing: -0.5px;
        }

        .page-intro p {
            font-size: 15px;
            color: var(--gray-500);
            margin-top: 6px;
        }

        .guide-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .guide-item-card {
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid var(--gray-200);
            padding: 26px;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s ease;
        }

        .guide-item-card:hover {
            transform: translateY(-3px);
            border-color: var(--unimal-green);
            box-shadow: 0 12px 24px -6px rgba(0, 147, 68, 0.12);
        }

        .guide-badge {
            display: inline-block;
            align-self: flex-start;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 14px;
        }

        .badge-k3 {
            background: #fee2e2;
            color: #dc2626;
        }

        .badge-umum {
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
        }

        .guide-item-card h3 {
            font-size: 18px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 8px;
        }

        .guide-item-card p {
            font-size: 13.5px;
            color: var(--gray-500);
            line-height: 1.5;
            margin-bottom: 20px;
        }

        .read-more {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 700;
            color: var(--unimal-green);
        }
    </style>
</head>
<body>

    <header class="sub-header">
        <a href="{{ route('portal') }}" class="back-link">
            <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Kembali ke Beranda Portal</span>
        </a>
        <div style="font-size: 13px; font-weight: 700; color: var(--gray-500);">SmartLab Unimal Documentation</div>
    </header>

    <div class="container">
        <div class="page-intro">
            <h2>Katalog Panduan & SOP Laboratorium</h2>
            <p>Petunjuk operasional resmi untuk mahasiswa praktikan, asisten laboratorium, dan teknisi.</p>
        </div>

        <div class="guide-grid">
            <a href="{{ route('panduan.ups') }}" class="guide-item-card">
                <div>
                    <span class="guide-badge badge-k3">Kritikal K3 Kelistrikan</span>
                    <h3>Manual & SOP Pengoperasian UPS 10kVA</h3>
                    <p>Urutan start-up, shut-down, pembebanan harian (maks 80%), serta pantangan alat berat untuk mencegah tripping dan kerusakan modul inverter.</p>
                </div>
                <div class="read-more">
                    <span>Baca Panduan Lengkap</span>
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </div>
            </a>

            <a href="{{ route('panduan.komputer') }}" class="guide-item-card">
                <div>
                    <span class="guide-badge badge-umum">Operasional Lab</span>
                    <h3>Tata Tertib Penggunaan Komputer Lab</h3>
                    <p>Etika pemakaian PC, penyimpanan direktori praktikum, aturan logout, dan larangan menjalankan game ataupun program tidak resmi.</p>
                </div>
                <div class="read-more">
                    <span>Baca Panduan Lengkap</span>
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </div>
            </a>

            <a href="{{ route('panduan.lapor-kendala') }}" class="guide-item-card">
                <div>
                    <span class="guide-badge badge-umum" style="background:#e0f2fe; color:#0369a1;">Pelayanan & Kendala</span>
                    <h3>Panduan & Lapor Kendala Meja / PC</h3>
                    <p>Laporkan kerusakan keyboard, mouse, layar monitor, atau kendala software komputer lab agar segera diperbaiki oleh tim ASLAB.</p>
                </div>
                <div class="read-more">
                    <span>Baca Panduan SOP</span>
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </div>
            </a>

            <a href="{{ route('panduan.software') }}" class="guide-item-card">
                <div>
                    <span class="guide-badge badge-umum" style="background:#fef3c7; color:#92400e;">Software & Otomasi</span>
                    <h3>Standarisasi Software & Otomasi Lab</h3>
                    <p>Daftar aplikasi wajib praktikum (VS Code, Android Studio, Visual Studio, Flutter, Python, JDK, QGIS, Figma) dan script PowerShell otomatis.</p>
                </div>
                <div class="read-more">
                    <span>Lihat Panduan & Unduh Script</span>
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </div>
            </a>

            <a href="{{ route('panduan.kabel-lan') }}" class="guide-item-card" style="border-color: #009344; background: linear-gradient(180deg, #ffffff 0%, #f0fdf4 100%);">
                <div>
                    <span class="guide-badge badge-umum" style="background:#dcfce7; color:#15803d; border: 1px solid #bbf7d0;">3D Interaktif & Model</span>
                    <h3>Perakitan & Crimping Kabel LAN UTP</h3>
                    <p>Visualisasi 3D konektor RJ-45 & kabel Cat5e/Cat6 yang dapat diputar 360°, urutan warna standar T568A vs T568B, Straight-Through vs Crossover, serta simulator tester pinout.</p>
                </div>
                <div class="read-more">
                    <span>Eksplorasi Model 3D & Panduan</span>
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </div>
            </a>
        </div>
    </div>

</body>
</html>
