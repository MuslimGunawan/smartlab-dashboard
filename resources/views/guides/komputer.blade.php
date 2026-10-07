<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tata Tertib Penggunaan Komputer Lab — Lab TI Unimal</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #006830;
            --unimal-green-light: #e6f7ee;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
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

        .rules-list {
            margin-top: 24px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .rule-item {
            display: flex;
            gap: 14px;
            align-items: flex-start;
        }

        .rule-num {
            width: 28px;
            height: 28px;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 800;
            flex-shrink: 0;
            margin-top: 2px;
        }
    </style>
</head>
<body>

    <header class="sop-topbar">
        <a href="{{ route('panduan.index') }}" class="back-nav">
            <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Daftar Panduan</span>
        </a>
    </header>

    <div class="container">
        <div class="card">
            <h1>Tata Tertib Penggunaan Komputer Lab</h1>
            <p style="color: var(--gray-500); font-size: 14px;">Aturan baku pemakaian unit komputer di seluruh laboratorium Teknik Informatika Universitas Malikussaleh.</p>

            <div class="rules-list">
                <div class="rule-item">
                    <span class="rule-num">1</span>
                    <div>
                        <strong>Penggunaan Khusus Akademik & Praktikum</strong>
                        <p style="font-size: 13.5px; color: var(--gray-700); margin-top: 2px;">Komputer lab hanya digunakan untuk kegiatan perkuliahan, praktikum resmi, riset skripsi, dan kerja praktik yang disetujui lab.</p>
                    </div>
                </div>

                <div class="rule-item">
                    <span class="rule-num">2</span>
                    <div>
                        <strong>Larangan Game & Aplikasi Terlarang</strong>
                        <p style="font-size: 13.5px; color: var(--gray-700); margin-top: 2px;">Dilarang menginstal atau menjalankan game online/offline serta emulator Android. Sistem agent LabControl akan mematikan proses otomatis dan mencatat pelanggaran.</p>
                    </div>
                </div>

                <div class="rule-item">
                    <span class="rule-num">3</span>
                    <div>
                        <strong>Penyimpanan File dan Pembersihan Berkala</strong>
                        <p style="font-size: 13.5px; color: var(--gray-700); margin-top: 2px;">Simpan file tugas pada flashdisk atau cloud storage pribadi. File temporer di direktori Downloads dan Desktop akan dibersihkan secara otomatis oleh sistem.</p>
                    </div>
                </div>

                <div class="rule-item">
                    <span class="rule-num">4</span>
                    <div>
                        <strong>Pelaporan Kerusakan</strong>
                        <p style="font-size: 13.5px; color: var(--gray-700); margin-top: 2px;">Jika menemukan kendala mouse, keyboard, monitor, atau koneksi jaringan, segera laporkan dengan men-scan QR Code di meja komputer tersebut.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
