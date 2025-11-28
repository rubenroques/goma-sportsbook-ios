# Tag-Based Dual Release Distribution

This document explains how to use the automated tag-based release system for distributing iOS builds to Firebase App Distribution.

## Overview

The tag-based release system automates the build and distribution process with **dual release** - each tag deploys to BOTH staging AND production automatically.

**Workflow:**
1. Set the version in Xcode
2. Commit and push
3. Create and push a tag
4. The system builds and distributes to **both** environments automatically

The GitHub Action validates that your Xcode project version matches the tag, then builds and distributes to Firebase for both staging and production.

---

## Tag Format

Tags follow this format:

```
CLIENT[-_]v?VERSION(BUILD)
```

| Component | Description | Examples |
|-----------|-------------|----------|
| `CLIENT` | Client identifier (case-insensitive) | `BCM`, `BFR`, `bcm`, `bfr` |
| `SEPARATOR` | Hyphen or underscore | `-` or `_` |
| `v` | Optional version prefix | `v` (optional) |
| `VERSION` | Marketing version (X.Y or X.Y.Z) | `2.1`, `2.1.3` |
| `BUILD` | Build number in parentheses | `(21309)`, `(100)` |

### Supported Formats

| Format | Example | Works? |
|--------|---------|--------|
| `CLIENT-VERSION(BUILD)` | `BCM-0.3.0(3001)` | Yes |
| `CLIENT-vVERSION(BUILD)` | `BCM-v0.3.0(3001)` | Yes |
| `CLIENT_VERSION(BUILD)` | `BCM_0.3.0(3001)` | Yes |
| `CLIENT_vVERSION(BUILD)` | `BCM_v0.3.0(3001)` | Yes |
| Case insensitive | `bcm-0.3.0(3001)` | Yes |
| Two-part version | `BCM-0.3(3001)` | Yes |
| Three-part version | `BCM-0.3.0(3001)` | Yes |

### NOT Supported Formats

| Format | Example | Why |
|--------|---------|-----|
| No parentheses | `BCM-0.3.0-3001` | Build must be in `(BUILD)` format |
| Spaces | `BCM - 0.3.0(3001)` | No spaces allowed |
| No build number | `BCM-0.3.0` | Build number is required |
| Environment in tag | `BCM-Stg-0.3.0(3001)` | Old format, no longer supported |

---

## Supported Clients

| Client ID | Name | Dual Release Behavior |
|-----------|------|----------------------|
| `BCM` | Betsson Cameroon | Staging + Production |
| `BFR` | Betsson France | UAT + Production |

### Release Details

| Client | Step 1 | Step 2 |
|--------|--------|--------|
| BCM | Staging (`BetssonCM Staging` scheme) | Production (`BetssonCM Prod` scheme) |
| BFR | UAT (`Betsson UAT` scheme) | Production (`Betsson PROD` scheme) |

---

## Step-by-Step Release Process

### Step 1: Update Version in Xcode

Before creating a tag, you **must** update the version in the Xcode project:

1. Open the project in Xcode
2. Select the target (e.g., `BetssonCameroonApp`)
3. Go to **General** tab
4. Update:
   - **Version** (MARKETING_VERSION): e.g., `2.1.3`
   - **Build** (CURRENT_PROJECT_VERSION): e.g., `21309`

Alternatively, use fastlane locally:
```bash
cd BetssonCameroonApp
bundle exec fastlane marketing_version_bump  # Update version
bundle exec fastlane version_bump            # Update build number
```

### Step 2: Commit and Push

Commit the version change:

```bash
git add .
git commit -m "Bump version to 2.1.3 (21309)"
git push origin betsson-cm
```

### Step 3: Create and Push Tag

Create the tag matching your version:

```bash
# BCM Release (deploys to BOTH Staging + Production)
git tag BCM-2.1.3(21309)
git push origin BCM-2.1.3(21309)

# BFR Release (deploys to BOTH UAT + Production)
git tag BFR-1.5.0(15000)
git push origin BFR-1.5.0(15000)
```

### Step 4: Monitor the Workflow

1. Go to **GitHub Actions** in the repository
2. Find the "Tag-Based Dual Release Distribution" workflow
3. Monitor the progress (builds staging first, then production)
4. On success, a Discord notification is sent

---

## What Happens Automatically

When you push a tag, the workflow:

1. **Parses the tag** - Extracts client, version, and build
2. **Reads configuration** - Loads settings from `.github/tag-config.yml`
3. **Checks out the release branch** - Based on client's `release_branch` config
4. **Validates version** - Ensures Xcode project matches the tag (fails if mismatch)
5. **Reads release notes** - From `CHANGELOG.yml` (version + build match)
6. **Registers devices** - From `devices.csv` (BCM) or `devices.txt` (BFR)
7. **Builds Staging** - First build using staging scheme
8. **Distributes to Firebase (Staging)** - Uploads to Firebase App Distribution
9. **Builds Production** - Second build using production scheme
10. **Distributes to Firebase (Production)** - Uploads to Firebase App Distribution
11. **Sends notification** - Posts to Discord with dual release status

---

## Version Validation

The workflow **validates** that your Xcode project version matches the tag. If they don't match, the workflow fails with a clear error:

```
::error::Version mismatch! Tag has 2.1.3 but Xcode project has 2.1.2
Please update the Xcode project version before tagging.
```

This prevents accidental releases with wrong version numbers.

### Fixing a Version Mismatch

If you see a version mismatch error:

1. Update the Xcode project to match the tag
2. Commit and push
3. Delete the tag locally and remotely:
   ```bash
   git tag -d BCM-2.1.3(21309)
   git push origin :refs/tags/BCM-2.1.3(21309)
   ```
4. Recreate and push the tag:
   ```bash
   git tag BCM-2.1.3(21309)
   git push origin BCM-2.1.3(21309)
   ```

---

## Tag Examples

### BCM (Betsson Cameroon)

```bash
# All deploy to BOTH Staging + Production
git tag BCM-2.0.0(200)
git tag BCM-v2.0.1(201)
git tag bcm-2.0.2(202)
git tag bcm_v2.0.3(203)
```

### BFR (Betsson France)

```bash
# All deploy to BOTH UAT + Production
git tag BFR-1.5.0(15000)
git tag BFR-v1.5.1(15001)
git tag bfr-1.5.2(15002)
```

---

## Release Notes (CHANGELOG.yml)

Release notes are stored in YAML files and matched by version + build:

**Format:**
```yaml
releases:
  - version: "2.1.3"
    build: 21309
    date: "2025-11-26"
    notes:
      - "Added live score updates"
      - "Fixed crash in match details"
      - "Performance improvements"
```

**Locations:**
| Client | File Location |
|--------|---------------|
| BCM | `BetssonCameroonApp/CHANGELOG.yml` |
| BFR | `BetssonFranceApp/CHANGELOG.yml` |

**Note:** The same release notes are used for both environments in a dual release.

If no matching entry is found, generic notes are used: `"Build 21309 - Version 2.1.3"`

---

## Device Registration

Devices are automatically registered from:

| Client | File Location |
|--------|---------------|
| BCM | `BetssonCameroonApp/fastlane/devices.csv` |
| BFR | `BetssonFranceApp/fastlane/devices.txt` |

### Adding New Devices

1. Edit the devices file (tab-separated format):
   ```
   Device ID	Device Name
   00008030-001234567890001E	iPhone 15 Pro - John Doe
   00008101-001234567890002E	iPhone 14 - Jane Smith
   ```

2. Commit and push to the appropriate branch
3. The next tag-based release will include the new devices

---

## Troubleshooting

### Tag Not Triggering Workflow

- Ensure the tag format is correct (see examples above)
- Old format `BCM-Stg-...` is no longer supported
- Check that the tag was pushed: `git ls-remote --tags origin`
- Verify the workflow file exists in `.github/workflows/tag-release.yml`

### Version Mismatch Error

- Update Xcode project version to match the tag
- Commit, push, delete tag, recreate tag (see "Fixing a Version Mismatch")

### Build Fails

- Check the GitHub Actions logs for detailed error messages
- Common issues:
  - Missing secrets (check repository secrets)
  - Provisioning profile issues (run match locally first)
  - Code signing errors (verify certificates are valid)

### Staging Succeeds But Production Fails

- Check production-specific secrets are configured
- Verify production scheme builds correctly locally
- Check production Firebase App ID is correct

### Firebase Upload Fails

- Verify `FIREBASE_CLI_TOKEN` secret is set and valid
- Check Firebase App ID is correct for the environment
- Ensure Firebase App Distribution groups exist

### Discord Notification Not Received

- Verify `DISCORD_WEBHOOK_URL` secret is set
- Check webhook URL is valid and channel still exists

---

## Quick Reference

### Create a Dual Release

```bash
# 1. Update version in Xcode (or use fastlane)
# 2. Commit
git commit -am "Bump to 2.1.3(21309)"
git push

# 3. Tag and push
git tag BCM-2.1.3(21309)
git push origin BCM-2.1.3(21309)

# Result: Deploys to BOTH Staging AND Production
```

### Delete a Tag (if needed)

```bash
# Local
git tag -d BCM-2.1.3(21309)

# Remote
git push origin :refs/tags/BCM-2.1.3(21309)
```

### List Tags

```bash
# Local tags
git tag -l "BCM-*"

# Remote tags
git ls-remote --tags origin | grep BCM
```

---

## Configuration

The system is configured via `.github/tag-config.yml`. This file maps:
- Client IDs to directories, projects, and targets
- Release branches for version validation
- Staging and production schemes
- Discord notification colors

Modify this file to add new clients or change configuration.

---

## Migration from Environment-Specific Tags

If you were using the old format with environment in the tag:

| Old Format (No Longer Supported) | New Format (Dual Release) |
|----------------------------------|---------------------------|
| `BCM-Stg-2.1.3(21309)` | `BCM-2.1.3(21309)` |
| `BCM-Prod-2.1.3(21309)` | `BCM-2.1.3(21309)` |
| `BFR-Stg-1.5.0(15000)` | `BFR-1.5.0(15000)` |

Old tags with environment (`Stg`, `Prod`) will be **rejected** by the new workflow.
