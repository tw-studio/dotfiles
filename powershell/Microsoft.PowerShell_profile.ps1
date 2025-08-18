# PowerShell profile
#
# Source with `. $PROFILE`
# Location: $ONEDRIVE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

###
##
# MARK: Variables

$global:WSLHOME = Get-ChildItem -Path "\\wsl$\Ubuntu\home" -Directory | Select-Object -First 1
$global:BUILDSPACE = "$WSLHOME\buildspace"
$global:CODESPACE = "$WSLHOME\codespace"
$global:ONESPACE = "$ONEDRIVE\onespace"
$global:WINSPACE = "$HOME\winspace"
$global:ONEDRIVE = "$HOME\OneDrive"
# $global:ONEDRIVE = "$HOME\OneDrive - Microsoft"
# $global:myprofile = "$HOME\Documents\WindowsPowerShell\Profile.ps1"
# $global:myps = "$HOME\Documents\WindowsPowerShell\Profile.ps1"

###
##
# MARK: Configurations

# Improve terminal colors (guarded to work with 5.1 or 7)
if ($PSStyle -and $PSStyle.FileInfo) {
  foreach ($prop in 'SymbolicLink','Directory') {
    if ($PSStyle.FileInfo.PSObject.Properties.Name -contains $prop) {
      $PSStyle.FileInfo.$prop = switch ($prop) {
        'SymbolicLink' { "`e[35;1m" }
        'Directory'    { "`e[36;1m" }
      }
    }
  }
}
Set-PSReadLineOption -Colors @{ "Command" = "White" }

# Enhance tab completion with PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Delete line with Ctrl-U
Set-PSReadLineKeyHandler -Chord Ctrl+U -Function BackwardDeleteLine

###
##
# MARK: Aliases

# > MARK: Navigation Aliases

# >> MARK: Advanced-Ls: List in columns and rows
function Advanced-Ls {
  param($Path = ".", $Buffer = 2)

  # Retrieve all items in the specified path
  $items = Get-ChildItem -Path $Path
  $info = $items | ForEach-Object {
    [PSCustomObject]@{
      Text = $_.Name
      Length = $_.Name.Length
      Color = if ($_.PSIsContainer) { 'Cyan' } else { 'White' }
    }
  }

  # Determine the maximum width needed to display the longest item
  $maxWidth = ($info | Measure-Object -Property Length -Maximum).Maximum + $Buffer
  if ($maxWidth -eq $null -or $maxWidth -lt 1) {
    $maxWidth = 10  # Default minimum column width
  }

  # Calculate available columns based on the console window width
  $screenWidth = [console]::WindowWidth
  if ($screenWidth -lt $maxWidth) {
    $screenWidth = $maxWidth + 10  # Ensure screen width is always greater than max width
  }
  $columns = [Math]::Max(1, [Math]::Floor($screenWidth / $maxWidth))
  $formatString = "{0,-$maxWidth}"

  # Calculate the number of rows needed based on the number of columns
  $rowCount = [Math]::Ceiling($info.Count / $columns)
  if ($rowCount -eq 0) {
    $rowCount = 1  # Ensure at least one row
  }

  for ($row = 0; $row -lt $rowCount; $row++) {
    for ($col = 0; $col -lt $columns; $col++) {
      $index = $col * $rowCount + $row
      if ($index -lt $info.Count) {
        $text = $info[$index].Text
        $color = $info[$index].Color
        # Output each item formatted to fill the determined width
        Write-Host ($formatString -f $text) -ForegroundColor $color -NoNewline
      }
    }
    Write-Host ""  # New line after each row
  }
}
Set-Alias -Name ls -Value Advanced-Ls

# > MARK: Advanced-Cd: List directory contents after change
function Advanced-Cd {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
  )

  $fullPath = [System.IO.Path]::Combine($Path)

  if ($Host.Name -eq 'ConsoleHost' -and -not $PSISE) {
    Set-Location $fullPath
    ls
  } else {
    Set-Location $fullPath
  }
}
Remove-Item -Path Alias:cd -Force
Set-Alias -Name cd -Value Advanced-Cd -Option AllScope -Force

# >> MARK: Go* Shortcuts
function GoUp { cd .. }
function GoUpUp { cd ..\.. }
function GoUpUpUp { cd ..\..\.. }
Set-Alias -Name .. -Value GoUp
Set-Alias -Name ... -Value GoUpUp
Set-Alias -Name .... -Value GoUpUpUp
function GoBuildspace { cd $BUILDSPACE }
Set-Alias -Name build -Value GoBuildspace
Set-Alias -Name buildspace -Value GoBuildspace
function GoCodespace { cd $CODESPACE }
Set-Alias -Name codespace -Value GoCodespace
function GoDotfiles { cd $WINSPACE\dotfiles }
Set-Alias -Name dot -Value GoDotfiles
Set-Alias -Name dotfiles -Value GoDotfiles
function GoOnespace { cd $ONESPACE }
Set-Alias -Name one -Value GoOnespace
Set-Alias -Name onespace -Value GoOnespace
function GoWinspace { cd $WINSPACE }
Set-Alias -Name win -Value GoWinspace
Set-Alias -Name winspace -Value GoWinspace

# >> MARK: Assorted Shortcuts

# nv: nvim
Remove-Item -Path Alias:nv -Force
Set-Alias -Name nv -Value nvim

# pathr: Reload-Path
function Reload-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
Set-Alias -Name pathr -Value "Reload-Path"

# pedit: Edit-Profile
function Edit-Profile { nvim $PROFILE }
Set-Alias -Name pedit -Value "Edit-Profile"

# pnvim: Edit Nvim init.vim
function Edit-Nvim { nvim $env:LOCALAPPDATA\nvim\init.vim }
Set-Alias -Name pnvim -Value "Edit-Nvim"

# ptheme: Edit-Posh-Theme
function Edit-Posh-Theme {
  $winspacePoshThemePath = "$WINSPACE\setup\winspace.omp.json"
  if (Test-Path $winspacePoshThemePath) {
    nvim $winspacePoshThemePath
  } else {
    Write-Host "Custom theme not found at $winspacePoshThemePath."
  }
}
Set-Alias -Name ptheme -Value "Edit-Posh-Theme"

# touch: Touch-File
function Touch-File {
  param([string]$filePath)
  if (-Not (Test-Path $filePath)) {
    New-Item -ItemType File -Path $filePath -Force | Out-Null
  } else {
    (Get-Item $filePath).LastWriteTime = Get-Date
  }
}
Set-Alias -Name touch -Value "Touch-File"

# which: Get-Command
Set-Alias -Name which -Value Get-Command

###
##
# MARK: Pshmarks (like zshmarks)

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

# bm: Set-Pshmark
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

# go: Go-Pshmark
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

# dm: Delete-Pshmark
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

# sm: Show-Pshmarks
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

###
##
# MARK: Activate oh-my-posh

if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
  oh-my-posh init pwsh --config "$WINSPACE\setup\winspace.omp.json" | Invoke-Expression
  # oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\robbyrussell.omp.json" | Invoke-Expression
}

###
##
# MARK: Completions

Invoke-Expression -Command $(gh completion -s powershell | Out-String)
