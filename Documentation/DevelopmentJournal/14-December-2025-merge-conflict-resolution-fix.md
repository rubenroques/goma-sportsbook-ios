## Date
14 December 2025

### Project / Branch
BetssonCameroonApp / rr/bet-at-home (git worktree)

### Goals for this session
- Investigate why BetAtHome schemes disappeared after merging main into bet-at-home branch
- Restore the BetAtHome configurations while keeping the desired version 0.3.6 (3601)

### Achievements
- [x] Identified root cause: using "theirs" strategy during merge conflict resolution replaced entire project.pbxproj with main's version
- [x] Confirmed 46 BetAtHome references were lost (0 in current vs 46 in pre-merge commit)
- [x] Extracted pre-merge project.pbxproj from commit `4efbb0888`
- [x] Updated version numbers from `1.0.0 (10037)` to `0.3.6 (3601)` in extracted file
- [x] Restored project.pbxproj with all BetAtHome configurations intact

### Issues / Bugs Hit
- [x] Merge conflict in `project.pbxproj` - resolved incorrectly with "theirs" strategy
  - "Theirs" (main) had version 0.3.6 but no BetAtHome configs
  - "Ours" (bet-at-home) had version 1.0.0 but all BetAtHome configs
  - Needed: version from theirs + configs from ours

### Key Decisions
- Restored project.pbxproj from pre-merge commit rather than manually re-adding configurations
- Used sed to update version numbers in bulk (CURRENT_PROJECT_VERSION and MARKETING_VERSION)
- This approach preserved all BetAtHome-specific additions:
  - Build configurations (Debug/Release for BetAtHome-Production)
  - Firebase script with BetAtHome case
  - GomaPlatform framework references
  - Environment-specific app icons

### Experiments & Notes
- Merge commit: `d8ac6d1b9` (Merge origin/main into rr/bet-at-home)
- Pre-merge bet-at-home commit: `4efbb0888` (feat: Add BrandLogoImageResolver)
- Main branch commit: `4899e5472` (Fixed log)
- Lesson learned: For project.pbxproj conflicts, manual merge or "ours" with selective updates is safer than "theirs"

### Useful Files / Links
- [project.pbxproj](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)
- [BetAtHome Prod.xcscheme](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/xcshareddata/xcschemes/BetAtHome%20Prod.xcscheme)

### Next Steps
1. Commit the restored project.pbxproj
2. Verify BetAtHome Prod scheme appears in Xcode
3. Test build with `xcodebuild -scheme "BetAtHome Prod"`
