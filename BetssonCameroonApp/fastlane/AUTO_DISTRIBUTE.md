# Auto-Distribution with Device Registration

Complete guide for the **fully automated CI/CD workflow** for Betsson Cameroon.

## 🎯 Quick Reference

### When to use which lane?

| **Scenario** | **Lane to Use** | **What Happens** |
|-------------|----------------|------------------|
| 🆕 **New release** (default) | `distribute_staging` | Prompts for build++, registers devices, builds, distributes |
| 📱 **Added devices only** | `keep_version_distribute_staging` | NO bump, registers devices, builds (SAME build #), distributes |

**Key principle:** ALL lanes check `devices.txt` and register devices automatically.

---

## 📱 Complete Workflow Examples

### Scenario 1: Normal Release (New Build Version)

**When**: You've merged new features and want to release a new build.

```bash
cd BetssonCameroonApp

# Default workflow: increment build + distribute
fastlane distribute_staging

# Prompts you:
# "Enter new build number, press enter to keep current, or '+' to increment:"
# Type: +  (increments 1234 → 1235)

# What happens:
# ✅ Increments build number (1234 → 1235)
# ✅ Reads devices.txt and registers any new devices
# ✅ Updates provisioning profiles with new devices
# ✅ Builds app with NEW build number
# ✅ Distributes to Firebase App Distribution

# With custom release notes
fastlane distribute_staging release_notes:"Added live chat feature"
```

**Build Number**: Incremented (e.g., 1234 → 1235)
**Why**: New release with code changes
**Devices**: Automatically registered from devices.txt

---

### Scenario 2: Adding Devices Only (Keep Same Build)

**When**: You need to add new tester devices without changing the app version.

```bash
# 1. Add device UDIDs to local file
vim BetssonCameroonApp/fastlane/devices.txt
# Add lines:
# 00008030-001234567890001E	iPhone 15 Pro - John Doe
# 00008110-000123456789ABCD	iPhone 16 - Jane Smith

# 2. Run device registration + distribution (KEEP same build)
cd BetssonCameroonApp
fastlane keep_version_distribute_staging

# What happens:
# ✅ Reads devices.txt (2 new devices)
# ✅ Registers devices with Apple Developer Portal
# ✅ Regenerates provisioning profiles (force_for_new_devices: true)
# ✅ Builds app with SAME build number but new profile
# ✅ Distributes to Firebase App Distribution

# With custom release notes
fastlane keep_version_distribute_staging release_notes:"Added 2 new testers"
```

**Build Number**: Same as current build (e.g., stays at 1234)
**Why**: Only provisioning profile changed, app code unchanged
**Devices**: Automatically registered from devices.txt

---

## 🤖 GitHub Actions (CI/CD)

### Automatic Trigger on Device Changes

**When you push changes to `devices.txt`**, GitHub Actions automatically:

```bash
# Locally: add devices
vim BetssonCameroonApp/fastlane/devices.txt

# Commit and push
git add BetssonCameroonApp/fastlane/devices.txt
git commit -m "Add new tester devices for Cameroon"
git push origin betsson-cm

# 🎉 GitHub Actions automatically runs:
# - keep_version_distribute_staging
# - Registers devices, rebuilds (same build #), distributes
```

### Manual Trigger

Go to **GitHub Actions** → **Auto-Distribute Betsson Cameroon** → **Run workflow**

Options:
- **Environment**: `staging` or `production`
- **Release Notes**: Optional custom message

**Note**: CI/CD always keeps the same build number (uses `keep_version_distribute_*`)

---

## 🛠️ Available Fastlane Lanes

### 🆕 Default Distribution Lanes (Increment Build)

#### `distribute_staging`
**Use when**: Normal release to staging (most common)

```bash
fastlane distribute_staging
fastlane distribute_staging release_notes:"Added live chat feature"
```

**Flow**: Prompts for build++ → Registers devices → Builds → Distributes (NEW build #)

#### `distribute_production`
**Use when**: Normal release to production

```bash
fastlane distribute_production
```

**Flow**: Prompts for build++ → Registers devices → Builds → Distributes (NEW build #)

#### `distribute_all`
**Use when**: Release to BOTH staging and production

```bash
fastlane distribute_all
```

**Flow**: Prompts for build++ once → Distributes to both environments

---

### 📱 Keep Version Lanes (Same Build Number)

#### `keep_version_distribute_staging`
**Use when**: Adding devices without new app version

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

### 🔧 Utility Lanes

#### `register_new_devices`
**Use when**: Only register devices, don't build/distribute

```bash
fastlane register_new_devices app_scheme:"BetssonCM Staging"
```

**Flow**: Reads devices.txt → Registers with Apple → Updates profiles (NO build)

#### `fetch_firebase_devices`
**Use when**: Download all Firebase testers as reference

```bash
fastlane fetch_firebase_devices

# Creates: fastlane/firebase_devices.txt
# Use to see all devices across projects, then manually copy to devices.txt
```

#### `version_bump`
**Use when**: Manually increment build number (without distributing)

```bash
fastlane version_bump
# Prompts: Enter new build number, '+' to increment, or enter to keep
```

---

## 📝 devices.txt Format

Location: `BetssonCameroonApp/fastlane/devices.txt`

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

## ⚙️ Setup Requirements

### 1. Local Environment (.env file)

Create `BetssonCameroonApp/fastlane/.env`:

```bash
# Match Configuration
MATCH_GIT_URL=git@github.com:gomagaming/FastlaneAppleCertificates.git
MATCH_PASSWORD=your_match_encryption_password

# Firebase Distribution
FIREBASE_CLI_TOKEN=your_firebase_cli_token
FIREBASE_PROJECT_NUMBER=123456789  # Find in Firebase Console > Project Settings
FIREBASE_DISTRIBUTION_GROUPS=ios-internal
FIREBASE_DISTRIBUTION_TESTERS=tester@example.com

# Apple Developer Account (GOMA account hosts Betsson Cameroon)
GOMA_APPLE_ID=apple@gomagaming.com
GOMA_TEAM_ID=422GNXXZJR

# Firebase App IDs (find in Firebase Console > App Settings)
BETSSONCM_STG_FIREBASE_APP_ID=1:123456:ios:abc123
BETSSONCM_PROD_FIREBASE_APP_ID=1:123456:ios:xyz789
```

### 2. GitHub Secrets (for CI/CD)

Repository Settings → Secrets and Variables → Actions:

- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_GIT_PRIVATE_KEY` (SSH private key for certificates repo)
- `FIREBASE_CLI_TOKEN`
- `FIREBASE_PROJECT_NUMBER`
- `FIREBASE_DISTRIBUTION_GROUPS`
- `FIREBASE_DISTRIBUTION_TESTERS`
- `GOMA_APPLE_ID`
- `GOMA_TEAM_ID`
- `BETSSONCM_STG_FIREBASE_APP_ID`
- `BETSSONCM_PROD_FIREBASE_APP_ID`

---

## 🔍 Understanding Build Numbers

### Default: New Build Number

When using `distribute_*`:
- **Build number**: 1234 → 1235 (incremented)
- **What changed**: App code, features, fixes
- **Devices**: Automatically registered from devices.txt
- **Firebase**: Creates new build 1235 alongside old builds

### Keep Version: Same Build Number

When using `keep_version_distribute_*`:
- **Build number**: 1234 (stays same)
- **What changed**: Provisioning profile (new devices added)
- **App code**: No changes
- **Firebase**: Replaces existing build 1234 with new profile

---

## 🔄 Device Registration Flow

**Every distribution lane follows this pattern:**

```
1. Check devices.txt exists
2. Read all device UDIDs
3. Register devices with Apple Developer Portal
4. Update provisioning profiles (force_for_new_devices: true)
5. Build app with updated profile
6. Distribute to Firebase
```

**This happens automatically** - you never need to worry about forgetting device registration!

---

## 🐛 Troubleshooting

### "No devices.txt file found"

```bash
# Create the file
cd BetssonCameroonApp/fastlane
echo -e "Device ID\tDevice Name" > devices.txt
# Then add your devices
```

### "Device already registered"

✅ **This is normal!** Fastlane handles duplicates gracefully. Provisioning profiles will still be updated with all devices.

### Empty devices.txt

If `devices.txt` is empty or has no valid entries:
- ✅ Lane continues normally
- ⚠️ No new devices registered
- ✅ Build proceeds with existing provisioning profile

### Firebase Project Number

Find it: **Firebase Console** → **Project Settings** → **General** → **Project number** (numeric value like 123456789)

### Match SSH Key for CI/CD

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "github-actions@gomagaming.com" -f ~/.ssh/match_deploy_key

# Add public key to certificates repo:
# GitHub.com → FastlaneAppleCertificates repo → Settings → Deploy keys
cat ~/.ssh/match_deploy_key.pub

# Add private key to GitHub secret MATCH_GIT_PRIVATE_KEY:
cat ~/.ssh/match_deploy_key
```

### Build Fails in CI

1. Check logs: GitHub Actions → Failed workflow → View logs
2. Check local: `BetssonCameroonApp/fastlane/logs/`
3. Verify all secrets are set correctly
4. Test locally first: `fastlane keep_version_distribute_staging`

---

## 📊 Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    WHICH WORKFLOW?                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🆕 Normal release? (default)                               │
│      └─> distribute_staging                                 │
│          ├─ Prompts for build++                            │
│          ├─ Registers devices automatically                │
│          └─ Builds + distributes                           │
│                                                             │
│  📱 Only adding devices?                                    │
│      └─> keep_version_distribute_staging                   │
│          ├─ NO build increment                             │
│          ├─ Registers devices automatically                │
│          └─ Builds + distributes (same build #)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│              distribute_staging Flow                      │
│           (Default - increments build)                    │
└───────────────────────────────────────────────────────────┘
           │
           ├─> Prompt for build number increment
           │
           ├─> Update build number in Xcode project
           │
           ├─> Read devices.txt
           │
           ├─> Register devices (Apple Developer Portal)
           │
           ├─> Update provisioning profiles (force_for_new_devices)
           │
           ├─> Build app (NEW build #, updated profile)
           │
           └─> Distribute to Firebase App Distribution

┌───────────────────────────────────────────────────────────┐
│       keep_version_distribute_staging Flow                │
│         (Keep version - same build)                       │
└───────────────────────────────────────────────────────────┘
           │
           ├─> Read devices.txt
           │
           ├─> Register devices (Apple Developer Portal)
           │
           ├─> Update provisioning profiles (force_for_new_devices)
           │
           ├─> Build app (SAME build #, updated profile)
           │
           └─> Distribute to Firebase App Distribution
```

---

## 💡 Best Practices

1. **Default to `distribute_*`**: Use for normal releases (most common)
2. **Use `keep_version_*` sparingly**: Only when adding devices without code changes
3. **Test staging first**: Always use staging lanes before production
4. **Keep devices.txt clean**: Remove inactive testers periodically
5. **Commit devices.txt**: Track device list in git for transparency
6. **Use release notes**: Always provide meaningful release notes
7. **Trust automation**: All lanes check devices.txt automatically - no manual steps needed

---

## 🚀 Quick Command Reference

```bash
# Most common: Normal release (increments build)
fastlane distribute_staging

# Adding devices only (keeps same build)
fastlane keep_version_distribute_staging

# Deploy to production
fastlane distribute_production

# Deploy to both environments
fastlane distribute_all

# Utility: Fetch all Firebase devices as reference
fastlane fetch_firebase_devices

# Utility: Only register devices (no build)
fastlane register_new_devices app_scheme:"BetssonCM Staging"

# Utility: Manual version bump (prompts for build number)
fastlane version_bump

# Debug: Verify environment
fastlane test

# List all available lanes
fastlane lanes
```

---

## 🆘 Support

**Issues?**
1. Check Fastlane logs: `BetssonCameroonApp/fastlane/logs/`
2. Check GitHub Actions logs (for CI/CD runs)
3. Verify `.env` file has all required variables
4. Ensure `devices.txt` format is correct (tab-separated)
5. Test locally before using CI/CD

**Key Insight**: All distribution lanes automatically handle device registration - you can't forget this step!
