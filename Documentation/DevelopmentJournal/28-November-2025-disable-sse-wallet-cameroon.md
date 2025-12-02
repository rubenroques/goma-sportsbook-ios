## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Disable SSE wallet/session implementation for BetssonCameroonApp
- Revert to previous REST-based wallet fetching
- Remove session expiration logic from SSE

### Achievements
- [x] Replaced SSE stream startup with REST wallet fetch on login
- [x] Removed SSE stop call from logout flow
- [x] Preserved SSE infrastructure in ServicesProvider (unused but available)

### Issues / Bugs Hit
- None

### Key Decisions
- **Minimal changes approach**: Instead of removing SSE code entirely, simply stopped calling it
- **Dead code left in place**: `startUserInfoSSEStream()` and `stopUserInfoSSEStream()` methods remain but are never called
- **No feature flags**: User opted for simple approach over configuration-based toggle
- **ServicesProvider untouched**: SSE implementation remains intact for potential future use or other targets

### Experiments & Notes
- SSE implementation was using `LDSwiftEventSource` library with hybrid REST+SSE pattern
- SSE provided: real-time wallet balance updates (`BALANCE_UPDATE_V2`) and session expiration (`SESSION_EXPIRATION_V2`)
- REST fallback in `forceRefreshUserWallet()` now always executes since `isWalletSubscriptionActive` stays `false`

### Useful Files / Links
- [UserSessionStore.swift](../../BetssonCameroonApp/App/Services/UserSessionStore.swift) - Main changes here
- [EveryMatrixPAMProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixPAMProvider.swift) - SSE provider (unchanged)
- [UserInfoStreamManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/SubscriptionManagers/UserInfoStreamManager.swift) - SSE stream manager (unused now)

### Next Steps
1. Test wallet balance fetching works correctly via REST after login
2. Verify logout flow works without SSE cleanup
3. Consider removing dead SSE code from UserSessionStore if not needed in future
