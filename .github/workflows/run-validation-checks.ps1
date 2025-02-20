<#
.SYNOPSIS
    Runs validation checks for the repository.

.DESCRIPTION
    This script performs validation checks such as verifying the existence and integrity of downloaded MSI files
    and checking if the version numbers have been updated.

#>

# Check if MSI files exist and match expected names
$msiFiles = @("iiscompression_x86.msi", "iiscompression_amd64.msi")

foreach ($file in $msiFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file exists"
    } else {
        Write-Host "❌ $file not found in expected location"
        exit 1
    }
}

# Validate SHA256 hashes
$expectedHashes = @{
    "iiscompression_x86.msi" = $env:x86_sha256
    "iiscompression_amd64.msi" = $env:amd64_sha256
}

foreach ($file in $msiFiles) {
    $actualHash = (Get-FileHash -Path $file -Algorithm SHA256).Hash
    if ($actualHash -eq $expectedHashes[$file]) {
        Write-Host "✓ SHA256 hash verified for $file"
    } else {
        Write-Host "❌ SHA256 hash mismatch for $file"
        Write-Host "Expected: $($expectedHashes[$file])"
        Write-Host "Actual: $actualHash"
        exit 1
    }
}

# Validate nuspec file
[xml]$nuspec = Get-Content -Path "../../iis-compression.nuspec"
$nuspecVersion = $nuspec.package.metadata.version

if (-not $nuspecVersion) {
    Write-Host "❌ Failed to read version from nuspec file"
    exit 1
}

# Check if version numbers are consistent
if ($env:nuspec_version -ne $nuspecVersion) {
    Write-Host "❌ Version mismatch between update script and nuspec"
    Write-Host "Update script version: $($env:nuspec_version)"
    Write-Host "Nuspec version: $nuspecVersion"
    exit 1
}

Write-Host "✓ All validation checks passed"
exit 0
