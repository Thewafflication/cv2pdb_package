[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Package,

    [string] $Repository = 'Thewafflication/cv2pdb_package',
    [string] $OutputPath = (Join-Path $PSScriptRoot '..\out\release-assets\index.json')
)

$ErrorActionPreference = 'Stop'
$file = Get-Item -LiteralPath $Package
if ($file.Name -notmatch '^cv2pdb-any-(?<version>.+)\.zip$') {
    throw "Unexpected package filename: $($file.Name)"
}
$version = $Matches.version
$tag = "cv2pdb-$version"
$index = [ordered]@{
    version = 1
    packages = @(
        [ordered]@{
            name = 'cv2pdb'
            version = $version
            arch = 'any'
            url = "https://github.com/$Repository/releases/download/$tag/$($file.Name)"
        }
    )
}
$resolvedOutput = [IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedOutput) | Out-Null
[IO.File]::WriteAllText($resolvedOutput, ($index | ConvertTo-Json -Depth 4) + "`n", [Text.UTF8Encoding]::new($false))
Get-Item -LiteralPath $resolvedOutput
