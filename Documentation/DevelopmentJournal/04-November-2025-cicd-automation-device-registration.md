## Date
04 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Implement full CI/CD automation for BetssonCameroon device registration and distribution
- Integrate Firebase App Distribution device fetching with Fastlane
- Create automated workflow triggered by devices.txt changes
- Simplify and clarify Fastlane lane naming

### Achievements
- [x] Researched Firebase App Distribution device fetching capabilities
- [x] Discovered built-in `firebase_app_distribution_get_udids` Fastlane action
- [x] Installed Firebase App Distribution plugin for Fastlane
- [x] Created comprehensive device registration workflow with 3 main lanes:
  - `distribute_staging/production` - Default: increment build, register devices, distribute
  - `keep_version_distribute_staging/production` - Keep build number, register devices, distribute
  - Utility lanes: `fetch_firebase_devices`, `register_new_devices`
- [x] Implemented GitHub Actions workflow (`.github/workflows/auto-distribute-cameroon.yml`)
  - Auto-triggers on `devices.txt` push
  - Manual trigger with environment selection
- [x] Refactored lane naming for clarity (consolidated from 3 to 2 lane types)
- [x] ALL distribution lanes now automatically check devices.txt and register devices
- [x] Created comprehensive documentation (`AUTO_DISTRIBUTE.md`)

### Issues / Bugs Hit
- [ ] Initial confusion: `firebase_app_distribution_get_udids` not found in standard actions
  - **Resolved**: Required plugin installation (`fastlane-plugin-firebase_app_distribution`)
- [ ] Duplicate gem entry in Pluginfile
  - **Resolved**: Removed duplicate line
- [ ] Naming confusion with multiple similar lane names
  - **Resolved**: Consolidated to clear `distribute_*` and `keep_version_distribute_*` pattern
- [ ] Unnecessary `sync_version` copying BetssonFrance version to BetssonCameroon
  - **Resolved**: Deleted entirely - separate products should have independent versions

### Key Decisions
- **Client-specific device lists**: Keep local `devices.txt` manually curated instead of auto-fetching all Firebase devices
  - Reason: Firebase shows devices across ALL projects/clients - can't mix Cameroon with France testers
  - Solution: `fetch_firebase_devices` available as reference tool, but main workflow uses local file
- **Default lane increments build**: `distribute_*` prompts for build++ (most common workflow)
- **Explicit keep version**: `keep_version_distribute_*` for device-only updates
- **ALL lanes register devices**: Automatic safety - can never forget device registration
- **CI/CD uses keep_version**: GitHub Actions always uses `keep_version_distribute_*` (no version bumping in automation)
- **Same build number for device additions**: Only provisioning profile changes, Firebase replaces build
- **REMOVED sync_version**: BetssonFrance and BetssonCameroon are separate products for different markets
  - Reason: No valid reason to synchronize version numbers between independent products
  - Each product should manage its own version independently
  - Deleted `sync_version` lane and all calls to it

### Experiments & Notes
- Firebase CLI `appdistribution:testers:list` returns JSON with device UDIDs
- Fastlane plugin provides cleaner interface than raw CLI calls
- `force_for_new_devices: true` in Match forces profile regeneration
- Private lanes (`private_lane`) used for internal implementation details
- GitHub Actions `bundler-cache: true` works correctly with `working-directory: BetssonCameroonApp`

### Architecture & Flow
**Device Registration Flow** (all distribution lanes):
```
1. Read devices.txt (format: UDID<TAB>Device Name)
2. Register devices with Apple Developer Portal (register_devices)
3. Update provisioning profiles (match with force_for_new_devices: true)
4. Build app with updated profile
5. Distribute to Firebase App Distribution
```

**Lane Hierarchy**:
```
distribute_staging
  └─> version_bump (prompts for build++)
  └─> keep_version_distribute_staging
      └─> register_new_devices (reads devices.txt)
      └─> build_and_distribute_to_firebase
```

### Useful Files / Links
- [BetssonCameroon Fastfile](../../BetssonCameroonApp/fastlane/Fastfile)
- [devices.txt](../../BetssonCameroonApp/fastlane/devices.txt)
- [GitHub Actions Workflow](../../.github/workflows/auto-distribute-cameroon.yml)
- [Auto-Distribution Documentation](../../BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md)
- [Pluginfile](../../BetssonCameroonApp/fastlane/Pluginfile)
- [.env.template](../../BetssonCameroonApp/fastlane/.env.template)
- [Firebase App Distribution Plugin](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution)

### Configuration Requirements
**Local Environment** (`.env`):
- `FIREBASE_CLI_TOKEN` - Firebase auth token
- `FIREBASE_PROJECT_NUMBER` - Numeric project ID (NOT Firebase App ID)
- `MATCH_GIT_URL` - Certificate repo URL
- `MATCH_PASSWORD` - Match encryption password
- `GOMA_APPLE_ID` - Apple Developer account
- `GOMA_TEAM_ID` - Apple Team ID
- `BETSSONCM_STG_FIREBASE_APP_ID` - Staging Firebase app
- `BETSSONCM_PROD_FIREBASE_APP_ID` - Production Firebase app

**GitHub Secrets** (for CI/CD):
- All above environment variables
- `MATCH_GIT_PRIVATE_KEY` - SSH key for certificates repo

### Post-Session Updates (Evening Session)

#### Additional Issues Discovered & Resolved
- [x] **Removed `sync_version` entirely**: BetssonFrance and BetssonCameroon are separate products
  - Issue: `sync_version` was copying France version to Cameroon (makes no sense)
  - Resolution: Deleted lane and all references - each product manages own version independently

- [x] **Replaced agvtool with versioning plugin**:
  - Issue: `agvtool` showed multiple confusing build numbers (01921, 1)
  - Resolution: Installed `fastlane-plugin-versioning` (v0.7.1)
  - Updated all `get_build_number` → `get_build_number_from_xcodeproj`
  - Updated all `increment_build_number` → `increment_build_number_in_xcodeproj`
  - Result: Single, clear build number across all configurations

- [x] **Fixed Fastlane `return` vs `next`**:
  - Issue: Used `return` in lanes causing "unexpected return" error
  - Resolution: Changed to `next` for early lane exit

- [ ] **devices.txt vs devices.csv format confusion** (IN PROGRESS):
  - Issue: `register_devices` expects specific format, header causing issues
  - Current state: Renamed to devices.csv, testing format requirements
  - Apple format: Tab-separated with 3 columns (UDID, Name, Platform), NO header
  - Path issue resolved: Changed from `./fastlane/devices.txt` to `./devices.csv`

#### Versioning Plugin Benefits Confirmed
- ✅ Updates all 4 configurations simultaneously (Debug/Release × Staging/Production)
- ✅ Single source of truth - no confusion
- ✅ Target-specific: Explicitly uses `target: "BetssonCameroonApp"`
- ✅ No more `agvtool` inconsistencies

### Next Steps
1. **IMMEDIATE**: Resolve devices.csv format - remove header, test registration
2. Test full workflow: Add device → `keep_version_distribute_staging` → verify on Firebase
3. Test CI/CD workflow: Push devices.csv changes → verify GitHub Actions triggers
4. Verify provisioning profiles regenerate correctly with new devices
5. Test production workflow after staging validation
6. Consider: Add Slack/Discord notification on distribution completion
7. Consider: Add build success/failure badges to README
8. Apply same pattern to BetssonFrance project if successful
9. Update AUTO_DISTRIBUTE.md to reflect devices.csv (not devices.txt)
