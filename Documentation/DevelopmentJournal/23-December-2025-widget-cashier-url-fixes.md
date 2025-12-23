## Date
23 December 2025

### Project / Branch
BetssonCameroonApp / rr/swift-lint-fixes

### Goals for this session
- Investigate Widget Cashier not working (deposit/withdraw showing same URL)
- Add debug logging to trace URL construction
- Fix any issues found in the cashier URL building

### Achievements
- [x] Traced full Widget Cashier flow: Coordinator → ViewModel → PAMProvider → URL
- [x] Fixed `endpoint` parameter URL encoding - Widget Cashier requires `https://` → `https%3A%2F%2F`
- [x] Fixed theme detection - now respects app's saved AppearanceMode (dark/light/system)
- [x] Added comprehensive debug logging to `EveryMatrixPAMProvider.getWidgetCashierURL()`

### Issues / Bugs Hit
- [x] `endpoint` param not URL-encoded: `URLQueryItem` doesn't encode `:` and `/` by default (RFC 3986 allows them in query values)
- [x] Theme always "light": Code used `UIScreen.main.traitCollection` which doesn't respect app's saved preference

### Key Decisions
- **Manual endpoint encoding**: Build URL with `URLComponents` for all params except endpoint, then manually append encoded endpoint to avoid double-encoding
- **Theme from UserDefaults**: Check `UserDefaults.standard.appearanceMode` first; only resolve from window trait collection when mode is `.device` (system)

### Experiments & Notes
- `URLQueryItem` uses "form encoding" which encodes spaces but NOT `:` and `/` - these are technically allowed in query values per RFC 3986
- Using `.alphanumerics` character set for encoding ensures all special chars including `://` get encoded
- `UIScreen.main.traitCollection` unreliable for theme detection - must check the key window's resolved trait collection when following system theme

### Useful Files / Links
- [EveryMatrixPAMProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixPAMProvider.swift) - URL construction with encoding fix
- [WidgetCashierDepositViewModel.swift](../../BetssonCameroonApp/App/Screens/Banking/WidgetCashier/Deposit/WidgetCashierDepositViewModel.swift) - Theme detection fix
- [WidgetCashierWithdrawViewModel.swift](../../BetssonCameroonApp/App/Screens/Banking/WidgetCashier/Withdraw/WidgetCashierWithdrawViewModel.swift) - Theme detection fix
- [EveryMatrixUnifiedConfiguration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift) - Cashier URLs config
- [AppearanceMode.swift](../../BetssonCameroonApp/App/Models/Configs/UI/AppearanceMode.swift) - App theme enum
- [JIRA SPOR-7001](https://gomagaming.atlassian.net/browse/SPOR-7001)

### Next Steps
1. Test Widget Cashier with encoded endpoint URL
2. Verify theme param correctly reflects dark/light/system modes
3. Confirm deposit vs withdraw both work with correct `type` param
