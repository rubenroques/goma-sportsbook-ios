## Date
15 October 2025

### Project / Branch
BetssonCameroonApp / rr/bettingOfferSubscription

### Goals for this session
- Research collapsible/expandable market groups feature in Match Details Textual
- Investigate git history to understand if feature existed in the past
- Compare BetssonFranceApp vs BetssonCameroonApp implementations

### Achievements
- [x] Deep research performed across both projects
- [x] Confirmed BetssonFranceApp has full two-level collapse system
- [x] Confirmed BetssonCameroonApp never had collapsible feature
- [x] Created TODO_TASKS.md for feature tracking
- [x] Added TODO_TASKS.md to .gitignore for personal tracking

### Issues / Bugs Hit
- None

### Key Decisions
- Decided to track missing features in TODO_TASKS.md (git-ignored)
- Keeping task list minimal and concrete (one line per task)

### Experiments & Notes

**Collapsible Feature Discovery:**

BetssonFranceApp has sophisticated two-level collapse system:

1. **Individual Market Group Expansion** (`seeAllOutcomes`)
   - Limits each market to 4 lines when collapsed
   - "See All" / "See Less" button per market group
   - Only shows for markets with >4 lines
   - State tracked in `Set<String>` (MarketGroupDetailsViewController.swift:22)

2. **Global Expand/Collapse All** (`isCollapsedMarketGroupIds`)
   - Master button in table header
   - Collapses entire sections (hides all outcomes)
   - Toggles between "Collapse All" / "Expand All"
   - State tracked in `Set<String>` (MarketGroupDetailsViewController.swift:23)

**Architecture differences:**
- **France**: XIB-based cells with expand UI outlets, tap gesture handlers, callbacks
- **Cameroon**: Clean GomaUI-based cells, no collapse state, always shows all outcomes

**Git history findings:**
- Commit `cd81cdf36`: Converted MatchDetails from UICollectionView to UITableView
- Even old CollectionViewCell version had NO collapse logic
- Feature was never implemented in BetssonCameroonApp

### Useful Files / Links

**BetssonFranceApp (Reference Implementation):**
- [MarketGroupDetailsViewController.swift](../../BetssonFranceApp/Core/Screens/MatchDetails/MarketGroupDetailsViewController.swift) - Lines 20-23, 72-88, 228-296
- [ThreeAwayMarketDetailTableViewCell.swift](../../BetssonFranceApp/Core/Screens/MatchDetails/Cells/ThreeAwayMarketDetailTableViewCell.swift) - Lines 25-30, 49-72, 86-90, 104-108, 199-289

**BetssonCameroonApp (Current Implementation):**
- [MarketsTabSimpleViewController.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewController.swift)
- [MarketTypeGroupTableViewCell.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketTypeGroupTableViewCell.swift)
- [MarketsTabSimpleViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewModel.swift)

**Task Tracking:**
- [TODO_TASKS.md](../../TODO_TASKS.md) - Personal git-ignored task list

### Next Steps
1. Implement collapsible market groups when prioritized
2. Follow modern MVVM-C pattern with publishers for state management
3. Create GomaUI components for expandable headers if needed
4. Use protocol-driven approach consistent with BetssonCameroonApp architecture
