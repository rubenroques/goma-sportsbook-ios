# ExtendedListFooterView Auto Layout Width Fix

## Date
03 November 2025

## Project / Branch
sportsbook-ios / rr/live_scores

## Goals for this session
- Study the ExtendedListFooterView component architecture
- Diagnose Auto Layout issue causing 0-width container views
- Fix container width constraints for proper layout

## Achievements
- [x] Completed comprehensive study of ExtendedListFooterView component
- [x] Documented component architecture, patterns, and design decisions
- [x] Identified root cause: centered UIStackView alignment with missing width constraints
- [x] Applied fix to 4 affected sections (Partnership, Social Media, Responsible Gambling, License)
- [x] Added width constraints: `sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)`

## Issues / Bugs Hit
- [x] **0-width container bug**: Container views had 0 width despite visible subviews
  - **Cause**: `mainStackView.alignment = .center` doesn't impose width on arranged subviews
  - **Symptom**: Subviews only visible because `clipsToBounds = false` (overflow rendering)
  - **Solution**: Added explicit width constraint to match parent stack width

## Key Decisions
- **Option 1 (Chosen)**: Add width constraints to containers
  - ✅ Minimal code changes
  - ✅ Preserves centered layout intent
  - ✅ Fixes 0-width issue
  - ✅ Maintains current visual appearance
- **Option 2 (Rejected)**: Change stack alignment to `.fill`
  - ❌ Would affect all sections, not just problematic ones
- **Option 3 (Rejected)**: Replace `centerXAnchor` with `leading/trailing`
  - ❌ More complex, changes constraint approach

## Experiments & Notes

### Component Architecture Insights
- **Protocol-driven MVVM**: View uses `ExtendedListFooterViewModelProtocol`
- **Image resolver pattern**: Flexible asset loading (GomaUI bundle → App bundle → SF Symbol fallbacks)
- **Enum-based type safety**: Uses `PartnerClub`, `PaymentOperator`, `SocialPlatform` enums instead of indices
- **Closure callbacks**: `onLinkTap: ((FooterLinkType) -> Void)?` for interaction
- **Static content**: No Combine publishers (footer content doesn't change frequently)

### Auto Layout Pattern Issue
```swift
// ❌ PROBLEMATIC PATTERN: Container has 0 width
mainStackView.alignment = .center  // Parent doesn't impose width
sectionContainer (no width constraint)
    ├── headerLabel (centerX only)
    └── iconsContainer (centerX only)

// ✅ FIXED PATTERN: Container matches parent width
sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
```

### Affected Sections
1. **Partnership Sponsorships** (lines 91-117) - Fixed
2. **Social Media** (lines 292-318) - Fixed
3. **Responsible Gambling** (lines 362-395) - Fixed
4. **License** (lines 443-483) - Fixed

**Not affected**: Navigation Links, Payment Providers, Copyright (direct label additions or fill-constrained)

### Component Features
- **8 sections**: Partnership, Links, Payment, Social, Gambling, Copyright, License
- **Dynamic partner grid**: 2×2 layout with flexible row count
- **Advanced tap detection**: NSLayoutManager for attributed string link tapping
- **Image resolution layers**: 3-tier fallback (GomaUI → App → SF Symbols)

## Useful Files / Links

### Modified File
- [ExtendedListFooterView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterView.swift)

### Related Component Files
- [ExtendedListFooterViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterViewModelProtocol.swift)
- [ExtendedListFooterModels.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterModels.swift)
- [ExtendedListFooterImageResolver.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterImageResolver.swift)
- [MockExtendedListFooterViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/MockExtendedListFooterViewModel.swift)
- [Component Documentation](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/Documentation/ExtendedListFooterView.md)

### App Integration
- [FooterTableViewCell.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/FooterTableViewCell.swift)
- [AppExtendedListFooterImageResolver.swift](../../BetssonCameroonApp/App/Services/ImageResolvers/AppExtendedListFooterImageResolver.swift)

### Previous Development Journals
- [02-November-2025-extended-list-footer-component.md](02-November-2025-extended-list-footer-component.md)
- [03-November-2025-footer-mvvm-c-refactor.md](03-November-2025-footer-mvvm-c-refactor.md)

## Next Steps
1. Build and test in simulator to verify visual appearance
2. Test all footer sections render with proper width
3. Verify centered alignment maintained for subviews
4. Check footer in both NextUpEvents and InPlayEvents screens
5. Run debug view hierarchy inspector to confirm container widths > 0
6. Consider documenting this Auto Layout pattern in UI Component Guide
