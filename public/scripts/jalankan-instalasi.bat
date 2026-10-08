@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Installer Otomatis 22 Software Lab TI - UNIMAL [v3.4.5 Modular]

:: 1. Tentukan target file powershell utama di dalam folder modules
if not exist "%~dp0modules" mkdir "%~dp0modules" >nul 2>&1
if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1

set "TARGET_PS=%~dp0modules\install-lab-software.ps1"
if not exist "%TARGET_PS%" set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"

:: 2. Selalu sinkronkan & perbarui skrip utama serta seluruh modul secara otomatis dari Cloud SmartLab / GitHub
echo [i] Memeriksa pembaruan skrip utama & modul dari Cloud SmartLab...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $urls = @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/install-lab-software.ps1', 'https://smartlab.is-best.net/scripts/modules/install-lab-software.ps1'); foreach ($u in $urls) { try { $tempFile = '%~dp0modules\temp_update.ps1'; $wc.DownloadFile($u, $tempFile); if (Test-Path $tempFile) { Move-Item -Path $tempFile -Destination '%~dp0modules\install-lab-software.ps1' -Force; break } } catch {} }; $mods = @('01-helpers.ps1','02-runtimes.ps1','03-webserver.ps1','04-dev-tools.ps1','05-virtual-gis.ps1','06-orchestrator.ps1'); foreach ($m in $mods) { $mPath = '%~dp0modules\' + $m; if (-not (Test-Path $mPath) -or ((Get-Item $mPath).Length -lt 200)) { foreach ($b in @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/','https://smartlab.is-best.net/scripts/modules/')) { try { $wc.DownloadFile($b + $m, $mPath); if (Test-Path $mPath) { break } } catch {} } } }; $wc.Dispose()"

:: 3. Bersihkan file lama di root jika ada agar tampilan tetap bersih hanya 1 file launcher
if exist "%~dp0install-lab-software.ps1" del /f /q "%~dp0install-lab-software.ps1" >nul 2>&1
if exist "%~dp0setup.ps1" del /f /q "%~dp0setup.ps1" >nul 2>&1
if exist "%~dp0fix-port-80.bat" del /f /q "%~dp0fix-port-80.bat" >nul 2>&1

:: 4. Buka izin PowerShell ExecutionPolicy di latar belakang
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: 5. Jalankan langsung skrip PowerShell dari dalam modules/:
:: Skrip PowerShell memiliki logika elevasi cerdas bawaan dan mendukung penuh mode Administrator maupun Pengguna Standar
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%~dp0modules\install-lab-software.ps1"
exit /b 0
