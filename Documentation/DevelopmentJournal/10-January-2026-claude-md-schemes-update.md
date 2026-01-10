## Date
10 January 2026

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate actual Xcode schemes per project
- Update CLAUDE.md with accurate scheme information

### Achievements
- [x] Discovered workspace has 5 xcodeproj files (not the structure documented in CLAUDE.md)
- [x] Identified all schemes per project via scheme files in xcshareddata
- [x] Updated CLAUDE.md "Available Schemes by Project" section with accurate data

### Issues / Bugs Hit
- Initial `xcodebuild -list` was slow due to package resolution
- CLAUDE.md referenced non-existent `BetssonFranceApp/Sportsbook.xcodeproj` path

### Key Decisions
- Used direct scheme file inspection (`ls xcshareddata/xcschemes/`) instead of `xcodebuild -list` for faster results
- Kept the scheme documentation concise - just project path and scheme names

### Useful Files / Links
- [CLAUDE.md](../../CLAUDE.md) - Updated schemes section

### Actual Project Structure Discovered
```
BetssonCameroonApp/BetssonCameroonApp.xcodeproj
  → BetssonCM UAT, BetssonCM Staging, BetssonCM Prod

BetssonFrance/BetssonFrance.xcodeproj
  → BetssonFrance UAT, BetssonFrance PRD

BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj
  → Betsson UAT, Betsson PROD

Showcase/Showcase.xcodeproj
  → Showcase, DAZN

Frameworks/GomaUI/GomaUICatalog.xcodeproj
  → GomaUICatalog
```

### Next Steps
1. Consider updating other CLAUDE.md sections that reference old project paths
2. Verify workspace configuration matches actual project structure
