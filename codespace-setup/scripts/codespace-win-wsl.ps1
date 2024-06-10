# codespace-win-wsl.ps1
# This PowerShell script begins the setup for codespace on Windows.
#
# To run:
# 1)  Press Windows + X and select Windows PowerShell (Admin) or Terminal (Admin)� if you're on a newer version of Windows.
# 2)  Allow the current user to run scripts by running: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
# 3)  Run this script directly from PowerShell

###
##
# MARK: Global variables
$userProfileName = Split-Path $env:USERPROFILE -leaf
$wslUbuntuDrive = "\\wsl.localhost\Ubuntu"
$wslUserName = Get-WslUserName

###
##
# MARK: Helper Functions

# >> MARK: Get-WslUserName
function Get-WslUserName {
  param (
    [string]$WslUbuntuDrivePath = $wslUbuntuDrive
  )
  
  # Attempt to get WSL home directories
  $wslUserPSDirectory = Get-ChildItem -Path "$WslUbuntuDrivePath\home" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
  
  # If one WSL home directory exists, return its name
  if ($wslUserPSDirectory) {
    return $wslUserPSDirectory.Name
  } else {
    return $null
  }
}

###
##
# MARK: |A| Install WSL and Ubuntu

Write-Host "Starting..."

# >> MARK: |1| Enable WSL and Virtual Machine Platform
if (-not (Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Enabled") {
  Write-Host "Enabling WSL..."
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  $enabledWSLOrVMP = $true
} else {
  Write-Host "WSL is already enabled."
}
if (-not (Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online).State -eq "Enabled") {
  Write-Host "Enabling Virtual Machine Platform..."
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
  $enabledWSLOrVMP = $true
} else {
  Write-Host "Virtual Machine Platform is already enabled."
}
if ($enabledWSLOrVMP) {
  Write-Host "Enabling WSL and/or Virtual Machine Platform requires a restart."
  Write-Host "Not restarting before continuing the script may result in unexpected errors."
  $userConfirmation = Read-Host "Do you want to restart the computer now? (Y/n)"
  if ($userConfirmation -eq 'N' -or $userConfirmation -eq 'n') {
    Write-Host "Restart aborted. Please remember to manually restart later before retrying the script."
    exit 1
  } else {
    Write-Host "Restarting the computer..."
    Restart-Computer
  }
}

# >> MARK: |2| Install WSL 2 kernel update package and distribution only if no distributions are installed
$readyToInstallUbuntu = $false
$mustInitializeUbuntu = $false
$wslOutput = wsl -l -v 2>&1
if ($LASTEXITCODE -ne 0) {
  
  # Restart system when WSL is finishing an upgrade
  if ($wslOutput -like "*WSL is finishing an upgrade*") {

    Write-Host "WSL is finishing an upgrade and may require a restart."
    $userConfirmation = Read-Host "Do you want to restart the computer now? (y/N)"
    if ($userConfirmation -eq 'Y' -or $userConfirmation -eq 'y') {
      Write-Host "Restarting the computer..."
      Restart-Computer
    } else {
      Write-Host "Restart aborted. Please remember to manually restart the computer later."
      exit 1
    }
  
  # Install and configure WSL update package and distribution otherwise
  } else {

    Write-Host "WSL distributions are not found."

    # Install the WSL 2 Linux kernel update package
    $kernelUpdatePath = "$env:TEMP\wsl_update_x64.msi"
    if (-not (Test-Path $kernelUpdatePath)) {
      Write-Host "Downloading and installing WSL 2 Linux kernel update package for x64 machines..."
      Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $kernelUpdatePath
      Start-Process -FilePath $kernelUpdatePath -Args "/quiet" -Wait
    } else {
      Write-Host "WSL 2 Linux kernel update package is already downloaded and likely installed."
    }
    
    # Ask user to set the default version of WSL distributions
    $userConfirmation = Read-Host "Set the default version for WSL distributions to 1 or 2 (default)? (1/2)"
    if ($userConfirmation -eq '1') {
      Write-Host "Setting WSL default version to 1..."
      wsl --set-default-version 1
    } else {
      Write-Host "Setting WSL default version to 2..."
      wsl --set-default-version 2
    }
    
    $readyToInstallUbuntu = $true
    
  }
  
} else {

  $cleanedWslOutput = $wslOutput -replace '[^\P{C}\p{Z}]', ''
  if ($cleanedWslOutput -like "*Ubuntu*") {

    Write-Host "Ubuntu for WSL is already installed."

  } else {

    Write-Host "WSL distributions are installed, but Ubuntu is not installed."

    # Ask user to set the default version of WSL distributions
    $userConfirmation = Read-Host "Set the default version for WSL distributions to 1 or 2 (default)? (1/2)"
    if ($userConfirmation -eq '1') {
      Write-Host "Setting WSL default version to 1..."
      wsl --set-default-version 1
    } else {
      Write-Host "Setting WSL default version to 2..."
      wsl --set-default-version 2
    }
    
    $readyToInstallUbuntu = $true
  }
}

# >> MARK: |3| Install Ubuntu if not already installed
if ($readyToInstallUbuntu) {

  # Install Ubuntu distribution
  Write-Host "Installing Ubuntu..."
  wsl --install --no-launch -d Ubuntu
  Write-Host "Wait 10 seconds for installation to finish..."
  Start-Sleep -Seconds 10
  $mustInitializeUbuntu = $true
}

# >> MARK: |4| Instruct user to initialize Ubuntu distribution
if ($mustInitializeUbuntu) {

  Write-Host ""
  Write-Host "ACTION NEEDED: Ubuntu must be launched a first time to initialize."
  Write-Host "IMPORTANT: If on an Intel Mac, first launch Windows from macOS in System Preferences > Startup Disk to enable virtualization."
  Write-Host "When ready to proceed, this script will launch Ubuntu, which will ask you to configure a username and password."
  Write-Host "Ubuntu will then silently initialize itself, after which it will show the bash prompt."
  Write-Host "IMPORTANT: Ubuntu initialization may take several minutes without progress indication."
  Write-Host "Once the bash prompt appears, please exit Ubuntu, return to this window, and press Enter to continue."
  $readReadyForUbuntu = Read-Host "Are you ready to proceed? (Y/n)"
  if (($readReadyForUbuntu -eq 'n') -or ($readReadyForUbuntu -eq 'N')) {
    Write-Host "Script aborted."
    exit 1
  }

  $ubuntuApp = Get-StartApps | Where-Object { $_.Name -like "*ubuntu*" }
  if (-not $ubuntuApp) {
    Write-Host "Error: Ubuntu is not found in the Start Menu apps. Aborting."
    exit 1
  }
  $ubuntuAppId = $ubuntuApp.AppID
  Start-Process "shell:AppsFolder\$ubuntuAppId"
  Write-Host ""
  Read-Host "Press Enter after waiting for the bash prompt to appear and exiting Ubuntu"
  $wslUserName = Read-Host "Enter the new user name configured for Ubuntu"
}

###
##
# MARK: |B| Create a winspace directory in %USERPROFILE%

$winspaceDir = Join-Path -Path $env:USERPROFILE -ChildPath "winspace"
if (-not (Test-Path -Path $winspaceDir)) {
  
  Write-Host "winspace directory in $env:USERPROFILE doesn't exist."
  Write-Host "Creating winspace in $env:USERPROFILE..."
  New-Item -Path $winspaceDir -ItemType Directory | Out-Null
} else {
   
  Write-Host "winspace directory in $env:USERPROFILE already exists."
}
    
###
##
# MARK: |C| Invoke codespace-ubuntu-wsl inside Ubuntu

$winspaceScriptsDir = Join-Path -Path $winspaceDir -ChildPath "scripts"
$winspaceUbuntuWinPath = Join-Path -Path $winspaceScriptsDir -ChildPath "codespace-ubuntu-wsl.sh"
$winspaceUbuntuUnixPath = $winspaceUbuntuWinPath -replace '^C:\\', '/mnt/c/'
$winspaceUbuntuUnixPath = $winspaceUbuntuUnixPath -replace '\\', '/'

# >> MARK: |1| Download personal setup script for codespace on Ubuntu
if (-not (Test-Path $winspaceUbuntuWinPath)) {

  # Create scripts directory in winspace
  if (-not (Test-Path -Path $winspaceScriptsDir)) {

    Write-Host "scripts directory in winspace doesn't exist."
    Write-Host "Creating winspace/scripts in $env:USERPROFILE..."
    New-Item -Path $winspaceScriptsDir -ItemType Directory | Out-Null
  }

  # Download script
  Write-Host "Setup script for codespace-ubuntu-wsl is not found."
  Write-Host "Downloading personal setup script for codespace on Ubuntu for WSL..."
  $codespaceSetupUbuntuUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/codespace-setup/scripts/codespace-ubuntu-wsl.sh"
  Invoke-WebRequest -Uri $codespaceSetupUbuntuUrl -OutFile $winspaceUbuntuWinPath
} else {

  Write-Host "Setup script for codespace-ubuntu-wsl already exists."
}

# >> MARK: |2| Fix nameserver in wsl.conf and resolv.conf
$wslResolvConfPath = "$wslUbuntuDrive\etc\resolv.conf"
if (-not (Select-String -Path $wslResolvConfPath -Pattern "nameserver 8.8.8.8" -Quiet)) {

  Write-Host "Fixing wsl.conf in Ubuntu..."
  $appendWslConfLines = @"
[network]
generateResolvConf = false
"@
  $appendWslConfCommand = @"
if ! grep -q 'generateResolvConf = false' /etc/wsl.conf; then
  echo '$appendWslConflines' | sudo tee -a /etc/wsl.conf > /dev/null
fi
"@
  wsl -d Ubuntu -u root -- bash -c $appendWslConfCommand
  Write-Host "Fixing resolv.conf in Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "sudo chattr -f -i /etc/resolv.conf"
  wsl -d Ubuntu -u root -- bash -c "sudo rm /etc/resolv.conf"
  wsl -d Ubuntu -u root -- bash -c "sudo echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
  wsl -d Ubuntu -u root -- bash -c "sudo chattr -f +i /etc/resolv.conf"
} else {

  Write-Host "wsl.conf and resolv.conf is already fixed."
}

# >> MARK: |3| Run codespace setup in Ubuntu
$wslEtcPasswdPath = "$wslUbuntuDrive\etc\passwd"
$rootPasswdEntry = Get-Content $wslEtcPasswdPath | Select-String "^root:"
if (-not ($rootPasswdEntry -and $rootPasswdEntry -match "root:.*:/bin/zsh$")) {
  Write-Host "Running codespace setup script in Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "chmod +x $winspaceUbuntuUnixPath"
  wsl -d Ubuntu -u root -- bash -c $winspaceUbuntuUnixPath
  if ($LASTEXITCODE -ne 0) {
    Write-Host "The codespace-ubuntu-wsl script exited with an error: $LASTEXITCODE"
    exit $LASTEXITCODE
  }
} else {

  Write-Host "Codespace setup script for Ubuntu has already completed successfully."
}

###
##
# MARK: |C| Generate SSH keys for GitHub and add to SSH agent

# >> MARK: |1| Generate SSH keys in WSL for the WSL user (optional)
if (-not $wslUserName) {
  $wslUserName = Get-WslUserName
}
if ($wslUserName) {
  $wslUserSSHDir = "$wslUbuntuDrive\home\$wslUserName\.ssh"  
}
if (-not ($wslUserName -and (Test-Path $wslUserSSHDir\*))) {

  Write-Host "SSH key files for WSL user not found."

  $readReadyForSSHKeygen = Read-Host "Do you want to generate a SSH key for use with GitHub in WSL now? (Y/n)"
  if ((-not $readReadyForSSHKeygen) -or $readReadyForSSHKeygen -eq 'y' -or $readReadyForSSHKeygen -eq 'Y') {

    # TODO: Remove redundant logic
    if (-not $wslUserName) {
      
      $wslUserName = Read-Host "Enter the user name configured for WSL Ubuntu"
    }
    if ($wslUserName) {
      
      $wslUserHome = "$wslUbuntuDrive\home\$wslUserName"
      if (Test-Path $wslUserHome) {

        $readEmailForGitHub = Read-Host "Enter your optional email identifier to use with ssh-keygen"

        # Generate SSH keys with or without email identifier
        if ($readEmailForGitHub) {
          wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-keygen -t ed25519 -C `"$readEmailForGitHub`""
        } else {
          wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-keygen -t ed25519"
        }
        $didGenerateSSHKeys = $true
      } else {
        
        Write-Host "$wslUserHome not found. Skipping."
      }
    } else {
      
      Write-Host "No user name given. Skipping."
    }
  }
} else {
  Write-Host "SSH key files for WSL user already exist."
}

# >> MARK: |2| Add SSH keys to ssh-agent
if ($didGenerateSSHKeys) {

  Write-Host "Adding SSH private key to ssh-agent..."

  # Get SSH key name
  $sshFiles = Get-ChildItem -Path $wslUserSSHDir
  if ($sshFiles.Count -eq 2) {
    $sshFile1BaseName = $sshFiles[0].BaseName
    $sshFile2BaseName = $sshFiles[1].BaseName
    if ($sshFile1BaseName -eq $sshFile2BaseName -and ($sshFiles[0].Extension -eq ".pub" -xor $sshFiles[1].Extension -eq ".pub")) {
      $sshKeyName = $sshFile1BaseName
    }
  }

  # Take the opportunity to set private key permissions to 600
  if ($sshKeyName) {
    wsl -d Ubuntu -u $wslUserName -- bash -c "chmod 600 ~/.ssh/$sshKeyName"
  }

  # Configure ssh-agent and funtoo/keychain with SSH key
  if ($sshKeyName) {
    
    # Careful syntax required to preserve environment for ssh-add
    wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-agent bash -c 'ssh-add ~/.ssh/$sshKeyName'"
    
    # Initialize funtoo/keychain with ssh key
    wsl -d Ubuntu -u $wslUserName -- bash -c "sed -i '/^#keychain#/c\eval \$\(keychain -q --eval --agents ssh $sshKeyName)' ~/.zshrc"

    # Update .zshrc to load identify in ssh-agent when sourced (disabled, keychain sufficient)
    # wsl -d Ubuntu -u $wslUserName -- bash -c "sed -i '/^#zsshagent#/c\zstyle :omz:plugins:ssh-agent identities $sshKeyName' ~/.zshrc"

  } else {
    
    Write-Host "Unexpected error. SSH key not added to ssh-agent."
  }
}

###
##
# MARK: |D| Install VSCode

# >> MARK: |1| Download and install VS Code if not already installed
$vsCodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
if (-not (Test-Path $vsCodePath)) {
  Write-Host "VSCode is not installed."

  Write-Host "Downloading installer for VSCode..."
  $installerPath = "$env:TEMP\VSCodeSetup.exe"
  Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $installerPath
  
  Write-Host "Running installer for VSCode..."
  Start-Process -FilePath $installerPath -Args "/silent /mergetasks=!runcode" -Wait
} else {
  Write-Host "VSCode is already installed."
}

# >> MARK: |2| Install extensions

# |2.1| Define the path to code CLI command
$vscodeCLIPath = "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
if (-not (Test-Path $vscodeCLIPath)) { $vscodeCLIPath = "C:\Program Files\Microsoft VS Code\bin\code.cmd" }

if ($vscodeCLIPath) {

  # |2.2| Function to install a VSCode extension by id only when not already installed
  function Install-VSCodeExtension {
    Param([string]$ExtensionId)
    $baseExtensionId = $ExtensionId -split '@' | Select-Object -First 1
    $installedExtensions = & $vscodeCLIPath --list-extensions
    if ($baseExtensionId -notin $installedExtensions) {
      Write-Host "Installing extension: $ExtensionId..."
      & $vscodeCLIPath --install-extension $ExtensionId
      $didInstallExtension = $true
    } else {
      Write-Host "Extension $ExtensionId is already installed."
    }
  }

  # |2.3| Install extensions by id
  @(
    # Most Important
    "alefragnani.project-manager",
    "asvetliakov.vscode-neovim@0.0.42",
    "ms-vscode-remote.remote-wsl",
    "tw.monokai-accent",
    # Nice to Have
    "dbaeumer.vscode-eslint",
    "dunstontc.viml",
    "geddski.macros",
    "huntertran.auto-markdown-toc",
    "jebbs.markdown-extended",
    "jsynowiec.vscode-insertdatestring",
    "mhutchie.git-graph",
    "ms-python.black-formatter",
    "naumovs.color-highlight",
    "redhat.vscode-yaml",
    "hoovercj.vscode-settings-cycler",
    "spywhere.mark-jump",
    "tyriar.sort-lines",
    "wayou.vscode-todo-highlight"
  ) | ForEach-Object {
    Install-VSCodeExtension $_
  }
} else {

  Write-Host "VSCode binary is not found."
}

# |2.4| Install personal box-checker extension

# Create vscode directory in winspace
$winspaceVscodeDir = Join-Path -Path $winspaceDir -ChildPath "vscode"
if (-not (Test-Path -Path $winspaceVscodeDir)) {
  
  Write-Host "vscode directory in $winspaceDir doesn't exist."
  Write-Host "Creating vscode in $winspaceDir..."
  New-Item -Path $winspaceVscodeDir -ItemType Directory | Out-Null
} else {
   
  Write-Host "vscode directory in $winspaceDir already exists."
}

# Download box-checker extension file into this directory
$boxCheckerPath = Join-Path -Path $winspaceVscodeDir -ChildPath "box-checker-0.0.1.vsix"
if (-not (Test-Path $boxCheckerPath)) {
  
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/box-checker-0.0.1.vsix" -OutFile $boxCheckerPath
}

# Install box-checker extension from vsix
$boxCheckerId = "tw.box-checker"
if ($boxCheckerId -notin $installedExtensions) {

  Write-Host "Installing extension: $boxCheckerId..."
  & $vscodeCLIPath --install-extension $boxCheckerPath
  $didInstallExtension = $true
} else {

  Write-Host "Extension $boxCheckerId is already installed."
}

# >> MARK: |3| Import personal settings and keybindings files

# |3.1| First check whether backup files already exist, and continue only if they don't
$vsCodeUserPath = "$env:APPDATA\Code\User"
$settingsBackupPattern = '^settings_\d{4}-\d{2}-\d{2}(-\d{4})?\.json$'
$keybindingsBackupPattern = '^keybindings_\d{4}-\d{2}-\d{2}(-\d{4})?\.json$'

# |3.2| Function to search for files matching a pattern
function Find-FilesMatchingPattern {
  param (
    [string]$path,
    [string]$pattern
  )

  # Search for files that match the pattern
  $matchingFiles = Get-ChildItem -Path $path -File | Where-Object {
    $_.Name -match $pattern
  }

  # Return true if any matching files were found, otherwise false
  return $matchingFiles.Count -gt 0
}

# |3.3| Check if both settings and keybindings backup files exist
$hasSettingsBackup = Find-FilesMatchingPattern -path $vsCodeUserPath -pattern $settingsBackupPattern
$hasKeybindingsBackup = Find-FilesMatchingPattern -path $vsCodeUserPath -pattern $keybindingsBackupPattern

if (-not ($hasSettingsBackup -and $hasKeybindingsBackup)) {
  
  # |3.4| Back up settings and keybindings only when not already backed up
  Write-Host "Backups for default settings and keybindings are not found."
  Write-Host "Backing up settings and keybindings files to $vsCodeUserPath..."
  $settingsPath = Join-Path -Path $vsCodeUserPath -ChildPath "settings.json"
  $keybindingsPath = Join-Path -Path $vsCodeUserPath -ChildPath "keybindings.json"
  $currentDate = Get-Date -Format "yyyy-MM-dd"
  $newSettingsFilename = "settings_$currentDate.json"
  $newKeybindingsFilename = "keybindings_$currentDate.json"
  $newSettingsPath = Join-Path -Path $vsCodeUserPath -ChildPath $newSettingsFilename
  $newKeybindingsPath = Join-Path -Path $vsCodeUserPath -ChildPath $newKeybindingsFilename
  if (Test-Path $settingsPath) { Rename-Item -Path $settingsPath -NewName $newSettingsPath }
  if (Test-Path $keybindingsPath) { Rename-Item -Path $keybindingsPath -NewName $newKeybindingsPath }

  # |3.5| Download and replace with personal settings and keybindings files
  Write-Host "Downloading personal settings and keybindings into VSCode..."
  $settingsUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/win/settings.json"
  $keybindingsUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/win/keybindings.json"
  Invoke-WebRequest -Uri $settingsUrl -OutFile $settingsPath
  Invoke-WebRequest -Uri $keybindingsUrl -OutFile $keybindingsPath
} else {
  
  Write-Host "Backups for default settings and keybindings are found."
}

# >> MARK: |4| Install personal VSCode fonts if not already installed

# |4.1| Check if fonts are already installed
$fontName1 = "MesloLGLDZNerdFontMono-Bold.ttf"
$fontName2 = "RobotoMonoNerdFontMono-Medium.ttf"
$fontsDirectory = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Windows\Fonts"
if (-not (Test-Path -Path $fontsDirectory)) {
  New-Item -Path $fontsDirectory -ItemType Directory
}
$fontFilePath1 = Join-Path -Path $fontsDirectory -ChildPath $fontName1
$fontFilePath2 = Join-Path -Path $fontsDirectory -ChildPath $fontName2

if (-not ((Test-Path -Path $fontFilePath1) -and (Test-Path -Path $fontFilePath2))) {

  Write-Host "Fonts for VSCode are not installed."

  # |4.2| Download fonts only when not already installed
  Write-Host "Downloading fonts for VSCode..."
  $fontUrl1 = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/fonts/$fontName1"
  $fontUrl2 = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/fonts/$fontName2"
  $tempDir = "$env:TEMP\FontDownloads"
  New-Item -ItemType Directory -Force -Path $tempDir
  $fontTempPath1 = Join-Path -Path $tempDir -ChildPath $fontName1
  $fontTempPath2 = Join-Path -Path $tempDir -ChildPath $fontName2
  Invoke-WebRequest -Uri $fontUrl1 -OutFile $fontTempPath1
  Invoke-WebRequest -Uri $fontUrl2 -OutFile $fontTempPath2

  # |4.3| Guide users to installing fonts themselves
  Write-Host "Installing fonts requires completing the installations in the dialogs that appear."
  Write-Host "Installing $fontName1..."
  Invoke-Item $fontTempPath1
  Read-Host "Press Enter after you have finished installing the font."
  Write-Host "Installing $fontName2..."
  Invoke-Item $fontTempPath2
  Read-Host "Press Enter after you have finished installing the font."

  # |4.4| Clean up the downloaded files
  Write-Host "Cleaning up downloads..."
  Remove-Item -Path $tempDir -Recurse -Force
} else {

  Write-Host "Fonts for VSCode are already installed."
}

###
##
# MARK: |E| Install PowerToys

# Continue only if PowerToys is not already installed
$alreadyInstalledPowerToys = Get-CimInstance -ClassName Win32_Product |
                             Where-Object { $_.Name -like "*PowerToys*" }
if ($alreadyInstalledPowerToys) {

  Write-Host "Microsoft PowerToys is already installed."
} else {

  Write-Host "Microsoft PowerToys is not installed."
 
  # Use the GitHub API URL for fetching metadata about the latest release
  $repo = "microsoft/PowerToys"
  $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
  $latestReleaseAll = Invoke-RestMethod -Uri $apiUrl

  # Download PowerToysUserSetup (assets[4])
  $latestRelease = $latestReleaseAll.assets[4]
  $downloadUrl = $latestRelease.browser_download_url
  $downloadName = $latestRelease.name
  $downloadPath = Join-Path -Path $env:TEMP -ChildPath $downloadName
  Write-Host "Downloading $downloadName..."
  Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

  # Run the downloaded exe installer
  Write-Host "Installing $downloadName..."
  Start-Process -FilePath $downloadPath -Wait

  # Wait for user to install PowerToys
  Write-Host "The Keyboard Manager PowerToy is useful for remapping Caps Lock to Esc."
  Read-Host "Press Enter after you have finished installing Microsoft PowerToys."
  $didInstallPowerToys = $true
}

###
##
# MARK: |F| Install WinGet

# >> MARK: |1| Install NuGet CLI
if (-not (Get-Command "nuget" -ErrorAction SilentlyContinue)) {
  
  Write-Host "NuGet CLI is not installed."

  # Download NuGet CLI and add to PATH
  $nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
  $nugetDir = "$env:USERPROFILE"
  $nugetPath = "$nugetDir\nuget.exe"
  if (-not (Test-Path -Path $nugetPath)) {
    Write-Host "nuget.exe is not downloaded."
    Write-Host "Downloading NuGet to $nugetDir and adding to PATH..."
    Invoke-WebRequest -Uri $nugetUrl -OutFile $nugetPath
  } else {
    Write-Host "nuget.exe is already downloaded."
  }
  Write-Host "Adding $nugetDir to PATH..."
  $envPathMachine = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
  $envPathMachineArray = $envPathMachine -split ';'
  if (-not ($envPathMachineArray -contains $nugetDir)) {
    $newEnvPath = "$envPath;$nugetDir"
    [System.Environment]::SetEnvironmentVariable("PATH", $newEnvPath, "Machine")
  }
  $envPath = $env:Path
  $envPathArray = $envPath -split ';'
  if (-not ($envPathArray -contains $nugetDir)) {
    $env:Path += ";$nugetDir"
  }

  # Verify installation
  if (-not (Get-Command "nuget" -ErrorAction SilentlyContinue)) {
    Write-Host "Failed to install NuGet CLI."
    exit 1
  }
} else {

  Write-Host "NuGet CLI is already installed."
}

# >> MARK: |2| Use NuGet to install Microsoft.UI.Xaml framework dependency for WinGet
$xamlPackageName = "Microsoft.UI.Xaml"
$nugetGlobalPackagesPath = Join-Path -Path $env:USERPROFILE -ChildPath ".nuget\packages\$xamlPackageName"
if (-not (Test-Path -Path $nugetGlobalPackagesPath)) {
  Write-Host "$xamlPackageName >=2.8 framework is not already installed."
  Write-Host "Installing $xamlPackageName..."
  nuget install $xamlPackageName -OutputDirectory $nugetGlobalPackagesPath
} else {
  Write-Host "$xamlPackageName >=2.8 is already installed."
}

# >> MARK: |3| Download and install winget-cli
$wingetPackageName = "Microsoft.DesktopAppInstaller"
if (-not (Get-AppxPackage -Name $wingetPackageName)) {

  Write-Host "winget-cli (Microsoft.DesktopAppInstaller) is not already installed."

  # Use the GitHub API URL to fetch metadata about the latest release of winget
  $repo = "microsoft/winget-cli"
  $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
  $latestReleaseAll = Invoke-RestMethod -Uri $apiUrl
  $latestRelease = $latestReleaseAll.assets[2]
  $downloadUrl = $latestRelease.browser_download_url
  $downloadName = $latestRelease.name
  $downloadPath = Join-Path -Path $env:TEMP -ChildPath $downloadName

  # Check if the winget-cli latest release is already downloaded
  if (-not (Test-Path -Path $downloadPath)) {
    Write-Host "Downloading $downloadName..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
  } else {
    Write-Host "$downloadName is already downloaded."
  }
  
  Write-Host "Installing $wingetPackageName..."
  Add-AppxPackage -Path $downloadPath
} else {

  Write-Host "$wingetPackageName is already installed."
}

###
##
# MARK: |G| Install Windows Terminal

# >> MARK: |1| Install Windows Terminal via winget
$windowsTerminalId = "Microsoft.WindowsTerminal"
$wingetListWindowsTerminalOutput = winget list -q $windowsTerminalId
if (-not $wingetListWindowsTerminalOutput) {

  Write-Host "$windowsTerminalId is not already installed by $wingetPackageName."
  Write-Host "Installing $windowsTerminalId..."
  winget install --id=Microsoft.WindowsTerminal -e
} else {
  
  Write-Host "$windowsTerminalId is already installed."
}

# >> MARK: |2| Launch Windows Terminal once when settings.json isn't found
$settingsPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path -Path $settingsPath)) {

  Write-Host "Settings file for Windows Terminal is not found."

  Write-Host "Launching Windows Terminal to automatically create its settings.json file..."
  Start-Process wt

  Read-Host "Please close Windows Terminal and then press Enter to continue."
} else {

  Write-Host "Settings file for Windows Terminal already exists."
}

# >> MARK: |3| Modify settings for Windows Terminal
if (Test-Path -Path $settingsPath) {

  $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

  # Check if settings has already been modified by this script by checking if "tw" scheme exists
  if ($settings.schemes -and ($settings.schemes | Where-Object { $_.name -eq "tw" }).Count -gt 0) {

    Write-Host "Customizing settings for Windows Terminal..."
    
    # Update global settings
    $settings | Add-Member -NotePropertyName "alwaysShowTabs" -NotePropertyValue $false -Force
    $settings | Add-Member -NotePropertyName "confirmCloseAllTabs" -NotePropertyValue $false -Force
    $settings | Add-Member -NotePropertyName "showTabsInTitlebar" -NotePropertyValue $true -Force
    $settings | Add-Member -NotePropertyName "theme" -NotePropertyValue "dark" -Force
    $settings | Add-Member -NotePropertyName "initialCols" -NotePropertyValue 120 -Force
    $settings | Add-Member -NotePropertyName "initialPosition" -NotePropertyValue "150,75" -Force
    $settings | Add-Member -NotePropertyName "initialRows" -NotePropertyValue 32 -Force
    $settings | Add-Member -NotePropertyName "showTerminalTitleInTitlebar" -NotePropertyValue $false -Force
    $settings | Add-Member -NotePropertyName "tabWidthMode" -NotePropertyValue "equal" -Force

    # Update default profile settings, safely
    if (-not $settings.psobject.Properties.Match("profiles").Count) {
      $settings | Add-Member -NotePropertyName "profiles" -NotePropertyValue @{} -Force
    }
    if (-not $settings.profiles.psobject.Properties.Match("defaults").Count) {
      $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
    }
    if (-not $settings.profiles.defaults.psobject.Properties.Match("font").Count) {
      $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
    }
    $settings.profiles.defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue "tw" -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "historySize" -NotePropertyValue 9001 -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "opacity" -NotePropertyValue 90 -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "padding" -NotePropertyValue "8" -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "startingDirectory" -NotePropertyValue "%USERPROFILE%/codespace" -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "useAcrylic" -NotePropertyValue $true -Force
    $settings.profiles.defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue "MesloLGLDZ Nerd Font Mono" -Force
    $settings.profiles.defaults.font | Add-Member -NotePropertyName "size" -NotePropertyValue 10 -Force

    # Add custom color scheme
    $twScheme = @{
      name = "tw"
      foreground = "#f7f1ff"
      background = "#222222"
      selectionBackground = "#525053"
      cursorColor = "#bab6c0"
      black = "#222222"
      blue = "#fd9353"
      brightBlack = "#69676c"
      brightBlue = "#fd9353"
      brightCyan = "#5ad4e6"
      brightGreen = "#7bd88f"
      brightPurple = "#948ae3"
      brightRed = "#fc618d"
      brightWhite = "#f7f1ff"
      brightYellow = "#fce566"
      cyan = "#5ad4e6"
      green = "#7bd88f"
      purple = "#948ae3"
      red = "#fc618d"
      white = "#f7f1ff"
      yellow = "#fce566"
    }
    if (-not $settings.schemes) { $settings.schemes = @() }
    if (-not ($settings.schemes | Where-Object { $_.name -eq "tw" })) {
      $settings.schemes += $twScheme
    }

    # Save the updated settings back to the file
    $settings | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath

    Write-Host "Customizing settings for Windows Terminal completed."
  } else {

    Write-Host "Settings for Windows Terminal are already customized."
  }
} else {
  
  Write-Host "Error: settings.json for Windows Terminal was expected but not found."
  exit 1
}

###
##
# MARK: |H| Install NeoVim for Windows

$neovimId = "Neovim.Neovim"
$wingetListNeovimOutput = winget list -q $neovimId
if (-not $wingetListNeovimOutput) {

  Write-Host "Neovim for Windows is not installed."
  Write-Host "Installing Neovim with winget..."
  winget install Neovim.Neovim
} else {

  Write-Host "Neovim for Windows is already installed."
}

###
##
# MARK: |X| Recommend next steps

# Only show recommended tasks related to modifications made in this script run.
if (-not ($didInstallPowerToys -or $didGenerateSSHKeys)) {

  Write-Host ""
  Write-Host "Recommended next steps:"

  if ($didInstallPowerToys) { Write-Host "- Remap Caps Lock to Esc with the Keyboard Manager PowerToy." }
  if ($didGenerateSSHKeys) { Write-Host "- Add the generated SSH public key to your GitHub account."}
  if ($didInstallExtension) { Write-Host "- Install VSCode extensions in WSL:Ubuntu from the VSCode Extensions sidebar"}

  Write-Host "Complete."
} else {

  Write-Host "Complete."
}

