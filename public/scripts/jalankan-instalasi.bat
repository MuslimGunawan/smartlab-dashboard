@echo off
setlocal EnableDelayedExpansion
title Installer Otomatis Software Lab TI Unimal

:: ==============================================================================
:: 1. Cek & Minta Hak Akses Administrator Secara Otomatis
:: ==============================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Membutuhkan hak akses Administrator...
    echo Mengarahkan ke jendela Administrator (UAC elevation)...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo ==============================================================
echo   INSTALLER OTOMASI STANDARISASI SOFTWARE LAB TI - UNIMAL
echo ==============================================================
echo.

:: ==============================================================================
:: 2. Nonaktifkan Sementara Antivirus Defender & Buat Folder Exclusion
::    (Mencegah False Alarm pada installer berlisensi pihak ketiga / patch lab)
:: ==============================================================================
echo [1/3] Menyiapkan keamanan sistem (Mencegah False Alarm Antivirus)...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%~dp0' -ErrorAction SilentlyContinue; Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue" >nul 2>&1
echo   [OK] Folder flashdisk aman dari pemblokiran & karantina Windows Defender.
echo.

:: ==============================================================================
:: 3. Deteksi File Script PowerShell Otomasi di dalam Folder Apps
:: ==============================================================================
echo [2/3] Memeriksa script otomatisasi di dalam folder Apps...
set "PS_SCRIPT=%~dp0Apps\install-lab-software.ps1"
if not exist "%PS_SCRIPT%" (
    set "PS_SCRIPT=%~dp0install-lab-software.ps1"
)

:: Fitur Auto-Update: Sinkronisasi skrip otomatis dari Cloud SmartLab jika ada internet
echo   [SYNC] Memeriksa pembaruan skrip otomatis dari Cloud SmartLab...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$urls = @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1', 'http://smartlab.is-best.net/scripts/install-lab-software.ps1');" ^
    "$target = '%PS_SCRIPT%';" ^
    "$updated = $false;" ^
    "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;" ^
    "foreach ($url in $urls) {" ^
    "    try {" ^
    "        $req = [System.Net.HttpWebRequest]::Create($url);" ^
    "        $req.Timeout = 4000;" ^
    "        $req.UserAgent = 'SmartLab-Client/2.4';" ^
    "        $resp = $req.GetResponse();" ^
    "        if ($resp.StatusCode -eq 200) {" ^
    "            $stream = $resp.GetResponseStream();" ^
    "            $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8);" ^
    "            $latestContent = $reader.ReadToEnd();" ^
    "            $reader.Close(); $resp.Close();" ^
    "            if ($latestContent.Length -gt 5000 -and $latestContent -match 'Run-FullInstallation') {" ^
    "                [System.IO.File]::WriteAllText($target, $latestContent, [System.Text.Encoding]::UTF8);" ^
    "                Write-Host '  [OK] Skrip instalasi berhasil disinkronkan ke versi terbaru dari Cloud Lab!' -ForegroundColor Green;" ^
    "                $updated = $true; break;" ^
    "            }" ^
    "        }" ^
    "    } catch {}" ^
    "}" ^
    "if (-not $updated) {" ^
    "    Write-Host '  [i] Menggunakan skrip lokal di flashdisk (Mode Offline / Tanpa Internet).' -ForegroundColor Yellow;" ^
    "}"

if not exist "%PS_SCRIPT%" (
    echo.
    echo [X] PERINGATAN: File script tidak ditemukan!
    echo     Pastikan file install-lab-software.ps1 berada di dalam folder:
    echo     "%~dp0Apps\"
    echo.
    pause
    exit /b
)

echo   [OK] Script siap dijalankan: %PS_SCRIPT%
echo.

:: ==============================================================================
:: 4. Jalankan PowerShell Script dengan Bypass Policy
:: ==============================================================================
echo [3/3] Membuka antarmuka instalasi PowerShell...
echo ==============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

:: ==============================================================================
:: 5. Kembalikan Proteksi Real-Time Antivirus Setelah Selesai
:: ==============================================================================
echo.
echo ==============================================================
echo   SESI INSTALASI SELESAI
echo ==============================================================
echo Mengaktifkan kembali proteksi Real-Time Windows Defender...
powershell -NoProfile -Command "Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue" >nul 2>&1
echo [OK] Proteksi keamanan PC kembali aktif normal.
echo.
echo Tekan sembarang tombol untuk keluar...
pause >nul
