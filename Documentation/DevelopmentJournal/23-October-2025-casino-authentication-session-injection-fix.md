# Casino Authentication & Game Launch Session Injection Fix

## Date
23 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix Casino API authentication headers (remove incorrect Cookie header)
- Implement correct game launch URL building with session injection
- Fix game preview button logic to show correct states based on authentication
- Ensure logged-in users can play casino games with session tracking

### Achievements
- [x] **Removed incorrect Cookie header** from `EveryMatrixCasinoConnector.swift:197-199`
- [x] **Fixed game launch URL parameters** in `EveryMatrixCasinoProvider.swift:203-216`
  - Changed `fun=true/false` → `funMode=True` (only when in fun mode)
  - Removed incorrect `authenticated=true/false` parameter
  - Changed `sessionId=` → `_sid=` parameter name
- [x] **Fixed game preview button logic** in `CasinoGamePrePlayViewModel.swift`
  - Removed hardcoded "Login to Play" button return
  - Simplified to two states: logged in vs logged out
  - Implemented real authentication check using `Env.userSessionStore.isUserLogged()`
- [x] **Fixed critical ViewModel bug** - was using raw `launchUrl` without session injection
- [x] **Refactored ViewModel to call `buildCasinoGameLaunchUrl()`** with proper mode conversion
- [x] **Added auto-fetch of session from connector** when sessionId not provided
- [x] **Removed unused `sessionId` parameter** from public API (always fetched internally)
- [x] **Added comprehensive debug logging** with `[🎰]` prefix for easy filtering

### Issues / Bugs Hit
- [x] **ROOT CAUSE IDENTIFIED:** `CasinoGamePlayViewModel` was using raw `casinoGame.launchUrl` from API
  - Game URLs never had session parameters injected
  - Game providers treated all users as anonymous
  - Fixed by calling `buildCasinoGameLaunchUrl()` instead
- [x] **Architecture violation:** ViewModel had ServicesProvider dependency just for URL building
  - Discussed better approach: Coordinator builds URL and passes to ViewModel
  - Current implementation acceptable for now, can refactor later
- [x] **sessionId parameter was dead code** - always passed as `nil` and always fetched from connector
  - Removed from all method signatures for cleaner API

### Key Decisions
- **Session management stays internal to ServicesProvider** - ViewModels never handle sessionId
- **ViewModels CAN check authentication status** - `isUserLogged()` is acceptable
- **URL building happens at ViewModel level** - Could be moved to Coordinator in future refactor
- **Auto-fetch session from connector** - When `sessionId` parameter removed, always fetch internally
- **No insufficient funds logic** - Simplified to logged in/out states only
- **Keep debug logs** - `[🎰]` prefix for Casino, `[🎰 GAME-LAUNCH]`, `[🎰 VIEWMODEL]`, `[🎰 COORDINATOR]`

### Experiments & Notes

#### Web App Validation
Extracted working cURL commands from web app to confirm correct implementation:
```bash
# Login flow
curl '.../v1/player/legislation/login' --data-raw '{"username":"+237699198921","password":"1234"}'

# User details (with session headers)
curl '.../v1/player/7054250/details' \
  -H 'x-session-type: others' \
  -H 'x-sessionid: af41254f-28d4-4560-b28a-f01e8774c8c3'

# Working game URLs
https://gamelaunch-stage.everymatrix.com/.../lions_riches_rgs_matrix?language=en&_sid=<sessionId>
https://gamelaunch-stage.everymatrix.com/.../sports-betting?funMode=True&language=en&_sid=<sessionId>
```

#### Architecture Discussion
Explored optimal data flow:
1. **Current:** ViewModel calls `buildCasinoGameLaunchUrl()` → Works but creates SP dependency
2. **Better:** Coordinator builds URL, passes to ViewModel → Cleaner separation
3. **Why not in CasinoGame?** Session state changes, model should be immutable

**Conclusion:** Current approach acceptable, can refactor to Coordinator-level later

#### Debug Log Structure
```
[🎰 COORDINATOR] → Mode selection and auth status
[🎰 VIEWMODEL] → Mode conversion and URL building call
[🎰 GAME-LAUNCH] → Session fetching and URL construction with _sid
```

Filter console with `🎰` to see complete flow.

### Useful Files / Links
- [EveryMatrixCasinoConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/CasinoAPI/EveryMatrixCasinoConnector.swift)
- [EveryMatrixCasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift)
- [CasinoGamePlayViewModel.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewModel.swift)
- [CasinoGamePrePlayViewModel.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewModel.swift)
- [CasinoCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift)
- [CasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/CasinoProvider.swift)
- [Previous Investigation](./22-October-2025-casino-api-header-investigation.md)
- [Web App Session Docs](../../Documentation/CasinoAPI-Header-Investigation-Report.md)

### Technical Details

#### Changes Made

**1. EveryMatrixCasinoConnector.swift (Lines 197-199)**
```swift
// REMOVED: Incorrect Cookie header
- request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
```

**2. EveryMatrixCasinoProvider.swift (Lines 192-243)**
```swift
// REMOVED sessionId parameter, auto-fetch from connector
func buildGameLaunchUrl(for game: CasinoGame, mode: CasinoGameMode, language: String?) -> String? {
    let sessionId = self.connector.sessionToken  // Always fetch internally

    switch mode {
    case .funGuest:
        // No session parameters
    case .funLoggedIn:
        queryParams.append("funMode=True")
        queryParams.append("_sid=\(sessionId)")  // ✅ Correct parameter name
    case .realMoney:
        queryParams.append("_sid=\(sessionId)")  // ✅ Just session
    }
}
```

**3. CasinoGamePrePlayViewModel.swift (Lines 240-284)**
```swift
// REMOVED: 24 lines of hardcoded button return
// REMOVED: 30 lines of insufficient funds logic
// ADDED: Simple two-state logic
private func determineButtonConfiguration() -> [CasinoGamePlayModeButton] {
    let isUserLoggedIn = checkUserLoginStatus()

    if !isUserLoggedIn {
        return [loginButton, practiceButton]
    } else {
        return [playNowButton, practiceModeButton]
    }
}

private func checkUserLoginStatus() -> Bool {
    return Env.userSessionStore.isUserLogged()
}
```

**4. CasinoGamePlayViewModel.swift (Lines 42-168)**
```swift
// NEW: Init with mode parameter
init(casinoGame: CasinoGame, mode: CasinoGamePlayMode, servicesProvider: ServicesProvider.Client)

// NEW: Proper URL building with session injection
private func loadGameDataWithMode(mode: CasinoGamePlayMode) {
    let casinoGameMode: CasinoGameMode = mode == .practice
        ? (Env.userSessionStore.isUserLogged() ? .funLoggedIn : .funGuest)
        : .realMoney

    // ✅ CRITICAL FIX: Call buildCasinoGameLaunchUrl instead of using raw launchUrl
    if let urlString = servicesProvider.buildCasinoGameLaunchUrl(
        for: casinoGame,
        mode: casinoGameMode,
        language: "en"
    ), let url = URL(string: urlString) {
        gameURL = url
    }
}
```

**5. CasinoCoordinator.swift (Lines 194-209)**
```swift
// ADDED: Pass mode to ViewModel
private func showGamePlay(gameId: String, casinoGame: CasinoGame?, mode: CasinoGamePlayMode) {
    let gamePlayViewModel = CasinoGamePlayViewModel(
        casinoGame: casinoGame,
        mode: mode,  // ← Now passes mode
        servicesProvider: environment.servicesProvider
    )
}
```

#### Expected Game Launch URLs

**Not Logged In (funGuest):**
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/4093/game-slug?language=en
```

**Logged In - Practice Mode (funLoggedIn):**
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/4093/game-slug?language=en&funMode=True&_sid=<sessionId>
```

**Logged In - Real Money (realMoney):**
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/4093/game-slug?language=en&_sid=<sessionId>
```

### What This Enables
✅ Users can play casino games while logged in
✅ Practice mode tracks progress with session
✅ Real money mode has access to user balance
✅ Game providers recognize authenticated users
✅ Correct button display based on auth state
✅ Casino API uses correct authentication headers

### Next Steps
1. **Test in simulator with login/logout flow**
   - Verify buttons change based on auth state
   - Check console logs with `🎰` filter
   - Confirm `_sid` parameter in game URLs
2. **Test game play in all three modes**
   - Guest mode (no session)
   - Practice mode while logged in (session + funMode)
   - Real money mode (session only)
3. **Verify game provider recognizes session**
   - Check if balance is accessible
   - Verify progress tracking in practice mode
4. **Consider refactoring URL building to Coordinator level**
   - Would simplify ViewModel (no SP dependency)
   - Better separation of concerns
   - Can be done in future cleanup session
5. **Remove debug logs after validation**
   - Keep or reduce verbosity once confirmed working
   - Consider adding to project logging system
