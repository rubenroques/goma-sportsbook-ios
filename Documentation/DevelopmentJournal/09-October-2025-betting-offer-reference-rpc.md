## Date
09 October 2025

### Project / Branch
sportsbook-ios / rr/rebet

### Goals for this session
- Understand EveryMatrix Provider WAMP architecture (WebSocket, RPCs, Subscriptions)
- Add RPC function to get betting offer IDs from outcome IDs for rebet feature
- Follow 3-layer model architecture (Internal → Mapper → Facade)
- Ensure comprehensive documentation for abstract domain concepts

### Achievements
- [x] Documented EveryMatrix Provider WAMP architecture comprehensively
- [x] Created facade model `OutcomeBettingOfferReference` with extensive documentation
- [x] Created internal model `EveryMatrix.BettingOfferReferenceResponse`
- [x] Created mapper `EveryMatrixModelMapper+BettingOfferReference`
- [x] Added `WAMPRouter.getBettingOfferReference(outcomeId:)` RPC case
- [x] Updated `EventsProvider` protocol with documented method signature
- [x] Implemented `getBettingOfferReference()` in `EveryMatrixProvider`
- [x] Added stub implementation in `SportRadarEventsProvider`

### Issues / Bugs Hit
- None - implementation went smoothly following established patterns

### Key Decisions
- **Function naming**: Chose `getBettingOfferReference` over generic name to clearly indicate it's a reference/lookup operation
- **Language hardcoding**: Hardcoded `"en"` in WAMPRouter kwargs following established pattern from `PreLiveMatchesPaginator` (line 149)
- **Single outcome only**: Function accepts single outcome ID (not array) since rebet reconstructs one selection at a time
- **Return type**: Created dedicated facade model instead of raw dictionary to maintain type safety and domain clarity
- **Documentation priority**: Added extensive inline docs explaining the abstract outcome→betting-offer relationship, critical for future maintainability

### Experiments & Notes
- Explored WAMP Manager implementation - discovered two communication patterns:
  - **RPCs**: Request/response for one-time data fetches
  - **Subscriptions**: Real-time streaming with initial dump + incremental updates
- Studied entity store architecture - subscriptions maintain internal entity stores for memory-efficient incremental updates
- RPC endpoint `/sports#oddsByOutcomes` maps outcome IDs to event ID + betting offer IDs
- Response structure: `{"bettingOfferIdsByEventId": {"eventId": ["offerId1", "offerId2"]}, "allBettingOffersFound": true}`

### Architecture Insights: EveryMatrix Provider

#### WAMP Protocol Layers
1. **Connection Layer** (`WAMPManager`):
   - WebSocket: `wss://sportsapi-betsson-stage.everymatrix.com/v2`
   - Realm: `www.betsson.cm`
   - Session state monitoring with auto-reconnect

2. **RPC Pattern** (Request → Response):
   - One-time data fetches
   - Examples: search, match details, operator info
   - Method: `getModel<T: Decodable>(router: WAMPRouter, decodingType: T.Type)`

3. **Subscription Pattern** (Subscribe → Initial Dump → Updates):
   - Real-time streaming data
   - Examples: live odds, match scores, account balance
   - Method: `subscribeEndpoint<T: Decodable>(_:decodingType:)`
   - Content types: `.connect`, `.initialContent`, `.updatedContent`, `.disconnect`

#### 3-Layer Model Architecture
```
Internal Models (EveryMatrix namespace)
    ↓ (via Model Mappers)
Facade Models (Public API)
    ↓ (consumed by)
App Layer (ViewModels)
```

### Useful Files / Links
- [OutcomeBettingOfferReference.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/OutcomeBettingOfferReference.swift) - Facade model with comprehensive documentation
- [EveryMatrix+BettingOfferReference.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+BettingOfferReference.swift) - Internal API response model
- [EveryMatrixModelMapper+BettingOfferReference.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+BettingOfferReference.swift) - Mapper implementation
- [WAMPRouter.swift:33](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift) - RPC case definition
- [EventsProvider.swift:110](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Protocol method signature
- [EveryMatrixProvider.swift:742](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Implementation
- [CLAUDE.md](../../CLAUDE.md) - Project architecture documentation
- [API_DEVELOPMENT_GUIDE.md](../../Documentation/API_DEVELOPMENT_GUIDE.md) - 3-layer architecture guide

### Testing Notes
Can test RPC with cWAMP CLI tool:
```bash
cwamp --url wss://sportsapi-betsson-stage.everymatrix.com/v2 \
      --realm www.betsson.cm \
      --rpc "/sports#oddsByOutcomes" \
      --kwargs '{"lang":"en","outcomeIds":["281887009723020544"]}' \
      --verbose
```

Expected response:
```json
{
  "bettingOfferIdsByEventId": {
    "281887009513017344": ["281961032314902016"]
  },
  "allBettingOffersFound": true,
  "message": "All selections were added"
}
```

### Next Steps
1. Integrate `getBettingOfferReference()` into rebet feature in BetssonCameroonApp
2. Handle edge cases:
   - Outcome no longer available (allOffersFound: false)
   - Multiple betting offers per outcome (if they exist)
   - Network errors and timeouts
3. Add unit tests for mapper logic
4. Test rebet flow end-to-end with real betting history data
