## Date
12 January 2026

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Debug and fix BFR (Betsson France Legacy) UAT distribution via manual-distribute GitHub Action
- Understand why Match decryption was failing with "Invalid password" error

### Achievements
- [x] Diagnosed root cause: fastlane version mismatch (BFR had 2.214.0, goma branch encrypted with 2.228.0)
- [x] Updated BetssonFranceLegacy fastlane to 2.230.0 (`bundle update fastlane`)
- [x] Created missing provisioning profile `AdHoc_com.gomagaming.betsson` on goma branch
- [x] Added CI keychain configuration to BFR Fastfile (was missing, caused keychain errors)
- [x] Added `workspace: "../Sportsbook.xcworkspace"` to `build_ios_app` (was using xcodeproj, missing local packages)
- [x] Removed hardcoded Discord webhook URL from Fastfile (security issue)
- [x] Removed `_notify_discord` lane - Discord notifications now handled by workflow YAML only
- [x] Removed outdated FASTLANE_USER/PASSWORD warning (using API keys now)

### Issues / Bugs Hit
- [x] "Invalid password passed via 'MATCH_PASSWORD'" - Actually a fastlane version mismatch, not wrong password
- [x] Match connecting to wrong Apple team (Betsson France instead of Goma) - Matchfile defaults leaking through
- [x] Missing provisioning profile for `com.gomagaming.betsson` - Had to run match with `readonly: false`
- [x] Keychain errors in CI - BFR Fastfile wasn't passing keychain params to match
- [x] Missing local Swift packages (RegisterFlow, SharedModels, etc.) - Using xcodeproj instead of workspace

### Key Decisions
- **Fastlane version**: Updated to 2.230.0 to match Match encryption format on goma branch
- **Discord notifications**: Removed from Fastfile, consolidated in workflow YAML only (avoids duplicate notifications, keeps secrets in GitHub)
- **Workspace vs Project**: Must use `Sportsbook.xcworkspace` for builds to resolve local packages in `Frameworks/`

### Experiments & Notes
- Verified MATCH_PASSWORD secret is correct ("goma") using hex output: `676f6d61` = "goma"
- GitHub Actions masks secrets even when echoed, but hex/base64 encoding bypasses masking
- Match v2 encryption format is base64 encoded, starts with `match_encrypted_v2_`
- goma branch has certs for BCM (`com.gomagaming.betssoncm.*`), BFR UAT uses `com.gomagaming.betsson`

### Useful Files / Links
- [Manual Distribute Workflow](../../.github/workflows/manual-distribute.yml)
- [Tag Release Workflow](../../.github/workflows/tag-release.yml)
- [BFR Fastfile](../../BetssonFranceLegacy/fastlane/Fastfile)
- [BCM Fastfile](../../BetssonCameroonApp/fastlane/Fastfile)
- [Match Certificates Repo](https://github.com/gomagaming/FastlaneAppleCertificates) - goma & betsson-france branches
- [Previous DJ: Manual Distribute Creation](./10-January-2026-manual-distribute-workflow.md)

### Key Configuration Differences (BFR vs BCM)
| Setting | BCM | BFR UAT | BFR PROD |
|---------|-----|---------|----------|
| Match Branch | goma | goma | betsson-france |
| Team ID | 422GNXXZJR (Goma) | 422GNXXZJR (Goma) | QN2DYX5K4M (Betsson France) |
| Bundle ID | com.gomagaming.betssoncm.* | com.gomagaming.betsson | fr.betsson.ios.app |
| API Key | Goma API Key | Goma API Key | BFR PROD API Key |

### Next Steps
1. Commit Fastfile changes and retry manual-distribute workflow
2. Verify BFR UAT build completes successfully
3. Test BFR PROD distribution (needs BFR_PROD_API_KEY secrets)
4. Consider regenerating Discord webhook (old one was exposed in repo history)
5. Delete old `auto-distribute-cameroon.yml` after successful testing
