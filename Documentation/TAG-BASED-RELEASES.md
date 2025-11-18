# Tag-Based Release System

## Overview

This document describes the automated tag-based release system for distributing iOS builds to Firebase App Distribution. When developers push a properly formatted tag to GitHub, the system automatically:

1. ✅ Parses the tag to extract client, environment, version, and build information
2. ✅ Checks out the correct branch based on configuration
3. ✅ Reads release notes from CHANGELOG.yml
4. ✅ Sets the version in the Xcode project
5. ✅ Builds and distributes to Firebase
6. ✅ Commits the version change back to the repository
7. ✅ Sends a Discord notification with release details

---

## Quick Start Guide

### 1. Update CHANGELOG.yml

Add an entry for your release:

```yaml
# BetssonCameroonApp/CHANGELOG.yml
releases:
  - version: "2.1.3"
    build: 21309
    environment: staging
    date: "2025-11-18"
    notes:
      - "Fixed live match score updates"
      - "Improved betting slip performance"
      - "Updated French translations"
```

### 2. Create and Push Tag

```bash
# For Betsson Cameroon Staging
git tag BCM-Stg-2.1.3(21309)
git push origin BCM-Stg-2.1.3(21309)

# For Betsson Cameroon Production
git tag BCM-Prod-2.1.3(21309)
git push origin BCM-Prod-2.1.3(21309)

# For Betsson France Staging
git tag BFR-Stg-1.5.2(15200)
git push origin BFR-Stg-1.5.2(15200)

# For Betsson France Production
git tag BFR-Prod-1.5.2(15200)
git push origin BFR-Prod-1.5.2(15200)
```

### 3. Monitor Progress

- Watch the GitHub Actions workflow in the "Actions" tab
- Receive Discord notification when complete
- Check Firebase App Distribution for the build

---

## Tag Format

### Standard Format

```
CLIENT-ENVIRONMENT-VERSION(BUILD)
```

### Components

| Component | Description | Examples |
|-----------|-------------|----------|
| **CLIENT** | Client code (case-insensitive) | `BCM`, `bcm`, `Bcm` (Betsson Cameroon)<br>`BFR`, `bfr`, `Bfr` (Betsson France) |
| **ENVIRONMENT** | Deployment environment | `Stg`, `Stage`, `Staging` → staging<br>`Prod`, `Production` → production |
| **VERSION** | Marketing version (X.Y.Z) | `2.1.3`, `1.5.2` |
| **BUILD** | Build number | `21309`, `15200` |

### Valid Tag Examples

All of these formats work (case-insensitive):

```bash
# Betsson Cameroon
BCM-Stg-2.1.3(21309)
bcm-stage-2.1.3(21309)
BCM-STAGING-2.1.3(21309)
Bcm-Prod-2.1.3(21309)
bcm-production-2.1.3(21309)

# Betsson France
BFR-Stg-1.5.2(15200)
bfr-stage-1.5.2(15200)
BFR-Prod-1.5.2(15200)
bfr-production-1.5.2(15200)
```

### Invalid Tag Examples

```bash
# ❌ Missing build number
BCM-Stg-2.1.3

# ❌ Wrong separator
BCM-Stg-2.1.3-21309

# ❌ Wrong client code
BETSSON-Stg-2.1.3(21309)

# ❌ Missing version
BCM-Stg-(21309)
```

---

## Configuration Files

### `.github/tag-config.yml`

Maps clients and environments to build configuration:

```yaml
clients:
  BCM:
    name: "Betsson Cameroon"
    directory: "BetssonCameroonApp"
    project: "BetssonCameroonApp.xcodeproj"
    target: "BetssonCameroonApp"
    changelog: "BetssonCameroonApp/CHANGELOG.yml"

    environments:
      staging:
        branch: "betsson-cm"              # Which branch to checkout
        scheme: "BetssonCM Staging"       # Xcode scheme to build
        fastlane_lane: "keep_version_distribute_staging"
        discord_color: 3447003            # Blue

      production:
        branch: "main"
        scheme: "BetssonCM Prod"
        fastlane_lane: "keep_version_distribute_production"
        discord_color: 3066993            # Green
```

**Key Points:**
- Each client has its own directory, project file, and changelog
- Each environment maps to a specific branch
- Staging and production can build from different branches

---

## CHANGELOG.yml Format

Each client has its own CHANGELOG.yml file:
- `BetssonCameroonApp/CHANGELOG.yml`
- `BetssonFranceApp/CHANGELOG.yml`

### Structure

```yaml
releases:
  - version: "2.1.3"          # Must match tag version
    build: 21309              # Must match tag build
    environment: staging      # Must match tag environment
    date: "2025-11-18"        # Release date
    notes:
      - "Feature or fix description"
      - "Another change"
      - "Bug fix details"
```

### Matching Logic

When tag `BCM-Stg-2.1.3(21309)` is pushed:

1. System reads `BetssonCameroonApp/CHANGELOG.yml`
2. Searches for entry with:
   - `version: "2.1.3"`
   - `build: 21309`
   - `environment: "staging"`
3. If found → uses release notes
4. If not found → uses generic notes: "Build 21309 - Version 2.1.3"

### Best Practices

✅ **DO:**
- Add CHANGELOG entry BEFORE creating the tag
- Use clear, concise bullet points
- Keep notes under 10 items for readability
- Include ticket/issue references if applicable

❌ **DON'T:**
- Use extremely long notes (Discord has character limits)
- Include sensitive information
- Use special characters that need escaping (", \, etc.)

---

## Workflow Process

### Step-by-Step

```
Developer pushes tag: BCM-Stg-2.1.3(21309)
          ↓
GitHub Actions triggers
          ↓
Parse tag → Client: BCM, Env: staging, Version: 2.1.3, Build: 21309
          ↓
Read tag-config.yml → Branch: betsson-cm, Scheme: BetssonCM Staging
          ↓
Checkout betsson-cm branch
          ↓
Read BetssonCameroonApp/CHANGELOG.yml → Extract release notes
          ↓
Set MARKETING_VERSION=2.1.3, CURRENT_PROJECT_VERSION=21309
          ↓
Run fastlane keep_version_distribute_staging
          ↓
Build → Upload to Firebase
          ↓
Commit version change → Push to betsson-cm
          ↓
Send Discord notification
          ↓
✅ Complete
```

### GitHub Actions Workflow

File: `.github/workflows/tag-release.yml`

**Triggers:**
- Push tags matching: `BCM-**`, `bcm-**`, `Bcm-**`, `BFR-**`, `bfr-**`, `Bfr-**`

**Key Steps:**
1. Parse tag and validate format
2. Read configuration from `tag-config.yml`
3. Checkout target branch
4. Read changelog and extract notes
5. Setup Ruby, certificates, keychain
6. Set version in Xcode project
7. Build and distribute via fastlane
8. Commit version changes
9. Send Discord notification
10. Cleanup (remove keys, keychains)

---

## Branch Strategy

### Betsson Cameroon (BCM)

| Environment | Branch | Purpose |
|-------------|--------|---------|
| **Staging** | `betsson-cm` | Development branch for Cameroon features |
| **Production** | `main` | Stable production branch |

### Betsson France (BFR)

| Environment | Branch | Purpose |
|-------------|--------|---------|
| **Staging** | `betsson-france-dev` | Development branch for France features |
| **Production** | `main` | Stable production branch |

### Why This Matters

When you tag `BCM-Stg-2.1.3(21309)`:
- Workflow checks out `betsson-cm` branch
- Builds from the latest code on `betsson-cm`
- Commits version change back to `betsson-cm`

When you tag `BCM-Prod-2.1.3(21309)`:
- Workflow checks out `main` branch
- Builds from the latest code on `main`
- Commits version change back to `main`

**This allows different code bases for staging vs production!**

---

## Version Management

### How Versions Are Set

1. **Before Build:** Xcode project has current version (e.g., 0.2.0 build 2099)
2. **Tag Created:** Developer creates tag with new version (e.g., 2.1.3 build 21309)
3. **Workflow Runs:** Sets Xcode project to match tag version
4. **Build Executes:** App is compiled with tag version
5. **Commit Created:** Version change is committed back to branch

### Version Fields

| Field | Xcode Name | Example | Location |
|-------|------------|---------|----------|
| Marketing Version | `MARKETING_VERSION` | `2.1.3` | User-facing version |
| Build Number | `CURRENT_PROJECT_VERSION` | `21309` | Internal build number |

### Version Bump Strategy

```bash
# Staging: Test new features
git tag BCM-Stg-2.1.3(21309)

# After QA approval, same version to production
git tag BCM-Prod-2.1.3(21309)

# Or increment build for production
git tag BCM-Prod-2.1.3(21310)
```

---

## Discord Notifications

### What Gets Sent

When a build completes, Discord receives:

```
🚀 Betsson Cameroon Staging Release - v2.1.3 (21309)

Client: Betsson Cameroon
Environment: Staging
Version: 2.1.3 (21309)
Tag: BCM-Stg-2.1.3(21309)

Release Notes:
• Fixed live match score updates
• Improved betting slip performance
• Updated French translations

Build Status: ✅ Successfully distributed to Firebase
```

### Color Coding

| Environment | Color | Value |
|-------------|-------|-------|
| Staging | Blue | 3447003 |
| Production | Green | 3066993 |
| Failed | Red | 15158332 |

### Setup

Requires `DISCORD_WEBHOOK_URL` secret in GitHub repository settings.

---

## Troubleshooting

### Tag Format Error

**Error:** `❌ Invalid tag format`

**Solution:** Ensure tag follows format: `CLIENT-ENV-VERSION(BUILD)`

```bash
# ✅ Correct
BCM-Stg-2.1.3(21309)

# ❌ Wrong
BCM-Stg-2.1.3-21309
```

### Configuration Not Found

**Error:** `❌ Configuration not found for BCM/staging in tag-config.yml`

**Solution:** Check `.github/tag-config.yml` has entry for client and environment

### Changelog Not Found

**Warning:** `⚠️  No matching changelog entry found`

**Impact:** Uses generic notes: "Build 21309 - Version 2.1.3"

**Solution:** Add entry to CHANGELOG.yml before tagging

### Build Failed

**Check:**
1. GitHub Actions logs in "Actions" tab
2. Fastlane logs (uploaded as artifacts on failure)
3. Discord notification shows error details

### Version Already Exists

If you need to retag:

```bash
# Delete local tag
git tag -d BCM-Stg-2.1.3(21309)

# Delete remote tag
git push --delete origin BCM-Stg-2.1.3(21309)

# Create new tag
git tag BCM-Stg-2.1.3(21309)
git push origin BCM-Stg-2.1.3(21309)
```

---

## Advanced Usage

### Testing Tag Parsing Locally

```bash
# Clone the repo
git clone <repo-url>
cd sportsbook-ios

# Test tag parsing
TAG="BCM-Stg-2.1.3(21309)"

if [[ $TAG =~ ^([A-Za-z]+)-(Stg|Stage|Staging|Prod|Production)-([0-9.]+)\(([0-9]+)\)$ ]]; then
  echo "Client: ${BASH_REMATCH[1]^^}"
  echo "Environment: ${BASH_REMATCH[2],,}"
  echo "Version: ${BASH_REMATCH[3]}"
  echo "Build: ${BASH_REMATCH[4]}"
else
  echo "Invalid tag format"
fi
```

### Reading CHANGELOG.yml Locally

Requires `yq` (YAML processor):

```bash
# Install yq
brew install yq

# Read changelog
VERSION="2.1.3"
BUILD="21309"
ENV="staging"

yq e ".releases[] | select(.version == \"$VERSION\" and .build == $BUILD and .environment == \"$ENV\")" BetssonCameroonApp/CHANGELOG.yml
```

### Manual Version Setting

If you need to set version manually without tagging:

```bash
cd BetssonCameroonApp

bundle exec fastlane run increment_version_number_in_xcodeproj \
  version_number:"2.1.3" \
  xcodeproj:"BetssonCameroonApp.xcodeproj" \
  target:"BetssonCameroonApp"

bundle exec fastlane run increment_build_number_in_xcodeproj \
  build_number:"21309" \
  xcodeproj:"BetssonCameroonApp.xcodeproj" \
  target:"BetssonCameroonApp"
```

---

## GitHub Secrets Required

The workflow requires these secrets to be configured in repository settings:

| Secret Name | Description |
|-------------|-------------|
| `APP_STORE_CONNECT_API_KEY_CONTENT` | App Store Connect API key (.p8 file content) |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | API Issuer ID |
| `MATCH_GIT_URL` | Git URL for certificates repository |
| `MATCH_PASSWORD` | Password for certificates encryption |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key for certificates repo |
| `FIREBASE_CLI_TOKEN` | Firebase CLI token |
| `FIREBASE_PROJECT_NUMBER` | Firebase project number |
| `GOMA_TEAM_ID` | Apple Developer Team ID |
| `BETSSONCM_STG_FIREBASE_APP_ID` | Firebase App ID for BCM Staging |
| `BETSSONCM_PROD_FIREBASE_APP_ID` | Firebase App ID for BCM Production |
| `DISCORD_WEBHOOK_URL` | Discord webhook for notifications |

---

## FAQ

### Q: Can I use the same version for staging and production?

**A:** Yes! You can tag both with the same version:

```bash
git tag BCM-Stg-2.1.3(21309)
git tag BCM-Prod-2.1.3(21309)
```

They'll build from different branches (`betsson-cm` vs `main`) as configured.

### Q: What if I forget to update CHANGELOG.yml?

**A:** The workflow will still run successfully but use generic release notes: "Build 21309 - Version 2.1.3"

### Q: Can I trigger a release without tagging?

**A:** No, this system is specifically tag-triggered. For manual releases, use the existing `auto-distribute-cameroon.yml` workflow or run fastlane locally.

### Q: How do I add a new client?

**A:** Add entry to `.github/tag-config.yml`:

```yaml
clients:
  NEW:
    name: "New Client"
    directory: "NewClientApp"
    # ... rest of configuration
```

Then create `NewClientApp/CHANGELOG.yml`.

### Q: Can I customize Discord messages?

**A:** Yes, edit the "Send Discord notification" step in `.github/workflows/tag-release.yml`

### Q: What happens if the build fails?

**A:**
- Workflow stops
- Discord notification sent with ❌ status
- Fastlane logs uploaded as artifacts
- No version commit is made
- No Firebase distribution occurs

---

## Best Practices

### ✅ DO

1. **Update CHANGELOG.yml first**, then create tag
2. **Use meaningful release notes** that help QA and stakeholders
3. **Follow semantic versioning** (major.minor.patch)
4. **Test in staging** before tagging production
5. **Keep build numbers sequential** and incrementing
6. **Tag from the correct branch** (ensure your branch is up to date)

### ❌ DON'T

1. **Don't tag without CHANGELOG entry** (you'll get generic notes)
2. **Don't reuse build numbers** (creates confusion)
3. **Don't skip staging** (always test before production)
4. **Don't tag uncommitted changes** (tag should represent exact code)
5. **Don't use special characters** in release notes (breaks Discord formatting)

---

## Support

For issues or questions:
- Check GitHub Actions logs
- Review this documentation
- Check Discord notifications for error details
- Consult team lead or DevOps

---

## Changelog for This System

### v1.0.0 - 2025-11-18
- Initial implementation of tag-based release system
- Support for BCM and BFR clients
- Automated CHANGELOG.yml reading
- Discord notifications
- Version management automation
