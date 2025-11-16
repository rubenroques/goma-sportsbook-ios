# Development Journal

## Date
16 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Migrate custom SSEManager to LDSwiftEventSource library for cashout SSE
- Implement UserInfo SSE stream manager for real-time wallet + session updates
- Follow WebApp hybrid REST + SSE pattern exactly

### Achievements
- [x] Successfully migrated cashout SSE from custom SSEManager to LDSwiftEventSource
  - Created reusable `SSEEventHandlerAdapter<T>` for callback → Combine bridging
  - Deleted 318 lines of custom SSE parsing code
  - Maintained exact same external API (`SSEStreamEvent` enum)
- [x] Implemented complete UserInfo SSE stream infrastructure (10 new files, 570 lines)
  - `UserInfo` domain model (wallet + session state container)
  - `BalanceUpdateEvent` with transaction type/operation enums (matches WebApp)
  - `EveryMatrix+UserInfoSSEResponse` and `EveryMatrix+BalanceUpdateBody` internal models
  - `EveryMatrixModelMapper+UserInfoSSE` for applying SSE deltas to wallet snapshots
  - `UserInfoStreamManager` with hybrid REST + SSE pattern (~280 lines)
  - Added `/v2/player/{userId}/information/updates` SSE endpoint to PlayerAPI
  - Extended `PrivilegedAccessManager` protocol with 3 new methods
  - Integrated manager into `EveryMatrixPAMProvider` with SSE connector support
- [x] Successfully built project after fixing all compilation errors

### Issues / Bugs Hit
- [ ] **UserWallet field naming confusion** - Initially assumed fields like `totalDouble`, `withdrawableDouble`, `bonusDouble` existed
  - Actual structure: paired fields `{name}String: String?` and `{name}: Double?` (e.g., `totalString`/`total`)
  - Fixed by reading existing `EveryMatrixModelMapper+WalletBalance.swift` for pattern reference
- [ ] **SessionCoordinator API misunderstanding** - Used `userId()` (Publisher) instead of `currentUserId` (String?)
  - Fixed by matching `getUserBalance()` implementation in PAMProvider
- [ ] **REST connector signature** - Added unnecessary `decodingType` parameter (inferred from return type)
  - Fixed by studying existing REST connector usage
- [ ] **SubscribableContent missing `.sessionExpired` case** - Assumed this case existed
  - Fixed by emitting `.contentUpdate` with `UserInfo.sessionState = .expired` instead

### Key Decisions
- **Chose LDSwiftEventSource over custom implementation**
  - Pros: Battle-tested, auto-reconnection, exponential backoff, spec-compliant
  - Cons: External dependency, not optimized for one-shot requests
  - Decision: Accept dependency for maintainability (cashout + user info both use SSE)
- **Manual lifecycle control for UserInfo stream**
  - App explicitly calls `subscribeUserInfoUpdates()` / `stopUserInfoStream()`
  - Not auto-started on login (app decides when to enable real-time updates)
- **Imperative force refresh pattern**
  - `refreshUserBalance()` void method emits via same publisher
  - Alternative (rejected): Return separate publisher for refresh
- **Session expiration as content update, not separate event**
  - `SubscribableContent` has no `.sessionExpired` case
  - Solution: Emit `.contentUpdate` with `sessionState = .expired(reason: nil)`
  - App layer decides logout behavior (matches WebApp flexibility)

### Experiments & Notes
- **LDSwiftEventSource Config exploration**:
  ```swift
  config.idleTimeout = 5.0  // Matches current SSEManager default
  config.reconnectTime = 1.0  // Initial retry delay
  config.maxReconnectTime = 30.0  // Cap at 30s (WebApp pattern)
  ```
- **SSE message format from EveryMatrix**:
  ```
  data: {"type":"BALANCE_UPDATE_V2","body":{...}}\n\n
  data: {"type":"SESSION_EXPIRATION_V2"}\n\n
  ```
- **Balance update merge logic** (critical for correctness):
  - SSE sends `afterAmount` (new balance), not `affectedAmount` (delta)
  - Real balance updates both `total` and `withdrawable`
  - Bonus balance updates only `bonus`
  - Must recalculate `total = Real + Bonus` after each update

### Code Review Feedback Received
Developer flagged 9 issues - analyzed and categorized:

**❌ False Alarms (2)**:
1. "Missing automatic reconnection" - **Already implemented** in LDSwiftEventSource library
2. "Missing User-Agent header" - **Already added** in PlayerAPI endpoint headers

**🐛 Critical Bugs (2)** - **NEED TO FIX**:
1. Double assignment of `total` in balance update logic
2. Session expiration doesn't stop SSE stream (keeps reconnecting with invalid token)

**⚠️ Valid Concerns (3)** - **SHOULD ADDRESS**:
1. Missing `totalCashAmount` vs `totalAmount` distinction
2. No auto-refresh REST balance after SSE reconnection
3. No deduplication logic for duplicate SSE events (same `postingId`)

**🤷 Design Choices (2)** - **App layer responsibility**:
1. No app lifecycle handling (background/foreground)
2. No balance persistence/caching

### Useful Files / Links
- [UserInfoStreamManager](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/SubscriptionManagers/UserInfoStreamManager.swift)
- [SSEEventHandlerAdapter](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/SSEClient/SSEEventHandlerAdapter.swift)
- [EveryMatrixModelMapper+UserInfoSSE](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+UserInfoSSE.swift)
- [UserInfo Domain Model](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/UserInfo.swift)
- [BalanceUpdateEvent](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/BalanceUpdateEvent.swift)
- [WebApp SSE Implementation Reference](../../../Documentation/balance-stream/) - WebApp docs in web project
- [LDSwiftEventSource GitHub](https://github.com/launchdarkly/swift-eventsource) - v3.3.0
- [EveryMatrix PlayerAPI Endpoints](../../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/EveryMatrixPlayerAPI.swift)

### Architecture Insights
**Hybrid REST + SSE Pattern** (from WebApp):
```
1. REST Snapshot: GET /v2/player/{userId}/balance
   → Initial UserWallet with all balance types

2. SSE Stream: GET /v2/player/{userId}/information/updates
   → BALANCE_UPDATE_V2: Delta updates (afterAmount)
   → SESSION_EXPIRATION_V2: Session timeout

3. Merge Logic: Apply SSE afterAmount to REST snapshot
   → Real: Update total + withdrawable
   → Bonus: Update bonus
   → Recalculate: total = Real + Bonus
```

**Two-Layer Model Flow** (REST models):
```
SSE JSON
  ↓
EveryMatrix.UserInfoSSEResponse (internal)
  ↓
EveryMatrixModelMapper
  ↓
UserInfo (domain model)
```

**NOT** the 4-layer WebSocket flow (DTO → Builder → Hierarchical → Domain)

### Next Steps
1. **Fix critical bugs** (#2, #5 from code review):
   - Remove double `total` assignment in `applyBalanceUpdate()`
   - Call `stop()` in `handleSessionExpiration()`
2. **Handle totalCashAmount field** (#3):
   - Read UserWallet structure to understand totalCashAmount vs totalAmount
   - Update mapper to set both fields correctly
3. **Add auto-refresh after reconnect** (#7):
   - Detect SSE reconnection (onOpened after onClosed)
   - Fetch fresh REST balance to catch missed updates
4. **Test real SSE integration**:
   - Login to staging environment
   - Subscribe to user info stream
   - Place bet to trigger BALANCE_UPDATE_V2
   - Verify balance updates correctly
5. **Consider deduplication** (#9):
   - Check if backend sends duplicate events
   - If yes, track `postingId` and skip duplicates
6. **Documentation**:
   - Update CLAUDE.md with UserInfo SSE usage examples
   - Add UserInfoStreamManager to provider documentation

### Performance Notes
- **Context usage**: Started at 200k tokens, ended at ~54k remaining
- **Files created**: 10 files (6 new, 4 updated)
- **Lines of code**: ~570 lines total
- **Build time**: No significant impact (Swift package build)
- **Dependencies added**: LDSwiftEventSource already in Package.swift

### Migration Notes for Future Reference
**If migrating other SSE endpoints**:
1. Use `SSEEventHandlerAdapter<T>` for callback → Combine bridge
2. Return `AnyPublisher<SSEStreamEvent, ServiceProviderError>`
3. Consumer decodes `MessageEvent.data` manually
4. Don't create custom SSE parsers - use LDSwiftEventSource

**Common pitfalls**:
- Don't assume UserWallet field names (check actual struct)
- SessionCoordinator methods: `currentUserId` (String?), NOT `userId()` (Publisher)
- REST connector: `request(endpoint)` (no decodingType param)
- SubscribableContent cases: `.connected`, `.contentUpdate`, `.disconnected` only

### Testing Checklist
- [ ] Cashout SSE still works with LDSwiftEventSource
- [ ] UserInfo stream connects successfully
- [ ] Initial balance fetched via REST
- [ ] BALANCE_UPDATE_V2 updates wallet correctly
- [ ] SESSION_EXPIRATION_V2 emits content update with expired state
- [ ] Force refresh updates balance while SSE continues
- [ ] Stop cleans up resources properly
- [ ] SSE reconnects automatically after network interruption
- [ ] No memory leaks (UserInfoStreamManager deinit called)
