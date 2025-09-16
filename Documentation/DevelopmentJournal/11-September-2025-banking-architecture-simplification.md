## Date
11 September 2025

### Project / Branch
sportsbook-ios / rr/deposit

### Goals for this session
- Fix critical architectural flaws in banking feature model layers
- Simplify over-engineered BankingCoordinator/ViewModel architecture
- Replace delegation patterns with closure-based patterns
- Implement correct 3-layer model architecture (EveryMatrix → ServicesProvider → App)

### Achievements
- [x] **Fixed 3-layer model architecture violation**
  - Created EveryMatrix internal models (`EveryMatrix+Cashier.swift`)
  - Made ServicesProvider models provider-agnostic (`CashierWebViewResponse`)
  - Added proper model mappers (`EveryMatrixModelMapper+Cashier.swift`)
- [x] **Replaced over-engineered generic abstractions with focused components**
  - Single generic `BankingCoordinator` (navigation only)
  - Separate `DepositWebContainerViewModel/ViewController` and `WithdrawWebContainerViewModel/ViewController`
  - Replaced 3 overlapping publishers with single `CashierFrameState` enum
- [x] **Replaced delegation with closure-based patterns**
  - Removed `BankingWebViewControllerDelegate` protocol
  - Updated to simple closures: `onTransactionComplete`, `onTransactionCancel`
- [x] **Fixed API endpoint to match Android implementation**
  - Changed from `/v1/payment/banking/webview` to `/v1/player/{userId}/payment/GetPaymentSession`
  - Updated request/response models to match actual API structure
- [x] **Cleaned up file structure**
  - Removed over-engineered files: old `BankingCoordinator`, `BankingViewModel`, `BankingWebViewController`
  - Proper directory structure: separate Deposit/Withdraw ViewControllers and ViewModels

### Issues / Bugs Hit
- [x] **Model layer violation**: Banking models were directly in ServicesProvider without provider-specific internal models
- [x] **Over-engineering**: Generic BankingViewModel trying to handle both deposit/withdraw with 3 overlapping state publishers
- [x] **Wrong endpoint**: iOS was using `/v1/payment/banking/webview` instead of Android's `/v1/player/{userId}/payment/GetPaymentSession`
- [x] **ProfileWalletCoordinator compilation errors**: API signature changes in BankingCoordinator factory methods

### Key Decisions
- **Correct MVVM-C pattern**: Coordinator handles navigation only, ViewModels handle business logic, ViewControllers handle UI
- **3-layer model architecture**: EveryMatrix internal models → ServicesProvider domain models → App models (if needed)
- **Single state enum**: `CashierFrameState` with clear states (idle, loadingURL, loadingWebView, ready, error)
- **Separate but similar components**: DepositWebContainer and WithdrawWebContainer instead of generic abstractions
- **Closure-based callbacks**: No delegation patterns, simple closures for coordinator communication

### Experiments & Notes
- **Android API exploration**: Used curl to verify actual API endpoint structure and response format
- **Model architecture analysis**: Studied existing patterns (WalletBalance, UserProfile) to understand correct 3-layer separation
- **MVVM-C role clarification**: Coordinator = navigation decisions, not business logic or generic abstractions

### Useful Files / Links
- [BankingCoordinator](../../BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift) - Generic coordinator for deposit/withdraw navigation
- [DepositWebContainerViewController](../../BetssonCameroonApp/App/Screens/Banking/Deposit/DepositWebContainerViewController.swift) - Deposit-specific UI
- [WithdrawWebContainerViewController](../../BetssonCameroonApp/App/Screens/Withdraw/WithdrawWebContainerViewController.swift) - Withdraw-specific UI  
- [CashierFrameState](../../BetssonCameroonApp/App/Models/Banking/CashierFrameState.swift) - Single state enum for WebView loading
- [EveryMatrix+Cashier](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+Cashier.swift) - Internal models
- [EveryMatrixModelMapper+Cashier](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Cashier.swift) - Model mapping
- [CashierWebViewResponse](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/Deposits/CashierWebViewResponse.swift) - Provider-agnostic domain model

### Next Steps
1. Test the banking feature end-to-end in BetssonCameroonApp
2. Verify JavaScript bridge communication in both Deposit and Withdraw WebViews
3. Add WithdrawWebContainer UI components (custom navigation, proper styling)
4. Consider creating app-level banking models if UI layer needs different data structure
5. Document the simplified banking architecture in technical documentation