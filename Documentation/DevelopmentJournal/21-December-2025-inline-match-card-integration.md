# Development Journal

## Date
21 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Create production ViewModels for InlineMatchCardView (already exists in GomaUI)
- Integrate inline match cards into BetssonCameroonApp
- Replace TallOddsMatchCardTableViewCell with InlineMatchCardTableViewCell in NextUpEvents

### Achievements
- [x] Created `InlineScoreViewModel.swift` - horizontal score display with sport-specific logic (Tennis sets, Football, Basketball quarters)
- [x] Created `CompactMatchHeaderViewModel.swift` - simplified header with date/LIVE badge + market count
- [x] Created `CompactOutcomesLineViewModel.swift` - single line of 2-3 outcomes with real-time odds updates
- [x] Created `InlineMatchCardViewModel.swift` - main composite ViewModel with live data + betslip integration
- [x] Added `InlineMatchCardData` struct and `inlineMatchCardsData` publisher to `MarketGroupCardsViewModel`
- [x] Replaced TallOddsMatchCard with InlineMatchCard in `MarketGroupCardsViewController`

### Issues / Bugs Hit
- None - clean implementation following existing patterns

### Key Decisions
- **Reused existing patterns**: All new ViewModels follow the same architecture as TallOddsMatchCardViewModel (CurrentValueSubject, factory methods, ServicesProvider subscriptions)
- **Single market per card**: InlineMatchCard displays only the first relevant market (compact design), vs TallOdds which shows multiple
- **Horizontal score layout**: InlineScoreView uses horizontal columns vs vertical ScoreView for compact display
- **GomaUI cell already exists**: `InlineMatchCardTableViewCell` was already in GomaUI, no new cell needed in app

### Experiments & Notes
- InlineMatchCardView components were created in November 2025 (see DJ from 25-November-2025)
- The transformation logic for scores is nearly identical between ScoreViewModel and InlineScoreViewModel, just outputs different data types
- CompactOutcomesLineViewModel is simpler than MarketOutcomesLineViewModel as it only handles a single market line

### Useful Files / Links

**New Production ViewModels:**
- [InlineScoreViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/InlineScoreViewModel.swift)
- [CompactMatchHeaderViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/CompactMatchHeaderViewModel.swift)
- [CompactOutcomesLineViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/CompactOutcomesLineViewModel.swift)
- [InlineMatchCardViewModel](../../BetssonCameroonApp/App/ViewModels/InlineMatchCard/InlineMatchCardViewModel.swift)

**Modified Files:**
- [MarketGroupCardsViewModel](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift) - Added InlineMatchCardData + factory methods
- [MarketGroupCardsViewController](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift) - Switched to InlineMatchCardTableViewCell

**GomaUI Components (reference):**
- [InlineMatchCardView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/InlineMatchCardView/)
- [InlineMatchCardTableViewCell](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/InlineMatchCardView/InlineMatchCardTableViewCell.swift)
- [CompactMatchHeaderView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactMatchHeaderView/)
- [CompactOutcomesLineView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CompactOutcomesLineView/)
- [InlineScoreView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/InlineScoreView/)

**Reference DJ:**
- [25-November-2025-inline-match-card-components.md](./25-November-2025-inline-match-card-components.md)

### Next Steps
1. Test inline cards with live matches to verify score updates
2. Test betslip integration (outcome selection/deselection)
3. Consider adding navigation callback for `onMoreMarketsTapped` (currently just logs)
4. Evaluate if icons (Express Pick, BetBuilder) should be added to CompactMatchHeaderViewModel
