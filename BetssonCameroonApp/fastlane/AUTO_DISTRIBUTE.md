# Auto-Distribution with Device Registration

Complete guide for the **fully automated CI/CD workflow** for Betsson Cameroon.

## Quick Reference

### When to use which method?

| **Scenario** | **Method** | **What Happens** |
|-------------|------------|------------------|
| **New release** (recommended) | Tag-based dual release | Deploys to BOTH staging + production |
| **Adding devices only** | `keep_version_distribute_staging` | NO bump, registers devices, builds (SAME build #), distributes |
| **Local testing** | `distribute_staging` | Prompts for build++, registers devices, builds, distributes |

**Key principle:** ALL lanes check `devices.csv` and register devices automatically.

---

## Tag-Based Dual Releases (Recommended)

**The easiest way to create releases**: Push a Git tag, and GitHub Actions automatically builds and distributes to **BOTH** staging AND production.

### Quick Start

```bash
# 1. Update version in Xcode project first
# 2. Commit and push

# 3. Create a tag with format: CLIENT-VERSION(BUILD)
git tag BCM-2.1.3(21309)
git push origin BCM-2.1.3(21309)

# GitHub Actions automatically:
# Step 1: Validates tag format and Xcode version match
# Step 2: Reads CHANGELOG.yml for release notes
# Step 3: Builds and distributes to STAGING
# Step 4: Builds and distributes to PRODUCTION
# Step 5: Sends Discord notification
```

### Tag Format

**Pattern**: `CLIENT-VERSION(BUILD)`

**Supported formats** (case-insensitive):
- Separator: Hyphen (`-`) or underscore (`_`)
- Version prefix: Optional `v` (e.g., `v2.1.3` or `2.1.3`)
- Version format: `X.Y` or `X.Y.Z`

**Examples:**
```bash
BCM-2.1.3(21309)       # Standard format
BCM-v2.1.3(21309)      # With v prefix
bcm_2.1.3(21309)       # Underscore + lowercase
bcm-2.1(2130)          # Two-part version
```

**Invalid formats:**
```bash
BCM-2.1.3              # Missing build number
BCM-Stg-2.1.3(21309)   # Old format with environment (no longer supported)
2.1.3(21309)           # Missing client
BCM-0.0(0)             # Invalid version/build (< minimums)
```

### Workflow Behavior

**When you push a tag:**

1. **Parse & Validate** tag format and version numbers
2. **Checkout** the release branch (`betsson-cm`)
3. **Validate Version** - Xcode project must match tag (fails if mismatch)
4. **Read CHANGELOG.yml** for release notes (optional - falls back to generic)
5. **Build & Distribute Staging** - First environment
6. **Build & Distribute Production** - Second environment
7. **Notify** via Discord (success or failure)

**Configuration:**
- Tag mapping defined in `.github/tag-config.yml`
- BCM → branch: `betsson-cm`
- Staging scheme: `BetssonCM Staging`
- Production scheme: `BetssonCM Prod`

### Release Notes (CHANGELOG.yml)

**Optional** - Create `BetssonCameroonApp/CHANGELOG.yml` with release notes:

**Format:**
```yaml
releases:
  - version: "2.1.3"
    build: 21309
    date: "2025-11-26"
    notes:
      - "Added live score updates"
      - "Fixed crash in match details"
      - "Improved filter performance"
```

**Key points:**
- Match by version + build only (no environment field)
- Same notes used for both staging and production
- If not found, uses generic notes: `"Build 21309 - Version 2.1.3"`

### Complete Example

```bash
# 1. Update version in Xcode
# Set MARKETING_VERSION = 2.1.3
# Set CURRENT_PROJECT_VERSION = 21309

# 2. Update CHANGELOG.yml (optional)
vim BetssonCameroonApp/CHANGELOG.yml
# Add entry for version 2.1.3 build 21309

# 3. Ensure devices.csv has latest devices
vim BetssonCameroonApp/fastlane/devices.csv

# 4. Commit changes
git add .
git commit -m "Prepare release 2.1.3 (21309)"
git push origin betsson-cm

# 5. Create and push tag
git tag BCM-2.1.3(21309)
git push origin BCM-2.1.3(21309)

# 6. Monitor workflow
# Check: GitHub Actions → Tag-Based Dual Release Distribution
# Discord notification will be sent on completion
```

### Benefits of Tag-Based Dual Releases

- **Fully automated** - No manual Fastlane commands needed
- **Dual release** - One tag deploys to both environments
- **Version tracking** - Git tags provide permanent version history
- **Consistency** - Same process every time, reduces human error
- **Transparency** - Anyone can see release history via `git tag -l`
- **Discord notifications** - Team stays informed automatically

---

## Manual Fastlane Lanes

For local development and specific scenarios:

### Default Distribution Lanes (Increment Build)

#### `distribute_staging`
**Use when**: Local testing with new build number

```bash
fastlane distribute_staging
fastlane distribute_staging release_notes:"Added live chat feature"
```

**Flow**: Prompts for build++ → Registers devices → Builds → Distributes (NEW build #)

#### `distribute_production`
**Use when**: Local production release with new build

```bash
fastlane distribute_production
```

#### `distribute_all`
**Use when**: Local release to BOTH environments

```bash
fastlane distribute_all
```

**Flow**: Prompts for build++ once → Distributes to both environments

---

### Keep Version Lanes (Same Build Number)

#### `keep_version_distribute_staging`
**Use when**: Adding devices without changing app version

```bash
fastlane keep_version_distribute_staging
fastlane keep_version_distribute_staging release_notes:"Added 5 new testers"
```

**Flow**: Registers devices → Updates profiles → Builds → Distributes (SAME build)

#### `keep_version_distribute_production`
**Use when**: Adding devices to production without new version

```bash
fastlane keep_version_distribute_production
```

#### `keep_version_distribute_all`
**Use when**: Adding devices to BOTH environments

```bash
fastlane keep_version_distribute_all
```

---

### Utility Lanes

#### `register_new_devices`
**Use when**: Only register devices, don't build/distribute

```bash
fastlane register_new_devices app_scheme:"BetssonCM Staging"
```

#### `fetch_firebase_devices`
**Use when**: Download all Firebase testers as reference

```bash
fastlane fetch_firebase_devices
# Creates: fastlane/firebase_devices.txt
```

#### `version_bump`
**Use when**: Manually increment build number

```bash
fastlane version_bump
# Prompts: Enter new build number, '+' to increment, or enter to keep
```

---

## devices.csv Format

Location: `BetssonCameroonApp/fastlane/devices.csv`

```
Device ID	Device Name
00008030-001234567890001E	iPhone 15 Pro - John Doe
00008110-000123456789ABCD	iPhone 16 Pro - Jane Smith
00008120-000FEDCBA9876543	iPhone 15 - Bob Johnson
```

**Format**: `UDID<TAB>Device Name`

**Tips**:
- Use `<TAB>` not spaces between UDID and name
- Add `#` for comments
- Keep file clean - remove old devices periodically
- **All distribution lanes automatically check this file**

---

## Setup Requirements

### 1. Local Environment (.env file)

Create `BetssonCameroonApp/fastlane/.env`:

```bash
# Match Configuration
MATCH_GIT_URL=git@github.com:gomagaming/FastlaneAppleCertificates.git
MATCH_PASSWORD=your_match_encryption_password

# Firebase Distribution
FIREBASE_CLI_TOKEN=your_firebase_cli_token
FIREBASE_PROJECT_NUMBER=123456789

# Apple Developer Account
GOMA_TEAM_ID=422GNXXZJR

# Firebase App IDs
BETSSONCM_STG_FIREBASE_APP_ID=1:123456:ios:abc123
BETSSONCM_PROD_FIREBASE_APP_ID=1:123456:ios:xyz789

# App Store Connect API Key
APP_STORE_CONNECT_API_KEY_ID=your_key_id
APP_STORE_CONNECT_API_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_API_KEY_FILEPATH=./fastlane/AuthKey_XXXX.p8
```

### 2. GitHub Secrets (for CI/CD)

Repository Settings → Secrets and Variables → Actions:

- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_GIT_PRIVATE_KEY`
- `FIREBASE_CLI_TOKEN`
- `FIREBASE_PROJECT_NUMBER`
- `GOMA_TEAM_ID`
- `BETSSONCM_STG_FIREBASE_APP_ID`
- `BETSSONCM_PROD_FIREBASE_APP_ID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`
- `DISCORD_WEBHOOK_URL`

---

## Troubleshooting

### Tag format rejected
```
Invalid tag format: BCM-Stg-2.1.3(21309)
Expected format: CLIENT-VERSION(BUILD)
```
→ Fix: Remove environment from tag. Use `BCM-2.1.3(21309)` instead

### Version mismatch
```
Version mismatch! Tag has 2.1.3 but Xcode project has 2.1.2
```
→ Fix: Update Xcode project version, commit, delete tag, recreate tag

### CHANGELOG not found
```
Changelog file not found, using generic notes
```
→ This is OK - generic notes will be used. Create CHANGELOG.yml if you want custom notes.

### Devices not registered
```
WARNING: devices.csv not found
```
→ Create `devices.csv` in `BetssonCameroonApp/fastlane/`

### Staging succeeds but production fails
→ Check production-specific secrets and Firebase App ID

---

## Quick Command Reference

### Tag-Based Dual Releases (Recommended)

```bash
# Create dual release (deploys to BOTH staging + production)
git tag BCM-2.1.3(21309)
git push origin BCM-2.1.3(21309)

# Delete a tag (if needed)
git tag -d BCM-2.1.3(21309)
git push origin :refs/tags/BCM-2.1.3(21309)

# List tags
git tag -l "BCM-*"
```

### Manual Fastlane Lanes

```bash
# Most common: Normal release (increments build)
fastlane distribute_staging

# Adding devices only (keeps same build)
fastlane keep_version_distribute_staging

# Deploy to production
fastlane distribute_production

# Deploy to both environments
fastlane distribute_all

# Utility: Only register devices (no build)
fastlane register_new_devices app_scheme:"BetssonCM Staging"

# Debug: Verify environment
fastlane test

# List all available lanes
fastlane lanes
```

---

## Support

**Issues?**
1. Check Fastlane logs: `BetssonCameroonApp/fastlane/logs/`
2. Check GitHub Actions logs (for CI/CD runs)
3. Verify `.env` file has all required variables
4. Ensure `devices.csv` format is correct (tab-separated)
5. Test locally before using CI/CD

**Key Insight**: Tag-based dual releases are the recommended approach - they automatically deploy to both environments with a single tag push!
