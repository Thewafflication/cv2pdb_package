# Agent Tasks Record — cv2pdb WPM Package

**Owner:** Maintainer (jmwau)
**Branch/worktree:** master, head 8f741a9a35bf890d5eeabd437fc314f73507c6af
**Upstream:** origin/master same commit (8f741a9)

---

## Bounded Outcomes (what "done" means for this session)

- [x] PROJECT-WORK.md created at package root with adoption records from WSP-PROC-0012
- [x] AGENT-TASKS.md created at package root with bounded outcomes, prerequisites, and acceptance gates
- [x] TestBuild.ps1 validates package structure after work-record creation
- [x] Changes staged, committed locally, and pushed to upstream with remote branch SHA verification

---

## Prerequisites (must hold before each deliverable)

- Git worktree must be clean and on master branch at head 8f741a9
- PROJECT-WORK.md must exist and be populated before AGENT-TASKS.md commit
- TestBuild.ps1 must run without errors to confirm package-structure integrity
- WPM release key must be trusted for signed builds (separate from this task)

---

## Branch/Worktree Status

- **Current branch:** master
- **Current head:** 8f741a9a35bf890d5eeabd437fc314f73507c6af
- **Upstream head:** 8f741a9 (origin/master)
- **Detached:** No
- **Local commits:** None (clean working tree)
- **Unpushed commits:** None

---

## Retained Checks (validation commands kept across sessions)

| Check | Command | Purpose |
| --- | --- | --- |
| Package structure | `.\scripts\TestBuild.ps1` | Prints `ok` if package layout intact |
| Package metadata verification | `.\scripts\Verify-Cv2PdbPackage.ps1` | Validates WPM package metadata |
| Git status | `git status` | Confirms clean working tree / branch |
| Remote SHA | `git rev-parse origin/master` | Verifies upstream state |

---

## Acceptance Commands (run to confirm completion)

```powershell
# 1. Verify both work records exist and have content
Test-Path .\PROJECT-WORK.md && Test-Path .\AGENT-TASKS.md

# 2. Run package-structure validation
& .\scripts\TestBuild.ps1

# 3. Run metadata verification
& .\scripts\Verify-Cv2PdbPackage.ps1

# 4. Confirm git status and upstream SHA
git status
git rev-parse origin/master
```

---

## Publication Target

- **WPM release repository:** `https://github.com/Thewafflication/cv2pdb_package/releases/latest/download`
- **Package output directory:** `out/packages`
- **Signed build trigger:** `.\scripts\Build-Cv2PdbPackage.ps1 -SigningKey <path-to-wpm-private-key>`
- **Debug build trigger:** `.\scripts\Build-Cv2PdbPackage.ps1 -DebugPackage`
- **Release key:** `wpm-release.public` (located at release download URL)
- **Package identity:** `any` architecture; installs beneath `%ProgramFiles%\cv2pdb\<version>`

---

## Exact Last Failure / Next Experiment

- **Last monitoring audit (2026-11-04):** Root PROJECT-WORK.md absent; adoption not complete.
- **Last verification (2026-11-01):** report231402ac9210455e9e9001fa130da4cc reran Verify-Cv2PdbPackage.Test.ps1; no new commit; HEAD/live/origin/master still 4b0eae1 (prior parser repair) — but actual HEAD and live origin/master are 8f741a9 (per 2026-11-06 audit).
- **Current next experiment:** Create PROJECT-WORK.md and AGENT-TASKS.md at package root, validate with TestBuild.ps1, commit and push to upstream, verify remote branch SHA.

---

## Notes

- No Python tests or tools/check.py are required; this is a PowerShell/WPM package project.
- TestBuild.ps1 only prints `ok` and does not build or test executable behavior; it validates package structure only.
- Verify-Cv2PdbPackage.ps1 validates package metadata.
- Prior parser repair 4b0eae1 is independently verified already; do not repeat.
- Untracked file `scripts/TestBuild.ps1` and owner work are preserved.
- This record is maintained under the `wsp/` submodule process. Changes require review per WSP-PROC-0005.
- Upstream cv2pdb is redistributed under the Artistic License 2.0.
- This packaging repository is not affiliated with the cv2pdb project.