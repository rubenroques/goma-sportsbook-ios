## Date
17 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Investigate Mock ViewModel usage across BetssonCameroonApp
- Identify protocol-based ViewModels in app code (should only be in GomaUI)
- Document architectural violations for future cleanup

### Achievements
- [x] Performed comprehensive search across both BetssonCameroonApp and BetssonFranceApp
- [x] Identified 19+ GomaUI Mock ViewModels being used in production code
- [x] Identified 19 protocol-based ViewModels in BetssonCameroonApp that violate architectural pattern
- [x] Documented all violations with specific file paths and line numbers
- [x] Added detailed entries to TODO_TASKS.md for future refactoring

### Issues / Bugs Hit
- **CRITICAL ARCHITECTURAL VIOLATION**: Production app code extensively uses GomaUI Mock ViewModels instead of real implementations
  - Mock ViewModels are designed for testing/SwiftUI previews only
  - Production betting, registration, and casino flows running on test infrastructure
  - Example: `SportsBetslipViewModel` creates 7 Mock ViewModels in init, then downcasts them at runtime

- **Protocol Pattern Misuse**: App-specific ViewModels using GomaUI's protocol pattern
  - Protocol pattern should only be in GomaUI library for reusable components
  - App ViewModels are client-specific glue code, not reusable components
  - Creates unnecessary 3x file proliferation (Protocol + Real + Mock)

### Key Decisions
- **POSTPONED**: Refactoring these violations to later sprint
- **DOCUMENTED**: Added comprehensive TODO entries in TODO_TASKS.md marked as [CRITICAL]
- **PATTERN CLARIFICATION**:
  - GomaUI components: Use protocol pattern with real + mock implementations
  - App ViewModels: Use concrete classes only, no protocols, no mocks

### Violations Found

#### GomaUI Mock ViewModels in Production (19 types)
**Most Critical:**
- `SportsBetslipViewModel.swift:58-76` - Creates 7 Mock ViewModels in production
- `PhoneRegistrationViewModel.swift:112-195` - Creates 5 Mock text field ViewModels dynamically
- `MultiWidgetToolbarViewModel.swift:21` - Uses MockWalletWidgetViewModel for wallet display

**Component Categories:**
- Betslip: MockButtonIconViewModel, MockEmptyStateActionViewModel, MockBetInfoSubmissionViewModel, MockOddsAcceptanceViewModel, MockCodeInputViewModel, MockSuggestedBetsExpandedViewModel
- Common UI: MockButtonViewModel (15+ usages), MockHeaderTextViewModel, MockSeeMoreButtonViewModel
- Casino: MockQuickLinksTabBarViewModel, MockRecentlyPlayedGamesViewModel, MockTopBannerSliderViewModel
- Wallet: MockWalletWidgetViewModel
- Forms: MockPromotionalHeaderViewModel, MockHighlightedTextViewModel, MockBorderedTextFieldViewModel, MockTermsAcceptanceViewModel, MockPinDigitEntryViewModel, MockResendCodeCountdownViewModel

#### Protocol-Based App ViewModels (19 violations)
**Betslip Flow:**
- SportsBetslipViewModelProtocol
- BetslipViewModelProtocol
- BetSuccessViewModelProtocol
- VirtualBetslipViewModelProtocol

**Registration Flow (with mocks!):**
- PhoneRegistrationViewModelProtocol + PhoneRegistrationViewModel + Mock
- PhoneVerificationViewModelProtocol + PhoneVerificationViewModel + Mock

**Password Recovery Flow (5 protocols, each with mock):**
- PhonePasswordCodeResetViewModelProtocol
- PhonePasswordCodeVerificationViewModelProtocol
- PhoneForgotPasswordSuccessViewModelProtocol
- PhoneForgotPasswordViewModelProtocol

**First Deposit Flow (5 protocols, each with mock):**
- FirstDepositPromotionsViewModelProtocol
- DepositVerificationViewModelProtocol
- DepositBonusSuccessViewModelProtocol
- DepositBonusViewModelProtocol
- DepositAlternativeStepsViewModelProtocol

**Search:**
- SportsSearchViewModelProtocol
- CasinoSearchViewModelProtocol
- TransactionHistoryViewModelProtocol (even has its own app-specific mock!)

### Experiments & Notes
- Used parallel Grep searches across BetssonCameroonApp and BetssonFranceApp
- Pattern searches: `Mock\w+ViewModel`, `protocol \w+ViewModelProtocol`, `: Mock\w+ViewModel`
- BetssonFranceApp has fewer violations (4 mocks, 5 protocols) - mostly in password recovery flow
- Type casting pattern found: `if let mockViewModel = self.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel` - production code downcasting protocols to concrete mock types!

### Useful Files / Links
- [TODO_TASKS.md](../../TODO_TASKS.md) - Added comprehensive refactoring entries
- [SportsBetslipViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift) - Most critical example
- [PhoneRegistrationViewModel.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Dynamic mock creation
- [MVVM Architecture Guide](../MVVM.md) - Reference for correct patterns

### Impact Assessment
**Type Safety**: Production code performing runtime downcasts from protocols to concrete mock types
**Maintainability**: 3x file proliferation for single features (Protocol + Implementation + Mock)
**Architectural Confusion**: New developers will copy these incorrect patterns
**Testing**: Impossible to distinguish test infrastructure from production code
**Spread**: Pattern already spreading from BetssonCameroonApp to BetssonFranceApp

### Next Steps
1. Prioritize betslip refactoring (highest business value, most mock usage)
2. Create concrete ViewModel implementations for most-used GomaUI components (Button, TextField, etc.)
3. Remove app ViewModel protocols starting with registration flow (most complex, 5 dynamic mocks)
4. Update MVVM.md documentation to explicitly warn against this pattern
5. Consider adding SwiftLint rule to prevent Mock* imports in app code
