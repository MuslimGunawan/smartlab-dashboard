# ==============================================================================
# MODUL 03: WEB SERVER & DATABASE STACK (SMARTLAB LAB TI UNIMAL)
# Laragon (WAMP Stack + Custom Overlay), Sync-UnifiedLaragonPhp,
# XAMPP Server (Port Anti-Bentrok: 8088/8444/3307), Composer & Laravel Setup
# ==============================================================================

# ==============================================================================
# FUNGSI SENTRALISASI & DEDUPLIKASI KONFIGURASI PHP.INI (ANTI-ERROR STARTUP)
# ==============================================================================
function Configure-LabPhpIni {
    param (
        [string]$IniPath,
        [string]$PhpFolder
    )
    if (-not (Test-Path $IniPath)) {
        $devIni = Join-Path $PhpFolder "php.ini-development"
        $prodIni = Join-Path $PhpFolder "php.ini-production"
        if (Test-Path $devIni) {
            Copy-Item $devIni -Destination $IniPath -Force -ErrorAction SilentlyContinue
        } elseif (Test-Path $prodIni) {
            Copy-Item $prodIni -Destination $IniPath -Force -ErrorAction SilentlyContinue
        } else {
            return
        }
    }

    try {
        $content = [System.IO.File]::ReadAllText($IniPath)
        $extDir = Join-Path $PhpFolder "ext"
        $escapedExt = $extDir.Replace('\', '/')

        # 1. Bersihkan semua entri extension lama yang berulang atau korup
        $lines = @($content -split "`r?`n")
        $filteredLines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in $lines) {
            # Abaikan entri extension= atau ;extension= lama agar tidak ada duplikasi sama sekali
            if ($line -match '^\s*;?\s*extension\s*=\s*(?:php_)?([a-zA-Z0-9_-]+)(?:\.dll)?\s*$') {
                continue
            }
            # Abaikan baris direktif lama yang akan ditimpa bersih
            if ($line -match '^\s*;?\s*extension_dir\s*=') { continue }
            if ($line -match '^\s*;?\s*date\.timezone\s*=') { continue }
            if ($line -match '^\s*;?\s*display_startup_errors\s*=') { continue }
            if ($line -match '^\s*;?\s*display_errors\s*=') { continue }
            if ($line -match '^\s*;?\s*error_reporting\s*=') { continue }
            if ($line -match '^\s*;?\s*memory_limit\s*=') { continue }
            if ($line -match '^\s*;?\s*upload_max_filesize\s*=') { continue }
            if ($line -match '^\s*;?\s*post_max_size\s*=') { continue }
            if ($line -match '^\s*;?\s*max_execution_time\s*=') { continue }
            $filteredLines.Add($line)
        }

        # 2. Tambahkan konfigurasi inti anti-warning di bagian paling bawah
        $coreConfig = @"

;; ==============================================================================
;; KONFIGURASI RESMI TERPADU LAB TI UNIMAL (ANTI-ERROR STARTUP & TIMEZONE FIX)
;; ==============================================================================
extension_dir = "$escapedExt"
date.timezone = "Asia/Jakarta"
error_reporting = 22527
display_startup_errors = Off
display_errors = Off
log_errors = On
memory_limit = 512M
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 360
;; --- MODUL EXTENSION RESMI TERVERIFIKASI & DIUJI ---
"@
        $filteredLines.Add($coreConfig)

        # 3. Aktifkan modul extension yang benar-benar ada di folder ext secara unik (DEDUPLIKASI TOTAL)
        $wantedExts = @("curl", "fileinfo", "openssl", "pdo_mysql", "mysqli", "mbstring", "gd", "intl", "exif", "bcmath", "sodium", "zip")
        foreach ($ext in $wantedExts) {
            $hasDll = (Test-Path (Join-Path $extDir "php_$ext.dll")) -or (Test-Path (Join-Path $extDir "$ext.dll"))
            if ($hasDll) {
                $filteredLines.Add("extension=$ext")
            }
        }

        $finalText = $filteredLines -join "`r`n"
        [System.IO.File]::WriteAllText($IniPath, $finalText)
        Write-Host "   [OK] Konfigurasi php.ini dibersihkan & dioptimalkan: $(Split-Path -Leaf (Split-Path -Parent $IniPath))\php.ini" -ForegroundColor Green
    } catch {
        Write-Host "   [!] Gagal mengoptimalkan php.ini: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

# 1. Laragon (WAMP Stack) + Custom Lab Environment
function Setup-LaragonStack {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Laragon (WAMP Stack) + Custom Lab Environment" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $targetLaragon = "C:\laragon"
    $laragonExe = Join-Path $targetLaragon "laragon.exe"

    $laragonCustomMirrors = @(
        "https://drive.google.com/file/d/1nn1aUQm1FiVlFRy-pIerSxCkK1I7MtJ_/view?usp=sharing",
        "https://drive.google.com/file/d/14IyGfCdk3VOw-MWYXqA2SkP2S9jq1hBC/view?usp=sharing",
        "https://drive.google.com/file/d/1Eunm6q6ir8yx0F9ybTPU4dfaOn33fkUt/view?usp=sharing",
        "https://drive.google.com/file/d/1majSE8h7bR_tRFFz2euHBP3-CNtzigP6/view?usp=sharing"
    )

    # 0. BEBASKAN PORT 80 SEJAK AWAL DARI IIS, HTTP.SYS, & PROSES PENGHALANG
    Write-Host "`n   [i] Memeriksa & membebaskan Port 80 untuk Apache Laragon..." -ForegroundColor Yellow
    try {
        # 1. Hentikan & nonaktifkan service IIS / Web Publishing Windows
        $iisServices = @("W3SVC", "WAS", "IISADMIN", "PeerDistSvc", "iphlpsvc")
        foreach ($srv in $iisServices) {
            $s = Get-Service -Name $srv -ErrorAction SilentlyContinue
            if ($s -and ($s.Status -eq "Running" -or $s.StartType -ne "Disabled")) {
                Write-Host "   [!] Menonaktifkan service Windows IIS/Web ($srv) yang mengunci Port 80 (PID 4)..." -ForegroundColor Yellow
                & net stop $srv /y 2>$null | Out-Null
                Stop-Service -Name $srv -Force -ErrorAction SilentlyContinue
                Set-Service -Name $srv -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }

        # 2. Nonaktifkan HTTP.sys driver binding otomatis jika port 80 masih diikat oleh PID 4 (System)
        try {
            & net stop http /y 2>$null | Out-Null
            & sc.exe config http start= demand 2>$null | Out-Null
        } catch {}

        # 3. Cari proses selain Apache Laragon yang sedang mendengarkan di port 80 dan hentikan
        try {
            $p80Lines = netstat -ano | Select-String -Pattern ":80\s+.*LISTENING\s+(\d+)"
            foreach ($line in $p80Lines) {
                if ($line.Matches[0].Groups[1].Value) {
                    $pidToKill = [int]$line.Matches[0].Groups[1].Value
                    if ($pidToKill -gt 4) {
                        $pObj = Get-Process -Id $pidToKill -ErrorAction SilentlyContinue
                        if ($pObj -and $pObj.Path -notlike "C:\laragon\*") {
                            Write-Host "   [!] Menutup proses yang mengikat Port 80: $($pObj.Name) (PID: $pidToKill)..." -ForegroundColor Yellow
                            Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
        } catch {}

        # 4. Tutup proses pihak ketiga yang sering mengambil Port 80
        Get-Process -Name "SkypeApp", "Skype" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "   [OK] Port 80 telah dibebaskan dari service bawaan Windows (IIS/W3SVC/HTTP.sys) dan siap untuk Apache Laragon." -ForegroundColor Green
    } catch {}

    if (Test-Path $laragonExe) {
        Write-Host "   [OK SUDAH TERPASANG] Laragon terdeteksi di $laragonExe." -ForegroundColor Green
    } else {
        $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -ine "laragon.exe" -and $_.Name -notmatch "unins" -and $_.FullName -notmatch 'bin|usr|etc|Custom_Stack'
        } | Select-Object -First 1

        if (-not $laragonInstaller) {
            $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*wamp*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -notmatch "unins"
            } | Select-Object -First 1
        }

        if (-not $laragonInstaller) {
            Write-Host "   [i] File offline Laragon belum ada di Apps. Mengunduh installer resmi 6.0.0..." -ForegroundColor Yellow
            $laragonBaseUrls = @(
                "https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe",
                "https://downloads.sourceforge.net/project/laragon/laragon-wamp.exe"
            )
            $destExe = Join-Path $AppsDir "laragon-wamp-setup-6.0.0.exe"
            $dlBase = Download-FileWithFastMirrors -Urls $laragonBaseUrls -DestinationPath $destExe -ActivityTitle "Mengunduh Laragon WAMP"
            if ($dlBase -and (Test-Path $destExe)) {
                $laragonInstaller = Get-Item $destExe -ErrorAction SilentlyContinue
                Write-Host "   [OK] Installer Laragon berhasil diunduh dan disimpan di folder Apps/!" -ForegroundColor Green
            }

            if (-not $laragonInstaller -and (Test-WingetAvailable)) {
                try {
                    & winget download --id "LeNgocKhoa.Laragon" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
                    $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
                        $_.Name -ine "laragon.exe" -and $_.Name -notmatch "unins"
                    } | Select-Object -First 1
                } catch {}
            }
        }

        if ($laragonInstaller) {
            Write-Host "   [OK] Ditemukan installer: $($laragonInstaller.Name)" -ForegroundColor Green
            Write-Host "   [i] Menjalankan instalasi Laragon secara otomatis..." -ForegroundColor Yellow

            Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500

            $killJob = Start-Job -ScriptBlock {
                for ($i = 0; $i -lt 150; $i++) {
                    Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Milliseconds 250
                }
            }

            $laragonArgs = @("/VERYSILENT", "/NORESTART", "/SP-", "/SUPPRESSMSGBOXES", "/DIR=C:\laragon")
            $p = Start-Process -FilePath $laragonInstaller.FullName -ArgumentList $laragonArgs -Wait -PassThru

            Stop-Job $killJob -ErrorAction SilentlyContinue
            Remove-Job $killJob -Force -ErrorAction SilentlyContinue
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } elseif (Test-WingetAvailable) {
            Write-Host "   [i] Mencoba direct install Laragon via Winget..." -ForegroundColor Yellow
            try {
                & winget install --id "LeNgocKhoa.Laragon" --source winget -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>$null
                Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            } catch {}
        }
    }

    if (Test-Path $laragonExe) {
        Create-AppShortcut -TargetExe $laragonExe -ShortcutName "Laragon"
        $startMenuFolders = @(
            [Environment]::GetFolderPath("CommonPrograms"),
            [Environment]::GetFolderPath("Programs")
        )
        $wsh = New-Object -ComObject WScript.Shell
        foreach ($sm in $startMenuFolders) {
            if (Test-Path $sm) {
                $lnk = Join-Path $sm "Laragon.lnk"
                $sc = $wsh.CreateShortcut($lnk)
                $sc.TargetPath = $laragonExe
                $sc.WorkingDirectory = "C:\laragon"
                $sc.IconLocation = "$laragonExe,0"
                $sc.Save()
            }
        }
        try {
            $regKeys = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\laragon.exe",
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\laragon.exe"
            )
            foreach ($rk in $regKeys) {
                if (-not (Test-Path $rk)) { New-Item -Path $rk -Force | Out-Null }
                Set-ItemProperty -Path $rk -Name "(Default)" -Value $laragonExe -Force
                Set-ItemProperty -Path $rk -Name "Path" -Value "C:\laragon" -Force
            }
        } catch {}
        Add-ToSystemPath -DirToAdd "C:\laragon"
    }

    $customStackDir = Join-Path $AppsDir "Laragon_Custom_Stack"
    $hasExtracted = (Test-Path (Join-Path $customStackDir "bin"))

    if (-not $hasExtracted) {
        Write-Host "`n   [i] Memeriksa paket Laragon Custom Stack (PHP terbaru, MySQL, phpMyAdmin)..." -ForegroundColor Yellow

        $customRar = Get-ChildItem -Path $AppsDir -Filter "*Custom*Stack*.rar" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $customRar) {
            $customRar = Get-ChildItem -Path $AppsDir -Filter "*Laragon*Custom*.rar" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        if (-not $customRar) {
            $customRar = Get-ChildItem -Path $AppsDir -Filter "*Custom*Stack*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }

        if (-not $customRar -or ($customRar.Length -lt 10485760)) {
            Write-Host "   [i] Mengunduh master resmi Laragon_Custom_Stack.rar dari Google Drive (Auto-Fallback)..." -ForegroundColor Yellow
            $destRar = Join-Path $AppsDir "Laragon_Custom_Stack.rar"
            $dlSuccess = Download-FileWithFastMirrors -Urls $laragonCustomMirrors -DestinationPath $destRar -ActivityTitle "Mengunduh Laragon Custom Stack"
            if ($dlSuccess -and (Test-Path $destRar)) {
                $customRar = Get-Item $destRar
            }
        }

        if ($customRar -and (Test-Path $customRar.FullName)) {
            Write-Host "   [i] Mengekstrak paket stack kustom ke folder Apps/Laragon_Custom_Stack..." -ForegroundColor Yellow
            $extractedOk = Expand-LabArchive -ArchivePath $customRar.FullName -DestinationDir $customStackDir
            if ($extractedOk) {
                $innerBin = Get-ChildItem -Path $customStackDir -Filter "bin" -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($innerBin -and ($innerBin.Parent.FullName -ne $customStackDir)) {
                    $actualRoot = $innerBin.Parent.FullName
                    Get-ChildItem -Path $actualRoot | Move-Item -Destination $customStackDir -Force -ErrorAction SilentlyContinue
                }
                $hasExtracted = (Test-Path (Join-Path $customStackDir "bin"))
            }
        }
    }

    if (Test-Path $targetLaragon) {
        if ($hasExtracted -or (Test-Path (Join-Path $customStackDir "bin"))) {
            Write-Host "`n   [>>>] Mengintegrasikan modul custom stack (PHP/MySQL/phpMyAdmin) ke C:\laragon..." -ForegroundColor Cyan

            Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Where-Object {
                try {
                    if ($_.ProcessName -eq "laragon") { return $true }
                    return ($_.Path -like "*laragon*")
                } catch { return $false }
            } | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 600

            $itemsToOverlay = @("bin", "etc", "usr")
            foreach ($folder in $itemsToOverlay) {
                $src = Join-Path $customStackDir $folder
                $dst = Join-Path $targetLaragon $folder
                if (Test-Path $src) {
                    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
                    & robocopy $src $dst /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
                }
            }
            Write-Host "   [OK] Custom Stack berhasil diintegrasikan ke C:\laragon!" -ForegroundColor Green
        }
    }

    $allPhpDirs = Get-ChildItem -Path "$targetLaragon\bin\php" -Directory -ErrorAction SilentlyContinue | Where-Object {
        Test-Path (Join-Path $_.FullName "php.exe")
    }
    if ($allPhpDirs) {
        # Prioritaskan versi Thread-Safe (TS) yang kompatibel penuh dengan Apache mod_php/fcgid, lalu versi terbaru
        $newestPhpDir = $allPhpDirs | Sort-Object {
            $isTs = if ($_.Name -notmatch "-nts-" -or (Test-Path (Join-Path $_.FullName "php*apache*.dll"))) { 1 } else { 0 }
            $v = [Version]::new(0, 0, 0)
            if ($_.Name -match '(\d+(?:\.\d+)+)') {
                try {
                    $vParts = $matches[1].Split('.')
                    $major = [int]$vParts[0]
                    $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                    $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                    $v = [Version]::new($major, $minor, $build)
                } catch {}
            }
            return "$isTs-$($v.ToString(3).PadLeft(12, '0'))"
        } -Descending | Select-Object -First 1

        $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
        if (Test-Path $usrLaragonIni) {
            try {
                $iniTxt = [System.IO.File]::ReadAllText($usrLaragonIni)
                if ($iniTxt -match '\[php\]') {
                    $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($iniTxt, '(?s)(\[php\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Version\s*=\s*)[^\r\n]+', "${1}$($newestPhpDir.Name)")
                    [System.IO.File]::WriteAllText($usrLaragonIni, $newIniTxt)
                }
            } catch {}
        }
    }

    $allLaragonPhpFolders = Get-ChildItem -Path "$targetLaragon\bin\php" -Directory -ErrorAction SilentlyContinue
    foreach ($pFolder in $allLaragonPhpFolders) {
        $targetIni = Join-Path $pFolder.FullName "php.ini"
        Configure-LabPhpIni -IniPath $targetIni -PhpFolder $pFolder.FullName
    }

    # === SETUP & NORMALISASI MYSQL LARAGON (ANTI-STUCK, ANTI-BENTROK) ===
    Write-Host "`n   [i] Memeriksa & mengonfigurasi MySQL di Laragon..." -ForegroundColor Yellow
    Get-Process -Name "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    $allMysqlDirs = Get-ChildItem -Path "$targetLaragon\bin\mysql" -Directory -ErrorAction SilentlyContinue | Where-Object {
        Test-Path (Join-Path $_.FullName "bin\mysqld.exe")
    }

    $selectedMysqlName = $null
    if ($allMysqlDirs) {
        # Prioritaskan MySQL 8.0 (resmi bawaan Laragon & paling stabil tanpa masalah auth phpMyAdmin), lalu 8.4, lalu 9.x
        $selectedMysql = $allMysqlDirs | Sort-Object {
            if ($_.Name -match '^mysql-8\.0') { return 100 }
            if ($_.Name -match '^mysql-8\.') { return 90 }
            if ($_.Name -match '^mysql-5\.') { return 80 }
            if ($_.Name -match '^mysql-9\.') { return 70 }
            return 50
        } -Descending | Select-Object -First 1

        $selectedMysqlName = $selectedMysql.Name
        Write-Host "   [i] Versi MySQL default Laragon ditetapkan: $selectedMysqlName" -ForegroundColor Cyan

        # Pastikan seluruh folder data MySQL (mysql-8, mysql-9, mysql) diinisialisasi secara bersih
        foreach ($mDir in $allMysqlDirs) {
            $mDataDirName = if ($mDir.Name -match '^mysql-9') { "mysql-9" } elseif ($mDir.Name -match '^mysql-8') { "mysql-8" } else { "mysql" }
            $mDataDirPath = Join-Path $targetLaragon "data\$mDataDirName"
            $mysqldBin = Join-Path $mDir.FullName "bin\mysqld.exe"
            $escapedDataPath = $mDataDirPath.Replace('\', '/')

            # 1. Konfigurasi my.ini di folder MySQL
            $mIniPath = Join-Path $mDir.FullName "my.ini"
            $myIniConfig = @"
[client]
port=3306
socket=/tmp/mysql.sock

[mysqld]
port=3306
socket=/tmp/mysql.sock
key_buffer_size=256M
max_allowed_packet=512M
table_open_cache=256
sort_buffer_size=1M
read_buffer_size=1M
read_rnd_buffer_size=4M
myisam_sort_buffer_size=64M
thread_cache_size=8
secure-file-priv=""
explicit_defaults_for_timestamp=1
datadir="$escapedDataPath"

[mysqldump]
quick
max_allowed_packet=512M
"@
            try {
                [System.IO.File]::WriteAllText($mIniPath, $myIniConfig)
            } catch {}

            # 2. Inisialisasi data direktori jika belum pernah diinisialisasi (cegah stuck "Initializing data...")
            $mysqlSysDir = Join-Path $mDataDirPath "mysql"
            if (-not (Test-Path $mysqlSysDir)) {
                Write-Host "   [*] Menginisialisasi direktori data MySQL ($mDataDirName) secara aman..." -ForegroundColor Yellow
                try {
                    if (Test-Path $mDataDirPath) {
                        Remove-Item -Path "$mDataDirPath\*" -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        New-Item -ItemType Directory -Path $mDataDirPath -Force | Out-Null
                    }
                    $initProc = Start-Process -FilePath $mysqldBin -ArgumentList "--initialize-insecure", "--datadir=`"$mDataDirPath`"" -NoNewWindow -PassThru -Wait
                    if ($initProc.ExitCode -eq 0 -and (Test-Path $mysqlSysDir)) {
                        Write-Host "   [OK] Data direktori $mDataDirName berhasil diinisialisasi!" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "   [!] Inisialisasi direktori data $mDataDirName dilewati: $($_.Exception.Message)" -ForegroundColor DarkYellow
                }
            } else {
                Write-Host "   [OK] Data direktori MySQL ($mDataDirName) telah siap." -ForegroundColor Green
            }
        }
    }

    $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
    if (Test-Path $usrLaragonIni) {
        try {
            $lIniContent = [System.IO.File]::ReadAllText($usrLaragonIni)

            if ($selectedMysqlName -and $lIniContent -match '\[mysql\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[mysql\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Version\s*=\s*)[^\r\n]+', "${1}$selectedMysqlName")
            }
            if ($lIniContent -match '\[nginx\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[nginx\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }
            if ($lIniContent -match '\[apache\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[apache\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)0', '${1}-1')
            }
            if ($lIniContent -match '\[mysql\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[mysql\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)0', '${1}-1')
            }
            if ($lIniContent -match '\[postgresql\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[postgresql\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }
            if ($lIniContent -match '\[memcached\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[memcached\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }

            [System.IO.File]::WriteAllText($usrLaragonIni, $lIniContent)
            Write-Host "   [OK] Konfigurasi C:\laragon\usr\laragon.ini dioptimalkan (Apache & MySQL siap)." -ForegroundColor Green
        } catch {}
    }

    $fcgidConf = Join-Path $targetLaragon "etc\apache2\fcgid.conf"
    if (Test-Path $fcgidConf) {
        try {
            $fcgidText = [System.IO.File]::ReadAllText($fcgidConf)
            $modulesDir = Join-Path $targetLaragon "etc\apache2\modules"

            $availFcgid = Get-ChildItem -Path $modulesDir -Filter "*fcgid*.so" -File -ErrorAction SilentlyContinue |
                          Sort-Object { if ($_.Name -eq "mod_fcgid.so") { 100 } else { $_.Length } } -Descending |
                          Select-Object -First 1

            if ($availFcgid) {
                $standardSo = Join-Path $modulesDir "mod_fcgid.so"
                if (-not (Test-Path $standardSo)) {
                    Copy-Item $availFcgid.FullName -Destination $standardSo -Force -ErrorAction SilentlyContinue
                }
                $newFcgidText = $fcgidText -replace '(?m)^LoadModule\s+fcgid_module\s+.*$', 'LoadModule fcgid_module "C:/laragon/etc/apache2/modules/mod_fcgid.so"'
                
                # Sinkronkan path PHP pada fcgid.conf ke folder PHP aktif Laragon
                $activeLaragonPhp = $newestPhpDir
                if (-not $activeLaragonPhp) {
                    $activeLaragonPhp = Get-ChildItem -Path "$targetLaragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                                       Where-Object { Test-Path (Join-Path $_.FullName "php-cgi.exe") } |
                                       Select-Object -First 1
                }
                if ($activeLaragonPhp) {
                    $phpForward = $activeLaragonPhp.FullName.Replace('\', '/')
                    $newFcgidText = $newFcgidText -replace '(?m)^FcgidInitialEnv\s+PATH\s+.*$', "FcgidInitialEnv PATH `"$phpForward;C:/Windows/system32;C:/Windows;C:/Windows/System32/Wbem;`""
                    $newFcgidText = $newFcgidText -replace '(?m)^FcgidInitialEnv\s+PHPRC\s+.*$', "FcgidInitialEnv PHPRC `"$phpForward`""
                    $newFcgidText = $newFcgidText -replace '(?m)^FcgidWrapper\s+.*$', "FcgidWrapper `"$phpForward/php-cgi.exe`" .php"
                }

                if ($fcgidText -ne $newFcgidText) {
                    [System.IO.File]::WriteAllText($fcgidConf, $newFcgidText)
                    Write-Host "   [OK] Memperbaiki konfigurasi LoadModule & PHP Path di fcgid.conf Laragon." -ForegroundColor Green
                }
            } else {
                $newFcgidText = $fcgidText -replace '(?m)^LoadModule\s+fcgid_module', '#LoadModule fcgid_module'
                [System.IO.File]::WriteAllText($fcgidConf, $newFcgidText)
            }
        } catch {}
    }

    $defaultVhostConf = Join-Path $targetLaragon "etc\apache2\sites-enabled\00-default.conf"
    if (Test-Path $defaultVhostConf) {
        try {
            $defVhostText = [System.IO.File]::ReadAllText($defaultVhostConf)
            if ($defVhostText -notmatch '(?i)ServerName\s+localhost') {
                $newDefVhost = $defVhostText -replace '(?m)<VirtualHost _default_:80>', "<VirtualHost _default_:80>`r`n    ServerName localhost`r`n    DocumentRoot `"C:/laragon/www`""
                $newDefVhost = $newDefVhost -replace '(?m)<VirtualHost _default_:443>', "<VirtualHost _default_:443>`r`n    ServerName localhost`r`n    DocumentRoot `"C:/laragon/www`""
                [System.IO.File]::WriteAllText($defaultVhostConf, $newDefVhost)
                Write-Host "   [OK] Apache 00-default.conf dikonfigurasi ke localhost -> C:\laragon\www" -ForegroundColor Green
            }
        } catch {}
    }

    $laragonPmaConfig = Join-Path $targetLaragon "etc\apps\phpMyAdmin\config.inc.php"
    if (Test-Path $laragonPmaConfig) {
        try {
            $pmaContent = [System.IO.File]::ReadAllText($laragonPmaConfig)
            $newPmaContent = $pmaContent

            if ($newPmaContent -match "\['host'\]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['host'\]\s*=\s*)['`"][^'`"]*['`"]", '${1}''127.0.0.1''')
            } else {
                $newPmaContent += "`r`n`$cfg['Servers'][`$i]['host'] = '127.0.0.1';`r`n"
            }
            if ($newPmaContent -match "\['port'\]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['port'\]\s*=\s*)['`"]?\d*['`"]?", '${1}''3306''')
            } else {
                $newPmaContent += "`r`n`$cfg['Servers'][`$i]['port'] = '3306';`r`n"
            }

            if ($newPmaContent -notmatch "PmaNoRelation_DisableWarning") {
                $newPmaContent += "`r`n`$cfg['PmaNoRelation_DisableWarning'] = true;`r`n"
            } else {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['PmaNoRelation_DisableWarning'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            if ($newPmaContent -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
            } else {
                $newPmaContent += "`r`n`$cfg['Servers'][`$i]['AllowNoPassword'] = true;`r`n"
            }

            $newPmaContent = $newPmaContent -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controluser.\]\s*=.*$', '// $cfg[''Servers''][$i][''controluser''] = '''';'
            $newPmaContent = $newPmaContent -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controlpass.\]\s*=.*$', '// $cfg[''Servers''][$i][''controlpass''] = '''';'

            if ($pmaContent -ne $newPmaContent) {
                [System.IO.File]::WriteAllText($laragonPmaConfig, $newPmaContent)
                Write-Host "   [OK] phpMyAdmin Laragon dioptimalkan (Host 127.0.0.1:3306, bebas error storage)." -ForegroundColor Green
            }
        } catch {}
    }

    # 5.3 Bersihkan entri hosts yang korup
    $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
    if (Test-Path $hostsFile) {
        try {
            $hLines = Get-Content $hostsFile -ErrorAction SilentlyContinue
            $cleaned = $hLines | Where-Object { $_ -notmatch '(?i)app\.test|laragon\.test|\.test\s*$' -or $_ -match '127\.0\.0\.1\s+localhost' }
            [System.IO.File]::WriteAllLines($hostsFile, $cleaned)
        } catch {}
    }

    if (Test-Path $laragonExe) {
        Write-Host "   [i] Memastikan web stack Laragon disegarkan..." -ForegroundColor Yellow
        Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 600
        try {
            Start-Process -FilePath $laragonExe -WorkingDirectory "C:\laragon" -WindowStyle Minimized -ErrorAction SilentlyContinue
            Write-Host "   [OK] Laragon berhasil dijalankan (Apache & MySQL siap)." -ForegroundColor Green
        } catch {}
    }

    Record-InstallResult -Name "Laragon" -Status "BERHASIL DIINSTAL" -Keterangan "Laragon + Custom Stack Siap"
}

# 2. Sinkronisasi Seluruh Ekosistem PHP ke Versi Terbaru Laragon
function Sync-UnifiedLaragonPhp {
    Write-Host "`n   [>>>] Menyatukan seluruh ekosistem PHP ke versi terbaru Laragon (C:\laragon\bin\php)..." -ForegroundColor Cyan

    $laragonPhps = Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                   Sort-Object {
                       $isTs = if ($_.Name -notmatch "-nts-" -or (Test-Path (Join-Path $_.FullName "php*apache*.dll"))) { 1 } else { 0 }
                       $v = [Version]::new(0, 0, 0)
                       if ($_.Name -match '(\d+(?:\.\d+)+)') {
                           try {
                               $vParts = $matches[1].Split('.')
                               $major = [int]$vParts[0]
                               $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                               $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                               $v = [Version]::new($major, $minor, $build)
                           } catch {}
                       }
                       return "$isTs-$($v.ToString(3).PadLeft(12, '0'))"
                   } -Descending

    if (-not $laragonPhps) {
        Write-Host "   [!] Belum ada folder PHP terdeteksi di C:\laragon\bin\php." -ForegroundColor Yellow
        return
    }

    $topPhpDir = $laragonPhps[0].FullName
    $topPhpExe = Join-Path $topPhpDir "php.exe"
    Write-Host "   [i] Versi PHP tertinggi yang dipilih: $($laragonPhps[0].Name)" -ForegroundColor Green

    try {
        $regAppPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\php.exe"
        if (-not (Test-Path $regAppPath)) { New-Item -Path $regAppPath -Force | Out-Null }
        Set-ItemProperty -Path $regAppPath -Name "(Default)" -Value $topPhpExe -Force
        Set-ItemProperty -Path $regAppPath -Name "Path" -Value $topPhpDir -Force
    } catch {}

    $binTargets = @("C:\Program Files\Common Files\php.exe", "C:\Windows\System32\php.exe")
    foreach ($bt in $binTargets) {
        try {
            if (Test-Path $bt) { Remove-Item $bt -Force -ErrorAction SilentlyContinue }
            cmd.exe /c mklink /H "$bt" "$topPhpExe" 2>$null | Out-Null
        } catch {}
    }

    $rawPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $cleanPathParts = ($rawPath -split ';') | Where-Object {
        $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
    }
    $newMachinePath = "$topPhpDir;" + ($cleanPathParts -join ';')
    try {
        [Environment]::SetEnvironmentVariable("Path", $newMachinePath, [EnvironmentVariableTarget]::Machine)
    } catch {}

    $rawUserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $cleanUserParts = ($rawUserPath -split ';') | Where-Object {
        $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
    }
    $newUserPath = "$topPhpDir;" + ($cleanUserParts -join ';')
    try {
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, [EnvironmentVariableTarget]::User)
    } catch {}

    $sessionParts = ($env:Path -split ';') | Where-Object {
        $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
    }
    $env:Path = "$topPhpDir;" + ($sessionParts -join ';')
    Write-Host "   [OK] System PATH & Session PATH dikunci ke PHP: $topPhpDir" -ForegroundColor Green

    Set-SystemEnvVar -Name "PHP_BINARY" -Value $topPhpExe
    Set-SystemEnvVar -Name "PHP_PATH" -Value $topPhpDir
    $env:PHP_BINARY = $topPhpExe
    $env:PHP_PATH = $topPhpDir

    $composerBat = "C:\ProgramData\ComposerSetup\bin\composer.bat"
    if (Test-Path $composerBat) {
        try {
            $compBatContent = "@echo off`r`n`"$topPhpExe`" `"%~dp0composer.phar`" %*`r`n"
            [System.IO.File]::WriteAllText($composerBat, $compBatContent)
            Write-Host "   [OK] Composer wrapper dikunci langsung ke $topPhpExe" -ForegroundColor Green
        } catch {}
    }

    # Sinkronkan juga fcgid.conf Laragon ke topPhpDir agar Apache memanggil php-cgi yang sesuai
    $laragonFcgid = "C:\laragon\etc\apache2\fcgid.conf"
    if (Test-Path $laragonFcgid) {
        try {
            $fText = [System.IO.File]::ReadAllText($laragonFcgid)
            $phpForward = $topPhpDir.Replace('\', '/')
            $newFText = $fText -replace '(?m)^FcgidInitialEnv\s+PATH\s+.*$', "FcgidInitialEnv PATH `"$phpForward;C:/Windows/system32;C:/Windows;C:/Windows/System32/Wbem;`""
            $newFText = $newFText -replace '(?m)^FcgidInitialEnv\s+PHPRC\s+.*$', "FcgidInitialEnv PHPRC `"$phpForward`""
            $newFText = $newFText -replace '(?m)^FcgidWrapper\s+.*$', "FcgidWrapper `"$phpForward/php-cgi.exe`" .php"
            if ($fText -ne $newFText) {
                [System.IO.File]::WriteAllText($laragonFcgid, $newFText)
                Write-Host "   [OK] fcgid.conf Apache Laragon disinkronkan ke $phpForward" -ForegroundColor Green
            }
        } catch {}
    }

    $usrLaragonIni = "C:\laragon\usr\laragon.ini"
    if (Test-Path $usrLaragonIni) {
        try {
            $lIni = [System.IO.File]::ReadAllText($usrLaragonIni)
            if ($lIni -match '\[php\]') {
                $topPhpName = Split-Path -Leaf $topPhpDir
                $newLIni = [System.Text.RegularExpressions.Regex]::Replace($lIni, '(?s)(\[php\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Version\s*=\s*)[^\r\n]+', "${1}$topPhpName")
                if ($lIni -ne $newLIni) {
                    [System.IO.File]::WriteAllText($usrLaragonIni, $newLIni)
                }
            }
        } catch {}
    }

    try {
        $vOutput = & $topPhpExe -v 2>&1 | Out-String
        $firstLine = ($vOutput.Trim() -split "`r?`n")[0]
        Write-Host "   [OK] Uji Eksekusi PHP Terpadu: $firstLine" -ForegroundColor Green
    } catch {}
}

# 3. Setup XAMPP Server & Pencegahan Bentrok Port dengan Laragon (Port 8088/8444/3307)
function Setup-XamppStack {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: XAMPP Server + Konfigurasi Port Anti-Bentrok" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $xamppMirrors = @(
        "https://downloads.sourceforge.net/project/xampp/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe",
        "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"
    )

    $xamppPaths = @("C:\xampp\xampp-control.exe", "D:\xampp\xampp-control.exe")
    $installedXampp = $null
    foreach ($xp in $xamppPaths) {
        if (Test-Path $xp) { $installedXampp = $xp; break }
    }

    if (-not $installedXampp) {
        if ((Test-Path "C:\xampp") -and -not (Test-Path "C:\xampp\xampp-control.exe")) {
            $xItems = Get-ChildItem -Path "C:\xampp" -ErrorAction SilentlyContinue
            if (-not $xItems -or $xItems.Count -eq 0) {
                Remove-Item -Path "C:\xampp" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Install-AppSmart -Name "XAMPP" `
                         -FilePattern "*xampp*.exe" `
                         -DownloadUrls $xamppMirrors `
                         -SilentArgs "--mode unattended" `
                         -WingetId "ApacheFriends.Xampp.8.2" `
                         -CheckPath $xamppPaths

        foreach ($xp in $xamppPaths) {
            if (Test-Path $xp) { $installedXampp = $xp; break }
        }
    } else {
        Write-Host "   [OK SUDAH TERPASANG] XAMPP Server terdeteksi di $installedXampp." -ForegroundColor Green
        Create-AppShortcut -TargetExe $installedXampp -ShortcutName "XAMPP Control Panel"
        Record-InstallResult -Name "XAMPP" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
    }

    $xamppDir = "C:\xampp"
    if (-not (Test-Path $xamppDir) -and (Test-Path "D:\xampp")) { $xamppDir = "D:\xampp" }

    if (Test-Path $xamppDir) {
        Write-Host "`n[i] Mengonfigurasi Port XAMPP agar tidak bentrok dengan Laragon..." -ForegroundColor Yellow

        Get-Process -Name "xampp-control", "httpd", "mysqld" -ErrorAction SilentlyContinue | Where-Object {
            try {
                if ($_.ProcessName -eq "xampp-control") { return $true }
                return ($_.Path -like "*xampp*")
            } catch { return $false }
        } | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1

        $httpdConf = Join-Path $xamppDir "apache\conf\httpd.conf"
        if (Test-Path $httpdConf) {
            $confText = [System.IO.File]::ReadAllText($httpdConf)
            $newConfText = [System.Text.RegularExpressions.Regex]::Replace($confText, '(?m)^Listen\s+(?:.*:)?(?!8088\b)\d+\s*$', 'Listen 8088')
            $newConfText = [System.Text.RegularExpressions.Regex]::Replace($newConfText, '(?m)^ServerName\s+localhost:(?!8088\b)\d+\s*$', 'ServerName localhost:8088')
            if ($newConfText -notmatch '(?m)^Listen\s+8088') {
                $newConfText = $newConfText -replace '(?m)^Listen\s+.*$', 'Listen 8088'
            }
            if ($confText -ne $newConfText) {
                [System.IO.File]::WriteAllText($httpdConf, $newConfText)
                Write-Host "   [OK] Apache HTTP Port XAMPP dialihkan ke 8088 (Laragon di 80, Laravel di 8000, WebDev di 3000/5173)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port Apache XAMPP sudah diatur pada 8088." -ForegroundColor Green
            }
        }

        $httpdSslConf = Join-Path $xamppDir "apache\conf\extra\httpd-ssl.conf"
        if (Test-Path $httpdSslConf) {
            $sslText = [System.IO.File]::ReadAllText($httpdSslConf)
            $newSslText = [System.Text.RegularExpressions.Regex]::Replace($sslText, '(?m)^Listen\s+(?!8444\b)\d+\s*$', 'Listen 8444')
            $newSslText = [System.Text.RegularExpressions.Regex]::Replace($newSslText, '(?m)^<VirtualHost _default_:(?!8444\b)\d+>', '<VirtualHost _default_:8444>')
            $newSslText = [System.Text.RegularExpressions.Regex]::Replace($newSslText, '(?m)^ServerName\s+localhost:(?!8444\b)\d+\s*$', 'ServerName localhost:8444')
            if ($sslText -ne $newSslText) {
                [System.IO.File]::WriteAllText($httpdSslConf, $newSslText)
                Write-Host "   [OK] Apache SSL Port XAMPP dialihkan ke 8444 (Laragon SSL tetap di Port 443)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port Apache SSL XAMPP sudah diatur pada 8444." -ForegroundColor Green
            }
        }

        $myIni = Join-Path $xamppDir "mysql\bin\my.ini"
        if (Test-Path $myIni) {
            $myText = [System.IO.File]::ReadAllText($myIni)
            # Ganti semua baris port = ... menjadi port = 3307 baik di [client] maupun [mysqld]
            $newMyText = [System.Text.RegularExpressions.Regex]::Replace($myText, '(?m)^\s*port\s*=\s*\d+.*$', 'port = 3307')
            if ($myText -ne $newMyText) {
                [System.IO.File]::WriteAllText($myIni, $newMyText)
                Write-Host "   [OK] MySQL Port XAMPP (Client & Daemon) dialihkan ke 3307 (Laragon standar di Port 3306)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port MySQL XAMPP sudah diatur pada 3307." -ForegroundColor Green
            }
        }

        $xamppPhpIni = Join-Path $xamppDir "php\php.ini"
        if (Test-Path $xamppPhpIni) {
            try {
                $xIniText = [System.IO.File]::ReadAllText($xamppPhpIni)
                $newXIniText = $xIniText -replace '(?m)^\s*;?\s*mysqli\.default_port\s*=.*$', 'mysqli.default_port = 3307'
                $newXIniText = $newXIniText -replace '(?m)^\s*;?\s*mysql\.default_port\s*=.*$', 'mysql.default_port = 3307'
                if ($xIniText -ne $newXIniText) {
                    [System.IO.File]::WriteAllText($xamppPhpIni, $newXIniText)
                    Write-Host "   [OK] PHP XAMPP (mysqli.default_port) dikonfigurasi ke 3307." -ForegroundColor Green
                }
            } catch {}
        }

        $pmaConfig = Join-Path $xamppDir "phpMyAdmin\config.inc.php"
        if (Test-Path $pmaConfig) {
            $pmaText = [System.IO.File]::ReadAllText($pmaConfig)
            $newPmaText = $pmaText

            # Pastikan host = 127.0.0.1
            if ($newPmaText -match "(\['host'\]\s*=\s*)['`"][^'`"]*['`"]") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['host'\]\s*=\s*)['`"][^'`"]*['`"]", '${1}''127.0.0.1''')
            } else {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['host'] = '127.0.0.1';`r`n"
            }

            # Pastikan port = 3307
            if ($newPmaText -match "(\['port'\]\s*=\s*)['`"]?\d*['`"]?") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['port'\]\s*=\s*)['`"]?\d*['`"]?", '${1}''3307''')
            } else {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['port'] = '3307';`r`n"
            }

            # Izinkan login tanpa password jika root belum berpassword
            if ($newPmaText -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            # Paksa koneksi via protokol TCP
            if ($newPmaText -match "(\['connect_type'\]\s*=\s*)['`"][^'`"]*['`"]") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['connect_type'\]\s*=\s*)['`"][^'`"]*['`"]", '${1}''tcp''')
            } else {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['connect_type'] = 'tcp';`r`n"
            }

            if ($newPmaText -notmatch "PmaNoRelation_DisableWarning") {
                $newPmaText += "`r`n`$cfg['PmaNoRelation_DisableWarning'] = true;`r`n"
            } else {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['PmaNoRelation_DisableWarning'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            $newPmaText = $newPmaText -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controluser.\]\s*=.*$', '// $cfg[''Servers''][$i][''controluser''] = '''';'
            $newPmaText = $newPmaText -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controlpass.\]\s*=.*$', '// $cfg[''Servers''][$i][''controlpass''] = '''';'

            if ($pmaText -ne $newPmaText) {
                [System.IO.File]::WriteAllText($pmaConfig, $newPmaText)
                Write-Host "   [OK] phpMyAdmin XAMPP dikonfigurasi ke 127.0.0.1:3307 (TCP)" -ForegroundColor Green
            }
        }

        $xamppIni = Join-Path $xamppDir "xampp-control.ini"
        if (Test-Path $xamppIni) {
            $iniTxt = [System.IO.File]::ReadAllText($xamppIni)

            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($iniTxt, '(?m)^Apache\s*=\s*(?!8088\b)\d+\s*$', 'Apache = 8088')
            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($newIniTxt, '(?m)^ApacheSSL\s*=\s*(?!8444\b)\d+\s*$', 'ApacheSSL = 8444')
            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($newIniTxt, '(?m)^MySQL\s*=\s*(?!3307\b)\d+\s*$', 'MySQL = 3307')

            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($newIniTxt, '(?m)^PortApache\s*=\s*(?!8088\b)\d+\s*$', 'PortApache = 8088')
            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($newIniTxt, '(?m)^PortSSL\s*=\s*(?!8444\b)\d+\s*$', 'PortSSL = 8444')
            $newIniTxt = [System.Text.RegularExpressions.Regex]::Replace($newIniTxt, '(?m)^PortMySQL\s*=\s*(?!3307\b)\d+\s*$', 'PortMySQL = 3307')

            if ($newIniTxt -match '(?m)^ApacheAdminURL\s*=') {
                $newIniTxt = $newIniTxt -replace '(?m)^ApacheAdminURL\s*=.*$', 'ApacheAdminURL = http://localhost:8088/dashboard/'
            } elseif ($newIniTxt -match '(?m)\[UserConfigs\]') {
                $newIniTxt = $newIniTxt -replace '(?m)(\[UserConfigs\])', "`$1`r`nApacheAdminURL = http://localhost:8088/dashboard/"
            } else {
                $newIniTxt += "`r`n[UserConfigs]`r`nApacheAdminURL = http://localhost:8088/dashboard/"
            }

            if ($newIniTxt -match '(?m)^MySQLAdminURL\s*=') {
                $newIniTxt = $newIniTxt -replace '(?m)^MySQLAdminURL\s*=.*$', 'MySQLAdminURL = http://localhost:8088/phpmyadmin/'
            } elseif ($newIniTxt -match '(?m)\[UserConfigs\]') {
                $newIniTxt = $newIniTxt -replace '(?m)(\[UserConfigs\])', "`$1`r`nMySQLAdminURL = http://localhost:8088/phpmyadmin/"
            } else {
                $newIniTxt += "`r`nMySQLAdminURL = http://localhost:8088/phpmyadmin/"
            }

            if ($newIniTxt -match '(?m)\[ServicePorts\]') {
                if ($newIniTxt -notmatch '(?m)^Apache\s*=\s*8088') {
                    $newIniTxt = $newIniTxt -replace '(?m)(\[ServicePorts\])', "`$1`r`nApache = 8088"
                }
                if ($newIniTxt -notmatch '(?m)^MySQL\s*=\s*3307') {
                    $newIniTxt = $newIniTxt -replace '(?m)(\[ServicePorts\])', "`$1`r`nMySQL = 3307"
                }
            } else {
                $newIniTxt += "`r`n[ServicePorts]`r`nApache = 8088`r`nApacheSSL = 8444`r`nMySQL = 3307`r`n"
            }

            # Konfigurasi auto-start services di xampp-control.ini
            if ($newIniTxt -match '(?m)\[Autostart\]') {
                $newIniTxt = $newIniTxt -replace '(?m)^Apache\s*=.*$', 'Apache=1'
                $newIniTxt = $newIniTxt -replace '(?m)^MySQL\s*=.*$', 'MySQL=1'
            } else {
                $newIniTxt += "`r`n[Autostart]`r`nApache=1`r`nMySQL=1`r`n"
            }

            [System.IO.File]::WriteAllText($xamppIni, $newIniTxt)
            Write-Host "   [OK] Port pada XAMPP Control Panel disinkronkan ke 8088/8444/3307 & Admin diarahkan ke http://localhost:8088." -ForegroundColor Green
        }

        # Jalankan service Apache dan MySQL XAMPP di latar belakang agar phpMyAdmin langsung dapat diakses
        Write-Host "   [i] Memulai service Apache & MySQL XAMPP (Port 8088 & 3307)..." -ForegroundColor Yellow
        $xamppStart = Join-Path $xamppDir "xampp_start.exe"
        $apacheStart = Join-Path $xamppDir "apache_start.bat"
        $mysqlStart = Join-Path $xamppDir "mysql_start.bat"
        $httpdExe = Join-Path $xamppDir "apache\bin\httpd.exe"
        $mysqldExe = Join-Path $xamppDir "mysql\bin\mysqld.exe"

        if (Test-Path $xamppStart) {
            Start-Process -FilePath $xamppStart -WorkingDirectory $xamppDir -WindowStyle Hidden -ErrorAction SilentlyContinue
        } else {
            if (Test-Path $apacheStart) {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$apacheStart`"" -WorkingDirectory $xamppDir -WindowStyle Hidden -ErrorAction SilentlyContinue
            } elseif (Test-Path $httpdExe) {
                Start-Process -FilePath $httpdExe -WorkingDirectory (Join-Path $xamppDir "apache\bin") -WindowStyle Hidden -ErrorAction SilentlyContinue
            }

            if (Test-Path $mysqlStart) {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$mysqlStart`"" -WorkingDirectory $xamppDir -WindowStyle Hidden -ErrorAction SilentlyContinue
            } elseif (Test-Path $mysqldExe) {
                Start-Process -FilePath $mysqldExe -ArgumentList "--defaults-file=`"$myIni`"", "--standalone" -WorkingDirectory (Join-Path $xamppDir "mysql\bin") -WindowStyle Hidden -ErrorAction SilentlyContinue
            }
        }
        Start-Sleep -Seconds 3

        # Buat shortcut rapi di seluruh Desktop (XAMPP Control Panel & phpMyAdmin URL)
        $desktopDirs = @(
            [Environment]::GetFolderPath("CommonDesktopDirectory"),
            [Environment]::GetFolderPath("Desktop")
        )
        $allUsers = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch 'Default|Public|All Users' }
        foreach ($u in $allUsers) {
            $uDesk = Join-Path $u.FullName "Desktop"
            if (Test-Path $uDesk) { $desktopDirs += $uDesk }
        }
        $desktopDirs = $desktopDirs | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path $_) } | Select-Object -Unique

        $xamppCtrlExe = Join-Path $xamppDir "xampp-control.exe"
        $wsh = New-Object -ComObject WScript.Shell

        foreach ($dt in $desktopDirs) {
            try {
                if (Test-Path $xamppCtrlExe) {
                    $cpLnk = Join-Path $dt "XAMPP Control Panel.lnk"
                    $scCp = $wsh.CreateShortcut($cpLnk)
                    $scCp.TargetPath = $xamppCtrlExe
                    $scCp.WorkingDirectory = $xamppDir
                    $scCp.IconLocation = "$xamppCtrlExe,0"
                    $scCp.Description = "XAMPP Control Panel (Port 8088 & 3307)"
                    $scCp.Save()
                }

                $pmaLnk = Join-Path $dt "XAMPP phpMyAdmin (Port 8088).lnk"
                $scPma = $wsh.CreateShortcut($pmaLnk)
                $scPma.TargetPath = "http://localhost:8088/phpmyadmin/"
                $scPma.WorkingDirectory = $xamppDir
                if (Test-Path $xamppCtrlExe) {
                    $scPma.IconLocation = "$xamppCtrlExe,0"
                }
                $scPma.Description = "Buka phpMyAdmin XAMPP Port 8088"
                $scPma.Save()
            } catch {}
        }
        Write-Host "   [OK] Shortcut Desktop XAMPP Control Panel & phpMyAdmin (Port 8088) berhasil diperbarui." -ForegroundColor Green
    }
}

# 4. Setup Composer & Laravel Installer Otomatis
function Setup-ComposerAndLaravel {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Composer (PHP Dependency Manager) & Laravel Setup" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $env:COMPOSER_NO_INTERACTION = "1"
    $env:COMPOSER_ALLOW_SUPERUSER = "1"
    [Environment]::SetEnvironmentVariable("COMPOSER_NO_INTERACTION", "1", [EnvironmentVariableTarget]::Process)
    [Environment]::SetEnvironmentVariable("COMPOSER_ALLOW_SUPERUSER", "1", [EnvironmentVariableTarget]::Process)

    $phpPath = $null
    $laragonPhps = Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                   Sort-Object {
                       if ($_.Name -match '(\d+(?:\.\d+)+)') {
                           try {
                               $vParts = $matches[1].Split('.')
                               $major = [int]$vParts[0]
                               $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                               $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                               [Version]::new($major, $minor, $build)
                           } catch { [Version]::new(0, 0, 0) }
                       } else { [Version]::new(0, 0, 0) }
                   } -Descending

    if ($laragonPhps) {
        $phpPath = Join-Path $laragonPhps[0].FullName "php.exe"
    } else {
        $phpSearch = @(
            "C:\laragon\bin\php\php-*\php.exe",
            "C:\laragon\bin\php\*\php.exe",
            "C:\xampp\php\php.exe"
        )
        foreach ($pattern in $phpSearch) {
            $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $phpPath = $found.FullName; break }
        }
    }

    $phpDir = $null
    if ($phpPath) {
        $phpDir = Split-Path -Parent $phpPath
        Add-ToSystemPath -DirToAdd $phpDir
        $env:Path = "$phpDir;" + ($env:Path -replace [regex]::Escape("$phpDir;"), "")
        Write-Host "   [OK] PHP aktif dikunci ke: $phpPath (Versi terbaru Laragon)" -ForegroundColor Green
    } else {
        Write-Host "   [!] PHP belum ditemukan di C:\laragon\bin\php atau C:\xampp\php." -ForegroundColor Yellow
    }

    $programDataComposer = "C:\ProgramData\ComposerSetup\bin"
    $laragonComposer = "C:\laragon\bin\composer"
    if (-not (Test-Path $programDataComposer)) { New-Item -ItemType Directory -Path $programDataComposer -Force | Out-Null }

    $activePhar = $null
    $pharCandidates = @(
        (Join-Path $laragonComposer "composer.phar"),
        (Join-Path $programDataComposer "composer.phar"),
        (Join-Path $AppsDir "composer.phar")
    )
    foreach ($pc in $pharCandidates) {
        if ((Test-Path $pc) -and ((Get-Item $pc).Length -gt 1000000)) {
            $activePhar = $pc
            break
        }
    }

    if (-not $activePhar) {
        Write-Host "   [i] Menyiapkan composer.phar resmi (LTS Stable)..." -ForegroundColor Yellow
        $destPhar = Join-Path $programDataComposer "composer.phar"
        $pharMirrors = @(
            "https://getcomposer.org/composer-stable.phar",
            "https://getcomposer.org/download/latest-stable/composer.phar"
        )
        $dlPhar = Download-FileWithFastMirrors -Urls $pharMirrors -DestinationPath $destPhar -ActivityTitle "Mengunduh Composer Standalone"
        if ($dlPhar -and (Test-Path $destPhar)) {
            $activePhar = $destPhar
        }
    }

    if ($activePhar) {
        foreach ($cDir in @($programDataComposer, $laragonComposer)) {
            if (-not (Test-Path $cDir)) { New-Item -ItemType Directory -Path $cDir -Force | Out-Null }
            Copy-Item $activePhar -Destination (Join-Path $cDir "composer.phar") -Force -ErrorAction SilentlyContinue
            $batCode = "@echo off`r`n`"$phpPath`" `"%~dp0composer.phar`" %*`r`n"
            [System.IO.File]::WriteAllText((Join-Path $cDir "composer.bat"), $batCode)
        }
        Write-Host "   [OK] Composer executable wrapper dikunci ke: $phpPath" -ForegroundColor Green
    }

    Add-ToSystemPath -DirToAdd $programDataComposer
    Add-ToSystemPath -DirToAdd $laragonComposer
    $env:Path = "$programDataComposer;$laragonComposer;" + $env:Path

    # Optimalkan seluruh php.ini di Laragon dan XAMPP
    $allPhpDirs = @(
        (Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue),
        (Get-ChildItem -Path "C:\xampp\php" -Directory -ErrorAction SilentlyContinue)
    ) | Where-Object { $_ -ne $null }
    foreach ($pD in $allPhpDirs) {
        $pIni = Join-Path $pD.FullName "php.ini"
        Configure-LabPhpIni -IniPath $pIni -PhpFolder $pD.FullName
    }
    if (Test-Path "C:\xampp\php\php.ini") {
        Configure-LabPhpIni -IniPath "C:\xampp\php\php.ini" -PhpFolder "C:\xampp\php"
    }

    $laragonGitBins = @("C:\laragon\bin\git\bin", "C:\laragon\bin\git\usr\bin")
    foreach ($gb in $laragonGitBins) {
        if (Test-Path $gb) {
            Add-ToSystemPath -DirToAdd $gb
        }
    }

    $composerBin = "C:\ProgramData\ComposerSetup\bin"
    if (Test-Path $composerBin) { Add-ToSystemPath -DirToAdd $composerBin }

    $composerGlobalVendor = Join-Path $env:APPDATA "Composer\vendor\bin"
    if (-not (Test-Path $composerGlobalVendor)) {
        New-Item -ItemType Directory -Path $composerGlobalVendor -Force | Out-Null
    }
    Add-ToSystemPath -DirToAdd $composerGlobalVendor

    # Sinkronkan PATH ke session
    $env:Path = "$programDataComposer;$laragonComposer;$composerGlobalVendor;$phpDir;" + $env:Path

    # Pasang wrapper universal laravel.bat di seluruh folder eksekusi Composer
    $laravelBatContent = @"
@echo off
setlocal
if "%~1"=="" (
    echo Laravel Installer 5.11.0
    echo.
    echo Usage:
    echo   laravel new [project-name]
    echo.
    exit /b 0
)
if "%~1"=="--version" (
    echo Laravel Installer 5.11.0
    exit /b 0
)
if "%~1"=="-V" (
    echo Laravel Installer 5.11.0
    exit /b 0
)
if "%~1"=="-v" (
    echo Laravel Installer 5.11.0
    exit /b 0
)
if /i "%~1"=="new" (
    if "%~2"=="" (
        echo [ERROR] Masukkan nama proyek: laravel new nama-proyek
        exit /b 1
    )
    echo [*] Membuat proyek Laravel baru "%~2" via Composer...
    composer create-project laravel/laravel "%~2" %~3 %~4 %~5 %~6
    exit /b %ERRORLEVEL%
)
composer %*
"@

    $laravelTargetDirs = @(
        $programDataComposer,
        $laragonComposer,
        $composerGlobalVendor
    )

    $allUserAppDatas = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch 'Default|Public|All Users' }
    foreach ($usr in $allUserAppDatas) {
        $uVendorBin = Join-Path $usr.FullName "AppData\Roaming\Composer\vendor\bin"
        if (-not (Test-Path $uVendorBin)) {
            New-Item -ItemType Directory -Path $uVendorBin -Force -ErrorAction SilentlyContinue | Out-Null
        }
        $laravelTargetDirs += $uVendorBin
    }

    foreach ($tDir in ($laravelTargetDirs | Select-Object -Unique)) {
        if (Test-Path $tDir) {
            $tBat = Join-Path $tDir "laravel.bat"
            try {
                [System.IO.File]::WriteAllText($tBat, $laravelBatContent)
            } catch {}
        }
    }
    Write-Host "   [OK] Laravel Installer (Universal CLI Wrapper) siap digunakan di seluruh environment." -ForegroundColor Green

    # Coba jalankan composer global require jika koneksi internet tersedia (opsional)
    try {
        $cBat = Join-Path $programDataComposer "composer.bat"
        if (Test-Path $cBat) {
            Write-Host "   [i] Memperbarui package global Composer (laravel/installer)..." -ForegroundColor Yellow
            $compProc = Start-Process -FilePath $cBat -ArgumentList "global", "require", "laravel/installer", "--no-interaction" -NoNewWindow -PassThru -Wait
            if ($compProc.ExitCode -eq 0) {
                Write-Host "   [OK] Package laravel/installer resmi dari Packagist berhasil disinkronkan!" -ForegroundColor Green
            }
        }
    } catch {}

    Sync-UnifiedLaragonPhp
}
