<#
Robust installer for Java 21 (Temurin) on Windows.

Usage (run PowerShell as Administrator to install into Program Files):
  .\scripts\install-java21.ps1
  # or with custom args:
  .\scripts\install-java21.ps1 -InstallDir 'C:\Program Files\Java\jdk-21' -Force

This script:
- downloads a Temurin JDK zip to the temp folder
- extracts it and moves it into the requested install directory
- backs up any existing directory at the destination
- sets the User-scoped JAVA_HOME env var and optionally adds %JAVA_HOME%\bin to the User PATH
- performs cleanup only if paths exist (avoids null Remove-Item errors)
#>

param(
    [string]$Url = 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_windows_hotspot_21.0.5_11.zip',
    [string]$InstallDir = 'C:\Program Files\Java\jdk-21',
    [switch]$Force,
    [switch]$AddToPath
)

function Test-Admin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Host "Starting Java 21 installer script..."

if (-not (Test-Path $env:TEMP)) { New-Item -Path $env:TEMP -ItemType Directory -Force | Out-Null }

$tempZip = Join-Path $env:TEMP 'java21.zip'
$tempExtract = Join-Path $env:TEMP 'java21_extract'

try {
    Write-Host "Download URL: $Url"
    if (Test-Path $tempZip) {
        if ($Force) { Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue } else { Write-Host "Removing existing temp zip: $tempZip"; Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue }
    }

    Write-Host "Downloading Java 21 to: $tempZip"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $tempZip -UseBasicParsing -ErrorAction Stop

    if (-not (Test-Path $tempZip)) { throw "Download failed or file not found: $tempZip" }

    # Ensure extraction folder is clean
    if (Test-Path $tempExtract) {
        Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path $tempExtract -ItemType Directory | Out-Null

    Write-Host "Extracting to: $tempExtract"
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # Find the extracted root directory (usually a single folder)
    $extractedDir = Get-ChildItem -Path $tempExtract -Directory | Select-Object -First 1
    if (-not $extractedDir) { throw "Extraction did not produce a directory. Zip contents may be unexpected." }

    # If destination exists, back it up (timestamped) unless -Force specified to remove
    if (Test-Path $InstallDir) {
        $ts = Get-Date -Format 'yyyyMMddHHmmss'
        $backup = "${InstallDir}_backup_$ts"
        Write-Host "Destination already exists. Backing up to: $backup"
        Move-Item -Path $InstallDir -Destination $backup -Force
    }

    # Move extracted folder to destination. Requires admin for Program Files.
    Write-Host "Installing to: $InstallDir"
    if ((Test-Path $InstallDir) -and -not $Force) {
        throw "Install directory already exists and -Force not specified: $InstallDir"
    }

    Move-Item -Path $extractedDir.FullName -Destination $InstallDir -Force

    # Cleanup temp files if they exist (check before Remove-Item to avoid null/path errors)
    if (Test-Path $tempZip) { Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $tempExtract) { Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue }

    # Set JAVA_HOME (User scope) and optionally add to User PATH
    Write-Host "Setting JAVA_HOME to: $InstallDir"
    [Environment]::SetEnvironmentVariable('JAVA_HOME', $InstallDir, 'User')

    if ($AddToPath) {
        $javaBinRef = '%JAVA_HOME%\bin'
        $curPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if (-not $curPath) { $curPath = '' }
        if ($curPath -notlike "*$javaBinRef*") {
            $newPath = ($curPath.TrimEnd(';') + ';' + $javaBinRef).Trim(';')
            [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
            Write-Host "Added $javaBinRef to User PATH. New sessions will pick this up."
        } else {
            Write-Host "User PATH already contains $javaBinRef"
        }
    }

    Write-Host "Installation complete. Current (in-session) verification:"
    $javaExe = Join-Path $InstallDir 'bin\java.exe'
    if (Test-Path $javaExe) {
        & $javaExe -version
    } else {
        Write-Warning "java executable not found at $javaExe"
    }

    Write-Host "Note: The User-scoped environment variables set by this script are available in new sessions."
    Write-Host "You can log off/log on or start a new PowerShell session to pick them up."

    Write-Host "If you want to use Java 21 in the current session immediately, run:"
    Write-Host "  `$env:JAVA_HOME = '$InstallDir'"
    Write-Host "  `$env:Path = '%JAVA_HOME%\bin;' + $env:Path"

} catch {
    Write-Error "An error occurred: $_"
    # Attempt cleanup if temp paths exist
    if (Test-Path $tempZip) { Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $tempExtract) { Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue }
    exit 1
}

Write-Host "Done."
