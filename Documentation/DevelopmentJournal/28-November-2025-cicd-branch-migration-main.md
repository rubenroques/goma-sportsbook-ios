## Date
28 November 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Fix GitHub Actions CI/CD failure due to missing `betsson-cm` branch
- Migrate all CI/CD references from `betsson-cm` to `main`
- Trigger a new release to verify the fix

### Achievements
- [x] Updated `.github/tag-config.yml` - changed `release_branch` from `betsson-cm` to `main`
- [x] Updated `.github/workflows/auto-distribute-cameroon.yml` - removed `betsson-cm` from branch triggers
- [x] Updated `BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md` - updated 3 documentation references
- [x] Incremented build number from 3110 to 3111
- [x] Updated CHANGELOG.yml with CI fix note
- [x] Committed, pushed to main, and created tag `bcm-v0.3.1(3111)`

### Issues / Bugs Hit
- GitHub Actions tag-based release was failing with error: `A branch or tag with the name 'betsson-cm' could not be found`
- The `betsson-cm` branch was deleted after merging to `main`, but CI/CD config still referenced it

### Key Decisions
- Betsson Cameroon now uses `main` as the release branch (same as France)
- Documentation files (dev journals) were not updated as they contain historical context
- Firebase URLs in `TargetVariables.swift` containing `betsson-cm` were left unchanged (project identifiers, not Git branches)

### Experiments & Notes
- User initially confused `origin/HEAD` in SourceTree with detached HEAD state - clarified this is normal Git behavior pointing to remote's default branch

### Useful Files / Links
- [Tag Config](.github/tag-config.yml)
- [Auto-Distribute Workflow](.github/workflows/auto-distribute-cameroon.yml)
- [Auto-Distribute Documentation](BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md)
- [Changelog](BetssonCameroonApp/CHANGELOG.yml)

### Next Steps
1. Monitor GitHub Actions to verify the tag-based release completes successfully
2. Confirm Firebase distribution to both staging and production
3. Check Discord notification is received
