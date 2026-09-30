<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Standarisasi Software & Klasifikasi Lisensi Lab TI — Universitas Malikussaleh</title>
    
    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ asset('favicon.png') }}">
    <link rel="apple-touch-icon" href="{{ asset('apple-touch-icon.png') }}">
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #006830;
            --unimal-green-light: #e6f7ee;
            --unimal-gold: #D97706;
            --unimal-gold-light: #fef3c7;
            --unimal-gold-border: #fde68a;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-400: #94a3b8;
            --gray-500: #64748b;
            --gray-600: #475569;
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

        header.topbar {
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

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--gray-700);
            font-size: 13.5px;
            font-weight: 700;
            transition: color 0.2s;
        }

        .back-link:hover {
            color: var(--unimal-green);
        }

        .container {
            max-width: 1060px;
            width: 100%;
            margin: 32px auto 60px auto;
            padding: 0 20px;
        }

        .hero-banner {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 32px;
            margin-bottom: 28px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
            position: relative;
            overflow: hidden;
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 240px;
            height: 100%;
            background: linear-gradient(135deg, transparent 40%, rgba(0, 147, 68, 0.05) 100%);
            pointer-events: none;
        }

        .pill-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 800;
            text-transform: uppercase;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            margin-bottom: 12px;
            border: 1px solid rgba(0, 147, 68, 0.2);
        }

        .hero-title {
            font-size: 26px;
            font-weight: 900;
            color: var(--gray-900);
            letter-spacing: -0.4px;
            line-height: 1.3;
            margin-bottom: 8px;
        }

        .hero-subtitle {
            font-size: 14.5px;
            color: var(--gray-600);
            max-width: 840px;
        }

        /* Summary Grid */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 28px;
        }

        .summary-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 18px 22px;
            border: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
        }

        .summary-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .summary-val {
            font-size: 22px;
            font-weight: 900;
            color: var(--gray-900);
            line-height: 1.2;
        }

        .summary-lbl {
            font-size: 12px;
            font-weight: 700;
            color: var(--gray-500);
        }

        /* Filter Tab Buttons */
        .tab-bar {
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 6px;
            margin-bottom: 24px;
        }

        .tab-btn {
            background: #ffffff;
            border: 1px solid var(--gray-200);
            color: var(--gray-700);
            font-size: 13px;
            font-weight: 700;
            padding: 8px 16px;
            border-radius: 10px;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .tab-btn:hover {
            border-color: var(--gray-400);
            color: var(--gray-900);
        }

        .tab-btn.active {
            background: var(--unimal-green);
            color: #ffffff;
            border-color: var(--unimal-green);
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.25);
        }

        .tab-count {
            background: rgba(0,0,0,0.08);
            font-size: 11px;
            padding: 2px 7px;
            border-radius: 12px;
        }

        .tab-btn.active .tab-count {
            background: rgba(255,255,255,0.25);
            color: #fff;
        }

        /* Section Headers */
        .license-section-header {
            margin: 32px 0 16px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--gray-200);
        }

        .section-badge-header {
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .section-badge-header h2 {
            font-size: 20px;
            font-weight: 900;
            color: var(--gray-900);
            letter-spacing: -0.3px;
        }

        .badge-type {
            font-size: 11px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        .badge-licensed {
            background: var(--unimal-gold-light);
            color: #b45309;
            border: 1px solid var(--unimal-gold-border);
        }

        .badge-foss {
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border: 1px solid rgba(0, 147, 68, 0.25);
        }

        .software-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }

        .soft-card {
            background: #ffffff;
            border: 1.5px solid var(--gray-200);
            border-radius: 18px;
            padding: 22px;
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
            display: flex;
            flex-direction: column;
        }

        .soft-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            border-color: var(--gray-300);
        }

        .soft-card.card-licensed {
            border-left: 4px solid var(--unimal-gold);
        }

        .soft-card.card-foss {
            border-left: 4px solid var(--unimal-green);
        }

        .soft-top {
            display: flex;
            align-items: flex-start;
            gap: 14px;
            margin-bottom: 12px;
        }

        .soft-icon {
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 900;
            flex-shrink: 0;
            letter-spacing: -0.5px;
        }

        .soft-meta {
            flex: 1;
        }

        .soft-meta h4 {
            font-size: 16px;
            font-weight: 800;
            color: var(--gray-900);
            line-height: 1.3;
        }

        .soft-meta .soft-vendor {
            font-size: 12px;
            color: var(--gray-500);
            font-weight: 600;
        }

        .soft-desc {
            font-size: 13px;
            color: var(--gray-600);
            line-height: 1.55;
            margin-bottom: 16px;
            flex: 1;
        }

        .license-spec-box {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 12px;
            margin-bottom: 12px;
        }

        .license-spec-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
        }

        .license-spec-row:last-child {
            margin-bottom: 0;
        }

        .license-spec-lbl {
            color: var(--gray-500);
            font-weight: 600;
        }

        .license-spec-val {
            font-weight: 700;
            color: var(--gray-800);
            text-align: right;
        }

        .soft-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            padding-top: 12px;
            border-top: 1px solid var(--gray-100);
        }

        .soft-tag {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            background: var(--gray-100);
            color: var(--gray-700);
        }

        .badge-status-pill {
            font-size: 11px;
            font-weight: 800;
            padding: 3px 8px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-status-licensed {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-status-foss {
            background: #dcfce7;
            color: #166534;
        }

        /* Installer Hub Top Section */
        .installer-hub {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 30px;
            margin-bottom: 32px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.04);
        }

        .installer-hub-header {
            margin-bottom: 24px;
            padding-bottom: 18px;
            border-bottom: 1px solid var(--gray-200);
        }

        .hub-pill {
            display: inline-block;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 800;
            text-transform: uppercase;
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
            margin-bottom: 10px;
        }

        .hub-title {
            font-size: 22px;
            font-weight: 900;
            color: var(--gray-900);
            letter-spacing: -0.3px;
            line-height: 1.3;
            margin-bottom: 6px;
        }

        .hub-subtitle {
            font-size: 13.5px;
            color: var(--gray-600);
            max-width: 860px;
            line-height: 1.5;
        }

        .hub-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 22px;
            margin-bottom: 24px;
        }

        @media (max-width: 900px) {
            .hub-grid {
                grid-template-columns: 1fr;
            }
        }

        .hub-card {
            border-radius: 16px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .hub-card-primary {
            background: #0f172a;
            color: #f8fafc;
            border: 1px solid #1e293b;
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.35);
        }

        .hub-card-secondary {
            background: #f8fafc;
            color: var(--gray-800);
            border: 1px solid var(--gray-200);
        }

        .hub-card-badge {
            display: inline-block;
            font-size: 11.5px;
            font-weight: 800;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .badge-rec {
            background: rgba(16, 185, 129, 0.2);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .badge-sec {
            background: #e0f2fe;
            color: #0284c7;
            border: 1px solid #bae6fd;
        }

        .hub-card-title {
            font-size: 17px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .hub-card-primary .hub-card-title {
            color: #ffffff;
        }

        .hub-card-secondary .hub-card-title {
            color: var(--gray-900);
        }

        .hub-card-desc {
            font-size: 12.5px;
            line-height: 1.5;
            margin-bottom: 14px;
        }

        .hub-card-primary .hub-card-desc {
            color: #94a3b8;
        }

        .hub-card-secondary .hub-card-desc {
            color: var(--gray-600);
        }

        .guide-steps {
            background: rgba(0, 0, 0, 0.02);
            border-radius: 12px;
            padding: 14px 16px;
        }

        .hub-card-primary .guide-steps {
            background: #1e293b;
            border: 1px solid #334155;
        }

        .hub-card-secondary .guide-steps {
            background: #ffffff;
            border: 1px solid var(--gray-200);
        }

        .guide-step-title {
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            margin-bottom: 10px;
        }

        .hub-card-primary .guide-step-title {
            color: #38bdf8;
        }

        .hub-card-secondary .guide-step-title {
            color: var(--unimal-green-dark);
        }

        .step-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .step-list li {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 12.5px;
            line-height: 1.45;
        }

        .hub-card-primary .step-list li {
            color: #cbd5e1;
        }

        .hub-card-secondary .step-list li {
            color: var(--gray-700);
        }

        .step-num {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 800;
            flex-shrink: 0;
            margin-top: 1px;
        }

        .hub-card-primary .step-num {
            background: var(--unimal-green);
            color: #ffffff;
        }

        .hub-card-secondary .step-num {
            background: #e2e8f0;
            color: var(--gray-800);
        }

        .download-action-grid {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .btn-hub-download {
            text-decoration: none;
            border-radius: 12px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.2s;
        }

        .btn-bat {
            background: #ffffff;
            border: 1.5px solid #009344;
            color: #006830;
        }

        .btn-bat:hover {
            background: #e6f7ee;
        }

        .btn-ps {
            background: #ffffff;
            border: 1.5px solid #2563eb;
            color: #1d4ed8;
        }

        .btn-ps:hover {
            background: #eff6ff;
        }

        .btn-title {
            font-size: 13px;
            font-weight: 800;
            line-height: 1.2;
        }

        .btn-sub {
            font-size: 11.5px;
            color: var(--gray-500);
            margin-top: 2px;
        }

        .tree-display {
            background: #f1f5f9;
            border-radius: 8px;
            padding: 10px 14px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            color: #0f172a;
            border: 1px solid #cbd5e1;
            line-height: 1.5;
            white-space: pre;
        }

        .arch-pillars-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 16px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid var(--gray-200);
        }

        .arch-pillar-card {
            border-radius: 14px;
            padding: 16px 18px;
        }

        .arch-pillar-card h4 {
            font-size: 13.5px;
            font-weight: 800;
            margin: 6px 0;
        }

        .arch-pillar-card p {
            font-size: 12px;
            line-height: 1.5;
            margin: 0;
        }

        .p-green {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
        }
        .p-green .arch-pillar-badge { color: #1d4ed8; font-size: 11px; font-weight: 800; text-transform: uppercase; }
        .p-green h4 { color: #1e3a8a; }
        .p-green p { color: #1e40af; }

        .p-emerald {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
        }
        .p-emerald .arch-pillar-badge { color: #15803d; font-size: 11px; font-weight: 800; text-transform: uppercase; }
        .p-emerald h4 { color: #14532d; }
        .p-emerald p { color: #166534; }

        .p-amber {
            background: #fffbeb;
            border: 1px solid #fde68a;
        }
        .p-amber .arch-pillar-badge { color: #b45309; font-size: 11px; font-weight: 800; text-transform: uppercase; }
        .p-amber h4 { color: #78350f; }
        .p-amber p { color: #92400e; }

        /* 1-Click Installer Box */
        .terminal-box {
            background: #0f172a;
            color: #f8fafc;
            border-radius: 20px;
            padding: 26px;
            margin: 36px 0;
            border: 1px solid #1e293b;
            box-shadow: 0 14px 30px -10px rgba(15, 23, 42, 0.4);
        }

        .terminal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
            padding-bottom: 12px;
            border-bottom: 1px solid #334155;
        }

        .terminal-dots {
            display: flex;
            gap: 6px;
        }

        .dot {
            width: 11px;
            height: 11px;
            border-radius: 50%;
        }
        .dot-red { background: #ef4444; }
        .dot-yellow { background: #f59e0b; }
        .dot-green { background: #10b981; }

        .terminal-title {
            font-size: 12px;
            font-weight: 700;
            color: #94a3b8;
            font-family: 'JetBrains Mono', monospace;
        }

        .cmd-display {
            background: #1e293b;
            padding: 14px 18px;
            border-radius: 12px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 13.5px;
            color: #38bdf8;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            word-break: break-all;
            border: 1px solid #334155;
        }

        .btn-copy {
            background: var(--unimal-green);
            color: #ffffff;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
            transition: background 0.2s;
        }

        .btn-copy:hover {
            background: var(--unimal-green-dark);
        }

        .terminal-desc {
            font-size: 12.5px;
            color: #94a3b8;
            margin-top: 14px;
            line-height: 1.6;
        }

        .download-actions {
            display: flex;
            gap: 12px;
            margin-top: 18px;
            flex-wrap: wrap;
        }

        .btn-download {
            background: #334155;
            color: #ffffff;
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 10px;
            font-size: 12.5px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.2s;
        }

        .btn-download:hover {
            background: #475569;
        }

        /* Matriks Table */
        .spec-table {
            width: 100%;
            border-collapse: collapse;
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--gray-200);
            margin-top: 14px;
        }

        .spec-table th {
            background: var(--gray-50);
            padding: 12px 18px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--gray-500);
            border-bottom: 1px solid var(--gray-200);
            text-align: left;
        }

        .spec-table td {
            padding: 13px 18px;
            font-size: 13px;
            border-bottom: 1px solid var(--gray-100);
            color: var(--gray-700);
        }

        .spec-table code {
            font-family: 'JetBrains Mono', monospace;
            background: var(--gray-100);
            padding: 3px 6px;
            border-radius: 4px;
            font-size: 12px;
            color: #b91c1c;
        }

        footer.guide-footer {
            margin-top: auto;
            border-top: 1px solid var(--gray-200);
            background: #ffffff;
            padding: 24px;
            text-align: center;
            font-size: 12.5px;
            color: var(--gray-500);
        }
    </style>
</head>
<body>

    <header class="topbar">
        <a href="{{ route('panduan.index') }}" class="back-link">
            <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Kembali ke Katalog Panduan</span>
        </a>
        <div style="font-size: 13px; font-weight: 700; color: var(--gray-500);">Laboratorium Komputer Teknik Informatika — Unimal</div>
    </header>

    <div class="container">
        
        <!-- Banner Intro -->
        <div class="hero-banner">
            <span class="pill-badge">Standard Operating Environment (SOE) & Lisensi Software</span>
            <h1 class="hero-title">Standarisasi Perangkat Lunak Praktikum Lab TI</h1>
            <p class="hero-subtitle">
                Daftar resmi perangkat lunak kurikulum praktikum Program Studi Teknik Informatika Universitas Malikussaleh yang dipasang di seluruh PC laboratorium, diklasifikasikan secara jelas antara <strong>Aplikasi Berlisensi</strong> dan <strong>Aplikasi Bebas Lisensi</strong>.
            </p>
        </div>

        <!-- Summary Bar -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-icon" style="background: #fef3c7; color: #b45309;">
                    <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                </div>
                <div>
                    <div class="summary-val">4 Software</div>
                    <div class="summary-lbl">Aplikasi Berlisensi / Edu</div>
                </div>
            </div>

            <div class="summary-card">
                <div class="summary-icon" style="background: #dcfce7; color: #15803d;">
                    <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>
                </div>
                <div>
                    <div class="summary-val">10 Software</div>
                    <div class="summary-lbl">Bebas Lisensi / Open Source</div>
                </div>
            </div>

            <div class="summary-card">
                <div class="summary-icon" style="background: #eff6ff; color: #2563eb;">
                    <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                </div>
                <div>
                    <div class="summary-val">14 Software</div>
                    <div class="summary-lbl">Total Standar Praktikum</div>
                </div>
            </div>
        </div>

        <!-- ============================================================== -->
        <!-- PUSAT OTOMASI & PANDUAN INSTALASI SOFTWARE LAB TI (UTAMA)      -->
        <!-- ============================================================== -->
        <div class="installer-hub" id="installerHub">
            <div class="installer-hub-header">
                <span class="hub-pill">⚡ Pusat Otomasi & Runner Standarisasi Lab TI</span>
                <h2 class="hub-title">Instalasi Otomatis Seluruh Perangkat Lunak Praktikum</h2>
                <p class="hub-subtitle">
                    Gunakan salah satu dari 2 metode resmi di bawah ini untuk memasang seluruh software praktikum Teknik Informatika Unimal secara cepat, cerdas (<em>smart-skip</em>), dan bebas bentrok port.
                </p>
            </div>

            <!-- Hub Grid: 2 Metode -->
            <div class="hub-grid">
                
                <!-- METODE 1: VIA COMMAND POWERSHELL -->
                <div class="hub-card hub-card-primary">
                    <div>
                        <div class="hub-card-header">
                            <div class="hub-card-badge badge-rec">⭐ Metode 1: Rekomendasi Aslab (Paling Cepat)</div>
                            <h3 class="hub-card-title">1-Baris Perintah PowerShell</h3>
                            <p class="hub-card-desc">
                                Tanpa perlu download file atau membuat folder manual. Cukup jalankan perintah ini, script otomatis membentuk folder <code>Lab_Software\Apps</code>, mengunduh berkas eksekutor terbaru, dan menjalankan instalasi.
                            </p>
                        </div>

                        <div class="terminal-box" style="margin: 14px 0 18px 0; padding: 18px;">
                            <div class="terminal-header">
                                <div class="terminal-dots">
                                    <div class="dot dot-red"></div>
                                    <div class="dot dot-yellow"></div>
                                    <div class="dot dot-green"></div>
                                </div>
                                <div class="terminal-title">Windows PowerShell</div>
                            </div>

                            <div class="cmd-display">
                                <span id="cmdText">irm https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/setup.ps1 | iex</span>
                                <button class="btn-copy" onclick="copyCommand()">
                                    <svg style="width:14px;height:14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"/></svg>
                                    <span id="copyLabel">Salin Perintah</span>
                                </button>
                            </div>
                        </div>

                        <div class="guide-steps">
                            <div class="guide-step-title">📖 Panduan Eksekusi Perintah:</div>
                            <ol class="step-list">
                                <li>
                                    <span class="step-num">1</span>
                                    <div class="step-content">
                                        <strong>Masuk ke Flashdisk Anda</strong> di File Explorer, tahan tombol <kbd style="background:#334155;color:#fff;padding:2px 6px;border-radius:4px;font-size:11px;">Shift</kbd> lalu <strong>klik kanan</strong> di area kosong, kemudian pilih <em>"Open PowerShell window here"</em> (atau <em>"Buka jendela PowerShell di sini"</em>).
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">2</span>
                                    <div class="step-content">
                                        <strong>Klik tombol Salin Perintah di atas</strong>, tempelkan (<em>paste</em>) ke jendela PowerShell tersebut, lalu tekan <kbd style="background:#334155;color:#fff;padding:2px 6px;border-radius:4px;font-size:11px;">Enter</kbd>.
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">3</span>
                                    <div class="step-content">
                                        Script otomatis membentuk folder <code>Lab_Software\Apps</code> langsung di flashdisk Anda dan mengunduh berkas launcher resmi terbaru.
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">4</span>
                                    <div class="step-content">
                                        Saat muncul konfirmasi <em>"Apakah Anda ingin langsung menjalankan instalasi sekarang? (Y/T)"</em>, ketik <strong>Y</strong> lalu tekan <kbd style="background:#334155;color:#fff;padding:2px 6px;border-radius:4px;font-size:11px;">Enter</kbd>.
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">5</span>
                                    <div class="step-content">
                                        <em>Info Penting:</em> Pada komputer pertama kali, script akan mengunduh master installer dan menyimpannya di folder <code>Apps\</code>. Flashdisk Anda otomatis menjadi <strong>Master USB Offline</strong> untuk komputer lab berikutnya!
                                    </div>
                                </li>
                            </ol>
                        </div>
                    </div>
                </div>

                <!-- METODE 2: DOWNLOAD MANUAL & FLASH DISK -->
                <div class="hub-card hub-card-secondary">
                    <div>
                        <div class="hub-card-header">
                            <div class="hub-card-badge badge-sec">💾 Metode 2: Unduh Berkas Manual (Mode USB)</div>
                            <h3 class="hub-card-title">Download Berkas & Susun Manual</h3>
                            <p class="hub-card-desc">
                                Gunakan opsi ini jika Anda ingin mengunduh berkas launcher secara mandiri dan menyusun struktur foldernya secara manual ke dalam flashdisk.
                            </p>
                        </div>

                        <div class="download-action-grid" style="margin: 14px 0 18px 0;">
                            <a href="{{ route('panduan.software.download-bat') }}" class="btn-hub-download btn-bat">
                                <svg style="width:20px;height:20px;color:#009344;flex-shrink:0;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                <div>
                                    <div class="btn-title">1. Unduh Runner Double-Click (.bat)</div>
                                    <div class="btn-sub">jalankan-instalasi.bat (Launcher Hak Administrator)</div>
                                </div>
                            </a>

                            <a href="{{ route('panduan.software.download') }}" class="btn-hub-download btn-ps">
                                <svg style="width:20px;height:20px;color:#2563eb;flex-shrink:0;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
                                <div>
                                    <div class="btn-title">2. Unduh Script Otomasi (.ps1)</div>
                                    <div class="btn-sub">install-lab-software.ps1 (Engine Inti 16 Software)</div>
                                </div>
                            </a>
                        </div>

                        <div class="guide-steps">
                            <div class="guide-step-title">📖 Panduan Penempatan & Struktur Folder:</div>
                            <div class="tree-display">📁 <strong style="color: #0284c7;">Lab_Software\</strong>
├── 📄 <span style="color: #059669; font-weight:700;">jalankan-instalasi.bat</span> <em style="color:#64748b;">(Simpan di luar folder)</em>
└── 📁 <strong style="color: #0284c7;">Apps\</strong>
    └── 📄 <span style="color: #2563eb; font-weight:700;">install-lab-software.ps1</span> <em style="color:#64748b;">(Wajib di dalam Apps\)</em></div>

                            <ol class="step-list" style="margin-top: 14px;">
                                <li>
                                    <span class="step-num">1</span>
                                    <div class="step-content">
                                        Buat folder bernama <code>Lab_Software</code> di flashdisk Anda, dan di dalamnya buat sub-folder bernama <code>Apps</code>.
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">2</span>
                                    <div class="step-content">
                                        Simpan berkas <code>jalankan-instalasi.bat</code> di folder <code>Lab_Software\</code>, dan simpan <code>install-lab-software.ps1</code> ke dalam <code>Lab_Software\Apps\</code>.
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">3</span>
                                    <div class="step-content">
                                        Klik kanan <code>jalankan-instalasi.bat</code> lalu pilih <strong>Run as administrator</strong> (atau klik 2x).
                                    </div>
                                </li>
                                <li>
                                    <span class="step-num">4</span>
                                    <div class="step-content">
                                        Pilih menu <strong>[1] Jalankan Otomasi Lengkap Lab</strong>. Software yang sudah ada otomatis diskip, yang belum ada akan langsung dipasang.
                                    </div>
                                </li>
                            </ol>
                        </div>
                    </div>
                </div>

            </div>

            <!-- 3 Pilar Fitur Unggulan Sistem Otomasi -->
            <div class="arch-pillars-grid">
                <div class="arch-pillar-card p-green">
                    <div class="arch-pillar-badge">1. Smart-Skip & Port Anti-Bentrok</div>
                    <h4>Otomatis Lewati yang Sudah Ada</h4>
                    <p>
                        Aplikasi yang sudah terpasang otomatis diskip. Port XAMPP dialihkan ke <strong>8088 & 3307</strong> sehingga Laragon, Laravel (8000), Vite (5173), dan Node.js berjalan berdampingan tanpa konflik port.
                    </p>
                </div>
                <div class="arch-pillar-card p-emerald">
                    <div class="arch-pillar-badge">2. Mode Hybrid Cepat (USB / Cloud)</div>
                    <h4>Otomatis Simpan Installer di USB</h4>
                    <p>
                        Jika installer offline belum ada, script mendownloadnya dan otomatis menyimpannya ke folder <code>Apps\</code> sehingga komputer lab berikutnya tinggal colok tanpa butuh kuota internet lagi.
                    </p>
                </div>
                <div class="arch-pillar-card p-amber">
                    <div class="arch-pillar-badge">3. GUI Interaktif Lisensi & Anti-Hang</div>
                    <h4>Bypass Antivirus & Timeout Proteksi</h4>
                    <p>
                        Aplikasi berlisensi (Delphi & Proteus) membuka wizard GUI interaktif untuk aktivasi lab, serta seluruh pengecekan status CLI diproteksi timeout agar proses tidak pernah macet/hang.
                    </p>
                </div>
            </div>
        </div>

        <!-- Filter Tab Buttons -->
        <div class="tab-bar">
            <button class="tab-btn active" onclick="filterCatalog('all', this)">
                <span>Semua Software</span>
                <span class="tab-count">14</span>
            </button>
            <button class="tab-btn" onclick="filterCatalog('licensed', this)">
                <span>🔒 Aplikasi Berlisensi</span>
                <span class="tab-count">4</span>
            </button>
            <button class="tab-btn" onclick="filterCatalog('foss', this)">
                <span>🌐 Aplikasi Bebas Lisensi</span>
                <span class="tab-count">10</span>
            </button>
        </div>

        <!-- ============================================================== -->
        <!-- SECTION 1: APLIKASI BERLISENSI (LICENSED) -->
        <!-- ============================================================== -->
        <div id="sectionLicensed" class="catalog-section">
            <div class="license-section-header">
                <div class="section-badge-header">
                    <h2>1. Perangkat Lunak Berlisensi</h2>
                    <span class="badge-type badge-licensed">🔒 Berlisensi & Academic Agreement</span>
                </div>
                <div style="font-size: 13px; color: var(--gray-500);">
                    Aplikasi komersial yang terikat lisensi akademik vendor, kemitraan akademi institusi, atau lisensi komunitas resmi.
                </div>
            </div>

            <div class="software-grid">
                <!-- 1. Delphi -->
                <div class="soft-card card-licensed" data-type="licensed">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#fee2e2;color:#dc2626;">DEL</div>
                        <div class="soft-meta">
                            <h4>Embarcadero Delphi</h4>
                            <span class="soft-vendor">Embarcadero Technologies</span>
                        </div>
                    </div>
                    <p class="soft-desc">IDE pemrograman visual berbasis Object Pascal untuk praktikum Algoritma & Pemrograman, Pemrograman Visual, dan pembuatan aplikasi desktop GUI.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Berlisensi Komersial / Academic</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Model Lisensi:</span>
                            <span class="license-spec-val">Academic Lab / Community License</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Fokus Praktikum:</span>
                            <span class="license-spec-val">Pemrograman Visual & GUI Desktop</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-licensed">🔒 Berlisensi Komersial</span>
                        <span class="soft-tag">Visual Pascal</span>
                    </div>
                </div>

                <!-- 2. Cisco Packet Tracer -->
                <div class="soft-card card-licensed" data-type="licensed">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#e0f2fe;color:#0284c7;">CIS</div>
                        <div class="soft-meta">
                            <h4>Cisco Packet Tracer</h4>
                            <span class="soft-vendor">Cisco Systems</span>
                        </div>
                    </div>
                    <p class="soft-desc">Perangkat lunak simulasi dan pemodelan arsitektur jaringan komputer untuk praktikum Jaringan Komputer, Komunikasi Data, Routing, Switching, dan IoT.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Berlisensi Cisco Systems</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Model Akses:</span>
                            <span class="license-spec-val">Akun Cisco Networking Academy (NetAcad)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Fokus Praktikum:</span>
                            <span class="license-spec-val">Jaringan Komputer & Topologi</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-licensed">🎓 NetAcad Licensed</span>
                        <span class="soft-tag">Jaringan Komputer</span>
                    </div>
                </div>

                <!-- 3. Visual Studio -->
                <div class="soft-card card-licensed" data-type="licensed">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#f3e8ff;color:#7c3aed;">VS</div>
                        <div class="soft-meta">
                            <h4>Microsoft Visual Studio</h4>
                            <span class="soft-vendor">Microsoft Corporation</span>
                        </div>
                    </div>
                    <p class="soft-desc">Integrated Development Environment (IDE) komprehensif untuk praktikum Pemrograman C#, .NET Framework, C++, dan Rekayasa Perangkat Lunak.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Microsoft Community License</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Ketentuan Lisensi:</span>
                            <span class="license-spec-val">Bebas Royalti untuk Laboratorium Akademik</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Fokus Praktikum:</span>
                            <span class="license-spec-val">Pemrograman C# & Desktop .NET</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-licensed">🎓 Academic Community</span>
                        <span class="soft-tag">IDE & .NET</span>
                    </div>
                </div>

                <!-- 4. Proteus Design Suite -->
                <div class="soft-card card-licensed" data-type="licensed">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#dbeafe;color:#1d4ed8;">PRT</div>
                        <div class="soft-meta">
                            <h4>Proteus Design Suite</h4>
                            <span class="soft-vendor">Labcenter Electronics Ltd</span>
                        </div>
                    </div>
                    <p class="soft-desc">Perangkat lunak simulasi sirkuit elektronika analog/digital, mikrokontroler (Arduino, AVR, PIC, ARM), serta desain layout PCB untuk praktikum Sistem Tertanam dan Arsitektur Komputer.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Berlisensi Komersial (Labcenter)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Model Lisensi:</span>
                            <span class="license-spec-val">Lab Site License / Key File (.lxk)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Fokus Praktikum:</span>
                            <span class="license-spec-val">Sistem Tertanam, IoT & Mikroprosesor</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-licensed">🔒 Commercial Lab License</span>
                        <span class="soft-tag">Simulasi Sirkuit & PCB</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================== -->
        <!-- SECTION 2: APLIKASI BEBAS LISENSI (OPEN SOURCE / FREE) -->
        <!-- ============================================================== -->
        <div id="sectionFoss" class="catalog-section">
            <div class="license-section-header">
                <div class="section-badge-header">
                    <h2>2. Perangkat Lunak Bebas Lisensi</h2>
                    <span class="badge-type badge-foss">🌐 100% Free & Open Source</span>
                </div>
                <div style="font-size: 13px; color: var(--gray-500);">
                    Aplikasi gratis dan open-source (FOSS) yang bebas royalti tanpa memerlukan serial key ataupun aktivasi lisensi berbayar.
                </div>
            </div>

            <div class="software-grid">
                <!-- 1. VS Code -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#e0f2fe;color:#0284c7;">VSC</div>
                        <div class="soft-meta">
                            <h4>Visual Studio Code (VS Code)</h4>
                            <span class="soft-vendor">Microsoft & Komunitas Open Source</span>
                        </div>
                    </div>
                    <p class="soft-desc">Editor kode sumber modern, cepat, dan ringan yang mendukung ekstensi untuk praktikum Pemrograman Web, Python, C++, dan bahasa pemrograman lainnya.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">MIT License</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">Microsoft.VisualStudioCode</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Open Source (MIT)</span>
                        <span class="soft-tag">Editor Kode</span>
                    </div>
                </div>

                <!-- 2. Android Studio -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#dcfce7;color:#16a34a;">AS</div>
                        <div class="soft-meta">
                            <h4>Android Studio</h4>
                            <span class="soft-vendor">Google LLC & JetBrains</span>
                        </div>
                    </div>
                    <p class="soft-desc">IDE resmi pengembangan aplikasi mobile Android native berbasis Kotlin dan Java, dilengkapi Android SDK, Platform Tools, dan Emulator.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Free & Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">Apache License 2.0 / Freeware</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">Google.AndroidStudio</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Free SDK & IDE</span>
                        <span class="soft-tag">Mobile Android</span>
                    </div>
                </div>

                <!-- 3. Python -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#fef3c7;color:#b45309;">PY</div>
                        <div class="soft-meta">
                            <h4>Python (3.x with PIP)</h4>
                            <span class="soft-vendor">Python Software Foundation</span>
                        </div>
                    </div>
                    <p class="soft-desc">Runtime bahasa pemrograman serbaguna untuk praktikum Algoritma & Pemrograman, Kecerdasan Buatan (AI), Machine Learning, dan Analisis Data.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">Python Software Foundation (PSF)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">Python.Python.3.12</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Open Source (PSF)</span>
                        <span class="soft-tag">Bahasa Pemrograman</span>
                    </div>
                </div>

                <!-- 4. Java & Java SDK -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#fee2e2;color:#dc2626;">JDK</div>
                        <div class="soft-meta">
                            <h4>Java & Java SDK (OpenJDK)</h4>
                            <span class="soft-vendor">OpenJDK / Eclipse Adoptium</span>
                        </div>
                    </div>
                    <p class="soft-desc">Java Development Kit (JDK) resmi untuk kompilasi dan eksekusi kode praktikum Pemrograman Berorientasi Objek (PBO) serta dependensi build Gradle.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">GNU GPLv2 with Classpath Exception</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">System Variable:</span>
                            <span class="license-spec-val">JAVA_HOME & %JAVA_HOME%\bin</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Free & Open Source</span>
                        <span class="soft-tag">Java Development</span>
                    </div>
                </div>

                <!-- 5. QGIS -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#ecfdf5;color:#047857;">GIS</div>
                        <div class="soft-meta">
                            <h4>QGIS Desktop</h4>
                            <span class="soft-vendor">OSGeo Foundation</span>
                        </div>
                    </div>
                    <p class="soft-desc">Perangkat lunak Sistem Informasi Geografis (SIG) tingkat lanjut untuk analisis data spasial, pemetaan tematik peta, dan digitasi citra satelit.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">GNU General Public License (GPLv2)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">OSGeo.QGIS</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Open Source (GPLv2)</span>
                        <span class="soft-tag">Sistem Informasi Geografis</span>
                    </div>
                </div>

                <!-- 6. XAMPP -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#ffedd5;color:#ea580c;">XMP</div>
                        <div class="soft-meta">
                            <h4>XAMPP</h4>
                            <span class="soft-vendor">Apache Friends</span>
                        </div>
                    </div>
                    <p class="soft-desc">Paket web server lokal yang menggabungkan Apache HTTP Server, MariaDB/MySQL database, dan modul PHP/Perl untuk praktikum Pemrograman Web Dasar.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Port Standar Lab:</span>
                            <span class="license-spec-val" style="color:#c2410c;">Port 8080 (Web) & 3307 (DB)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Komponen:</span>
                            <span class="license-spec-val">Apache, MariaDB, PHP, phpMyAdmin</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Free Web Server</span>
                        <span class="soft-tag" style="background:#fef3c7;color:#92400e;">⚠️ Hindari Port 80 & 3306</span>
                    </div>
                </div>

                <!-- 7. Laragon -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#eff6ff;color:#1e40af;">LRG</div>
                        <div class="soft-meta">
                            <h4>Laragon</h4>
                            <span class="soft-vendor">Laragon Team</span>
                        </div>
                    </div>
                    <p class="soft-desc">Lingkungan server web modern, cepat, dan terisolasi untuk praktikum pengembangan aplikasi web berbasis PHP, Laravel, Node.js, dan MySQL.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Free Edition)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Port Standar Lab:</span>
                            <span class="license-spec-val" style="color:#15803d;">Port 80 (Web) & 3306 (DB)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Keunggulan:</span>
                            <span class="license-spec-val">Pretty URLs (*.test), Ringan & Portable</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Free Development Stack</span>
                        <span class="soft-tag" style="background:#dcfce7;color:#166534;">✓ Prioritas Port Utama</span>
                    </div>
                </div>

                <!-- 8. VirtualBox -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#e0f2fe;color:#0369a1;">VBX</div>
                        <div class="soft-meta">
                            <h4>Oracle VM VirtualBox</h4>
                            <span class="soft-vendor">Oracle Corporation</span>
                        </div>
                    </div>
                    <p class="soft-desc">Hypervisor tipe-2 open source untuk virtualisasi mesin tamu (Guest OS) Linux/Windows pada praktikum Sistem Operasi, Jaringan Komputer, dan Administrasi Server.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">GNU General Public License v3 (GPLv3)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">Oracle.VirtualBox</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Open Source (GPLv3)</span>
                        <span class="soft-tag">Virtualisasi & OS</span>
                    </div>
                </div>

                <!-- 9. NetBeans -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#fdf2f8;color:#be185d;">NB</div>
                        <div class="soft-meta">
                            <h4>Apache NetBeans IDE</h4>
                            <span class="soft-vendor">Apache Software Foundation</span>
                        </div>
                    </div>
                    <p class="soft-desc">IDE modular terkemuka untuk pengembangan aplikasi berbasis Java Desktop (Swing/JavaFX), PHP, dan Web Service dalam kurikulum Pemrograman Berorientasi Objek.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">Apache License 2.0</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">Apache.NetBeans</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Apache License 2.0</span>
                        <span class="soft-tag">Java IDE</span>
                    </div>
                </div>

                <!-- 10. Arduino IDE -->
                <div class="soft-card card-foss" data-type="foss">
                    <div class="soft-top">
                        <div class="soft-icon" style="background:#ccfbf1;color:#0f766e;">ARD</div>
                        <div class="soft-meta">
                            <h4>Arduino IDE</h4>
                            <span class="soft-vendor">Arduino SA</span>
                        </div>
                    </div>
                    <p class="soft-desc">IDE resmi untuk pemrograman mikrokontroler Arduino Uno, Nano, Mega, dan modul IoT (ESP32/ESP8266) dalam kurikulum Sistem Tertanam, Robotika, dan IoT.</p>
                    <div class="license-spec-box">
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Status Lisensi:</span>
                            <span class="license-spec-val">Bebas Lisensi (Open Source)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Jenis Lisensi:</span>
                            <span class="license-spec-val">GNU General Public License (GPL)</span>
                        </div>
                        <div class="license-spec-row">
                            <span class="license-spec-lbl">Winget Package:</span>
                            <span class="license-spec-val">ArduinoSA.IDE.stable</span>
                        </div>
                    </div>
                    <div class="soft-footer">
                        <span class="badge-status-pill badge-status-foss">🌐 Open Source (GPL)</span>
                        <span class="soft-tag">Arduino Uno / IoT</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================== -->
        <!-- PANDUAN PENCEGAHAN TABRAKAN (XAMPP VS LARAGON CONFLICT GUARD) -->
        <!-- ============================================================== -->
        <div style="background: #ffffff; border: 2px solid #fed7aa; border-radius: 20px; padding: 28px; margin: 36px 0; box-shadow: 0 4px 20px rgba(249, 115, 22, 0.06);">
            <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 16px;">
                <div style="width: 44px; height: 44px; background: #ffedd5; color: #ea580c; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <svg style="width: 24px; height: 24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                </div>
                <div>
                    <h3 style="font-size: 18px; font-weight: 900; color: #9a3412; margin: 0 0 4px 0;">SOP Penanganan Konflik Port: XAMPP vs Laragon</h3>
                    <p style="font-size: 13px; color: #7c2d12; margin: 0;">Panduan teknis agar XAMPP dan Laragon dapat terpasang di satu PC lab yang sama tanpa saling bentrok atau gagal start (*Port Binding Collision*).</p>
                </div>
            </div>

            <!-- Analisis Masalah -->
            <div style="background: #fff7ed; border-radius: 12px; padding: 14px 18px; margin-bottom: 20px; border: 1px solid #ffedd5;">
                <p style="font-size: 13px; color: #9a3412; line-height: 1.6; margin: 0;">
                    <strong>Kenapa Bisa Bentrok?</strong> Secara bawaan (default), baik Apache di XAMPP maupun Nginx/Apache di Laragon memperebutkan <strong>Port 80 (HTTP)</strong> dan <strong>Port 443 (SSL)</strong>. Selain itu, database MariaDB/MySQL pada kedua aplikasi sama-sama memperebutkan <strong>Port 3306</strong>. Jika salah satu sedang berjalan, aplikasi lainnya akan error dengan pesan <em>"Port 80 in use by another program"</em> atau <em>"Cannot start MySQL: Port 3306 already bound"</em>.
                </p>
            </div>

            <!-- 3 Langkah Penjagaan Resmi Lab -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 22px;">
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 12px; font-weight: 800; color: #0284c7; text-transform: uppercase; margin-bottom: 6px;">Aturan 1 (On-Demand)</div>
                    <h4 style="font-size: 14.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Dilarang Pasang Sebagai Windows Service</h4>
                    <p style="font-size: 12.5px; color: #475569; line-height: 1.5; margin: 0;">
                        Jangan pernah mencentang kotak <strong>"Service"</strong> pada XAMPP Control Panel dan jangan aktifkan opsi <em>"Run when Windows starts"</em> pada Laragon. Keduanya hanya dijalankan saat praktikum berlangsung dan wajib di-<strong>Stop</strong> setelah praktikum selesai.
                    </p>
                </div>

                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 12px; font-weight: 800; color: #16a34a; text-transform: uppercase; margin-bottom: 6px;">Aturan 2 (Pembagian Port)</div>
                    <h4 style="font-size: 14.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Standardisasi Port Terpisah (Dual-Stack)</h4>
                    <p style="font-size: 12.5px; color: #475569; line-height: 1.5; margin: 0;">
                        • <strong>Laragon:</strong> Menggunakan port standar web (Port <code>80</code> & MySQL <code>3306</code>) agar fitur virtual host <code>*.test</code> berjalan lancar.<br>
                        • <strong>XAMPP:</strong> Di-setting ke port alternatif: Apache Port <code>8080</code> (akses via <code>localhost:8080</code>) dan MySQL Port <code>3307</code>.
                    </p>
                </div>

                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 12px; font-weight: 800; color: #ea580c; text-transform: uppercase; margin-bottom: 6px;">Aturan 3 (Kerapian PATH)</div>
                    <h4 style="font-size: 14.5px; font-weight: 800; color: #0f172a; margin-bottom: 8px;">Isolasi Eksekutabel PHP di Terminal</h4>
                    <p style="font-size: 12.5px; color: #475569; line-height: 1.5; margin: 0;">
                        Gunakan terminal bawaan Laragon saat mengerjakan proyek Laravel/Composer modern. Jangan menaruh folder <code>C:\xampp\php</code> dan <code>C:\laragon\bin\php</code> secara bersamaan di System PATH Windows agar perintah <code>php -v</code> tidak membingungkan mahasiswa.
                    </p>
                </div>
            </div>

            <!-- Skrip Darurat Pembebas Port -->
            <div style="background: #0f172a; border-radius: 14px; padding: 18px 20px; border: 1px solid #1e293b;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; flex-wrap: wrap; gap: 8px;">
                    <span style="font-size: 12.5px; font-weight: 700; color: #38bdf8; font-family: 'JetBrains Mono', monospace;">⚡ Skrip Cepat Pembebas Port Macet (PowerShell Administrator)</span>
                    <button class="btn-copy" onclick="copyPortScript()" style="padding: 6px 12px; font-size: 11.5px;">
                        <svg style="width:13px;height:13px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"/></svg>
                        <span id="copyPortLabel">Salin Perintah</span>
                    </button>
                </div>
                <div style="background: #1e293b; padding: 12px 14px; border-radius: 8px; font-family: 'JetBrains Mono', monospace; font-size: 12px; color: #f8fafc; overflow-x: auto; white-space: nowrap;">
                    <code id="cmdPortScript">Get-Process -Name httpd, mysqld, nginx, php-cgi -ErrorAction SilentlyContinue | Stop-Process -Force</code>
                </div>
                <p style="font-size: 11.5px; color: #94a3b8; margin: 8px 0 0 0;">
                    Jalankan perintah ini jika XAMPP atau Laragon tertutup mendadak (*force close*) dan proses servernya masih mengunci Port 80 atau 3306 di latar belakang.
                </p>
            </div>
        </div>

        <!-- Matriks Audit Lisensi 13 Software -->
        <h3 style="font-size: 19px; font-weight: 800; color: var(--gray-900); margin: 36px 0 16px 0; display: flex; align-items: center; gap: 10px;">
            <svg style="width:22px;height:22px;color:var(--unimal-green);" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
            <span>Matriks Ringkasan Lisensi 13 Software Standar Lab TI</span>
        </h3>

        <div style="overflow-x: auto;">
            <table class="spec-table">
                <thead>
                    <tr>
                        <th style="width: 5%;">No</th>
                        <th style="width: 25%;">Nama Software</th>
                        <th style="width: 25%;">Kategori Praktikum</th>
                        <th style="width: 25%;">Klasifikasi Lisensi</th>
                        <th style="width: 20%;">Status Kepatuhan</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1</td>
                        <td><strong>Embarcadero Delphi</strong></td>
                        <td>Pemrograman Visual & Algoritma</td>
                        <td><span class="badge-status-pill badge-status-licensed">🔒 Berlisensi Komersial</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td><strong>Cisco Packet Tracer</strong></td>
                        <td>Jaringan Komputer & Topologi</td>
                        <td><span class="badge-status-pill badge-status-licensed">🔒 Berlisensi (NetAcad)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>3</td>
                        <td><strong>Microsoft Visual Studio</strong></td>
                        <td>Pemrograman C# & .NET Desktop</td>
                        <td><span class="badge-status-pill badge-status-licensed">🎓 Community Academic</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>4</td>
                        <td><strong>Proteus Design Suite</strong></td>
                        <td>Sistem Tertanam & Simulasi PCB</td>
                        <td><span class="badge-status-pill badge-status-licensed">🔒 Berlisensi Labcenter</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>5</td>
                        <td><strong>Visual Studio Code (VS Code)</strong></td>
                        <td>Editor Kode Universal</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (MIT)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>6</td>
                        <td><strong>Android Studio</strong></td>
                        <td>Mobile Android Development</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (Apache 2.0)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>7</td>
                        <td><strong>Python (with PIP)</strong></td>
                        <td>Algoritma & Pemrograman / AI</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (PSF)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>8</td>
                        <td><strong>Java & Java SDK (JDK)</strong></td>
                        <td>Pemrograman Berorientasi Objek (PBO)</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (GPLv2)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>9</td>
                        <td><strong>Oracle VM VirtualBox</strong></td>
                        <td>Sistem Operasi & Virtualisasi</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (GPLv3)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>10</td>
                        <td><strong>Apache NetBeans IDE</strong></td>
                        <td>Pemrograman PBO & Java GUI</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (Apache 2.0)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>11</td>
                        <td><strong>QGIS Desktop</strong></td>
                        <td>Sistem Informasi Geografis (SIG)</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (GPLv2)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>12</td>
                        <td><strong>Arduino IDE</strong></td>
                        <td>Sistem Tertanam, Robotika & IoT (Uno)</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (GPL)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>13</td>
                        <td><strong>XAMPP</strong></td>
                        <td>Web Server & Database (MySQL)</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (GPL)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                    <tr>
                        <td>14</td>
                        <td><strong>Laragon</strong></td>
                        <td>Modern Web Stack (PHP/Laravel)</td>
                        <td><span class="badge-status-pill badge-status-foss">🌐 Bebas Lisensi (Free)</span></td>
                        <td><span style="color:#15803d;font-weight:700;">✓ Legal</span></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- ============================================================== -->
        <!-- PANDUAN STRUKTUR MEDIA INSTALLER (OFFLINE / USB DEPLOYMENT) -->
        <!-- ============================================================== -->
        <div style="background: #ffffff; border: 2px solid #bae6fd; border-radius: 20px; padding: 28px; margin: 36px 0; box-shadow: 0 4px 20px rgba(14, 165, 233, 0.06);">
            <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 18px;">
                <div style="width: 44px; height: 44px; background: #e0f2fe; color: #0284c7; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <svg style="width: 24px; height: 24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2"/></svg>
                </div>
                <div>
                    <h3 style="font-size: 19px; font-weight: 900; color: #0369a1; margin: 0 0 4px 0;">Panduan Standardisasi Media Flashdisk & SSD (Offline Lab Deployment)</h3>
                    <p style="font-size: 13px; color: #075985; margin: 0;">Susunan direktori media instalasi laboratorium agar asisten lab dapat menginstal 30–40 PC dengan cepat tanpa membebani bandwidth internet.</p>
                </div>
            </div>

            <!-- Pohon Direktori Flashdisk -->
            <div style="background: #0f172a; border-radius: 14px; padding: 20px; border: 1px solid #1e293b; margin-bottom: 22px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px solid #334155; padding-bottom: 10px;">
                    <span style="font-size: 12.5px; font-weight: 800; color: #38bdf8; font-family: 'JetBrains Mono', monospace;">📁 Denah Folder Media Installer (Drive USB E:\ atau D:\)</span>
                    <span style="font-size: 11px; background: #0369a1; color: #fff; padding: 2px 8px; border-radius: 6px; font-weight: 700;">Format NTFS</span>
                </div>
                <pre style="font-family: 'JetBrains Mono', monospace; font-size: 12.5px; color: #f1f5f9; line-height: 1.65; overflow-x: auto; margin: 0;">
<strong>Media Installer</strong> (Drive D:\ atau E:\)
└── <strong>Lab_Software/</strong>
    ├── <span style="color:#facc15;font-weight:900;">jalankan-instalasi.bat</span>         <span style="color:#facc15;font-weight:700;">← [SATU-SATUNYA FILE DI LUAR] Klik kanan &gt; Run as Administrator</span>
    └── <strong>Apps/</strong>                          <span style="color:#34d399;font-weight:700;">← [SEMUA FILE SCRIPT &amp; MASTER INSTALLER OFFLINE]</span>
        ├── <span style="color:#38bdf8;font-weight:700;">install-lab-software.ps1</span>   <span style="color:#94a3b8;">← Script Otomasi PowerShell (Dijalankan otomatis oleh file .bat)</span>
        ├── <span style="color:#38bdf8;font-weight:700;">Laragon_Custom_Stack/</span>      <span style="color:#34d399;font-weight:700;">← [MODUL STACK KHUSUS LAB]</span> <span style="color:#94a3b8;">PHP 8.3/8.4/8.5, MySQL, Node, Python, PMA (Tanpa www &amp; data)</span>
        ├── <span style="color:#a7f3d0;">laragon-wamp-setup-6.0.0.exe</span> <span style="color:#a7f3d0;">[🌐 Installer Resmi v6.0.0 Bebas Lisensi]</span> <span style="color:#94a3b8;">Diinstal resmi dulu, lalu ditimpa custom stack</span>
        <span style="color:#fbbf24;">├── [1] proteus*.exe</span>           <span style="color:#fbbf24;font-weight:700;">[🔒 Pihak Ketiga / Lab License]</span> <span style="color:#94a3b8;">Wizard GUI interaktif otomatis terbuka</span>
        <span style="color:#fbbf24;">├── [2] delphi*.exe</span>            <span style="color:#fbbf24;font-weight:700;">[🔒 Pihak Ketiga / Academic]</span> <span style="color:#94a3b8;">Wizard GUI interaktif otomatis terbuka</span>
        <span style="color:#fbbf24;">├── [3] CiscoPacketTracer_901_win_64bit.exe</span> <span style="color:#fbbf24;font-weight:700;">[🔒 NetAcad Standalone]</span> <span style="color:#94a3b8;">Otomatis silent (295 MB - v9.0.1 64-bit)</span>
        <span style="color:#fbbf24;">├── [4] vs_Community*.exe</span>      <span style="color:#fbbf24;font-weight:700;">[🔒 Visual Studio 2022]</span> <span style="color:#94a3b8;">Otomatis silent (Microsoft)</span>
        <span style="color:#a7f3d0;">├── [5] Oracle VirtualBox*.exe</span> <span style="color:#a7f3d0;">[🌐 Oracle VM VirtualBox]</span> <span style="color:#94a3b8;">Otomatis silent (178 MB)</span>
        <span style="color:#a7f3d0;">├── [6] Apache NetBeans*.exe</span>   <span style="color:#a7f3d0;">[🌐 Apache NetBeans IDE]</span> <span style="color:#94a3b8;">Otomatis silent (517 MB)</span>
        <span style="color:#a7f3d0;">├── [7] Eclipse Temurin JDK*.msi</span><span style="color:#a7f3d0;">[🌐 Temurin Java JDK 17]</span> <span style="color:#94a3b8;">Otomatis silent + JAVA_HOME (168 MB)</span>
        <span style="color:#a7f3d0;">├── [8] Android Studio*.exe</span>    <span style="color:#a7f3d0;">[🌐 Android Studio]</span> <span style="color:#94a3b8;">Otomatis silent (1.48 GB)</span>
        <span style="color:#a7f3d0;">├── [9] Visual Studio Code*.exe</span><span style="color:#a7f3d0;">[🌐 Visual Studio Code]</span> <span style="color:#94a3b8;">Otomatis silent (232 MB)</span>
        <span style="color:#a7f3d0;">├── [10] Python 3.12*.exe</span>      <span style="color:#a7f3d0;">[🌐 Python 3.12 + PIP]</span> <span style="color:#94a3b8;">Otomatis silent + System PATH (27 MB)</span>
        <span style="color:#a7f3d0;">├── [11] QGIS_*.msi</span>            <span style="color:#a7f3d0;">[🌐 QGIS Desktop]</span> <span style="color:#94a3b8;">Otomatis silent (618 MB)</span>
        <span style="color:#a7f3d0;">├── [12] Arduino IDE_*.msi</span>     <span style="color:#a7f3d0;">[🌐 Arduino IDE (Uno/IoT)]</span> <span style="color:#94a3b8;">Otomatis silent (167 MB)</span>
        <span style="color:#a7f3d0;">├── [13] Dependencies/</span>         <span style="color:#a7f3d0;">[🌐 Paket Pendukung]</span> <span style="color:#94a3b8;">VC++ 2015-2022 Redistributable 64-bit</span>
        <span style="color:#a7f3d0;">└── [14] xampp-windows*.exe</span>    <span style="color:#a7f3d0;">[🌐 XAMPP 8.2+]</span> <span style="color:#94a3b8;">Otomatis silent</span></pre>
            </div>

            <!-- Penjelasan Mengapa Pola Ini Paling Efektif -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px;">
                <div style="background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 11.5px; font-weight: 800; color: #0284c7; text-transform: uppercase; margin-bottom: 6px;">1. Satu File di Luar (Mudah Dipahami)</div>
                    <h4 style="font-size: 14px; font-weight: 800; color: #0c4a6e; margin-bottom: 8px;">Cukup Dobel-Klik jalankan-instalasi.bat</h4>
                    <p style="font-size: 12.5px; color: #0369a1; line-height: 1.5; margin: 0;">
                        Seluruh file script <code>.ps1</code> dan installer ditaruh rapi di dalam folder <code>Apps/</code>. Pengguna cukup klik kanan <strong>jalankan-instalasi.bat</strong> di luar folder tanpa pusing memilih file.
                    </p>
                </div>

                <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 11.5px; font-weight: 800; color: #15803d; text-transform: uppercase; margin-bottom: 6px;">2. Metode Hybrid Laragon (Resmi + Stack Lengkap)</div>
                    <h4 style="font-size: 14px; font-weight: 800; color: #14532d; margin-bottom: 8px;">Terdaftar di Windows + Modul Kustom</h4>
                    <p style="font-size: 12.5px; color: #166534; line-height: 1.5; margin: 0;">
                        Script menginstal installer resmi Laragon agar terdaftar di Windows, lalu secara otomatis menimpakan modul <code>bin</code> (PHP 8.3–8.5, MySQL, Node.js, Python) & <code>phpMyAdmin</code>. Folder web <code>www</code> dan database <code>data</code> pribadi dijamin <strong>100% tidak terbawa</strong>.
                    </p>
                </div>

                <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 14px; padding: 18px;">
                    <div style="font-size: 11.5px; font-weight: 800; color: #b45309; text-transform: uppercase; margin-bottom: 6px;">3. Anti-False Alarm Defender & Pihak Ketiga</div>
                    <h4 style="font-size: 14px; font-weight: 800; color: #78350f; margin-bottom: 8px;">Bypass Antivirus Sementara & GUI Interaktif</h4>
                    <p style="font-size: 12.5px; color: #92400e; line-height: 1.5; margin: 0;">
                        Defender otomatis dimasukkan ke <em>Exclusion</em> selama instalasi agar patch lisensi tidak terhapus. Untuk software pihak ketiga (Proteus & Delphi), script membuka wizard GUI agar aktivasi lisensi berjalan lancar tanpa macet di latar belakang.
                    </p>
                </div>
            </div>
        </div>

    </div>

    <footer class="guide-footer">
        <p>&copy; {{ date('Y') }} Laboratorium Komputer Program Studi Teknik Informatika — Universitas Malikussaleh (Unimal). Seluruh hak cipta dilindungi.</p>
    </footer>

    <script>
        function copyCommand() {
            const cmd = document.getElementById('cmdText').innerText;
            navigator.clipboard.writeText(cmd).then(() => {
                const label = document.getElementById('copyLabel');
                const prev = label.innerText;
                label.innerText = 'Tersalin ke Clipboard!';
                setTimeout(() => {
                    label.innerText = prev;
                }, 2500);
            });
        }

        function copyPortScript() {
            const cmd = document.getElementById('cmdPortScript').innerText;
            navigator.clipboard.writeText(cmd).then(() => {
                const label = document.getElementById('copyPortLabel');
                const prev = label.innerText;
                label.innerText = 'Tersalin! ✓';
                setTimeout(() => {
                    label.innerText = prev;
                }, 2500);
            });
        }

        function filterCatalog(type, el) {
            const tabs = document.querySelectorAll('.tab-btn');
            tabs.forEach(t => t.classList.remove('active'));
            el.classList.add('active');

            const cards = document.querySelectorAll('.soft-card');
            const secLicensed = document.getElementById('sectionLicensed');
            const secFoss = document.getElementById('sectionFoss');

            if (type === 'all') {
                secLicensed.style.display = 'block';
                secFoss.style.display = 'block';
                cards.forEach(c => c.style.display = 'flex');
            } else if (type === 'licensed') {
                secLicensed.style.display = 'block';
                secFoss.style.display = 'none';
                cards.forEach(c => {
                    c.style.display = c.dataset.type === 'licensed' ? 'flex' : 'none';
                });
            } else if (type === 'foss') {
                secLicensed.style.display = 'none';
                secFoss.style.display = 'block';
                cards.forEach(c => {
                    c.style.display = c.dataset.type === 'foss' ? 'flex' : 'none';
                });
            }
        }
    </script>
</body>
</html>
