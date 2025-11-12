## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Configure OpenSans fonts for BetssonCameroonApp
- Update Info.plist files for PROD and STG environments
- Switch app-wide font system from Ubuntu to OpenSans

### Achievements
- [x] Added OpenSans-Italic.ttf to font resources
- [x] Configured BetssonCM-PROD-Info.plist with all 7 OpenSans font files
- [x] Configured BetssonCM-STG-Info.plist with all 7 OpenSans font files
- [x] Updated AppFont.swift to use OpenSans family instead of Ubuntu
- [x] Properly mapped font weights to OpenSans variants

### Issues / Bugs Hit
None

### Key Decisions
- **Font weight mapping decisions:**
  - `.thin` and `.light` both map to OpenSans-Light (no separate thin variant)
  - `.semibold` now maps to OpenSans-SemiBold (was mapped to Medium in Ubuntu)
  - `.heavy` maps to OpenSans-ExtraBold (OpenSans doesn't have "Black" weight)
  - `.regular` now correctly maps to Regular instead of Light
  - `.medium` now correctly maps to Medium instead of Regular
- **DEV environment**: Intentionally skipped as it will be deleted later
- **Info.plist structure**: Kept Ubuntu fonts alongside OpenSans for backwards compatibility during transition

### Experiments & Notes
- OpenSans font files located at: `BetssonCameroonApp/App/Resources/Fonts/OpenSans/`
- Font files included:
  - OpenSans-Regular.ttf
  - OpenSans-Bold.ttf
  - OpenSans-SemiBold.ttf
  - OpenSans-Medium.ttf
  - OpenSans-Light.ttf
  - OpenSans-ExtraBold.ttf
  - OpenSans-Italic.ttf

### Useful Files / Links
- [AppFont.swift](../../BetssonCameroonApp/App/Style/AppFont.swift) - Main font configuration file
- [BetssonCM-PROD-Info.plist](../../BetssonCameroonApp/App/SupportingFiles/Misc-Prod/BetssonCM-PROD-Info.plist)
- [BetssonCM-STG-Info.plist](../../BetssonCameroonApp/App/SupportingFiles/Misc-Stg/BetssonCM-STG-Info.plist)

### Next Steps
1. Test font rendering in simulator to verify all weights display correctly
2. Remove Ubuntu fonts from Info.plist files once OpenSans is confirmed working
3. Delete DEV environment configuration as planned
4. Consider adding font preview/testing utility to verify all variants load properly
