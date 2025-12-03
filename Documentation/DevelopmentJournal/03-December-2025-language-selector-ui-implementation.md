## Date
03 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Implement language selector UI with two presentation modes
- Floating overlay from top bar (like wallet popup)
- Full screen pushed view from Profile screen (MVVM-C pattern)
- Add proper flag images with ImageResolver pattern

### Achievements
- [x] Created `LanguageSelectorViewModel` in BetssonCameroonApp for EN/FR language support
- [x] Added floating language overlay to `TopBarContainerController` with spring animation
- [x] Implemented auto-dismiss on language selection
- [x] Created full MVVM-C stack for profile screen:
  - `LanguageSelectorCoordinator`
  - `LanguageSelectorFullScreenViewController`
  - `LanguageSelectorFullScreenViewModelProtocol`
  - `LanguageSelectorFullScreenViewModel`
  - `MockLanguageSelectorFullScreenViewModel`
- [x] Wired up `ProfileWalletCoordinator` to use new coordinator
- [x] Added flag images to `Media.xcassets/Flags/` (flag_en, flag_fr)
- [x] Created `LanguageFlagImageResolver` protocol in GomaUI
- [x] Updated `LanguageItemView` to use `UIImageView` instead of `UILabel` for flags
- [x] Updated `LanguageSelectorView` to accept `imageResolver` parameter
- [x] Made `flagIcon` deprecated in `LanguageModel` (now derived from `id` via resolver)
- [x] Created `AppLanguageFlagImageResolver` in BetssonCameroonApp
- [x] Used localized strings for language names (`language_english`, `language_french`)

### Issues / Bugs Hit
- [ ] Build verification pending - session ended before compilation test

### Key Decisions
- **ImageResolver pattern**: Flag images are resolved based on language `id`, not stored in model
- **Deprecated `flagIcon`**: Kept for backwards compatibility but marked deprecated
- **Localized language names**: Use `localized("language_english")` instead of hardcoded strings
- **UIImageView over UILabel**: Replaced emoji-based flag label with proper image view for asset support
- **Globe fallback**: When no resolver or image found, falls back to SF Symbol globe icon

### Experiments & Notes
- Initially used `flagIcon` property in `LanguageModel` to store asset names
- Refactored to ImageResolver pattern to avoid redundant data and follow existing patterns in codebase
- GomaUI `LanguageSelectorView` now optionally accepts `imageResolver` parameter

### Useful Files / Links

**New Files Created:**
- `BetssonCameroonApp/App/ViewModels/LanguageSelectorViewModel.swift`
- `BetssonCameroonApp/App/Coordinators/LanguageSelectorCoordinator.swift`
- `BetssonCameroonApp/App/Screens/LanguageSelector/LanguageSelectorFullScreenViewController.swift`
- `BetssonCameroonApp/App/Screens/LanguageSelector/LanguageSelectorFullScreenViewModelProtocol.swift`
- `BetssonCameroonApp/App/Screens/LanguageSelector/LanguageSelectorFullScreenViewModel.swift`
- `BetssonCameroonApp/App/Screens/LanguageSelector/MockLanguageSelectorFullScreenViewModel.swift`
- `BetssonCameroonApp/App/Services/ImageResolvers/LanguageFlagImageResolver.swift`
- `BetssonCameroonApp/App/Resources/Assets/Media.xcassets/Flags/flag_en.imageset/`
- `BetssonCameroonApp/App/Resources/Assets/Media.xcassets/Flags/flag_fr.imageset/`
- `Frameworks/GomaUI/.../LanguageSelectorView/LanguageFlagImageResolver.swift`

**Modified Files:**
- `BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift`
- `BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift`
- `Frameworks/GomaUI/.../LanguageSelectorView/LanguageItemView.swift`
- `Frameworks/GomaUI/.../LanguageSelectorView/LanguageSelectorView.swift`
- `Frameworks/GomaUI/.../LanguageSelectorView/LanguageModel.swift`

### Next Steps
1. Build and verify compilation
2. Test floating overlay presentation from top bar
3. Test full screen presentation from Profile menu
4. Connect language switching logic (actual locale change)
5. Add visual polish if needed based on testing
