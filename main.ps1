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
        [Parameter(Mandatory=$true)]
        [string]$VariableName
    )

    try {
        # Check if the environment variable exists
        if (-not (Test-Path "Env:\$VariableName")) {
            Write-Host "Environment variable not found: $VariableName"
            Log-Action "Environment variable not found: $VariableName"
            return
        }

        # Remove the environment variable
        [Environment]::SetEnvironmentVariable($VariableName, $null, "Machine")
        Write-Host "Environment variable removed: $VariableName"
        Log-Action "Environment variable removed: $VariableName"
        
    } catch {
        Write-Host "An error occurred while removing the environment variable: $_"
        Log-Action "Error removing environment variable '$VariableName': $_"
    }
}


function Remove-RegistryEntry {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RegistryPath
    )

    try {
        # Check if the registry path exists
        if (-not (Test-Path $RegistryPath)) {
            Write-Host "Registry path not found: $RegistryPath"
            Log-Action "Registry path not found: $RegistryPath"
            return
        }

        # Attempt to remove the registry entry
        Remove-Item -Path $RegistryPath -Recurse -Force
        Write-Host "Registry entry removed: $RegistryPath"
        Log-Action "Registry entry removed: $RegistryPath"

    } catch {
        Write-Host "An error occurred while removing the registry entry: $_"
        Log-Action "Error removing registry entry at '$RegistryPath': $_"
    }
}


function Remove-Folder {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )

    try {
        # Check if the folder exists
        if (-not (Test-Path -Path $FolderPath -PathType Container)) {
            Write-Host "Folder not found: $FolderPath"
            Log-Action "Folder not found: $FolderPath"
            return
        }

        # Attempt to remove the folder and its contents
        Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction Stop
        Write-Host "Folder removed: $FolderPath"
        Log-Action "Folder removed: $FolderPath"

    } catch {
        Write-Host "An error occurred while removing the folder: $_"
        Log-Action "Error removing folder at '$FolderPath': $_"
    }
}


function Kill-Process {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )

    try {
        # Attempt to get the process by name
        $processes = Get-Process -Name $ProcessName -ErrorAction Stop

        # Terminate each instance of the process
        $processes | ForEach-Object {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Host "Process '$ProcessName' (ID: $($_.Id)) killed."
            Log-Action "Process '$ProcessName' (ID: $($_.Id)) killed."
        }

    } catch [System.Management.Automation.ItemNotFoundException] {
        # Specific catch block for when the process is not found
        Write-Host "Process '$ProcessName' not found."
        Log-Action "Process '$ProcessName' not found."

    } catch {
        # General catch block for other errors
        Write-Host "An error occurred while trying to kill the process '$ProcessName': $_"
        Log-Action "Error killing process '$ProcessName': $_"
    }
}


function Stop-Service {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    try {
        # Attempt to retrieve the service by name
        $service = Get-Service -Name $ServiceName -ErrorAction Stop

        # Check if the service is already stopped
        if ($service.Status -eq 'Stopped') {
            Write-Host "Service '$ServiceName' is already stopped."
            Log-Action "Service '$ServiceName' is already stopped."
            return
        }

        # Stop the service
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Host "Service '$ServiceName' stopped."
        Log-Action "Service '$ServiceName' stopped."

    } catch [System.InvalidOperationException] {
        # Specific catch block for when the service is not found
        Write-Host "Service '$ServiceName' not found."
        Log-Action "Service '$ServiceName' not found."

    } catch {
        # General catch block for other errors
        Write-Host "An error occurred while stopping the service '$ServiceName': $_"
        Log-Action "Error stopping service '$ServiceName': $_"
    }
}


function Remove-FileWithEnvPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    try {
        # Expand environment variables in the file path
        $expandedFilePath = [Environment]::ExpandEnvironmentVariables($FilePath)

        # Check if the file exists
        if (-not (Test-Path -Path $expandedFilePath -PathType Leaf)) {
            Write-Host "File not found: $expandedFilePath"
            Log-Action "File not found: $expandedFilePath"
            return
        }

        # Attempt to remove the file
        Remove-Item -Path $expandedFilePath -Force -ErrorAction Stop
        Write-Host "File removed: $expandedFilePath"
        Log-Action "File removed: $expandedFilePath"

    } catch {
        # Handle errors during file removal
        Write-Host "An error occurred while removing the file '$expandedFilePath': $_"
        Log-Action "Error removing file at '$expandedFilePath': $_"
    }
}


function Run-ExeUninstaller {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UninstallerPath
    )

    try {
        # Check if the uninstaller executable exists
        if (-not (Test-Path -Path $UninstallerPath -PathType Leaf)) {
            Write-Host "Uninstaller not found: $UninstallerPath"
            Log-Action "Uninstaller not found: $UninstallerPath"
            return
        }

        # Run the uninstaller with silent mode and wait for completion
        Write-Host "Running uninstaller: $UninstallerPath"
        Log-Action "Running uninstaller: $UninstallerPath"
        
        Start-Process -FilePath $UninstallerPath -ArgumentList "/S" -Wait -ErrorAction Stop

        Write-Host "Uninstaller completed: $UninstallerPath"
        Log-Action "Uninstaller completed: $UninstallerPath"

    } catch {
        # Handle errors that occur during the uninstallation process
        Write-Host "An error occurred while running the uninstaller at '$UninstallerPath': $_"
        Log-Action "Error running uninstaller at '$UninstallerPath': $_"
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