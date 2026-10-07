<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panduan & Model 3D Perakitan Kabel LAN UTP RJ-45 — Lab TI Unimal</title>
    
    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ asset('favicon.png') }}">
    <link rel="apple-touch-icon" href="{{ asset('apple-touch-icon.png') }}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">

    <!-- Three.js & OrbitControls via CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>

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

        /* Topbar Header */
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
            backdrop-filter: blur(8px);
        }

        .back-nav {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--gray-700);
            font-size: 13.5px;
            font-weight: 700;
            transition: color 0.2s;
        }

        .back-nav:hover {
            color: var(--unimal-green);
        }

        .back-nav svg {
            width: 18px;
            height: 18px;
        }

        .brand-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.3px;
        }

        .main-container {
            max-width: 1240px;
            margin: 32px auto;
            padding: 0 24px;
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 32px;
        }

        /* Hero Banner */
        .hero-banner {
            background: linear-gradient(135deg, #064e3b 0%, #065f46 40%, #047857 100%);
            border-radius: 24px;
            padding: 40px 48px;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            box-shadow: 0 20px 40px -15px rgba(6, 78, 59, 0.4);
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 240px;
            height: 240px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.08);
            pointer-events: none;
        }

        .hero-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(8px);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 16px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .hero-banner h1 {
            font-size: 32px;
            font-weight: 900;
            letter-spacing: -0.5px;
            line-height: 1.25;
            margin-bottom: 12px;
        }

        .hero-banner p {
            font-size: 16px;
            color: #d1fae5;
            max-width: 780px;
            line-height: 1.6;
        }

        /* 3D Visualizer Card */
        .viewer-card {
            background: #ffffff;
            border-radius: 24px;
            border: 1px solid var(--gray-200);
            box-shadow: 0 10px 30px -10px rgba(0,0,0,0.06);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .viewer-header {
            padding: 20px 28px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            background: #ffffff;
        }

        .viewer-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .viewer-title .icon-cube {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: #ecfdf5;
            color: var(--unimal-green);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .viewer-title h2 {
            font-size: 18px;
            font-weight: 800;
            color: var(--gray-900);
        }

        .viewer-title span {
            font-size: 12.5px;
            color: var(--gray-500);
            font-weight: 500;
        }

        .controls-toolbar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn-view-toggle {
            padding: 8px 16px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            border: 1px solid var(--gray-300);
            background: #ffffff;
            color: var(--gray-700);
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
        }

        .btn-view-toggle:hover {
            border-color: var(--unimal-green);
            color: var(--unimal-green);
        }

        .btn-view-toggle.active {
            background: var(--unimal-green);
            color: #ffffff;
            border-color: var(--unimal-green);
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.25);
        }

        /* 3D Canvas Container */
        .canvas-wrapper {
            position: relative;
            width: 100%;
            height: 520px;
            background: radial-gradient(circle at center, #1e293b 0%, #0f172a 100%);
            cursor: grab;
            overflow: hidden;
        }

        .canvas-wrapper:active {
            cursor: grabbing;
        }

        #threejs-canvas {
            width: 100%;
            height: 100%;
            display: block;
        }

        /* Floating Overlays on 3D Canvas */
        .canvas-hud {
            position: absolute;
            top: 20px;
            left: 20px;
            pointer-events: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .hud-badge {
            background: rgba(15, 23, 42, 0.75);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #ffffff;
            padding: 8px 14px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .hud-hint {
            font-size: 11.5px;
            color: #94a3b8;
            font-weight: 500;
        }

        .canvas-actions {
            position: absolute;
            bottom: 20px;
            right: 20px;
            display: flex;
            gap: 8px;
        }

        .canvas-btn {
            background: rgba(15, 23, 42, 0.8);
            backdrop-filter: blur(6px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #ffffff;
            padding: 8px 14px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .canvas-btn:hover {
            background: rgba(0, 147, 68, 0.9);
            border-color: var(--unimal-green);
        }

        /* Color Code Quick Bar */
        .color-sequence-strip {
            background: #ffffff;
            padding: 18px 28px;
            border-top: 1px solid var(--gray-200);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .sequence-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .sequence-title h4 {
            font-size: 14px;
            font-weight: 800;
            color: var(--gray-800);
        }

        .sequence-title span {
            font-size: 12px;
            color: var(--gray-500);
            font-family: 'JetBrains Mono', monospace;
        }

        .pins-flex {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 8px;
        }

        .pin-pill {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 6px;
            border-radius: 12px;
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }

        .pin-pill:hover, .pin-pill.active {
            transform: translateY(-3px);
            box-shadow: 0 8px 16px -4px rgba(0, 0, 0, 0.1);
            border-color: var(--unimal-green);
            background: #ffffff;
        }

        .pin-number {
            font-size: 11px;
            font-weight: 800;
            color: var(--gray-500);
            margin-bottom: 6px;
        }

        .pin-swatch {
            width: 22px;
            height: 40px;
            border-radius: 6px;
            border: 1.5px solid rgba(0, 0, 0, 0.15);
            margin-bottom: 6px;
            box-shadow: inset 0 2px 4px rgba(255, 255, 255, 0.4);
        }

        .pin-name {
            font-size: 10px;
            font-weight: 700;
            text-align: center;
            color: var(--gray-700);
            line-height: 1.2;
            word-break: break-word;
        }

        /* Content Grid (2 Columns: Standards Comparison & Tools/Steps) */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 28px;
        }

        @media (max-width: 992px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
            .pins-flex {
                grid-template-columns: repeat(4, 1fr);
            }
        }

        .info-card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 30px;
            box-shadow: 0 4px 20px -5px rgba(0,0,0,0.03);
        }

        .info-card h3 {
            font-size: 18px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-card h3 svg {
            color: var(--unimal-green);
        }

        /* Cable Type Cards */
        .cable-type-box {
            border: 1px solid var(--gray-200);
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 16px;
            background: var(--gray-50);
            transition: border-color 0.2s;
        }

        .cable-type-box:hover {
            border-color: var(--unimal-green);
        }

        .cable-type-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .cable-type-title {
            font-size: 16px;
            font-weight: 800;
            color: var(--gray-900);
        }

        .badge-type {
            font-size: 11px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
        }

        .badge-straight {
            background: #e0f2fe;
            color: #0369a1;
        }

        .badge-cross {
            background: #fef3c7;
            color: #92400e;
        }

        .cable-type-desc {
            font-size: 13.5px;
            color: var(--gray-600);
            line-height: 1.5;
            margin-bottom: 12px;
        }

        .use-case-list {
            font-size: 12.5px;
            color: var(--gray-700);
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .use-case-list li {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .use-case-list li svg {
            width: 14px;
            height: 14px;
            color: var(--unimal-green);
            flex-shrink: 0;
        }

        /* Step by Step Guide */
        .step-timeline {
            display: flex;
            flex-direction: column;
            gap: 20px;
            position: relative;
        }

        .step-item {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .step-num {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            font-weight: 800;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            margin-top: 2px;
            border: 1px solid rgba(0, 147, 68, 0.2);
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

        .step-tip {
            margin-top: 8px;
            background: #fefce8;
            border-left: 3px solid var(--unimal-gold);
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 12px;
            color: #854d0e;
        }

        /* Tool Checklist */
        .tool-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px;
            margin-top: 14px;
        }

        .tool-card {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 12px;
            padding: 14px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .tool-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            font-size: 18px;
        }

        .tool-card span {
            font-size: 12px;
            font-weight: 700;
            color: var(--gray-800);
        }

        /* Interactive Tester Simulator */
        .tester-card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--gray-200);
            padding: 30px;
            box-shadow: 0 4px 20px -5px rgba(0,0,0,0.03);
        }

        .tester-grid {
            display: grid;
            grid-template-columns: 1fr 80px 1fr;
            gap: 16px;
            align-items: center;
            background: #0f172a;
            padding: 24px;
            border-radius: 16px;
            margin-top: 16px;
            color: #ffffff;
        }

        .tester-unit {
            display: flex;
            flex-direction: column;
            gap: 10px;
            background: #1e293b;
            padding: 16px;
            border-radius: 12px;
            border: 1px solid #334155;
        }

        .unit-header {
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            color: #94a3b8;
            text-align: center;
            border-bottom: 1px solid #334155;
            padding-bottom: 8px;
        }

        .led-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 4px 8px;
            border-radius: 6px;
            background: #0f172a;
        }

        .led-num {
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            font-weight: 700;
            color: #cbd5e1;
        }

        .led-light {
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: #334155;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.5);
            transition: all 0.15s ease;
        }

        .led-light.active-green {
            background: #22c55e;
            box-shadow: 0 0 12px #22c55e, inset 0 1px 2px #bbf7d0;
        }

        .led-light.active-yellow {
            background: #eab308;
            box-shadow: 0 0 12px #eab308, inset 0 1px 2px #fef08a;
        }

        .tester-status-panel {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            gap: 12px;
        }

        .btn-test-run {
            background: var(--unimal-green);
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 10px;
            font-weight: 800;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.4);
        }

        .btn-test-run:hover {
            background: #15803d;
            transform: scale(1.05);
        }

        /* Footer */
        footer.page-footer {
            margin-top: auto;
            background: #ffffff;
            border-top: 1px solid var(--gray-200);
            padding: 24px;
            text-align: center;
            font-size: 13px;
            color: var(--gray-500);
        }

        /* Color Striping Patterns */
        .color-white-orange {
            background: repeating-linear-gradient(45deg, #ffffff, #ffffff 4px, #ea580c 4px, #ea580c 8px);
        }
        .color-orange {
            background: #ea580c;
        }
        .color-white-green {
            background: repeating-linear-gradient(45deg, #ffffff, #ffffff 4px, #16a34a 4px, #16a34a 8px);
        }
        .color-blue {
            background: #2563eb;
        }
        .color-white-blue {
            background: repeating-linear-gradient(45deg, #ffffff, #ffffff 4px, #2563eb 4px, #2563eb 8px);
        }
        .color-green {
            background: #16a34a;
        }
        .color-white-brown {
            background: repeating-linear-gradient(45deg, #ffffff, #ffffff 4px, #854d0e 4px, #854d0e 8px);
        }
        .color-brown {
            background: #854d0e;
        }
    </style>
</head>
<body>

    <!-- Topbar -->
    <header class="topbar">
        <a href="{{ route('panduan.index') }}" class="back-nav">
            <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Kembali ke Pusat Panduan</span>
        </a>
        <div class="brand-badge">
            <svg style="width:14px;height:14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/></svg>
            <span>Laboratorium Jaringan Komputer TI Unimal</span>
        </div>
    </header>

    <div class="main-container">
        <!-- Hero Banner -->
        <div class="hero-banner">
            <div class="hero-tag">Modul Praktikum & SOP Jaringan</div>
            <h1>Panduan Perakitan & Crimping Kabel LAN UTP (RJ-45)</h1>
            <p>Pelajari anatomi konektor 8P8C (RJ-45), susunan urutan 8 inti kawat berdasarkan standar internasional EIA/TIA 568A & 568B, perbedaan tipe Straight vs Crossover, serta interaksi 3D langsung untuk mempermudah pemahaman praktikum.</p>
        </div>

        <!-- 3D Interactive Viewer Card -->
        <div class="viewer-card">
            <div class="viewer-header">
                <div class="viewer-title">
                    <div class="icon-cube">
                        <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1v-2.5M18 18l2-1v-2.5"/></svg>
                    </div>
                    <div>
                        <h2>Visualisasi Model 3D: Konektor RJ-45 & 8 Kawat UTP</h2>
                        <span>Klik & geser mouse / swipe untuk memutar model 360°, scroll untuk zoom</span>
                    </div>
                </div>

                <div class="controls-toolbar">
                    <button class="btn-view-toggle active" id="btn-t568b" onclick="switchStandard('T568B')">
                        <span>Standar T568B (Umum)</span>
                    </button>
                    <button class="btn-view-toggle" id="btn-t568a" onclick="switchStandard('T568A')">
                        <span>Standar T568A</span>
                    </button>
                    <button class="btn-view-toggle" id="btn-toggle-clip" onclick="toggleClip()">
                        <span id="clip-text">Buka Pengait Clip</span>
                    </button>
                </div>
            </div>

            <!-- Canvas Three.js -->
            <div class="canvas-wrapper" id="canvas-container">
                <div class="canvas-hud">
                    <div class="hud-badge">
                        <svg style="width:16px;height:16px;color:#34d399;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                        <span id="hud-standard-label">STANDAR T568B — STRAIGHT THROUGH</span>
                    </div>
                    <div class="hud-hint">Mode Rotasi Aktif &bull; Posisikan klip pengait menghadap bawah untuk membaca Pin 1 s/d Pin 8 dari kiri ke kanan</div>
                </div>

                <div class="canvas-actions">
                    <button class="canvas-btn" onclick="reset3DCamera()">
                        <svg style="width:14px;height:14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                        <span>Reset Posisi</span>
                    </button>
                    <button class="canvas-btn" onclick="toggleAutoRotate()">
                        <svg style="width:14px;height:14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                        <span id="rotate-label">Pause Putar Otomatis</span>
                    </button>
                </div>

                <canvas id="threejs-canvas"></canvas>
            </div>

            <!-- Color Sequence Strip -->
            <div class="color-sequence-strip">
                <div class="sequence-title">
                    <h4 id="sequence-heading">Urutan Pinout Kabel UTP (T568B — Standar Lab)</h4>
                    <span id="sequence-summary">Pin 1: Putih Oranye &bull; Pin 8: Cokelat</span>
                </div>

                <div class="pins-flex" id="pins-container">
                    <!-- Populated dynamically via JS -->
                </div>
            </div>
        </div>

        <!-- 2 Columns Information -->
        <div class="content-grid">
            <!-- Left Column: Standar Kabel & Perbedaan -->
            <div class="info-card">
                <h3>
                    <svg style="width:22px;height:22px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/></svg>
                    <span>Klasifikasi Tipe Sambungan Kabel LAN</span>
                </h3>

                <!-- Straight Through -->
                <div class="cable-type-box">
                    <div class="cable-type-header">
                        <span class="cable-type-title">1. Kabel Straight-Through</span>
                        <span class="badge-type badge-straight">T568B &mdash; T568B</span>
                    </div>
                    <p class="cable-type-desc">
                        Kedua ujung kabel menggunakan standar susunan yang sama (biasanya sama-sama <strong>T568B</strong>). Digunakan untuk menghubungkan <strong>dua perangkat yang berbeda jenis/layer</strong> dalam jaringan.
                    </p>
                    <ul class="use-case-list">
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Komputer PC / Laptop ke Switch / Hub</span>
                        </li>
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Router ke Switch / Access Point</span>
                        </li>
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Komputer ke Wall-Plate / Outlet LAN Dinding Lab</span>
                        </li>
                    </ul>
                </div>

                <!-- Crossover -->
                <div class="cable-type-box">
                    <div class="cable-type-header">
                        <span class="cable-type-title">2. Kabel Crossover</span>
                        <span class="badge-type badge-cross">T568A &mdash; T568B</span>
                    </div>
                    <p class="cable-type-desc">
                        Ujung pertama dirakit dengan standar <strong>T568A</strong>, sedangkan ujung lainnya dirakit dengan standar <strong>T568B</strong>. Menyilangkan jalur Transmit (TX) dan Receive (RX). Digunakan untuk <strong>dua perangkat sejenis</strong>.
                    </p>
                    <ul class="use-case-list">
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Komputer PC ke Komputer PC (Peer-to-Peer Direct)</span>
                        </li>
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Switch ke Switch (Kaskade tanpa fitur Auto-MDIX)</span>
                        </li>
                        <li>
                            <svg viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                            <span>Router ke Router (Port Ethernet)</span>
                        </li>
                    </ul>
                </div>

                <div style="background:#f1f5f9; border-radius:12px; padding:14px; font-size:12.5px; color:var(--gray-600); margin-top:10px;">
                    <strong>Catatan Teknologi Modern (Auto-MDIX):</strong> Sebagian besar kartu jaringan (NIC) dan Switch Gigabit modern sudah mendukung Auto-MDIX, yaitu kemampuan mendeteksi dan membalik sinyal TX/RX secara otomatis, sehingga kabel Straight dapat langsung dipakai untuk menghubungkan PC ke PC. Namun penguasaan crimping Crossover tetap wajib di kurikulum jaringan komputer dasar.
                </div>
            </div>

            <!-- Right Column: Langkah Pembuatan & Alat Kerja -->
            <div class="info-card">
                <h3>
                    <svg style="width:22px;height:22px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
                    <span>Alat Kerja & Langkah Crimping SOP</span>
                </h3>

                <div class="tool-grid">
                    <div class="tool-card">
                        <div class="tool-icon">✂️</div>
                        <span>Tang Crimping RJ-45</span>
                    </div>
                    <div class="tool-card">
                        <div class="tool-icon">🔌</div>
                        <span>Konektor RJ-45 (8P8C)</span>
                    </div>
                    <div class="tool-card">
                        <div class="tool-icon">🧵</div>
                        <span>Kabel UTP Cat5e / Cat6</span>
                    </div>
                    <div class="tool-card">
                        <div class="tool-icon">📟</div>
                        <span>LAN Cable Tester</span>
                    </div>
                </div>

                <div class="step-timeline" style="margin-top: 24px;">
                    <div class="step-item">
                        <div class="step-num">1</div>
                        <div class="step-body">
                            <h4>Kupas Jaket Luar Kabel (Outer Jacket)</h4>
                            <p>Gunakan pisau pengupas pada tang crimping sekitar 2 cm dari ujung kabel. Putar perlahan agar insulasi kawat tembaga di dalamnya tidak tergores/putus.</p>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-num">2</div>
                        <div class="step-body">
                            <h4>Urai dan Luruskan 4 Pasang Kawat (Untwist)</h4>
                            <p>Pisahkan lilitan 4 pasang kawat (Oranye, Hijau, Biru, Cokelat). Luruskan setiap inti kawat hingga tidak bergelombang agar mudah dimasukkan ke lubang konektor.</p>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-num">3</div>
                        <div class="step-body">
                            <h4>Urutkan Warna Berdasarkan Standar (T568B)</h4>
                            <p>Susun kawat secara sejajar dari kiri ke kanan: <strong>Putih Oranye, Oranye, Putih Hijau, Biru, Putih Biru, Hijau, Putih Cokelat, Cokelat</strong>.</p>
                            <div class="step-tip">Pastikan kawat tersusun rapat, pipih, dan tidak saling silang sebelum dipotong.</div>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-num">4</div>
                        <div class="step-body">
                            <h4>Potong Rata Ujung Kawat (~1.2 cm)</h4>
                            <p>Gunakan pisau potong tang crimping untuk memotong ujung kawat hingga benar-benar rata secara horizontal dengan panjang sisa sekitar 1.2 cm.</p>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-num">5</div>
                        <div class="step-body">
                            <h4>Masukkan Kawat ke Konektor RJ-45 & Crimping</h4>
                            <p>Posisikan klip konektor RJ-45 menghadap ke bawah. Dorong kawat masuk hingga seluruh tembaga menyentuh ujung pin emas. Masukkan ke slot tang crimping dan tekan kuat hingga berbunyi 'klik'.</p>
                            <div class="step-tip">Perhatikan dari samping: Kulit jaket luar kabel wajib ikut terjepit di dalam pengunci konektor untuk mencegah kabel mudah putus jika tertarik.</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Simulator Tester Pinout (Interactive Tester) -->
        <div class="tester-card">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">
                <div>
                    <h3 style="font-size:18px; font-weight:800; color:var(--gray-900);">Simulator LAN Cable Tester (Master & Remote)</h3>
                    <p style="font-size:13.5px; color:var(--gray-500); margin-top:4px;">Uji hasil rakitan Anda untuk memastikan koneksi 8 pin tersambung sempurna tanpa ada kawat tertukar atau terputus.</p>
                </div>
                <div>
                    <button class="btn-test-run" onclick="runTesterSimulation()">
                        ▶ Jalankan Uji Sinyal Tester
                    </button>
                </div>
            </div>

            <div class="tester-grid">
                <!-- Master Unit -->
                <div class="tester-unit">
                    <div class="unit-header">Master Unit (Tx)</div>
                    <div id="master-leds">
                        <!-- 8 LEDs generated via JS -->
                    </div>
                </div>

                <!-- Status indicator -->
                <div class="tester-status-panel">
                    <div style="font-size:24px;">⚡</div>
                    <div style="font-size:11px; font-weight:800; color:#38bdf8; letter-spacing:0.5px; text-transform:uppercase;" id="tester-pulse-text">STANDBY</div>
                    <div style="font-size:11px; color:#94a3b8;" id="tester-mode-text">Mode: Straight</div>
                </div>

                <!-- Remote Unit -->
                <div class="tester-unit">
                    <div class="unit-header">Remote Unit (Rx)</div>
                    <div id="remote-leds">
                        <!-- 8 LEDs generated via JS -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="page-footer">
        Laboratorium Teknik Informatika &bull; Fakultas Teknik Universitas Malikussaleh &bull; &copy; {{ date('Y') }} SmartLab
    </footer>

    <!-- Three.js Interactive 3D Model Script -->
    <script>
        // Data Standar Warna
        const colorData = {
            T568B: [
                { pin: 1, name: "Putih Oranye", hex: 0xff8c00, cssClass: "color-white-orange", desc: "Transmit (+)" },
                { pin: 2, name: "Oranye", hex: 0xe65100, cssClass: "color-orange", desc: "Transmit (-)" },
                { pin: 3, name: "Putih Hijau", hex: 0x4caf50, cssClass: "color-white-green", desc: "Receive (+)" },
                { pin: 4, name: "Biru", hex: 0x1976d2, cssClass: "color-blue", desc: "Telephony / Reserved" },
                { pin: 5, name: "Putih Biru", hex: 0x42a5f5, cssClass: "color-white-blue", desc: "Telephony / Reserved" },
                { pin: 6, name: "Hijau", hex: 0x2e7d32, cssClass: "color-green", desc: "Receive (-)" },
                { pin: 7, name: "Putih Cokelat", hex: 0x8d6e63, cssClass: "color-white-brown", desc: "PoE Power (+/-)" },
                { pin: 8, name: "Cokelat", hex: 0x4e342e, cssClass: "color-brown", desc: "PoE Power (+/-)" }
            ],
            T568A: [
                { pin: 1, name: "Putih Hijau", hex: 0x4caf50, cssClass: "color-white-green", desc: "Transmit (+)" },
                { pin: 2, name: "Hijau", hex: 0x2e7d32, cssClass: "color-green", desc: "Transmit (-)" },
                { pin: 3, name: "Putih Oranye", hex: 0xff8c00, cssClass: "color-white-orange", desc: "Receive (+)" },
                { pin: 4, name: "Biru", hex: 0x1976d2, cssClass: "color-blue", desc: "Telephony / Reserved" },
                { pin: 5, name: "Putih Biru", hex: 0x42a5f5, cssClass: "color-white-blue", desc: "Telephony / Reserved" },
                { pin: 6, name: "Oranye", hex: 0xe65100, cssClass: "color-orange", desc: "Receive (-)" },
                { pin: 7, name: "Putih Cokelat", hex: 0x8d6e63, cssClass: "color-white-brown", desc: "PoE Power (+/-)" },
                { pin: 8, name: "Cokelat", hex: 0x4e342e, cssClass: "color-brown", desc: "PoE Power (+/-)" }
            ]
        };

        let currentStandard = 'T568B';
        let scene, camera, renderer, controls;
        let wireMeshes = [];
        let rj45Group;
        let clipMesh = null;
        let isClipOpen = false;
        let isAutoRotate = true;

        function initThreeJS() {
            const container = document.getElementById('canvas-container');
            const width = container.clientWidth;
            const height = container.clientHeight;

            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x0f172a);

            // Lighting
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
            scene.add(ambientLight);

            const dirLight1 = new THREE.DirectionalLight(0xffffff, 0.8);
            dirLight1.position.set(10, 20, 15);
            scene.add(dirLight1);

            const dirLight2 = new THREE.DirectionalLight(0x38bdf8, 0.4);
            dirLight2.position.set(-10, -10, -10);
            scene.add(dirLight2);

            const pointLight = new THREE.PointLight(0xffffff, 0.6, 50);
            pointLight.position.set(0, 5, 10);
            scene.add(pointLight);

            // Camera
            camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
            camera.position.set(0, 4.5, 12);

            // Renderer
            renderer = new THREE.WebGLRenderer({ canvas: document.getElementById('threejs-canvas'), antialias: true, alpha: true });
            renderer.setSize(width, height);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            renderer.shadowMap.enabled = true;

            // Controls
            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.maxDistance = 25;
            controls.minDistance = 3;
            controls.autoRotate = isAutoRotate;
            controls.autoRotateSpeed = 1.2;

            // Build 3D Model
            createRJ45Model();

            // Animate Loop
            function animate() {
                requestAnimationFrame(animate);
                controls.update();
                renderer.render(scene, camera);
            }
            animate();

            // Window resize handler
            window.addEventListener('resize', onWindowResize);
        }

        function createRJ45Model() {
            rj45Group = new THREE.Group();

            // 1. Transparent Clear Polycarbonate Body
            const bodyGeo = new THREE.BoxGeometry(4.2, 2.2, 6.5);
            const bodyMat = new THREE.MeshPhysicalMaterial({
                color: 0xffffff,
                transparent: true,
                opacity: 0.42,
                roughness: 0.1,
                transmission: 0.9,
                thickness: 1.2,
                clearcoat: 1.0,
                clearcoatRoughness: 0.1,
                reflectivity: 0.8
            });
            const bodyMesh = new THREE.Mesh(bodyGeo, bodyMat);
            bodyMesh.position.set(0, 0, 0);
            rj45Group.add(bodyMesh);

            // 2. RJ-45 Front Lip / Latch guide
            const frontLipGeo = new THREE.BoxGeometry(3.8, 1.8, 1.2);
            const frontLipMat = new THREE.MeshPhysicalMaterial({
                color: 0x93c5fd,
                transparent: true,
                opacity: 0.35,
                roughness: 0.2
            });
            const frontLipMesh = new THREE.Mesh(frontLipGeo, frontLipMat);
            frontLipMesh.position.set(0, 0, 3.8);
            rj45Group.add(frontLipMesh);

            // 3. Flexible Locking Clip (Pengait)
            const clipGeo = new THREE.BoxGeometry(1.4, 0.4, 4.0);
            const clipMat = new THREE.MeshPhysicalMaterial({
                color: 0xdbeafe,
                transparent: true,
                opacity: 0.65,
                roughness: 0.15
            });
            clipMesh = new THREE.Mesh(clipGeo, clipMat);
            clipMesh.position.set(0, 1.4, -0.6);
            clipMesh.rotation.x = -0.15;
            rj45Group.add(clipMesh);

            // 4. Gold Pins (8 Pins Contacts on top front)
            const pinGeo = new THREE.BoxGeometry(0.2, 0.35, 1.4);
            const pinMat = new THREE.MeshStandardMaterial({
                color: 0xf59e0b,
                metalness: 0.9,
                roughness: 0.2
            });

            const startX = -1.55;
            const stepX = 0.44;

            for (let i = 0; i < 8; i++) {
                const p = new THREE.Mesh(pinGeo, pinMat);
                p.position.set(startX + (i * stepX), 0.9, 2.6);
                rj45Group.add(p);
            }

            // 5. Cable Outer Blue Jacket (Cat5e / Cat6)
            const jacketGeo = new THREE.CylinderGeometry(1.6, 1.6, 6, 32);
            const jacketMat = new THREE.MeshStandardMaterial({
                color: 0x1d4ed8,
                roughness: 0.4,
                metalness: 0.1
            });
            const jacketMesh = new THREE.Mesh(jacketGeo, jacketMat);
            jacketMesh.rotation.x = Math.PI / 2;
            jacketMesh.position.set(0, 0, -5.5);
            rj45Group.add(jacketMesh);

            // 6. The 8 Internal Twisted-Pair Wires
            wireMeshes = [];
            const wireRadius = 0.14;
            const wireLength = 4.8;
            const currentColors = colorData[currentStandard];

            for (let i = 0; i < 8; i++) {
                const wireGeo = new THREE.CylinderGeometry(wireRadius, wireRadius, wireLength, 24);
                const wireMat = new THREE.MeshStandardMaterial({
                    color: currentColors[i].hex,
                    roughness: 0.3,
                    metalness: 0.15
                });
                const wireMesh = new THREE.Mesh(wireGeo, wireMat);
                wireMesh.rotation.x = Math.PI / 2;
                wireMesh.position.set(startX + (i * stepX), 0.1, 0.4);
                rj45Group.add(wireMesh);
                wireMeshes.push(wireMesh);
            }

            scene.add(rj45Group);
        }

        function updateWireColors() {
            const currentColors = colorData[currentStandard];
            for (let i = 0; i < 8; i++) {
                if (wireMeshes[i]) {
                    wireMeshes[i].material.color.setHex(currentColors[i].hex);
                }
            }
        }

        function renderColorPills() {
            const container = document.getElementById('pins-container');
            container.innerHTML = '';
            const list = colorData[currentStandard];

            list.forEach((item, index) => {
                const pill = document.createElement('div');
                pill.className = `pin-pill`;
                pill.onclick = () => highlightPin(index);
                pill.innerHTML = `
                    <span class="pin-number">Pin ${item.pin}</span>
                    <div class="pin-swatch ${item.cssClass}"></div>
                    <span class="pin-name">${item.name}</span>
                `;
                container.appendChild(pill);
            });

            // Update headings
            if (currentStandard === 'T568B') {
                document.getElementById('sequence-heading').innerText = 'Urutan Pinout Kabel UTP (T568B — Standar Lab TI Unimal)';
                document.getElementById('sequence-summary').innerText = 'Pin 1: Putih Oranye • Pin 2: Oranye • Pin 3: Putih Hijau • Pin 6: Hijau';
                document.getElementById('hud-standard-label').innerText = 'STANDAR T568B — STRAIGHT THROUGH';
                document.getElementById('tester-mode-text').innerText = 'Mode: Straight (T568B)';
            } else {
                document.getElementById('sequence-heading').innerText = 'Urutan Pinout Kabel UTP (T568A — Standar Alternatif)';
                document.getElementById('sequence-summary').innerText = 'Pin 1: Putih Hijau • Pin 2: Hijau • Pin 3: Putih Oranye • Pin 6: Oranye';
                document.getElementById('hud-standard-label').innerText = 'STANDAR T568A — CROSSOVER PAIR';
                document.getElementById('tester-mode-text').innerText = 'Mode: Crossover (T568A)';
            }
        }

        function switchStandard(standard) {
            currentStandard = standard;
            document.getElementById('btn-t568b').classList.toggle('active', standard === 'T568B');
            document.getElementById('btn-t568a').classList.toggle('active', standard === 'T568A');
            updateWireColors();
            renderColorPills();
        }

        function toggleClip() {
            isClipOpen = !isClipOpen;
            if (clipMesh) {
                clipMesh.rotation.x = isClipOpen ? 0.35 : -0.15;
                document.getElementById('clip-text').innerText = isClipOpen ? 'Kunci Pengait Clip' : 'Buka Pengait Clip';
            }
        }

        function reset3DCamera() {
            camera.position.set(0, 4.5, 12);
            controls.target.set(0, 0, 0);
            controls.update();
        }

        function toggleAutoRotate() {
            isAutoRotate = !isAutoRotate;
            controls.autoRotate = isAutoRotate;
            document.getElementById('rotate-label').innerText = isAutoRotate ? 'Pause Putar Otomatis' : 'Aktifkan Putar Otomatis';
        }

        function highlightPin(index) {
            // Pulse wire mesh in 3D
            if (wireMeshes[index]) {
                const originalScale = wireMeshes[index].scale.x;
                wireMeshes[index].scale.set(1.4, 1.0, 1.4);
                setTimeout(() => {
                    wireMeshes[index].scale.set(1, 1, 1);
                }, 400);
            }

            // Visual active pill
            const pills = document.querySelectorAll('.pin-pill');
            pills.forEach((p, idx) => {
                p.classList.toggle('active', idx === index);
            });
        }

        function onWindowResize() {
            const container = document.getElementById('canvas-container');
            if (!container) return;
            const width = container.clientWidth;
            const height = container.clientHeight;
            camera.aspect = width / height;
            camera.updateProjectionMatrix();
            renderer.setSize(width, height);
        }

        // ==========================================
        // Cable Tester Simulation
        // ==========================================
        function initTesterUI() {
            const masterContainer = document.getElementById('master-leds');
            const remoteContainer = document.getElementById('remote-leds');
            masterContainer.innerHTML = '';
            remoteContainer.innerHTML = '';

            for (let i = 1; i <= 8; i++) {
                masterContainer.innerHTML += `
                    <div class="led-row" id="row-m-${i}">
                        <span class="led-num">PIN ${i}</span>
                        <div class="led-light" id="led-m-${i}"></div>
                    </div>
                `;

                remoteContainer.innerHTML += `
                    <div class="led-row" id="row-r-${i}">
                        <div class="led-light" id="led-r-${i}"></div>
                        <span class="led-num">PIN ${i}</span>
                    </div>
                `;
            }
        }

        let isTesting = false;
        function runTesterSimulation() {
            if (isTesting) return;
            isTesting = true;
            const pulseText = document.getElementById('tester-pulse-text');
            pulseText.innerText = "TESTING...";
            pulseText.style.color = "#22c55e";

            // Cross map: jika T568A pada remote kabel crossover: pin 1->3, 2->6, 3->1, 6->2
            const isCross = (currentStandard === 'T568A');
            const crossMap = { 1: 3, 2: 6, 3: 1, 4: 4, 5: 5, 6: 2, 7: 7, 8: 8 };

            let currentStep = 1;

            const interval = setInterval(() => {
                // Clear previous lights
                for (let k = 1; k <= 8; k++) {
                    const lm = document.getElementById(`led-m-${k}`);
                    const lr = document.getElementById(`led-r-${k}`);
                    if (lm) lm.className = 'led-light';
                    if (lr) lr.className = 'led-light';
                }

                if (currentStep <= 8) {
                    const masterLed = document.getElementById(`led-m-${currentStep}`);
                    const remotePinTarget = isCross ? crossMap[currentStep] : currentStep;
                    const remoteLed = document.getElementById(`led-r-${remotePinTarget}`);

                    if (masterLed) masterLed.className = 'led-light active-green';
                    if (remoteLed) remoteLed.className = isCross ? 'led-light active-yellow' : 'led-light active-green';

                    // Highlight pin on bottom bar
                    highlightPin(currentStep - 1);

                    currentStep++;
                } else {
                    clearInterval(interval);
                    isTesting = false;
                    pulseText.innerText = isCross ? "PASSED (CROSSOVER)" : "PASSED (STRAIGHT)";
                    pulseText.style.color = isCross ? "#eab308" : "#22c55e";

                    // Final green blink
                    setTimeout(() => {
                        for (let k = 1; k <= 8; k++) {
                            const lm = document.getElementById(`led-m-${k}`);
                            const lr = document.getElementById(`led-r-${k}`);
                            if (lm) lm.className = 'led-light active-green';
                            if (lr) lr.className = isCross ? 'led-light active-yellow' : 'led-light active-green';
                        }
                    }, 300);
                }
            }, 350);
        }

        // Initialize on Load
        document.addEventListener('DOMContentLoaded', () => {
            initThreeJS();
            renderColorPills();
            initTesterUI();
        });
    </script>
</body>
</html>
