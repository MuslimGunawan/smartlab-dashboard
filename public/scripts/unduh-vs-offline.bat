@echo off
setlocal EnableExtensions
title Unduh Paket Offline Visual Studio 2022 C++ - SmartLab UNIMAL
color 0B
cd /d "%~dp0"

echo ============================================================
echo   UNDUH PAKET OFFLINE VISUAL STUDIO 2022 C++ KE FLASHDISK
echo   Laboratorium Terpadu Teknik Informatika - UNIMAL
echo ============================================================
echo.
echo PERHATIAN PENTING:
echo  1. Jalankan script ini HANYA SEKALI pada komputer yang memiliki
echo     akses internet cepat / kuota stabil (misal di rumah atau hotspot).
echo  2. Script ini akan mengunduh paket resmi Microsoft Visual Studio
echo     Workload Desktop C++ (~2.5 - 3.5 GB) dan menyimpannya di:
echo     %~dp0Apps\vs_layout
echo  3. Setelah selesai, seluruh PC di Lab TI dapat menginstal Visual Studio
echo     secara 100%% OFFLINE tanpa perlu koneksi internet lagi!
echo.
set /p "KONFIRM=Mulai mengunduh paket offline sekarang? (Y/T): "
if /i not "%KONFIRM%"=="Y" exit /b 0

if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1
set "VS_BOOTSTRAP=%~dp0Apps\vs_community.exe"
set "VS_LAYOUT_DIR=%~dp0Apps\vs_layout"

if not exist "%VS_BOOTSTRAP%" (
    echo.
    echo [i] Mengunduh bootstrapper resmi Microsoft vs_community.exe...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_community.exe', '%VS_BOOTSTRAP%')"
)

if not exist "%VS_BOOTSTRAP%" (
    echo.
    echo [ERROR] Gagal mengunduh vs_community.exe. Periksa koneksi internet Anda.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo [>>>] Memulai pembuatan offline layout Visual Studio C++...
echo       Folder Tujuan: %VS_LAYOUT_DIR%
echo ============================================================
echo.
echo Harap tunggu hingga proses unduhan selesai...
echo (Jendela Visual Studio Installer akan muncul menampilkan progres unduhan)
echo.

"%VS_BOOTSTRAP%" --layout "%VS_LAYOUT_DIR%" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US

echo.
echo ============================================================
echo   PAKET OFFLINE VISUAL STUDIO 2022 C++ BERHASIL DISIAPKAN!
echo ============================================================
echo.
echo Seluruh berkas offline tersimpan di: %VS_LAYOUT_DIR%
echo Flashdisk Anda kini resmi menjadi Master USB Offline Visual Studio!
echo.
pause
