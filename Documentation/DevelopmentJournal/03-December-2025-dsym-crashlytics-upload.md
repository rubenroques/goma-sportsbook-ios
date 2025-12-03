## Date
03 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Add dSYM upload to Firebase Crashlytics in the tag-release GitHub Action pipeline
- Enable crash report symbolication (readable stack traces instead of memory addresses)

### Achievements
- [x] Researched `upload_symbols_to_crashlytics` fastlane action requirements
- [x] Identified SPM-specific issue: binary path unpredictable in CI (`DerivedData/*/SourcePackages/...`)
- [x] Copied `upload-symbols` binary from Firebase SDK to `BetssonCameroonApp/scripts/`
- [x] Added `upload_symbols_to_crashlytics` call to `build_and_distribute_to_firebase` lane
- [x] Implemented environment-specific GoogleService-Info.plist selection (STG/PROD)
- [x] Wrapped upload in begin/rescue so failures don't block releases

### Issues / Bugs Hit
- [x] Initial plan assumed `app_id` parameter would work without `binary_path` - incorrect for SPM projects
- [x] SPM cache paths differ between local (`.build/SourcePackages/`) and CI (`~/Library/Developer/Xcode/DerivedData/*/SourcePackages/`)

### Key Decisions
- **Commit binary to repo** vs dynamic path discovery: Chose committing binary for reliability
  - Fastlane auto-searches `./scripts/upload-symbols`
  - Binary is ~740KB, universal (x86_64 + arm64)
  - Tradeoff: needs manual update when Firebase SDK updates
- **Non-blocking upload**: dSYM upload failure shouldn't fail the entire release (IPA already distributed)
- **Use `gsp_path`** over `app_id`: More explicit, uses existing environment-specific plist files

### Experiments & Notes
- Tested dynamic path approach using `xcodebuild -showBuildSettings | grep BUILD_DIR`
- Works locally but adds complexity and depends on xcodebuild availability post-build
- GitHub Action SPM cache at `~/Library/Developer/Xcode/DerivedData/*/SourcePackages` confirmed different from local

### Useful Files / Links
- [Fastfile](../../BetssonCameroonApp/fastlane/Fastfile) - Lines 325-344
- [upload-symbols binary](../../BetssonCameroonApp/scripts/upload-symbols)
- [tag-release.yml](../../.github/workflows/tag-release.yml)
- [Fastlane upload_symbols_to_crashlytics docs](https://docs.fastlane.tools/actions/upload_symbols_to_crashlytics/)
- [SPM Crashlytics solution - GitHub Issue #17288](https://github.com/fastlane/fastlane/issues/17288)
- [Firebase Blog - Uploading dSYM Files with Fastlane](https://firebase.blog/posts/2021/09/uploading-dsym-files-to-crashlytics-with-fastlane/)

### Next Steps
1. Test locally: `bundle exec fastlane keep_version_distribute_staging`
2. Verify dSYMs appear in Firebase Crashlytics console > dSYMs tab
3. Trigger test crash to confirm symbolication works
4. Consider adding reminder to update `upload-symbols` binary when Firebase SDK is updated
