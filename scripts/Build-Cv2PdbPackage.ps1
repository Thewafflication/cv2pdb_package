[CmdletBinding()]

if ($null -eq $PSScriptRoot) { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }
param(
    [string] $OutputDirectory = (Join-Path $PSScriptRoot ..\out\packages),
    [string] $WorkDirectory = (Join-Path $PSScriptRoot ..\out\work),
    [string] $SigningKey,
    [string] $WpmExecutable = 'wpm.exe',
    [switch] $DebugPackage,
    [string] $ReleaseRepository = 'rainers/cv2pdb'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

function Invoke-Checked {
    param([Parameter(Mandatory)][scriptblock] $Command, [Parameter(Mandatory)][string] $Description)
    & $Command
    if ($LASTEXITCODE -ne 0) { throw "$Description failed with exit code $LASTEXITCODE." }
}

$headers = @{ Accept = 'application/vnd.github+json'; 'User-Agent' = 'cv2pdb-wpm-builder' }
if ($env:GITHUB_TOKEN) { $headers.Authorization = "Bearer $env:GITHUB_TOKEN" }
$release = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$ReleaseRepository/releases/latest"
$sourceVersion = ([string]$release.tag_name).TrimStart('v')
if ($sourceVersion -notmatch '^[0-9]+\.[0-9]+(?:\.[0-9]+)?(?:[-+][0-9A-Za-z.-]+)?$') {
    throw "The upstream tag '$($release.tag_name)' is not a supported package version."
}
$version = if ($sourceVersion -match '^[0-9]+\.[0-9]+$') { "$sourceVersion.0" } else { $sourceVersion }

$expectedName = "cv2pdb-$sourceVersion.zip"
$assets = @($release.assets | Where-Object { $_.name -eq $expectedName })
if ($assets.Count -ne 1) { throw "Expected one upstream asset named '$expectedName'; found $($assets.Count)." }
$asset = $assets[0]

$resolvedWork = [IO.Path]::GetFullPath($WorkDirectory)
$resolvedOutput = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $resolvedWork) { Remove-Item -LiteralPath $resolvedWork -Recurse -Force }
$downloadDirectory = Join-Path $resolvedWork 'download'
$extractDirectory = Join-Path $resolvedWork 'extract'
$stagingDirectory = Join-Path $resolvedWork 'staging'
$metadataDirectory = Join-Path $stagingDirectory '.wpm'
New-Item -ItemType Directory -Force -Path $downloadDirectory, $extractDirectory, $metadataDirectory, $resolvedOutput | Out-Null

$archive = Join-Path $downloadDirectory $asset.name
Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $asset.browser_download_url -OutFile $archive
if ($asset.digest -and $asset.digest -match '^sha256:(?<hash>[0-9a-fA-F]{64})$') {
    $hashAlg = [System.Security.Cryptography.SHA256]::Create();
$hashBytes = $hashAlg.ComputeHash([IO.File]::OpenRead($archive));
$actualHash = [BitConverter]::ToString($hashBytes).Replace('-','').ToLowerInvariant();
    if ($actualHash -ne $Matches.hash) { throw "SHA-256 mismatch for $($asset.name)." }
}
Expand-Archive -LiteralPath $archive -DestinationPath $extractDirectory

foreach ($required in 'cv2pdb.exe', 'cv2pdb64.exe', 'LICENSE', 'README.MD', 'VERSION') {
    if (-not (Test-Path -LiteralPath (Join-Path $extractDirectory $required) -PathType Leaf)) {
        throw "The upstream archive is missing $required."
    }
}
Copy-Item -Path (Join-Path $extractDirectory '*') -Destination $stagingDirectory -Recurse -Force

$debugValue = if ($DebugPackage) { 'true' } else { 'false' }
$metadata = @(
    'name=cv2pdb'
    "version=$version"
    'arch=any'
    "debug=$debugValue"
    'description=Converter of CodeView and DWARF debug information to PDB files'
    'maintainer=Jordan Waughtal'
    'homepage=https://github.com/rainers/cv2pdb'
    "repository=https://github.com/$ReleaseRepository"
    'license=Artistic-2.0'
    "source-version=$sourceVersion"
    "source-url=$($asset.browser_download_url)"
) -join "`n"
[IO.File]::WriteAllText((Join-Path $metadataDirectory 'package.txt'), $metadata + "`n", [Text.UTF8Encoding]::new($false))

$installDirectory = "%ProgramFiles%\cv2pdb\$version"
$installScript = @"
@echo off
setlocal
set "CV2PDB_DEST=$installDirectory"
if not exist "%CV2PDB_DEST%" mkdir "%CV2PDB_DEST%" || exit /b 1
xcopy "%~dp0..\*" "%CV2PDB_DEST%\" /E /I /Q /Y >nul || exit /b 1
if exist "%CV2PDB_DEST%\.wpm" rmdir /S /Q "%CV2PDB_DEST%\.wpm"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v CV2PDB_HOME /t REG_EXPAND_SZ /d "%CV2PDB_DEST%" /f >nul || exit /b 1
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSTEM_PATH=%%B"
echo ;%SYSTEM_PATH%; | find /I ";%CV2PDB_DEST%;" >nul || reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%SYSTEM_PATH%;%CV2PDB_DEST%" /f >nul || exit /b 1
exit /b 0
"@ -replace "`n", "`r`n"
[IO.File]::WriteAllText((Join-Path $metadataDirectory 'install.cmd'), $installScript, [Text.ASCIIEncoding]::new())

$removeScript = @"
@echo off
setlocal EnableDelayedExpansion
set "CV2PDB_DEST=$installDirectory"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v CV2PDB_HOME 2^>nul') do set "CV2PDB_CURRENT=%%B"
if /I "%CV2PDB_CURRENT%"=="%CV2PDB_DEST%" reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v CV2PDB_HOME /f >nul 2>&1
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSTEM_PATH=%%B"
set "SYSTEM_PATH=!SYSTEM_PATH:;%CV2PDB_DEST%=!"
set "SYSTEM_PATH=!SYSTEM_PATH:%CV2PDB_DEST%;=!"
if /I "!SYSTEM_PATH!"=="%CV2PDB_DEST%" set "SYSTEM_PATH="
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "!SYSTEM_PATH!" /f >nul || exit /b 1
if exist "%CV2PDB_DEST%" rmdir /S /Q "%CV2PDB_DEST%" || exit /b 1
exit /b 0
"@ -replace "`n", "`r`n"
[IO.File]::WriteAllText((Join-Path $metadataDirectory 'remove.cmd'), $removeScript, [Text.ASCIIEncoding]::new())
[IO.File]::WriteAllText((Join-Path $metadataDirectory 'wpmignore.txt'), ".wpm/`n*.log`nout/`n", [Text.ASCIIEncoding]::new())

$arguments = @('build', $stagingDirectory, $resolvedOutput)
if ($SigningKey) {
    $resolvedKey = [IO.Path]::GetFullPath($SigningKey)
    if (-not (Test-Path -LiteralPath $resolvedKey -PathType Leaf)) { throw "Signing key not found: $resolvedKey" }
    $arguments += @('--sign', $resolvedKey)
}
Invoke-Checked -Description 'WPM package build' -Command { & $WpmExecutable @arguments }

$debugPart = if ($DebugPackage) { '-debug' } else { '' }
$packagePath = Join-Path $resolvedOutput "cv2pdb-any$debugPart-$version.zip"
if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) { throw "WPM did not produce $packagePath." }
[pscustomobject]@{ Version = $version; SourceVersion = $sourceVersion; Architecture = 'any'; Package = $packagePath; Source = $asset.browser_download_url }
