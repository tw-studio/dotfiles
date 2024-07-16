# Profile.ps1

###
##
# Variables

$global:myprofile = "$HOME\Documents\WindowsPowerShell\Profile.ps1"
$global:myps = "$HOME\Documents\WindowsPowerShell\Profile.ps1"
$global:winspace = "$HOME\winspace"

###
##
# Aliases

Set-Alias -Name n -Value nvim
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
Set-Alias -Name pathr -Value "Reload-Path"
function Edit-Profile {
  nvim $HOME\Documents\WindowsPowerShell\Profile.ps1
}
Set-Alias -Name pedit -Value "Edit-Profile"
function Edit-Nvim {
  nvim $env:LOCALAPPDATA\nvim\init.vim
}
Set-Alias -Name pnvim -Value "Edit-Nvim"
function Reload-Profile {
  Write-Host "Reloading profile..."
  . "$HOME\Documents\WindowsPowerShell\Profile.ps1"
}
Set-Alias -Name preload -Value "Reload-Profile"
function Touch-File {
    param([string]$filePath)
    if (-Not (Test-Path $filePath)) {
        New-Item -ItemType File -Path $filePath -Force | Out-Null
    } else {
        (Get-Item $filePath).LastWriteTime = Get-Date
    }
}
Set-Alias -Name touch -Value "Touch-File"
function GoTo-Winspace {
  Set-Location $winspace
}
Set-Alias -Name win -Value "GoTo-Winspace"

###
##
# Pshmarks (like zshmarks)

$global:pshmarksDir = "$winspace\.pshmarks"
$global:pshmarksFile = Join-Path -Path $pshmarksDir -ChildPath "pshmarks.json"
if (-Not (Test-Path $pshmarksDir)) {
  New-Item -Path $pshmarksDir -ItemType Directory -Force
}
if (-Not (Test-Path $pshmarksFile)) {
  @{} | ConvertTo-Json | Set-Content $pshmarksFile
}

# Utility
function ConvertTo-Hashtable {
  param([psobject]$psObject)
  $hashTable = @{}
  $psObject.PSObject.Properties | ForEach-Object {
    $hashTable[$_.Name] = $_.Value
  }
  return $hashTable
}

# Utility
function Manage-Pshmarks {
  param(
    [string]$action,        # "get", "set", or "delete"
    [string]$name = $null,
    [string]$path = $null
  )

  try {
    $pshmarks = if ($pshmarksFile -and (Test-Path $pshmarksFile)) {
      $psObject = Get-Content $pshmarksFile | ConvertFrom-Json
      ConvertTo-Hashtable -psObject $psObject
    } else {
      @{}
    }

    switch ($action) {
      "get" {
        return $pshmarks
      }
      "set" {
        $pshmarks[$name] = $path
      }
      "delete" {
        $pshmarks.Remove($name) > $null
      }
    }

    if ($action -ne "get") {
      $pshmarks | ConvertTo-Json | Set-Content $pshmarksFile
    }
  } catch {
    Write-Error "Failed to manage bookmarks: $_"
  }
}

function Set-Pshmark {
  param(
    [Parameter(Mandatory=$true)]
    [string]$name
  )

  if ([string]::IsNullOrWhiteSpace($name)) {
    Write-Error "A bookmark name must be provided."
    return
  }

  $pshmarks = Manage-Pshmarks -action "get"

  if ($pshmarks[$name]) {
    Write-Warning "Bookmark with the name '$name' already exists."
  } else {
    Manage-Pshmarks -action "set" -name $name -path (Get-Location).Path
    Write-Host "Bookmark '$name' set."
  }
}
Set-Alias -Name bm -Value "Set-Pshmark"

function Go-Pshmark {
  param([string]$name)
  $pshmarks = Manage-Pshmarks -action "get"
  if ($pshmarks[$name]) {
    Set-Location $pshmarks.$name
  } else {
    Write-Error "Bookmark not found: $name"
  }
}
Set-Alias -Name go -Value "Go-Pshmark"

function Delete-Pshmark {
  param([string]$name)
  $pshmarks = Manage-Pshmarks -action "get"
  if ($pshmarks[$name]) {
    Manage-Pshmarks -action "delete"
    Write-Host "Bookmark '$name' deleted."
  } else {
    Write-Warning "Bookmark not found: $name"
  }
}
Set-Alias -Name dm -Value "Delete-Pshmark"

function Show-Pshmarks {
  $pshmarks = Manage-Pshmarks -action "get"

  if ($pshmarks.Count -eq 0) {
    Write-Host "No bookmarks found."
  } else {
    Write-Host "Bookmarks:"
    $pshmarks.GetEnumerator() | Sort-Object Name | ForEach-Object {
      Write-Host "  $($_.Name) -> $($_.Value)"
    }
  }
}
Set-Alias -Name sm -Value "Show-Pshmarks"

