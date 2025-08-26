## Date
26 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix WalletDetailView UI to match Figma design
- Resolve color visibility issues on orange background
- Add missing phone number to header
- Fix button styling (withdraw bordered white, deposit solid white)

### Achievements
- [x] Created dedicated WalletDetailBalanceLineView for white text on orange background
- [x] Replaced problematic WalletBalanceLineView with custom white-themed component
- [x] Added phoneNumber field to WalletDetailData model and all related components
- [x] Updated WalletDetailHeaderView to display phone number with proper layout
- [x] Fixed all text colors to use StyleProvider.Color.allWhite for proper contrast
- [x] Updated button styling timing (moved to layoutSubviews) for white-on-orange theme
- [x] Updated all MockWalletDetailViewModel mock data to include phone numbers
- [x] Maintained MVVM architecture and reactive Combine patterns

### Issues / Bugs Hit
- [x] **WalletBalanceLineView color mismatch**: Component was designed for white backgrounds, orange text on orange background was invisible
- [x] **Button styling timing issue**: Styling applied before ButtonView internal setup was complete
- [x] **Missing phone number**: Model and UI were missing phone number field from Figma design
- [x] **Component reuse problem**: WalletStatusView's WalletBalanceLineView wasn't suitable for orange background

### Key Decisions
- **Created dedicated WalletDetailBalanceLineView**: Rather than hack existing component, created clean white-themed version
- **Applied button styling in layoutSubviews()**: Ensures buttons are fully initialized before custom theming
- **Used internal class**: WalletDetailBalanceLineView is internal, not public like WalletBalanceLineView
- **Preserved existing WalletBalanceLineView**: Maintained separation - WalletStatusView unchanged

### Experiments & Notes
- Tried recursive view traversal to override WalletBalanceLineView colors → fragile approach, abandoned
- Discovered ButtonView uses hardcoded StyleProvider colors → needed custom override in layoutSubviews
- Found optimal layout: phone number right-aligned, wallet title left, proper spacing constraints

### Useful Files / Links
- [WalletDetailView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailView.swift)
- [WalletDetailBalanceLineView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailBalanceLineView.swift) - New component
- [WalletDetailViewModelProtocol.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailViewModelProtocol.swift) - Updated with phoneNumber
- [MockWalletDetailViewModel.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/MockWalletDetailViewModel.swift) - All mocks updated
- [WalletDetailHeaderView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/WalletDetailView/WalletDetailHeaderView.swift) - Added phone number
- [Figma Design](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=7263-39001&m=dev) - Reference design

### Next Steps
1. Build and test in GomaUIDemo simulator to verify visual appearance
2. Add WalletDetailView to ComponentsTableViewController if not already present
3. Create integration tests for phone number display
4. Consider extracting button white-theme styling to reusable utility
5. Document the new WalletDetailBalanceLineView in component README

### Component Architecture Summary
```
WalletDetailView/
├── WalletDetailView.swift                    # Main container
├── WalletDetailHeaderView.swift              # Header with icon, title, phone
├── WalletDetailBalanceView.swift             # Balance section using new lines
├── WalletDetailBalanceLineView.swift         # NEW: White-themed balance lines
├── WalletDetailViewModelProtocol.swift       # Updated with phoneNumber
└── MockWalletDetailViewModel.swift           # All mocks updated

Color Strategy:
- Orange background: StyleProvider.Color.highlightPrimary
- White text: StyleProvider.Color.allWhite (titles, values, separators)
- White buttons: Custom styling in layoutSubviews()
- Header: White background with dark text
```

This session successfully resolved the UI mismatch by creating proper component separation rather than forcing incompatible components to work together.