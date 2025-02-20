# Read the current version from nuspec file
[xml]$nuspec = Get-Content -Path "../../iis-compression.nuspec"
$version = $nuspec.package.metadata.version.Trim()

if (-not $version) {
    Write-Host "❌ Failed to read version from nuspec file"
    exit 1
}

# Set the version as an output for GitHub Actions
"version=$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Append

# Set it as an environment variable for other steps to use
$env:nuspec_version = $version

Write-Host "✓ Package version: $version"
return $true