# GomaUI Mock ViewModels Used in Production Code

**Created**: 2026-01-13
**Status**: CRITICAL Technical Debt
**Impact**: 52 files using 56 unique mock ViewModels in production code

## Overview

This document catalogs all GomaUI Mock ViewModels being used directly in BetssonCameroonApp production code. **Mock ViewModels are designed for testing/previews only** - they should not be used in production.

### Why This Is a Problem

1. **Architectural Violation**: Mocks exist for SwiftUI previews and GomaUICatalog demos, not production
2. **Hidden Dependencies**: Production code depends on test infrastructure
3. **GomaUI Mocks Should Be Internal**: They shouldn't even be public API
4. **Fragile Code**: Mock implementations may change without consideration for production usage
5. **Testability**: Can't properly unit test code that already uses mocks

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Files Using Mocks | 52 |
| Unique Mock ViewModels | 56 |
| Most Used Mock | MockButtonViewModel (14 files) |

### Most Frequently Used Mocks

| Mock ViewModel | Usage Count |
|----------------|-------------|
| MockButtonViewModel | 14 |
| MockPromotionalHeaderViewModel | 9 |
| MockHighlightedTextViewModel | 8 |
| MockBorderedTextFieldViewModel | 7 |
| MockBetslipTicketViewModel | 4 |
| MockPromotionCardViewModel | 3 |
| MockPromotionSelectorBarViewModel | 3 |
| MockHeaderTextViewModel | 3 |
| MockInfoRowViewModel | 2 |
| MockStatusNotificationViewModel | 2 |

---

## Complete File-by-File Breakdown

### Coordinators

#### `App/Coordinators/FirstDepositPromotionsCoordinator.swift`
- MockDepositAlternativeStepsViewModel
- MockDepositBonusSuccessViewModel
- MockDepositBonusViewModel
- MockDepositVerificationViewModel
- MockFirstDepositPromotionsViewModel

---

### Extensions

#### `App/Extensions/GomaUI/MockTopBannerSliderViewModel+Casino.swift`
- MockSingleButtonBannerViewModel
- MockTopBannerSliderViewModel

---

### Betslip Screens

#### `App/Screens/Betslip/BetslipViewModel.swift`
- MockBetslipHeaderViewModel
- MockBetslipTypeSelectorViewModel

#### `App/Screens/Betslip/BetSuccessScreen/BetSuccessViewModel.swift`
- MockStatusNotificationViewModel

#### `App/Screens/Betslip/Cells/BetslipTicketTableViewCell.swift`
- MockBetslipTicketViewModel

#### `App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift`
- MockBetslipTicketViewModel
- MockButtonIconViewModel
- MockButtonViewModel
- MockCodeInputViewModel
- MockEmptyStateActionViewModel
- MockSuggestedBetsExpandedViewModel

#### `App/Screens/Betslip/SportsBetslip/SportsBetslipViewModelProtocol.swift`
- MockBetslipTicketViewModel

#### `App/Screens/Betslip/VirtualBetslip/VirtualBetslipViewController.swift`
- MockBetslipTicketViewModel

#### `App/Screens/Betslip/VirtualBetslip/VirtualBetslipViewModel.swift`
- MockBetInfoSubmissionViewModel
- MockButtonIconViewModel
- MockEmptyStateActionViewModel
- MockOddsAcceptanceViewModel

---

### Bonus Screen

#### `App/Screens/Bonus/BonusViewModel.swift`
- MockBonusCardViewModel
- MockBonusInfoCardViewModel
- MockButtonViewModel
- MockPromotionSelectorBarViewModel

---

### Casino Screens

#### `App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewModel.swift`
- MockRecentlyPlayedGamesViewModel

#### `App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewController.swift`
- MockHeaderTextViewModel

#### `App/Screens/CasinoSearch/CasinoSearchViewController.swift`
- MockHeaderTextViewModel

#### `App/Screens/CasinoSearch/CasinoSearchViewModel.swift`
- MockCasinoGameSearchedViewModel

---

### First Deposit Promotions

#### `App/Screens/FirstDepositPromotions/DepositAlternativeSteps/MockDepositAlternativeStepsViewModel.swift`
- MockButtonViewModel
- MockCustomNavigationViewModel
- MockDepositAlternativeStepsViewModel
- MockStepInstructionViewModel

#### `App/Screens/FirstDepositPromotions/DepositBonus/MockDepositBonusViewModel.swift`
- MockAmountPillsViewModel
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockDepositBonusInfoViewModel
- MockDepositBonusViewModel
- MockHighlightedTextViewModel
- MockPromotionalHeaderViewModel

#### `App/Screens/FirstDepositPromotions/DepositBonusSuccess/MockDepositBonusSuccessViewModel.swift`
- MockDepositBonusSuccessViewModel
- MockInfoRowViewModel
- MockStatusNotificationViewModel

#### `App/Screens/FirstDepositPromotions/DepositVerification/MockDepositVerificationViewModel.swift`
- MockButtonViewModel
- MockDepositVerificationViewModel
- MockTransactionVerificationViewModel

#### `App/Screens/FirstDepositPromotions/FirstDepositPromotionsViewController.swift`
- MockFirstDepositPromotionsViewModel

#### `App/Screens/FirstDepositPromotions/MockFirstDepositPromotionsViewModel.swift`
- MockFirstDepositPromotionsViewModel
- MockPromotionalBonusCardsScrollViewModel
- MockPromotionalHeaderViewModel

---

### InPlay Events

#### `App/Screens/InPlayEvents/InPlayEventsViewController.swift`
- MockPillItemViewModel

---

### Language Selector

#### `App/Screens/LanguageSelector/LanguageSelectorFullScreenViewController.swift`
- MockLanguageSelectorFullScreenViewModel

#### `App/Screens/LanguageSelector/MockLanguageSelectorFullScreenViewModel.swift`
- MockLanguageSelectorFullScreenViewModel
- MockLanguageSelectorViewModel

---

### Main Tab Bar

#### `App/Screens/MainTabBar/MainTabBarViewModel.swift`
- MockFloatingOverlayViewModel

---

### Match Details

#### `App/Screens/MatchDetailsTextual/MarketsTab/MarketTypeGroupCollectionViewCell.swift`
- MockMarketOutcomesMultiLineViewModel

#### `App/Screens/MatchDetailsTextual/MarketsTab/MarketTypeGroupTableViewCell.swift`
- MockMarketOutcomesMultiLineViewModel

#### `App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift`
- MockStatisticsWidgetViewModel

---

### Next Up Events

#### `App/Screens/NextUpEvents/CombinedFilters/CombinedFiltersViewController.swift`
- MockTimeSliderViewModel

#### `App/Screens/NextUpEvents/FooterTableViewCell.swift`
- MockExtendedListFooterViewModel

#### `App/Screens/NextUpEvents/NextUpEventsViewModel.swift`
- MockGeneralFilterBarViewModel

#### `App/Screens/NextUpEvents/SeeMoreButtonTableViewCell.swift`
- MockSeeMoreButtonViewModel

---

### Notifications

#### `App/Screens/Notifications/NotificationsViewModel.swift`
- MockNotificationListViewModel

---

### Phone Login

#### `App/Screens/PhoneLogin/PhoneLoginViewModel.swift`
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPhoneLoginViewModel
- MockPromotionalHeaderViewModel

---

### Profile Wallet

#### `App/Screens/ProfileWallet/WalletDetailViewModel.swift`
- MockButtonViewModel

---

### Promotions

#### `App/Screens/Promotions/PromotionDetailViewController.swift`
- MockActionButtonBlockViewModel
- MockBulletItemBlockViewModel
- MockDescriptionBlockViewModel
- MockGradientHeaderViewModel
- MockImageBlockViewModel
- MockImageSectionViewModel
- MockListBlockViewModel
- MockStackViewBlockViewModel
- MockTitleBlockViewModel
- MockVideoBlockViewModel
- MockVideoSectionViewModel

#### `App/Screens/Promotions/PromotionsViewController.swift`
- MockPromotionCardViewModel

#### `App/Screens/Promotions/PromotionsViewModel.swift`
- MockPromotionalHeaderViewModel
- MockPromotionCardViewModel
- MockPromotionSelectorBarViewModel

---

### Password Recovery

#### `App/Screens/RecoverPassword/PhoneForgotPassword/PhoneForgotPasswordViewModel.swift`
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPromotionalHeaderViewModel

#### `App/Screens/RecoverPassword/PhoneForgotPasswordSuccess/PhoneForgotPasswordSuccessViewModel.swift`
- MockButtonViewModel
- MockStatusInfoViewModel

#### `App/Screens/RecoverPassword/PhonePasswordCodeVerify/PhonePasswordCodeVerificationViewModel.swift`
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPinDigitEntryViewModel
- MockPromotionalHeaderViewModel
- MockResendCodeCountdownViewModel

#### `App/Screens/RecoverPassword/PhonePasswordRecover/PhonePasswordCodeResetViewModel.swift`
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPromotionalHeaderViewModel

---

### Registration

#### `App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift`
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPhoneRegistrationViewModel
- MockPromotionalHeaderViewModel
- MockTermsAcceptanceViewModel

#### `App/Screens/Register/PhoneVerification/MockPhoneVerificationViewModel.swift`
- MockButtonViewModel
- MockHighlightedTextViewModel
- MockPhoneVerificationViewModel
- MockPinDigitEntryViewModel
- MockPromotionalHeaderViewModel
- MockResendCodeCountdownViewModel

#### `App/Screens/Register/PhoneVerification/PhoneVerificationViewController.swift`
- MockPhoneVerificationViewModel

---

### Responsible Gaming

#### `App/Screens/ResponsibleGaming/LimitsSuccessScreen/LimitsSuccessViewModel.swift`
- MockInfoRowViewModel

#### `App/Screens/ResponsibleGaming/ResponsibleGamingViewModel.swift`
- MockBorderedTextFieldViewModel
- MockButtonViewModel
- MockExpandableSectionViewModel
- MockTextSectionViewModel

---

### Sports Search

#### `App/Screens/SportsSearch/SearchComponentViewModel.swift`
- MockSearchViewModel

#### `App/Screens/SportsSearch/SportsSearchViewController.swift`
- MockRecentSearchViewModel

---

### Transaction History

#### `App/Screens/TransactionHistory/MockTransactionHistoryViewModel.swift`
- MockTransactionHistoryViewModel

#### `App/Screens/TransactionHistory/TransactionHistoryViewController.swift`
- MockTransactionHistoryViewModel

---

### View Components

#### `App/ViewComponents/HeaderTextReusableView/HeaderTextReusableView.swift`
- MockHeaderTextViewModel

---

### View Models

#### `App/ViewModels/Banners/MatchBannerViewModel.swift`
- MockMarketOutcomesLineViewModel

---

## All 56 Unique Mock ViewModels

1. MockActionButtonBlockViewModel
2. MockAmountPillsViewModel
3. MockBetInfoSubmissionViewModel
4. MockBetslipHeaderViewModel
5. MockBetslipTicketViewModel
6. MockBetslipTypeSelectorViewModel
7. MockBonusCardViewModel
8. MockBonusInfoCardViewModel
9. MockBorderedTextFieldViewModel
10. MockBulletItemBlockViewModel
11. MockButtonIconViewModel
12. MockButtonViewModel
13. MockCasinoGameSearchedViewModel
14. MockCodeInputViewModel
15. MockCustomNavigationViewModel
16. MockDepositAlternativeStepsViewModel
17. MockDepositBonusInfoViewModel
18. MockDepositBonusSuccessViewModel
19. MockDepositBonusViewModel
20. MockDepositVerificationViewModel
21. MockDescriptionBlockViewModel
22. MockEmptyStateActionViewModel
23. MockExpandableSectionViewModel
24. MockExtendedListFooterViewModel
25. MockFirstDepositPromotionsViewModel
26. MockFloatingOverlayViewModel
27. MockGeneralFilterBarViewModel
28. MockGradientHeaderViewModel
29. MockHeaderTextViewModel
30. MockHighlightedTextViewModel
31. MockImageBlockViewModel
32. MockImageSectionViewModel
33. MockInfoRowViewModel
34. MockLanguageSelectorFullScreenViewModel
35. MockLanguageSelectorViewModel
36. MockListBlockViewModel
37. MockMarketOutcomesLineViewModel
38. MockMarketOutcomesMultiLineViewModel
39. MockNotificationListViewModel
40. MockOddsAcceptanceViewModel
41. MockPhoneLoginViewModel
42. MockPhoneRegistrationViewModel
43. MockPhoneVerificationViewModel
44. MockPillItemViewModel
45. MockPinDigitEntryViewModel
46. MockPromotionCardViewModel
47. MockPromotionSelectorBarViewModel
48. MockPromotionalBonusCardsScrollViewModel
49. MockPromotionalHeaderViewModel
50. MockRecentSearchViewModel
51. MockRecentlyPlayedGamesViewModel
52. MockResendCodeCountdownViewModel
53. MockSearchViewModel
54. MockSeeMoreButtonViewModel
55. MockSingleButtonBannerViewModel
56. MockStackViewBlockViewModel
57. MockStatisticsWidgetViewModel
58. MockStatusInfoViewModel
59. MockStatusNotificationViewModel
60. MockStepInstructionViewModel
61. MockSuggestedBetsExpandedViewModel
62. MockTermsAcceptanceViewModel
63. MockTextSectionViewModel
64. MockTimeSliderViewModel
65. MockTitleBlockViewModel
66. MockTopBannerSliderViewModel
67. MockTransactionHistoryViewModel
68. MockTransactionVerificationViewModel
69. MockVideoBlockViewModel
70. MockVideoSectionViewModel
71. MockWalletWidgetViewModel

---

## Resolution Pattern

Follow the pattern established with `BetInfoSubmissionViewModel` (completed 14-Nov-2024):

1. **Create production ViewModel** in app target with factory methods matching Mock pattern
2. **Replace Mock imports** with production ViewModel
3. **Delete Mock usage** from production code

### Example Migration

**Before (using Mock):**
```swift
import GomaUI

let buttonVM = MockButtonViewModel.primary(title: "Submit")
```

**After (production ViewModel):**
```swift
// In app target: App/ViewModels/Components/SubmitButtonViewModel.swift
final class SubmitButtonViewModel: ButtonViewModelProtocol {
    // Real implementation with actual business logic
}

// Usage
let buttonVM = SubmitButtonViewModel(title: "Submit", action: { ... })
```

---

## Priority Ranking

### Critical (Core User Flows)
1. **Betslip** - 7 files, betting is core functionality
2. **Registration** - 3 files, user onboarding
3. **Login** - 1 file, authentication
4. **Password Recovery** - 4 files, account access

### High (Revenue Impact)
5. **First Deposit Promotions** - 6 files, conversion funnel
6. **Casino** - 4 files, revenue stream
7. **Promotions** - 3 files, marketing

### Medium (User Experience)
8. **Transaction History** - 2 files
9. **Responsible Gaming** - 2 files
10. **Match Details** - 3 files
11. **Next Up Events** - 4 files
12. **Search** - 2 files

### Lower (Supporting Features)
13. **Bonus** - 1 file
14. **Language Selector** - 2 files
15. **Notifications** - 1 file
16. **Main Tab Bar** - 1 file

---

## Related TODO Entry

See `TODO_TASKS.md` line 116:
```
- [ ] **[CRITICAL] Replace GomaUI Mock ViewModels with Real Implementations in Production Code**
```

---

## Audit Date

Last audited: 2026-01-13
