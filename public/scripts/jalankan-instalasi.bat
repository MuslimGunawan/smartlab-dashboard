@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Installer Otomatis 22 Software Lab TI - UNIMAL [v3.5.0 Modular]

:: 1. Tentukan target file powershell utama di dalam folder modules
if not exist "%~dp0modules" mkdir "%~dp0modules" >nul 2>&1
if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1

:: 2. Sinkronkan & perbarui skrip utama serta seluruh modul secara otomatis dari Cloud GitHub
echo [i] Memeriksa pembaruan skrip utama dan modul dari Cloud GitHub...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $curVer = '3.5.0'; $u = 'https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/install-lab-software.ps1'; try { $txt = $wc.DownloadString($u); if ($txt -match '\$SCRIPT_CURRENT_VERSION\s*=\s*\"\"([^\"\"]+)\"\"') { $remVer = $matches[1]; if ([version]$remVer -gt [version]$curVer -or (-not (Test-Path '%~dp0modules\install-lab-software.ps1'))) { [System.IO.File]::WriteAllText('%~dp0modules\install-lab-software.ps1', $txt, [System.Text.Encoding]::UTF8); $mods = @('01-helpers.ps1','02-runtimes.ps1','03-webserver.ps1','04-dev-tools.ps1','05-virtual-gis.ps1','06-orchestrator.ps1'); foreach ($m in $mods) { try { $wc.DownloadFile('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/' + $m, '%~dp0modules\' + $m) } catch {} } } } } catch {}; $mods = @('01-helpers.ps1','02-runtimes.ps1','03-webserver.ps1','04-dev-tools.ps1','05-virtual-gis.ps1','06-orchestrator.ps1'); foreach ($m in $mods) { $mPath = '%~dp0modules\' + $m; if (-not (Test-Path $mPath) -or ((Get-Item $mPath).Length -lt 1000)) { try { $wc.DownloadFile('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/' + $m, $mPath) } catch {} } }; $wc.Dispose()"

:: 3. Bersihkan file lama/rusak jika ada
if exist "%~dp0install-lab-software.ps1" del /f /q "%~dp0install-lab-software.ps1" >nul 2>&1
if exist "%~dp0setup.ps1" del /f /q "%~dp0setup.ps1" >nul 2>&1
if exist "%~dp0fix-port-80.bat" del /f /q "%~dp0fix-port-80.bat" >nul 2>&1

:: Jika di folder Apps ada file install-lab-software.ps1 lama yang corrupt (HTML), bersihkan
if exist "%~dp0Apps\install-lab-software.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if ((Get-Content '%~dp0Apps\install-lab-software.ps1' -First 2 -Raw) -match '<html|<body') { Remove-Item '%~dp0Apps\install-lab-software.ps1' -Force }" >nul 2>&1
)

:: 4. Buka izin PowerShell ExecutionPolicy di latar belakang
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: 5. Tentukan target eksekusi (prioritas modules\install-lab-software.ps1)
set "TARGET_PS=%~dp0modules\install-lab-software.ps1"
if not exist "%TARGET_PS%" set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"

:: 6. Jalankan langsung skrip PowerShell
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%TARGET_PS%"
exit /b 0
