## Date
02 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Investigate if MarketsTabSimpleViewController suffers from same async data issue as MarketGroupCardsViewController
- Convert MarketsTabSimpleViewController from UICollectionView to UITableView
- Apply TABLEVIEW_CELL_COMPONENT_PATTERN for proper synchronous data access
- Maintain exact visual fidelity with previous UICollectionView implementation

### Achievements
- [x] Analyzed MarketsTabSimpleViewController and confirmed it uses UICollectionView with diffable data source
- [x] Identified that UICollectionView with estimated heights doesn't suffer from same async issue as UITableView automatic dimensions
- [x] Created MarketTypeGroupTableViewCell wrapper following established pattern from MarketGroupCardsViewController
- [x] Converted MarketsTabSimpleViewController from UICollectionView to UITableView with traditional UITableViewDataSource
- [x] Added `currentMarketGroups` synchronous property to MarketsTabSimpleViewModel
- [x] Preserved all visual properties (16pt top/bottom spacing, cell spacing, 12pt corner radius)
- [x] Applied container view architecture for flexible cell adjustments
- [x] User fine-tuned visual properties (background colors, spacing, header height, font size)

### Issues / Bugs Hit
- [x] ViewModel lacked synchronous `currentMarketGroups` property → Added computed property returning `marketGroupsSubject.value`
- [x] Initial visual properties needed adjustment → User modified spacing, colors, and header height to match design

### Key Decisions
- **UITableView over UICollectionView**: Better automatic dimension calculation for TABLEVIEW_CELL_COMPONENT_PATTERN
- **Traditional DataSource over Diffable**: More control over cell sizing and direct data access from ViewModel
- **Container View Pattern**: Cell structure: UITableViewCell → contentView → containerView → header + marketOutcomesView
- **Synchronous Data Access**: Added `currentMarketGroups` to ViewModel following TABLEVIEW_CELL_COMPONENT_PATTERN
- **Section Headers/Footers**: 16pt header and footer for top/bottom spacing (matches UICollectionView contentInsets)
- **Cell Spacing**: 1pt bottom margin on containerView creates spacing between cells

### Experiments & Notes
- **Why UITableView**: Even though UICollectionView with estimated heights works, UITableView provides better automatic dimension calculation for complex nested views like MarketOutcomesMultiLineView
- **MarketOutcomesMultiLineView Already Fixed**: Component already has `configureImmediately()` and `.dropFirst()` from previous session
- **Eager View Creation**: MarketTypeGroupTableViewCell creates MarketOutcomesMultiLineView in init with loading state, then configures on reuse
- **Visual Property Mapping**:
  - UICollectionView `contentInsets.top: 16` → UITableView section header height: 16
  - UICollectionView `contentInsets.bottom: 16` → UITableView section footer height: 16
  - UICollectionView `interGroupSpacing: 12` → Container bottom margin: -1pt (adjusted by user)
  - Cell padding maintained: leading/trailing 16pt (user changed to 0pt for full width)

### Useful Files / Links
- [MarketsTabSimpleViewController](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewController.swift)
- [MarketTypeGroupTableViewCell](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketTypeGroupTableViewCell.swift)
- [MarketsTabSimpleViewModel](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewModel.swift)
- [MarketOutcomesMultiLineView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesMultiLineView/MarketOutcomesMultiLineView.swift)
- [TABLEVIEW_CELL_COMPONENT_PATTERN](../Patterns/TABLEVIEW_CELL_COMPONENT_PATTERN.md)
- [Previous Session - MarketGroupCardsViewController](./02-October-2025-uitableview-migration-and-tableview-pattern.md)

### Architecture Patterns Applied

#### TABLEVIEW_CELL_COMPONENT_PATTERN
**Problem**: UITableView automatic dimension requires synchronous data during cell configuration.

**Solution**: ViewModel provides both synchronous current values AND async publishers
```swift
// ViewModel
var currentMarketGroups: [MarketGroupWithIcons] {
    return marketGroupsSubject.value
}
var marketGroupsPublisher: AnyPublisher<[MarketGroupWithIcons], Never> { ... }

// View Controller
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.currentMarketGroups.count  // Synchronous access
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = viewModel.currentMarketGroups[indexPath.row]  // Synchronous access
    cell.configure(with: data)
    return cell
}
```

#### Cell Container Architecture
```
UITableViewCell
└── contentView (background primary)
    └── containerView (background tertiary, no corner radius per user preference)
        ├── headerView (title + icons, height: 26pt)
        └── marketOutcomesView (MarketOutcomesMultiLineView)
```

#### Traditional UITableViewDataSource Pattern
```swift
// Direct data access from ViewModel
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.currentMarketGroups.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let marketGroupWithIcons = viewModel.currentMarketGroups[indexPath.row]
    cell.configure(with: marketGroupWithIcons)
    // Setup callbacks...
    return cell
}

// Updates trigger reload
viewModel.marketGroupsPublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
        self?.tableView.reloadData()
    }
```

### Visual Property Comparison

| Property | UICollectionView | UITableView | User Adjusted |
|----------|------------------|-------------|---------------|
| Top spacing | contentInsets.top: 16 | Section header: 16pt | ✓ |
| Bottom spacing | contentInsets.bottom: 16 | Section footer: 16pt | ✓ |
| Cell spacing | interGroupSpacing: 12 | Container bottom: -1pt | ✓ User changed |
| Cell padding | leading: 16, trailing: -16 | leading: 0, trailing: 0 | ✓ User changed |
| Corner radius | 12pt | Removed per user | ✓ User removed |
| Header height | 24pt | 26pt | ✓ User adjusted |
| Font size | 14pt | 15pt | ✓ User adjusted |
| Background | backgroundSecondary | backgroundTertiary | ✓ User changed |

### Next Steps
1. Test the conversion in the app to verify visual fidelity
2. Monitor scroll performance with large datasets
3. Verify memory management during rapid scrolling
4. Consider applying same pattern to other collection view controllers if needed
5. Update UI_COMPONENT_GUIDE.md with UITableView conversion pattern if this becomes standard
