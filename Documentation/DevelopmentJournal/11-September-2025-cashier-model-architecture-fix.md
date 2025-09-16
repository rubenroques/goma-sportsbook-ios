## Date
11 September 2025

### Project / Branch
sportsbook-ios / rr/deposit

### Goals for this session
- Fix critical model architecture flaw in cashier feature
- Verify API endpoint matches Android implementation 
- Replace delegation with closures in BankingWebViewController
- Implement proper 3-layer model architecture

### Achievements
- [x] Tested Android API endpoint with curl - confirmed working
- [x] Updated iOS endpoint to match Android: `/v1/player/{userId}/payment/GetPaymentSession`
- [x] Replaced BankingWebViewControllerDelegate with closure-based pattern
- [x] Created proper 3-layer model architecture for Cashier feature
- [x] Implemented EveryMatrix internal models (EveryMatrix+Cashier.swift)
- [x] Updated ServicesProvider domain models to be provider-agnostic
- [x] Created EveryMatrixModelMapper+Cashier.swift for proper mapping
- [x] Updated API usage to follow established patterns
- [x] Fixed BankingViewModel to use new response structure

### Issues / Bugs Hit
- [x] Wrong API endpoint - was using `/v1/payment/banking/webview`, should be `/v1/player/{userId}/payment/GetPaymentSession`
- [x] Response model missing ResponseCode and RequestId fields from actual API
- [x] BankingWebViewController using delegation instead of closures (violates app patterns)
- [x] Critical architecture flaw: Models bypassed proper layer separation
- [x] Duplicate BankingNavigationAction enums in different files

### Key Decisions
- **Follow 3-layer architecture**: EveryMatrix Internal → ServicesProvider Domain → App Models
- **Closure-based WebView communication**: Removed BankingWebViewControllerDelegate protocol
- **Provider-agnostic domain models**: Removed Codable/CodingKeys from CashierWebViewResponse
- **Use established mapping patterns**: Created EveryMatrixModelMapper+Cashier following existing conventions
- **Endpoint alignment with Android**: Changed to match Android's working implementation

### Experiments & Notes
- Android curl test confirmed API structure: `CashierInfo.Url`, `ResponseCode`, `RequestId`
- Investigated existing model mappers (WalletBalance, Sports) to understand patterns
- Found ServiceProviderModelMapper in BetssonCameroonApp for app-level mapping
- Discovered JavaScriptBridge already had BankingNavigationAction enum with different case names

### Useful Files / Links
- [EveryMatrix+Cashier.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+Cashier.swift) - Internal API models
- [EveryMatrixModelMapper+Cashier.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Cashier.swift) - Layer mapping
- [CashierWebViewResponse.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/Deposits/CashierWebViewResponse.swift) - Domain model
- [BankingWebViewController.swift](../../BetssonCameroonApp/App/Screens/Banking/WebView/BankingWebViewController.swift) - Closure-based UI
- [BankingCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift) - Updated coordinator
- [EveryMatrixModelMapper+WalletBalance.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+WalletBalance.swift) - Reference pattern

### Next Steps
1. Test complete banking flow end-to-end with proper session
2. Consider creating app-level models if UI needs simpler structure
3. Add ServiceProviderModelMapper+Banking.swift if app models needed
4. Validate JavaScript bridge communication works with closure pattern
5. Test both Deposit and Withdraw flows to ensure unified approach works