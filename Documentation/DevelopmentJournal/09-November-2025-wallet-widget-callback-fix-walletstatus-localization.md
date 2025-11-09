## Date
09 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix broken deposit button callback after localization changes
- Fix broken balance tap callback (wallet overlay not opening)
- Localize WalletStatusView overlay strings (Deposit, Withdraw, Total Balance, Cashback Balance)

### Achievements
- [x] Identified and fixed broken deposit button callback chain
- [x] Discovered and fixed wallet widget ID mismatch ("wallet_widget" vs "wallet")
- [x] Added comprehensive debug logging with "💰 WALLET_TAP:" prefix
- [x] Localized 4 hardcoded strings in WalletStatusView overlay
- [x] Verified all localization keys exist in both EN and FR files

### Issues / Bugs Hit
- [x] Deposit button non-functional after ViewModel injection
  - **Root Cause**: Missing callback connection between `MultiWidgetToolbarViewModel.onDepositRequested` and `TopBarContainerController.onDepositRequested`
  - **Fix**: Added callback connection in `TopBarContainerController.setupCallbacks()`
- [x] Balance tap not opening wallet overlay
  - **Root Cause**: Widget ID mismatch - `WalletWidgetViewModel` used `"wallet_widget"` but `TopBarContainerController` checked for `"wallet"`
  - **Discovery Method**: Debug logging revealed `widgetId 'wallet_widget' does NOT match 'wallet'`
  - **Fix**: Changed `WalletWidgetViewModel` from `id: "wallet_widget"` to `id: "wallet"`
- [x] Latent bug in `WalletWidgetViewModel` since creation (02/09/2025)
  - **Never triggered before**: File existed with wrong ID but was never used until we injected it today
  - **Surfaced when**: We started injecting production `WalletWidgetViewModel` instead of creating Mock

### Key Decisions
- **Removed redundant callback assignment**: Deleted lines 43-46 from `TopBarContainerViewModel.swift` (duplicate callback setup)
- **Added callback connection in proper location**: `TopBarContainerController.setupCallbacks()` is the correct place (happens in viewDidLoad)
- **Used common debug prefix**: "💰 WALLET_TAP:" for all wallet-related tap debugging (easier console filtering)
- **Fixed ID at source**: Changed WalletWidgetViewModel's hardcoded ID rather than changing the check (widget ID should be "wallet")
- **Verified all localization keys**: Checked both EN and FR files before implementing changes (all keys already existed)

### Experiments & Notes
- **Callback Chain Discovery**: Used git diff to verify we didn't modify balance tap callbacks - they were intact
- **Debug Logging Strategy**: Added 3 levels of logging:
  1. `WalletWidgetView.balanceTapped()` - View level
  2. `MultiWidgetToolbarView` - Forwarding level
  3. `TopBarContainerController` - Final handler level
- **Console Output Analysis**: Logs revealed exact point of failure: `widgetId 'wallet_widget' does NOT match 'wallet'`
- **Git History Analysis**: Traced bug origin to file creation commit (2e84c8fe4) - wrong ID from day one but never used
- **French Translation Research**: Confirmed all translations:
  - "Deposit" → "Créditer" (not "Dépôt")
  - "Withdraw" → "Retirer"
  - "Total Balance" → "Solde total"
  - "Cashback Balance" → "Solde Cashback"

### Useful Files / Links
- [TopBarContainerController.swift](../../BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift) - Lines 218-222 (callback connection), 198-212 (debug logging)
- [TopBarContainerViewModel.swift](../../BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerViewModel.swift) - Removed lines 43-46 (redundant callback)
- [WalletWidgetViewModel.swift](../../BetssonCameroonApp/App/ViewModels/WalletWidgetViewModel.swift) - Line 42 (ID fix: "wallet_widget" → "wallet")
- [WalletWidgetView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletWidgetView/WalletWidgetView.swift) - Lines 148-154 (debug logging)
- [MultiWidgetToolbarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift) - Line 182 (debug logging)
- [WalletStatusView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletStatusView/WalletStatusView.swift) - Lines 16, 22 (localized "Total Balance", "Cashback balance")
- [ButtonViewModel.swift](../../BetssonCameroonApp/App/ViewModels/ButtonViewModel.swift) - Lines 108, 120 (localized "Deposit", "Withdraw")
- [English Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings) - Lines 3482, 565, 873, 3768
- [French Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings) - Lines 3482, 565, 873, 3768
- [Previous Session Journal](08-November-2025-deposit-withdraw-localization-wallet-widget-fix.md) - Context for ViewModel injection changes

### Technical Details

#### Callback Chain Fix

**Problem**: Deposit button worked via ViewModel but callback chain was incomplete.

**Before (Broken)**:
```
WalletWidgetViewModel.deposit()
    ↓
WalletWidgetViewModel.onDepositRequested?()
    ↓ (set by MultiWidgetToolbarViewModel.didSet)
MultiWidgetToolbarViewModel.onDepositRequested?() ❌ NIL!
    ↓
❌ STOPS HERE - Never reaches Coordinator
```

**After (Fixed)**:
```
WalletWidgetViewModel.deposit()
    ↓
WalletWidgetViewModel.onDepositRequested?()
    ↓
MultiWidgetToolbarViewModel.onDepositRequested?()
    ↓ (NEW: set by TopBarContainerController.setupCallbacks)
TopBarContainerController.onDepositRequested?()
    ↓
MainTabBarCoordinator.presentDepositFlow()
```

**Changes Made**:
1. **TopBarContainerViewModel.swift**: Removed redundant callback assignment (lines 43-46 deleted)
2. **TopBarContainerController.swift**: Added missing link (lines 218-222):
```swift
viewModel.multiWidgetToolbarViewModel.onDepositRequested = { [weak self] in
    print("💳 TopBarContainer: ViewModel deposit requested")
    self?.onDepositRequested?()
}
```

#### Widget ID Mismatch Fix

**Problem**: Balance tap callback chain complete but ID check failing.

**Debug Logging Output**:
```
💰 WALLET_TAP: WalletWidgetView.balanceTapped() called
💰 WALLET_TAP: Calling onBalanceTapped callback with id: wallet_widget
💰 WALLET_TAP: MultiWidgetToolbarView forwarding balance tap with widgetID: wallet_widget
💰 WALLET_TAP: TopBarContainerController received balance tap with widgetId: wallet_widget
💰 WALLET_TAP: widgetId 'wallet_widget' does NOT match 'wallet', ignoring
```

**Root Cause Analysis**:
- `WalletWidgetViewModel.swift` line 42: `id: "wallet_widget"`
- `TopBarContainerController.swift` line 200: `if widgetId == "wallet"`
- Widget config in `MultiWidgetToolbarViewModel.swift`: `id: "wallet"`

**Fix**: Changed `WalletWidgetViewModel.swift` line 42 from `"wallet_widget"` to `"wallet"`

**Historical Context**:
- Bug introduced: Commit 2e84c8fe4 (02/09/2025) - file created with wrong ID
- Never triggered: File existed but was never actually used (Mock was used instead)
- Surfaced: Today when we injected production `WalletWidgetViewModel` for first time

#### WalletStatusView Localization

**Files Modified**: 2 files, 4 string replacements

**GomaUI Changes** (WalletStatusView.swift):
- Line 16: `"Total Balance"` → `LocalizationProvider.string("total_balance")`
- Line 22: `"Cashback balance"` → `LocalizationProvider.string("cashback_balance")`

**BetssonCameroonApp Changes** (ButtonViewModel.swift):
- Line 108: `"Deposit"` → `localized("deposit")`
- Line 120: `"Withdraw"` → `localized("withdraw")`

**Localization Keys Used** (All Pre-existing):
| Key | EN (Line) | FR (Line) | EN Translation | FR Translation |
|-----|-----------|-----------|----------------|----------------|
| `total_balance` | 3482 | 3482 | "Total Balance" | "Solde total" |
| `cashback_balance` | 565 | 565 | "Cashback Balance" | "Solde Cashback" |
| `deposit` | 873 | 873 | "Deposit" | "Créditer" |
| `withdraw` | 3768 | 3768 | "Withdraw" | "Retirer" |

#### Debug Logging Added

**Purpose**: Trace balance tap callback chain to identify where it breaks.

**Common Prefix**: `💰 WALLET_TAP:` for easy console filtering

**Files Modified with Debug Logs**:
1. `WalletWidgetView.swift` (lines 148-154): View-level tap detection
2. `MultiWidgetToolbarView.swift` (line 182): Callback forwarding
3. `TopBarContainerController.swift` (lines 199-211): Final handler with ID check

**Console Filtering**: `xcrun simctl spawn booted log stream --predicate 'eventMessage contains "WALLET_TAP"'`

### Files Modified Summary

**Total**: 8 files modified

**BetssonCameroonApp (4 files)**:
1. `TopBarContainerController.swift` - Added callback connection + debug logging
2. `TopBarContainerViewModel.swift` - Removed redundant callback
3. `WalletWidgetViewModel.swift` - Fixed widget ID mismatch
4. `ButtonViewModel.swift` - Localized deposit/withdraw buttons

**GomaUI (3 files)**:
5. `WalletWidgetView.swift` - Added debug logging
6. `MultiWidgetToolbarView.swift` - Added debug logging
7. `WalletStatusView.swift` - Localized total balance/cashback strings

**Debug Logging Only** (can be removed later):
- Lines with `print("💰 WALLET_TAP:` - 3 files, 8 total log statements

### Architecture Insights

**ViewModel Injection Pattern**:
- Production ViewModels must be injected BEFORE view creation
- Callback connections should happen in ViewController lifecycle (viewDidLoad)
- Property `didSet` is too early for callbacks that depend on parent coordinator

**Widget ID Convention**:
- Widget IDs should match between config and implementation
- Check both Mock and Production implementations for consistency
- IDs flow: Widget config → ViewModel → View → accessibilityIdentifier → callback

**Callback Chain Best Practices**:
1. ViewModel → ViewModel (via didSet or init)
2. ViewModel → ViewController (via setupCallbacks in viewDidLoad)
3. ViewController → Coordinator (set by coordinator after VC creation)

**Debug Logging Strategy**:
- Use common prefixes for related functionality
- Log at each layer: View → Component → Controller
- Include context: IDs, values, match/mismatch results
- Can remove after issue resolved

### Next Steps
1. Test deposit button works in both English and French
2. Test balance tap opens overlay in both languages
3. Verify WalletStatusView displays all localized strings correctly
4. Consider removing debug logging after confirming stability
5. Update development journal entry in previous session to reference this one
6. Test wallet balance updates still work correctly through reactive chain
