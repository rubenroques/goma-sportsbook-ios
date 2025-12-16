## Date
16 December 2025

### Project / Branch
sportsbook-ios / single_code

### Goals for this session
- Fix deprecated cashout SSE endpoint (503 error)
- Update SSEConnector to support POST with JSON body
- Wire cashout values in MyBets UI
- Implement ViewModel caching to prevent SSE reconnection on scroll

### Achievements
- [x] Updated `EveryMatrixSSEConnector` to support POST method and request body
- [x] Updated `EveryMatrixOddsMatrixWebAPI.getCashoutValueSSE` endpoint:
  - Changed from `GET /cashout/v1/cashout-value/{betId}` (deprecated, returns 503)
  - To `POST /bets-api/v1/{operatorId}/cashout-value-updates` with `{"betIds": [...]}`
  - Updated headers: `Content-Type: application/json`, lowercase `x-session-id`, `x-user-id`
- [x] Updated `EveryMatrixBettingProvider.subscribeToCashoutValue` to use new endpoint
- [x] Wired static cashout data in `TicketBetInfoViewModel.createTicketBetInfoData`:
  - Now shows `partialCashoutValue` and `cashoutTotalAmount` from `myBet.partialCashoutReturn`
  - Added `overrideCashoutValue` parameter for future SSE updates
- [x] Created `TicketBetInfoViewModelCache` (LRU cache with max 20 entries)
  - Thread-safe with concurrent DispatchQueue
  - Prevents ViewModel recreation on scroll
  - Preserves SSE subscriptions when cells are reused
- [x] Integrated cache in `MyBetsViewModel.createTicketViewModels`
- [x] Added cache invalidation on logout (security)
- [x] Build verified: BetssonCM UAT compiles successfully

### Issues / Bugs Hit
- [x] `HTTP.Method` uses `.value()` not `.rawValue` - fixed

### Key Decisions
- **Per-ViewModel SSE subscriptions** (not shared at MyBetsViewModel level)
  - Simpler ownership model
  - Cache preserves subscriptions across cell reuse
  - Each ViewModel manages its own cashout stream lifecycle
- **LRU cache size = 20** (1 page worth of bets)
  - Balances memory usage vs scroll performance
  - Prevents 100+ SSE connections for users with many open bets

### Experiments & Notes
- Verified OLD endpoint returns 503 on both STG and PROD
- Verified NEW endpoint works with cURL tests
- Web/Android use similar per-bet subscription pattern with caching

### Useful Files / Links
- [EveryMatrixSSEConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSSEConnector.swift)
- [EveryMatrixOddsMatrixWebAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixWebAPI/EveryMatrixOddsMatrixWebAPI.swift)
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)
- [TicketBetInfoViewModelCache.swift](../../BetssonCameroonApp/App/Screens/MyBets/Cache/TicketBetInfoViewModelCache.swift)
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift)
- [Plan File](~/.claude/plans/foamy-wondering-lamport.md)
- [Cashout SSE Business Logic](../../../CoreMasterAggregator/Documentation/Cashout_SSE_Business_Logic.md)

### Next Steps
1. Add SSE subscription to `TicketBetInfoViewModel` (real-time cashout updates)
2. Wire slider calculations (formula: `partialValue = (fullValue × sliderAmount) / totalStake`)
3. Implement cashout state machine (slider → loading → success/failed)
4. Test with real open bet to verify end-to-end flow
5. Wire cashout execution button to `executeCashout` API
