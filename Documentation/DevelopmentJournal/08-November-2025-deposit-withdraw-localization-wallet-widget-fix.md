## Date
08 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Localize deposit/withdraw popup text (titles, buttons, error messages)
- Localize top bar deposit widget button
- Fix hardcoded "DEPOSIT" button in wallet widget

### Achievements
- [x] Added "retry" localization key (EN + FR)
- [x] Localized DepositWebContainerViewController (5 strings)
- [x] Localized WithdrawWebContainerViewController (5 strings)
- [x] Localized WalletWidgetViewModel deposit button
- [x] Localized MultiWidgetToolbarViewModel deposit button
- [x] Fixed architectural issue: Production WalletWidgetViewModel now properly injected
- [x] Updated protocol hierarchy to use WalletWidgetViewModelProtocol instead of Mock
- [x] Fixed 3 compilation errors across GomaUI framework

### Issues / Bugs Hit
- [x] Hardcoded "DEPOSIT" still showing despite localization in WalletWidgetViewModel
  - **Root Cause**: MultiWidgetToolbarView was creating its own MockWalletWidgetViewModel with hardcoded "DEPOSIT"
  - **Fix**: Implemented protocol-based injection pattern
- [x] Type conformance errors in MultiWidgetToolbarViewModelProtocol
  - **Root Cause**: Protocol required MockWalletWidgetViewModel instead of WalletWidgetViewModelProtocol
  - **Fix**: Updated protocol + mock to use WalletWidgetViewModelProtocol

### Key Decisions
- **Reused existing localization keys**: Only added 1 new key ("retry"), reused 5 existing keys (deposit, withdraw, cancel, deposit_error, withdraw_error)
- **Protocol-based injection over quick fixes**: Chose Option 1 (inject production ViewModel) instead of:
  - Option 2: Add localization to mock creation (quick fix but architecturally unclean)
  - Option 3: Update default in WalletWidgetData (changes GomaUI framework)
- **Injected before view creation**: Critical timing - WalletWidgetViewModel must be assigned to MultiWidgetToolbarViewModel BEFORE MultiWidgetToolbarView creates the wallet widget
- **Added updateBalance() to protocol**: Made it part of WalletWidgetViewModelProtocol for runtime balance updates (not just in Mock)
- **Graceful fallback**: MultiWidgetToolbarView.createWalletWidget() checks for injected ViewModel, falls back to localized mock for GomaUI demos

### Experiments & Notes
- **Architecture Discovery**: Found unused production ViewModel - WalletWidgetViewModel existed with correct localization but was never instantiated
- **Data Flow Analysis**: Traced complete flow from app initialization → TopBarContainerViewModel → MultiWidgetToolbarViewModel → MultiWidgetToolbarView → WalletWidgetView
- **Protocol hierarchy**: Updated 3 files to use WalletWidgetViewModelProtocol:
  1. MultiWidgetToolbarViewModelProtocol (GomaUI)
  2. MockMultiWidgetToolbarViewModel (GomaUI)
  3. MultiWidgetToolbarViewModel (BetssonCameroonApp)

### Useful Files / Links
- [DepositWebContainerViewController.swift](../../BetssonCameroonApp/App/Screens/Banking/Deposit/DepositWebContainerViewController.swift) - Lines 200, 205, 209, 285, 295
- [WithdrawWebContainerViewController.swift](../../BetssonCameroonApp/App/Screens/Banking/Withdraw/WithdrawWebContainerViewController.swift) - Lines 200, 205, 209, 285, 295
- [WalletWidgetViewModel.swift](../../BetssonCameroonApp/App/ViewModels/WalletWidgetViewModel.swift) - Line 44, 62-69
- [MultiWidgetToolbarViewModel.swift](../../BetssonCameroonApp/App/ViewModels/MultiWidgetToolbarViewModel.swift) - Lines 21, 134
- [TopBarContainerViewModel.swift](../../BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerViewModel.swift) - Lines 27-49
- [MultiWidgetToolbarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift) - Lines 159-185
- [WalletWidgetViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletWidgetView/WalletWidgetViewModelProtocol.swift) - Lines 15, 35
- [MultiWidgetToolbarViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarViewModelProtocol.swift) - Line 140
- [MockMultiWidgetToolbarViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MockMultiWidgetToolbarViewModel.swift) - Line 19
- [English Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings) - Line 3002
- [French Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings) - Line 3002
- [GomaUI Localization Migration Journal](08-November-2025-gomaui-localization-migration.md) - Reference for localization approach

### Technical Details

#### Files Modified (10 total)

**BetssonCameroonApp (4 files):**
1. `DepositWebContainerViewController.swift` - 5 string replacements
2. `WithdrawWebContainerViewController.swift` - 5 string replacements
3. `WalletWidgetViewModel.swift` - 1 string + updateBalance() implementation
4. `MultiWidgetToolbarViewModel.swift` - 1 string + type change to protocol
5. `TopBarContainerViewModel.swift` - Create and inject WalletWidgetViewModel
6. `en.lproj/Localizable.strings` - Added "retry" key
7. `fr.lproj/Localizable.strings` - Added "retry" key

**GomaUI Framework (3 files):**
8. `WalletWidgetViewModelProtocol.swift` - Added updateBalance() method + localized default parameter
9. `MultiWidgetToolbarViewModelProtocol.swift` - Changed walletViewModel type to protocol
10. `MockMultiWidgetToolbarViewModel.swift` - Changed walletViewModel type to protocol
11. `MultiWidgetToolbarView.swift` - Use injected ViewModel with fallback

#### Localization Summary

**New Keys Added:**
- `"retry" = "Retry";` (EN)
- `"retry" = "Réessayer";` (FR)

**Existing Keys Reused:**
- `deposit` - "Deposit" / "Dépôt"
- `withdraw` - "Withdraw" / "Retrait"
- `cancel` - "Cancel" / "Annuler"
- `deposit_error` - "Deposit Error" / "Erreur de Dépôt"
- `withdraw_error` - "Withdraw Error" / "Erreur de Retrait"

**Total String Replacements:** 12 hardcoded strings across 4 files

#### Architecture Changes

**Before:**
```
TopBarContainerViewModel
  ↓
MultiWidgetToolbarViewModel (no wallet ViewModel)
  ↓
MultiWidgetToolbarView.createWalletWidget()
  ↓ (creates)
MockWalletWidgetViewModel(depositButtonTitle: "DEPOSIT")  ← HARDCODED
  ↓
WalletWidgetView (renders "DEPOSIT")
```

**After:**
```
TopBarContainerViewModel
  ↓ (creates + injects)
WalletWidgetViewModel(depositButtonTitle: localized("deposit").uppercased())
  ↓ (injected into)
MultiWidgetToolbarViewModel.walletViewModel
  ↓
MultiWidgetToolbarView.createWalletWidget()
  ↓ (uses injected)
WalletWidgetViewModel (production with localization)
  ↓
WalletWidgetView (renders "DEPOSIT" / "DÉPÔT")
```

### Compilation Errors Fixed

1. **Error**: `Type 'MultiWidgetToolbarViewModel' does not conform to protocol 'MultiWidgetToolbarViewModelProtocol'`
   - **File**: BetssonCameroonApp/App/ViewModels/MultiWidgetToolbarViewModel.swift:5
   - **Fix**: Updated protocol to use `WalletWidgetViewModelProtocol?` instead of `MockWalletWidgetViewModel?`

2. **Error**: `Cannot assign value of type 'any WalletWidgetViewModelProtocol' to type 'MockWalletWidgetViewModel'`
   - **File**: Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift:174
   - **Fix**: Protocol change automatically resolved this

3. **Error**: `Type 'MockMultiWidgetToolbarViewModel' does not conform to protocol 'MultiWidgetToolbarViewModelProtocol'`
   - **File**: Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MockMultiWidgetToolbarViewModel.swift:5
   - **Fix**: Updated mock implementation to use `WalletWidgetViewModelProtocol?`

### Next Steps
1. Build and test BetssonCameroonApp to verify localization works
2. Test language switching (FR/EN) to ensure deposit button updates
3. Verify wallet balance updates still work correctly through new injection pattern
4. Test GomaUIDemo to ensure fallback mock still works for component previews
5. Consider applying same injection pattern to other widgets if needed in future
