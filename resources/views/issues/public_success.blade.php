<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporan Terkirim — SmartLab Unimal</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #007033;
            --unimal-green-light: #e6f7ee;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-600: #475569;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gray-900: #0f172a;
            --radius-md: 10px;
            --radius-lg: 16px;
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.08);
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
            justify-content: center;
            padding: 20px 16px;
        }

        .card-success {
            background: #ffffff;
            width: 100%;
            max-width: 440px;
            border-radius: var(--radius-lg);
            padding: 36px 24px;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-200);
            text-align: center;
        }

        .success-icon {
            width: 64px;
            height: 64px;
            background: var(--unimal-green-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: var(--unimal-green);
        }

        h1 {
            font-size: 20px;
            font-weight: 800;
            color: var(--gray-900);
            margin-bottom: 8px;
        }

        p {
            font-size: 13.5px;
            color: var(--gray-600);
            line-height: 1.5;
            margin-bottom: 24px;
        }

        .ticket-box {
            background: var(--gray-100);
            border: 1px dashed var(--gray-300);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            margin-bottom: 24px;
            text-align: left;
        }

        .ticket-row {
            display: flex;
            justify-content: space-between;
            font-size: 12.5px;
            padding: 4px 0;
        }

        .ticket-row .label {
            color: var(--gray-600);
        }

        .ticket-row .val {
            font-weight: 700;
            color: var(--gray-800);
        }

        .btn-back {
            display: inline-block;
            width: 100%;
            padding: 12px;
            background: var(--unimal-green);
            color: #ffffff;
            border-radius: var(--radius-md);
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-back:hover {
            background: var(--unimal-green-dark);
        }
    </style>
</head>
<body>

    <div class="card-success">
        <div class="success-icon">
            <svg style="width:36px;height:36px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>
        </div>

        <h1>Laporan Diterima!</h1>
        <p>Terima kasih atas laporan Anda. Informasi kerusakan telah tercatat dan tim ASLAB yang bertugas segera memeriksanya.</p>

        <div class="ticket-box">
            @if($issue)
                <div class="ticket-row">
                    <span class="label">ID Tiket:</span>
                    <span class="val">#{{ str_pad($issue->id, 5, '0', STR_PAD_LEFT) }}</span>
                </div>
                <div class="ticket-row">
                    <span class="label">Perangkat:</span>
                    <span class="val">{{ $computer->nama_pc }}</span>
                </div>
                <div class="ticket-row">
                    <span class="label">Ruangan:</span>
                    <span class="val">{{ $computer->lab ? $computer->lab->nama_lab : 'Lab TI' }}</span>
                </div>
                <div class="ticket-row">
                    <span class="label">Kategori:</span>
                    <span class="val">{{ $issue->category_label }}</span>
                </div>
                <div class="ticket-row">
                    <span class="label">Waktu:</span>
                    <span class="val">{{ $issue->created_at->translatedFormat('d M Y, H:i') }} WIB</span>
                </div>
            @else
                <div class="ticket-row">
                    <span class="label">Perangkat:</span>
                    <span class="val">{{ $computer->nama_pc }}</span>
                </div>
            @endif
        </div>

        <a href="{{ route('report-issue.create', $computer->device_token) }}" class="btn-back">Kirim Laporan Lain</a>
    </div>

</body>
</html>
