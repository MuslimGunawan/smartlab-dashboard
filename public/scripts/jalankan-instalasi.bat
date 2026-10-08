@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Installer Otomatis 22 Software Lab TI - UNIMAL [v3.4.4]

:: 1. Tentukan target file powershell utama
set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
if not exist "%TARGET_PS%" set "TARGET_PS=%~dp0install-lab-software.ps1"

:: 2. Selalu sinkronkan & perbarui skrip utama secara otomatis dari Cloud SmartLab / GitHub
echo [i] Memeriksa pembaruan skrip otomatis dari Cloud SmartLab...
if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1
set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $urls = @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1', 'https://smartlab.is-best.net/scripts/install-lab-software.ps1'); foreach ($u in $urls) { try { $tempFile = '%~dp0Apps\temp_update.ps1'; $wc.DownloadFile($u, $tempFile); if (Test-Path $tempFile) { Move-Item -Path $tempFile -Destination '%TARGET_PS%' -Force; break } } catch {} }; $wc.Dispose()"

:: 3. Buka izin PowerShell ExecutionPolicy di latar belakang
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: 4. Jalankan langsung skrip PowerShell:
:: Skrip PowerShell memiliki logika elevasi cerdas bawaan dan mendukung penuh mode Administrator maupun Pengguna Standar
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%TARGET_PS%"
exit /b 0
