param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [switch]$SkipBuild,
    [string]$PublishedDirectory
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = $PSScriptRoot
$project = Join-Path $projectRoot 'Ulp.Docs.Web.csproj'
$testingPublishedOutput = -not [string]::IsNullOrWhiteSpace($PublishedDirectory)
if (-not $SkipBuild -and -not $testingPublishedOutput) {
    & dotnet build $project --configuration $Configuration --verbosity minimal
    if ($LASTEXITCODE -ne 0) { throw "Website build failed with exit code $LASTEXITCODE." }
}

$siteRoot = if ($testingPublishedOutput) {
    [IO.Path]::GetFullPath($PublishedDirectory)
} else {
    $projectRoot
}
$assembly = if ($testingPublishedOutput) {
    Join-Path $siteRoot 'Ulp.Docs.Web.dll'
} else {
    Join-Path $projectRoot "bin\$Configuration\net10.0\Ulp.Docs.Web.dll"
}
if (-not (Test-Path -LiteralPath $assembly -PathType Leaf)) { throw "Website assembly not found: $assembly" }
if ($testingPublishedOutput) {
    foreach ($forbiddenDirectory in @('artifacts', 'bin', 'obj')) {
        if (Test-Path -LiteralPath (Join-Path $siteRoot $forbiddenDirectory)) {
            throw "Published website contains recursive build output: $forbiddenDirectory"
        }
    }
}

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port
$listener.Stop()
$baseUrl = "http://127.0.0.1:$port"
$stdout = Join-Path ([IO.Path]::GetTempPath()) ("ulp-docs-site-" + [Guid]::NewGuid().ToString('N') + '.out.log')
$stderr = Join-Path ([IO.Path]::GetTempPath()) ("ulp-docs-site-" + [Guid]::NewGuid().ToString('N') + '.err.log')

$previousEnvironment = $env:ASPNETCORE_ENVIRONMENT
$previousDotNetEnvironment = $env:DOTNET_ENVIRONMENT
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:DOTNET_ENVIRONMENT = 'Development'
try {
    $processArguments = ('"{0}" --urls "{1}"' -f $assembly, $baseUrl)
    $process = Start-Process -FilePath 'dotnet' -ArgumentList $processArguments -WorkingDirectory $siteRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    try {
        $ready = $false
        $lastProbeError = $null
        for ($attempt = 0; $attempt -lt 100; $attempt++) {
            if ($process.HasExited) {
                $errorText = Get-Content -LiteralPath $stderr -Raw -ErrorAction SilentlyContinue
                throw "Documentation website exited before startup. $errorText"
            }
            try {
                $homeResponse = Invoke-WebRequest -Uri ($baseUrl + '/') -UseBasicParsing -TimeoutSec 2
                if ($homeResponse.StatusCode -eq 200) { $ready = $true; break }
            } catch {
                $lastProbeError = $_.Exception.Message
                Start-Sleep -Milliseconds 200
            }
        }
        if (-not $ready) {
            $outputText = Get-Content -LiteralPath $stdout -Raw -ErrorAction SilentlyContinue
            $errorText = Get-Content -LiteralPath $stderr -Raw -ErrorAction SilentlyContinue
            throw "Documentation website did not become ready. Last probe: $lastProbeError Output: $outputText $errorText"
        }

        if ($homeResponse.Content -notmatch 'Turn files and system data into answers') { throw 'Home-page content was not rendered.' }
        $document = Invoke-WebRequest -Uri ($baseUrl + '/docs/getting-started') -UseBasicParsing
        if ($document.Content -notmatch '<h1[^>]*>Getting Started</h1>') { throw 'Markdown document was not rendered.' }
        if ($document.Headers['Content-Security-Policy'] -notmatch "default-src 'self'") { throw 'CSP header is missing.' }
        $search = Invoke-WebRequest -Uri ($baseUrl + '/search?q=SQLite') -UseBasicParsing
        if ($search.Content -notmatch 'result') { throw 'Search results were not rendered.' }
        $sitemap = Invoke-WebRequest -Uri ($baseUrl + '/sitemap.xml') -UseBasicParsing
        if ($sitemap.Content -notmatch '/docs/getting-started') { throw 'Sitemap is missing documentation pages.' }
        $robots = Invoke-WebRequest -Uri ($baseUrl + '/robots.txt') -UseBasicParsing
        if ($robots.Content -notmatch 'Sitemap:') { throw 'robots.txt is missing its sitemap.' }
        try {
            Invoke-WebRequest -Uri ($baseUrl + '/docs/does-not-exist') -UseBasicParsing -ErrorAction Stop | Out-Null
            throw 'Missing documentation page unexpectedly succeeded.'
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
            $notFoundBody = [IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
            if ($notFoundBody -notmatch 'That documentation page is not here') { throw 'Friendly not-found page was not rendered.' }
        }

        try {
            Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/%2e%2e/navigation.json') -UseBasicParsing -ErrorAction Stop | Out-Null
            throw 'Traversal request unexpectedly succeeded.'
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -notin @(400, 404)) { throw }
        }
        Write-Host 'Documentation website smoke tests passed.' -ForegroundColor Green
    }
    finally {
        if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force }
        $process.WaitForExit()
    }
}
finally {
    $env:ASPNETCORE_ENVIRONMENT = $previousEnvironment
    $env:DOTNET_ENVIRONMENT = $previousDotNetEnvironment
    Remove-Item -LiteralPath $stdout, $stderr -Force -ErrorAction SilentlyContinue
}
