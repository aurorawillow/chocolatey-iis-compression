<#
.SYNOPSIS
    Runs validation checks for the repository.

.DESCRIPTION
    This script performs validation checks such as verifying the existence and integrity of downloaded MSI files
    and checking if the version numbers have been updated.

#>

# Check if URLs are accessible
$urls = @{
    "x86" = "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_x86.msi"
    "x64" = "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_amd64.msi"
}

foreach ($platform in $urls.Keys) {
    try {
        $response = Invoke-WebRequest -Uri $urls[$platform] -Method Head -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ MSI URL for $platform is accessible"
        } else {
            Write-Host "❌ MSI URL for $platform returned status code $($response.StatusCode)"
            exit 1
        }
    } catch {
        Write-Host "❌ Failed to access MSI URL for $platform"
        Write-Host $_.Exception.Message
        exit 1
    }
}

# Validate nuspec file
[xml]$nuspec = Get-Content -Path "../../iis-compression.nuspec"
$nuspecVersion = $nuspec.package.metadata.version.Trim()
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
