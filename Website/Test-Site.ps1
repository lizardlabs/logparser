param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [switch]$SkipBuild,
    [string]$PublishedDirectory
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Net.Http

function Get-HttpErrorStatusCode {
    param([Exception]$Exception)
    if ($null -eq $Exception -or $null -eq $Exception.Response) { return $null }
    return [int]$Exception.Response.StatusCode
}

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
        $navigation = Get-Content -LiteralPath (Join-Path $siteRoot 'navigation.json') -Raw | ConvertFrom-Json
        $navigationSlugs = @($navigation.groups | ForEach-Object { $_.items } | ForEach-Object { $_.slug } | Sort-Object -Unique)
        foreach ($slug in $navigationSlugs) {
            $page = Invoke-WebRequest -Uri ($baseUrl + '/docs/' + $slug) -UseBasicParsing
            if ($page.StatusCode -ne 200 -or $page.Content -notmatch '<h1') { throw "Navigation target did not render: $slug" }
        }
        Write-Host "PASS  $($navigationSlugs.Count) sidebar documentation destinations render successfully."
        $functionJson = Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/reference/generated/sqlite-functions.json') -UseBasicParsing
        $functionCatalog = $functionJson.Content | ConvertFrom-Json
        if (@($functionCatalog.Table0.Data).Count -lt 100) { throw 'Published runtime function inventory is missing or incomplete.' }
        $search = Invoke-WebRequest -Uri ($baseUrl + '/search?q=SQLite') -UseBasicParsing
        if ($search.Content -notmatch 'result') { throw 'Search results were not rendered.' }
        $sitemap = Invoke-WebRequest -Uri ($baseUrl + '/sitemap.xml') -UseBasicParsing
        if ($sitemap.Content -notmatch '/docs/getting-started') { throw 'Sitemap is missing documentation pages.' }
        if ($sitemap.Content -match '/docs/developer/|COMPLIANCE-REVIEW|PRODUCT-LEGAL|EULA-TEMPLATE') { throw 'Private documentation leaked into sitemap.' }
        foreach ($privateSlug in @('developer/ARCHITECTURE', 'legal/COMPLIANCE-REVIEW', 'legal/PRODUCT-LEGAL', 'legal/EULA-TEMPLATE')) {
            try {
                Invoke-WebRequest -Uri ($baseUrl + '/docs/' + $privateSlug) -UseBasicParsing -ErrorAction Stop | Out-Null
                throw "Private documentation was served: $privateSlug"
            } catch {
                if ((Get-HttpErrorStatusCode $_.Exception) -ne 404) { throw }
            }
        }
        $showcaseCsv = Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/assets/outputs/employees.csv') -UseBasicParsing
        if ($showcaseCsv.StatusCode -ne 200 -or $showcaseCsv.Content -notmatch 'Ada') { throw 'Generated CSV showcase did not render.' }
        $showcaseZip = Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/assets/outputs/ulp-output-showcase.zip') -UseBasicParsing
        if ($showcaseZip.StatusCode -ne 200 -or $showcaseZip.RawContentLength -lt 1000) { throw 'Generated output showcase download is missing.' }
        $workflowZip = Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/assets/outputs/workflow-tutorials.zip') -UseBasicParsing
        if ($workflowZip.StatusCode -ne 200 -or $workflowZip.RawContentLength -lt 1000) { throw 'Workflow tutorial download is missing.' }
        $robots = Invoke-WebRequest -Uri ($baseUrl + '/robots.txt') -UseBasicParsing
        if ($robots.Content -notmatch 'Sitemap:') { throw 'robots.txt is missing its sitemap.' }
        $httpClient = [Net.Http.HttpClient]::new()
        $notFoundResponse = $null
        try {
            $notFoundResponse = $httpClient.GetAsync($baseUrl + '/docs/does-not-exist').GetAwaiter().GetResult()
            $notFoundBody = $notFoundResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            if ([int]$notFoundResponse.StatusCode -ne 404) { throw 'Missing documentation page unexpectedly succeeded.' }
            if ($notFoundBody -notmatch 'That documentation page is not here') { throw 'Friendly not-found page was not rendered.' }
        }
        finally {
            if ($null -ne $notFoundResponse) { $notFoundResponse.Dispose() }
            $httpClient.Dispose()
        }

        try {
            Invoke-WebRequest -Uri ($baseUrl + '/docs-assets/%2e%2e/navigation.json') -UseBasicParsing -ErrorAction Stop | Out-Null
            throw 'Traversal request unexpectedly succeeded.'
        } catch {
            if ((Get-HttpErrorStatusCode $_.Exception) -notin @(400, 404)) { throw }
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
