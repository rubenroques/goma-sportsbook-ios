# CI/CD Guide

This document describes the GitHub Actions CI/CD pipelines for the iOS sportsbook workspace.

## Workflows Overview

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| **Claude Code Review** | `claude-code-review.yml` | Every PR (auto) | Automated code review |
| **Claude Interactive** | `claude.yml` | `@claude` mention | On-demand AI assistance |
| **Manual Distribution** | `manual-distribute.yml` | Manual | Build and distribute to TestFlight/Firebase |
| **Tag-Based Release** | `tag-release.yml` | Git tag push | Full dual-environment releases |

---

## Manual Distribution Workflow

The primary workflow for distributing builds to testers.

### Inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `client` | choice | required | `BCM - Betsson Cameroon` or `BFR - Betsson France Legacy` |
| `deploy_stg` | boolean | false | Deploy to STG (BCM only) |
| `deploy_uat` | boolean | true | Deploy to UAT |
| `deploy_prod` | boolean | false | Deploy to PROD |
| `auto_increment` | boolean | false | Auto-increment build number for each environment |
| `new_devices` | text | empty | Devices to register (UUID,Name per line) |
| `confirm_prod` | string | empty | Type "PROD" to confirm production deployment |

### Features

- **Multi-environment deployment** - Select any combination of STG/UAT/PROD
- **Auto-increment builds** - Each environment gets its own build number (4001 → 4002 → 4003)
- **Device registration** - Paste UUID,Name pairs, automatically formatted for each client
- **Single commit at end** - `CI: Manual distribution - Build 4001 → 4003, +2 device(s) [skip ci]`
- **PROD confirmation** - Must type "PROD" to deploy to production
- **Validation** - Prevents BFR+STG (invalid), requires at least one environment
- **Discord notifications** - Success and failure to personal webhook

### Environment Availability

| Client | STG | UAT | PROD |
|--------|-----|-----|------|
| BCM (Betsson Cameroon) | Yes | Yes | No* |
| BFR (Betsson France Legacy) | No | Yes | Yes |

*BCM PROD uses client's Apple account, not available via this workflow.

### Device Input Format

```
00008030-001234567890,iPhone 15 Pro - John
00008140-000A4C501E07801C,iPhone 16 Pro - Jane
```

Each line: `UUID,Device Name`

---

## Tag-Based Release Workflow

Triggered by git tags for formal releases.

### Tag Format

```
CLIENT-vVERSION(BUILD)
```

Examples:
- `bcm-v0.3.8(3801)` - Betsson Cameroon v0.3.8, build 3801
- `BFR-v1.5.0(15000)` - Betsson France v1.5.0, build 15000

### Features

- Validates tag version matches Xcode project
- Extracts release notes from `CHANGELOG.yml`
- Builds and distributes to configured environments
- Updates Jira tickets with deployment info
- Sends Discord notification to team channel

---

## GitHub Secrets

### New Secret (for `manual-distribute.yml`)

| Secret | Description | How to Get |
|--------|-------------|------------|
| `DISCORD_PERSONAL_RELEASE_WEBHOOK` | Personal Discord webhook for success/failure notifications | Discord → Channel Settings → Integrations → Webhooks → Copy URL |

### App Store Connect (Apple API)

| Secret | Description |
|--------|-------------|
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID (e.g., `7NC93JSN42`) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Contents of the `.p8` API key file |

### Code Signing (Match)

| Secret | Description |
|--------|-------------|
| `MATCH_GIT_URL` | Git URL for certificates repo (Goma team) |
| `MATCH_PASSWORD` | Password to decrypt Match certificates |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key for Match repo access |
| `GOMA_TEAM_ID` | Apple Team ID for Goma |

### BCM - Betsson Cameroon (Firebase)

| Secret | Description |
|--------|-------------|
| `BETSSONCM_STG_FIREBASE_APP_ID` | Firebase App ID for STG |
| `BETSSONCM_UAT_FIREBASE_APP_ID` | Firebase App ID for UAT |
| `BETSSONCM_PROD_FIREBASE_APP_ID` | Firebase App ID for PROD |
| `FIREBASE_CLI_TOKEN` | Firebase CLI token (Goma account) |
| `FIREBASE_PROJECT_NUMBER` | Firebase project number |

### BFR - Betsson France Legacy

| Secret | Description |
|--------|-------------|
| `BFR_PROD_TEAM_ID` | Apple Team ID for Betsson France production (`QN2DYX5K4M`) |
| `BFR_PROD_API_KEY_ID` | App Store Connect API Key ID (Betsson France team) |
| `BFR_PROD_API_ISSUER_ID` | App Store Connect API Issuer ID (Betsson France team) |
| `BFR_PROD_API_KEY_CONTENT` | Contents of the `.p8` API key file (Betsson France team) |
| `BFR_UAT_FIREBASE_APP_ID` | Firebase App ID for BFR UAT (Team Firebase) |
| `BFR_PROD_FIREBASE_APP_ID` | Firebase App ID for BFR PROD (Client Firebase) |
| `BFR_PROD_FIREBASE_CLI_TOKEN` | Firebase CLI token for BFR PROD (Client Firebase) |

> **Note:** BFR uses the same Match repository as BCM (`MATCH_GIT_URL`), just different branches:
> - UAT: `goma` branch (Team ID: `422GNXXZJR`) - uses Goma API Key
> - PROD: `betsson-france` branch (Team ID: `QN2DYX5K4M`) - uses BFR PROD API Key

### Jira Integration

| Secret | Description |
|--------|-------------|
| `JIRA_EMAIL` | Jira account email |
| `JIRA_API_TOKEN` | Jira API token |
| `JIRA_BASE_URL` | Jira instance URL (e.g., `https://yourcompany.atlassian.net`) |

### Discord Notifications

| Secret | Description |
|--------|-------------|
| `DISCORD_TEAM_RELEASE_WEBHOOK` | Team Discord webhook for formal release notifications |
| `DISCORD_PERSONAL_RELEASE_WEBHOOK` | Personal Discord webhook for manual distribution |

### Claude Code Review

| Secret | Description |
|--------|-------------|
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for Claude code review |

### GitHub (Automatic)

| Secret | Description |
|--------|-------------|
| `GITHUB_TOKEN` | Automatically provided by GitHub Actions |

---

## Secrets Checklist

### For `manual-distribute.yml`

```
Common:
[ ] APP_STORE_CONNECT_API_KEY_ID
[ ] APP_STORE_CONNECT_API_ISSUER_ID
[ ] APP_STORE_CONNECT_API_KEY_CONTENT
[ ] MATCH_GIT_URL
[ ] MATCH_PASSWORD
[ ] MATCH_GIT_PRIVATE_KEY
[ ] GOMA_TEAM_ID
[ ] FIREBASE_CLI_TOKEN
[ ] FIREBASE_PROJECT_NUMBER
[ ] DISCORD_PERSONAL_RELEASE_WEBHOOK

BCM-specific:
[ ] BETSSONCM_STG_FIREBASE_APP_ID
[ ] BETSSONCM_UAT_FIREBASE_APP_ID

BFR-specific:
[ ] BFR_PROD_TEAM_ID (= QN2DYX5K4M)
[ ] BFR_PROD_API_KEY_ID
[ ] BFR_PROD_API_ISSUER_ID
[ ] BFR_PROD_API_KEY_CONTENT
[ ] BFR_UAT_FIREBASE_APP_ID
[ ] BFR_PROD_FIREBASE_APP_ID
[ ] BFR_PROD_FIREBASE_CLI_TOKEN
```

### For `tag-release.yml`

All secrets from `manual-distribute.yml` plus:

```
[ ] JIRA_EMAIL
[ ] JIRA_API_TOKEN
[ ] JIRA_BASE_URL
[ ] DISCORD_TEAM_RELEASE_WEBHOOK
```

### For `claude-code-review.yml` and `claude.yml`

```
[ ] CLAUDE_CODE_OAUTH_TOKEN
```

---

## Configuration Files

### `.github/tag-config.yml`

Client-specific configuration for tag-based releases:

```yaml
clients:
  BCM:
    name: "Betsson Cameroon"
    directory: "BetssonCameroonApp"
    project: "BetssonCameroonApp.xcodeproj"
    target: "BetssonCameroonApp"
    changelog: "BetssonCameroonApp/CHANGELOG.yml"
    devices_file: "fastlane/devices.csv"
    release_branch: "main"
    staging_scheme: "BetssonCM Staging"
    production_scheme: "BetssonCM Prod"

  BFR:
    name: "Betsson France Legacy"
    directory: "BetssonFranceLegacy"
    project: "Sportsbook.xcodeproj"
    target: "BetssonFranceApp"
    changelog: "BetssonFranceLegacy/CHANGELOG.yml"
    devices_file: "fastlane/devices.csv"
    release_branch: "betsson-france-dev"
    staging_scheme: "Betsson UAT"
    production_scheme: "Betsson PROD"
```

---

## Device Files

### BCM Format (`BetssonCameroonApp/fastlane/devices.csv`)

```csv
Device ID,Device Name,Device Platform
00008030-001234567890,iPhone 15 Pro - John,ios
```

No quotes, comma-separated.

### BFR Format (`BetssonFranceLegacy/fastlane/devices.csv`)

```csv
Device ID,Device Name,Device Platform
00008030-001234567890,iPhone 15 Pro - John,ios
```

Same format as BCM — unquoted, comma-separated.

---

## Fastlane Lanes

### BCM (BetssonCameroonApp)

| Lane | Description |
|------|-------------|
| `keep_version_distribute_staging` | Distribute to STG, keep current version |
| `keep_version_distribute_uat` | Distribute to UAT, keep current version |
| `distribute_staging` | Increment build, distribute to STG |
| `distribute_uat` | Increment build, distribute to UAT |
| `register_new_devices` | Register devices from devices.csv |

### BFR (BetssonFranceLegacy)

| Lane | Description |
|------|-------------|
| `betsson_uat` | Distribute to UAT |
| `betsson_prod` | Distribute to PROD |
| `betsson` | Increment build, distribute to UAT + PROD |

---

## Typical Workflows

### Quick UAT Build (Manual)

1. Go to Actions → Manual Distribution
2. Select client (BCM or BFR)
3. Check "Deploy to UAT"
4. Click "Run workflow"

### Multi-Environment with New Device

1. Go to Actions → Manual Distribution
2. Select client
3. Check desired environments (UAT, PROD)
4. Enable "Auto-increment build number"
5. Add device: `00008030-001234567890,iPhone 16 Pro - NewUser`
6. If PROD selected, type `PROD` in confirmation
7. Click "Run workflow"

### Formal Release (Tag-Based)

1. Ensure version/build in Xcode project is correct
2. Update `CHANGELOG.yml` with release notes
3. Commit and push
4. Create and push tag: `git tag bcm-v0.3.8(3801) && git push --tags`
5. Workflow runs automatically

---

## Troubleshooting

### Build Fails at Code Signing

- Verify `MATCH_GIT_URL` and `MATCH_PASSWORD` are correct
- Check `MATCH_GIT_PRIVATE_KEY` has access to certificates repo
- Ensure certificates are up to date in Match repo

### Firebase Upload Fails

- Verify `FIREBASE_CLI_TOKEN` is valid (tokens expire)
- Check Firebase App ID matches the environment

### PROD Deployment Rejected

- Must type exactly `PROD` in confirmation field
- Case-sensitive

### No Discord Notification

- Verify `DISCORD_PERSONAL_RELEASE_WEBHOOK` secret is set
- Check webhook URL is valid in Discord

---

## Where to Configure Secrets

GitHub → Repository → Settings → Secrets and variables → Actions → Repository secrets

Direct URL:
```
https://github.com/gomagaming/sportsbook-ios/settings/secrets/actions
```
