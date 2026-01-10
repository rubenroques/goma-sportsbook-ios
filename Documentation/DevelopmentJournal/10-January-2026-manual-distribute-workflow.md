## Date
10 January 2026

### Project / Branch
sportsbook-ios / rr/gomaui_metadata

### Goals for this session
- Explore and understand existing GitHub CI/CD workflows
- Create new unified manual distribution workflow to replace `auto-distribute-cameroon.yml`
- Support both BCM (Betsson Cameroon) and BFR (Betsson France Legacy) clients
- Enable multi-environment deployment (STG/UAT/PROD)
- Add device registration and auto-increment build number features

### Achievements
- [x] Explored and documented full CI/CD pipeline (4 workflows)
- [x] Created `manual-distribute.yml` with multi-client, multi-environment support
- [x] Fixed `tag-config.yml` - corrected BFR directory from `BetssonFranceApp` to `BetssonFranceLegacy`
- [x] Renamed Discord webhook secrets for clarity (`DISCORD_TEAM_RELEASE_WEBHOOK`, `DISCORD_PERSONAL_RELEASE_WEBHOOK`)
- [x] Updated BFR Fastfile to support separate API Key for PROD (Betsson France team)
- [x] Removed unnecessary `BFR_MATCH_GIT_URL_PROD` - same repo, different branches
- [x] Created comprehensive `Documentation/CI_CD_GUIDE.md` with all secrets and configurations
- [x] Added success/failure Discord notifications to personal webhook

### Issues / Bugs Hit
- [x] BFR directory mismatch in `tag-config.yml` (was `BetssonFranceApp`, should be `BetssonFranceLegacy`)
- [x] BFR PROD used Apple ID auth instead of API Key - would fail in CI due to 2FA

### Key Decisions
- **Single text area for devices** - Format: `UUID,Name` per line, supports multiple devices
- **One commit at end** - Cleaner git history with `[skip ci]` to prevent loops
- **Sequential multi-environment builds** - STG → UAT → PROD (safer than parallel)
- **Separate API Keys per team** - Goma API Key for BCM/BFR-UAT, Betsson France API Key for BFR-PROD
- **Same Match repo, different branches** - `goma` branch for Goma team, `betsson-france` branch for BF team

### Experiments & Notes
- Tested Discord webhook with "Banana Deploy" message to verify correct channel
- GitHub Actions doesn't support dynamic dropdowns - used checkboxes for environment selection instead

### Useful Files / Links
- [Manual Distribute Workflow](../../.github/workflows/manual-distribute.yml)
- [Tag Release Workflow](../../.github/workflows/tag-release.yml)
- [Tag Config](../../.github/tag-config.yml)
- [CI/CD Guide](../CI_CD_GUIDE.md)
- [BFR Fastfile](../../BetssonFranceLegacy/fastlane/Fastfile)
- [BCM Fastfile](../../BetssonCameroonApp/fastlane/Fastfile)
- [Match Certificates README](/tmp/FastlaneAppleCertificates/README.md)

### GitHub Secrets Status

**Configured:**
- All common secrets (App Store Connect, Match, Firebase CLI, Jira, Discord)
- BCM: All Firebase App IDs, `FIREBASE_PROJECT_NUMBER`
- BFR: `BFR_PROD_TEAM_ID`, `BFR_UAT_FIREBASE_APP_ID`, `BFR_PROD_FIREBASE_APP_ID`, `BFR_PROD_FIREBASE_CLI_TOKEN`

**Still needed for BFR PROD:**
- `BFR_PROD_API_KEY_ID`
- `BFR_PROD_API_ISSUER_ID`
- `BFR_PROD_API_KEY_CONTENT`

**Can delete:**
- `DISCORD_TEST_RELEASE_BOT_WEBHOOK` (replaced by `DISCORD_TEAM_RELEASE_WEBHOOK`)

### Next Steps
1. Create App Store Connect API Key in Betsson France team account
2. Add 3 BFR PROD API Key secrets to GitHub
3. Test manual-distribute workflow with BCM UAT
4. Test manual-distribute workflow with BFR UAT + PROD
5. Delete `auto-distribute-cameroon.yml` after successful testing
6. Delete old `DISCORD_TEST_RELEASE_BOT_WEBHOOK` secret
