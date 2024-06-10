# get-repo-asset.ps1
# Get-RepoAsset helper to download latest asset from GitHub

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
    $latestRelease = Invoke-RestMethod -Uri $apiUrl -Headers @{ Accept = 'application/vnd.github.v3+json' }

    # Check if the specified index is valid
    if ($latestRelease.assets.Count -le $AssetsIndex -or $AssetsIndex -lt 0) {
      Write-Error "AssetsIndex is out of range."
      return $null
    }

    # Get the asset URL and name
    $assetUrl = $latestRelease.assets[$AssetsIndex].browser_download_url
    if (-not $assetUrl) {
      Write-Error "No download URL found at the specified index."
      return $null
    }
    $assetName = $latestRelease.assets[$AssetsIndex].name
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
