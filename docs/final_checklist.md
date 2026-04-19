# Final MVP Checklist

## Release Readiness

- [ ] All MVP features implemented
- [ ] End-to-end auth to map flow validated
- [ ] No major crashes in core flow
- [ ] No broken navigation routes
- [ ] Data load paths verified

## Testing

- [ ] Unit tests pass in Xcode
- [ ] UI tests pass in Xcode
- [ ] Manual smoke flow passes
- [ ] Asset catalog validation script passes (`pwsh ./docs/validate_asset_catalog.ps1`)

## Asset Import Guardrail

- Run `pwsh ./docs/validate_asset_catalog.ps1` after any new image import.
- Script fails when:
	- `Contents.json` references `.webp` filenames
	- referenced image files are missing
	- unsupported file extensions are used
	- orphan `.webp` files exist under `Assets.xcassets`

## Demo Readiness

- [ ] Demo script finalized
- [ ] Presenter backup steps prepared
- [ ] Map loading/empty/error/retry states rehearsed

## Fresh Install Rehearsal

- [ ] Simulator app deleted before run
- [ ] Clean build performed
- [ ] Fresh install launch successful
- [ ] Auth works from scratch
- [ ] Permissions behave correctly

## Freeze Control

- [ ] Freeze policy documented
- [ ] Team informed: critical fixes only
- [ ] No new feature PRs accepted

## Freeze Policy Statement

Project is now in freeze state. Only critical issues affecting demo or core functionality will be addressed.

## Freeze Gate Declaration (Mandatory)

FREEZE POLICY ACTIVE

- No new features allowed
- No refactoring allowed
- No UI redesign allowed
- Only critical bug fixes are permitted

Reason:
To ensure demo stability and prevent regressions.

## Validation Environment Note

- This repository was validated from a Windows workspace.
- Xcode runtime actions (simulator install/reinstall, xcodebuild test) must be executed on macOS.
- Architecture checks, diagnostics, logging verification, and freeze-gate documentation were completed here.
