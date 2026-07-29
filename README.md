# cv2pdb WPM package

This repository builds a signed [WPM](https://github.com/Thewafflication/wpm)
package from the latest binary release of
[cv2pdb](https://github.com/rainers/cv2pdb). It does not compile cv2pdb.

The upstream archive contains both `cv2pdb.exe` (x86) and `cv2pdb64.exe`
(x64), so the WPM package uses the `any` architecture and installs the
unmodified release beneath `%ProgramFiles%\cv2pdb\<version>`. The installer
adds that directory to the system `PATH` and sets `CV2PDB_HOME`.

Upstream versions with only two numeric components are normalized to SemVer by
appending `.0`; for example, upstream `0.54` is packaged as `0.54.0` while the
original value remains recorded as `source-version` metadata.

## Install with WPM

From an elevated PowerShell session:

```powershell
wpm repo add https://github.com/Thewafflication/cv2pdb_package/releases/latest/download
wpm update
wpm install cv2pdb
```

Before the first installation, trust the release key:

```powershell
Invoke-WebRequest https://github.com/Thewafflication/cv2pdb_package/releases/latest/download/wpm-release.public -OutFile wpm-release.public
wpm trust add wpm-release.public
```

## Build locally

Install WPM, then run:

```powershell
.\scripts\Build-Cv2PdbPackage.ps1 -DebugPackage
```

For a signed build, pass `-SigningKey <path-to-wpm-private-key>`. Packages are
written to `out\packages`.

## GitHub release setup

Add the `WPM_RELEASE_PRIVATE_KEY` repository secret containing the private key
corresponding to `release_keys/wpm-release.public`. Pushes and pull requests
build unsigned debug packages. A scheduled run checks upstream daily and
publishes a signed package; manually running the workflow with `publish=true`
does the same immediately. Publishing is idempotent for an upstream version.

cv2pdb is redistributed under the Artistic License 2.0. This packaging
repository is not affiliated with the cv2pdb project.
