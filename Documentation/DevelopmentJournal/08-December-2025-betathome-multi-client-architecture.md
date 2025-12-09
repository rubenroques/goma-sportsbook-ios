## Date
08 December 2025

### Project / Branch
BetssonCameroonApp / rr/new_client_structure

### Goals for this session
- Add BetAtHome as a new client to BetssonCameroonApp without code duplication
- Configure different EveryMatrix operatorId and realm per client
- Set up different theme colors per client
- Create proper Xcode build configurations and supporting files

### Achievements
- [x] Added `betAtHomeProd` case to `BuildEnvironment` enum in `TargetVariables.swift`
- [x] Extended `ServicesProvider.Configuration.Builder` with `.withOperatorId()` and `.withSocketRealm()` methods
- [x] Added `operatorId` and `socketRealm` static vars to `TargetVariables` that switch on `BuildEnvironment`
- [x] Updated `Client.swift` to apply operatorId/realm overrides from Configuration
- [x] Added `clientOperatorId` and `clientWebSocketRealm` override properties to `EveryMatrixUnifiedConfiguration`
- [x] Added BetAtHome light theme colors (`ThemeColors.betAtHomeLight`) from Figma export
- [x] Updated `ThemeService` to select theme based on `BuildEnvironment`
- [x] Created `Misc-BetAtHome-PROD/` directory with:
  - `BetAtHome-Info.plist`
  - `BetAtHome.entitlements` (with bet-at-home.de associated domains)
  - `GoogleService-Info.plist` (Firebase config)
- [x] Updated BetAtHome build configurations in `project.pbxproj`:
  - Fixed `CODE_SIGN_ENTITLEMENTS` path
  - Fixed `INFOPLIST_FILE` path
  - Fixed `INFOPLIST_KEY_CFBundleDisplayName` to "bet-at-home"
  - Fixed `PRODUCT_NAME` to "BetAtHome"
  - Fixed test target `TEST_HOST` paths

### Issues / Bugs Hit
- [ ] Test target configurations still partially referencing Betsson Cameroon (Debug test config TEST_HOST fix incomplete)
- [ ] Launch screen still uses BetssonCM storyboard (acceptable for now)

### Key Decisions
- **Simplified architecture**: Instead of complex client abstraction protocol, we extended existing `BuildEnvironment` enum with new case
- **Configuration through Builder**: operatorId and socketRealm flow through `Configuration.Builder` → `Client.swift` → `EveryMatrixUnifiedConfiguration` (no direct access from app layer)
- **TargetVariables as config source**: All client-specific values (operatorId, socketRealm, Firebase URL) defined in `TargetVariables` with switch on `BuildEnvironment`
- **Dark theme fallback**: BetAtHome uses Betsson Cameroon dark theme until BetAtHome provides dark mode design

### Experiments & Notes
- Initial plan was overly complex with `ClientConfiguration` protocol and factory pattern - simplified after feedback
- BetAtHome credentials: operatorId = "2687", realm = "www.bet-at-home.de"
- BetAtHome primary color: green `#73bd1c`, secondary: navy `#00214a`

### Useful Files / Links
- [TargetVariables.swift](../../BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift) - BuildEnvironment enum and client configs
- [Configuration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Configuration/Configuration.swift) - Builder pattern
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Applies config overrides
- [EveryMatrixUnifiedConfiguration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift) - EM config singleton
- [ThemeColors.swift](../../BetssonCameroonApp/App/Resources/Theme/ThemeColors.swift) - Theme color definitions
- [ThemeService.swift](../../BetssonCameroonApp/App/Style/Theme/ThemeService.swift) - Theme selection logic
- [Misc-BetAtHome-PROD/](../../BetssonCameroonApp/App/SupportingFiles/Misc-BetAtHome-PROD/) - BetAtHome supporting files
- Figma theme export: `/Users/rroques/Downloads/5 dezembro vars.json`

### Next Steps
1. Complete test target configuration fixes (Debug TEST_HOST)
2. Add BetAtHome app icon to asset catalog (`AppIcon-BetAtHome-PROD`)
3. Create BetAtHome launch screen (or adapt existing)
4. Test build and run with BetAtHome scheme
5. Verify EveryMatrix connection with BetAtHome credentials
6. Consider adding more BetAtHome environments (STG/UAT) later
