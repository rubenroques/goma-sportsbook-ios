## Date
12 December 2025

### Project / Branch
BetssonCameroonApp / rr/bet-at-home

### Goals for this session
- Fix profile menu icon tinting (showing orange instead of bet-at-home green)
- Implement client-specific branding logo system for top bar and other screens

### Achievements
- [x] Fixed profile menu icon tinting by applying `.withRenderingMode(.alwaysTemplate)` to ActionRowView bundle images
- [x] Created `BrandLogoImageResolver` protocol in GomaUI following existing ImageResolver pattern
- [x] Added `brandLogoResolver` property to `MultiWidgetToolbarViewModelProtocol`
- [x] Implemented `AppBrandLogoImageResolver` in BetssonCameroonApp
- [x] Added `TargetVariables.brandLogoAssetName` to return client-specific asset names based on build environment
- [x] Added bet-at-home logo asset (`bet_at_home_brand_horizontal`) to Media.xcassets
- [x] Updated MultiWidgetToolbarView to use resolver instead of hardcoded logo
- [x] Replaced all hardcoded brand logo references across 8 view controllers:
  - PhoneLoginViewController
  - PhoneRegistrationViewController
  - SplashInformativeViewController
  - VersionUpdateViewController
  - MaintenanceViewController
  - DepositWebContainerViewController
  - WithdrawWebContainerViewController
  - MockDepositAlternativeStepsViewModel
- [x] Fixed logo sizing issue with aspect ratio constraint + max width cap (140pt)

### Issues / Bugs Hit
- [x] Logo was expanding too wide horizontally, compressing wallet widget
  - Root cause: bet-at-home 1x image is 779×188 pixels (iOS interprets as points for intrinsic content size)
  - Solution: Added aspect ratio constraint with `.defaultHigh` priority + max width constraint at `.required` priority

### Key Decisions
- Used **ImageResolver pattern** (consistent with `LanguageFlagImageResolver`, `ExtendedListFooterImageResolver`) instead of modifying asset catalogs
- `TargetVariables.brandLogoAssetName` serves as single source of truth for client branding
- Logo constraints: height=32pt fixed, width=aspectRatio×height but capped at 140pt max
- Used **white** bet-at-home logo variant (white text + green underline) for dark top bar backgrounds

### Experiments & Notes
- Explored multiple targets for same-named assets - not viable without separate targets
- Considered asset catalog `template-rendering-intent` but code-based `.alwaysTemplate` is cleaner for ActionRowView
- bet-at-home logo aspect ratio (~4.14:1) vs Betsson (~5.56:1) - both fit within 140pt cap

### Useful Files / Links
- [BrandLogoImageResolver.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/BrandLogoImageResolver.swift) - New protocol
- [AppBrandLogoImageResolver.swift](../../BetssonCameroonApp/App/Style/AppBrandLogoImageResolver.swift) - App implementation
- [TargetVariables.swift](../../BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift) - brandLogoAssetName property
- [MultiWidgetToolbarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MultiWidgetToolbarView/MultiWidgetToolbarView.swift) - Logo sizing fix
- [ActionRowView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowView.swift) - Icon tinting fix

### Next Steps
1. Test all screens with bet-at-home logo to verify sizing/appearance
2. Consider resizing bet-at-home logo source files to proper 1x/2x/3x dimensions
3. Add bet-at-home specific assets for other branding elements if needed
