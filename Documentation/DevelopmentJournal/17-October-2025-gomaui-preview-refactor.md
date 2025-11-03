# GomaUI Preview Refactor Session

## Date
17 October 2025

### Project / Branch
sportsbook-ios / rr/oddsboost_ui

### Goals for this session
- Refactor GomaUI components from PreviewUIView to PreviewUIViewController
- Improve preview render fidelity to match runtime behavior
- Consolidate multiple previews into single comprehensive previews
- Establish consistent preview pattern across all simple components

### Achievements
- [x] Documented why PreviewUIViewController provides better runtime-render fidelity
- [x] Refactored 9 simple GomaUI components to use PreviewUIViewController:
  1. **ActionButtonBlockView** - Added NEW preview (previously had none) with 3 button states
  2. **ResendCodeCountdownView** - 2 countdown states (60s, 5s)
  3. **StepInstructionView** - 3 instruction states with different highlights
  4. **WalletWidgetView** - 3 balance variations (default, high, low)
  5. **BorderedTextFieldView** - 7 comprehensive states (phone, password, email, name, error, disabled, focused)
  6. **CustomSliderView** - 6 slider variations (default, mid position, time filter, disabled, custom image, volume)
  7. **OddsAcceptanceView** - 3 checkbox states (accepted, not accepted, disabled)
  8. **ProgressInfoCheckView** - 3 progress states (win boost, complete, disabled)
  9. **CodeClipboardView** - 4 clipboard states (default, copied, custom code, disabled)
  10. **CodeInputView** - 4 input states (default, loading, error, with code) with scrollView
  11. **MarketOutcomesLineView** - 4 market types (two way, three way, suspended, see all)
  12. **ButtonView** - 6 main button states (solid, bordered, transparent - each enabled/disabled)
- [x] Established consistent preview pattern:
  - Single preview with title label at top showing component name
  - All variations visible at once in scrollable view
  - Proper Auto Layout (no fixed frames)
  - ScrollView added when needed for longer component lists

### Issues / Bugs Hit
None - refactoring went smoothly

### Key Decisions
- **Single Preview Pattern**: Always prefer one preview with all variations inside rather than multiple separate previews
- **Title Label Mandatory**: Every preview must have a centered title label with the component name at the top
- **No Fixed Frames**: Use intrinsic content sizing and Auto Layout constraints instead of `.frame()` modifiers
- **ScrollView for Long Lists**: Components with 4+ states should use ScrollView to ensure all variations are accessible
- **PreviewUIViewController over PreviewUIView**: Provides pixel-perfect runtime fidelity because:
  - Actual UIKit code execution (same layout engine, constraints, view lifecycle)
  - StyleProvider consistency (theming works identically)
  - Protocol-driven ViewModels (same initialization path)
  - Layout engine parity (Auto Layout resolves correctly)
  - No SwiftUI ↔ UIKit impedance mismatch

### Experiments & Notes
- GradientView was noted as already having an excellent PreviewUIViewController implementation with comprehensive states
- Explored 29 components still using PreviewUIView (via Explore agent)
- Categorized components into "simple" (straightforward refactor) vs "complex" (need careful handling)
- BorderedTextFieldView was expanded from 2 to 7 states using existing mock factory methods
- CustomSliderView showcased 6 different configurations including custom SF Symbols and colors

### Useful Files / Links
- [PreviewUIViewController Helper](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIViewController.swift)
- [PreviewUIView Helper (Legacy)](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIView.swift)
- [GradientView Example](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/HelperViews/GradientView.swift) - Reference implementation
- [UI Component Guide](Documentation/UI_COMPONENT_GUIDE.md)
- [MVVM Architecture Guide](Documentation/MVVM.md)

### Remaining Work
**15 "complex" components** still need refactoring but require more careful handling:
- PinDigitEntryView (interactive keyboard handling)
- ThemeSwitcherView (has both preview types in same file)
- TimeSliderView (custom container setup)
- TallOddsMatchCardView (likely complex layout)
- MultiWidgetToolbarView (multiple widgets)
- AdaptiveTabBarView (tab navigation)
- SportGamesFilterView, SortFilterView, LeaguesFilterView, GeneralFilterBarView (filter components)
- PromotionalBonusCardsScrollView, PromotionalBonusCardView (scrolling cards)
- LanguageSelectorView, CountryLeaguesFilterView (selection UI)
- MatchDateNavigationBarView, CustomNavigationView (navigation components)
- TopBannerSliderView, CasinoGamePlayModeSelectorView (banner/selector UI)
- TransactionVerificationView (verification flow)

### Next Steps
1. Continue refactoring complex components one-by-one with careful attention to interactions
2. Consider creating documentation/guidelines for preview best practices
3. Update UI_COMPONENT_GUIDE.md to mandate PreviewUIViewController for all new components
4. Review ButtonView's other preview groups ("Custom Color Examples", "Font Customization") for potential consolidation
