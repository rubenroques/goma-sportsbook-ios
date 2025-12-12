## Date
09 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Investigate casino game descriptions showing English instead of French
- Fix language indicator in top bar MultiWidgetToolbar showing "EN" when app is in French
- Prepare release 0.3.4 with all pending fixes

### Achievements
- [x] Identified root cause: `localized("current_language_code")` uses iOS system locale, not app's LanguageManager
- [x] Standardized 15 files to use `LanguageManager.shared.currentLanguageCode` instead of `localized()`
- [x] Fixed MultiWidgetToolbarViewModel to pass language label to language switcher widget
- [x] Added `NSBluetoothAlwaysUsageDescription` to all Info.plist files (App Store requirement for XtremePush SDK)
- [x] Added new tester device (sabrina.rabini iPhone 17 Pro Max)
- [x] Created and pushed release tag BCM-0.3.4(3402)

### Issues / Bugs Hit
- [x] App Store rejected build 3401 due to missing `NSBluetoothAlwaysUsageDescription` - added to all 3 Info.plist files
- [x] Casino game descriptions in wrong language - fixed by using LanguageManager across all API calls

### Key Decisions
- **LanguageManager over localized()**: Standardized on `LanguageManager.shared.currentLanguageCode` for all API language parameters because it respects in-app language selection, while `localized()` only checks iOS system locale
- **App-wide standardization**: Updated all 15 files using language parameter (not just casino) for consistency
- **Build increment**: Bumped from 3401 to 3402 after App Store rejection

### Experiments & Notes

**Language Parameter Flow:**
```
localized("current_language_code") → NSLocalizedString → iOS System Locale
LanguageManager.shared.currentLanguageCode → UserDefaults override → App Language Selection
```

**Files Updated for Language Standardization:**
- Casino: CasinoGamePrePlayViewModel, CasinoCategoriesListViewModel, CasinoCategoryGamesListViewModel, CasinoGamePlayViewModel, CasinoSearchViewModel
- Banking: DepositWebContainerViewModel, WithdrawWebContainerViewModel
- Bonus/Promotions: BonusViewModel, PromotionsViewModel, PromotionDetailViewModel
- Other: BetslipViewModel, PhoneRegistrationViewModel, ExtendedListFooterViewModel, AppExtendedListFooterImageResolver, MultiWidgetToolbarViewModel

**MultiWidgetToolbar Language Indicator Fix:**
```swift
// Before: No label, fell back to Locale.current.languageCode
Widget(id: .languageSwitcher, type: .languageSwitcher)

// After: Explicit label from LanguageManager
Widget(id: .languageSwitcher, type: .languageSwitcher,
       label: LanguageManager.shared.currentLanguageCode.uppercased())
```

### Useful Files / Links
- [LanguageManager.swift](../../BetssonCameroonApp/App/Services/LanguageManager.swift)
- [MultiWidgetToolbarViewModel.swift](../../BetssonCameroonApp/App/ViewModels/MultiWidgetToolbarViewModel.swift)
- [MultiWidgetToolbarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift)
- [AUTO_DISTRIBUTE.md](../../BetssonCameroonApp/fastlane/AUTO_DISTRIBUTE.md)
- [CHANGELOG.yml](../../BetssonCameroonApp/CHANGELOG.yml)

### Next Steps
1. Monitor GitHub Actions for successful dual release (staging + production)
2. Verify casino game descriptions show French when app is in French
3. Verify language indicator shows "FR" when app is in French
4. Test push notifications with XtremePush SDK
