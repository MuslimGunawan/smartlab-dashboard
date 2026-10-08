# ==============================================================================
# MODUL 01: CORE HELPERS & UTILITIES (SMARTLAB LAB TI UNIMAL)
# ==============================================================================

function Invoke-LabKeepAlive {
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys("{F15}")
    } catch {}
}

function Test-WingetAvailable {
    try {
        $testOut = & winget --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $testOut -match '^\s*v?\d+\.\d+' -and $testOut -notmatch 'No applicable app licenses found') {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

function Show-SmartLabBanner {
    Write-Host "  +----------------------------------------------------------------------------+" -ForegroundColor Cyan
    $mainBanner = "SMARTLAB TI | STANDARISASI LABORATORIUM KOMPUTER [v$SCRIPT_CURRENT_VERSION]"
    Write-Host ("  | {0,-74} |" -f $mainBanner) -ForegroundColor Cyan
    Write-Host "  | Teknik Informatika * Universitas Malikussaleh (UNIMAL)                     |" -ForegroundColor DarkCyan
    Write-Host "  +----------------------------------------------------------------------------+" -ForegroundColor Cyan
    if ($script:IsAdmin) {
        Write-Host "  | Hak Akses Sesi : " -NoNewline -ForegroundColor Gray
        Write-Host "* ADMINISTRATOR (Full Elevated Access)                    " -NoNewline -ForegroundColor Green
        Write-Host "|" -ForegroundColor Cyan
    } else {
        Write-Host "  | Hak Akses Sesi : " -NoNewline -ForegroundColor Gray
        Write-Host "^ PENGGUNA STANDAR (Non-Admin / User Scope Only)           " -NoNewline -ForegroundColor Yellow
        Write-Host "|" -ForegroundColor Cyan
    }
    Write-Host "  +----------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

function Add-ToSystemPath {
    param ([string]$DirToAdd)
    if ([string]::IsNullOrWhiteSpace($DirToAdd) -or !(Test-Path $DirToAdd)) { return }

    $target = if ($script:IsAdmin) { [EnvironmentVariableTarget]::Machine } else { [EnvironmentVariableTarget]::User }
    $scopeName = if ($script:IsAdmin) { "System (Machine)" } else { "User" }

    try {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)
        $paths = if ($currentPath) { $currentPath -split ';' | Where-Object { $_ -ne "" } } else { @() }

        if ($paths -notcontains $DirToAdd) {
            $newPath = if ($currentPath) { "$currentPath;$DirToAdd" } else { $DirToAdd }
            [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
            $env:Path = "$env:Path;$DirToAdd"
            Write-Host "   [PATH] Ditambahkan ke PATH ($scopeName): $DirToAdd" -ForegroundColor Green
        } else {
            Write-Host "   [PATH] Sudah terdaftar di PATH ($scopeName): $DirToAdd" -ForegroundColor Cyan
        }
    } catch {
        try {
            $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
            $uPaths = if ($userPath) { $userPath -split ';' | Where-Object { $_ -ne "" } } else { @() }
            if ($uPaths -notcontains $DirToAdd) {
                $newUPath = if ($userPath) { "$userPath;$DirToAdd" } else { $DirToAdd }
                [Environment]::SetEnvironmentVariable("Path", $newUPath, [EnvironmentVariableTarget]::User)
                $env:Path = "$env:Path;$DirToAdd"
                Write-Host "   [PATH] Ditambahkan ke User PATH (Fallback): $DirToAdd" -ForegroundColor Green
            }
        } catch {
            Write-Host "   [PATH] Gagal menyimpan ke registry PATH: $_" -ForegroundColor Yellow
        }
    }
}

function Set-SystemEnvVar {
    param ([string]$Name, [string]$Value)
    $target = if ($script:IsAdmin) { [EnvironmentVariableTarget]::Machine } else { [EnvironmentVariableTarget]::User }
    $scopeName = if ($script:IsAdmin) { "Machine" } else { "User" }
    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, $target)
        [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
        Write-Host "   [ENV] $Name = $Value ($scopeName)" -ForegroundColor Green
    } catch {
        try {
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::User)
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
            Write-Host "   [ENV] $Name = $Value (User Fallback)" -ForegroundColor Green
        } catch {
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
            Write-Host "   [ENV] $Name = $Value (Process Saja)" -ForegroundColor Yellow
        }
    }
}

function Convert-ArgsToArray([string]$arguments) {
    if ([string]::IsNullOrWhiteSpace($arguments)) { return @() }
    $regex = [regex]'(?:[^\s"]+|"[^"]*")+'
    $matches = $regex.Matches($arguments)
    $list = @()
    foreach ($m in $matches) {
        $val = $m.Value
        if ($val.StartsWith('"') -and $val.EndsWith('"') -and $val.Length -ge 2) {
            $val = $val.Substring(1, $val.Length - 2)
        }
        $list += $val
    }
    return $list
}

function Create-AppShortcut {
    param (
        [string]$TargetExe,
        [string]$ShortcutName,
        [string]$WorkingDir = "",
        [string]$Arguments = "",
        [switch]$StartMenuOnly
    )
    if (-not (Test-Path $TargetExe)) { return }
    if ([string]::IsNullOrWhiteSpace($WorkingDir)) {
        $WorkingDir = Split-Path -Parent $TargetExe
    }

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $desktopDir = if ($script:IsAdmin) {
            [Environment]::GetFolderPath("CommonDesktopDirectory")
        } else {
            [Environment]::GetFolderPath("Desktop")
        }

        $programsDir = if ($script:IsAdmin) {
            [Environment]::GetFolderPath("CommonPrograms")
        } else {
            [Environment]::GetFolderPath("Programs")
        }

        $allowedDesktopApps = @(
            "Visual Studio Code",
            "Oracle VM VirtualBox",
            "Oracle VirtualBox",
            "Cisco Packet Tracer",
            "Apache NetBeans",
            "Android Studio",
            "Arduino IDE",
            "QGIS Desktop",
            "Google Chrome",
            "Google Chrome Enterprise",
            "Laragon",
            "XAMPP Control Panel",
            "Embarcadero Delphi",
            "Proteus Design Suite",
            "Visual Studio 2022"
        )

        $isAllowedOnDesktop = (-not $StartMenuOnly) -and ($allowedDesktopApps -contains $ShortcutName -or ($allowedDesktopApps | Where-Object { $ShortcutName -like "*$_*" }))
        $blockedFromDesktop = @("Java", "JDK", "Node", "Git", "7-Zip", "7z", "Python", "Driver Easy", "Extras", "Composer")
        if ($blockedFromDesktop | Where-Object { $ShortcutName -like "*$_*" }) {
            $isAllowedOnDesktop = $false
        }

        if ($isAllowedOnDesktop -and (Test-Path $desktopDir)) {
            $lnk1 = Join-Path $desktopDir "$ShortcutName.lnk"
            $sc1 = $wsh.CreateShortcut($lnk1)
            $sc1.TargetPath = $TargetExe
            $sc1.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc1.Arguments = $Arguments }
            $sc1.Save()
        }

        if (Test-Path $programsDir) {
            $lnk2 = Join-Path $programsDir "$ShortcutName.lnk"
            $sc2 = $wsh.CreateShortcut($lnk2)
            $sc2.TargetPath = $TargetExe
            $sc2.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc2.Arguments = $Arguments }
            $sc2.Save()
        }
    } catch {}
}

function Clean-LabDesktopIcons {
    Write-Host "`n   [>>>] Mengoptimalkan & merapikan ikon Desktop Lab TI..." -ForegroundColor Cyan

    $desktopDirs = @(
        [Environment]::GetFolderPath("CommonDesktopDirectory"),
        [Environment]::GetFolderPath("Desktop"),
        "C:\Users\Public\Desktop"
    )
    if ($env:USERPROFILE) {
        $desktopDirs += (Join-Path $env:USERPROFILE "Desktop")
        $desktopDirs += (Join-Path $env:USERPROFILE "OneDrive\Desktop")
    }
    $desktopDirs = $desktopDirs | Select-Object -Unique | Where-Object { Test-Path $_ }

    $clutterPatterns = @(
        "*Git Bash*.lnk",
        "*Git GUI*.lnk",
        "*Git for Windows*.lnk",
        "*7-Zip*.lnk",
        "*7z*.lnk",
        "*Node.js*.lnk",
        "*Nodejs*.lnk",
        "*Java JDK*.lnk",
        "*OpenJDK*.lnk",
        "*Temurin*.lnk",
        "*Driver Easy*.lnk",
        "*Extras*.lnk",
        "*Python*.lnk",
        "*Composer*.lnk"
    )

    foreach ($dir in $desktopDirs) {
        foreach ($pattern in $clutterPatterns) {
            $junkFiles = Get-ChildItem -Path $dir -Filter $pattern -File -ErrorAction SilentlyContinue
            foreach ($jf in $junkFiles) {
                try {
                    Remove-Item -Path $jf.FullName -Force -ErrorAction SilentlyContinue
                    Write-Host "   [x] Menghapus ikon latar/CLI dari desktop: $($jf.Name)" -ForegroundColor DarkGray
                } catch {}
            }
        }
    }

    $commonDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
    $userDesktop = [Environment]::GetFolderPath("Desktop")
    if ($commonDesktop -and $userDesktop -and (Test-Path $commonDesktop) -and (Test-Path $userDesktop) -and ($commonDesktop -ne $userDesktop)) {
        $commonLnks = Get-ChildItem -Path $commonDesktop -Filter "*.lnk" -File -ErrorAction SilentlyContinue
        foreach ($cl in $commonLnks) {
            $dupUserLnk = Join-Path $userDesktop $cl.Name
            if (Test-Path $dupUserLnk) {
                Remove-Item -Path $dupUserLnk -Force -ErrorAction SilentlyContinue
                Write-Host "   [x] Menghapus duplikat user desktop: $($cl.Name)" -ForegroundColor DarkGray
            }
        }
    }

    foreach ($dir in $desktopDirs) {
        $vboxLnk1 = Join-Path $dir "Oracle VM VirtualBox.lnk"
        $vboxLnk2 = Join-Path $dir "Oracle VirtualBox.lnk"
        if ((Test-Path $vboxLnk1) -and (Test-Path $vboxLnk2)) {
            Remove-Item -Path $vboxLnk2 -Force -ErrorAction SilentlyContinue
            Write-Host "   [x] Menghapus duplikat shortcut: Oracle VirtualBox.lnk (Menyimpan Oracle VM VirtualBox.lnk)" -ForegroundColor DarkGray
        }
    }

    foreach ($dir in $desktopDirs) {
        $ciscoLnks = Get-ChildItem -Path $dir -Filter "*Packet*Tracer*.lnk" -File -ErrorAction SilentlyContinue
        if ($ciscoLnks -and $ciscoLnks.Count -gt 1) {
            $keep = $ciscoLnks[0]
            for ($i = 1; $i -lt $ciscoLnks.Count; $i++) {
                Remove-Item -Path $ciscoLnks[$i].FullName -Force -ErrorAction SilentlyContinue
                Write-Host "   [x] Menghapus duplikat shortcut: $($ciscoLnks[$i].Name)" -ForegroundColor DarkGray
            }
        }
    }

    foreach ($dir in $desktopDirs) {
        $chromeLnk1 = Join-Path $dir "Google Chrome.lnk"
        $chromeLnk2 = Join-Path $dir "Google Chrome Enterprise.lnk"
        if ((Test-Path $chromeLnk1) -and (Test-Path $chromeLnk2)) {
            Remove-Item -Path $chromeLnk2 -Force -ErrorAction SilentlyContinue
            Write-Host "   [x] Menghapus duplikat shortcut: Google Chrome Enterprise.lnk (Menyimpan Google Chrome.lnk)" -ForegroundColor DarkGray
        }
    }

    foreach ($dir in $desktopDirs) {
        $geLnks = Get-ChildItem -Path $dir -Filter "*Google*Earth*.lnk" -File -ErrorAction SilentlyContinue
        if ($geLnks -and $geLnks.Count -gt 1) {
            $keep = $geLnks[0]
            for ($i = 1; $i -lt $geLnks.Count; $i++) {
                Remove-Item -Path $geLnks[$i].FullName -Force -ErrorAction SilentlyContinue
                Write-Host "   [x] Menghapus duplikat shortcut: $($geLnks[$i].Name)" -ForegroundColor DarkGray
            }
        }
    }

    try {
        $shell = New-Object -ComObject Shell.Application
        $shell.Namespace(0).Self.InvokeVerb("refresh")
    } catch {}

    Write-Host "   [OK] Desktop tertata rapi! Hanya aplikasi GUI praktikum utama yang tampil di layar." -ForegroundColor Green
}

function Expand-LabArchive {
    param (
        [string]$ArchivePath,
        [string]$DestinationDir
    )
    if (-not (Test-Path $ArchivePath)) { return $false }
    if (-not (Test-Path $DestinationDir)) { New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null }

    $sevenZip = "C:\Program Files\7-Zip\7z.exe"
    $sevenZipX86 = "C:\Program Files (x86)\7-Zip\7z.exe"
    $winRar = "C:\Program Files\WinRAR\WinRAR.exe"
    $tarCmd = Get-Command tar.exe -ErrorAction SilentlyContinue

    $archiveName = Split-Path -Leaf $ArchivePath
    Write-Host "   [i] Mengekstrak arsip instalasi: $archiveName ..." -ForegroundColor Yellow

    if (Test-Path $sevenZip) {
        $p = Start-Process -FilePath $sevenZip -ArgumentList "x `"$ArchivePath`" `"-o$DestinationDir`" -y" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }
    if (Test-Path $sevenZipX86) {
        $p = Start-Process -FilePath $sevenZipX86 -ArgumentList "x `"$ArchivePath`" `"-o$DestinationDir`" -y" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    if (Test-Path $winRar) {
        $p = Start-Process -FilePath $winRar -ArgumentList "x -ibck -inul -y `"$ArchivePath`" `"$DestinationDir\`"" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    if ($tarCmd) {
        $p = Start-Process -FilePath $tarCmd.Source -ArgumentList "-xf `"$ArchivePath`" -C `"$DestinationDir`"" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    if ($ArchivePath -match '\.zip$') {
        $zipSuccess = $false
        try {
            Expand-Archive -Path $ArchivePath -DestinationPath $DestinationDir -Force -ErrorAction Stop
            $zipSuccess = $true
        } catch {}
        if ($zipSuccess) { return $true }
    }

    Write-Host "   [!] Tidak ditemukan ekstraktor yang cocok untuk format arsip $archiveName." -ForegroundColor Yellow
    return $false
}

$script:LastDownloadedFile = ""

function Download-FileWithFastMirrors {
    param (
        [object]$Urls,
        [string]$DestinationPath,
        [string]$ActivityTitle = "Mengunduh Berkas"
    )

    $urlList = @($Urls)
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $parentDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }

    $cookieJar = New-Object System.Net.CookieContainer
    $downloadSuccess = $false

    foreach ($url in $urlList) {
        if ([string]::IsNullOrWhiteSpace($url)) { continue }
        $cleanHost = ($url -split '/')[2]
        Write-Host "   -> Mencoba server unduh: $cleanHost ..." -ForegroundColor DarkCyan

        $actualUrl = $url
        $gdriveId = $null
        if ($url -match 'drive\.google\.com') {
            if ($url -match 'id=([a-zA-Z0-9_-]+)') {
                $gdriveId = $matches[1]
            } elseif ($url -match '/d/([a-zA-Z0-9_-]+)') {
                $gdriveId = $matches[1]
            }
            if ($gdriveId) {
                $actualUrl = "https://drive.usercontent.google.com/download?id=$gdriveId&export=download&confirm=t"
            }
        }

        $targetFile = $null
        $responseStream = $null
        $response = $null
        $currentDest = $DestinationPath
        try {
            $request = [System.Net.HttpWebRequest]::Create($actualUrl)
            $request.Timeout = 20000
            $request.ReadWriteTimeout = 60000
            $request.CookieContainer = $cookieJar
            if ($actualUrl -match 'sourceforge\.net') {
                $request.UserAgent = "curl/8.4.0"
            } else {
                $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            }
            $response = $request.GetResponse()

            $contentType = $response.ContentType
            if (($url -match 'drive\.google\.com') -and ($contentType -match 'text/html')) {
                $htmlReader = New-Object System.IO.StreamReader($response.GetResponseStream(), [System.Text.Encoding]::UTF8)
                $htmlBody = $htmlReader.ReadToEnd()
                $htmlReader.Close()
                $response.Close()

                if ($htmlBody -match "quota exceeded" -or $htmlBody -match "kuota terlampaui" -or $htmlBody -match "akses terlampaui") {
                    Write-Host "      [!] Kuota harian Google Drive mirror ini penuh. Berpindah ke salinan berikutnya..." -ForegroundColor DarkYellow
                    continue
                }

                $confirmToken = $null
                if ($htmlBody -match 'confirm=([0-9a-zA-Z_-]+)') {
                    $confirmToken = $matches[1]
                } elseif ($htmlBody -match 'name="confirm"\s+value="([^"]+)"') {
                    $confirmToken = $matches[1]
                }

                if ($confirmToken -and $gdriveId) {
                    $actualUrl = "https://docs.google.com/uc?export=download&id=$gdriveId&confirm=$confirmToken"
                    $request = [System.Net.HttpWebRequest]::Create($actualUrl)
                    $request.Timeout = 20000
                    $request.ReadWriteTimeout = 60000
                    $request.CookieContainer = $cookieJar
                    $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                    $response = $request.GetResponse()
                }
            }

            $contentDisp = $response.Headers["Content-Disposition"]
            $serverName = $null
            if ($contentDisp -and ($contentDisp -match 'filename="?([^";]+)"?')) {
                $serverName = [System.IO.Path]::GetFileName($matches[1].Trim())
            }

            $currentBase = [System.IO.Path]::GetFileName($currentDest)
            if (-not [string]::IsNullOrWhiteSpace($serverName)) {
                $currentDest = Join-Path $parentDir $serverName
            } elseif (($currentBase -ieq "view") -or (-not ([System.IO.Path]::HasExtension($currentDest)))) {
                $fallbackSafe = ($ActivityTitle -replace 'Mengunduh\s*', '' -replace '[^a-zA-Z0-9_-]', '_') + ".exe"
                $currentDest = Join-Path $parentDir $fallbackSafe
            }

            $totalBytes = $response.ContentLength
            $responseStream = $response.GetResponseStream()

            $targetFile = New-Object System.IO.FileStream($currentDest, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $buffer = New-Object byte[] 65536
            $downloadedBytes = 0
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $lastReport = [System.Diagnostics.Stopwatch]::StartNew()

            while (($bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $targetFile.Write($buffer, 0, $bytesRead)
                $downloadedBytes += $bytesRead

                if ($lastReport.ElapsedMilliseconds -gt 300) {
                    Invoke-LabKeepAlive
                    $percent = if ($totalBytes -gt 0) { [math]::Min(100, [int](($downloadedBytes / $totalBytes) * 100)) } else { 0 }
                    $speedKBps = if ($sw.Elapsed.TotalSeconds -gt 0) { [math]::Round(($downloadedBytes / 1024) / $sw.Elapsed.TotalSeconds, 1) } else { 0 }
                    $speedMBps = [math]::Round($speedKBps / 1024, 2)
                    $mbDownloaded = [math]::Round($downloadedBytes / 1MB, 2)
                    $mbTotal = if ($totalBytes -gt 0) { [math]::Round($totalBytes / 1MB, 2) } else { 0 }

                    $barLength = 20
                    $completedBars = [int]($percent / (100 / $barLength))
                    $remainingBars = $barLength - $completedBars
                    $barStr = ("#" * $completedBars) + ("-" * $remainingBars)

                    Write-Progress -Activity "$ActivityTitle" -Status "[$barStr] $percent% ($mbDownloaded MB / $mbTotal MB) @ $speedMBps MB/s" -PercentComplete $percent
                    $lastReport.Restart()
                }
            }

            Write-Progress -Activity "$ActivityTitle" -Completed
            $targetFile.Close()
            $responseStream.Close()
            $response.Close()

            $fInfo = Get-Item $currentDest -ErrorAction SilentlyContinue
            if ($fInfo) {
                $destExt = [System.IO.Path]::GetExtension($currentDest).ToLower()
                $isBinaryTarget = ($destExt -match '\.(exe|msi|zip|rar|7z|vbox-extpack)$')
                if ($isBinaryTarget -and ($contentType -match 'text/html')) {
                    $targetFile = $null
                    Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                    Write-Host "      [!] Server mengembalikan dokumen HTML (bukan installer biner). Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                    continue
                }

                if (($fInfo.Length -lt 500000) -and ($url -match 'drive\.google\.com')) {
                    $checkTxt = [System.IO.File]::ReadAllText($currentDest)
                    if (($checkTxt -match "<html") -or ($checkTxt -match "quota exceeded") -or ($checkTxt -match "kuota terlampaui")) {
                        Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                        Write-Host "      [!] Google Drive mirror ini limit/kuota terlampaui. Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                        continue
                    }
                }

                if ($isBinaryTarget -and ($fInfo.Length -lt 1048576)) {
                    $checkTxt = ""
                    try { $checkTxt = [System.IO.File]::ReadAllText($currentDest) } catch {}
                    if ($checkTxt -match "<html") {
                        Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                        Write-Host "      [!] File terunduh adalah halaman web/error ($([math]::Round($fInfo.Length/1KB,1)) KB). Dihapus & berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                        continue
                    }
                }

                if ($totalBytes -gt 0 -and ($downloadedBytes -lt $totalBytes)) {
                    Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                    Write-Host "      [!] Unduhan terputus sebelum selesai ($downloadedBytes / $totalBytes bytes). Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                    continue
                }
            }

            $script:LastDownloadedFile = $currentDest
            $downloadSuccess = $true
            break
        } catch {
            Write-Progress -Activity "$ActivityTitle" -Completed
            if ($targetFile) { $targetFile.Close() }
            if ($responseStream) { $responseStream.Close() }
            if ($response) { $response.Close() }
            if (Test-Path $currentDest) { Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue }
            $errMsg = $_.Exception.Message
            Write-Host "      [!] Server $cleanHost lambat/gagal: $errMsg. Mencoba mirror cadangan..." -ForegroundColor DarkYellow
        }
    }
    return $downloadSuccess
}

$script:InstallResults = @()

function Record-InstallResult {
    param (
        [string]$Name,
        [string]$Status,
        [string]$Keterangan
    )
    $existing = $script:InstallResults | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
    if ($existing) {
        $existing.Status = $Status
        $existing.Keterangan = $Keterangan
    } else {
        $script:InstallResults += [PSCustomObject]@{
            Name       = $Name
            Status     = $Status
            Keterangan = $Keterangan
        }
    }
}

function Install-AppSmart {
    param (
        [string]$Name,
        [object]$FilePattern,
        [string]$SilentArgs = "",
        [string]$WingetId = "",
        [string]$WingetArgs = "",
        [object]$DownloadUrls = $null,
        [object]$CheckPath = $null,
        [switch]$IsInteractive
    )

    $boxTitle = "  [>] MEMPROSES: $Name "
    $padding = [math]::Max(0, 76 - $boxTitle.Length)
    Write-Host "`n  +$('-' * 76)+" -ForegroundColor DarkCyan
    Write-Host "  |" -NoNewline -ForegroundColor DarkCyan
    Write-Host "$boxTitle" -NoNewline -ForegroundColor Cyan
    Write-Host (" " * $padding) -NoNewline
    Write-Host "|" -ForegroundColor DarkCyan
    Write-Host "  +$('-' * 76)+" -ForegroundColor DarkCyan

    if ($CheckPath) {
        $checkList = @($CheckPath)
        foreach ($cp in $checkList) {
            $item = $null
            if ($cp -like "*\*" -or $cp -like "*/*") {
                if ($cp -match '\*') {
                    $item = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                } elseif (Test-Path $cp) {
                    $item = Get-Item $cp -ErrorAction SilentlyContinue
                }
            } else {
                $cmd = Get-Command $cp -ErrorAction SilentlyContinue
                if ($cmd) { $item = $cmd }
            }

            if ($item) {
                Write-Host "[OK SUDAH TERPASANG] $Name terdeteksi aktif di sistem." -ForegroundColor Green
                if ($item.FullName) {
                    Create-AppShortcut -TargetExe $item.FullName -ShortcutName $Name
                }
                Record-InstallResult -Name $Name -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
                return
            }
        }
    }

    $patterns = @($FilePattern)
    $installerFile = $null

    foreach ($pat in $patterns) {
        $candidates = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue
        foreach ($cand in $candidates) {
            if ($cand.Length -lt 512000) {
                $isBad = $false
                try {
                    $txt = [System.IO.File]::ReadAllText($cand.FullName)
                    if ($txt -match "<html" -or $txt -match "quota exceeded") { $isBad = $true }
                } catch {}
                if ($isBad) {
                    Remove-Item -Path $cand.FullName -Force -ErrorAction SilentlyContinue
                    continue
                }
            }
            $installerFile = $cand
            break
        }
        if ($installerFile) { break }
    }

    $archiveCandidates = @(
        "*$($Name -replace '\s+','*')*.rar",
        "*$($Name -replace '\s+','*')*.zip",
        "*$($Name -replace '\s+','*')*.7z"
    )
    if (-not $installerFile) {
        foreach ($arcPat in $archiveCandidates) {
            $arcFile = Get-ChildItem -Path $AppsDir -Filter $arcPat -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($arcFile) {
                Write-Host "[i] Ditemukan file arsip untuk $Name : $($arcFile.Name)" -ForegroundColor Yellow
                $extractTarget = Join-Path $AppsDir ($Name -replace '\s+','_')
                $extracted = Expand-LabArchive -ArchivePath $arcFile.FullName -DestinationDir $extractTarget
                if ($extracted) {
                    foreach ($pat in $patterns) {
                        $installerFile = Get-ChildItem -Path $extractTarget -Filter $pat -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($installerFile) { break }
                    }
                }
                if ($installerFile) { break }
            }
        }
    }

    if (-not $installerFile -and $DownloadUrls) {
        Write-Host "[i] File master offline belum ada di folder Apps/. Mengunduh otomatis..." -ForegroundColor Yellow
        $firstPattern = $patterns[0] -replace '\*',''
        $ext = if ($firstPattern -match '\.(exe|msi|zip|rar|7z)$') { [System.IO.Path]::GetExtension($firstPattern) } else { ".exe" }
        $safeBase = ($Name -replace '[^a-zA-Z0-9_-]', '_') + $ext
        $destPath = Join-Path $AppsDir $safeBase

        $dlSuccess = Download-FileWithFastMirrors -Urls $DownloadUrls -DestinationPath $destPath -ActivityTitle "Mengunduh $Name"
        if ($dlSuccess -and (Test-Path $script:LastDownloadedFile)) {
            $downloadedCandidate = Get-Item $script:LastDownloadedFile
            if ($downloadedCandidate.Extension -match '\.(zip|rar|7z)$') {
                $extractTarget = Join-Path $AppsDir ($Name -replace '\s+','_')
                Expand-LabArchive -ArchivePath $downloadedCandidate.FullName -DestinationDir $extractTarget
                foreach ($pat in $patterns) {
                    $installerFile = Get-ChildItem -Path $extractTarget -Filter $pat -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($installerFile) { break }
                }
            } else {
                $installerFile = $downloadedCandidate
            }
        }
    }

    if ($installerFile) {
        Write-Host "[OK] Ditemukan file installer: $($installerFile.Name)" -ForegroundColor Green

        if ($IsInteractive) {
            Write-Host "[*] Membuka jendela instalasi resmi $Name..." -ForegroundColor Cyan
            Write-Host "    (Silakan ikuti petunjuk pada layar dan selesaikan wizard instalasi)." -ForegroundColor Gray
            $proc = Start-Process -FilePath $installerFile.FullName -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "[OK] Instalasi $Name selesai!" -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Instalasi interaktif selesai"
            } else {
                Write-Host "[!] Jendela installer $Name ditutup dengan kode: $($proc.ExitCode)" -ForegroundColor Yellow
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Instalasi interaktif (Exit: $($proc.ExitCode))"
            }
        } else {
            Write-Host "[*] Menginstal $Name secara otomatis di latar belakang..." -ForegroundColor Cyan

            if ($installerFile.Extension -ieq ".msi") {
                # msiexec flags: filter out exe switches like /S, /VERYSILENT, /silent, /SILENT
                $rawArgs = Convert-ArgsToArray $SilentArgs
                $validMsiArgs = @("/i", "`"$($installerFile.FullName)`"")
                $hasQuiet = $false
                foreach ($a in $rawArgs) {
                    if ($a -match '^(ALLUSERS=|ADDLOCAL=|TRANSFORMS=|TARGETDIR=|INSTALLDIR=|[a-zA-Z0-9_]+=)') {
                        $validMsiArgs += $a
                    } elseif ($a -match '^\/(qn|qb|quiet|passive|norestart|promptrestart)') {
                        $validMsiArgs += $a
                        if ($a -match 'qn|quiet|passive') { $hasQuiet = $true }
                    }
                }
                if (-not $hasQuiet) { $validMsiArgs += @("/qn", "/norestart") }
                
                $logFile = Join-Path $env:TEMP ("msi_" + ($Name -replace '[^a-zA-Z0-9]', '_') + ".log")
                $validMsiArgs += @("/l*v", "`"$logFile`"")

                $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $validMsiArgs -Wait -PassThru -NoNewWindow
                
                # Jika error 1603 (Fatal error), coba fallback tanpa ALLUSERS=1 atau via UI pasif
                if ($proc -and $proc.ExitCode -eq 1603) {
                    Write-Host "   [i] Mencoba pemasangan ulang $Name (mode pasif/standar)..." -ForegroundColor Yellow
                    $fallbackMsi = @("/i", "`"$($installerFile.FullName)`"", "/qn", "/norestart")
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $fallbackMsi -Wait -PassThru -NoNewWindow
                }
            } else {
                $argsList = Convert-ArgsToArray $SilentArgs
                $proc = Start-Process -FilePath $installerFile.FullName -ArgumentList $argsList -Wait -PassThru
            }

            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "[OK] Berhasil menginstal $Name!" -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Instalasi otomatis sukses"
            } else {
                Write-Host "[!] Installer $Name keluar dengan kode: $($proc.ExitCode)" -ForegroundColor Yellow
                Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Kode keluar installer: $($proc.ExitCode)"
            }
        }

        if ($CheckPath) {
            $checkList = @($CheckPath)
            foreach ($cp in $checkList) {
                if ($cp -like "*\*" -or $cp -like "*/*") {
                    $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                    if (-not $f) { $f = Get-Item -Path $cp -ErrorAction SilentlyContinue }
                    if ($f) { Create-AppShortcut -TargetExe $f.FullName -ShortcutName $Name; break }
                }
            }
        }
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($WingetId) -and (Test-WingetAvailable)) {
        Write-Host "[i] Master offline belum ada. Mengunduh & menginstal via Winget ($WingetId)..." -ForegroundColor Yellow
        $wingetDownloadedSuccess = $false
        try {
            $dlResult = & winget download --id "$WingetId" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0) {
                $downloadedFiles = Get-ChildItem -Path $AppsDir -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) }
                $wInstaller = $downloadedFiles | Where-Object { $_.Extension -match "exe|msi" } | Select-Object -First 1
                if ($wInstaller) {
                    Write-Host "[OK] Winget berhasil mengunduh file master: $($wInstaller.Name)" -ForegroundColor Green
                    $wSilent = if (-not [string]::IsNullOrWhiteSpace($SilentArgs)) { $SilentArgs } else { "/silent /norestart /qn /S /VERYSILENT" }
                    $wArgs = Convert-ArgsToArray $wSilent
                    if ($wInstaller.Extension -ieq ".msi") {
                        Start-Process -FilePath "msiexec.exe" -ArgumentList (@("/i", "`"$($wInstaller.FullName)`"") + $wArgs) -Wait -NoNewWindow
                    } else {
                        Start-Process -FilePath $wInstaller.FullName -ArgumentList $wArgs -Wait
                    }
                    if ($CheckPath) {
                        foreach ($cp in @($CheckPath)) {
                            $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                            if ($f) { Create-AppShortcut -TargetExe $f.FullName -ShortcutName $Name; break }
                        }
                    }
                    Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terunduh & terpasang via Winget"
                    $wingetDownloadedSuccess = $true
                }
            }
        } catch {
            Write-Host "[!] Unduhan installer offline via Winget dilewati: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
        if ($wingetDownloadedSuccess) { return }

        try {
            $installed = & winget list --id "$WingetId" --source winget 2>$null
            if ($LASTEXITCODE -eq 0 -and $installed -match $WingetId) {
                Write-Host "[OK] $Name sudah terinstal di sistem ini." -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi via Winget (Skip)"
                return
            }

            $wArgsList = @("install", "--id", "$WingetId", "--source", "winget", "-e", "--silent", "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity")
            if (-not [string]::IsNullOrWhiteSpace($WingetArgs)) {
                $extraW = Convert-ArgsToArray $WingetArgs
                if ($extraW) { $wArgsList += $extraW }
            }
            $pWinget = Start-Process -FilePath "winget.exe" -ArgumentList $wArgsList -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue

            if ($pWinget -and ($pWinget.ExitCode -eq 0 -or $pWinget.ExitCode -eq 3010)) {
                Write-Host "[OK] Berhasil menginstal $Name via Winget!" -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang via Winget Direct"
            } else {
                Write-Host "[!] Pemasangan $Name via Winget tidak berhasil (Exit: $($pWinget.ExitCode))." -ForegroundColor DarkYellow
                Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Winget error / offline"
            }
        } catch {
            Write-Host "[!] Eksekusi Winget gagal: $($_.Exception.Message)" -ForegroundColor DarkYellow
            Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Winget tidak tersedia"
        }
    } else {
        Write-Host "[!] File installer offline $Name ($FilePattern) belum ada di folder Apps/." -ForegroundColor Yellow
        Write-Host "    (Silakan salin installer pihak ketiga $Name ke folder Apps dan jalankan kembali)." -ForegroundColor Gray
        Record-InstallResult -Name $Name -Status "BELUM TERSEDIA" -Keterangan "Menunggu file master di Apps/"
    }
}
