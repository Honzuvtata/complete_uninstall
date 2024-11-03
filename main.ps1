function Uninstall-App {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AppName
    )


    try {
        $installedApps = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -Like "*$AppName*" }

        #check required application is installed
        if ($installedApps.Count -eq 0) {
            Log-Action "Application not installed: $AppName"
            Write-Host "Application not installed: $AppName"
            return
        }

        foreach ($app in $installedApps) {
            Write-Host "Uninstalling $($app.Name)..."
            $app.Uninstall()
            Log-Action "Uninstalled application: $($app.Name)"
        }

        Write-Host "Uninstallation complete."
    } catch {
        Write-Host "An error occurred: $_"
        Log-Action "Error during uninstallation: $_"
    }
}


function Remove-EnvironmentVariable {
    param (
        [string]$VariableName
    )

    # Check if the environment variable exists
    if (-not (Test-Path "Env:\$VariableName")) {
        Write-Host "Environment variable not found: $VariableName"
        return
    }

    # Remove the environment variable
    [Environment]::SetEnvironmentVariable($VariableName, $null, "Machine")

    Write-Host "Environment variable removed: $VariableName"
}

function Remove-RegistryEntry {
    param (
        [string]$RegistryPath
    )

    # Check if the registry path exists
    if (-not (Test-Path $RegistryPath)) {
        Write-Host "Registry path not found: $RegistryPath"
        return
    }

    # Remove the registry entry
    Remove-Item -Path $RegistryPath -Recurse -Force

    Write-Host "Registry entry removed: $RegistryPath"
}

function Remove-Folder {
    param (
        [string]$FolderPath
    )

    # Check if the folder exists
    if (Test-Path $FolderPath) {
        # Remove the folder
        Get-ChildItem $FolderPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item $FolderPath -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Folder removed: $FolderPath"
    } else {
        Write-Host "Folder not found: $FolderPath"
    }
}

function Kill-Process {
    param (
        [string]$ProcessName
    )

    # Get the process by name
    $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

    # Check if the process exists
    if ($process) {
        # Kill the process
        $process | ForEach-Object { Stop-Process $_.Id -Force }
        Write-Host "Process '$ProcessName' killed."
    } else {
        Write-Host "Process '$ProcessName' not found."
    }
}

function Stop-Service {
    param (
        [string]$ServiceName
    )

    # Get the service by name
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    # Check if the service exists
    if ($service) {
        # Stop the service
        Stop-Service -Name $ServiceName -Force
        Write-Host "Service '$ServiceName' stopped."
    } else {
        Write-Host "Service '$ServiceName' not found."
    }
}

function Remove-FileWithEnvPath {
    param (
        [string]$FilePath
    )

    # Expand environment variables in the file path
    $expandedFilePath = [Environment]::ExpandEnvironmentVariables($FilePath)

    # Check if the file exists
    if (Test-Path $expandedFilePath) {
        # Remove the file
        Remove-Item -Path $expandedFilePath -Force
        Write-Host "File removed: $expandedFilePath"
    } else {
        Write-Host "File not found: $expandedFilePath"
    }
}

function Run-ExeUninstaller {
    param (
        [string]$UninstallerPath
    )

    # Check if the uninstaller executable exists
    if (Test-Path $UninstallerPath) {
        Write-Host "Running uninstaller: $UninstallerPath"
        Start-Process -FilePath $UninstallerPath -ArgumentList "/S" -Wait
        Write-Host "Uninstaller completed: $UninstallerPath"
    } else {
        Write-Host "Uninstaller not found: $UninstallerPath"
    }
}

Uninstall-App -AppName "Amberg Track Pro Field"
Remove-Folder "C:\Program Files\Amberg Technologies AG\Amberg Track Pro Field"

Uninstall-App -AppName "Pandrol GeoVizio-Field"
Remove-Folder "C:\Program Files\Pandrol SAS\Pandrol GeoVizio-Field"

Uninstall-App -AppName "ATCertificates"
Remove-EnvironmentVariable -VariableName "ATCertPath"
Remove-Folder "C:\Program Files\Amberg Technologies AG\ATCertificates"

Stop-Service -ServiceName "RabbitMQ"
Kill-Process -ProcessName "erl"
Kill-Process -ProcessName "erlsrv"
Uninstall-App -AppName "RabbitMQ"
Remove-Folder -FolderPath "C:\Program Files\Amberg Technologies AG\RabbitMQ"
Remove-Folder -FolderPath "C:\Program Files\RabbitMQ Server"
Remove-EnvironmentVariable -VariableName "RABBITMQ_BASE"
Remove-EnvironmentVariable -VariableName "RABBITMQ_CONF_ENV_FILE"

Run-ExeUninstaller -AppName "C:\Program Files\Erlang OTP\Uninstall.exe"
Run-ExeUninstaller -AppName "C:\Program Files\Erlang 25\Uninstall.exe"
Remove-EnvironmentVariable -VariableName "ERLANG_HOME"
Remove-FileWithEnvPath -FilePath "%HOMEDRIVE%%HOMEPATH%\erlang.cookie"
Remove-FileWithEnvPath -FilePath "%SYSTEMROOT%\system32\config\systemprofile\.erlang.cookie"
Remove-RegistryEntry -RegistryPath "HKLM:\SOFTWARE\Ericsson\Erlang"
Remove-Folder -FolderPath "C:\Program Files\Erlang OTP"
Remove-Folder -FolderPath "C:\Program Files\Erlang 25"

Remove-EnvironmentVariable -VariableName "ATDataPath"

Stop-Service -ServiceName "Mosquitto Broker"
Kill-Process -ProcessName "mosquitto"
Uninstall-App -AppName "Eclipse Mosquitto MQTT"
Remove-EnvironmentVariable -VariableName "MOSQUITTO_DIR"
Remove-Folder -FolderPath "C:\Program Files\mosquitto"

Uninstall-App -AppName "ISC BIND"
Remove-Folder -FolderPath "C:\Program Files\ISC BIND 9"

Uninstall-App -AppName "HostWifiDirectNetwork"
Remove-Folder "C:\Program Files\Amberg Technologies AG\HostWifiDirectNetwork"

Uninstall-App -AppName "WiFiHotspot"
Remove-Folder "C:\Program Files\Amberg Technologies AG\WiFiHotspot"

Uninstall-App -AppName "MongoDB"
Remove-Folder -FolderPath "C:\Program Files\MongoDB"

 Write-Warning "Uninstallation done, please restart your PC."