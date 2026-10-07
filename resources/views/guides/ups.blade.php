<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SOP & Manual Pengoperasian UPS 10kVA — Lab TI Unimal</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #006830;
            --unimal-green-light: #e6f7ee;
            --unimal-gold: #E2A313;
            --unimal-gold-light: #fef7e6;
            --danger-bg: #fef2f2;
            --danger-border: #fca5a5;
            --danger-text: #b91c1c;
            --warning-bg: #fffbeb;
            --warning-border: #fde68a;
            --warning-text: #b45309;
            --info-bg: #f0fdf4;
            --info-border: #bbf7d0;
            --info-text: #166534;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-500: #64748b;
            --gray-700: #334155;
            --gray-800: #1e293b;
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
            color: var(--gray-800);
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
            position: sticky;
            top: 0;
            z-index: 50;
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

        .top-actions {
            display: flex;
            gap: 10px;
        }

        .btn-print {
            background: var(--gray-100);
            color: var(--gray-700);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            border: 1px solid var(--gray-300);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-print:hover {
            background: var(--gray-200);
            color: var(--gray-900);
        }

        /* Layout Container */
        .sop-wrapper {
            max-width: 1080px;
            margin: 36px auto 60px;
            padding: 0 24px;
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 36px;
            align-items: start;
        }

        /* Sticky TOC */
        aside.sop-toc {
            position: sticky;
            top: 90px;
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--gray-200);
            padding: 20px;
        }

        .toc-title {
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--gray-500);
            margin-bottom: 12px;
        }

        .toc-list {
            list-style: none;
        }

        .toc-list li {
            margin-bottom: 8px;
        }

        .toc-list a {
            font-size: 13px;
            color: var(--gray-700);
            text-decoration: none;
            display: block;
            padding: 6px 10px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.15s;
        }

        .toc-list a:hover {
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
        }

        /* Main Article */
        article.sop-content {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 44px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03);
        }

        .sop-header {
            border-bottom: 2px solid var(--gray-100);
            padding-bottom: 24px;
            margin-bottom: 32px;
        }

        .sop-meta-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border-radius: 20px;
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 14px;
        }

        .sop-title {
            font-size: 28px;
            font-weight: 900;
            color: var(--gray-900);
            letter-spacing: -0.5px;
            line-height: 1.25;
            margin-bottom: 10px;
        }

        .sop-subtitle {
            font-size: 14.5px;
            color: var(--gray-500);
        }

        /* Callout Box Danger */
        .callout-danger {
            background-color: var(--danger-bg);
            border: 1px solid var(--danger-border);
            border-left: 5px solid var(--danger-text);
            border-radius: 12px;
            padding: 20px;
            margin: 28px 0;
            display: flex;
            gap: 16px;
        }

        .callout-icon {
            flex-shrink: 0;
            color: var(--danger-text);
            width: 28px;
            height: 28px;
        }

        .callout-title {
            font-size: 15px;
            font-weight: 800;
            color: var(--danger-text);
            margin-bottom: 6px;
        }

        .callout-text {
            font-size: 13.5px;
            color: #7f1d1d;
            line-height: 1.5;
        }

        /* Callout Info / Warning */
        .callout-warning {
            background-color: var(--warning-bg);
            border: 1px solid var(--warning-border);
            border-left: 5px solid var(--warning-text);
            border-radius: 12px;
            padding: 18px;
            margin: 24px 0;
            font-size: 13.5px;
            color: #78350f;
        }

        /* Section Styling */
        section.sop-section {
            margin-bottom: 40px;
            scroll-margin-top: 100px;
        }

        .section-heading {
            font-size: 20px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            letter-spacing: -0.3px;
        }

        .section-num {
            width: 32px;
            height: 32px;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 800;
        }

        /* Step-by-Step Flow */
        .steps-container {
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-top: 16px;
        }

        .step-box {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 14px;
            padding: 18px 22px;
            display: flex;
            gap: 18px;
            align-items: flex-start;
        }

        .step-badge {
            background: var(--gray-900);
            color: #ffffff;
            font-size: 12px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 8px;
            white-space: nowrap;
            margin-top: 2px;
        }

        .step-body h4 {
            font-size: 15px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 4px;
        }

        .step-body p {
            font-size: 13.5px;
            color: var(--gray-600);
            line-height: 1.5;
        }

        .param-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-top: 16px;
        }

        .param-card {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 14px;
            padding: 18px;
        }

        .param-card h4 {
            font-size: 14px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .param-card p {
            font-size: 13px;
            color: var(--gray-600);
        }

        /* Checklist Maintenance */
        .maintenance-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 14px;
        }

        .maintenance-item {
            background: #ffffff;
            border: 1px solid var(--gray-200);
            border-radius: 12px;
            padding: 16px 20px;
            display: flex;
            gap: 14px;
        }

        .m-tag {
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            align-self: flex-start;
        }

        .m-weekly { background: #dcfce7; color: #166534; }
        .m-monthly { background: #fef3c7; color: #92400e; }
        .m-yearly { background: #fee2e2; color: #991b1b; }

        @media print {
            aside.sop-toc, header.sop-topbar { display: none !important; }
            .sop-wrapper { grid-template-columns: 1fr; margin: 0; padding: 0; }
            article.sop-content { border: none; box-shadow: none; padding: 0; }
        }

        @media (max-width: 860px) {
            .sop-wrapper {
                grid-template-columns: 1fr;
            }
            aside.sop-toc {
                display: none;
            }
            article.sop-content {
                padding: 24px 20px;
            }
        }
    </style>
</head>
<body>

    <header class="sop-topbar">
        <a href="{{ route('panduan.index') }}" class="back-nav">
            <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Daftar Panduan</span>
        </a>
        <div class="top-actions">
            <button onclick="window.print()" class="btn-print">
                <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
                <span>Cetak / Simpan PDF</span>
            </button>
        </div>
    </header>

    <div class="sop-wrapper">
        <!-- Table of Contents -->
        <aside class="sop-toc">
            <div class="toc-title">Daftar Isi SOP</div>
            <ul class="toc-list">
                <li><a href="#k3-peringatan">⚠️ Peringatan K3 Listrik</a></li>
                <li><a href="#persyaratan-lingkungan">1. Persyaratan Lingkungan</a></li>
                <li><a href="#prosedur-menyalakan">2. Prosedur Start-Up (ON)</a></li>
                <li><a href="#prosedur-mematikan">3. Prosedur Shut-Down (OFF)</a></li>
                <li><a href="#penggunaan-harian">4. Panduan Beban Harian</a></li>
                <li><a href="#pemeliharaan">5. Pemeliharaan & Servis</a></li>
            </ul>
        </aside>

        <!-- Article -->
        <article class="sop-content">
            <div class="sop-header">
                <div class="sop-meta-tag">SOP Kelistrikan Laboratorium • Rev. 2026</div>
                <h1 class="sop-title">Manual & SOP Pengoperasian UPS 10kVA (Online System)</h1>
                <p class="sop-subtitle">Pedoman resmi tata cara pengoperasian, perlindungan modul inverter, dan keselamatan kerja di Laboratorium Teknik Informatika Universitas Malikussaleh.</p>
            </div>

            <!-- Danger Alert -->
            <div id="k3-peringatan" class="callout-danger">
                <div class="callout-icon">
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                </div>
                <div>
                    <div class="callout-title">Peringatan Keselamatan Kelistrikan (K3)</div>
                    <div class="callout-text">
                        UPS berkapasitas <strong>10kVA (Sistem Online)</strong> menyimpan tegangan tinggi yang mematikan bahkan ketika listrik utama (PLN) padam. <strong>Jangan pernah menutupi ventilasi kipas</strong>, jauhkan unit dari cairan, dan <strong>dilarang keras membuka casing unit</strong> kecuali oleh teknisi bersertifikat kelistrikan.
                    </div>
                </div>
            </div>

            <!-- Bagian 1 -->
            <section id="persyaratan-lingkungan" class="sop-section">
                <h2 class="section-heading">
                    <span class="section-num">1</span>
                    <span>Persyaratan Lingkungan (Sebelum Pengoperasian)</span>
                </h2>
                <p style="font-size: 14px; color: var(--gray-600); margin-bottom: 12px;">
                    Untuk mendukung puluhan PC menyala secara stabil, lingkungan ruang lab harus memenuhi standar operasional berikut:
                </p>

                <div class="param-grid">
                    <div class="param-card">
                        <h4>❄️ Suhu & Kelembapan</h4>
                        <p>Pastikan AC ruangan selalu aktif. Suhu ideal keawetan baterai adalah <strong>20°C - 25°C</strong>. Suhu di atas 30°C akan memotong umur baterai hingga 50%.</p>
                    </div>
                    <div class="param-card">
                        <h4>💨 Sirkulasi Udara</h4>
                        <p>Berikan jarak minimal <strong>30 cm</strong> di bagian belakang dan samping UPS agar kipas pembuangan panas (exhaust) tidak terhalang.</p>
                    </div>
                    <div class="param-card">
                        <h4>🧹 Kebersihan Ruangan</h4>
                        <p>Ruang lab harus bebas dari debu berlebih yang berpotensi tersedot ke dalam modul pendingin dan jalur papan PCB UPS.</p>
                    </div>
                </div>
            </section>

            <!-- Bagian 2 -->
            <section id="prosedur-menyalakan" class="sop-section">
                <h2 class="section-heading">
                    <span class="section-num">2</span>
                    <span>Prosedur Menyalakan UPS (Start-Up)</span>
                </h2>
                <p style="font-size: 14px; color: var(--gray-600);">
                    Urutan ini sangat krusial untuk menghindari lonjakan arus (surge) yang dapat merusak modul inverter atau menjepretkan MCB panel utama ruang lab:
                </p>

                <div class="steps-container">
                    <div class="step-box">
                        <span class="step-badge">Langkah 1</span>
                        <div class="step-body">
                            <h4>Pastikan MCB Output UPS dalam Posisi OFF (Prasyarat)</h4>
                            <p>Pastikan aliran listrik dari UPS ke seluruh jalur distribusi stopkontak meja komputer lab dalam keadaan terputus sebelum unit dinyalakan.</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge">Langkah 2</span>
                        <div class="step-body">
                            <h4>Nyalakan MCB Input Listrik (Mains/Grid PLN)</h4>
                            <p>Naikkan tuas MCB Input listrik dari panel utama ke UPS. Kipas UPS akan mulai berputar dan layar LCD panel depan akan menyala dalam mode <strong>Bypass</strong> (listrik PLN langsung diteruskan tanpa inverter).</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge">Langkah 3</span>
                        <div class="step-body">
                            <h4>Nyalakan Inverter UPS (Tahan Tombol ON 3-5 Detik)</h4>
                            <p>Tekan dan tahan tombol <strong>ON</strong> (atau kombinasi tombol panel depan) selama 3 hingga 5 detik sampai terdengar bunyi beep. Status di layar LCD akan berubah dari <em>Bypass</em> menjadi <strong>Line Mode</strong> atau <strong>Inverter Mode</strong>.</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge">Langkah 4</span>
                        <div class="step-body">
                            <h4>Nyalakan MCB Output (Distribusi Beban ke Seluruh PC)</h4>
                            <p>Setelah UPS beroperasi stabil di <em>Inverter Mode</em>, naikkan tuas MCB Output. Listrik kini telah tersalurkan dengan aman ke seluruh PC di laboratorium.</p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Bagian 3 -->
            <section id="prosedur-mematikan" class="sop-section">
                <h2 class="section-heading">
                    <span class="section-num">3</span>
                    <span>Prosedur Mematikan UPS (Shut-Down)</span>
                </h2>
                <p style="font-size: 14px; color: var(--gray-600);">
                    Jika lab libur panjang atau ada jadwal pemeliharaan instalasi gedung, matikan UPS dengan urutan kebalikan yang benar:
                </p>

                <div class="steps-container">
                    <div class="step-box">
                        <span class="step-badge" style="background: #ef4444;">Tahap 1</span>
                        <div class="step-body">
                            <h4>Matikan Seluruh PC dan Beban Lab Terlebih Dahulu</h4>
                            <p>Pastikan semua unit PC, layar monitor, proyektor, dan switch jaringan di lab komputer sudah di-shut down secara normal.</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge" style="background: #ef4444;">Tahap 2</span>
                        <div class="step-body">
                            <h4>Turunkan MCB Output UPS (Memutus Arus Beban)</h4>
                            <p>Posisikan MCB Output pada panel UPS ke arah <strong>OFF</strong> untuk memastikan tidak ada arus yang keluar ke meja lab.</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge" style="background: #ef4444;">Tahap 3</span>
                        <div class="step-body">
                            <h4>Matikan Inverter (Tahan Tombol OFF 3-5 Detik)</h4>
                            <p>Tekan dan tahan tombol <strong>OFF</strong> di panel depan selama 3-5 detik hingga terdengar bunyi beep. UPS akan kembali ke mode Bypass.</p>
                        </div>
                    </div>

                    <div class="step-box">
                        <span class="step-badge" style="background: #ef4444;">Tahap 4</span>
                        <div class="step-body">
                            <h4>Turunkan MCB Input Listrik (Memutus Suplai PLN)</h4>
                            <p>Posisikan MCB Input ke arah <strong>OFF</strong>. Layar panel LCD dan kipas pendingin UPS akan mati sepenuhnya setelah beberapa detik.</p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Bagian 4 -->
            <section id="penggunaan-harian" class="sop-section">
                <h2 class="section-heading">
                    <span class="section-num">4</span>
                    <span>Panduan Beban Harian & Ketentuan Alat</span>
                </h2>

                <div class="param-grid">
                    <div class="param-card" style="border-left: 4px solid var(--unimal-green);">
                        <h4>⚡ Manajemen Beban (Load)</h4>
                        <p>Kapasitas maksimal aman UPS 10kVA adalah sekitar <strong>8.000 Watt</strong> (asumsi Power Factor 0.8). Untuk konfigurasi ~40 unit PC, perhatikan persentase Load di LCD. <strong>Usahakan beban total tidak melebihi 80%</strong> agar tersedia cadangan lonjakan arus.</p>
                    </div>

                    <div class="param-card" style="border-left: 4px solid #ef4444;">
                        <h4>🚫 Periferal Terlarang</h4>
                        <p><strong>JANGAN PERNAH</strong> menyambungkan printer laser, mesin fotokopi, dispenser air, atau vacuum cleaner ke stopkontak UPS. Tarikan daya awalnya yang sangat tinggi akan langsung memicu <strong>Overload Fault</strong>.</p>
                    </div>

                    <div class="param-card" style="border-left: 4px solid var(--unimal-gold);">
                        <h4>🔔 Indikator Alarm & Pemadaman</h4>
                        <p>Jika listrik PLN padam, UPS akan berbunyi beep berkala (tiap 4 detik). Segera instruksikan pengguna lab untuk menyimpan file dan mematikan PC jika bar kapasitas baterai di LCD mulai menipis.</p>
                    </div>
                </div>
            </section>

            <!-- Bagian 5 -->
            <section id="pemeliharaan" class="sop-section">
                <h2 class="section-heading">
                    <span class="section-num">5</span>
                    <span>Pemeliharaan dan Perawatan (Maintenance)</span>
                </h2>

                <div class="maintenance-list">
                    <div class="maintenance-item">
                        <span class="m-tag m-weekly">Mingguan</span>
                        <div>
                            <strong style="font-size: 14px; color: var(--gray-900);">Pengecekan Status & Suara Kipas</strong>
                            <p style="font-size: 13px; color: var(--gray-600); margin-top: 4px;">Periksa layar indikator untuk memastikan status Normal / Line Mode. Dengarkan suara kipas—jika berisik abnormal, kipas kemungkinan tertutup debu tebal atau bearing aus.</p>
                        </div>
                    </div>

                    <div class="maintenance-item">
                        <span class="m-tag m-monthly">Bulanan</span>
                        <div>
                            <strong style="font-size: 14px; color: var(--gray-900);">Self-Test Baterai Terencana</strong>
                            <p style="font-size: 13px; color: var(--gray-600); margin-top: 4px;">Saat lab tidak dipakai, lakukan simulasi pemadaman dengan mematikan MCB Input selama 2-3 menit. Amati apakah UPS mengambil alih beban tanpa PC restart dan perhatikan kecepatan drop persentase baterai.</p>
                        </div>
                    </div>

                    <div class="maintenance-item">
                        <span class="m-tag m-yearly">Tahunan</span>
                        <div>
                            <strong style="font-size: 14px; color: var(--gray-900);">Pembersihan Internal & Anggaran Baterai VRLA</strong>
                            <p style="font-size: 13px; color: var(--gray-600); margin-top: 4px;">Pembersihan debu internal oleh teknisi bersertifikat. Masa pakai baterai VRLA/SLA umumnya 2–3 tahun (biasanya 16–20 unit 12V seri). Rencanakan pergantian sebelum sel baterai menggelembung atau bocor.</p>
                        </div>
                    </div>
                </div>
            </section>
        </article>
    </div>

</body>
</html>
