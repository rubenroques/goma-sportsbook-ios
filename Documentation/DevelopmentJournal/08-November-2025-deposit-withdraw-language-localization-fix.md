## Date
08 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Fix hardcoded "EN" language in deposit/withdraw screens
- Ensure French users see French cashier interface
- Make language selection respect app's localization settings

### Achievements
- [x] Updated `DepositWebContainerViewModel.loadDeposit()` to get language internally via `localized("current_language_code").uppercased()`
- [x] Updated `WithdrawWebContainerViewModel.loadWithdraw()` to get language internally via `localized("current_language_code").uppercased()`
- [x] Removed hardcoded `language: "EN"` parameter from `DepositWebContainerViewController` (2 call sites: viewDidLoad + error retry)
- [x] Removed hardcoded `language: "EN"` parameter from `WithdrawWebContainerViewController` (2 call sites: viewDidLoad + error retry)
- [x] User also improved UI strings with `localized()` for deposit/withdraw error alerts and labels

### Issues / Bugs Hit
- [x] Root cause: Hardcoded `language: "EN"` in 4 locations prevented French localization
- [x] Web app was doing it correctly by passing `locale.value` dynamically to the cashier API
- [x] iOS was ignoring app's language setting and always requesting English cashier URLs

### Key Decisions
- **Approach Selected**: ViewModel-level language retrieval (ViewModels get language internally)
  - Alternative 1 (Simple Fix): Replace hardcoded "EN" in ViewControllers - rejected, duplicates logic across 4 call sites
  - Alternative 2 (Coordinator Injection): Pass language from BankingCoordinator - rejected, requires init signature changes
  - **Chosen approach**: ViewModels call `localized("current_language_code")` internally
    - Encapsulates language logic in one place per ViewModel
    - Eliminates duplicate code across multiple call sites
    - No init signature changes required
    - Follows existing pattern used in ProfileWallet and ProfileMenuList ViewModels

### Experiments & Notes
- **Language Management Investigation**:
  - App uses iOS localization system with `localized("current_language_code")` helper
  - Returns `"en"` or `"fr"` based on app language setting
  - Defined in `/BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift`
  - Configured globally in `Environment.swift` for EveryMatrix API
  - Cameroon is bilingual (English/French) - critical to support both languages

- **Existing Patterns Found**:
  - `ProfileWalletViewModel` (line 94): `let currentLanguageCode = localized("current_language_code")`
  - `ProfileMenuListViewModel` (line 39): `self.currentLanguage = Self.displayNameForLanguageCode(localized("current_language_code"))`
  - `AppExtendedListFooterImageResolver` (line 36): `let languageCode = localized("current_language_code").lowercased()`

- **API Flow**:
  ```
  ViewModel.loadDeposit(currency: "XAF")
  → Gets language: localized("current_language_code").uppercased() // "EN" or "FR"
  → CashierParameters.forDeposit(language: language, currency: currency, bonusCode: bonusCode)
  → client.getBankingWebView(parameters: parameters)
  → API returns localized cashier URL
  → WebView loads cashier in correct language
  ```

### Useful Files / Links
**Modified Files**:
- [DepositWebContainerViewModel.swift](../../BetssonCameroonApp/App/Screens/Banking/Deposit/DepositWebContainerViewModel.swift) - Line 41: Removed language parameter, added internal language retrieval
- [WithdrawWebContainerViewModel.swift](../../BetssonCameroonApp/App/Screens/Banking/Withdraw/WithdrawWebContainerViewModel.swift) - Line 38: Removed language parameter, added internal language retrieval
- [DepositWebContainerViewController.swift](../../BetssonCameroonApp/App/Screens/Banking/Deposit/DepositWebContainerViewController.swift) - Lines 73, 206: Removed language parameter from calls
- [WithdrawWebContainerViewController.swift](../../BetssonCameroonApp/App/Screens/Banking/Withdraw/WithdrawWebContainerViewController.swift) - Lines 73, 206: Removed language parameter from calls

**Reference Files**:
- [Localization.swift](../../BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift) - Helper function for language retrieval
- [Environment.swift](../../BetssonCameroonApp/App/Boot/Environment.swift) - Line 22: Global EveryMatrix language config
- [CashierParameters.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/Deposits/CashierParameters.swift) - API parameter structure
- [ProfileWalletViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewModel.swift) - Line 94: Example of existing language pattern

**Localization Files**:
- [en.lproj/Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings) - English translations
- [fr.lproj/Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings) - French translations

**Web Reference**:
- Web implementation: `web-app/src/composables/deposit/useDepositHostedCashier.js:7,88` - Correct pattern using `locale.value`

### Next Steps
1. **Testing Required**:
   - Build BetssonCameroonApp scheme on simulator
   - Test deposit flow with app language set to English → verify English cashier appears
   - Switch app language to French (iOS Settings → General → Language & Region)
   - Test deposit flow again → verify French cashier appears
   - Test withdraw flow in both languages
   - Test error retry functionality in both languages

2. **Verification Checklist**:
   - [ ] English deposit cashier displays correctly
   - [ ] French deposit cashier displays correctly
   - [ ] English withdraw cashier displays correctly
   - [ ] French withdraw cashier displays correctly
   - [ ] Error alerts show in correct language
   - [ ] Retry button works and maintains language selection

3. **Future Considerations**:
   - Consider adding unit tests for language selection logic
   - Document pattern in UI Component Guide for future banking screens
   - Check if other WebView-based screens have similar hardcoded language issues
