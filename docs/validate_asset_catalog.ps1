param(
    [string]$AssetRoot = "Meowtropolis/Assets.xcassets"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $AssetRoot)) {
    Write-Error "Asset root not found: $AssetRoot"
    exit 2
}

$contentsFiles = Get-ChildItem -Path $AssetRoot -Recurse -Filter "Contents.json" -File
$invalidRefs = @()
$missingFiles = @()
$invalidExt = @()
$orphanWebp = Get-ChildItem -Path $AssetRoot -Recurse -File -Filter "*.webp" |
    Where-Object { $_.DirectoryName -notlike "*.imageset" }

foreach ($file in $contentsFiles) {
    $json = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
    if (-not $json.images) { continue }

    foreach ($img in $json.images) {
        if (-not $img.filename -or $img.filename.Trim().Length -eq 0) { continue }

        $filename = $img.filename
        $lower = $filename.ToLowerInvariant()

        if ($lower.EndsWith(".webp") -or $lower.Contains(".jpg.webp") -or $lower.Contains(".png.webp")) {
            $invalidRefs += "$($file.FullName)|$filename"
        }

        $fullPath = Join-Path $file.DirectoryName $filename
        if (-not (Test-Path $fullPath)) {
            $missingFiles += "$($file.FullName)|$filename"
        }

        $ext = [System.IO.Path]::GetExtension($filename).ToLowerInvariant()
        if ($ext -notin @(".png", ".jpg", ".jpeg", ".heic", ".pdf")) {
            $invalidExt += "$($file.FullName)|$filename"
        }
    }
}

Write-Output "CONTENTS_JSON_COUNT=$($contentsFiles.Count)"
Write-Output "INVALID_WEBP_REFS=$($invalidRefs.Count)"
Write-Output "MISSING_IMAGE_FILES=$($missingFiles.Count)"
Write-Output "INVALID_EXTENSIONS=$($invalidExt.Count)"
Write-Output "ORPHAN_WEBP_FILES=$($orphanWebp.Count)"

if ($invalidRefs.Count -gt 0) {
    Write-Output "--- INVALID WEBP REFERENCES ---"
    $invalidRefs | ForEach-Object { Write-Output $_ }
}

if ($missingFiles.Count -gt 0) {
    Write-Output "--- MISSING FILE REFERENCES ---"
    $missingFiles | ForEach-Object { Write-Output $_ }
}

if ($invalidExt.Count -gt 0) {
    Write-Output "--- INVALID FILE EXTENSIONS ---"
    $invalidExt | ForEach-Object { Write-Output $_ }
}

if ($orphanWebp.Count -gt 0) {
    Write-Output "--- ORPHAN WEBP FILES ---"
    $orphanWebp | ForEach-Object { Write-Output $_.FullName }
}

if ($invalidRefs.Count -gt 0 -or $missingFiles.Count -gt 0 -or $invalidExt.Count -gt 0 -or $orphanWebp.Count -gt 0) {
    exit 1
}

Write-Output "Asset catalog validation passed."
exit 0
