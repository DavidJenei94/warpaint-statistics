param(
    [string]$SdkPath,
    [string]$DeveloperKey
)

$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$projectName = Split-Path -Leaf $projectPath
$connectIqPath = Join-Path $env:APPDATA 'Garmin\ConnectIQ'
if (-not $SdkPath) {
    $localSdk = Join-Path $projectPath 'build\tooling\sdk-9.2.0'
    if (Test-Path -LiteralPath (Join-Path $localSdk 'bin\monkeyc.bat')) {
        $SdkPath = $localSdk
    } else {
        $SdkPath = (Get-Content -LiteralPath (Join-Path $connectIqPath 'current-sdk.cfg') -Raw).Trim()
    }
}
if (-not $DeveloperKey) {
    $DeveloperKey = Join-Path (Split-Path -Parent $projectPath) 'developer_key'
}
$downloadConfig = Join-Path $connectIqPath 'sdkmanager-download-location.cfg'
$downloadPath = $connectIqPath
if (Test-Path -LiteralPath $downloadConfig) {
    $downloadPath = (Get-Content -LiteralPath $downloadConfig -Raw).Trim()
}
$DevicesPath = Join-Path $downloadPath 'Devices'

$compiler = Join-Path $SdkPath 'bin\monkeyc.bat'
foreach ($requiredFile in @($compiler, $DeveloperKey)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file not found: $requiredFile"
    }
}
[xml]$manifest = Get-Content -LiteralPath (Join-Path $projectPath 'manifest.xml') -Raw
$ns = New-Object System.Xml.XmlNamespaceManager($manifest.NameTable)
$ns.AddNamespace('iq', 'http://www.garmin.com/xml/connectiq')
$products = @($manifest.SelectNodes('//iq:product', $ns) | ForEach-Object { $_.id })
$missing = @($products | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $DevicesPath "$_\compiler.json"))
})
if ($missing.Count -gt 0) {
    throw "Install/update these Watches/Wearables profiles in Garmin SDK Manager before exporting: $($missing -join ', ')"
}

[xml]$properties = Get-Content -LiteralPath (Join-Path $projectPath 'resources\settings\properties.xml') -Raw
$version = $properties.properties.property | Where-Object { $_.id -eq 'appVersion' } | Select-Object -ExpandProperty '#text'
$outputDir = Join-Path $projectPath 'dist'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
$output = Join-Path $outputDir "$projectName-$version.iq"
$temporaryOutput = Join-Path $outputDir "$projectName-$version.pending.iq"
$log = Join-Path $outputDir "$projectName-$version-build.log"
$buildPath = Join-Path $projectPath 'build'
New-Item -ItemType Directory -Force -Path $buildPath | Out-Null
$expectedVariantsFile = Join-Path $buildPath 'expected-variants.txt'
$application = $manifest.SelectSingleNode('//iq:application', $ns)
$minimumApi = [version]$application.minApiLevel
$expectedVariants = @($products | ForEach-Object {
    $profile = Get-Content -LiteralPath (Join-Path $DevicesPath "$_\compiler.json") -Raw | ConvertFrom-Json
    $profile.partNumbers | Where-Object { [version]$_.connectIQVersion -ge $minimumApi } | ForEach-Object { $_.number }
} | Sort-Object -Unique)
$expectedVariants | Set-Content -LiteralPath $expectedVariantsFile -Encoding ascii

Push-Location $projectPath
try {
    # Package every product from the manifest with the original developer key.
    # Windows PowerShell can treat native stderr warnings as terminating errors.
    $ErrorActionPreference = 'Continue'
    & $compiler -f monkey.jungle -e -r --no-gen-styles --Eno-invalid-symbol -y $DeveloperKey -o $temporaryOutput 2>&1 | Tee-Object -FilePath $log
    $compilerExitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($compilerExitCode -ne 0) {
        throw "Garmin export failed; see $log"
    }
    # Garmin IQ exports are 7z archives, not ZIP files.
    $packageBytes = [System.IO.File]::ReadAllBytes($temporaryOutput)
    if ($packageBytes.Length -lt 32 -or
        [BitConverter]::ToString($packageBytes, 0, 6) -ne '37-7A-BC-AF-27-1C') {
        throw 'Garmin export did not produce a valid IQ archive header.'
    }
    $ErrorActionPreference = 'Continue'
    & java -cp (Join-Path $SdkPath 'bin\monkeybrains.jar') (Join-Path $PSScriptRoot 'VerifyPackage.java') $temporaryOutput $expectedVariantsFile $application.id $application.type
    $verificationExitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($verificationExitCode -ne 0) {
        throw 'The exported package failed signature or device coverage verification.'
    }
    Move-Item -LiteralPath $temporaryOutput -Destination $output -Force
    $hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $(Split-Path -Leaf $output)" | Set-Content -LiteralPath "$output.sha256" -Encoding ascii
    Write-Host "Upload package: $output"
    Write-Host "Exported manifest products: $($products.Count)"
} finally {
    Pop-Location
}
