[CmdletBinding()]
Param(
    [string]$DebugOutput = $null
)

$ErrorActionPreference = 'Stop'

# Load compression assembly
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

# Create temporary directory
$TempDir = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# Prepare file contents
$files = @(
    'cv2pdb.exe',
    'cv2pdb64.exe',
    'LICENSE',
    'README.MD',
    'VERSION'
)
foreach ($f in $files) {
    New-Item -ItemType File -Path (Join-Path $TempDir $f) -Force | Out-Null
    Set-Content -Path (Join-Path $TempDir $f) -Value "Hello $f" -Encoding UTF8
}
# Create .wpm folder and package.txt
$WpmDir = Join-Path $TempDir '.wpm'
New-Item -ItemType Directory -Force -Path $WpmDir | Out-Null
$MetaContent = @(
    'name=cv2pdb',
    'version=0.54.0',
    'arch=any',
    'debug=false',
    'description=Test package',
    'maintainer=Tester',
    'homepage=https://example.com',
    'repository=https://github.com/example',
    'license=Artistic-2.0',
    'SourceVersion=0.54',
    'SourceUrl=https://example.com/download'
) -join "`n"
$MetaPath = Join-Path $WpmDir 'package.txt'
Set-Content -Path $MetaPath -Value $MetaContent -Encoding UTF8

# Create ZIP using .NET
$ZipPath = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + '.zip')
[System.IO.Compression.ZipFile]::CreateFromDirectory($TempDir, $ZipPath) | Out-Null

# Run verification script
try {
    & "scripts\Verify-Cv2PdbPackage.ps1" -PackagePath $ZipPath
    Write-Output "Test harness succeeded."
    Exit 0
} catch {
    Write-Error $_.Exception.Message -ErrorAction Stop
    Exit 1
}