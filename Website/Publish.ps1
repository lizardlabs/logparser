param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [ValidateSet('', 'win-x64', 'win-x86', 'linux-x64')]
    [string]$Runtime = '',
    [switch]$SelfContained,
    [switch]$SkipArchive,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = $PSScriptRoot
$project = Join-Path $projectRoot 'Ulp.Docs.Web.csproj'
$artifactsRoot = Join-Path $projectRoot 'artifacts'
$selectedName = if ([string]::IsNullOrWhiteSpace($Runtime)) {
    'framework-dependent'
} elseif ($SelfContained) {
    "$Runtime-self-contained"
} else {
    "$Runtime-framework-dependent"
}
$output = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path $artifactsRoot $selectedName
} else {
    [IO.Path]::GetFullPath($OutputDirectory)
}

if ($SelfContained -and [string]::IsNullOrWhiteSpace($Runtime)) {
    throw '-SelfContained requires -Runtime win-x64, win-x86, or linux-x64.'
}

$artifactsPrefix = [IO.Path]::GetFullPath($artifactsRoot).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$resolvedOutput = [IO.Path]::GetFullPath($output)
if (Test-Path -LiteralPath $resolvedOutput) {
    if (-not $resolvedOutput.StartsWith($artifactsPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to replace an output outside the website artifacts directory: $resolvedOutput"
    }
    Remove-Item -LiteralPath $resolvedOutput -Recurse -Force
}

$arguments = @('publish', $project, '--configuration', $Configuration, '--output', $resolvedOutput)
if (-not [string]::IsNullOrWhiteSpace($Runtime)) {
    $arguments += @('--runtime', $Runtime)
}
$arguments += @('--self-contained', $SelfContained.IsPresent.ToString().ToLowerInvariant())

& dotnet @arguments
if ($LASTEXITCODE -ne 0) {
    throw "Documentation website publish failed with exit code $LASTEXITCODE."
}

# Development symbols are deliberately omitted from the copy-ready package.
Get-ChildItem -LiteralPath $resolvedOutput -Recurse -File |
    Where-Object { $_.Extension -eq '.pdb' -or $_.Name -eq 'Ulp.Docs.Web.xml' } |
    Remove-Item -Force

$requiredFiles = @(
    'Ulp.Docs.Web.dll',
    'appsettings.json',
    'navigation.json',
    'web.config',
    'Content\getting-started.md',
    'Content\reference\generated\cli-reference.md',
    'wwwroot\css\site.css',
    'wwwroot\js\site.js'
)
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedOutput $relativePath) -PathType Leaf)) {
        throw "Published documentation website is missing: $relativePath"
    }
}

if (-not $SkipArchive) {
    $archivePath = Join-Path $artifactsRoot "$selectedName.zip"
    $checksumPath = "$archivePath.sha256"
    Remove-Item -LiteralPath $archivePath, $checksumPath -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path (Join-Path $resolvedOutput '*') -DestinationPath $archivePath -CompressionLevel Optimal
    $hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    Set-Content -LiteralPath $checksumPath -Value "$hash  $([IO.Path]::GetFileName($archivePath))" -Encoding ascii
    Write-Host "Archive: $archivePath" -ForegroundColor Green
    Write-Host "SHA256:  $checksumPath" -ForegroundColor Green
}

Write-Host "Documentation website ready: $resolvedOutput" -ForegroundColor Green
Write-Host 'Upload the complete folder to the shared-hosting application directory.'
