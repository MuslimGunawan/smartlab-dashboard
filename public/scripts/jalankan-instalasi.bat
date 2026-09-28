@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Installer Otomatis Software Lab TI - UNIMAL
color 0A

:: ============================================================
:: 1. Pastikan berjalan sebagai Administrator (UAC Elevation)
:: ============================================================
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo.
    echo ============================================================
    echo   MEMINTA HAK AKSES ADMINISTRATOR
    echo ============================================================
    echo.
    echo Silakan klik [YES] pada jendela konfirmasi User Account Control (UAC)...
    echo.

    powershell.exe -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"

    if errorlevel 1 (
        echo.
        echo [ERROR] Gagal meminta hak akses Administrator atau dibatalkan oleh pengguna.
        echo Klik kanan pada file ini lalu pilih 'Run as administrator'.
        echo.
        pause
    )
    exit /b
)

:: ============================================================
:: 2. Pindah ke direktori tempat file BAT ini berada
:: ============================================================
cd /d "%~dp0"

echo.
echo ============================================================
echo   INSTALLER OTOMASI STANDARISASI SOFTWARE LAB TI - UNIMAL
echo ============================================================
echo.
echo Lokasi Kerja: %CD%
echo.

:: ============================================================
:: 3. Amankan Folder dari Windows Defender (Cegah False Alarm)
:: ============================================================
echo [1/3] Menyiapkan keamanan sistem (Mencegah False Alarm Antivirus)...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%~dp0' -ErrorAction SilentlyContinue; Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue" >nul 2>&1
echo   [OK] Folder kerja aman dari pemblokiran & karantina Windows Defender.
echo.

:: ============================================================
:: 4. Cari Script PowerShell Otomasi
:: ============================================================
echo [2/3] Mendeteksi file script instalasi...

set "PS_SCRIPT=%~dp0Apps\install-lab-software.ps1"

if not exist "%PS_SCRIPT%" (
    set "PS_SCRIPT=%~dp0install-lab-software.ps1"
)

if not exist "%PS_SCRIPT%" (
    echo.
    echo ============================================================
    echo [ERROR] FILE SCRIPT TIDAK DITEMUKAN
    echo ============================================================
    echo.
    echo Script instalasi tidak ditemukan pada:
    echo   %~dp0Apps\install-lab-software.ps1
    echo atau:
    echo   %~dp0install-lab-software.ps1
    echo.
    echo Pastikan folder Apps beserta file install-lab-software.ps1 tersedia.
    echo.
    pause
    exit /b 1
)

echo   [OK] File lokal ditemukan: %PS_SCRIPT%
echo.

:: ============================================================
:: 5. Fitur Auto-Update Script dari Cloud SmartLab (Opsional)
::    (Tidak menggagalkan proses jika offline / tidak ada internet)
:: ============================================================
echo   [SYNC] Memeriksa pembaruan skrip dari Cloud SmartLab...
set "REMOTE_SCRIPT=%TEMP%\install-lab-software-latest.ps1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$urls = @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1', 'http://smartlab.is-best.net/scripts/install-lab-software.ps1');" ^
    "$target = '%PS_SCRIPT%';" ^
    "$tempFile = '%REMOTE_SCRIPT%';" ^
    "$updated = $false;" ^
    "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;" ^
    "foreach ($url in $urls) {" ^
    "    try {" ^
    "        $req = [System.Net.HttpWebRequest]::Create($url);" ^
    "        $req.Timeout = 4000;" ^
    "        $req.UserAgent = 'SmartLab-Client/2.5';" ^
    "        $resp = $req.GetResponse();" ^
    "        if ($resp.StatusCode -eq 200) {" ^
    "            $stream = $resp.GetResponseStream();" ^
    "            $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8);" ^
    "            $content = $reader.ReadToEnd();" ^
    "            $reader.Close(); $resp.Close();" ^
    "            if ($content.Length -gt 5000 -and $content -match 'Run-FullInstallation') {" ^
    "                [System.IO.File]::WriteAllText($target, $content, [System.Text.Encoding]::UTF8);" ^
    "                Write-Host '  [OK] Script berhasil diperbarui ke versi terbaru dari Cloud Lab!' -ForegroundColor Green;" ^
    "                $updated = $true; break;" ^
    "            }" ^
    "        }" ^
    "    } catch {}" ^
    "}" ^
    "if (-not $updated) {" ^
    "    Write-Host '  [i] Menggunakan script lokal di flashdisk (Mode Offline / Siap Pakai).' -ForegroundColor Yellow;" ^
    "}"

if exist "%REMOTE_SCRIPT%" del /q "%REMOTE_SCRIPT%" >nul 2>&1
echo.

:: ============================================================
:: 6. Jalankan Installer PowerShell
:: ============================================================
echo [3/3] Menjalankan installer PowerShell...
echo ============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

set "PS_EXIT=%errorlevel%"

:: ============================================================
:: 7. Kembalikan Pengaturan Keamanan Sistem & Tampilkan Ringkasan
:: ============================================================
echo.
echo ============================================================
echo   SESI INSTALASI SELESAI
echo ============================================================
echo.
echo Mengaktifkan kembali proteksi Real-Time Windows Defender...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue" >nul 2>&1
echo [OK] Proteksi keamanan PC kembali aktif.
echo.

if "%PS_EXIT%"=="0" (
    echo [OK] Script instalasi selesai dijalankan tanpa error.
) else (
    echo [PERINGATAN] Script berhenti dengan kode: %PS_EXIT%
    echo Silakan periksa pesan log di atas jika ada software yang membutuhkan perhatian.
)

echo.
echo Tekan sembarang tombol untuk keluar...
pause >nul
exit /b %PS_EXIT%
