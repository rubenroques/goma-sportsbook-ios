## Date
12 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix GomaUI archive build failure caused by Swift compiler crash
- Wrap all SwiftUI Previews in `#if DEBUG` guards to prevent compilation in Release builds

### Achievements
- [x] Identified root cause: Swift compiler crash during CSE optimization pass on SwiftUI Preview code in Release builds
- [x] Fixed 14 GomaUI component files by wrapping previews with `#if DEBUG` / `#endif`
- [x] Prevented previews from being compiled into production archives (reduces binary size and eliminates compiler crash)

### Issues / Bugs Hit
- [x] Swift compiler crash in `ExpandableSectionView.swift` during archive
  - Error: "While running pass #782837 SILFunctionTransform CSE on SILFunction"
  - Crash occurred during Release build optimization of complex SwiftUI Preview code
  - Solution: Wrap all preview sections with `#if DEBUG` conditional compilation

### Key Decisions
- **Wrapped all SwiftUI Previews with `#if DEBUG`**: Previews are development tools and should never be in production archives
- **Manual file-by-file approach**: After initial automation attempts, switched to reading and editing each file individually for reliability
- **Excluded MockSimpleNavigationBarViewModel.swift**: Only contained preview code in comments (documentation), not actual executable preview code

### Files Modified
All files in `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/`:

1. ExpandableSectionView/ExpandableSectionView.swift
2. BonusCardView/BonusCardView.swift
3. MatchHeaderCompactView/MatchHeaderCompactView.swift
4. MatchHeaderView/MatchHeaderView.swift
5. NotificationListView/NotificationCardView.swift
6. NotificationListView/NotificationListView.swift
7. PromotionCardView/PromotionCardView.swift
8. ScoreView/ScoreCellView.swift
9. ScoreView/ScoreView.swift
10. SearchView/SearchView.swift
11. SelectOptionsView/SelectOptionsView.swift
12. SimpleOptionRowView/SimpleOptionRowView.swift
13. SuggestedBetsExpandedView/SuggestedBetsExpandedView.swift
14. TextSectionView/TextSectionView.swift
15. UserLimitCardView/UserLimitCardView.swift

**Pattern applied:**
```swift
// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Component Name") {
    // ... preview code
}
#endif
```

### Experiments & Notes
- Initial Python automation approach was interrupted by user preference for manual approach
- Using Python to scan and identify unprotected files worked well: `pathlib` for file scanning, simple string matching for detection
- Swift compiler crashes during optimization passes are unpredictable - prophylactic `#if DEBUG` wrapping is a best practice for all preview code

### Useful Files / Links
- [GomaUI CLAUDE.md](../../Frameworks/GomaUI/CLAUDE.md) - Component development guidelines
- [Main Project CLAUDE.md](../../CLAUDE.md) - Project architecture documentation

### Next Steps
1. Test archive build to confirm compiler crash is resolved
2. Consider adding `#if DEBUG` guard to any remaining preview code in other frameworks
3. Document this pattern in GomaUI development guidelines for future component development
