# Development Journal Entry

## Date
31 October 2025

## Project / Branch
sportsbook-ios / rr/live_scores

## Goals for this session
- Understand EveryMatrix provider architecture and RPC integration patterns
- Integrate `/sports#bettingOptionsV2` WAMP RPC endpoint into ServicesProvider
- Add bet validation feature to BetslipManager in BetssonCameroonApp
- Test RPC endpoint with cWAMP CLI tool before implementation

## Achievements
- [x] Explored EveryMatrix provider structure and identified RPC integration patterns
- [x] Successfully tested `/sports#bettingOptionsV2` RPC endpoint with cWAMP CLI (SINGLE and MULTIPLE bets)
- [x] Created `BettingOptionsV2Response` with EveryMatrix internal models (all optional properties)
- [x] Created `UnifiedBettingOptions` domain model with bonus info structs (`FreeBetInfo`, `OddsBoostInfo`, `StakeBackInfo`)
- [x] Added `getBettingOptionsV2` case to `WAMPRouter` with type-safe `BetGroupingType` conversion
- [x] Created `EveryMatrixModelMapper+BettingOptions` for internal → domain transformation
- [x] Added `calculateUnifiedBettingOptions` method to `BettingProvider` protocol
- [x] Implemented method in `EveryMatrixBettingProvider` with socketConnector integration
- [x] Added stubs to `GomaProvider` and `SportRadarBettingProvider`
- [x] Updated `Client.swift` to pass shared socketConnector to BettingProvider
- [x] Integrated validation into `BetslipManager` with auto-validation triggers and public API
- [x] User refactored to use `BettingOptionsCalculateSelection` (simpler 2-field model)
- [x] User fixed `LoadableContent` state names (`.loaded` instead of `.success`)
- [x] User cleaned up logs (removed emojis)

## Issues / Bugs Hit
- [ ] Initial confusion about using `BetSelection` (full 14-field model) instead of minimal selection model
  - **Resolution**: User created `BettingOptionsCalculateSelection` with only `bettingOfferId` and `oddFormat`
- [ ] Wrong `LoadableContent` enum cases (`.success` instead of `.loaded`)
  - **Resolution**: User corrected to `.loaded(options)` and `.failed` (no parameter)
- [ ] API call went through `bettingProvider?` instead of direct on `servicesProvider`
  - **Resolution**: User moved to `Env.servicesProvider.calculateUnifiedBettingOptions(...)`

## Key Decisions
- **Reused existing `BetGroupingType` enum** instead of creating new enum (reduces duplication)
- **All response model properties are optional** to prevent crashes on API changes
- **Followed exact same patterns as `fetchOddsBoostStairs()`** in BetslipManager (reactive triggers, LoadableContent publisher)
- **Used minimal selection model** (`BettingOptionsCalculateSelection`) with only 2 fields instead of full `BetSelection`
- **3-layer architecture**: EveryMatrix internal models → Mapper → Domain models
- **Shared socketConnector** instance reused from EventsProvider (passed via Client initialization)
- **Auto-validation triggers**: When tickets change, when user logs in (affects bonuses)
- **REST API pattern**: No DTO suffix, no EntityStore, no Builders (follows EveryMatrix REST conventions)

## Experiments & Notes
- Tested RPC endpoint with cWAMP CLI before implementation:
  ```bash
  # SINGLE bet test
  cwamp rpc -p "/sports#bettingOptionsV2" \
    -k '{"type":"SINGLE","selections":[{"bettingOfferId":"...","priceValue":3.8}],...}'
  # Result: minStake: 0.35, odds: 3.8

  # MULTIPLE bet test
  cwamp rpc -p "/sports#bettingOptionsV2" \
    -k '{"type":"MULTIPLE","selections":[...3 selections...],...}'
  # Result: minStake: 0.35, odds: 15.65 (multiplied)
  ```
- Explored EveryMatrix architecture differences:
  - **WebSocket (WAMP)**: 4-layer flow (DTO → Builder → Hierarchical → Mapper → Domain)
  - **REST APIs**: 2-layer flow (Internal → Mapper → Domain) - simpler, already hierarchical
- BetslipManager is a **central service** (not ViewModel), manages betslip state app-wide
- WAMPRouter requires conversion: `BetGroupingType` enum → String ("SINGLE", "MULTIPLE", "SYSTEM")
- Discovered `LoadableContent` enum only has 4 cases: `idle`, `loading`, `loaded(T)`, `failed`

## Useful Files / Links
- [BetslipManager.swift](../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Central betslip service with validation integration
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift) - Implementation with socketConnector
- [BettingOptionsV2Response.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/Response/BettingOptionsV2Response.swift) - EveryMatrix internal models
- [Betting.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift) - Domain models (`UnifiedBettingOptions`, `BettingOptionsCalculateSelection`)
- [WAMPRouter.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPRouter.swift) - RPC endpoint definitions
- [EveryMatrixModelMapper+BettingOptions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+BettingOptions.swift) - Response transformation
- [BettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/BettingProvider.swift) - Protocol definition
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Provider initialization
- [cWAMP Tool](../../tools/wamp-client/) - CLI for testing WAMP RPC endpoints

## Architecture Insights
### EveryMatrix Provider Patterns
- **WAMP RPC calls flow**: Router → SocketConnector → WAMPManager → Response → Mapper → Domain
- **socketConnector shared**: Single instance created in `Client.swift`, passed to both `EveryMatrixEventsProvider` and `EveryMatrixBettingProvider`
- **BetSelectionInfo reused**: Existing model for RPC request (has `bettingOfferId` + `priceValue`)
- **No EntityStore for RPC**: EntityStore only used for WebSocket subscriptions (pub/sub), not RPC calls

### BetslipManager Integration Pattern
- **Publisher-based**: Uses `CurrentValueSubject<LoadableContent<T>, Never>` pattern
- **Auto-validation triggers**: Reactive chains on `bettingTicketsPublisher` and `userProfileStatusPublisher`
- **Same pattern as odds boost**: Follows exact structure of `fetchOddsBoostStairs()` method
- **Model conversion**: `BettingTicket` (app) → `BettingOptionsCalculateSelection` (SP) → `EveryMatrix.BettingOptionsCalculateSelection` (internal)

## Next Steps
1. Test validation in simulator with real betslip flow (add tickets, see min/max stakes)
2. Wire up UI to show validation results (min/max stake labels, bonus badges)
3. Add stake input field validation against min/max constraints
4. Consider adding validation debouncing when stake changes frequently
5. Monitor logs in production to see validation performance (`[BETTING_OPTIONS]` prefix)
6. Document usage examples for other developers consuming `bettingOptionsPublisher`
7. Add unit tests for `validateBettingOptions()` method with mock responses

## Session Statistics
- **Files created**: 3 (BettingOptionsV2Response.swift, EveryMatrixModelMapper+BettingOptions.swift, domain models in Betting.swift)
- **Files modified**: 7 (EveryMatrixBettingProvider, Client, WAMPRouter, BettingProvider protocol, BetslipManager, GomaProvider, SportRadarBettingProvider)
- **Lines added**: ~350 lines of production code
- **RPC endpoint tested**: ✅ Working with both SINGLE and MULTIPLE bet types
- **Architecture compliance**: ✅ Follows EveryMatrix REST patterns (2-layer, no DTO suffix, no EntityStore)
