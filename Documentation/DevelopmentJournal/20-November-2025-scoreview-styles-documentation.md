## Date
20 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Understand ScoreView component architecture and file structure
- Document the difference between ScoreCellStyle and HighlightingMode
- Create comprehensive examples showing all style/highlighting combinations
- Add detailed explanations for each variation

### Achievements
- [x] Read and analyzed all 6 ScoreView component files
- [x] Identified 3 GomaUI components using ScoreView as child views
- [x] Explained the orthogonal relationship between ScoreCellStyle and HighlightingMode
- [x] Created ScoreStylesViewController.swift with comprehensive examples
- [x] Added detailed SwiftUI preview to ScoreView.swift (373 lines)
- [x] Registered new component demo in ComponentRegistry.swift

### Issues / Bugs Hit
- [ ] None - session went smoothly

### Key Decisions

**ScoreCellStyle vs HighlightingMode - Two Independent Dimensions:**

1. **ScoreCellStyle (Container Appearance)**
   - Controls the visual container/background of the score cell
   - `.simple` - Plain text, 26pt wide, no border/background
   - `.border` - 1pt outline, 26pt wide, highlightPrimary color
   - `.background` - Filled background, 29pt wide, backgroundPrimary color

2. **HighlightingMode (Text Color Logic)**
   - Controls text colors based on score comparison
   - `.winnerLoser` - Winner: black (textPrimary), Loser: gray (textSecondary)
   - `.bothHighlight` - Both scores: orange (highlightPrimary)
   - `.noHighlight` - Both scores: black (textPrimary)

3. **Orthogonal Design**
   - These dimensions are completely independent
   - 3 styles × 3 highlighting modes = 9 possible combinations
   - Allows flexible score displays for different sports/contexts

**Real-World Usage Pattern (Tennis):**
```swift
// Current game: background container + both highlighted
ScoreDisplayData(
    id: "game",
    homeScore: "30",
    awayScore: "15",
    style: .background,           // Filled container
    highlightingMode: .bothHighlight  // Both orange
)

// Completed set: simple container + winner/loser highlighting
ScoreDisplayData(
    id: "set1",
    homeScore: "6",
    awayScore: "4",
    style: .simple,               // Plain container
    highlightingMode: .winnerLoser   // 6 black, 4 gray
)
```

### Experiments & Notes

**ScoreView Component Structure:**
- 6 files total in `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/`
  - ScoreView.swift (693 lines)
  - ScoreViewModelProtocol.swift (94 lines)
  - MockScoreViewModel.swift (316 lines)
  - ScoreCellView.swift (154 lines)
  - ServingIndicatorView.swift (70 lines)
  - Documentation/README.md (373 lines)

**Parent Components Using ScoreView:**
- MatchHeaderCompactView (compact match header with scores)
- TallOddsMatchCardView (full betting card with scores)
- MatchParticipantsInfoView (participants display with scores)

**Legacy ScoreView (Different Class):**
- BetssonFranceApp has OLD ScoreView class with different initialization
- Uses `ScoreView(sportCode:score:)` - not the GomaUI component
- Found in VerticalMatchInfoView and MatchDetailsViewController

### Useful Files / Links

**Created Files:**
- [ScoreStylesViewController.swift](../../Frameworks/GomaUI/Demo/Components/ScoreStylesViewController.swift)

**Modified Files:**
- [ScoreView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift) - Added comprehensive preview at line 693
- [ComponentRegistry.swift](../../Frameworks/GomaUI/Demo/Components/ComponentRegistry.swift) - Added registry entry

**ScoreView Component Files:**
- [ScoreView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreView.swift)
- [ScoreViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreViewModelProtocol.swift)
- [MockScoreViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/MockScoreViewModel.swift)
- [ScoreCellView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ScoreCellView.swift)
- [ServingIndicatorView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/ServingIndicatorView.swift)
- [README.md](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ScoreView/Documentation/README.md)

### Next Steps
1. Test SwiftUI preview renders correctly in Xcode (select "ScoreView - Comprehensive Style Guide")
2. Run GomaUIDemo app to verify ScoreStylesViewController displays properly
3. Build GomaUIDemo to ensure no compilation errors
4. Consider adding similar comprehensive style guides for other complex components (e.g., OutcomeItemView, MarketOutcomesLineView)
5. Update UI Component Guide documentation if needed
