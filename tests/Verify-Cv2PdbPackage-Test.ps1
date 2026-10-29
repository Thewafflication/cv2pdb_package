# Test script to verify Verify-Cv2PdbPackage.ps1 works on a valid package

$root = New-Item -ItemType Directory -Force -Path (Join-Path $env:TEMP ([IO.Path]::GetRandomFileName()))
# Necessary core files
@('cv2pdb.exe','cv2pdb64.exe','LICENSE','README.MD','VERSION') | ForEach-Object {
    New-Item -ItemType File -Path (Join-Path $root $_) -Force | Out-Null
}
# Create .wpm/package.txt metadata
$metaDir = Join-Path $root '.wpm'
New-Item -ItemType Directory -Force -Path $metaDir | Out-Null
$metaContent = @(
    'name=cv2pdb',
    'arch=any',
    'debug=false',
    "version=1.0.0",
    "source-version=1.0.0",
    "source-url=http://example.com"
) -join "`n"
Set-Content -Path (Join-Path $metaDir 'package.txt') -Value $metaContent -Encoding utf8
# Zip the directory
$zipPath = Join-Path $env:TEMP ('pkg.zip')
Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory($root,$zipPath)
# Run verification script
Write-Host "Running verification on $zipPath"
$verifyScript = Join-Path $PWD 'scripts/Verify-Cv2PdbPackage.ps1'
try {
    & $verifyScript -PackagePath $zipPath
    Write-Host "Verification succeeded"
}
catch {
    Write-Error "Verification failed: $_"
    exit 1
}
# Cleanup
Remove-Item -LiteralPath $root -Recurse -Force
Remove-Item -LiteralPath $zipPath -Force
