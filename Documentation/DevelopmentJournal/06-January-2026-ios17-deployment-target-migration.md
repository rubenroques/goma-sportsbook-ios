## Date
06 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests

### Goals for this session
- Investigate why GomaUI Swift Package couldn't be set to iOS 18+ deployment target
- Update all Swift Packages and Xcode projects to iOS 17 minimum deployment target
- Remove unnecessary `@available(iOS 17.0, *)` annotations from GomaUI

### Achievements
- [x] Identified root cause: `swift-tools-version` controls available platform enum values (5.7 → .v16 max, 5.9 → .v17, 6.0 → .v18)
- [x] Updated 13 Swift Packages from `swift-tools-version: 5.7` to `5.9` and `.iOS(.v15)` to `.iOS(.v17)`
- [x] Updated 4 Xcode projects deployment targets to 17.0:
  - BetssonCameroonApp (was 16.6/18.2 mixed)
  - BetssonFrance (was 26.2)
  - GomaUICatalog (was 15.6/16.6/18.2 mixed)
  - GomaUIDemo (was 15.6/16.6/18.2 mixed)
- [x] Removed 488 `@available(iOS 17.0, *)` annotations from 237 GomaUI files
- [x] Verified build succeeds with GomaUICatalog scheme
- [x] Updated documentation in README.md and CLAUDE.md

### Issues / Bugs Hit
- None - migration was straightforward

### Key Decisions
- **Swift 5.9 over 6.0**: Chose 5.9 to avoid Swift 6 strict concurrency changes (would require `swiftLanguageModes: [.v5]` workaround)
- **Skipped BetssonFranceLegacy**: Intentionally kept at iOS 13-15.6 for backward compatibility
- **Unified to iOS 17.0**: All projects now share same minimum deployment target for consistency
- **macOS also bumped**: Where packages had macOS targets, bumped from v12/v13 to v14 for consistency

### Experiments & Notes
- Learned iOS 26 is real - Apple jumped from iOS 18 to iOS 26 (year-matching naming for 2026)
- All `@available(iOS 17.0, *)` annotations were only for `#Preview` macros - zero iOS 17 APIs used in production code
- `sed -i '' '/@available(iOS 17\.0, \*)/d'` efficiently removed all annotations in one pass

### Useful Files / Links
- [GomaUI Package.swift](../../Frameworks/GomaUI/GomaUI/Package.swift)
- [GomaUI README.md](../../Frameworks/GomaUI/README.md)
- [GomaUI CLAUDE.md](../../Frameworks/GomaUI/CLAUDE.md)
- [Swift Package Manager SupportedPlatform docs](https://developer.apple.com/documentation/packagedescription/supportedplatform)

### Swift Packages Updated
| Package | Path |
|---------|------|
| AdresseFrancaise | `Frameworks/AdresseFrancaise/Package.swift` |
| CountrySelectionFeature | `Frameworks/CountrySelectionFeature/Package.swift` |
| EveryMatrixProviderClient | `Frameworks/EveryMatrixProviderClient/Package.swift` |
| Extensions | `Frameworks/Extensions/Package.swift` |
| GomaLogger | `Frameworks/GomaLogger/Package.swift` |
| GomaPerformanceKit | `Frameworks/GomaPerformanceKit/Package.swift` |
| GomaUI | `Frameworks/GomaUI/GomaUI/Package.swift` |
| HeaderTextField | `Frameworks/HeaderTextField/Package.swift` |
| PresentationProvider | `Frameworks/PresentationProvider/Package.swift` |
| RegisterFlow | `Frameworks/RegisterFlow/Package.swift` |
| ServicesProvider | `Frameworks/ServicesProvider/Package.swift` |
| SharedModels | `Frameworks/SharedModels/Package.swift` |
| Theming | `Frameworks/Theming/Package.swift` |

### Next Steps
1. Consider migrating to iOS 18 / Swift 6.0 in future when ready for strict concurrency
2. Clean up any remaining iOS 16-specific code paths that are now unreachable
3. Update CI/CD pipelines if they reference old iOS simulator versions
