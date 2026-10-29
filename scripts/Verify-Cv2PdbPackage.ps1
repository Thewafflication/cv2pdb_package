[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $PackagePath
)

$ErrorActionPreference = 'Stop'

# Verify ZIP exists
if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) {
    throw "Package not found: $PackagePath"
}

# Create temp dir
$TempDir = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

try {
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $TempDir -Force

    # Check core files
    $required = @('cv2pdb.exe', 'cv2pdb64.exe', 'LICENSE', 'README.MD', 'VERSION')
    foreach ($f in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $TempDir $f))) {
            throw "Missing required file '$f' in package."
        }
    }
    # Check metadata
    $metaPath = Join-Path $TempDir '.wpm/package.txt'
    if (-not (Test-Path -LiteralPath $metaPath)) { throw "Metadata file '.wpm/package.txt' missing."
    }
    $meta = Get-Content -LiteralPath $metaPath | ConvertFrom-StringData
    if ($meta.name -ne 'cv2pdb') { throw "Metadata name mismatch: expected 'cv2pdb', got '$($meta.name)'."
    }
    if ($meta.arch -ne 'any') { throw "Metadata arch mismatch: expected 'any', got '$($meta.arch)'."
    }
    if (-not $meta.version) { throw "Metadata missing 'version' field."
    }
    if (-not $meta.SourceVersion) { throw "Metadata missing 'source-version' field."
    }
    if (-not $meta.SourceUrl) { throw "Metadata missing 'source-url' field."
    }
    Write-Host "Package verification succeeded. Version: $($meta.version) Source: $($meta.SourceVersion)"
}
finally {
    # Optional clean up
    Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
