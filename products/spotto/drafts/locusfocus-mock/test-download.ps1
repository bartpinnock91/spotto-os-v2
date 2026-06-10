# Test script: verify access to the LocusFocus Azure Blob container via SAS URL.
#
# The provided URL is a *container-level* SAS (sr=c) with read+list permissions (sp=rl).
# You cannot open it in a browser. You must either:
#   1. List the blobs in the container   -> append &restype=container&comp=list
#   2. Download a specific blob           -> put the blob name in the path before the "?"
#
# Usage:
#   .\test-download.ps1                       # lists blobs in the container
#   .\test-download.ps1 -Blob "feed.json"     # downloads that blob to .\downloaded\

param(
    [string]$Blob,
    [string]$OutDir = (Join-Path $PSScriptRoot "downloaded")
)

$ErrorActionPreference = "Stop"

$account   = "https://spottoproduction.blob.core.windows.net"
$container = "locusfocus"
$sas       = "sp=rl&st=2026-05-06T08:12:44Z&se=2026-12-31T17:27:44Z&spr=https&sv=2025-11-05&sr=c&sig=ZkfIFqP6EeHBJjnZ2KJ64Ms89dB6XeXuIOl4QIvISXo%3D"

if (-not $Blob) {
    # --- List mode -------------------------------------------------------
    $listUrl = "$account/$container`?restype=container&comp=list&$sas"
    Write-Host "Listing blobs in container '$container'..." -ForegroundColor Cyan
    Write-Host $listUrl -ForegroundColor DarkGray

    $resp = Invoke-WebRequest -Uri $listUrl -UseBasicParsing
    [xml]$xml = $resp.Content.TrimStart([char]0xFEFF, [char]0xEF, [char]0xBB, [char]0xBF)

    $blobs = $xml.EnumerationResults.Blobs.Blob
    if (-not $blobs) {
        Write-Host "Container is reachable but contains no blobs." -ForegroundColor Yellow
        return
    }

    Write-Host "`nFound $($blobs.Count) blob(s):" -ForegroundColor Green
    $blobs | ForEach-Object {
        $sizeKb = [math]::Round([int64]$_.Properties.'Content-Length' / 1KB, 1)
        "{0,-50} {1,10} KB   {2}" -f $_.Name, $sizeKb, $_.Properties.'Last-Modified'
    }
    Write-Host "`nTo download one:  .\test-download.ps1 -Blob `"<name from above>`"" -ForegroundColor Cyan
}
else {
    # --- Download mode ---------------------------------------------------
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

    $blobUrl = "$account/$container/$Blob`?$sas"
    $dest    = Join-Path $OutDir (Split-Path $Blob -Leaf)

    Write-Host "Downloading '$Blob'..." -ForegroundColor Cyan
    Write-Host $blobUrl -ForegroundColor DarkGray

    Invoke-WebRequest -Uri $blobUrl -OutFile $dest -UseBasicParsing

    $size = (Get-Item $dest).Length
    Write-Host "`nOK - saved to $dest ($size bytes)" -ForegroundColor Green
}
