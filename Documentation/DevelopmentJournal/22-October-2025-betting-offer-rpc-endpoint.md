# Development Journal Entry

## Date
22 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Understand EveryMatrix WAMP WebSocket RPC and PubSub patterns
- Add RPC endpoint to fetch single betting offer data without subscription overhead
- Expose new API through ServicesProvider Client

### Achievements
- [x] Explored EveryMatrix WAMP architecture (RPC vs Subscription patterns)
- [x] Documented `bettingOfferPublisher` subscription flow (WAMPRouter → SingleOutcomeSubscriptionManager → Client API)
- [x] Added RPC case `getBettingOffer` to WAMPRouter.swift
- [x] Implemented `getEventWithSingleOutcome(bettingOfferId:)` in EveryMatrixProvider
- [x] Added protocol method to EventsProvider.swift with comprehensive documentation
- [x] Exposed public API in Client.swift
- [x] Added stub implementations for GomaProvider and SportRadarEventsProvider (protocol conformance)
- [x] Tested RPC endpoint using cWAMP tool - verified working correctly

### Issues / Bugs Hit
- None encountered - implementation went smoothly following existing patterns

### Key Decisions
- **Parameter simplification**: Used only `bettingOfferId` (not `eventId + outcomeId`) since eventId is included in response
- **No EntityStore persistence**: Reused existing `buildEvent(from:expectedMatchId:)` helper with temporary store pattern (same as `getEventWithMainMarkets`)
- **Stub implementations**: Other providers (Goma, SportRadar) return `notSupportedForProvider` error - only EveryMatrix has full implementation

### Experiments & Notes
- **WAMP Protocol Deep Dive**:
  - RPC: Request-response pattern (`/sports#initialDump` with topic parameter)
  - Subscription: Persistent connection with initial dump + delta updates
  - Key difference: Subscriptions use normalized data (EntityStore required), RPC returns hierarchical data

- **cWAMP Testing**:
  ```bash
  # Subscription (continuous updates)
  cwamp subscribe -t "/sports/4093/en/bettingOffers/284452380326634752" --initial-dump

  # RPC (one-time fetch) - NEW
  cwamp rpc -p "/sports#initialDump" -k '{"topic":"/sports/4093/en/bettingOffers/284452380326634752"}'
  ```

- **Response Structure**: Both return same 5 entities (MATCH, MARKET, OUTCOME, MARKET_OUTCOME_RELATION, BETTING_OFFER)

### Useful Files / Links
- [WAMPRouter.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift) - Lines 36, 142, 311-313
- [EveryMatrixProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Lines 796-820
- [EventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Lines 112-123
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Lines 908-916
- [SingleOutcomeSubscriptionManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/SingleOutcomeSubscriptionManager.swift) - Reference for subscription pattern
- [cWAMP Tool](../../tools/wamp-client/) - CLI tool for WAMP protocol testing

### Architecture Notes

**WAMP Flow for Betting Offer**:
```
Subscription (existing):
WAMPRouter.bettingOfferPublisher
  ↓
SingleOutcomeSubscriptionManager
  ↓ (manages lifecycle, EntityStore)
EveryMatrixProvider.subscribeToEventWithSingleOutcome
  ↓
Client.subscribeToEventWithSingleOutcome
  → Returns: AnyPublisher<SubscribableContent<Event>, Error>

RPC (new - this session):
WAMPRouter.getBettingOffer
  ↓ (no manager, temporary store)
EveryMatrixProvider.getEventWithSingleOutcome
  ↓
Client.getEventWithSingleOutcome
  → Returns: AnyPublisher<Event, Error>
```

**Use Cases**:
- Subscription: Betslip live odds tracking (continuous updates)
- RPC: Quick validation, initial load, rebet feature (one-time fetch)

### Next Steps
1. Test new RPC endpoint in BetssonCameroonApp betslip flow
2. Consider using RPC for initial betslip load, then upgrade to subscription for live tracking
3. Update betslip ViewModel to use new `getEventWithSingleOutcome` for initial odds fetch
4. Document performance comparison: RPC vs Subscription for different betslip scenarios
