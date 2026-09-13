<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lapor Kendala Komputer — SmartLab Unimal</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #007033;
            --unimal-green-light: #e6f7ee;
            --unimal-gold: #E2A313;
            --unimal-gold-light: #fef7e6;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-600: #475569;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gray-900: #0f172a;
            --radius-md: 10px;
            --radius-lg: 16px;
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.07), 0 2px 4px -2px rgb(0 0 0 / 0.07);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.08), 0 4px 6px -4px rgb(0 0 0 / 0.08);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
        }

        body {
            background-color: #f1f5f9;
            color: var(--gray-800);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px 16px 40px;
        }

        .header-brand {
            text-align: center;
            margin-bottom: 24px;
            max-width: 480px;
        }

        .brand-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #ffffff;
            padding: 6px 14px;
            border-radius: 9999px;
            box-shadow: var(--shadow-md);
            margin-bottom: 12px;
            border: 1px solid var(--gray-200);
        }

        .brand-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: var(--unimal-green);
        }

        .brand-badge span {
            font-size: 12px;
            font-weight: 700;
            color: var(--unimal-green-dark);
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .header-brand h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--gray-900);
            line-height: 1.3;
        }

        .header-brand p {
            font-size: 13px;
            color: var(--gray-600);
            margin-top: 4px;
        }

        .card-form {
            background: #ffffff;
            width: 100%;
            max-width: 480px;
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-200);
        }

        .pc-info-banner {
            background: linear-gradient(135deg, var(--unimal-green-light) 0%, #f0fdf4 100%);
            border: 1px solid rgba(0, 147, 68, 0.2);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .pc-info-left h3 {
            font-size: 15px;
            font-weight: 800;
            color: var(--unimal-green-dark);
        }

        .pc-info-left p {
            font-size: 12px;
            color: var(--gray-600);
            font-weight: 500;
        }

        .status-pill {
            background: #ffffff;
            color: var(--unimal-green-dark);
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 9999px;
            border: 1px solid rgba(0, 147, 68, 0.2);
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-label {
            display: block;
            font-size: 12.5px;
            font-weight: 700;
            color: var(--gray-700);
            margin-bottom: 6px;
        }

        .form-control {
            width: 100%;
            padding: 11px 14px;
            font-size: 14px;
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-md);
            outline: none;
            transition: all 0.2s;
            background: #ffffff;
        }

        .form-control:focus {
            border-color: var(--unimal-green);
            box-shadow: 0 0 0 3px rgba(0, 147, 68, 0.15);
        }

        select.form-control {
            cursor: pointer;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 90px;
        }

        .btn-submit {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, var(--unimal-green) 0%, var(--unimal-green-dark) 100%);
            color: #ffffff;
            border: none;
            border-radius: var(--radius-md);
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.25);
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 8px;
        }

        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(0, 147, 68, 0.35);
        }

        .footer-text {
            text-align: center;
            font-size: 11.5px;
            color: var(--gray-600);
            margin-top: 24px;
        }
    </style>
</head>
<body>

    <div class="header-brand">
        <div class="brand-badge">
            <div class="brand-dot"></div>
            <span>SmartLab TI Unimal</span>
        </div>
        <h1>Lapor Kendala Perangkat</h1>
        <p>Sampaikan masalah hardware/software di meja praktikum ini agar dapat segera ditangani oleh tim ASLAB.</p>
    </div>

    <div class="card-form">
        <!-- Informasi PC Otomatis Terdeteksi -->
        <div class="pc-info-banner">
            <div class="pc-info-left">
                <h3>{{ $computer->nama_pc }}</h3>
                <p>{{ $computer->lab ? $computer->lab->nama_lab : 'Laboratorium TI' }} • {{ $computer->ip_terakhir ?: 'Local PC' }}</p>
            </div>
            <div class="status-pill">Meja Terverifikasi</div>
        </div>

        @if($errors->any())
            <div style="background:#fee2e2; border:1px solid rgba(239,68,68,0.3); color:#b91c1c; padding:12px 14px; border-radius:var(--radius-md); margin-bottom:16px; font-size:13px;">
                <strong>Perhatian:</strong>
                <ul style="margin-left: 18px; margin-top: 4px;">
                    @foreach($errors->all() as $err)
                        <li>{{ $err }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('report-issue.store', $computer->device_token) }}" method="POST">
            @csrf

            <div class="form-group">
                <label class="form-label" for="reporter_name">Nama Lengkap Praktikan / Pelapor <span style="color:#ef4444;">*</span></label>
                <input type="text" id="reporter_name" name="reporter_name" class="form-control" placeholder="Contoh: Muslim Gunawan" value="{{ old('reporter_name') }}" required>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label" for="reporter_nim">NIM</label>
                    <input type="text" id="reporter_nim" name="reporter_nim" class="form-control" placeholder="220180xxx" value="{{ old('reporter_nim') }}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="reporter_contact">No. WhatsApp / HP</label>
                    <input type="text" id="reporter_contact" name="reporter_contact" class="form-control" placeholder="08xxxxxxxxxx" value="{{ old('reporter_contact') }}">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="category">Kategori Kendala <span style="color:#ef4444;">*</span></label>
                <select id="category" name="category" class="form-control" required>
                    <option value="" disabled {{ old('category') ? '' : 'selected' }}>-- Pilih Bagian yang Bermasalah --</option>
                    <option value="mouse" {{ old('category') == 'mouse' ? 'selected' : '' }}>🖱️ Mouse / Pointer (Macet/Klik Rusak)</option>
                    <option value="keyboard" {{ old('category') == 'keyboard' ? 'selected' : '' }}>⌨️ Keyboard (Tombol Tidak Merespons)</option>
                    <option value="monitor" {{ old('category') == 'monitor' ? 'selected' : '' }}>🖥️ Monitor / Layar (Mati/Garis/Buram)</option>
                    <option value="pc_hang" {{ old('category') == 'pc_hang' ? 'selected' : '' }}>⚡ PC Hang / Sangat Lambat / Sering Mati</option>
                    <option value="network" {{ old('category') == 'network' ? 'selected' : '' }}>🌐 Koneksi Internet / Jaringan LAN Putus</option>
                    <option value="software" {{ old('category') == 'software' ? 'selected' : '' }}>📦 Software Praktikum Tidak Berfungsi</option>
                    <option value="other" {{ old('category') == 'other' ? 'selected' : '' }}>🔧 Lainnya (Kabel, Meja, Kursi, Headset)</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="description">Detail Kendala / Gejala Kerusakan <span style="color:#ef4444;">*</span></label>
                <textarea id="description" name="description" class="form-control" placeholder="Jelaskan secara singkat apa yang terjadi (misal: tombol spasi tidak bisa ditekan, atau kabel monitor kendor)..." required>{{ old('description') }}</textarea>
            </div>

            <button type="submit" class="btn-submit">
                <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
                <span>Kirim Laporan Kerusakan</span>
            </button>
        </form>
    </div>

    <div class="footer-text">
        Laboratorium Teknik Informatika • Universitas Malikussaleh<br>
        Sistem Terintegrasi SmartLab Unimal
    </div>

</body>
</html>
