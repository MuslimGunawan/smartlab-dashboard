@echo off
title Bebaskan Port 80 Windows (Fix Laragon Apache)
echo ========================================================
echo   MELEPASKAN PORT 80 DARI WINDOWS IIS / W3SVC (PID 4)
echo ========================================================
echo.
echo [1/3] Menghentikan & menonaktifkan World Wide Web Publishing Service (W3SVC / IIS)...
net stop W3SVC >nul 2>&1
sc config W3SVC start= disabled >nul 2>&1

echo [2/3] Menghentikan service IISADMIN & WAS jika ada...
net stop IISADMIN >nul 2>&1
sc config IISADMIN start= disabled >nul 2>&1
net stop WAS >nul 2>&1
sc config WAS start= disabled >nul 2>&1

echo [3/3] Menghentikan BranchCache (PeerDistSvc)...
net stop PeerDistSvc >nul 2>&1
sc config PeerDistSvc start= demand >nul 2>&1

echo.
echo [OK] Port 80 berhasil dibebaskan dari sistem Windows!
echo Silakan buka kembali Laragon dan klik "Start All". Apache akan berjalan normal di Port 80.
echo.
pause
exit /b 0
