## Date
08 December 2025

### Project / Branch
BetssonCameroonApp / rr/new_client_structure

### Goals for this session
- Configure different app icons for STG, UAT, and PROD environments
- Add visual badges to non-production icons for easy identification

### Achievements
- [x] Created 3 separate app icon sets in `BetssonCM-Assets.xcassets`:
  - `AppIcon-BetssonCM-STG.appiconset`
  - `AppIcon-BetssonCM-UAT.appiconset`
  - `AppIcon-BetssonCM-PROD.appiconset`
- [x] Updated `project.pbxproj` to use per-configuration icon names:
  - Debug-Staging / Release-Staging → `AppIcon-BetssonCM-STG`
  - Debug-UAT / Release-UAT → `AppIcon-BetssonCM-UAT`
  - Debug-Production / Release-Production → `AppIcon-BetssonCM-PROD`
- [x] Added visual environment badges using ImageMagick:
  - STG: White banner at bottom with "STG" in black text
  - UAT: White banner at bottom with "UAT" in black text
  - PROD: Clean icon (no badge)

### Issues / Bugs Hit
- [ ] `badgy` CLI tool failed to detect ImageMagick despite it being installed
- [ ] Ruby `badge` gem installed but not found in PATH (rbenv shim issue)
- [x] Resolved by using ImageMagick `magick` command directly

### Key Decisions
- Used build configuration approach (not user-defined variables) for icon selection
- White banner with black text chosen for better visibility across icon backgrounds
- PROD icon remains clean/unbadged to maintain App Store appearance

### Experiments & Notes
- Tried multiple badge overlay tools:
  - `badgy` (brew) - failed dependency detection
  - `badge` (Ruby gem) - PATH issues with rbenv
  - ImageMagick `magick` - worked perfectly
- ImageMagick command for badge overlay:
  ```bash
  magick "source.png" -gravity South -fill "rgba(255,255,255,0.9)" \
    -draw "rectangle 0,850 1024,1024" -fill black \
    -font Helvetica-Bold -pointsize 100 -annotate +0+45 "STG" "output.png"
  ```

### Useful Files / Links
- [BetssonCM-Assets.xcassets](../../BetssonCameroonApp/App/Resources/Assets/BetssonCM-Assets.xcassets/)
- [project.pbxproj](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)
- [Kiprosh Blog: Environment setup for different app icons](https://blog.kiprosh.com/environment-setup-to-manage-different-app-name-icon-and-endpoint-using-xcode-configurations-in-ios-swift-language/)
- [Stack Overflow: Xcode AppIcon based on scheme](https://stackoverflow.com/questions/47769866/xcode-appicon-based-on-scheme)

### Next Steps
1. Test build with each scheme to verify correct icon is used
2. Consider adding dark mode icon variants for iOS 18+
3. Document ImageMagick command in project scripts for future icon updates
