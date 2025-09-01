## Date
29 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Create TicketSelectionView demo controller with dual modes (stack view + table view)
- Create TicketBetInfoView demo controller following same pattern
- Fix AutoLayout issues in TicketSelectionView component
- Modernize SwiftUI previews to use PreviewUIViewController pattern
- Address dynamic height calculation issues in table view cells

### Achievements
- [x] **Fixed critical AutoLayout issues in TicketSelectionView**:
  - Added missing `matchContentView.heightAnchor.constraint(equalToConstant: 40)` for deterministic height
  - Set proper content hugging/compression resistance priorities on team and score labels
  - Changed score label width constraints from `equalToConstant` to `greaterThanOrEqualToConstant`
  - Added missing bottom constraint for `awayTeamLabel`
  - Fixed horizontal spacing constraints in bottom section
- [x] **Created TicketSelectionViewController** with dual display modes:
  - Stack view mode with 7 different mock states
  - Table view mode with TicketSelectionTableViewCell wrapper
  - Interactive tap handlers with alert demonstrations
  - Dynamic height calculation for table view cells
- [x] **Created TicketBetInfoViewController** following same pattern:
  - 6 mock states showcasing different corner radius styles and cashout components
  - Interactive rebet, cashout, and navigation callbacks
  - Proper table view cell wrapper with corner style support
- [x] **Modernized SwiftUI previews** for both components:
  - Replaced UIViewRepresentable pattern with PreviewUIViewController
  - Updated from iOS 13.0 to iOS 17.0 availability
  - Individual #Preview declarations instead of grouped PreviewProvider
- [x] **Updated ComponentRegistry** with both new demo controllers
- [x] **Fixed table view dynamic height calculation issues**:
  - Improved cell layout timing with proper `layoutIfNeeded()` calls
  - Added content priorities and constraint management
  - Implemented smart estimated height calculation based on content type
  - Added proper `intrinsicContentSize` handling

### Issues / Bugs Hit
- [x] **TicketSelectionView text overlapping**: Team names bleeding into other elements due to missing vertical constraints
- [x] **Table view compressed cells on initial load**: Dynamic height calculation failing, requiring scroll to trigger proper layout
- [x] **Inconsistent spacing**: AutoLayout priority conflicts causing compression
- [x] **Preview rendering issues**: Old UIViewRepresentable pattern not rendering correctly in Xcode 16

### Key Decisions
- **Hardcoded height for matchContentView**: Used `heightAnchor.constraint(equalToConstant: 40)` instead of complex content-based calculations for reliability
- **PreviewUIViewController adoption**: Switched to modern preview pattern for better AutoLayout rendering and consistency across framework
- **Content-aware height estimation**: Implemented smart estimation (280-500pt range) instead of generic 200pt for all table cells
- **Required content priorities**: Used `.required` priorities for critical layout elements to prevent compression
- **One type per file rule**: Maintained GomaUI architectural standard of separating cell classes into dedicated files

### Experiments & Notes
- Tried content-based height calculation for matchContentView but hardcoded 40pt proved more reliable
- Used `systemLayoutSizeFitting` instead of `sizeThatFits` for more accurate cell size calculations
- Added `invalidateIntrinsicContentSize()` calls to trigger proper table view height recalculation
- Experimented with different content priority combinations - `.required` for vertical, `.defaultHigh` for horizontal worked best

### Useful Files / Links
- [TicketSelectionView Component](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketSelectionView/TicketSelectionView.swift)
- [TicketBetInfoView Component](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TicketBetInfoView/TicketBetInfoView.swift)  
- [TicketSelectionViewController Demo](../../Frameworks/GomaUI/Demo/Components/TicketSelectionViewController.swift)
- [TicketBetInfoViewController Demo](../../Frameworks/GomaUI/Demo/Components/TicketBetInfoViewController.swift)
- [ComponentRegistry](../../Frameworks/GomaUI/Demo/Components/ComponentRegistry.swift)
- [GomaUI Component Guide](../../Frameworks/GomaUI/CLAUDE.md)
- [UIKit Code Organization Guide](../../Documentation/UIKIT_CODE_ORGANIZATION_GUIDE.md)

### Next Steps
1. Test both demo controllers in GomaUIDemo app to validate fixes work correctly
2. Consider creating similar demo controllers for other missing betting components (CashoutSliderView, OddsAcceptanceView)  
3. Review and potentially fix other components with similar AutoLayout issues
4. Document the hardcoded height pattern for future component development
5. Update component creation templates to include proper content priorities by default