## Date
20 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Fix casino performance tracking not showing API/parsing entries
- Separate external SDK initialization from app boot tracking
- Fix WebSocket subscription tracking duplicates

### Achievements
- [x] Added `.externalDependencies` enum case to `PerformanceFeature`
- [x] Refactored `AppDelegate` to track external SDKs separately (Phrase, Firebase, XtremePush)
- [x] Added performance tracking to `EveryMatrixCasinoConnector.request()` (API + parsing layers)
- [x] Fixed casino app layer tracking to only end when data is loaded (not on empty initial state)
- [x] Removed performance tracking from `EveryMatrixSocketConnector.subscribe()` to prevent duplicates
- [x] Implemented tracking at manager-level in `PreLiveMatchesPaginator.subscribe()`

### Issues / Bugs Hit
- [x] Casino API/parsing tracking missing - **Root Cause**: Changes made to `EveryMatrixCasinoConnector` but user hadn't rebuilt app yet
- [x] App boot showing 4.6s - **Root Cause**: Included heavy external SDK initialization (Firebase, XtremePush, Phrase)
- [x] WebSocket subscriptions creating multiple tracking entries - **Root Cause**: Tracking at connector-level caused pagination re-subscriptions to create duplicate entries

### Key Decisions
- **External Dependencies Separation**: Created dedicated `.externalDependencies` feature to isolate third-party SDK initialization from core app boot
  - `appBoot` now only tracks lightweight app-specific initialization (~0.2s)
  - `externalDependencies` tracks Phrase/Firebase/XtremePush (~4.4s)
- **Socket Tracking Architecture**: Moved tracking from connector-level to manager-level (public API boundary)
  - Removed from `EveryMatrixSocketConnector.subscribe()` (low-level)
  - Added to `PreLiveMatchesPaginator.subscribe()` (user-facing)
  - Only track first data arrival, ignore pagination re-subscriptions
- **Keep REST Tracking**: User explicitly requested keeping REST API tracking in `EveryMatrixRESTConnector` since those are one-time operations
- **Casino Connector Tracking**: Full API + parsing tracking added to both authenticated and unauthenticated paths in `EveryMatrixCasinoConnector`

### Experiments & Notes
- **Socket Tracking Bug Analysis**: The duplicate entries occurred because:
  1. `PreLiveMatchesPaginator` calls `startInternalSubscription()` multiple times (initial + pagination)
  2. Each call triggered `connector.subscribe()` which called `PerformanceTracker.start()`
  3. The `firstEventReceived` flag was a local variable, not persisted across executions
  4. Result: Multiple tracking entries for same subscription (0.8s, 17s, 27s)
- **hasReceivedFirstData Flag**: Instance variable ensures tracking only happens on FIRST data arrival, not on pagination re-subscriptions

### Useful Files / Links
- [PerformanceFeature.swift](Frameworks/GomaPerformanceKit/Sources/GomaPerformanceKit/Models/PerformanceFeature.swift) - Added `.externalDependencies` case
- [AppDelegate.swift](BetssonCameroonApp/App/Boot/AppDelegate.swift) - Split tracking into `appBoot` vs `externalDependencies`
- [EveryMatrixCasinoConnector.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/CasinoAPI/EveryMatrixCasinoConnector.swift) - Added API + parsing tracking
- [EveryMatrixSocketConnector.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSocketConnector.swift) - Removed tracking
- [PreLiveMatchesPaginator.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Added manager-level tracking
- [CasinoCategoriesListViewController.swift](BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewController.swift) - Fixed timing
- [Previous DJ: Phase 3 Integration](Documentation/DevelopmentJournal/19-November-2025-gomaperformancekit-phase3-integration.md)

### Next Steps
1. **Rebuild app** - User needs to rebuild to see casino tracking and new architecture
2. **Test Expected Results**:
   - `appBoot,app,~0.2s` (lightweight)
   - `externalDependencies,app,~4.4s` (Phrase + Firebase + XtremePush)
   - `sportsData,api,~0.8s` (single entry, no duplicates)
   - `casinoHome,api + parsing` (multiple entries for categories + games)
3. **Consider Adding Tracking to Other Managers**:
   - `LiveMatchesPaginator.subscribe()`
   - `MatchDetailsManager.subscribe()` (if tracking match details is desired)
4. **Phase 4 - Enhanced Debug UI** (future):
   - Add charts/graphs for timing visualization
   - Export to JSON format
   - Session recording for comparison
   - Network waterfall view
5. **Phase 5 - Analytics Integration** (future):
   - FileDestination for disk persistence
   - AnalyticsDestination for backend integration
   - Aggregate metrics (p50, p95, p99)
   - Anomaly detection

### Performance Tracking Coverage Summary

**Features Tracked (10 total)**:
- `.deposit`, `.withdraw`, `.login`, `.register` - EveryMatrix REST
- `.sportsData` - Manager-level (PreLiveMatchesPaginator)
- `.appBoot` - App-specific initialization only
- `.externalDependencies` - Third-party SDKs (NEW)
- `.cms` - GOMA CMS content
- `.casinoHome` - Casino categories + games
- `.homeScreen` - NextUpEvents screen

**Layers Tracked (4 total)**:
- `.app` - iOS app processing
- `.api` - Backend HTTP/WebSocket network
- `.parsing` - JSON decoding
- `.web` - WKWebView rendering (not used yet)

**Expected Log Format After Rebuild**:
```csv
appBoot,app,0.2s               ← Settings, IQKeyboard, device ID, bootstrap
externalDependencies,app,4.4s  ← Phrase + Firebase + XtremePush
sportsData,api,0.8s            ← Single subscription entry (no duplicates)
casinoHome,api,0.5s            ← getCategories
casinoHome,parsing,0.01s
casinoHome,api,0.4s (×9)       ← Concurrent getGamesByCategory
casinoHome,parsing,0.01s (×9)
casinoHome,app,1.5s            ← Total user experience
homeScreen,app,0.08s           ← Screen visible
homeScreen,parsing,0.003s      ← Match mapping
```
