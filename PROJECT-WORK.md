# Project Work Record — cv2pdb WPM Package

**Adoption baseline:** WSP-PROC-0012 (Initialize-ProjectWork) from https://github.com/Thewafflication/wsp commit fa84ddedf37a4262ba0d21ffb95890a2d5a89d5c

**Pinned commit:** 8f741a9a35bf890d5eeabd437fc314f73507c6af (master)

**Status:** Adopted — records populated from actual requirements, code, tests, and handoff notes.

---

## Common Baseline

| Requirement set or practice | Applicability | Project artifact or scope |
| --- | --- | --- |
| Common requirements management | Yes | All controlled project requirements |
| WSP software lifecycle | Yes | Project lifecycle mapped to WSP processes |
| Project process | Yes | Planning through support and improvement |
| Documentation requirements | Yes | Controlled project documentation |
| Documentation style and identifiers | Yes | Project-authored artifacts |
| Testing requirements | Yes | Project verification and evidence |
| Release readiness | Yes | Package build and validation |
| Release approval and baseline | Yes | Published WPM package baseline |
| Support and response | Yes | Supported versions and defect reporting |
| Retrospective and improvement | Yes | Periodic improvement evaluation |

---

## Selected Profiles

| Profile | Selected | Project scope or rationale |
| --- | --- | --- |
| Personal process | Yes | Individual planning and improvement (worker record) |
| Security/DFS | Yes | Windows artifact signing, Defender exclusion awareness |
| C source style | No | No C source files in this packaging repository |
| PowerShell style | Yes | In-scope automation (Build-Cv2PdbPackage.ps1, scripts/) |
| CMake style | No | No CMake files in package root |
| Windows version resources | Yes | cv2pdb.exe / cv2pdb64.exe shipped artifacts |
| Windows code signing and Defender | Yes | WPM package signing and Defender trust requirements |
| Common tools | Yes | Verify-Cv2PdbPackage.ps1, TestBuild.ps1 |

---

## Requirement Dispositions

| WSP requirement | Disposition | Project artifact | Rationale or notes |
| --- | --- | --- | --- |
| `WSP-REQM-0001` | Applicable | Project requirements index | Package metadata and build scripts |
| `WSP-PROC-0001` | Applicable | PROJECT-WORK.md | Documented project process |
| `WSP-PROC-0002` | Applicable | — | No separate roles; single maintainer |
| `WSP-PROC-0003` | Applicable | — | Planning proportional to package scope |
| `WSP-PROC-0004` | Applicable | — | Change impact analyzed per commit |
| `WSP-PROC-0005` | Applicable | — | Review per commit approval |
| `WSP-PROC-0006` | Applicable | — | Issue/defect tracking per handoff |
| `WSP-PROC-0007` | Applicable | — | Release readiness evaluated via TestBuild.ps1 |
| `WSP-PROC-0008` | Applicable | — | Baseline: git commit + package output |
| `WSP-PROC-0009` | Applicable | — | Supported versions tracked upstream |
| `WSP-PROC-0010` | Applicable | — | Retrospective per monitoring audit schedule |

---

## Tailoring Decisions

### WSP-AREA-CV2PDB-0001 — PowerShell build script style

- **Disposition:** Tailored
- **Rationale:** Project uses PowerShell-native build automation; no POSIX shell dependency required.
- **Impact:** None; scripts remain Windows-compatible via PowerShell.
- **Compensating control:** None required.
- **Owner:** Maintainer
- **Completion condition:** N/A
- **Approval:** Initial adoption

### WSP-AREA-CV2PDB-0002 — Upstream version SemVer normalization

- **Disposition:** Applicable
- **Rationale:** Upstream versions with two numeric components normalized by appending `.0` (e.g., `0.54` → `0.54.0`).
- **Impact:** None; documented in README.md and WPM metadata.
- **Compensating control:** None required.
- **Owner:** Maintainer
- **Completion condition:** N/A
- **Approval:** Initial adoption

### WSP-AREA-CV2PDB-0003 — WPM release key trust

- **Disposition:** Applicable
- **Rationale:** First-time installation requires `wpm trust add` per README instructions.
- **Impact:** None; one-time operator action.
- **Compensating control:** None required.
- **Owner:** Maintainer
- **Completion condition:** N/A
- **Approval:** Initial adoption

---

## Baseline History

| Date | WSP baseline | Project change | Summary |
| --- | --- | --- | --- |
| 2026-11-07 | WSP-PROC-0012 (fa84dded) | Initial adoption | PROJECT-WORK.md and AGENT-TASKS.md created at package root |

---

## Notes

- This record is maintained under the `wsp/` submodule process. Changes require review per `WSP-PROC-0005`.
- `TestBuild.ps1` validates package structure (prints `ok`); does not compile cv2pdb.
- `Verify-Cv2PdbPackage.ps1` validates package metadata.
- Upstream cv2pdb is redistributed under the Artistic License 2.0.
- This packaging repository is not affiliated with the cv2pdb project.