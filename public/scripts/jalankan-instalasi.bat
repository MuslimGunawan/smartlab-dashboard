@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Installer Otomatis Software Lab TI - UNIMAL [v3.0.1]

:: 1. Tentukan target file powershell utama
set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
if not exist "%TARGET_PS%" set "TARGET_PS=%~dp0install-lab-software.ps1"

:: 2. Jika skrip belum ada di flashdisk/folder, unduh otomatis dari Cloud SmartLab
if not exist "%TARGET_PS%" (
    echo [i] Menyiapkan skrip utama dari Cloud SmartLab...
    if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1
    set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $urls = @('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1', 'https://smartlab.is-best.net/scripts/install-lab-software.ps1'); foreach ($u in $urls) { try { $wc.DownloadFile($u, '%~dp0Apps\install-lab-software.ps1'); break } catch {} }; $wc.Dispose()"
)

:: 3. Jalankan langsung di jendela PowerShell Administrator yang bersih!
:: CMD hanya bertindak sebagai pemicu/launcher, lalu jendela CMD ini langsung menutup otomatis.
net session >nul 2>&1
if "%errorlevel%"=="0" (
    start powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TARGET_PS%"
    exit /b 0
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"\"%TARGET_PS%\"\"' -Verb RunAs"
    exit /b 0
)
