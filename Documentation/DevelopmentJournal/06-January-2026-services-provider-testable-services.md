## Date
06 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests (brainstorming session, no code merged yet)

### Goals for this session
- Brainstorm strategy to improve ServicesProvider testability
- Design architecture for breaking down monolithic `Client.swift` (~3000 lines)
- Create first Protocol Witness services following pointfree.co pattern

### Achievements
- [x] Analyzed existing testability document from CoreMasterAggregator
- [x] Discovered protocols already exist (`BettingProvider`, `EventsProvider`, etc.) but aren't exposed publicly
- [x] Identified the real problem: `Client.swift` is a 2981-line God Object forwarding to internal providers
- [x] Designed 3-phase refactoring strategy (Expose → Deprecate → Remove)
- [x] Moved `CashoutService` from BetssonCameroonApp to ServicesProvider (Protocol Witness pattern)
- [x] Created `WalletService` in ServicesProvider following same pattern
- [x] Created `TESTABLE_SERVICES.md` tracking document with 13 planned services
- [x] Analyzed all major protocols with sub-agents to identify service decomposition

### Issues / Bugs Hit
- None - this was primarily a design/architecture session

### Key Decisions
- **Protocol Witness over traditional protocols**: Struct with closure properties enables inline mocking without mock classes
- **13 services, not 46**: Sub-agents identified 46 potential services but we simplified to practical set
- **Services live in ServicesProvider**: Shared across all client apps (BetssonCameroonApp, BetssonFranceApp)
- **Gradual migration**: Deprecation path allows existing code to keep working

### Experiments & Notes
- Protocol Witness pattern from pointfree.co provides:
  - `.live(client:)` for production
  - `.failing()`, `.noop`, `.mock()` for tests
  - No mock classes needed
- Existing `TicketBetInfoViewModelTests` already uses this pattern successfully

### Useful Files / Links
- [TESTABLE_SERVICES.md](../../Frameworks/ServicesProvider/Documentation/TESTABLE_SERVICES.md) - Tracking document
- [CashoutService.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Services/CashoutService.swift)
- [WalletService.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Services/WalletService.swift)
- [SP_Architecture_V2.md](../architecture/SP_Architecture_V2.md) - Domain-based facade pattern reference
- [iOS-CashOut-Testability.md](../../../CoreMasterAggregator/Documentation/TestIdeas/iOS-CashOut-Testability.md) - Original requirements

### Next Steps
1. Create `BetHistoryService` (simple, commonly needed for MyBets testing)
2. Create `AuthService` (login, session management)
3. Update `TicketBetInfoViewModel` to use `CashoutService` from ServicesProvider
4. Consider adding public accessors to `Client.swift` for gradual migration
5. Write unit tests using new services

### Service Breakdown Summary

| Protocol | Methods | Planned Services |
|----------|---------|------------------|
| BettingProvider | 30 | `CashoutService` ✅, `BetHistoryService`, `BetPlacementService`, `BetslipService` |
| PrivilegedAccessManager | 127 | `WalletService` ✅, `AuthService`, `ProfileService`, `PaymentsService`, `LimitsService`, `BonusService` |
| EventsProvider | 125 | `SportsEventsService`, `FavoritesService` |
| CasinoProvider | 6 | `CasinoService` |

**Done: 2 | Planned: 11**
