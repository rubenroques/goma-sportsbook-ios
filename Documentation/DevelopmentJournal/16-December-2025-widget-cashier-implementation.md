# Widget Cashier Implementation

## Date
16 December 2025

### Project / Branch
BetssonCameroonApp / `rr/goma_cashier`

### Goals for this session
- Implement new Widget Cashier screens (deposit/withdraw) for Goma-hosted cashier page
- Integrate with ServicesProvider to build cashier URLs with proper session management
- Remove debug performance overlay from cashier screens

### Achievements
- [x] Created `WidgetCashierType` enum in ServicesProvider for transaction types
- [x] Added `getWidgetCashierURL(type:language:theme:)` to `PrivilegedAccessManager` protocol
- [x] Implemented URL building in `EveryMatrixPAMProvider` using internal session token
- [x] Added `widgetCashierBaseURL` and `widgetCashierAPIEndpoint` to `EveryMatrixUnifiedConfiguration`
- [x] Created `WidgetCashierBridge` with proper JSON message parsing
- [x] Created `WidgetCashierDepositViewController` and `WidgetCashierDepositViewModel`
- [x] Created `WidgetCashierWithdrawViewController` and `WidgetCashierWithdrawViewModel`
- [x] Created `WidgetCashierWebViewConfiguration` for WKWebView setup
- [x] Wired up coordinators (`MainTabBarCoordinator`, `ProfileWalletCoordinator`, `BankingCoordinator`)
- [x] Fixed JS bridge false positive errors (`ErrorResponseCode` with empty code)
- [x] Removed timing/performance overlay from both ViewControllers

### Issues / Bugs Hit
- [x] Session token was being read from `UserProfile.sessionKey` (always empty) - Fixed by using `sessionCoordinator.getSessionToken()` in EveryMatrix provider
- [x] `ErrorResponseCode` with empty `errorResponseCode` was triggering failure delegate - Fixed by parsing JSON and checking for non-empty error codes
- [ ] Cashier page ignores `type=Withdraw` parameter (shows Deposit mode) - **Cashier page bug, not iOS**
- [ ] Theme parameter may not be respected by cashier page - **Needs verification with teammate**

### Key Decisions
- **Option B chosen**: URL building moved to ServicesProvider instead of client-side in ViewModel
  - Session token stays internal to provider (clean architecture)
  - App layer only passes `language` and `theme` preferences
  - Provider handles currency fallback internally (`"XAF"` default)
- **Renamed from `GomaCashier` to `WidgetCashier`** for clarity
- **JS bridge handler name**: `"cashierHandler"` (not `"iOS"` like legacy EM cashier)
- **Removed timing overlay** - was development/debug feature, not needed for production

### Experiments & Notes
- `URLQueryItem` with `URLComponents` handles most URL encoding, but `endpoint` param required explicit `.alphanumerics` encoding per cashier page requirements
- The cashier page sends many status messages (`DataLoading`, `CashierMethodsListReady`, `SelectPayMeth`, etc.) that should be logged but not acted upon
- `ErrorResponseCode` with empty string is a "clear error state" signal, not an actual error

### Useful Files / Links
- **New Files Created**:
  - `BetssonCameroonApp/App/Screens/Banking/WidgetCashier/` (entire directory)
  - `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/WidgetCashierType.swift`
- **Modified Files**:
  - `EveryMatrixPAMProvider.swift` - Added `getWidgetCashierURL()` implementation
  - `EveryMatrixUnifiedConfiguration.swift` - Added widget cashier URLs
  - `PrivilegedAccessManager.swift` - Added protocol method
  - `Client.swift` - Exposed method publicly
  - `BankingCoordinator.swift` - Added widget cashier transaction types
  - `MainTabBarCoordinator.swift` - Switched to widget cashier
  - `ProfileWalletCoordinator.swift` - Switched to widget cashier
- **Cashier Page README**: Provided by teammate with URL structure and query params

### Next Steps
1. Verify with teammate why `type=Withdraw` is ignored by cashier page
2. Confirm if `theme` parameter is being read correctly by cashier page
3. Test complete deposit/withdraw flows end-to-end
4. Consider adding error handling for specific `ErrorResponseCode` values when they are non-empty
