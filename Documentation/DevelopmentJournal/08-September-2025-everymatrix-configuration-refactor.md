## Date
08 September 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix EveryMatrix configuration anti-pattern identified in code review
- Align EveryMatrix configuration with SportRadar's proven pattern
- Enable runtime environment switching for EveryMatrix APIs

### Achievements
- [x] Created `EveryMatrixUnifiedConfiguration.swift` with mutable shared instance
- [x] Updated all EveryMatrix API classes to use unified configuration:
  - [x] EveryMatrixOddsMatrixAPI.swift
  - [x] EveryMatrixPlayerAPI.swift  
  - [x] EveryMatrixCasinoAPI.swift
- [x] Wired configuration updates in Client.swift (both constructor and didSet)
- [x] Removed deprecated configuration files:
  - [x] EveryMatrixOddsMatrixAPIEnvironment.swift
  - [x] EveryMatrixPlayerAPIEnvironment.swift
  - [x] EveryMatrixCasinoAPIEnvironment.swift
- [x] Fixed compilation errors in dependent classes
- [x] Centralized hardcoded URLs in unified configuration

### Issues / Bugs Hit
- [x] EveryMatrixSessionCoordinator still referenced deleted EveryMatrixConfiguration
- [x] EveryMatrixPrivilegedAccessManager had unused configuration parameter
- [x] EveryMatrixCasinoProvider had hardcoded game launch URLs
- [x] Multiple references to deleted environment classes needed updating

### Key Decisions
- **Followed SportRadar pattern exactly** - Used mutable `shared` instance instead of immutable `default`
- **Single source of truth** - All EveryMatrix APIs now use EveryMatrixUnifiedConfiguration.shared
- **Centralized URL management** - Moved all base URLs and game launch URLs to unified config
- **Removed unused dependencies** - Cleaned up configuration parameters that weren't being used

### Experiments & Notes
- EveryMatrix had **3 separate singleton configurations** - this was the core anti-pattern
- SportRadar uses **1 mutable configuration** that gets updated by Client.swift
- The pattern enables runtime environment switching when app configuration changes
- Domain ID "4093" is consistent across all environments (needs production verification)

### Useful Files / Links
- [EveryMatrixUnifiedConfiguration.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift) - New centralized config
- [SportRadarConfiguration.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarConfiguration.swift) - Reference pattern
- [Client.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Configuration wiring
- [EveryMatrixOddsMatrixAPI.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/OddsMatrixAPI/EveryMatrixOddsMatrixAPI.swift) - Updated API

### Next Steps
1. Test environment switching behavior in app
2. Verify production domain ID "4093" is correct
3. Consider adding configuration validation
4. Run full build test to confirm no remaining compilation errors