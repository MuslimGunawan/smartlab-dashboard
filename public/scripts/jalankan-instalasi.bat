@echo off
setlocal EnableExtensions
title Installer Otomatis Software Lab TI - UNIMAL
color 0A

:: 1. Pindah ke direktori tempat file BAT ini berada
cd /d "%~dp0"

:: 2. Cek apakah sudah berjalan sebagai Administrator
net session >nul 2>&1
if "%errorlevel%"=="0" goto :run_admin

echo.
echo ============================================================
echo   MEMINTA HAK AKSES ADMINISTRATOR
echo ============================================================
echo.
echo Membuka permintaan izin Administrator (UAC)...
echo Silakan klik [YES] pada jendela konfirmasi yang muncul.
echo.

:: Buat script VBS temporary untuk elevasi yang 100% kompatibel di semua versi Windows
set "VBS_TEMP=%TEMP%\smartlab_uac_%RANDOM%.vbs"
echo Set UAC = CreateObject^("Shell.Application"^) > "%VBS_TEMP%"
echo UAC.ShellExecute "cmd.exe", "/k cd /d ""%~dp0"" ^&^& ""%~f0"" admin", "", "runas", 1 >> "%VBS_TEMP%"
cscript //nologo "%VBS_TEMP%" >nul 2>&1
del /f /q "%VBS_TEMP%" >nul 2>&1

:: Tunggu sejenak lalu tutup jendela non-admin ini
timeout /t 2 >nul 2>&1
exit /b

:run_admin
cls
echo.
echo ============================================================
echo   INSTALLER OTOMASI STANDARISASI SOFTWARE LAB TI - UNIMAL
echo ============================================================
echo.
echo Folder kerja: %CD%
echo.

set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
if not exist "%TARGET_PS%" set "TARGET_PS=%~dp0install-lab-software.ps1"

if not exist "%TARGET_PS%" (
    echo [i] Script lokal tidak ditemukan, mencoba mengunduh dari Cloud SmartLab...
    if not exist "%~dp0Apps" mkdir "%~dp0Apps" >nul 2>&1
    set "TARGET_PS=%~dp0Apps\install-lab-software.ps1"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; try { (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1', '%~dp0Apps\install-lab-software.ps1') } catch {}"
)

if not exist "%TARGET_PS%" (
    echo.
    echo ============================================================
    echo [ERROR] FILE SCRIPT TIDAK DITEMUKAN
    echo ============================================================
    echo.
    echo Script instalasi tidak ditemukan pada:
    echo   %~dp0Apps\install-lab-software.ps1
    echo.
    echo Pastikan folder Apps tersedia atau komputer terhubung ke internet.
    echo.
    pause
    exit /b 1
)

echo [OK] Menjalankan installer: %TARGET_PS%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TARGET_PS%"

echo.
echo ============================================================
echo   SESI INSTALASI SELESAI
echo ============================================================
echo.
pause
