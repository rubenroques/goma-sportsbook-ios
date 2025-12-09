## Date
08 December 2025

### Project / Branch
BetssonCameroonApp / rr/new_client_structure

### Goals for this session
- Verify and fix BetAtHome multi-client configuration from previous session
- Fix Firebase plist copy build phase for BetAtHome
- Create custom launch screen for BetAtHome
- Fix WebSocket URL and origin for BetAtHome (different from Betsson Cameroon)

### Achievements
- [x] Added `GoogleService-Info-BetAtHome.plist` to Firebase build phase inputPaths
- [x] Created `LaunchScreen-BetAtHome.storyboard` (en/fr localizations) with placeholder assets
- [x] Updated BetAtHome build configs to use `LaunchScreen-BetAtHome` instead of `LaunchScreen-BetssonCM`
- [x] Created `SocketConfiguration` struct in `Configuration.swift` to group WebSocket settings (url, origin, realm, version)
- [x] Added client override properties to `EveryMatrixUnifiedConfiguration` (`clientWebSocketURL`, `clientWebSocketOrigin`, `clientWebSocketVersion`)
- [x] Updated computed properties to check overrides first before falling back to environment defaults
- [x] Updated `Client.swift` to apply socket configuration from builder
- [x] Added `socketConfiguration` static var to `TargetVariables.swift` with per-environment/client values
- [x] Replaced `.withSocketRealm()` with `.withSocketConfiguration()` in `Environment.swift`

### Issues / Bugs Hit
- [x] Firebase bundle ID mismatch error - was copying wrong plist (solved by clean build after fixing inputPaths)
- [x] WebSocket connecting to wrong URL (`wss://sportsapi.betssonem.com` instead of `wss://sportsapi.bet-at-home.de`)

### Key Decisions
- **SocketConfiguration struct**: Grouped all WebSocket settings (url, origin, realm, version) into a single struct rather than adding 4 separate builder methods - cleaner API
- **Override pattern**: Followed existing `clientOperatorId` pattern - nullable override properties that computed properties check first
- **Removed standalone socketRealm**: Consolidated into SocketConfiguration struct, removed deprecated `withSocketRealm()` builder method

### Experiments & Notes
- Researched `FirebaseApp.configure(options:)` - can accept custom plist path via `FirebaseOptions(contentsOfFile:)`, but kept build script approach to avoid Crashlytics issues
- BetAtHome WebSocket credentials:
  - URL: `wss://sportsapi.bet-at-home.de`
  - Origin: `https://sports2.bet-at-home.de`
  - Realm: `www.bet-at-home.de`

### Useful Files / Links
- [Configuration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Configuration/Configuration.swift) - SocketConfiguration struct
- [EveryMatrixUnifiedConfiguration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift) - Client override properties
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Applies socket config
- [TargetVariables.swift](../../BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift) - Per-client socket configs
- [Environment.swift](../../BetssonCameroonApp/App/Boot/Environment.swift) - Builder usage
- [Previous session journal](./08-December-2025-betathome-multi-client-architecture.md)

### Next Steps
1. Test BetAtHome scheme builds and WebSocket connects correctly
2. Add placeholder assets for BetAtHome launch screen (`brand_icon_betathome`, `splash_gradient_background_betathome`)
3. Verify EveryMatrix API calls work with BetAtHome credentials
4. Consider adding XtremePush key for BetAtHome (currently `break` no-op in AppDelegate)
