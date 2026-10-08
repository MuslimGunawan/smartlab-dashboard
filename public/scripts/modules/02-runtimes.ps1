# ==============================================================================
# MODUL 02: BASE RUNTIMES & EXTRACTORS (SMARTLAB LAB TI UNIMAL)
# 7-Zip, WinRAR, Google Chrome Enterprise, Git for Windows, Java JDK 17, Python, Node.js
# ==============================================================================

# 1. 7-Zip (High-Speed Multi-Format Archive Extractor)
function Setup-7Zip {
    $sevenZipMirrors = @(
        "https://www.7-zip.org/a/7z2408-x64.exe",
        "https://github.com/ip7z/7zip/releases/download/24.08/7z2408-x64.exe"
    )
    Install-AppSmart -Name "7-Zip" `
                     -FilePattern @("*7z*x64*.exe", "*7z*.exe", "*7-zip*.exe", "*7z*.msi") `
                     -DownloadUrls $sevenZipMirrors `
                     -SilentArgs "/S" `
                     -WingetId "7zip.7zip" `
                     -CheckPath @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe")

    $sevenZipPath = "C:\Program Files\7-Zip"
    if (Test-Path $sevenZipPath) {
        Add-ToSystemPath -DirToAdd $sevenZipPath
        if ($env:Path -notlike "*$sevenZipPath*") { $env:Path = "$sevenZipPath;" + $env:Path }
    }
}

# 2. WinRAR (Lab Archive Support .rar/.zip)
function Setup-WinRAR {
    $keyFileInApps = Join-Path $AppsDir "rarreg.key"

    $winRarMirrors = @(
        "https://www.rarlab.com/rar/winrar-x64-723.exe",
        "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-723.exe",
        "https://www.rarlab.com/rar/winrar-x64-701.exe"
    )
    Install-AppSmart -Name "WinRAR" `
                     -FilePattern @("*winrar*x64*.exe", "*winrar*.exe", "*wrar*.exe") `
                     -DownloadUrls $winRarMirrors `
                     -SilentArgs "/s" `
                     -WingetId "RARLab.WinRAR" `
                     -CheckPath @("C:\Program Files\WinRAR\WinRAR.exe", "C:\Program Files (x86)\WinRAR\WinRAR.exe")

    $winRarDirs = @(
        "C:\Program Files\WinRAR",
        "C:\Program Files (x86)\WinRAR",
        "$env:APPDATA\WinRAR"
    )

    foreach ($dir in $winRarDirs) {
        if (Test-Path $dir) {
            Add-ToSystemPath -DirToAdd $dir
            if (Test-Path $keyFileInApps) {
                try {
                    Copy-Item -Path $keyFileInApps -Destination (Join-Path $dir "rarreg.key") -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }
}

# 3. Google Chrome Enterprise (Browser Resmi Lab & Engine Flutter Web)
function Setup-GoogleChrome {
    $chromeMirrors = @(
        "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BADED07C9-40E0-4CB7-8055-2CA3BFD15EF0%7D%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi",
        "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
    )
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )

    Install-AppSmart -Name "Google Chrome Enterprise" `
                     -FilePattern @("*chrome*.msi", "*Chrome*.msi", "*chrome*.exe") `
                     -DownloadUrls $chromeMirrors `
                     -SilentArgs "/qn /norestart" `
                     -WingetId "Google.Chrome" `
                     -CheckPath $chromePaths

    foreach ($cp in $chromePaths) {
        if (Test-Path $cp) {
            Set-SystemEnvVar -Name "CHROME_EXECUTABLE" -Value $cp
            $env:CHROME_EXECUTABLE = $cp
            Add-ToSystemPath -DirToAdd (Split-Path -Parent $cp)
            Write-Host "   [OK] Google Chrome aktif & dikunci untuk Flutter Web: $cp" -ForegroundColor Green
            break
        }
    }
}

# 4. Git for Windows (Wajib untuk Dart SDK, Flutter, Composer, & VS Code)
function Setup-Git {
    $gitMirrors = @(
        "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/Git-2.48.1-64-bit.exe",
        "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe",
        "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    )
    $gitCheckPaths = @(
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files\Git\bin\git.exe",
        "C:\Program Files (x86)\Git\cmd\git.exe"
    )

    Install-AppSmart -Name "Git for Windows" `
                     -FilePattern @("Git-*-64-bit.exe", "Git-*.exe", "*Git*Setup*.exe") `
                     -DownloadUrls $gitMirrors `
                     -SilentArgs "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" `
                     -WingetId "Git.Git" `
                     -CheckPath $gitCheckPaths

    $gitFound = $null
    foreach ($gp in $gitCheckPaths) {
        if (Test-Path $gp) { $gitFound = $gp; break }
    }

    if ($gitFound) {
        $gitDir = Split-Path -Parent $gitFound
        $gitRoot = Split-Path -Parent $gitDir
        $gitCmd = Join-Path $gitRoot "cmd"
        $gitBin = Join-Path $gitRoot "bin"
        $gitUsrBin = Join-Path $gitRoot "usr\bin"
        $gitBashExe = Join-Path $gitRoot "git-bash.exe"
        $gitGuiExe = Join-Path $gitRoot "cmd\git-gui.exe"

        if (Test-Path $gitCmd) { Add-ToSystemPath -DirToAdd $gitCmd }
        if (Test-Path $gitBin) { Add-ToSystemPath -DirToAdd $gitBin }
        if (Test-Path $gitUsrBin) { Add-ToSystemPath -DirToAdd $gitUsrBin }

        if (Test-Path $gitBashExe) {
            Create-AppShortcut -TargetExe $gitBashExe -ShortcutName "Git Bash" -StartMenuOnly
        }
        if (Test-Path $gitGuiExe) {
            Create-AppShortcut -TargetExe $gitGuiExe -ShortcutName "Git GUI" -StartMenuOnly
        }

        try {
            $regAppPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\git.exe"
            if (-not (Test-Path $regAppPath)) { New-Item -Path $regAppPath -Force | Out-Null }
            Set-ItemProperty -Path $regAppPath -Name "(Default)" -Value "$gitCmd\git.exe" -Force
            Set-ItemProperty -Path $regAppPath -Name "Path" -Value "$gitCmd;$gitBin;$gitUsrBin" -Force
        } catch {}

        $pathsToPrepend = @($gitCmd, $gitBin, $gitUsrBin) | Where-Object { Test-Path $_ }
        foreach ($pt in $pathsToPrepend) {
            if ($env:Path -notlike "*$pt*") {
                $env:Path = "$pt;" + $env:Path
            }
        }
        Write-Host "   [OK] Git for Windows resmi aktif dan terintegrasi di Windows ($gitFound)!" -ForegroundColor Green
    }
}

# 5. Java JDK 17 LTS (with JAVA_HOME & System PATH)
function Setup-JavaJDK {
    $jdkMirrors = @(
        "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.msi"
    )
    Install-AppSmart -Name "Java JDK 17 (OpenJDK Temurin)" `
                     -FilePattern @("*Temurin*17*.msi", "*jdk*17*.msi", "*Temurin*.msi") `
                     -DownloadUrls $jdkMirrors `
                     -SilentArgs "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /qn" `
                     -WingetId "EclipseAdoptium.Temurin.17.JDK" `
                     -CheckPath @("C:\Program Files\Eclipse Adoptium\jdk-17*\bin\javac.exe", "C:\Program Files\Java\jdk-17*\bin\javac.exe")

    $jdkSearchPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Eclipse Adoptium\jdk-2*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Java\jdk-2*",
        "C:\Program Files\Java\jdk*"
    )
    $jdkPath = $null
    foreach ($pattern in $jdkSearchPaths) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $jdkPath = $found.FullName; break }
    }

    if ($jdkPath) {
        Set-SystemEnvVar -Name "JAVA_HOME" -Value $jdkPath
        $javaBin = Join-Path $jdkPath "bin"
        Add-ToSystemPath -DirToAdd $javaBin
        $env:JAVA_HOME = $jdkPath
        if ($env:Path -notlike "*$javaBin*") {
            $env:Path = "$javaBin;" + $env:Path
        }
        Write-Host "[OK] JAVA_HOME berhasil dikonfigurasi ke $jdkPath" -ForegroundColor Green
    } else {
        Write-Host "[!] Path JDK tidak terdeteksi otomatis. Silakan atur JAVA_HOME manual jika diperlukan." -ForegroundColor Yellow
    }
}

# 6. Python (Versi Terbaru 3.13 / 3.12 LTS with PIP & System PATH)
function Setup-Python {
    $pythonMirrors = @(
        "https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe",
        "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe",
        "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    )
    Install-AppSmart -Name "Python (Latest with PIP)" `
                     -FilePattern @("*python*3.13*.exe", "*python*3.12*.exe", "*python*.exe") `
                     -DownloadUrls $pythonMirrors `
                     -SilentArgs "/quiet InstallAllUsers=1 PrependPath=1 Include_pip=1" `
                     -WingetId "Python.Python.3.13" `
                     -CheckPath @("C:\Program Files\Python313\python.exe", "C:\Program Files\Python312\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe")

    $pyPaths = @(
        "C:\Program Files\Python313",
        "C:\Program Files\Python312",
        "$env:LOCALAPPDATA\Programs\Python\Python313",
        "$env:LOCALAPPDATA\Programs\Python\Python312"
    )
    foreach ($p in $pyPaths) {
        if (Test-Path $p) {
            Add-ToSystemPath -DirToAdd $p
            $pScripts = Join-Path $p "Scripts"
            if (Test-Path $pScripts) { Add-ToSystemPath -DirToAdd $pScripts }
            if ($env:Path -notlike "*$p*") { $env:Path = "$p;$pScripts;" + $env:Path }
            Write-Host "   [OK] Python berhasil didaftarkan ke System PATH ($p)" -ForegroundColor Green
            break
        }
    }
}

# 7. Node.js LTS (Versi Terbaru v22 LTS with NPM & Global PATH)
function Setup-NodeJS {
    $nodeMirrors = @(
        "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi",
        "https://nodejs.org/dist/v20.18.3/node-v20.18.3-x64.msi"
    )
    Install-AppSmart -Name "Node.js LTS (with NPM)" `
                     -FilePattern @("*node*v*.msi", "*node*.msi") `
                     -DownloadUrls $nodeMirrors `
                     -SilentArgs "/qn" `
                     -WingetId "OpenJS.NodeJS.LTS" `
                     -CheckPath "C:\Program Files\nodejs\node.exe"

    $nodePath = "C:\Program Files\nodejs"
    if (Test-Path $nodePath) {
        Add-ToSystemPath -DirToAdd $nodePath
        $npmGlobalPath = Join-Path $env:APPDATA "npm"
        if (-not (Test-Path $npmGlobalPath)) {
            New-Item -ItemType Directory -Path $npmGlobalPath -Force | Out-Null
        }
        Add-ToSystemPath -DirToAdd $npmGlobalPath
        if ($env:Path -notlike "*$nodePath*") { $env:Path = "$nodePath;$npmGlobalPath;" + $env:Path }

        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
            Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}
