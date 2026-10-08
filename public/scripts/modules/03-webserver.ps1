# ==============================================================================
# MODUL 03: WEB SERVER & DATABASE STACK (SMARTLAB LAB TI UNIMAL)
# Laragon (WAMP Stack + Custom Overlay), Sync-UnifiedLaragonPhp,
# XAMPP Server (Port Anti-Bentrok: 8088/8444/3307), Composer & Laravel Setup
# ==============================================================================

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

            Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
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

    $allPhpDirs = Get-ChildItem -Path "$targetLaragon\bin\php" -Directory -ErrorAction SilentlyContinue
    if ($allPhpDirs) {
        $newestPhpDir = $allPhpDirs | Sort-Object {
            if ($_.Name -match '(\d+(?:\.\d+)+)') {
                try {
                    $vParts = $matches[1].Split('.')
                    $major = [int]$vParts[0]
                    $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                    $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                    [Version]::new($major, $minor, $build)
                } catch { [Version]::new(0, 0, 0) }
            } else { [Version]::new(0, 0, 0) }
        } -Descending | Select-Object -First 1

        $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
        if (Test-Path $usrLaragonIni) {
            try {
                $iniTxt = [System.IO.File]::ReadAllText($usrLaragonIni)
                if ($iniTxt -match '(?m)^Version=.*$') {
                    $newIniTxt = $iniTxt -replace '(?m)^Version=.*$', "Version=$($newestPhpDir.Name)"
                    [System.IO.File]::WriteAllText($usrLaragonIni, $newIniTxt)
                }
            } catch {}
        }
    }

    $phpInis = Get-ChildItem -Path "$targetLaragon\bin\php" -Filter "php.ini" -Recurse -File -ErrorAction SilentlyContinue
    foreach ($pIni in $phpInis) {
        try {
            $iniText = [System.IO.File]::ReadAllText($pIni.FullName)
            $phpFolder = $pIni.Directory.FullName
            $extDir = Join-Path $phpFolder "ext"

            $hasZipDll = (Test-Path (Join-Path $extDir "php_zip.dll")) -or (Test-Path (Join-Path $extDir "zip.dll"))
            if ($hasZipDll) {
                $iniText = $iniText -replace '(?m)^;\s*extension\s*=\s*zip\b', 'extension=zip'
                $iniText = $iniText -replace '(?m)^;\s*extension\s*=\s*php_zip\.dll\b', 'extension=php_zip.dll'
                if ($iniText -notmatch '(?m)^extension\s*=\s*(zip|php_zip\.dll)\b') { $iniText += "`r`nextension=zip`r`n" }
            } else {
                $iniText = $iniText -replace '(?m)^\s*extension\s*=\s*php_zip\.dll\b', ';extension=php_zip.dll'
                $iniText = $iniText -replace '(?m)^\s*extension\s*=\s*zip\b', ';extension=zip'
            }

            $extList = @("curl", "fileinfo", "openssl", "pdo_mysql", "mysqli", "mbstring", "gd", "intl", "exif", "bcmath", "sodium")
            foreach ($ext in $extList) {
                $hasExtDll = (Test-Path (Join-Path $extDir "php_$ext.dll")) -or (Test-Path (Join-Path $extDir "$ext.dll"))
                if ($hasExtDll -or -not (Test-Path $extDir)) {
                    $iniText = $iniText -replace "(?m)^\s*extension\s*=\s*(?:php_)?$ext(?:\.dll)?\b", ";extension=$ext"
                    $matchedFirst = $false
                    $iniLines = @($iniText -split "`r?`n")
                    for ($li = 0; $li -lt $iniLines.Count; $li++) {
                        if ($iniLines[$li] -match "^\s*;\s*extension\s*=\s*$ext\b") {
                            $iniLines[$li] = "extension=$ext"
                            $matchedFirst = $true
                            break
                        }
                    }
                    if ($matchedFirst) {
                        $iniText = $iniLines -join "`r`n"
                    } else {
                        $iniText += "`r`nextension=$ext`r`n"
                    }
                }
            }

            if (Test-Path $extDir) {
                $escapedExt = $extDir.Replace('\', '/')
                $iniText = $iniText -replace '(?m)^\s*;?\s*extension_dir\s*=\s*"ext"', "extension_dir = `"$escapedExt`""
                $iniText = $iniText -replace '(?m)^\s*;?\s*extension_dir\s*=\s*''ext''', "extension_dir = `"$escapedExt`""
            }

            $iniText = $iniText -replace '(?m)^\s*memory_limit\s*=.*$', 'memory_limit = 512M'
            $iniText = $iniText -replace '(?m)^\s*upload_max_filesize\s*=.*$', 'upload_max_filesize = 128M'
            $iniText = $iniText -replace '(?m)^\s*post_max_size\s*=.*$', 'post_max_size = 128M'
            $iniText = $iniText -replace '(?m)^\s*max_execution_time\s*=.*$', 'max_execution_time = 360'

            if ($iniText -match '(?m)^\s*error_reporting\s*=') {
                $iniText = $iniText -replace '(?m)^\s*error_reporting\s*=.*$', 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT'
            } else {
                $iniText += "`r`nerror_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`r`n"
            }

            [System.IO.File]::WriteAllText($pIni.FullName, $iniText)
        } catch {}
    }

    $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
    if (Test-Path $usrLaragonIni) {
        try {
            $lIniContent = [System.IO.File]::ReadAllText($usrLaragonIni)

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
            Write-Host "   [OK] Konfigurasi C:\laragon\usr\laragon.ini dioptimalkan (Nginx dinonaktifkan dari port 80, Apache & MySQL siap)." -ForegroundColor Green
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
                if ($fcgidText -ne $newFcgidText) {
                    [System.IO.File]::WriteAllText($fcgidConf, $newFcgidText)
                    Write-Host "   [OK] Memperbaiki konfigurasi LoadModule fcgid.conf Laragon." -ForegroundColor Green
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

            if ($newPmaContent -notmatch "PmaNoRelation_DisableWarning") {
                $newPmaContent += "`r`n`$cfg['PmaNoRelation_DisableWarning'] = true;`r`n"
            } else {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['PmaNoRelation_DisableWarning'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            if ($newPmaContent -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            $newPmaContent = $newPmaContent -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controluser.\]\s*=.*$', '// $cfg[''Servers''][$i][''controluser''] = '''';'
            $newPmaContent = $newPmaContent -replace '(?m)^\s*\$cfg\[.Servers.\]\[\$i\]\[.controlpass.\]\s*=.*$', '// $cfg[''Servers''][$i][''controlpass''] = '''';'

            if ($pmaContent -ne $newPmaContent) {
                [System.IO.File]::WriteAllText($laragonPmaConfig, $newPmaContent)
                Write-Host "   [OK] phpMyAdmin Laragon dioptimalkan (Bebas pesan error konfigurasi storage)." -ForegroundColor Green
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
        $laragonProc = Get-Process -Name "laragon" -ErrorAction SilentlyContinue
        if (-not $laragonProc) {
            Write-Host "   [i] Memulai Laragon di latar belakang agar web server langsung siap..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath $laragonExe -WorkingDirectory "C:\laragon" -WindowStyle Minimized -ErrorAction SilentlyContinue
            } catch {}
        }
    }

    Record-InstallResult -Name "Laragon" -Status "BERHASIL DIINSTAL" -Keterangan "Laragon + Custom Stack Siap"
}

# 2. Sinkronisasi Seluruh Ekosistem PHP ke Versi Terbaru Laragon
function Sync-UnifiedLaragonPhp {
    Write-Host "`n   [>>>] Menyatukan seluruh ekosistem PHP ke versi terbaru Laragon (C:\laragon\bin\php)..." -ForegroundColor Cyan

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

        Get-Process -Name "xampp-control", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
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
            $newMyText = [System.Text.RegularExpressions.Regex]::Replace($myText, '(?m)^port\s*=\s*(?!3307\b)\d+\s*$', 'port = 3307')
            if ($myText -ne $newMyText) {
                [System.IO.File]::WriteAllText($myIni, $newMyText)
                Write-Host "   [OK] MySQL Port XAMPP dialihkan ke 3307 (Laragon & Laravel standar tetap di Port 3306)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port MySQL XAMPP sudah diatur pada 3307." -ForegroundColor Green
            }
        }

        $pmaConfig = Join-Path $xamppDir "phpMyAdmin\config.inc.php"
        if (Test-Path $pmaConfig) {
            $pmaText = [System.IO.File]::ReadAllText($pmaConfig)
            $newPmaText = $pmaText

            if ($newPmaText -match "['`"]host['`"]\s*=") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['host'\]\s*=\s*['`"])[^'`"]*(['`"])", '${1}127.0.0.1${2}')
            } else {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['host'] = '127.0.0.1';`r`n"
            }

            if ($newPmaText -notmatch "['`"]port['`"]\s*=") {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['port'] = '3307';`r`n"
            } else {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['port'\]\s*=\s*['`"]?)[^'`"]*?(['`"]?;)", '${1}3307${2}')
            }

            if ($newPmaText -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
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
                Write-Host "   [OK] phpMyAdmin XAMPP dikonfigurasi ke 127.0.0.1:3307" -ForegroundColor Green
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

            [System.IO.File]::WriteAllText($xamppIni, $newIniTxt)
            Write-Host "   [OK] Port pada XAMPP Control Panel disinkronkan ke 8088/8444/3307 & Admin diarahkan ke http://localhost:8088." -ForegroundColor Green
        }

        $shDir = [Environment]::GetFolderPath("Desktop")
        $wsh = New-Object -ComObject WScript.Shell
        try {
            $dashSc = $wsh.CreateShortcut((Join-Path $shDir "XAMPP Dashboard (Port 8088).url"))
            $dashSc.TargetPath = "http://localhost:8088/dashboard/"
            $dashSc.Save()

            $pmaSc = $wsh.CreateShortcut((Join-Path $shDir "XAMPP phpMyAdmin (Port 8088).url"))
            $pmaSc.TargetPath = "http://localhost:8088/phpmyadmin/"
            $pmaSc.Save()
            Write-Host "   [OK] Shortcut Desktop XAMPP Dashboard & phpMyAdmin Port 8088 berhasil dibuat." -ForegroundColor Green
        } catch {}
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

    $composerInstalled = $false
    $composerExe = Get-Command composer -ErrorAction SilentlyContinue
    if ($composerExe) {
        $composerInstalled = $true
    } elseif (Test-Path "C:\ProgramData\ComposerSetup\bin\composer.bat") {
        $composerInstalled = $true
    }

    if ($composerInstalled) {
        Write-Host "   [OK SUDAH TERPASANG] Composer terdeteksi di sistem." -ForegroundColor Green
        try {
            & composer self-update --quiet --no-interaction 2>$null
        } catch {}
        Write-Host "   -> Melewati instalasi Composer (Skip)." -ForegroundColor DarkGray
    } else {
        $composerInstaller = Get-ChildItem -Path $AppsDir -Filter "*Composer*.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $composerInstaller) {
            Write-Host "   [i] File Composer offline belum ada di Apps. Mengunduh Composer-Setup.exe otomatis..." -ForegroundColor Yellow
            try {
                $compUrl = "https://getcomposer.org/Composer-Setup.exe"
                $destPath = Join-Path $AppsDir "Composer-Setup.exe"
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($compUrl, $destPath)
                $wc.Dispose()
                $composerInstaller = Get-Item $destPath -ErrorAction SilentlyContinue
                Write-Host "   [OK] Composer-Setup.exe berhasil diunduh dan disimpan ke folder Apps!" -ForegroundColor Green
            } catch {
                Write-Host "   [!] Gagal mengunduh Composer secara otomatis dari internet: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        if ($composerInstaller) {
            Write-Host "   [OK] Ditemukan installer: $($composerInstaller.Name)" -ForegroundColor Green
            Write-Host "   [i] Menjalankan instalasi Composer secara silent..." -ForegroundColor Yellow
            $cArgs = "/VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES"
            if ($phpPath) {
                $cArgs += " /PHP=`"$phpPath`""
            }
            $proc = Start-Process -FilePath $composerInstaller.FullName -ArgumentList $cArgs -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "   [OK] Berhasil memasang Composer!" -ForegroundColor Green
            }
        }
    }

    $allPhpInis = @(
        (Get-ChildItem -Path "C:\laragon\bin\php\*\php.ini" -File -ErrorAction SilentlyContinue),
        (Get-ChildItem -Path "C:\xampp\php\php.ini" -File -ErrorAction SilentlyContinue)
    ) | Where-Object { $_ -ne $null }

    foreach ($iniFile in $allPhpInis) {
        try {
            $iniContent = [System.IO.File]::ReadAllText($iniFile.FullName)
            $phpDir = $iniFile.Directory.FullName
            $extDir = Join-Path $phpDir "ext"
            $hasZipDll = (Test-Path (Join-Path $extDir "php_zip.dll")) -or (Test-Path (Join-Path $extDir "zip.dll"))

            $newIni = $iniContent
            if ($hasZipDll) {
                $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*zip\b', 'extension=zip'
                $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*php_zip\.dll\b', 'extension=php_zip.dll'
                if ($newIni -notmatch '(?m)^extension\s*=\s*(zip|php_zip\.dll)\b') { $newIni += "`r`nextension=zip`r`n" }
            } else {
                $newIni = $newIni -replace '(?m)^\s*extension\s*=\s*php_zip\.dll\b', ';extension=php_zip.dll'
                $newIni = $newIni -replace '(?m)^\s*extension\s*=\s*zip\b', ';extension=zip'
            }

            $extList = @("curl", "fileinfo", "openssl", "pdo_mysql", "mysqli", "mbstring", "gd", "intl", "exif", "bcmath", "sodium")
            foreach ($ext in $extList) {
                $hasExtDll = (Test-Path (Join-Path $extDir "php_$ext.dll")) -or (Test-Path (Join-Path $extDir "$ext.dll"))
                if ($hasExtDll -or -not (Test-Path $extDir)) {
                    $newIni = $newIni -replace "(?m)^\s*extension\s*=\s*(?:php_)?$ext(?:\.dll)?\b", ";extension=$ext"
                    $matchedFirst = $false
                    $iniLines = @($newIni -split "`r?`n")
                    for ($li = 0; $li -lt $iniLines.Count; $li++) {
                        if ($iniLines[$li] -match "^\s*;\s*extension\s*=\s*$ext\b") {
                            $iniLines[$li] = "extension=$ext"
                            $matchedFirst = $true
                            break
                        }
                    }
                    if ($matchedFirst) {
                        $newIni = $iniLines -join "`r`n"
                    } else {
                        $newIni += "`r`nextension=$ext`r`n"
                    }
                }
            }

            if (Test-Path $extDir) {
                $escapedExt = $extDir.Replace('\', '/')
                $newIni = $newIni -replace '(?m)^\s*;?\s*extension_dir\s*=\s*"ext"', "extension_dir = `"$escapedExt`""
                $newIni = $newIni -replace '(?m)^\s*;?\s*extension_dir\s*=\s*''ext''', "extension_dir = `"$escapedExt`""
            }

            if ($newIni -match '(?m)^\s*error_reporting\s*=') {
                $newIni = $newIni -replace '(?m)^\s*error_reporting\s*=.*$', 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT'
            } else {
                $newIni += "`r`nerror_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`r`n"
            }

            if ($iniContent -ne $newIni) {
                [System.IO.File]::WriteAllText($iniFile.FullName, $newIni)
                Write-Host "   [OK] Konfigurasi php.ini bebas-warning diperbarui: $($iniFile.FullName)" -ForegroundColor Green
            }
        } catch {}
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

    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    if ($phpDir -and $env:Path -notlike "*$phpDir*") {
        $env:Path = "$phpDir;" + $env:Path
    }

    $laravelBat = Join-Path $composerGlobalVendor "laravel.bat"
    if (Test-Path $laravelBat) {
        Write-Host "   [OK SUDAH TERPASANG] Laravel Installer terdeteksi di $laravelBat" -ForegroundColor Green
    } else {
        Write-Host "`n   [i] Menyiapkan Laravel Installer secara global..." -ForegroundColor Yellow
        try {
            $compCmd = Get-Command composer -ErrorAction SilentlyContinue
            if ($compCmd -and (Get-Command php -ErrorAction SilentlyContinue)) {
                & composer global require laravel/installer --quiet --no-interaction
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   [OK] Berhasil memasang Laravel Installer! Perintah 'laravel new' siap digunakan." -ForegroundColor Green
                } else {
                    Write-Host "   [i] Composer global setup selesai (Koneksi online opsional untuk update package)." -ForegroundColor Yellow
                }
            } else {
                Write-Host "   [i] Composer terpasang. Restart PowerShell untuk mengaktifkan perintah 'laravel new'." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   [i] Melewati require online Laravel Installer." -ForegroundColor Gray
        }
    }

    Sync-UnifiedLaragonPhp
}
