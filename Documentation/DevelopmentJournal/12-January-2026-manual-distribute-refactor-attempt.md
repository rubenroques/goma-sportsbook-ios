## Date
12 January 2026

### Project / Branch
sportsbook-ios / wip/manual-distribute-refactor

### Goals for this session
- Understand the manual GitHub Action for CI distribution
- Simplify the manual distribution workflow by using boolean checkboxes instead of dropdown + environment toggles
- Enable deploying multiple clients in a single workflow run (rare use case)

### Achievements
- [x] Deep analysis of `manual-distribute.yml` workflow
- [x] Deep analysis of `tag-release.yml` workflow
- [x] Researched GitHub Actions `workflow_dispatch` input types and limitations (boolean, choice, string, number, environment - max 25 inputs, no multi-line textarea support)
- [x] Identified device file path inconsistencies between BCM and BFR Fastlane configurations
- [x] Discovered BCM device registration was silently failing due to wrong path (`./devices.csv` vs `./fastlane/devices.csv`)
- [x] Unified device file format to CSV for both clients (BFR was using quoted TXT format)
- [x] Updated BFR plugins to match BCM versions (firebase_app_distribution 0.10.1, versioning 0.7.1)
- [x] Added `dotenv` gem to BFR Gemfile (was missing, preventing .env loading)
- [x] Added begin/rescue error handling to BFR device registration (matching BCM pattern)

### Issues / Bugs Hit
- [ ] Fastlane working directory confusion - Fastlane runs from inside `fastlane/` subdirectory, not project root
- [ ] BCM path `./devices.csv` was correct (relative to fastlane/), initial "fix" to `./fastlane/devices.csv` broke it
- [ ] BFR `betsson_uat` lane disappeared after edits - likely syntax error introduced
- [ ] Both BCM and BFR `register_devices` action fails locally with "Please provide a file according to the Apple Sample UDID file" - even with correct credentials, the error handling catches it and continues

### Key Decisions
- Decided to save all changes to `wip/manual-distribute-refactor` branch for later analysis rather than continue debugging
- Original goal of boolean inputs for multi-client deployment was deprioritized due to scope creep
- CSV format standardization for both clients is a good simplification but needs more careful implementation

### Experiments & Notes
- GitHub Actions `workflow_dispatch` supports 5 input types only: boolean, choice, string, number, environment
- Max 25 inputs (increased from 10 in Dec 2024)
- No multi-line textarea support (major limitation for device registration input)
- `type: environment` auto-populates from GitHub Environments - potentially useful
- Fastlane `register_devices` action seems to fail locally even with proper .env setup - possibly needs actual Apple API authentication that only works in CI
- BCM's `begin/rescue` pattern around `register_devices` is essential for graceful degradation

### Useful Files / Links
- [Manual Distribute Workflow](../../.github/workflows/manual-distribute.yml)
- [Tag Release Workflow](../../.github/workflows/tag-release.yml)
- [Tag Config](../../.github/tag-config.yml)
- [BCM Fastfile](../../BetssonCameroonApp/fastlane/Fastfile)
- [BFR Fastfile](../../BetssonFranceLegacy/fastlane/Fastfile)
- [GitHub Actions Input Types Changelog](https://github.blog/changelog/2021-11-10-github-actions-input-types-for-manual-workflows/)
- [GitHub 25 Inputs Limit](https://github.blog/changelog/2025-12-04-actions-workflow-dispatch-workflows-now-support-25-inputs/)

### Next Steps
1. Review changes in `wip/manual-distribute-refactor` branch carefully
2. Fix BFR Fastfile syntax error (likely introduced during edit)
3. Test device path fix (`./devices.csv`) in isolation on BCM first
4. Decide whether CSV unification for BFR is worth the risk
5. Consider simpler approach: just add boolean checkboxes without touching device registration logic
6. Test full distribution in CI (not locally) where Apple API credentials work properly
