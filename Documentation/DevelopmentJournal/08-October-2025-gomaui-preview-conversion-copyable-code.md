# Development Journal Entry

## Date
08 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Convert BetInfoSubmissionView previews from PreviewUIView to PreviewUIViewController
- Convert StatusNotificationView previews to modern PreviewUIViewController pattern
- Create new CopyableCodeView component for share betslip feature

### Achievements
- [x] Converted BetInfoSubmissionView previews (3 states: Default, Sample Data, Disabled)
- [x] Extracted StatusNotificationType enum to separate file (file organization compliance)
- [x] Converted StatusNotificationView from legacy PreviewProvider to modern #Preview macros
- [x] Created 4 StatusNotificationView previews including "All States" composite preview
- [x] Created complete CopyableCodeView component with 3 files:
  - CopyableCodeViewModelProtocol.swift (simple protocol, no Combine)
  - MockCopyableCodeViewModel.swift (struct with 4 factory methods)
  - CopyableCodeView.swift (horizontal layout matching Figma design)
- [x] Fixed layout from vertical stack to horizontal "label | [code + icon]" layout after Figma review
- [x] Added 3 previews for CopyableCodeView (Booking Code, Promo Code, Long Code)

### Issues / Bugs Hit
- [x] Initial CopyableCodeView had vertical layout (label on top, code below)
  - **Fixed**: Used Figma MCP to fetch design (node 2208-210361)
  - Corrected to horizontal layout with label on left, code container on right
  - Updated styling: dark container (backgroundPrimary/backgroundGradient2), orange code text

### Key Decisions
- **No Combine/Publishers for CopyableCodeView**: Data is static, view manages internal state
  - Simpler architecture for temporary UI feedback (copied state)
  - View uses Timer for auto-revert after 2 seconds
  - Mock simulates clipboard operation with print statement
- **File Organization**: One type per file (extracted StatusNotificationType enum)
- **Preview Strategy**: Using PreviewUIViewController for better AutoLayout rendering
- **Component Reusability**: CopyableCodeView designed for booking codes, promo codes, referral codes, transaction IDs

### Experiments & Notes
- **PreviewUIViewController vs PreviewUIView**: ViewController-based previews provide better constraint rendering
- **Internal State Management**: View manages `isShowingCopied` state with UIView.transition crossfade animation (0.3s)
- **Haptic Feedback**: Added UIImpactFeedbackGenerator on copy tap
- **Auto-revert Pattern**: Timer-based state reset commonly used in GomaUI for temporary feedback

### Useful Files / Links
- [CopyableCodeView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CopyableCodeView/CopyableCodeView.swift)
- [StatusNotificationView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/StatusNotificationView/StatusNotificationView.swift)
- [BetInfoSubmissionView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/BetInfoSubmissionView.swift)
- [Figma Design - Share Betslip](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=2208-210361&m=dev)
- [GomaUI Component Guide](Frameworks/GomaUI/CLAUDE.md)
- [UI Component Guide](Documentation/UI_COMPONENT_GUIDE.md)

### Component Architecture Discussion
Discussed breaking down share betslip modal into reusable components:
1. **ShareSheetHeaderView** - Generic modal header (icon, title, close button)
2. **CopyableCodeView** - Code display with copy-to-clipboard (✅ COMPLETED)
3. **ShareChannelButtonView** - Individual social share button
4. **ShareChannelsGridView** - Grid layout of share options

Decided on **generic, reusable naming** (Option A) over context-specific names for maximum component reusability across features.

### Next Steps
1. Create ShareChannelsGridView and ShareChannelButtonView components
2. Create ShareSheetHeaderView for modal headers
3. Test CopyableCodeView in GomaUIDemo app
4. Implement full share betslip modal composition
5. Add production ViewModel that uses UIPasteboard for actual clipboard operations
