## Date
09 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Fix failing GitHub Actions tag-release workflow
- Understand and debug CI/CD pipeline issues
- Ensure BCM releases deploy correctly to Firebase App Distribution

### Achievements
- [x] Fixed missing `keep_version_distribute_production` lane error by switching to `keep_version_distribute_uat`
- [x] Added `BETSSONCM_UAT_FIREBASE_APP_ID` environment variable to both workflows:
  - `.github/workflows/tag-release.yml`
  - `.github/workflows/auto-distribute-cameroon.yml`
- [x] Launched audit agents to find all CI/CD inconsistencies between workflows and Fastfile
- [x] Identified Firebase App ID mismatch: UAT scheme builds `com.gomagaming.betssoncm.prod` bundle ID, requires PROD Firebase app
- [x] Confirmed `BETSSONCM_PROD_FIREBASE_APP_ID` secret can be safely removed (not validated or used by any lane)
- [x] Bumped build number through multiple iterations (3405 → 3406 → 3407)

### Issues / Bugs Hit
- [x] `keep_version_distribute_production` lane doesn't exist - workflow was calling non-existent lane
- [x] `BETSSONCM_UAT_FIREBASE_APP_ID` missing from both workflows - Fastfile expected it but workflows didn't provide it
- [x] Firebase upload failed: IPA bundle ID `com.gomagaming.betssoncm.prod` didn't match Firebase app `com.gomagaming.betssoncm.stg`
  - Root cause: `BETSSONCM_UAT_FIREBASE_APP_ID` was set to STG Firebase app instead of PROD

### Key Decisions
- **Use `keep_version_distribute_uat` for BCM releases** - Production lane doesn't exist, UAT lane builds with prod bundle ID
- **UAT Firebase App ID must point to PROD Firebase app** because:
  - `BetssonCM UAT` scheme → `BETSSONCM_UAT` internal ID → `com.gomagaming.betssoncm.prod` bundle ID
  - Firebase PROD app (`1:844144342615:ios:161f290cea43b3d78a9512`) expects this bundle ID
- **Removed `BETSSONCM_PROD_FIREBASE_APP_ID` from GitHub secrets** - not used by any executing lane, avoids confusion

### Experiments & Notes
- Audit agents found no critical issues beyond the UAT Firebase App ID mismatch
- `BETSSONCM_PROD_FIREBASE_APP_ID` is written to `.env` but never read by any Fastlane lane
- Echo statements like `${VAR:+SET}` are informational only, won't fail if empty

### Firebase App ID Mapping (for reference)
| App Nickname | Bundle ID | Firebase App ID |
|--------------|-----------|-----------------|
| Betsson CM STG | `com.gomagaming.betssoncm.stg` | `1:844144342615:ios:1fbd8347dfdc4e1c8a9512` |
| Betsson CM Prod | `com.gomagaming.betssoncm.prod` | `1:844144342615:ios:161f290cea43b3d78a9512` |

| GitHub Secret | Should Be Set To |
|---------------|------------------|
| `BETSSONCM_STG_FIREBASE_APP_ID` | `1:844144342615:ios:1fbd8347dfdc4e1c8a9512` |
| `BETSSONCM_UAT_FIREBASE_APP_ID` | `1:844144342615:ios:161f290cea43b3d78a9512` (PROD!) |

### Useful Files / Links
- [tag-release.yml](../../.github/workflows/tag-release.yml) - Main release workflow
- [auto-distribute-cameroon.yml](../../.github/workflows/auto-distribute-cameroon.yml) - Manual/auto distribution
- [Fastfile](../../BetssonCameroonApp/fastlane/Fastfile) - Fastlane configuration
- [CHANGELOG.yml](../../BetssonCameroonApp/CHANGELOG.yml) - Release notes

### Next Steps
1. Verify tag `bcm-v0.3.4(3407)` succeeds after setting correct `BETSSONCM_UAT_FIREBASE_APP_ID` secret
2. Consider renaming `BETSSONCM_UAT` to something clearer (it builds PROD bundle ID, which is confusing)
3. Update AUTO_DISTRIBUTE.md documentation to reflect current setup
4. Clean up unused `BETSSONCM_PROD_FIREBASE_APP_ID` references from workflow files
