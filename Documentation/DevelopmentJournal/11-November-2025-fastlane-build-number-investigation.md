## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate why GitHub Actions Fastlane is using build number 1960 instead of 2090
- Identify where the incorrect build number originates
- Provide solution to ensure Fastlane uses the correct Xcode-configured build number

### Achievements
- [x] Identified root cause: uncommitted changes in `project.pbxproj`
- [x] Verified local Xcode shows correct build number (2090)
- [x] Confirmed GitHub Actions uses committed version (1960)
- [x] Validated Info.plist files correctly reference `$(CURRENT_PROJECT_VERSION)`

### Issues / Bugs Hit
- [x] GitHub Actions distributing builds with wrong build number (1960 instead of 2090)

### Key Decisions
- Build number issue was NOT in Fastlane configuration
- Build number issue was NOT in Info.plist files
- Build number issue was NOT in scheme configurations
- **Root cause**: Xcode project file changes were made locally but never committed to git

### Experiments & Notes

**Investigation Steps:**

1. **Checked Fastlane Configuration**
   - Reviewed `.github/workflows/auto-distribute-cameroon.yml`
   - Examined `BetssonCameroonApp/fastlane/Fastfile`
   - Confirmed Fastlane uses `get_build_number_from_xcodeproj()` correctly
   - No hardcoded build numbers found in Fastlane

2. **Verified Xcode Project Settings**
   - Used `agvtool what-version` to check local build number: **2090** ✓
   - Searched `CURRENT_PROJECT_VERSION` in `project.pbxproj`: **2090** ✓
   - Checked workspace build settings: **2090** ✓

3. **Examined Info.plist Files**
   - `BetssonCM-STG-Info.plist`: Uses `$(CURRENT_PROJECT_VERSION)` ✓
   - `BetssonCM-PROD-Info.plist`: Uses `$(CURRENT_PROJECT_VERSION)` ✓
   - No hardcoded build numbers in plist files

4. **Checked Git Status**
   - `git status` revealed uncommitted changes in `project.pbxproj`
   - `git show HEAD:project.pbxproj | grep CURRENT_PROJECT_VERSION` showed **1960**
   - `git diff project.pbxproj` confirmed local change from 1960 → 2090

**Root Cause Analysis:**

GitHub Actions workflow:
1. Checks out code from git repository
2. Fastlane reads `CURRENT_PROJECT_VERSION` from checked-out `project.pbxproj`
3. Since the change 1960→2090 was never committed, Actions uses **1960**

Local Xcode:
1. Reads from working directory (uncommitted changes included)
2. Shows **2090** correctly

### Useful Files / Links
- [GitHub Actions Workflow](../../.github/workflows/auto-distribute-cameroon.yml)
- [Fastfile](../../BetssonCameroonApp/fastlane/Fastfile)
- [Project File](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)

### Solution

Commit the build number change:

```bash
git add BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj
git commit -m "Bump build number to 2090"
git push origin betsson-cm
```

After pushing, GitHub Actions will use the correct build number (2090).

### Next Steps
1. User needs to commit and push the `project.pbxproj` changes
2. Verify next GitHub Actions build uses 2090
3. Consider adding build number verification step to CI workflow
