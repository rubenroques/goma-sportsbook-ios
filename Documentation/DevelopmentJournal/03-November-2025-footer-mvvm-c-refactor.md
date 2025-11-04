# Footer Component - Stack Views Refactor & MVVM-C Architecture

## Date
03 November 2025

## Project / Branch
sportsbook-ios / rr/live_scores

## Goals for this session
- Refactor ExtendedListFooterView to use nested stack views instead of manual AutoLayout
- Fix footer "smashed" height issue in BetssonCameroonApp
- Implement proper MVVM-C architecture for footer navigation
- Create production ViewModel (remove Mock usage in production)
- Delegate URL/email opening to Coordinators

## Achievements

### Stack Views Refactor (GomaUI)
- [x] Refactored partner logos section: nested vertical/horizontal stacks (dynamic 2-per-row layout)
- [x] Refactored certification badges section: horizontal stack view
- [x] Simplified payment providers section: removed container wrapper, direct stack
- [x] Added mock presets for testing: `.threePartnersFooter`, `.singlePartnerFooter`, `.fivePartnersFooter`
- [x] Added SwiftUI previews: "Three Partners", "Single Partner", "Five Partners (3 Rows)"

### Footer Height Fix
- [x] Identified root cause: Using `cell.contentView` instead of actual view in `MarketGroupCardsViewController`
- [x] Fixed: Add `ExtendedListFooterView` directly to `footerInnerView` (proper intrinsic content size)
- [x] Removed `FooterTableViewCell` dependency from view controller setup

### MVVM-C Architecture Implementation
- [x] Created `ExtendedListFooterViewModel.swift` (production ViewModel, not Mock)
- [x] Created `FooterLinkType+URL.swift` extension (URL mapping logic)
- [x] Updated `MarketGroupCardsViewModel`: added footer ViewModel + navigation closures
- [x] Updated `MarketGroupCardsViewController`: gets footer ViewModel from parent (MVVM-C)
- [x] Updated `NextUpEventsViewController`: added navigation closures, delegates to coordinator
- [x] Updated `InPlayEventsViewController`: same MVVM-C pattern
- [x] Updated `NextUpEventsCoordinator`: handles URL opening (external Safari) + email (mailto:)
- [x] Updated `InPlayEventsCoordinator`: same coordinator pattern

## Issues / Bugs Hit
- [x] Footer appeared "smashed" without height → Fixed by using view directly, not cell wrapper
- [x] Using `MockExtendedListFooterViewModel` in production → Created production ViewModel
- [x] ViewControllers deciding how to open URLs → Moved decision to Coordinators
- [x] Email using `MFMailComposeViewController` (requires Mail app config) → Switched to `mailto:` URLs

## Key Decisions

### Stack Views Architecture
- **Nested stacks over manual constraints**: Cleaner, more maintainable, dynamic
- **Dynamic row layout**: 2 logos per row, supports any number of partner logos
- **Consistent pattern**: All grid sections (partners, payments, certifications) use stack views

### MVVM-C Navigation Pattern
- **Coordinator decides HOW**: External Safari for all web links (not SFSafariViewController)
- **mailto: for email**: Opens user's default email app (Gmail, Outlook, Mail, etc.)
- **ViewControllers delegate up**: Don't decide navigation behavior, just pass through
- **Production ViewModels**: No Mock in production app code

### URL Opening Strategy
- **External Safari**: `UIApplication.shared.open(url)` for all web links
- **System email handler**: `mailto:` URLs let iOS choose email app
- **No in-app browser**: Keeps navigation simple, lets user choose their experience

### Component Architecture
```
User taps link
  ↓ ExtendedListFooterView (detects tap)
  ↓ ExtendedListFooterViewModel (maps to URL/email)
  ↓ MarketGroupCardsViewModel (navigation closure)
  ↓ MarketGroupCardsViewController (delegates up)
  ↓ NextUpEventsViewController (delegates up)
  ↓ NextUpEventsCoordinator (DECIDES: external Safari or mailto:)
  ↓ UIApplication.shared.open()
```

## Experiments & Notes

### Stack Views Refactor
- Tested with 1, 3, 4, 5 partner logos - all layouts work correctly
- SwiftUI previews render perfectly with nested stacks
- Dynamic height calculation works automatically with intrinsic content size

### MVVM-C Benefits
- Easy to change navigation behavior (Safari vs SFSafariVC) without touching ViewControllers
- Testable: Each layer can be tested independently
- Reusable: Footer can be used anywhere with different coordinators
- Maintainable: Clear responsibilities at each layer

## Architecture Pattern

### File Structure
```
GomaUI/
└── ExtendedListFooterView/
    ├── ExtendedListFooterView.swift (nested stack views)
    ├── ExtendedListFooterViewModelProtocol.swift
    ├── MockExtendedListFooterViewModel.swift (with new presets)
    ├── ExtendedListFooterImageResolver.swift
    └── ExtendedListFooterModels.swift

BetssonCameroonApp/
├── ViewModels/
│   └── ExtendedListFooterViewModel.swift (PRODUCTION)
├── Extensions/
│   └── FooterLinkType+URL.swift (URL mapping)
├── Screens/
│   ├── NextUpEvents/
│   │   ├── NextUpEventsViewController.swift (navigation closures)
│   │   ├── MarketGroupCardsViewController.swift (uses footer ViewModel)
│   │   └── MarketGroupCardsViewModel.swift (footer ViewModel + closures)
│   └── InPlayEvents/
│       └── InPlayEventsViewController.swift (navigation closures)
└── Coordinators/
    ├── NextUpEventsCoordinator.swift (URL/email opening)
    └── InPlayEventsCoordinator.swift (URL/email opening)
```

### MVVM-C Responsibilities

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **View** | UI & user interaction | `ExtendedListFooterView` |
| **ViewModel** | Business logic & state | `ExtendedListFooterViewModel` |
| **ViewController** | View lifecycle & delegation | `NextUpEventsViewController` |
| **Coordinator** | **Navigation decisions** | `NextUpEventsCoordinator` |

## Useful Files / Links

### Stack Views Refactor
- [ExtendedListFooterView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterView.swift) - Lines 115-148 (partner logos grid), 396-430 (certification badges)
- [MockExtendedListFooterViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/MockExtendedListFooterViewModel.swift) - Lines 116-136 (new test presets)

### Production ViewModels
- [ExtendedListFooterViewModel.swift](../../BetssonCameroonApp/App/ViewModels/ExtendedListFooterViewModel.swift) - Production ViewModel
- [FooterLinkType+URL.swift](../../BetssonCameroonApp/App/Extensions/FooterLinkType+URL.swift) - URL mapping extension

### MVVM-C Implementation
- [MarketGroupCardsViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift) - Lines 52-84 (footer setup)
- [MarketGroupCardsViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift) - Lines 108-150 (sticky footer setup)
- [NextUpEventsViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewController.swift) - Lines 50-52 (navigation closures), 600-610 (delegation)
- [NextUpEventsCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/NextUpEventsCoordinator.swift) - Lines 63-92 (URL/email opening), 98-105 (closure wiring)
- [InPlayEventsViewController.swift](../../BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewController.swift) - Lines 49-51 (navigation closures), 578-588 (delegation)
- [InPlayEventsCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/InPlayEventsCoordinator.swift) - Lines 58-87 (URL/email opening), 120-127 (closure wiring)

### Reference
- [Previous Footer Journal](./02-November-2025-extended-list-footer-component.md) - Initial implementation
- [MVVM.md](../MVVM.md) - Architecture documentation
- [UI_COMPONENT_GUIDE.md](../UI_COMPONENT_GUIDE.md) - Component patterns

## Next Steps
1. Test footer in simulator - verify height is correct and links work
2. Test mailto: URLs with different email apps (Gmail, Outlook, Spark)
3. Test external Safari opening on device
4. Consider applying same MVVM-C pattern to other navigation points
5. Update `FooterTableViewCell.swift` if still used elsewhere (or remove if obsolete)
6. Consider coordinator-level URL configuration (staging vs production URLs)
7. Add analytics tracking for footer link taps in coordinators

## Benefits Summary

### Stack Views Refactor
✅ Dynamic layout supports any number of logos
✅ Cleaner code - no manual constraint calculations
✅ More maintainable - stack views handle distribution
✅ Better for future changes (add/remove logos easily)

### MVVM-C Architecture
✅ Proper separation of concerns
✅ Coordinator controls navigation behavior
✅ Easy to test each layer independently
✅ Flexible - change navigation without touching VCs
✅ Production-ready - no Mocks in production code
✅ User-friendly - mailto: works with any email app
