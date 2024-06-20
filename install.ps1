# Define the Node.js LTS version
$nodeVersion = "20.14.0"
$nodeLtsUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"

# Function to check if Node.js is installed
function Check-Nodejs {
    $version = node -v 2>$null
    if ($version) {
        return $true
    } else {
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
    $installerPath = "$env:TEMP\node-v$nodeVersion-x64.msi"
    Invoke-WebRequest -Uri $nodeLtsUrl -OutFile $installerPath
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -Wait
    Remove-Item $installerPath
}

# Function to uninstall Node.js
function Uninstall-Nodejs {
    $nodePath = (Get-Command node).Source
    $uninstallerPath = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "Node.js*" }).UninstallString
    if ($uninstallerPath) {
        Start-Process "msiexec.exe" -ArgumentList "/x", $uninstallerPath, "/quiet", "/norestart" -Wait
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

# Install pm2 globally
npm install pm2@latest -g

# Run pm2 command
pm2 start .\index.js --name jkn-fp-bot --node-args="--env-file=.env"

# Create pm2-startup.bat file
$batFilePath = "$env:TEMP\pm2-startup.bat"
$batFileContent = "@echo off`npm2 resurrect`nexit"
$batFileContent | Set-Content -Path $batFilePath

# Move the batch file to the Startup folder
$startupFolder = [System.Environment]::GetFolderPath('Startup')
Move-Item -Path $batFilePath -Destination $startupFolder

Write-Output "Setup completed."
