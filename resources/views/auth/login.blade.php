<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — LabControl Unimal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --unimal-green: #009344;
            --unimal-green-dark: #007033;
            --unimal-green-light: #e6f7ee;
            --unimal-gold: #E2A313;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-400: #94a3b8;
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
            background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 50%, #fefce8 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .login-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--gray-200);
            width: 100%;
            max-width: 440px;
            padding: 40px;
        }

        .brand-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .brand-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, var(--unimal-green) 0%, var(--unimal-green-dark) 100%);
            border-radius: 16px;
            color: #ffffff;
            font-size: 26px;
            font-weight: 800;
            margin-bottom: 16px;
            box-shadow: 0 8px 16px rgba(0, 147, 68, 0.25);
            position: relative;
        }

        .brand-badge::after {
            content: '';
            position: absolute;
            bottom: 6px;
            right: 6px;
            width: 12px;
            height: 12px;
            background: var(--unimal-gold);
            border-radius: 50%;
            border: 2px solid #ffffff;
        }

        .brand-header h1 {
            font-size: 22px;
            font-weight: 800;
            color: var(--gray-900);
            letter-spacing: -0.5px;
        }

        .brand-header p {
            font-size: 13px;
            color: var(--gray-500);
            margin-top: 4px;
            font-weight: 500;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--gray-700);
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            padding: 12px 16px;
            font-size: 14px;
            border: 1px solid var(--gray-300);
            border-radius: 10px;
            outline: none;
            transition: all 0.2s;
        }

        .form-control:focus {
            border-color: var(--unimal-green);
            box-shadow: 0 0 0 3px rgba(0, 147, 68, 0.15);
        }

        .remember-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            font-size: 13px;
            color: var(--gray-600);
        }

        .remember-label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }

        .btn-submit {
            width: 100%;
            padding: 13px;
            background: var(--unimal-green);
            color: #ffffff;
            font-size: 14.5px;
            font-weight: 700;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 12px rgba(0, 147, 68, 0.2);
        }

        .btn-submit:hover {
            background: var(--unimal-green-dark);
            box-shadow: 0 6px 16px rgba(0, 147, 68, 0.3);
        }

        .alert-error {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
            border: 1px solid #fecaca;
        }

        .demo-accounts {
            margin-top: 28px;
            padding: 14px;
            background: var(--gray-50);
            border-radius: 10px;
            border: 1px dashed var(--gray-300);
            font-size: 11.5px;
            color: var(--gray-600);
        }

        .demo-accounts strong {
            color: var(--gray-900);
        }

        .demo-account-item {
            display: flex;
            justify-content: space-between;
            margin-top: 6px;
            padding-top: 6px;
            border-top: 1px solid var(--gray-200);
        }

        .copy-link {
            color: var(--unimal-green);
            text-decoration: none;
            cursor: pointer;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="brand-header">
            <div class="brand-badge">L</div>
            <h1>LabControl Unimal</h1>
            <p>Sistem Manajemen Laboratorium TI Malikussaleh</p>
        </div>

        @if($errors->any())
            <div class="alert-error">
                {{ $errors->first() }}
            </div>
        @endif

        <form action="{{ route('login') }}" method="POST">
            @csrf

            <div class="form-group">
                <label class="form-label" for="email">Alamat Email</label>
                <input type="email" id="email" name="email" class="form-control" value="{{ old('email', 'aslab@unimal.ac.id') }}" required autofocus placeholder="nama@unimal.ac.id">
            </div>

            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" value="password123" required placeholder="••••••••">
            </div>

            <div class="remember-row">
                <label class="remember-label">
                    <input type="checkbox" name="remember" value="1" checked>
                    <span>Ingat sesi saya</span>
                </label>
            </div>

            <button type="submit" class="btn-submit">Masuk ke Dashboard</button>
        </form>

        <div class="demo-accounts">
            <strong>Akun Bawaan (Default):</strong>
            <div class="demo-account-item">
                <span>Super Admin: <code>admin@unimal.ac.id</code></span>
                <span class="copy-link" onclick="fillForm('admin@unimal.ac.id')">Isi</span>
            </div>
            <div class="demo-account-item">
                <span>ASLAB: <code>aslab@unimal.ac.id</code></span>
                <span class="copy-link" onclick="fillForm('aslab@unimal.ac.id')">Isi</span>
            </div>
            <div style="margin-top: 4px; font-size: 10.5px; color: var(--gray-400);">Password: <code>password123</code></div>
        </div>
    </div>

    <script>
        function fillForm(email) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = 'password123';
        }
    </script>
</body>
</html>
