## Date
06 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix GitHub Actions CI/CD keychain warnings preventing certificate import
- Resolve Firebase App Distribution authentication issues in CI environment
- Successfully build and distribute BetssonCameroonApp via automated workflow

### Achievements
- [x] Fixed keychain access warnings in GitHub Actions (WWDR certificate import failures)
- [x] Created temporary keychain setup step with proper password configuration
- [x] Updated Fastfile to detect CI environment and use keychain credentials automatically
- [x] Added proper keychain cleanup in workflow
- [x] Successfully built IPA in CI environment (build time: 11 minutes)
- [x] Added Firebase CLI token debugging to diagnose authentication issues

### Issues / Bugs Hit
- [x] **Initial Problem**: `security: SecKeychainItemSetAccessWithPassword: incorrect` warnings
  - Root cause: GitHub Actions runners use default `login.keychain` without password
  - Fastlane match couldn't set ACLs on imported certificates

- [ ] **Current Blocker**: Firebase App Distribution authentication failing in CI
  - Error: "Missing authentication credentials"
  - Token configured in GitHub secrets and passed to workflow
  - Works locally with same `FIREBASE_CLI_TOKEN`, fails only in CI
  - Added debug logging to verify token presence and length

### Key Decisions
- **Keychain Strategy**: Create dedicated temporary keychain (`ci-build.keychain-db`) in CI instead of using default `login.keychain`
  - More secure and isolated
  - Proper password management
  - Automatic cleanup after workflow completion

- **CI Detection Pattern**: Use environment variable presence (`KEYCHAIN_NAME`/`KEYCHAIN_PASSWORD`) to auto-detect CI
  - No code changes needed for local development
  - Fastfile automatically adapts to environment

- **Debug Approach**: Add verbose logging before switching authentication methods
  - Verify token is actually being passed from secrets
  - Check token length and Firebase App ID configuration
  - Determine if issue is token presence or plugin compatibility

### Experiments & Notes
- Tried verbose/debug mode on fastlane match - revealed keychain password was missing
- GitHub Actions `macos-26` runner uses keychain without password by default
- Keychain timeout set to 1 hour (3600 seconds) to cover full build duration
- Firebase CLI token method may have compatibility issues with CI environments - service account JSON is more reliable alternative

### Useful Files / Links
- [GitHub Workflow](.github/workflows/auto-distribute-cameroon.yml) - Lines 125-157 (keychain setup)
- [Fastfile](BetssonCameroonApp/fastlane/Fastfile) - Lines 206-211, 467-472 (CI keychain detection)
- [Match Documentation](https://docs.fastlane.tools/actions/match/)
- [Firebase App Distribution Plugin](https://github.com/fastlane/fastlane-plugin-firebase_app_distribution)

### Code Snippets

**Keychain Setup in CI (Workflow)**
```yaml
- name: Setup Keychain for Code Signing
  run: |
    KEYCHAIN_NAME="ci-build.keychain-db"
    KEYCHAIN_PASSWORD="ci-temporary-password"
    KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"

    security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
    security default-keychain -s "$KEYCHAIN_PATH"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
    security set-keychain-settings -t 3600 -u "$KEYCHAIN_PATH"
    security list-keychains -d user -s "$KEYCHAIN_PATH" $(security list-keychains -d user | sed s/\"//g)

    echo "KEYCHAIN_NAME=$KEYCHAIN_NAME" >> $GITHUB_ENV
    echo "KEYCHAIN_PASSWORD=$KEYCHAIN_PASSWORD" >> $GITHUB_ENV
```

**Auto-detect CI Environment (Fastfile)**
```ruby
# Add keychain configuration if running in CI
if ENV["KEYCHAIN_NAME"] && ENV["KEYCHAIN_PASSWORD"]
  UI.message "🔐 Using CI keychain: #{ENV['KEYCHAIN_NAME']}"
  match_params[:keychain_name] = ENV["KEYCHAIN_NAME"]
  match_params[:keychain_password] = ENV["KEYCHAIN_PASSWORD"]
end
```

### Git Commits
- `eff904d78` - Fix CI keychain warnings: Add temporary keychain setup for code signing
- `5b5f936c8` - Add Firebase CLI token debugging to diagnose CI authentication issue

### Next Steps
1. **Immediate**: Review next workflow run debug output for Firebase token status
   - Check if token shows as "SET" in environment variables
   - Verify token length matches expected format
   - Confirm Firebase App ID is correctly resolved

2. **If token is present but still fails**: Switch to Firebase service account authentication
   - Generate service account JSON from Firebase Console
   - Add `FIREBASE_SERVICE_ACCOUNT_JSON` secret to GitHub
   - Update workflow to write JSON file and point Fastfile to it
   - More reliable than CLI token in CI environments

3. **If token is missing**: Debug GitHub secrets configuration
   - Verify `FIREBASE_CLI_TOKEN` secret exists and has correct value
   - Check secret is available to workflow (not restricted by environment)

4. **After Firebase auth fixed**: Full end-to-end test
   - Manual workflow dispatch for staging
   - Verify Firebase distribution to testers
   - Test automatic trigger on `devices.csv` push
   - Document final working configuration
