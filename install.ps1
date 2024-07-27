# Define the Node.js LTS version
$nodeVersion = "20.14.0"
$nodeLtsUrl64 = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"
$nodeLtsUrl32 = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x86.msi"

# Determine if the system is 64-bit or 32-bit
$is64Bit = [Environment]::Is64BitOperatingSystem
$nodeLtsUrl = if ($is64Bit) { $nodeLtsUrl64 } else { $nodeLtsUrl32 }

# Refresh env variables in the current session
function Refresh-Env-Vars {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
}

# Function to check if Node.js is installed
function Check-Nodejs {
    try {
        node -v
        return $true        
    } catch {
        return $false
    }
}

# Function to get the current Node.js version
function Get-NodejsVersion {
    $version = node -v 2>$null
    if ($version) {
        return $version.TrimStart("v")
    }
    return $null
}

# Function to install Node.js
function Install-Nodejs {
    $arch = if ($is64Bit) { 'x64' } else { 'x86' }
    $installerPath = "$env:TEMP\node-v$nodeVersion-$arch.msi"
    if (-Not (Test-Path $installerPath)) {
        Invoke-WebRequest -Uri $nodeLtsUrl -OutFile $installerPath
    }
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/passive", "/norestart" -Wait
    Refresh-Env-Vars
}

# Function to uninstall Node.js
function Uninstall-Nodejs {
    $nodePath = (Get-Command node).Source
    $uninstallerPath = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "Node.js*" }).UninstallString
    if ($uninstallerPath) {
        Start-Process "msiexec.exe" -ArgumentList "/x", $uninstallerPath, "/passive", "/norestart" -Wait
    }
}

# Check if Node.js is installed
if (Check-Nodejs) {
    $currentVersion = Get-NodejsVersion
    if ($currentVersion -lt $nodeVersion) {
        Write-Output "Current Node.js version is $currentVersion. Upgrading to $nodeVersion."
        Uninstall-Nodejs
        Install-Nodejs
    } else {
        Write-Output "Node.js is already at version $currentVersion."
    }
} else {
    Write-Output "Node.js is not installed. Installing version $nodeVersion."
    Install-Nodejs
}

# Install only production dependencies
npm install --omit=dev

# Install pm2 globally
npm install pm2@latest -g

Refresh-Env-Vars

if (-not (Test-Path -Path .env)) {
    Move-Item -Path .env.example -Destination .env
}

# Run pm2 command
pm2 start .\index.js --name jkn-fp-bot --node-args="--env-file=.env"

# Save process list
pm2 save --force

# Create pm2-startup.bat file
$batFilePath = "$env:TEMP\pm2-startup.bat"
$batFileContent = "@echo off`npm2 resurrect`nexit"
$batFileContent | Set-Content -Path $batFilePath

# Move the batch file to the Startup folder
$startupFolder = [System.Environment]::GetFolderPath('Startup')
Move-Item -Path $batFilePath -Destination $startupFolder -Force

Write-Output "Setup completed."
Read-Host -Prompt "Press Enter to close this window"
