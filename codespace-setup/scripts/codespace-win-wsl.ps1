# codespace-win-wsl.ps1
# This PowerShell script begins the setup for codespace on Windows.
#
# To run:
# 1)  Press Windows + X and select Windows PowerShell (Admin) or Terminal (Admin)� if you're on a newer version of Windows.
# 2)  Allow scripts by running: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process`
# 3)  Run this script directly from PowerShell

###
##
# MARK: Helper Functions

# >> MARK: Find-FilesMatchingPattern
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

# >> MARK: Get-RepoAsset
function Get-RepoAsset {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [Parameter(Mandatory=$true)]
    [int]$AssetsIndex,

    [Parameter(Mandatory=$false)]
    [string]$OutDirectory = $env:TEMP
  )

  try {
    # Get the latest releases for the specified repo via the GitHub API Url
    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    Write-Host "Getting metadata for latest release of $Repo..."
    $latestReleases = Invoke-RestMethod -Uri $apiUrl -Headers @{ Accept = 'application/vnd.github.v3+json' }

    # Check if the specified index is valid
    if ($latestReleases.assets.Count -le $AssetsIndex -or $AssetsIndex -lt 0) {
      Write-Error "AssetsIndex is out of range."
      return $null
    }

    # Get the asset URL and name
    $assetUrl = $latestReleases.assets[$AssetsIndex].browser_download_url
    if (-not $assetUrl) {
      Write-Error "No download URL found at the specified index."
      return $null
    }
    $assetName = $latestReleases.assets[$AssetsIndex].name
    if (-not $assetName) {
      Write-Error "No name found at the specified index."
      return $null
    }

    # Ensure the output directory exists
    if (-not (Test-Path $OutDirectory)) {
      New-Item -Path $OutDirectory -ItemType Directory
    }

    # Download the file
    $outputPath = Join-Path -Path $OutDirectory -ChildPath $assetName
    Write-Host "Downloading $assetName..."
    Invoke-WebRequest -Uri $assetUrl -OutFile $outputPath

    # Return the path to the downloaded file
    return $outputPath
  } catch {
    Write-Error "An error occurred: $_"
    return $null
  }
}

# >> MARK: Get-WslUserName
function Get-WslUserName {
  param (
    [string]$WslUbuntuDrivePath = "\\wsl.localhost\Ubuntu"
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
# MARK: Global variables

$userProfileName = Split-Path $env:USERPROFILE -leaf
$windowsAppsDir = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft/WindowsApps"
$winspaceDir = Join-Path -Path $env:USERPROFILE -ChildPath "winspace"
$winspaceSetupDir = Join-Path -Path $winspaceDir -ChildPath "setup"
$wslUbuntuDrive = "\\wsl.localhost\Ubuntu"
$wslUserName = Get-WslUserName

###
##
# MARK: |A| Create a winspace directory in %USERPROFILE%

if (-not (Test-Path -Path $winspaceDir)) {

  Write-Host "winspace directory in $env:USERPROFILE doesn't exist."
  Write-Host "Creating winspace in $env:USERPROFILE..."
  New-Item -Path $winspaceSetupDir -ItemType Directory -Force | Out-Null

} elseif (-not (Test-Path -Path $winspaceSetupDir)) {

  Write-Host "setup directory in $winspaceDir doesn't exist."
  Write-Host "Creating setup directory in $winspaceDir..."
  New-Item -Path $winspaceSetupDir -ItemType Directory -Force | Out-Null

} else {

  Write-Host "winspace directory in $env:USERPROFILE already exists."
}


###
##
# MARK: |B| Install WSL and Ubuntu

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

# >> MARK: |2| Check for WSL upgrade race condition
$wslOutput = wsl -l -v 2>&1
if ($LASTEXITCODE -ne 0) {
  if ($wslOutput -like "*WSL is finishing an upgrade*") {

    Write-Host "WSL is finishing an upgrade and may require a restart."
    $userConfirmation = Read-Host "Do you want to restart the computer now? (Y/n)"
    if ($userConfirmation -eq 'N' -or $userConfirmation -eq 'n') {
      Write-Host "Restart aborted. Please remember to manually restart the computer later."
      exit 1
    } else {
      Write-Host "Restarting the computer..."
      Restart-Computer
    }
  }
}

# >> MARK: |3| Update WSL
wsl --update
# TODO: Test whether wsl --shutdown is needed (needs clean Win install)

# >> MARK: |4| Set the default version of WSL distributions
Write-Host "Setting WSL default version to 2..."
Start-Sleep -Seconds 2 # Avoids "file cannot be accessed" error
wsl --set-default-version 2

# >> MARK: |5| Install Ubuntu if not installed
$cleanedWslOutput = $wslOutput -replace '[^\P{C}\p{Z}]', ''
if ($cleanedWslOutput -like "*Ubuntu*") {

  Write-Host "Ubuntu for WSL is already installed."

} else {

  Write-Host "Installing Ubuntu..."
  wsl --install --no-launch -d Ubuntu
  Write-Host "Wait 10 seconds for installation to finish..."
  Start-Sleep -Seconds 10
  $mustInitializeUbuntu = $true
}

# >> MARK: |6| Instruct user to initialize Ubuntu distribution
if ($mustInitializeUbuntu) {

  # Give instructions
  Write-Host ""
  Write-Host "ACTION NEEDED: Ubuntu must be launched a first time to initialize."
  Write-Host ""
  Write-Host "IMPORTANT: If on an Intel Mac, first launch Windows from macOS in System Preferences > Startup Disk to enable virtualization."
  Write-Host ""
  Write-Host "When ready to proceed, this script will launch Ubuntu, which will ask you to configure a username and password."
  Write-Host "Ubuntu will then silently initialize itself, after which it will show the bash prompt."
  Write-host ""
  Write-Host "IMPORTANT: Ubuntu initialization may take several minutes without progress indication."
  Write-Host ""
  Write-Host "Once the bash prompt appears, please exit Ubuntu, return to this window, and press Enter to continue."

  # Require confirmation of understanding
  $readReadyForUbuntu = Read-Host "Are you ready to proceed? (Y/n)"
  if (($readReadyForUbuntu -eq 'n') -or ($readReadyForUbuntu -eq 'N')) {
    Write-Host "Script aborted. Please ensure Ubuntu launches into a bash prompt before rerunning this script."
    exit 1
  }

  # Launch Ubuntu
  $ubuntuApp = Get-StartApps | Where-Object { $_.Name -like "*ubuntu*" }
  if (-not $ubuntuApp) {
    Write-Host "Error: Ubuntu is not found in the Start Menu apps. Aborting."
    exit 1
  }
  $ubuntuAppId = $ubuntuApp.AppID
  Start-Process "shell:AppsFolder\$ubuntuAppId"

  # Instruct user to wait, then enter new Ubuntu user name
  Write-Host ""
  Read-Host "Press Enter after waiting for the bash prompt to appear and exiting Ubuntu"
  $wslUserName = Read-Host "Enter the new user name configured for Ubuntu"

  # Shutdown and innocuously re-launch Ubuntu for good measure
  Write-Host "Shutting down WSL for good measure and waiting 3 seconds..."
  wsl --shutdown
  Start-Sleep -Seconds 3
  Write-Host "Restarting WSL Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "echo 'Ubuntu restarted successfully'"
  Start-Sleep -Seconds 1
}

###
##
# MARK: |C| Invoke codespace-ubuntu-wsl inside Ubuntu

$codespaceUbuntuSetupWinPath = Join-Path -Path $winspaceSetupDir -ChildPath "codespace-ubuntu-wsl.sh"
$codespaceUbuntuSetupUnixPath = $codespaceUbuntuSetupWinPath -replace '^C:\\', '/mnt/c/'
$codespaceUbuntuSetupUnixPath = $codespaceUbuntuSetupUnixPath -replace '\\', '/'

# >> MARK: |1| Download personal setup script for codespace on Ubuntu
if (-not (Test-Path $codespaceUbuntuSetupWinPath)) {

  # Download script
  Write-Host "Setup script for codespace-ubuntu-wsl is not found."
  Write-Host "Downloading personal setup script for codespace on Ubuntu for WSL..."
  $codespaceUbuntuSetupUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/codespace-setup/scripts/codespace-ubuntu-wsl.sh"
  Invoke-WebRequest -Uri $codespaceUbuntuSetupUrl -OutFile $codespaceUbuntuSetupWinPath
} else {

  Write-Host "Setup script for codespace-ubuntu-wsl already exists."
}

# >> MARK: |2| Fix nameserver in wsl.conf and resolv.conf
$grepResolvConfOutput = wsl -d Ubuntu -u root -- bash -c "grep 'nameserver 8.8.8.8' /etc/resolv.conf"
if ($grepResolvConfOutput) {

  Write-Host "wsl.conf and resolv.conf is already fixed."

} else {

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

  # Restart WSL to apply wsl.conf changes
  Write-Host "Shutting down WSL for good measure and waiting 3 seconds..."
  wsl --shutdown
  Start-Sleep -Seconds 3
  Write-Host "Restarting WSL Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "echo 'Ubuntu restarted successfully'"
  Start-Sleep -Seconds 1

  Write-Host "Fixing resolv.conf in Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "sudo chattr -f -i /etc/resolv.conf"
  wsl -d Ubuntu -u root -- bash -c "sudo rm /etc/resolv.conf 2>/dev/null"
  wsl -d Ubuntu -u root -- bash -c "sudo sh -c 'echo ''nameserver 8.8.8.8'' > /etc/resolv.conf'"
  wsl -d Ubuntu -u root -- bash -c "sudo chattr -f +i /etc/resolv.conf"
}

# >> MARK: |3| Run codespace setup in Ubuntu
$wslEtcPasswdPath = "$wslUbuntuDrive\etc\passwd"
$rootPasswdEntry = wsl -d Ubuntu -u root -- bash -c "grep '^root:' /etc/passwd"
if (-not ($rootPasswdEntry -and $rootPasswdEntry -match "root:.*:/bin/zsh$")) {
  Write-Host "Running codespace setup script in Ubuntu..."
  wsl -d Ubuntu -u root -- bash -c "chmod +x $codespaceUbuntuSetupUnixPath"
  wsl -d Ubuntu -u root -- bash -c $codespaceUbuntuSetupUnixPath
  if ($LASTEXITCODE -ne 0) {
    Write-Host "The codespace-ubuntu-wsl script exited with an error: $LASTEXITCODE"
    exit $LASTEXITCODE
  }
} else {

  Write-Host "Codespace setup script for Ubuntu has already completed successfully."
}

###
##
# MARK: |D| Generate SSH keys for GitHub and add to SSH agent

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

    $sshHostName = Read-Host "Give this identity a Host name (id_ed25519)"
    if (-not $sshHostName) {
      $sshHostName = "id_ed25519"
    }

    # TODO: Remove redundant logic
    if (-not $wslUserName) {

      $wslUserName = Read-Host "Enter the user name configured for WSL Ubuntu"
    }
    if ($wslUserName) {

      $wslUserHome = "$wslUbuntuDrive\home\$wslUserName"
      if (Test-Path $wslUserHome) {

        $readEmailForGitHub = Read-Host "Enter your optional email identifier to use with ssh-keygen"

        # Generate SSH keys with or without email identifier
        $sshIdentityFilePath = "/home/$wslUserName/.ssh/$sshHostName"
        if ($readEmailForGitHub) {
          wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-keygen -t ed25519 -C `"$readEmailForGitHub`" -f `"$sshIdentityFilePath`""
        } else {
          wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-keygen -t ed25519 -f `"$sshIdentityFilePath`""
        }

        # Create .ssh/config file if doesn't exist
        $wslSSHConfigPath = "$wslUserSSHDir\config"
        if (-Not (Test-Path $wslSSHConfigPath)) {
          New-Item -Path $wslSSHConfigPath -ItemType File | Out-Null
          Write-Host "Creating SSH config file at $wslSSHConfigPath..."
        } else {
          Write-Host "SSH config file already exists."
        }

        # Add the Host configuration to .ssh/config if doesn't exist
        $sshConfigContent = Get-Content -Path $wslSSHConfigPath
        if ($sshConfigContent -notcontains "Host $sshHostName") {
          $sshHostConfig = @"
Host $sshHostName
    HostName github.com
    User git
    IdentityFile ~/.ssh/$sshHostName

"@
          Add-Content -Path $wslSSHConfigPath -Value $sshHostConfig

          # Converts line endings to Unix
          $sshConfigPath = "/home/$wslUserName/.ssh/config"
          wsl -d Ubuntu -u $wslUserName -- bash -c "[[ -x /usr/bin/dos2unix ]] && /usr/bin/dos2unix $sshConfigPath"

          Write-Host "Added configuration to SSH config file for Host $sshHostName."
        }

        # Add an AddKeysToAgent configuration to all Hosts
        if ($sshConfigContent -notcontains "Host *") {
          # Append the 'Host *' configuration
          $sshGlobalConfig = @"
Host *
    AddKeysToAgent yes

"@
          Add-Content -Path $wslSSHConfigPath -Value $sshGlobalConfig
          Write-Host "Added AddKeysToAgent configuration for all Hosts."
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

  # Take the opportunity to set private key permissions to 600
  if ($sshHostName) {
    wsl -d Ubuntu -u $wslUserName -- bash -c "chmod 600 ~/.ssh/$sshHostName"
  }

  # Configure ssh-agent and funtoo/keychain with SSH key
  if ($sshHostName) {

    # Careful syntax required to preserve environment for ssh-add
    wsl -d Ubuntu -u $wslUserName -- bash -c "ssh-agent bash -c 'ssh-add ~/.ssh/$sshHostName'"

    # Initialize funtoo/keychain with ssh key
    wsl -d Ubuntu -u $wslUserName -- bash -c "sed -i '/^#keychain#/c\eval \$\(keychain -q --eval --agents ssh $sshHostName)' ~/.zshrc"

    # Update .zshrc to load identify in ssh-agent when sourced (disabled, keychain sufficient)
    # wsl -d Ubuntu -u $wslUserName -- bash -c "sed -i '/^#zsshagent1#/c\zstyle :omz:plugins:ssh-agent identities $sshHostName' ~/.zshrc"
    # wsl -d Ubuntu -u $wslUserName -- bash -c "sed -i '/^#zsshagent2#/c\plugins=(ssh-agent)' ~/.zshrc"

  } else {

    Write-Host "Unexpected error. SSH key not added to ssh-agent."
  }
}

###
##
# MARK: |E| Install VSCode

# >> MARK: |1| Download and install VS Code if not already installed
$vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
if (-not (Test-Path $vscodePath)) {
  Write-Host "VSCode is not installed."

  $vscodeInstallerPath = "$winspaceSetupDir\VSCodeSetup.exe"
  if (-not (Test-Path $vscodeInstallerPath)) {

    Write-Host "Installer for VSCode is not found."
    Write-Host "Downloading installer for VSCode..."
    Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $vscodeInstallerPath
  } else {

    Write-Host "Installer for VSCode found in $winspaceSetupDir."
  }

  Write-Host "Running installer for VSCode silently (this may take a minute)..."
  Start-Process -FilePath $vscodeInstallerPath -Args "/VERYSILENT /MERGETASKS=!runcode" -Wait

  $didInstallVSCode = $true
} else {
  Write-Host "VSCode is already installed."
}

# >> MARK: |2| Install extensions

# Define the path to code CLI command
$vscodeCLIPath = "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
if (-not (Test-Path $vscodeCLIPath)) { $vscodeCLIPath = "C:\Program Files\Microsoft VS Code\bin\code.cmd" }

if ($vscodeCLIPath) {

  $vscodeInstalledExtensions = & $vscodeCLIPath --list-extensions

  # >>>> MARK: |2.1| Install-VSCodeExtension function installs a VSCode extension by id only when not already installed
  function Install-VSCodeExtension {
    Param(
      [string]$ExtensionId,
      [string[]]$InstalledExtensions,
      [string]$VscodeCLIPath
    )
    $baseExtensionId = $ExtensionId -split '@' | Select-Object -First 1
    if ($baseExtensionId -notin $InstalledExtensions) {
      Write-Host "Installing extension: $ExtensionId..."
      & $VscodeCLIPath --install-extension $ExtensionId
      $didInstallExtension = $true
    } else {
      Write-Host "Extension $ExtensionId is already installed."
    }
  }

  # >>>> MARK: |2.2| Install extensions by id
  @(
    # Most Important
    "alefragnani.project-manager",
    "asvetliakov.vscode-neovim",
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
    Install-VSCodeExtension -ExtensionId $_ -InstalledExtensions $vscodeInstalledExtensions -VscodeCLIPath $vscodeCLIPath
  }
} else {

  Write-Host "VSCode binary is not found."
}

# >>>> MARK: |2.3| Install personal box-checker extension

$boxCheckerId = "tw.box-checker"
if ($vscodeCLIPath) {
  $vscodeInstalledExtensions = & $vscodeCLIPath --list-extensions
}
if ($vscodeCLIPath -and $boxCheckerId -notin $vscodeInstalledExtensions) {

  Write-Host "Personal extension $boxCheckerId is not installed."

  $boxCheckerFilename = "box-checker-0.0.1.vsix"
  $boxCheckerPath = Join-Path -Path $winspaceSetupDir -ChildPath $boxCheckerFilename
  if (-not (Test-Path $boxCheckerPath)) {

    Write-Host "Installer for $boxCheckerId is not found."
    Write-Host "Downloading $boxCheckerFilename..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/$boxCheckerFilename" -OutFile $boxCheckerPath
  } else {

    Write-Host "Installer for $boxCheckerId found in $winspaceSetupDir."
  }

  Write-Host "Installing extension: $boxCheckerId..."
  & $vscodeCLIPath --install-extension $boxCheckerPath
  $didInstallExtension = $true
} else {

  Write-Host "Personal extension $boxCheckerId is already installed."
}

# >> MARK: |3| Import personal settings and keybindings files

# |3.1| First check whether backup files already exist, and continue only if they don't
$vscodeUserPath = "$env:APPDATA\Code\User"
$vscSettingsBackupPattern = '^settings_\d{4}-\d{2}-\d{2}(-\d{4})?\.json$'
$vscKeybindingsBackupPattern = '^keybindings_\d{4}-\d{2}-\d{2}(-\d{4})?\.json$'
$hasSettingsBackup = Find-FilesMatchingPattern -path $winspaceSetupDir -pattern $vscSettingsBackupPattern
$hasKeybindingsBackup = Find-FilesMatchingPattern -path $winspaceSetupDir -pattern $vscKeybindingsBackupPattern

if (-not ($hasSettingsBackup -and $hasKeybindingsBackup)) {

  # |3.2| Back up settings and keybindings only when not already backed up
  Write-Host "Backups for default settings and keybindings are not found."
  Write-Host "Backing up settings and keybindings files to $winspaceSetupDir..."
  $vscSettingsPath = Join-Path -Path $vscodeUserPath -ChildPath "settings.json"
  $vscKeybindingsPath = Join-Path -Path $vscodeUserPath -ChildPath "keybindings.json"
  $currentDate = Get-Date -Format "yyyy-MM-dd"
  $backupVscSettingsFilename = "settings_$currentDate.json"
  $backupVscKeybindingsFilename = "keybindings_$currentDate.json"
  $backupVscSettingsPath = Join-Path -Path $winspaceSetupDir -ChildPath $backupVscSettingsFilename
  $backupVscKeybindingsPath = Join-Path -Path $winspaceSetupDir -ChildPath $backupVscKeybindingsFilename
  if (Test-Path $vscSettingsPath) { Move-Item -Path $vscSettingsPath -Destination $backupVscSettingsPath }
  if (Test-Path $vscKeybindingsPath) { Move-Item -Path $vscKeybindingsPath -Destination $backupVscKeybindingsPath }

  # |3.4| Download and replace with personal settings and keybindings files
  Write-Host "Downloading personal settings and keybindings into VSCode..."
  $vscSettingsUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/win/settings.json"
  $vscKeybindingsUrl = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/vscode/win/keybindings.json"
  Invoke-WebRequest -Uri $vscSettingsUrl -OutFile $vscSettingsPath
  Invoke-WebRequest -Uri $vscKeybindingsUrl -OutFile $vscKeybindingsPath

  # |3.5| Modify username for linux in settings file
  if ($wslUserName) {
    $vscOldUserName = "/home/tomw"
    $vscNewUserName = "/home/$wslUserName"
    (Get-Content $vscSettingsPath) -replace $vscOldUserName, $vscNewUserName | Set-Content $vscSettingsPath
  }
} else {

  Write-Host "Backups for default settings and keybindings are found."
}

###
##
# MARK: |F| Install personal fonts

# |1| Check if fonts are already installed
$fontName1 = "MesloLGLDZNerdFontMono-Bold.ttf"
$fontName2 = "RobotoMonoNerdFontMono-Medium.ttf"
$fontsDirectory = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Windows\Fonts"
if (-not (Test-Path -Path $fontsDirectory)) {
  New-Item -Path $fontsDirectory -ItemType Directory | Out-Null
}
$fontFilePath1 = Join-Path -Path $fontsDirectory -ChildPath $fontName1
$fontFilePath2 = Join-Path -Path $fontsDirectory -ChildPath $fontName2

if (-not ((Test-Path -Path $fontFilePath1) -and (Test-Path -Path $fontFilePath2))) {

  Write-Host "Personal fonts for code are not installed."

  # |2| Download fonts when not found
  $fontDownloadPath1 = Join-Path -Path $winspaceSetupDir -ChildPath $fontName1
  $fontDownloadPath2 = Join-Path -Path $winspaceSetupDir -ChildPath $fontName2
  if (-not (Test-Path "$fontDownloadPath1") -and -not (Test-Path "$fontDownloadPath2")) {
    Write-Host "Downloading personal fonts for code..."
    $fontUrl1 = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/fonts/$fontName1"
    $fontUrl2 = "https://raw.githubusercontent.com/tw-studio/dotfiles/main/fonts/$fontName2"
    Invoke-WebRequest -Uri $fontUrl1 -OutFile $fontDownloadPath1
    Invoke-WebRequest -Uri $fontUrl2 -OutFile $fontDownloadPath2
  } else {
    Write-Host "Font files are found in $winspaceSetupDir."
  }

  # |3| Guide users to installing fonts themselves
  Write-Host "Installing fonts requires completing the installations in the dialogs that appear."
  Write-Host "Installing $fontName1..."
  Invoke-Item $fontDownloadPath1
  Read-Host "Press Enter after you have finished installing the font"
  Write-Host "Installing $fontName2..."
  Invoke-Item $fontDownloadPath2
  Read-Host "Press Enter after you have finished installing the font"

} else {

  Write-Host "Personal fonts for code are already installed."
}

###
##
# MARK: |H| Install PowerToys

# Continue only if PowerToys is not already installed
$alreadyInstalledPowerToys = Get-CimInstance -ClassName Win32_Product |
                             Where-Object { $_.Name -like "*PowerToys*" }
if ($alreadyInstalledPowerToys) {

  Write-Host "Microsoft PowerToys is already installed."

} else {

  Write-Host "Microsoft PowerToys is not installed."

  # Use the GitHub API to fetch metadata about the latest release of PowerToys
  $powerToysRepo = "microsoft/PowerToys"
  $powerToysDownloadName = "PowerToysUserSetup-0.81.1-x64.exe"
  $powerToysDownloadUrl = "https://github.com/microsoft/PowerToys/releases/download/v0.81.1/$powerToysDownloadName"
  $powerToysDownloadPath = Join-Path -Path "$winspaceSetupDir" -ChildPath $powerToysDownloadName

  # Download PowerToys installer when not found
  if (-not (Test-Path "$powerToysDownloadPath")) {

    Write-Host "Downloading $powerToysDownloadName from $powerToysRepo..."
    Invoke-WebRequest -Uri "$powerToysDownloadUrl" -OutFile "$powerToysDownloadPath"
    if (-not (Test-Path "$powerToysDownloadPath")) {
      Write-Error "Failed to download Microsoft PowerToys."
      exit 1
    }
  } else {

    Write-Host "Installer for Microsoft PowerToys found in $winspaceSetupDir."
  }

  # Install PowerToys
  Write-Host "Installing Microsoft PowerToys..."
  Start-Process -FilePath "$powerToysDownloadPath" -Wait

  # Wait for user to install PowerToys
  Write-Host "The Keyboard Manager PowerToy is useful for remapping Caps Lock to Esc."
  Read-Host "Press Enter after you have finished installing Microsoft PowerToys"
  $didInstallPowerToys = $true
}

###
##
# MARK: |G| Install WinGet

# >> MARK: |1| Install NuGet CLI
if (-not (Get-Command "nuget" -ErrorAction SilentlyContinue)) {

  Write-Host "NuGet CLI is not installed."

  $nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
  $nugetDownloadPath = "$winspaceSetupDir\nuget.exe"
  $nugetInstallDir = "$windowsAppsDir"
  $nugetInstallPath = "$nugetInstallDir\nuget.exe"

  if (-not (Test-Path "$nugetInstallPath")) {

    # Download NuGet CLI first to winspace setup before copying to WindowsApps
    if (-not (Test-Path "$nugetDownloadPath")) {
      Write-Host "NuGet CLI is not downloaded."
      Write-Host "Downloading NuGet CLI to $winspaceSetupDir..."
      Invoke-WebRequest -Uri $nugetUrl -OutFile "$nugetDownloadPath"
    } else {
      Write-Host "NuGet CLI found in $winspaceSetupDir."
    }

    Write-Host "Installing (copying) NuGet CLI to $nugetInstallDir..."
    Copy-Item -Path $nugetDownloadPath -Destination $nugetInstallPath
  } else {

    Write-Host "NuGet CLI is already installed."
  }

  # Verify installation
  if (-not (Get-Command "nuget" -ErrorAction SilentlyContinue)) {
    Write-Error "Failed to install NuGet CLI."
    exit 1
  }
} else {

  Write-Host "NuGet CLI is already installed."
}

# >> MARK: |2| Use NuGet to install Microsoft.UI.Xaml framework dependency for WinGet
$xamlPackageName = "Microsoft.UI.Xaml"
$nugetGlobalPackagesPath = Join-Path -Path "$env:USERPROFILE" -ChildPath ".nuget\packages"
$xamlPackagePath = Join-Path "$nugetGlobalPackagesPath" -ChildPath "$xamlPackageName"
if (-not (Test-Path -Path "$xamlPackagePath")) {
  Write-Host "$xamlPackageName >=2.8 framework is not already installed."
  Write-Host "Installing $xamlPackageName..."
  nuget install $xamlPackageName -OutputDirectory "$xamlPackagePath"
} else {
  Write-Host "$xamlPackageName >=2.8 is already installed."
}

# >> MARK: |3| Download and install winget-cli
$wingetPackageName = "Microsoft.DesktopAppInstaller"
if (-not (Get-AppxPackage -Name $wingetPackageName)) {

  Write-Host "winget-cli ($wingetPackageName) is not already installed."

  # Use the GitHub API to fetch metadata about the latest release of winget
  $wingetCliRepo = "microsoft/winget-cli"
  $wingetCliDownloadName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
  $wingetCliDownloadUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.7.11261/$wingetCliDownloadName"
  $wingetCliDownloadPath = Join-Path -Path "$winspaceSetupDir" -ChildPath $wingetCliDownloadName

  # Download winget-cli installer when not found
  if (-not (Test-Path "$wingetCliDownloadPath")) {

    Write-Host "Downloading $wingetCliDownloadName from $wingetCliRepo..."
    Invoke-WebRequest -Uri "$wingetCliDownloadUrl" -OutFile "$wingetCliDownloadPath"
    if (-not (Test-Path "$wingetCliDownloadPath")) {
      Write-Error "Failed to download winget-cli."
      exit 1
    }
  } else {

    Write-Host "Installer for winget-cli found in $winspaceSetupDir."
  }

  # Install winget
  Write-Host "Installing winget-cli ($wingetPackageName)..."
  Add-AppxPackage -Path $wingetCliDownloadPath

} else {

  Write-Host "winget-cli ($wingetPackageName) is already installed."
}

###
##
# MARK: |I| Install Windows Terminal

# >> MARK: |1| Install Windows Terminal via winget
$windowsTerminalId = "Microsoft.WindowsTerminal"
$wingetListWindowsTerminalOutput = winget list -q $windowsTerminalId --accept-source-agreements
if (-not $wingetListWindowsTerminalOutput -or ($wingetListWindowsTerminalOutput -like "*No installed package found*")) {

  Write-Host "$windowsTerminalId is not already installed by $wingetPackageName."
  Write-Host "Installing $windowsTerminalId..."
  winget install --id=Microsoft.WindowsTerminal -e --accept-source-agreements --accept-package-agreements
} else {

  Write-Host "$windowsTerminalId is already installed."
}

# >> MARK: |2| Launch Windows Terminal once when settings.json isn't found
$windowsTerminalSettingsPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path -Path $windowsTerminalSettingsPath)) {

  Write-Host "Settings file for Windows Terminal is not found."

  if (-not (winget list -q "$windowsTerminalId" | Select-String "$windowsTerminalId")) {
    Write-Error "Windows Terminal is unexpectedly not installed. Can't launch wt to initialize its settings."
    exit 1
  }

  Write-Host "Launching Windows Terminal to automatically create its settings.json file..."
  Start-Process wt

  Read-Host "Please close Windows Terminal and then press Enter to continue"
} else {

  Write-Host "Settings file for Windows Terminal already exists."
}

# >> MARK: |3| Modify settings for Windows Terminal
if (Test-Path -Path $windowsTerminalSettingsPath) {

  $wtSettings = Get-Content -Path $windowsTerminalSettingsPath -Raw | ConvertFrom-Json

  # Check if settings has already been modified by this script by checking if "tw" scheme exists
  if (-not ($wtSettings.schemes -and ($wtSettings.schemes | Where-Object { $_.name -eq "tw" }))) {

    Write-Host "Customizing settings for Windows Terminal..."

    # Update global settings
    $wtSettings | Add-Member -NotePropertyName "alwaysShowTabs" -NotePropertyValue $false -Force
    $wtSettings | Add-Member -NotePropertyName "confirmCloseAllTabs" -NotePropertyValue $false -Force
    $wtSettings | Add-Member -NotePropertyName "showTabsInTitlebar" -NotePropertyValue $true -Force
    $wtSettings | Add-Member -NotePropertyName "theme" -NotePropertyValue "dark" -Force
    $wtSettings | Add-Member -NotePropertyName "initialCols" -NotePropertyValue 120 -Force
    $wtSettings | Add-Member -NotePropertyName "initialPosition" -NotePropertyValue "150,75" -Force
    $wtSettings | Add-Member -NotePropertyName "initialRows" -NotePropertyValue 32 -Force
    $wtSettings | Add-Member -NotePropertyName "showTerminalTitleInTitlebar" -NotePropertyValue $false -Force
    $wtSettings | Add-Member -NotePropertyName "tabWidthMode" -NotePropertyValue "equal" -Force

    # Update default profile settings, safely
    if (-not ($wtSettings.PSObject.Properties.Name -contains "profiles")) {
      $wtSettings | Add-Member -NotePropertyName "profiles" -NotePropertyValue (New-Object PSObject -Property @{}) -Force
    }
    if (-not ($wtSettings.profiles.PSObject.Properties.Name -contains "defaults")) {
      $wtSettings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue (New-Object PSObject -Property @{}) -Force
    }
    if (-not ($wtSettings.profiles.defaults.PSObject.Properties.Name -contains "font")) {
      $wtSettings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue (New-Object PSObject -Property @{}) -Force
    }
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue "tw" -Force
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "historySize" -NotePropertyValue 9001 -Force
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "opacity" -NotePropertyValue 98 -Force
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "padding" -NotePropertyValue "8" -Force
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "startingDirectory" -NotePropertyValue "%USERPROFILE%\winspace" -Force
    $wtSettings.profiles.defaults | Add-Member -NotePropertyName "useAcrylic" -NotePropertyValue $true -Force
    $wtSettings.profiles.defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue "MesloLGLDZ Nerd Font Mono" -Force
    $wtSettings.profiles.defaults.font | Add-Member -NotePropertyName "size" -NotePropertyValue 10.0 -Force

    # Configure the Ubuntu profile
    $wtUbuntuProfile = $wtSettings.profiles.list | Where-Object { $_.source -like "CanonicalGroupLimited.Ubuntu*" } | Select-Object -First 1
    if ($wtUbuntuProfile) {

      # Set defaultProfile to Ubuntu profile's guid
      $wtUbuntuGuid = $wtUbuntuProfile.guid
      $wtSettings.defaultProfile = $wtUbuntuGuid

      # Set the startingDirectory for Ubuntu to codespace
      if (-not $wslUserName) {
        Write-Error "Unexpected error. User name for wsl is not detected."
        exit 1
      }
      if (-not ($wtUbuntuProfile.PSObject.Properties.Name -contains "startingDirectory")) {
        $wtUbuntuProfile | Add-Member -NotePropertyName "startingDirectory" -NotePropertyValue "$wslUbuntuDrive\home\$wslUserName\codespace"
      }

      # Reorder profiles to put Ubuntu first
      $wtOtherProfiles = $wtSettings.profiles.list | Where-Object { $_.source -notlike "CanonicalGroupLimited.Ubuntu*" }
      $wtSettings.profiles.list = @($wtUbuntuProfile) + $wtOtherProfiles
    }

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
      brightCyan = "#5fd7ff"
      brightGreen = "#7bd88f"
      brightPurple = "#948ae3"
      brightRed = "#fc618d"
      brightWhite = "#f7f1ff"
      brightYellow = "#fce566"
      cyan = "#5fd7ff"
      green = "#7bd88f"
      purple = "#948ae3"
      red = "#fc618d"
      white = "#f7f1ff"
      yellow = "#fce566"
    }
    if (-not $wtSettings.schemes) {
      $wtSettings.schemes = @()
    }
    if (-not ($wtSettings.schemes | Where-Object { $_.name -eq "tw" })) {
      $wtSettings.schemes += $twScheme
    }

    # Save the updated settings back to the file
    $wtSettings | ConvertTo-Json -Depth 100 | Set-Content -Path $windowsTerminalSettingsPath

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
# MARK: |J| Download and install Mullvad VPN

# Continue only when Mullvad is not installed
$isMullvadInstalled = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                      Where-Object { $_.DisplayName -like "*Mullvad*" }
if (-not $isMullvadInstalled) {

  Write-Host "Mullvad VPN is not installed."

  $readReadyForMullvadInstall = Read-Host "Do you want to install Mullvad VPN? (Y/n)"
  if ((-not $readReadyForMullvadInstall) -or $readReadyForMullvadInstall -eq 'y' -or $readReadyForMullvadInstall -eq 'Y') {

    Write-Host "Checking latest version of Mullvad VPN installer..."
    $mullvadInstallerUrl = "https://mullvad.net/en/download/app/exe/latest"
    $mullvadInstallerHeadResponse = Invoke-WebRequest -Uri $mullvadInstallerUrl -Method Head -MaximumRedirection 5 -ErrorAction Stop
    $mullvadInstallerFilename = [System.IO.Path]::GetFileName($mullvadInstallerHeadResponse.BaseResponse.ResponseUri.LocalPath)
    $mullvadInstallerOutputPath = Join-Path -Path $winspaceSetupDir -ChildPath $mullvadInstallerFilename

    if (-not (Test-Path "$mullvadInstallerOutputPath")) {
      Write-Host "Downloading latest Mullvad VPN installer to $winspaceSetupDir..."
      Invoke-WebRequest -Uri $mullvadInstallerUrl -OutFile $mullvadInstallerOutputPath
    } else {
      Write-Host "Latest installer for Mullvad VPN found in $winspaceSetupDir."
    }

    # Add 30 second timeout in case "Run now" checkbox is unchecked in the installer,
    # which keeps script from recognizing when install is done
    Write-Host "Installing Mullvad VPN..."
    $mullvadInstallerProcess = Start-Process -FilePath $mullvadInstallerOutputPath -PassThru
    $timeoutInSeconds = 30
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while ($mullvadInstallerProcess.HasExited -eq $false) {
      Start-Sleep -Seconds 1
      if ($stopwatch.Elapsed.TotalSeconds -gt $timeoutInSeconds) {
        $mullvadInstallerProcess | Stop-Process -Force
        Write-Host "Process for installing Mullvad VPN timed out at $timeoutInSeconds seconds and was killed."
        break
      }
    }
    $stopwatch.Stop()

    Write-Host "Mullvad VPN is installed."
    $didInstallMullvad = $true

    $readReadyForMullvadAccount = Read-Host "Do you want to log in with your Mullvad account number now? (Y/n)"
    if ((-not $readReadyForMullvadAccount) -or $readReadyForMullvadAccount -eq 'y' -or $readReadyForMullvadAccount -eq 'Y') {

      $mullvadCLIPath = "C:\Program Files\Mullvad VPN\resources\mullvad.exe"

      $readMullvadAccountNumber = Read-Host "Enter your Mullvad account number"
      if ($readMullvadAccountNumber -match "^\d{16}$") {

        Write-Host "Logging in to Mullvad with $readMullvadAccountNumber..."
        $outputMullvadAccountLogin = & $mullvadCLIPath account login $readMullvadAccountNumber

        if ($?) {

          Write-Host "Login successful."

          $readReadyForMullvadAutoConnect = Read-Host "Do you want to configure Mullvad to auto-connect on system startup? (Y/n)"
          if ((-not $readReadyForMullvadAutoConnect) -or $readReadyForMullvadAutoConnect -eq 'y' -or $readReadyForMullvadAutoConnect -eq 'Y') {

            Write-Host "Configuring Mullvad to auto-connect on system startup..."
            & $mullvadCLIPath auto-connect set on
          }

          $readReadyForMullvadLockdownMode = Read-Host "Do you want to configure Mullvad to enable Lockdown Mode? (Y/n)"
          if ((-not $readReadyForMullvadLockdownMode) -or $readReadyForMullvadLockdownMode -eq 'y' -or $readReadyForMullvadLockdownMode -eq 'Y') {

            Write-Host "Enabling Mullvad Lockdown Mode..."
            & $mullvadCLIPath lockdown-mode set on
          }
        } else {

          Write-Host "Login unsuccessful: $outputMullvadAccountLogin"
        }
      } else {

        Write-Host "Input not recognized as Mullvad account number. Skipping login."
      }
    }
  } else {

    Write-Host "Skipping install of Mullvad VPN."
  }
} else {

  Write-Host "Mullvad VPN is already installed."
}

###
##
# MARK: Configure personal PowerShell profile (placeholder)

# Steps:
# 1) Download personal PowerShell profile
# 2) Copy to $HOME\Documents\WindowsPowerShell\Profile.ps1 (PowerShell 5.1 or earlier)
# 3) Source with `. <path>`

###
##
# MARK: Install Neovim for Windows (placeholder)

# Steps:
# 0) (optional) Set up personal PowerShell profile
# 1) Install neovim via winget: winget install Neovim.Neovim -e
# 2) Make nvim config directory: New-Item -ItemType "directory" -Path "$env:LOCALAPPDATA\nvim" -Force
# 3) Download personal init.vim to nvim config directory
# 4) Make nvim/colors directory: New-Item -ItemType "directory" -Path "$env:LOCALAPPDATA\nvim\colors" -Force
# 5) Download color theme files to nvim/colors
# 6) Force create this directory path: $env:LOCALAPPDATA\nvim-data\site\autoload
# 7) Download plug.vim to this autoload directory
# 8) (troubleshoot why vim-plug isn't working on Windows)
# 9) (if vim-plug can't work on Windows, set up dracula theme with file instead)

###
##
# MARK: Set up git for Windows (placeholder)

# Steps:
# 1) Install git with winget: winget install --id Git.Git -e --source winget
# ...) Set up git stuff like for Ubuntu

###
##
# MARK: Set up oh-my-posh (placeholder)

# Steps:
# 1) Install oh-my-posh: winget install JanDeDobbeleer.OhMyPosh -s winget
# 2) Reload path
# -> (check whether antivirus acts up)
# ...) Follow next steps at https://ohmyposh.dev 

###
##
# MARK: Set up node (placeholder)

# Steps:
# 1) (from nodejs site) Install node with fnm::
#      winget install Schniz.fnm
#      fnm use --install-if-missing 20
# 2) (troubleshoot why fnm isn't working)
# ...) Set up other stuff I like, such as pnpm

###
##
# MARK: Suggested next steps

# Only show suggested tasks related to modifications made in this script run.
if ($didInstallPowerToys -or $didGenerateSSHKeys -or $didInstallExtension -or $didInstallVSCode -or $didInstallMullvad) {

  Write-Host ""
  Write-Host "Suggested next steps:"
  Write-Host "---------------------"

  if ($didGenerateSSHKeys)  { Write-Host "SSH key is generated. Add the generated SSH public key to your GitHub account." }
  if ($didInstallVSCode)    { Write-Host "VSCode is installed. Open VSCode in a WSL folder, then click 'Reopen folder in WSL' in notification." }
  if ($didInstallExtension) { Write-Host "VSCode extensions are installed. Open the VSCode Extensions sidebar when in WSL mode, then click Install in WSL:Ubuntu for the listed extensions." }
  if ($didInstallPowerToys) { Write-Host "PowerToys is installed. Remap Caps Lock to Esc with the Keyboard Manager PowerToy." }
  if ($didInstallMullvad)   { Write-Host "Mullvad VPN is installed. Run Mullvad, and remember to adjust its settings, if not already done." }
  Write-Host "Clean up downloaded setup files from $winspaceSetupDir."
  Write-Host "Set scaling to 175% in Display Settings."

  Write-Host ""
  Write-Host "Complete."
} else {

  Write-Host ""
  Write-Host "Complete."
}
