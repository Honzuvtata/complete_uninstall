# PowerShell Uninstallation Script

## Overview

This PowerShell script provides a set of functions to uninstall applications, remove environment variables, delete registry entries, and manage files and folders. It automates the cleanup process of specific applications and their related components from a Windows system.

## Features

- **Uninstall Applications**: Remove installed applications by name.
- **Remove Environment Variables**: Delete specified environment variables from the system.
- **Remove Registry Entries**: Clean up specific registry paths.
- **Delete Files and Folders**: Recursively delete files and folders.
- **Kill Processes**: Forcefully terminate running processes.
- **Stop Services**: Stop specified Windows services.
- **Run Executable Uninstallers**: Execute uninstallers for applications not registered with Windows.

## Installation

To use this script, you need to have PowerShell installed on your Windows machine. No additional installation is required for the script itself.

1. Copy the script code to a `.ps1` file (e.g., `CleanupScript.ps1`).
2. Open PowerShell with administrative privileges.
3. Navigate to the directory where the script is saved.

## Usage

To run the script, use the following command:

```powershell
.\CleanupScript.ps1
