## Date
10 September 2025

### Project / Branch
sportsbook-ios / rr/deposit

### Goals for this session
- Complete banking feature implementation for Deposit/Withdraw operations
- Fix all compilation errors from initial implementation
- Replace delegation with closure-based patterns
- Simplify EveryMatrix API architecture

### Achievements
- [x] Fixed HTTP enum case error (.POST → .post)
- [x] Corrected BankingWebViewResponse type (was BankingWebViewResponse, should be CashierWebViewResponse)
- [x] Removed @MainActor annotations from all banking classes (Swift 5 + Combine only)
- [x] Replaced BankingCoordinatorDelegate with closure-based pattern
- [x] Fixed ProfileWalletCoordinator to use UserSessionStore.refreshUserWallet()
- [x] Consolidated EveryMatrix Payment API into Player API
- [x] Removed unnecessary EveryMatrixPaymentAPI and EveryMatrixPaymentAPIConnector files
- [x] Updated ServicesProvider.Client to use unified connector approach

### Issues / Bugs Hit
- [x] MainActor isolation errors (resolved by removing Swift 6 concurrency features)
- [x] ServiceProviderError.invalidResponse("message") - enum case has no associated values
- [x] Architectural over-engineering - separate Payment API was unnecessary
- [x] ProfileWalletCoordinator structure broken - methods outside class scope
- [x] Banking feature violating encapsulation by exposing internal protocols

### Key Decisions
- **No Swift 6 concurrency features**: Stick to pure Swift 5 + Combine approach per project architecture
- **Closure-based coordinators**: Follow established app patterns instead of delegation
- **Unified EveryMatrix API**: Banking endpoints belong in Player API since they use same base URL
- **ServicesProvider.Client encapsulation**: Only expose public Client interface, not internal protocols
- **UserSessionStore responsibility**: Wallet refresh belongs in session store, not ViewModels

### Experiments & Notes
- Initially tried @MainActor on BankingCoordinator → caused isolation issues throughout
- Explored separate Payment API architecture → realized it was unnecessary duplication
- User feedback revealed critical encapsulation violation: "ServicesProvider framework does not expose its different providers' protocols like that"
- Android analysis showed unified banking architecture with JavaScript bridge pattern

### Useful Files / Links
- [Banking Technical Report](../BANKING_FEATURE_TECHNICAL_REPORT.md) - Platform-agnostic design from Android analysis
- [BankingCoordinator](../../BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift) - Closure-based coordinator
- [BankingViewModel](../../BetssonCameroonApp/App/Screens/Banking/Deposit/BankingViewModel.swift) - Pure Combine ViewModel
- [EveryMatrixPlayerAPI](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift) - Unified API endpoints
- [ProfileWalletCoordinator](../../BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift) - Integration example

### Next Steps
1. Test the banking feature end-to-end in BetssonCameroonApp
2. Verify JavaScript bridge communication in BankingWebViewController
3. Add proper error handling for different WebView completion scenarios
4. Consider adding BankingViewModel unit tests with mocks
5. Document the unified banking architecture in technical documentation