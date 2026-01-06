## Date
06 January 2026

### Project / Branch
BetssonCameroonApp / rw/snapshot_tests

### Goals for this session
- Create unit testing infrastructure for cashout business logic
- Implement pointfree.co-style struct-based dependency injection
- Create test fixtures for ServicesProvider and app models
- Document the testing patterns for the team

### Achievements
- [x] Created `CashoutService.swift` - protocol witness struct with closures for `subscribeToCashoutValue` and `executeCashout`
- [x] Refactored `TicketBetInfoViewModel` to use `CashoutService` instead of direct `ServicesProvider.Client` dependency
- [x] Created `CashoutTestFixtures.swift` - extensions on `CashoutValue`, `CashoutResponse`, `CashoutRequest`
- [x] Created `MyBetTestFixtures.swift` - extensions on `MyBet`, `MyBetSelection`, `PartialCashOut`
- [x] Created `TicketBetInfoViewModelTests.swift` with 5 exemplary test patterns
- [x] Created `Tests/Documentation/UNIT_TESTING_101.md` - comprehensive guide on the protocol witness pattern
- [x] Fixed TEST_HOST configuration for Debug-UAT and Release-UAT targets (was pointing to Prod instead of UAT)

### Issues / Bugs Hit
- [x] TEST_HOST mismatch - UAT test target was pointing to "Betsson CM Prod.app" instead of "Betsson CM UAT.app"
- [x] Argument order issue in test file - `stake` parameter must precede `partialCashOutEnabled` in fixture calls

### Key Decisions
- **Protocol Witness over Protocol+Mock**: Used pointfree.co struct-based dependencies instead of traditional protocol-based mocking
- **Backward compatibility**: Added `TicketBetInfoViewModel.create(from:servicesProvider:)` factory method so existing code doesn't break
- **Inline closure configuration**: Each test configures behavior via closures passed to `CashoutService` init
- **Factory methods on service**: `.live(client:)` for production, `.noop` and `.failing()` for tests

### Experiments & Notes
- The protocol witness pattern eliminates the need for mock classes entirely
- Each function in the struct is a "morphism" - transformation from input to output
- `PassthroughSubject` is key for simulating SSE streams in tests
- Combine publishers used: `Empty()`, `Just()`, `Fail()`, `PassthroughSubject`

### Useful Files / Links
- [CashoutService.swift](../../BetssonCameroonApp/App/Services/Cashout/CashoutService.swift)
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)
- [TicketBetInfoViewModelTests.swift](../../BetssonCameroonApp/Tests/ViewModels/MyBets/TicketBetInfoViewModelTests.swift)
- [UNIT_TESTING_101.md](../../BetssonCameroonApp/Tests/Documentation/UNIT_TESTING_101.md)
- [CashoutTestFixtures.swift](../../BetssonCameroonApp/Tests/Fixtures/CashoutTestFixtures.swift)
- [MyBetTestFixtures.swift](../../BetssonCameroonApp/Tests/Fixtures/MyBetTestFixtures.swift)
- [pointfree.co - Protocol Witnesses](https://www.pointfree.co/collections/protocol-witnesses)

### Next Steps
1. Team to create additional unit tests following the patterns in `TicketBetInfoViewModelTests.swift`
2. Consider applying same pattern to other ViewModels with external dependencies
3. Run full test suite on CI to validate TEST_HOST fixes work across all configurations
