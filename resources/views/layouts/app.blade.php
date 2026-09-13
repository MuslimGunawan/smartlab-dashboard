<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Dashboard') — LabControl Unimal</title>
    
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
            --dark-bg: #0f172a;
            --dark-surface: #1e293b;
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
            --danger: #ef4444;
            --danger-light: #fee2e2;
            --success: #10b981;
            --radius-md: 10px;
            --radius-lg: 16px;
            --radius-xl: 20px;
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
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
            background-color: var(--gray-50);
            color: var(--gray-800);
            min-height: 100vh;
            display: flex;
        }

        /* Sidebar */
        aside.sidebar {
            width: 270px;
            background: #ffffff;
            border-right: 1px solid var(--gray-200);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 50;
            transition: all 0.3s ease;
        }

        .sidebar-brand {
            padding: 24px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid var(--gray-100);
        }

        .brand-icon {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, var(--unimal-green) 0%, var(--unimal-green-dark) 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-weight: 800;
            font-size: 20px;
            box-shadow: 0 4px 10px rgba(0, 147, 68, 0.25);
            position: relative;
        }

        .brand-icon::after {
            content: '';
            position: absolute;
            bottom: 4px;
            right: 4px;
            width: 9px;
            height: 9px;
            background-color: var(--unimal-gold);
            border-radius: 50%;
            border: 2px solid #ffffff;
        }

        .brand-text h1 {
            font-size: 16px;
            font-weight: 800;
            color: var(--gray-900);
            letter-spacing: -0.3px;
        }

        .brand-text p {
            font-size: 11px;
            color: var(--gray-500);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .sidebar-nav {
            padding: 20px 14px;
            flex: 1;
            overflow-y: auto;
        }

        .nav-label {
            font-size: 11px;
            font-weight: 700;
            color: var(--gray-400);
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin: 14px 10px 8px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 14px;
            border-radius: var(--radius-md);
            color: var(--gray-600);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 4px;
            transition: all 0.2s ease;
        }

        .nav-item:hover {
            background-color: var(--gray-100);
            color: var(--gray-900);
        }

        .nav-item.active {
            background-color: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            font-weight: 700;
        }

        .nav-item svg {
            width: 20px;
            height: 20px;
            stroke-width: 2;
        }

        .sidebar-footer {
            padding: 16px;
            border-top: 1px solid var(--gray-200);
            background: #ffffff;
        }

        .user-card {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px;
            border-radius: var(--radius-md);
            background: var(--gray-50);
        }

        .user-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--unimal-gold-light);
            color: var(--unimal-gold);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
            border: 2px solid rgba(226, 163, 19, 0.3);
        }

        .user-info {
            flex: 1;
            min-width: 0;
        }

        .user-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--gray-900);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-role {
            font-size: 11px;
            color: var(--unimal-green);
            font-weight: 600;
            text-transform: capitalize;
        }

        /* Main Content */
        main.main-content {
            margin-left: 270px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        header.topbar {
            height: 70px;
            background: #ffffff;
            border-bottom: 1px solid var(--gray-200);
            padding: 0 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 40;
        }

        .topbar-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--gray-900);
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .live-status-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: #ffffff;
            border: 1px solid var(--gray-200);
            border-radius: 30px;
            font-size: 12px;
            font-weight: 600;
            color: var(--gray-700);
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--success);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); }
            70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .content-body {
            padding: 32px;
            flex: 1;
        }

        /* Buttons & Forms */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 9px 18px;
            font-size: 13.5px;
            font-weight: 600;
            border-radius: var(--radius-md);
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background-color: var(--unimal-green);
            color: #ffffff;
        }

        .btn-primary:hover {
            background-color: var(--unimal-green-dark);
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.25);
        }

        .btn-gold {
            background-color: var(--unimal-gold);
            color: #ffffff;
        }

        .btn-gold:hover {
            background-color: #cb9210;
        }

        .btn-secondary {
            background-color: var(--gray-100);
            color: var(--gray-700);
        }

        .btn-secondary:hover {
            background-color: var(--gray-200);
            color: var(--gray-900);
        }

        .btn-danger {
            background-color: var(--danger);
            color: #ffffff;
        }

        .btn-danger:hover {
            background-color: #dc2626;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 8px;
        }

        /* Cards & Grid */
        .card {
            background: #ffffff;
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-sm);
        }

        .badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 700;
        }

        .badge-online {
            background: var(--unimal-green-light);
            color: var(--unimal-green-dark);
        }

        .badge-offline {
            background: var(--gray-200);
            color: var(--gray-600);
        }

        .badge-pending {
            background: var(--unimal-gold-light);
            color: #b45309;
        }

        .badge-executed {
            background: #dcfce7;
            color: #15803d;
        }

        .badge-failed {
            background: var(--danger-light);
            color: #b91c1c;
        }

        /* Alert Notifications */
        .alert {
            padding: 14px 18px;
            border-radius: var(--radius-md);
            margin-bottom: 24px;
            font-size: 13.5px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .alert-success {
            background-color: var(--unimal-green-light);
            color: var(--unimal-green-dark);
            border: 1px solid rgba(0, 147, 68, 0.2);
        }

        .alert-error {
            background-color: var(--danger-light);
            color: #b91c1c;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        /* Tables */
        table.data-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        table.data-table th {
            padding: 12px 16px;
            background: var(--gray-50);
            color: var(--gray-500);
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--gray-200);
        }

        table.data-table td {
            padding: 14px 16px;
            font-size: 13px;
            color: var(--gray-700);
            border-bottom: 1px solid var(--gray-100);
        }

        table.data-table tr:hover td {
            background: #fafafa;
        }

        /* Modal */
        .modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 100;
        }

        .modal-backdrop.active {
            display: flex;
        }

        .modal-box {
            background: #ffffff;
            border-radius: var(--radius-xl);
            width: 100%;
            max-width: 500px;
            padding: 28px;
            box-shadow: var(--shadow-lg);
            animation: modalFadeIn 0.2s ease;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.96); }
            to { opacity: 1; transform: scale(1); }
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
            padding: 10px 14px;
            font-size: 13.5px;
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-md);
            outline: none;
            transition: all 0.2s;
        }

        .form-control:focus {
            border-color: var(--unimal-green);
            box-shadow: 0 0 0 3px rgba(0, 147, 68, 0.15);
        }
    </style>
    @yield('styles')
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="brand-icon">S</div>
            <div class="brand-text">
                <h1>SmartLab</h1>
                <p>TI Unimal</p>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-label">Menu Utama</div>
            <a href="{{ route('dashboard') }}" class="nav-item {{ request()->routeIs('dashboard*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                <span>Dashboard</span>
            </a>
            <a href="{{ route('labs.index') }}" class="nav-item {{ request()->routeIs('labs*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                <span>Ruangan Lab</span>
            </a>
            <a href="{{ route('computers.index') }}" class="nav-item {{ request()->routeIs('computers*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                <span>Komputer Lab</span>
            </a>

            <div class="nav-label">Otomasi & Kontrol</div>
            <a href="{{ route('schedules.index') }}" class="nav-item {{ request()->routeIs('schedules*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <span>Jadwal Otomatis</span>
            </a>
            <a href="{{ route('kiosk.index') }}" class="nav-item {{ request()->routeIs('kiosk*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                <span>Kiosk Mode</span>
            </a>
            <a href="{{ route('blocklist.index') }}" class="nav-item {{ request()->routeIs('blocklist*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/></svg>
                <span>Aplikasi Terlarang</span>
            </a>

            <div class="nav-label">Monitoring & Log</div>
            <a href="{{ route('issues.index') }}" class="nav-item {{ request()->routeIs('issues*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                <span>Kendala Meja / PC</span>
                @php $pendingCount = \App\Models\IssueReport::where('status', 'pending')->count(); @endphp
                @if($pendingCount > 0)
                    <span style="margin-left: auto; background: #ef4444; color: #fff; font-size: 10px; font-weight: 800; padding: 2px 6px; border-radius: 9999px;">{{ $pendingCount }}</span>
                @endif
            </a>
            <a href="{{ route('violations.index') }}" class="nav-item {{ request()->routeIs('violations*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/></svg>
                <span>Insiden Pelanggaran</span>
            </a>
            <a href="{{ route('reports.monthly') }}" class="nav-item {{ request()->routeIs('reports*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                <span>Laporan Bulanan</span>
            </a>
            <a href="{{ route('audit-logs.index') }}" class="nav-item {{ request()->routeIs('audit-logs*') ? 'active' : '' }}">
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                <span>Riwayat & Audit Log</span>
            </a>

            @if(auth()->user()->isSenior())
                <div class="nav-label">Administrasi</div>
                @if(auth()->user()->isSuperAdmin())
                    <a href="{{ route('users.index') }}" class="nav-item {{ request()->routeIs('users*') ? 'active' : '' }}">
                        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                        <span>Kelola Pengguna</span>
                    </a>
                @endif
                <a href="{{ route('settings.index') }}" class="nav-item {{ request()->routeIs('settings*') ? 'active' : '' }}">
                    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                    <span>Pengaturan & Alert</span>
                </a>
            @endif
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">{{ substr(auth()->user()->name ?? 'U', 0, 1) }}</div>
                <div class="user-info">
                    <div class="user-name">{{ auth()->user()->name ?? 'ASLAB User' }}</div>
                    <div class="user-role">{{ auth()->user()->role_badge ?? 'ASLAB' }}</div>
                </div>
                <form action="{{ route('logout') }}" method="POST" style="margin: 0;">
                    @csrf
                    <button type="submit" title="Logout" style="background:none; border:none; color:var(--gray-400); cursor:pointer; padding:6px; display:flex;">
                        <svg style="width:18px;height:18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <!-- Main Body -->
    <main class="main-content">
        <header class="topbar">
            <h2 class="topbar-title">@yield('page_title', 'Dashboard')</h2>
            <div class="topbar-right">
                <div class="live-status-pill">
                    <div class="status-dot"></div>
                    <span id="liveClock">{{ now()->translatedFormat('d M Y, H:i') }} WIB</span>
                </div>
                @yield('topbar_actions')
            </div>
        </header>

        <div class="content-body">
            @if(session('success'))
                <div class="alert alert-success">
                    <span>{{ session('success') }}</span>
                    <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer; font-size:16px;">&times;</button>
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-error">
                    <span>{{ session('error') }}</span>
                    <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer; font-size:16px;">&times;</button>
                </div>
            @endif

            @if($errors->any())
                <div class="alert alert-error">
                    <ul style="margin-left: 18px;">
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @yield('content')
        </div>
    </main>

    <!-- Global live feed refresher -->
    <script>
        function updateTime() {
            const now = new Date();
            const options = { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' };
            const clockEl = document.getElementById('liveClock');
            if (clockEl) {
                clockEl.innerText = now.toLocaleDateString('id-ID', options) + ' WIB';
            }
        }
        setInterval(updateTime, 1000);
    </script>
    @yield('scripts')
</body>
</html>
