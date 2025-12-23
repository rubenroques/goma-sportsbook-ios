## Date
23 December 2025

### Project / Branch
sportsbook-ios / rr/swift-lint-fixes

### Goals for this session
- Diagnose and fix infinite SSE reconnection loop on 403 errors
- Stop cashout SSE from spamming reconnection attempts when authentication fails

### Achievements
- [x] Identified root cause: `SSEEventHandlerAdapter.onError()` treats ALL errors as reconnectable
- [x] Found that `reconnectTime = 0.0` doesn't disable LDSwiftEventSource auto-reconnect (sets delay to 0ms)
- [x] Implemented fix: detect 401/403 `UnsuccessfulResponseError` and terminate stream instead of reconnecting
- [x] Added EventSource cleanup on auth errors to prevent zombie connections

### Issues / Bugs Hit
- [x] **Infinite loop on 403**: SSE cashout subscriptions hitting 403 → treated as disconnect → instant reconnect → 403 → loop forever
- [ ] **Build verification interrupted**: Need to verify fix compiles with LDSwiftEventSource types

### Key Decisions
- **Terminate stream on 401/403 errors** instead of allowing reconnection
  - **Rationale**: Auth errors won't resolve by reconnecting - session is invalid
  - **Impact**: Stops infinite loop, saves battery/network, provides clear error to UI
- **Keep reconnection for network errors** (timeouts, connection failures)
  - **Rationale**: These are transient and reconnection is appropriate behavior

### Experiments & Notes
- `reconnectTime = 0.0` in LDSwiftEventSource config does NOT disable auto-reconnect
- The library's `UnsuccessfulResponseError` contains `responseCode` property for HTTP status
- UserInfoStreamManager already has proper reconnection handling (exponential backoff, max retries)
- Cashout SSE lacks a manager - uses direct `sseConnector.request()` from ViewModel

### Useful Files / Links
- [SSEEventHandlerAdapter.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/SSEClient/SSEEventHandlerAdapter.swift) - **Modified**: Added 401/403 detection
- [EveryMatrixSSEConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSSEConnector.swift) - SSE connector with reconnectTime=0 config
- [UserInfoStreamManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/SubscriptionManagers/UserInfoStreamManager.swift) - Reference for proper reconnection handling
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - SSE subscription consumer
- [15-October-2025-everymatrix-sse-cashout-authentication.md](./15-October-2025-everymatrix-sse-cashout-authentication.md) - Original SSE implementation

### Code Change Summary

**SSEEventHandlerAdapter.swift** - `onError()` method:
```swift
// Before: All errors treated as disconnections → reconnect
subject.send(.disconnected)

// After: Check for auth errors → terminate stream
if let unsuccessfulError = error as? UnsuccessfulResponseError {
    if responseCode == 401 || responseCode == 403 {
        eventSource?.stop()
        subject.send(completion: .failure(serviceError))
        return
    }
}
subject.send(.disconnected) // Only for network errors
```

### Next Steps
1. Build and verify fix compiles (check `UnsuccessfulResponseError` import)
2. Test with BetssonCameroonApp in simulator
3. Consider adding exponential backoff for cashout SSE (like UserInfoStreamManager)
4. Document SSE error handling patterns for future reference
