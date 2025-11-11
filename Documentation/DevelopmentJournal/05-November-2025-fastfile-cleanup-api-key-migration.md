## Date
05 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix duplicate device registration in Fastfile
- Migrate from Apple ID/password to App Store Connect API Key authentication
- Resolve path inconsistencies in device registration workflow
- Add comprehensive logging to GitHub Actions workflow
- Clean up dead code and outdated references

### Achievements
- [x] Analyzed and documented Fastfile inconsistencies (duplicate device registration, path issues)
- [x] Migrated entire authentication flow to App Store Connect API Key (no more 2FA!)
- [x] Updated `.env.template` with API Key configuration
- [x] Fixed `certificates` lane - removed duplicate device registration logic
- [x] Fixed `register_new_devices` path from `./devices.csv` to `./fastlane/devices.csv`
- [x] Added `setup_api_key` call to `build_and_distribute_to_firebase`
- [x] Removed dead `skip_version_sync` parameters (leftover from deleted sync_version)
- [x] Updated all "devices.txt" references to "devices.csv"
- [x] Moved `FIREBASE_DISTRIBUTION_GROUPS` and `FIREBASE_DISTRIBUTION_TESTERS` from .env to Fastfile constants
- [x] Updated GitHub Actions workflow to use API Key secrets
- [x] Added comprehensive logging with emojis throughout GitHub Actions workflow
- [x] Fixed redundant `bundle install` step in GitHub Actions (bundler-cache handles it)
- [x] Regenerated expired certificates using `fastlane match` with API Key authentication
- [x] Added `*.p8` to `.gitignore` for security
- [x] Verified path consistency between local and CI/CD environments

### Issues / Bugs Hit
- [ ] **devices.csv format confusion** - Initially had CSV format with quotes, needed tab-separated without quotes
  - **Resolution**: Fixed format to tab-separated, 3 columns (UDID, Name, Platform), with header row
- [ ] **Ruby CSV gem missing** - Ruby 3.4 compatibility issue
  - **Resolution**: User manually installed `gem install csv`
- [ ] **Expired certificate K6MYN3ZXJA.cer** - Certificate expired, blocking builds
  - **Resolution**: Manually removed from Match repo, ran `fastlane match adhoc --force` with API Key
- [ ] **Duplicate device registration** - Devices registered twice (in `certificates` AND `register_new_devices`)
  - **Resolution**: Removed device registration from `certificates` lane entirely
- [ ] **Path confusion** - `./devices.csv` vs `./fastlane/devices.csv`
  - **Resolution**: Fastlane runs from `BetssonCameroonApp/`, so path is `./fastlane/devices.csv`

### Key Decisions
- **App Store Connect API Key > Apple ID/password**: No more 2FA prompts, better for CI/CD, more secure
- **Firebase distribution config in Fastfile**: Not sensitive data, easier to maintain in code
- **Bundle approach for Fastlane**: Use `bundle exec fastlane` everywhere (local + CI/CD) for version consistency
- **Certificates lane is private**: Changed to `private_lane` - only for internal use by build workflow
- **Device registration single responsibility**: Only `register_new_devices` handles device registration
- **Comprehensive logging**: Added emoji-based logging throughout GitHub Actions for easier debugging
- **Path structure maintained**: Files created in `fastlane/` subdirectory, fastlane runs from project root

### Experiments & Notes
- **API Key authentication flow**: `setup_api_key` → `app_store_connect_api_key` → Sets lane context → Auto-used by `match` and `register_devices`
- **Match certificate regeneration**: After removing expired cert from git repo, `--force` flag creates new certificate automatically
- **Working directory dance in GitHub Actions**: Creating files in `fastlane/` while running fastlane from parent directory is correct and matches local workflow
- **Gemfile.lock critical for CI/CD**: Must be committed - ensures identical gem versions between local and CI
- **bundler-cache: true**: GitHub Actions feature automatically runs `bundle install` and caches gems

### Useful Files / Links
- [BetssonCameroon Fastfile](../../BetssonCameroonApp/fastlane/Fastfile) - Main automation file with all lanes
- [devices.csv](../../BetssonCameroonApp/fastlane/devices.csv) - Device registration list (tab-separated)
- [.env.template](../../BetssonCameroonApp/fastlane/.env.template) - Environment variables template
- [GitHub Actions Workflow](../../.github/workflows/auto-distribute-cameroon.yml) - CI/CD automation
- [Pluginfile](../../BetssonCameroonApp/fastlane/Pluginfile) - Fastlane plugins (firebase, versioning)
- [Matchfile](../../BetssonCameroonApp/fastlane/Matchfile) - Match configuration
- [Previous Session Journal](./04-November-2025-cicd-automation-device-registration.md) - Context from yesterday
- [App Store Connect API Key Docs](https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)

### Architecture & Flow

**Fastfile Lane Structure (Post-Cleanup):**
```
distribute_staging
  └─> version_bump (prompts for build++)
  └─> keep_version_distribute_staging
      └─> register_new_devices (reads devices.csv, registers with Apple)
      └─> build_and_distribute_to_firebase
          └─> setup_api_key
          └─> certificates (only fetches profiles, NO device registration)
          └─> build_ios_app
          └─> firebase_app_distribution
```

**Device Registration Flow (Fixed):**
```
1. Read ./fastlane/devices.csv (tab-separated, with header)
2. Call register_devices action (uses API Key via lane context)
3. Call match with force_for_new_devices: true
4. Provisioning profiles regenerated with new devices
```

**API Key Authentication Flow:**
```
1. setup_api_key lane called
2. app_store_connect_api_key action sets lane context
3. All subsequent actions (register_devices, match) automatically use API Key
4. No username/password needed anywhere
```

### Configuration Requirements

**Local Environment** (`.env`):
```bash
# Match
MATCH_GIT_URL=git@github.com:gomagaming/FastlaneAppleCertificates.git
MATCH_PASSWORD=your_match_encryption_password

# App Store Connect API Key
APP_STORE_CONNECT_API_KEY_ID=7NC93JSN42
APP_STORE_CONNECT_API_ISSUER_ID=69a6de8e-8340-47e3-e053-5b8c7c11a4d1
APP_STORE_CONNECT_API_KEY_FILEPATH=./fastlane/AuthKey_7NC93JSN42.p8

# Firebase
FIREBASE_CLI_TOKEN=your_firebase_cli_token
FIREBASE_PROJECT_NUMBER=your_firebase_project_number

# Apple Developer
GOMA_TEAM_ID=422GNXXZJR

# Firebase App IDs
BETSSONCM_STG_FIREBASE_APP_ID=your_staging_app_id
BETSSONCM_PROD_FIREBASE_APP_ID=your_production_app_id
```

**GitHub Secrets** (11 total):
- `APP_STORE_CONNECT_API_KEY_CONTENT` - Full contents of .p8 file
- `APP_STORE_CONNECT_API_KEY_ID` - Key ID (7NC93JSN42)
- `APP_STORE_CONNECT_API_ISSUER_ID` - Issuer ID (UUID format)
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_GIT_PRIVATE_KEY` - SSH private key for certificates repo
- `FIREBASE_CLI_TOKEN`
- `FIREBASE_PROJECT_NUMBER`
- `BETSSONCM_STG_FIREBASE_APP_ID`
- `BETSSONCM_PROD_FIREBASE_APP_ID`
- `GOMA_TEAM_ID`

**Fastfile Constants** (not in .env):
```ruby
FIREBASE_DISTRIBUTION_GROUPS = "" # or "ios-internal"
FIREBASE_DISTRIBUTION_TESTERS = "ruben@gomadevelopment.pt"
```

### Files Modified

1. **BetssonCameroonApp/fastlane/Fastfile**
   - Added `setup_api_key` private lane (lines 52-61)
   - Fixed `certificates` lane: removed device registration, made private (lines 166-195)
   - Fixed `register_new_devices` path to `./fastlane/devices.csv` (line 402)
   - Added `setup_api_key` call in `build_and_distribute_to_firebase` (line 245)
   - Removed `skip_version_sync` dead code (lines 512-520)
   - Updated all "devices.txt" → "devices.csv" references (lines 388, 464, 488)
   - Moved Firebase distribution config to constants (lines 39-40)
   - Updated `test` lane to print new constants (lines 82-86)

2. **BetssonCameroonApp/fastlane/.env.template**
   - Added API Key configuration section
   - Removed `FIREBASE_DISTRIBUTION_GROUPS` and `FIREBASE_DISTRIBUTION_TESTERS`
   - Deprecated `GOMA_APPLE_ID` (no longer needed)

3. **BetssonCameroonApp/fastlane/devices.csv**
   - Fixed format: tab-separated, 3 columns, with header row
   - Format: `Device ID\tDevice Name\tDevice Platform`

4. **.github/workflows/auto-distribute-cameroon.yml**
   - Changed trigger path from `devices.txt` to `devices.csv` (line 23)
   - Removed redundant `bundle install` step (bundler-cache handles it)
   - Added API Key setup step (lines 45-55)
   - Updated environment variables with API Key IDs (lines 64-65)
   - Added comprehensive logging with emojis throughout (lines 50, 54-55, 70, 85-90, 96-113, 118-134, 140-152, 158-170, 185-189)
   - Added `.p8` file to cleanup (line 188)

5. **.gitignore**
   - Added `*.p8` to prevent committing sensitive API keys (line 114)

6. **BetssonCameroonApp/Gemfile** (committed to git)
   - Already had correct configuration with Pluginfile evaluation

7. **BetssonCameroonApp/Gemfile.lock** (committed to git)
   - Locks exact gem versions for reproducible builds

8. **BetssonCameroonApp/fastlane/Pluginfile** (committed to git)
   - `fastlane-plugin-firebase_app_distribution`
   - `fastlane-plugin-versioning`

### Next Steps
1. **IMMEDIATE**: Commit and push all changes to GitHub
   ```bash
   cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
   git add .
   git commit -m "Migrate to API Key authentication, fix Fastfile issues, add CI/CD logging"
   git push origin betsson-cm
   ```

2. **Add GitHub Secrets**: Configure all 11 required secrets in repository settings
   - Priority: `APP_STORE_CONNECT_API_KEY_CONTENT` (copy .p8 file contents)
   - Priority: `APP_STORE_CONNECT_API_KEY_ID` and `APP_STORE_CONNECT_API_ISSUER_ID`

3. **Test GitHub Actions**: Trigger workflow manually to verify all paths and secrets work
   - Go to Actions → Auto-Distribute Betsson Cameroon → Run workflow
   - Select staging environment
   - Watch logs for emoji progress indicators

4. **Test device addition workflow**: Add a new device to devices.csv and push
   - Should auto-trigger staging build
   - Verify device gets registered
   - Verify provisioning profile updates

5. **Update AUTO_DISTRIBUTE.md**: Reflect devices.csv (not devices.txt) and API Key setup

6. **Consider**: Apply same API Key migration pattern to BetssonFrance project

7. **Monitor**: First production build to ensure certificate and profile work correctly

8. **Security audit**: Verify no .p8 files or passwords committed to git history
