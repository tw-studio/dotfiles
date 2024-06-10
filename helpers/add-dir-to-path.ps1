# add-dir-to-path.ps1
# Function to add specified directory to PATH 

function Add-ToPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string]$Dir,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Machine", "User")]
    [string]$Target = "Machine"
  )

  Write-Host "Adding $Dir to $Target PATH..."

  # Get the current PATH environment variable
  $envPath = [System.Environment]::GetEnvironmentVariable("PATH", $Target)
  $envPathArray = $envPath -split ';'

  # Check if the path already exists in PATH
  if (-not ($envPathArray -contains $Dir)) {
    $newEnvPath = "$envPath;$Dir"
    [System.Environment]::SetEnvironmentVariable("PATH", $newEnvPath, $Target)
    Write-Host "$Dir added to $Target PATH."
  } else {
    Write-Host "$Dir is already in the $Target PATH."
  }

  # Refresh local process path environment variable if necessary
  if ($Target -eq "Machine") {
    if (-not ($env:PATH -split ';' -contains $Dir)) {
      $env:PATH += ";$Dir"
    }
  }
}
