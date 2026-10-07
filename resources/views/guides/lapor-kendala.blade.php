<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panduan Pelaporan Kendala Meja / PC — Lab TI Unimal</title>
    
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
            line-height: 1.6;
        }

        header.sop-topbar {
            background: #ffffff;
            border-bottom: 1px solid var(--gray-200);
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .back-nav {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--gray-700);
            font-size: 13.5px;
            font-weight: 700;
        }

        .back-nav:hover {
            color: var(--unimal-green);
        }

        .container {
            max-width: 860px;
            margin: 40px auto;
            padding: 0 24px;
            width: 100%;
        }

        .card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 40px;
        }

        h1 {
            font-size: 26px;
            font-weight: 800;
            margin-bottom: 12px;
        }

        .steps-list {
            margin-top: 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .step-item {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .step-num {
            width: 32px;
            height: 32px;
            background: #e0f2fe;
            color: #0369a1;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 14px;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .step-content h4 {
            font-size: 16px;
            font-weight: 700;
            color: var(--gray-900);
            margin-bottom: 4px;
        }

        .step-content p {
            font-size: 14px;
            color: var(--gray-700);
            line-height: 1.5;
        }

        .notice-box {
            background: var(--unimal-green-light);
            border: 1px solid rgba(0, 147, 68, 0.2);
            border-radius: 14px;
            padding: 20px;
            margin-top: 32px;
        }

        .notice-box h4 {
            font-size: 15px;
            font-weight: 800;
            color: var(--unimal-green-dark);
            margin-bottom: 6px;
        }

        .notice-box p {
            font-size: 13.5px;
            color: var(--unimal-green-dark);
            line-height: 1.5;
        }
    </style>
</head>
<body>

    <header class="sop-topbar">
        <a href="{{ route('panduan.index') }}" class="back-nav">
            <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Katalog Panduan</span>
        </a>
        <div style="font-size: 13px; font-weight: 700; color: var(--gray-500);">SOP Pelayanan Lab TI</div>
    </header>

    <div class="container">
        <div class="card">
            <span style="display:inline-block; padding:4px 10px; border-radius:20px; font-size:11px; font-weight:800; text-transform:uppercase; background:#e0f2fe; color:#0369a1; margin-bottom:12px;">
                Pelayanan & Maintenance
            </span>
            <h1>Panduan Pelaporan Kendala Meja / PC Laboratorium</h1>
            <p style="color: var(--gray-500); font-size: 14.5px;">SOP pelaporan mandiri bagi praktikan apabila menemukan kerusakan perangkat periferal, kelistrikan, jaringan, atau sistem operasi pada komputer laboratorium.</p>

            <div class="steps-list">
                <div class="step-item">
                    <div class="step-num">1</div>
                    <div class="step-content">
                        <h4>Pindai (Scan) QR Code di Meja Komputer</h4>
                        <p>Setiap meja lab telah dilengkapi stiker QR Code unik. Gunakan kamera smartphone Anda untuk memindai kode tersebut. Sistem akan otomatis membuka form pelaporan kendala khusus untuk nomor meja Anda tanpa perlu login.</p>
                    </div>
                </div>

                <div class="step-item">
                    <div class="step-num">2</div>
                    <div class="step-content">
                        <h4>Pilih Kategori Perangkat yang Bermasalah</h4>
                        <p>Pilih kategori kendala yang Anda alami, seperti: <strong>Keyboard</strong> (tombol macet/tidak terdeteksi), <strong>Mouse</strong> (kursor melompat/klik tidak merespon), <strong>Layar Monitor</strong> (mati/flickering), <strong>Jaringan LAN</strong> (tidak dapat IP/kabel lepas), atau <strong>Software/Sistem Operasi</strong>.</p>
                    </div>
                </div>

                <div class="step-item">
                    <div class="step-num">3</div>
                    <div class="step-content">
                        <h4>Tuliskan Gejala Kendala Secara Singkat & Jelas</h4>
                        <p>Uraikan apa yang terjadi, misalnya: <em>"Tombol spasi keyboard patah"</em> atau <em>"PC tiba-tiba restart sendiri saat menjalankan IDE"</em>, lalu klik tombol kirim.</p>
                    </div>
                </div>

                <div class="step-item">
                    <div class="step-num">4</div>
                    <div class="step-content">
                        <h4>Penanganan Langsung oleh Tim Asisten Lab</h4>
                        <p>Laporan Anda otomatis tercatat di dashboard monitoring Control Panel ASLAB secara real-time. Asisten lab piket akan segera memeriksa dan mengganti perangkat cadangan dari lemari logistik.</p>
                    </div>
                </div>
            </div>

            <div class="notice-box">
                <h4>Etika & Larangan Penting</h4>
                <p>Dilarang keras menukar sendiri periferal (keyboard, mouse, kabel power) ke meja mahasiswa lain tanpa izin asisten lab, karena akan merusak akurasi inventaris hardware lab.</p>
            </div>
        </div>
    </div>

</body>
</html>
