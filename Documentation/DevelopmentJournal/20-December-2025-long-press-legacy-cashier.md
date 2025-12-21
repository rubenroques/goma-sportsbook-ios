## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Compare old (EveryMatrix) vs new (Widget Cashier) implementations
- Add ability to test both cashiers from ProfileWallet screen
- Normal tap opens new Widget Cashier, long press opens old EveryMatrix cashier

### Achievements
- [x] Created comparison table of Old vs New cashier implementations
- [x] Added `performDepositLegacy()` and `performWithdrawLegacy()` to `WalletDetailViewModelProtocol`
- [x] Added `UILongPressGestureRecognizer` to deposit/withdraw buttons in `WalletDetailView`
- [x] Wired legacy callbacks through the full MVVM-C chain
- [x] Normal tap → Widget Cashier, Long press → EveryMatrix cashier

### Issues / Bugs Hit
- New Widget Cashier not working (reason for adding legacy fallback via long press)

### Key Decisions
- Added long press as a hidden debug feature to access old cashier while troubleshooting new one
- **All legacy long press code wrapped in `#if DEBUG`** - not available in release builds
- No haptic or visual feedback on long press (silent, per user preference)
- Both cashier implementations coexist in `BankingCoordinator` via different `TransactionType` enum cases

### Experiments & Notes
- The callback chain flows: `WalletDetailView` → `WalletDetailViewModel` → `ProfileWalletViewModel` → `ProfileWalletCoordinator`
- `BankingCoordinator` already had factory methods for both old (`forDeposit`/`forWithdraw`) and new (`forWidgetCashierDeposit`/`forWidgetCashierWithdraw`)

### Useful Files / Links
- [WalletDetailViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailViewModelProtocol.swift)
- [WalletDetailView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailView.swift)
- [WalletDetailViewModel](../../BetssonCameroonApp/App/Screens/ProfileWallet/WalletDetailViewModel.swift)
- [ProfileWalletViewModel](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewModel.swift)
- [ProfileWalletCoordinator](../../BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift)
- [BankingCoordinator](../../BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift)

### Changes Summary

| File | Change |
|------|--------|
| `WalletDetailViewModelProtocol.swift` | Added `performDepositLegacy()` and `performWithdrawLegacy()` protocol methods (`#if DEBUG`) |
| `WalletDetailView.swift` | Added long press gesture recognizers to buttons (`#if DEBUG`) |
| `MockWalletDetailViewModel.swift` | Implemented legacy protocol methods with callbacks (`#if DEBUG`) |
| `WalletDetailViewModel.swift` | Added legacy callbacks and protocol implementation (`#if DEBUG`) |
| `ProfileWalletViewModel.swift` | Added legacy callbacks and wired child ViewModel (`#if DEBUG`) |
| `ProfileWalletCoordinator.swift` | Reverted normal tap to Widget Cashier, added legacy flow methods (`#if DEBUG`) |

### Next Steps
1. Debug why new Widget Cashier is not working
2. Test both cashiers on device
3. Consider removing long press feature once Widget Cashier is stable
