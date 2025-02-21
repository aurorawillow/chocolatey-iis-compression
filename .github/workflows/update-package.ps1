# Read the current version from nuspec file
[xml]$nuspec = Get-Content -Path "../../iis-compression.nuspec"
$version = $nuspec.package.metadata.version.Trim()
if (-not $version) {
    Write-Output "❌ Failed to read version from nuspec file"
    exit 1
}
# Set the version as an output for GitHub Actions
"version=$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
# Set it as an environment variable for other steps to use
$env:nuspec_version = $version
Write-Output "✓ Package version: $version"
return $true

function Get-FileWithRetry {
    param (
        [string]$Uri,
        [string]$OutFile,
        [int]$MaxRetries = 3,
        [int]$RetryDelaySeconds = 10
    )

    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Output "Attempt $i of $MaxRetries to download $Uri"
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
            return $true
        }
        catch {
            Write-Output "Download attempt $i failed: $_"
            if ($i -lt $MaxRetries) {
                Write-Output "Waiting $RetryDelaySeconds seconds before retry..."
                Start-Sleep -Seconds $RetryDelaySeconds
            }
            else {
                throw "Failed to download after $MaxRetries attempts: $_"
            }
        }
    }
}

Write-Output "Downloading x86 MSI..."
Get-FileWithRetry -Uri $x86_url -OutFile $x86_msi_path
Write-Output "Downloading x64 MSI..."
Get-FileWithRetry -Uri $amd64_url -OutFile $amd64_msi_path
