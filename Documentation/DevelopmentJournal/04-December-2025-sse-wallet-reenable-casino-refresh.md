## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Re-enable SSE for wallet updates only (ignore session expiration)
- Add wallet refresh when closing casino game
- Investigate why SSE wallet updates not working during casino play

### Achievements
- [x] Re-enabled SSE stream for real-time wallet updates
- [x] Modified session expiration handling to log-only (no forced logout, no popup)
- [x] Added `forceRefreshUserWallet()` call in `CasinoGamePlayViewController.viewWillDisappear`
- [x] Documented Bootstrap restart flow - SSE correctly restarts after language change
- [x] Analyzed SSE logs and identified server-side issue

### Issues / Bugs Hit
- [x] **SSE connection immediately closed by server** - EveryMatrix SSE endpoint (`/v2/player/{userId}/information/updates`) accepts connection but closes immediately without sending any data
  - Connection opens successfully (auth passes)
  - No BALANCE_UPDATE messages ever received
  - Server closes connection within milliseconds
  - Results in constant reconnection loop (connect → open → close → reconnect)
  - **Root cause**: Likely SSE not enabled for Cameroon operator (4374) on backend

### Key Decisions
- **SSE re-enabled with session expiration disabled** - SSE used only for wallet updates, REST token refresh handles real session expiration
- **REST fallback as primary wallet refresh** - Since SSE is non-functional, `forceRefreshUserWallet()` in casino close provides reliable updates
- **Minimal code changes** - Only touched `UserSessionStore.swift` and `CasinoGamePlayViewController.swift`
- **Message drafted for PlayerAPI team** - To investigate why SSE endpoint closes connections immediately

### Experiments & Notes
**SSE Log Pattern (non-functional):**
```
State: connecting -> open
[SSEDebug] ✅ SSEEventHandlerAdapter: Connection opened
Connection unexpectedly closed.
[SSEDebug] 🔌 UserInfoStreamManager: SSE disconnected
[SSEDebug] 🔄 UserInfoStreamManager: Reconnecting in 0.2s (attempt 1/6)
```
- No `[SSEDebug] 📨` logs = no messages received
- Pattern repeats indefinitely

**Bootstrap Restart Flow (works correctly):**
1. `Bootstrap.restart()` → `servicesProvider.disconnect()`
2. New `MainTabBarViewController` → `unlockAppWithUser()` → `login()`
3. Login success → `userProfilePublisher.send(profile)` triggers sink
4. Sink calls `startUserInfoSSEStream()` with defensive code to stop old stream first

### Useful Files / Links
- [UserSessionStore.swift](../../BetssonCameroonApp/App/Services/UserSessionStore.swift) - SSE stream management, session expiration handling
- [CasinoGamePlayViewController.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift) - Added wallet refresh on close
- [28-November-2025-disable-sse-wallet-cameroon.md](./28-November-2025-disable-sse-wallet-cameroon.md) - Previous session that disabled SSE
- [UserInfoStreamManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/SubscriptionManagers/UserInfoStreamManager.swift) - SSE stream manager

### Next Steps
1. **Contact PlayerAPI team** - Ask if SSE is enabled for operator 4374 (Cameroon)
2. **Monitor REST wallet refresh** - Verify `forceRefreshUserWallet()` works reliably on casino close
3. **Re-test SSE** once backend team confirms it's enabled/fixed
4. **Consider disabling SSE startup** if server issue persists (to avoid reconnection loop overhead)
