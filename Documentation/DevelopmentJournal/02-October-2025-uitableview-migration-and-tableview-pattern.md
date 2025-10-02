## Date
02 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Convert MarketGroupCardsViewController from UICollectionView to UITableView
- Fix cell sizing issues with UITableView automatic dimensions
- Apply TABLEVIEW_CELL_COMPONENT_PATTERN to TallOddsMatchCardView and nested components
- Add placeholder market line for empty states

### Achievements
- [x] Created UITableViewCell wrappers for all three cell types (TallOddsMatchCardTableViewCell, SeeMoreButtonTableViewCell, FooterTableViewCell)
- [x] Converted MarketGroupCardsViewController from UICollectionView to UITableView with traditional UITableViewDataSource
- [x] Preserved all visual properties (1.5pt spacing, 8pt insets, 12pt corner radius logic)
- [x] Maintained scroll synchronization and delegate functionality
- [x] Applied TABLEVIEW_CELL_COMPONENT_PATTERN to TallOddsMatchCardView
- [x] Applied TABLEVIEW_CELL_COMPONENT_PATTERN to MarketOutcomesMultiLineView
- [x] Added `.dropFirst()` to all publishers to prevent duplicate configuration
- [x] Implemented placeholder market line with `.single` display mode for empty states
- [x] Created container view architecture for flexible cell adjustments

### Issues / Bugs Hit
- [x] UICollectionView diffable data source causing cell overlap and wrong sizing → Fixed by converting to traditional UITableViewDataSource
- [x] MarketOutcomesMultiLineView appearing empty on first display → Fixed by adding synchronous `currentDisplayState` property and `configureImmediately()` method
- [x] Duplicate configuration when subscribing to publishers → Fixed by adding `.dropFirst()` to skip initial emission
- [x] Empty market cards showing nothing → Fixed by adding placeholder line with "-" button
- [x] Exhaustive switch errors after adding `.single` display mode → Fixed by updating all switch statements

### Key Decisions
- **UITableView over UICollectionView**: Provides better automatic dimension calculation and simpler implementation for vertical list
- **Traditional DataSource over Diffable**: More control over cell sizing and configuration flow
- **Container View Pattern**: Cell structure: UITableViewCell → contentView → containerView (with rounded corners) → TallOddsMatchCardView
- **TABLEVIEW_CELL_COMPONENT_PATTERN**: All GomaUI components now provide synchronous `current*` properties alongside async publishers for proper UITableView sizing
- **`.dropFirst()` Pattern**: Skip first publisher emission since we already configured with current values immediately
- **Placeholder Line for Empty States**: Display single disabled "-" button when no markets available to maintain visual consistency

### Experiments & Notes
- **TallOddsMatchCardView nil viewModel support**: View can now init with nil viewModel, essential for eager cell creation
- **Eager vs Lazy View Creation**: Cell now creates TallOddsMatchCardView immediately in init (with nil viewModel), then configures on reuse
- **Synchronous vs Async Configuration**:
  - `configureImmediately()` uses current values (synchronous) for UITableView sizing
  - `setupBindings()` subscribes to publishers with `.dropFirst()` for updates only
- **Container View Constraints**: Leading: 13pt, Trailing: -13pt, Bottom: -1pt spacing matches UICollectionView spacing exactly

### Useful Files / Links
- [MarketGroupCardsViewController](../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift)
- [TallOddsMatchCardView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardView.swift)
- [TallOddsMatchCardViewModelProtocol](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TallOddsMatchCardView/TallOddsMatchCardViewModelProtocol.swift)
- [MarketOutcomesMultiLineView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesMultiLineView/MarketOutcomesMultiLineView.swift)
- [TABLEVIEW_CELL_COMPONENT_PATTERN](../Documentation/Patterns/TABLEVIEW_CELL_COMPONENT_PATTERN.md)
- [TallOddsMatchCardTableViewCell](../BetssonCameroonApp/App/Screens/NextUpEvents/TallOddsMatchCardTableViewCell.swift)

### Architecture Patterns Applied

#### TABLEVIEW_CELL_COMPONENT_PATTERN
**Problem**: UITableView automatic dimension requires synchronous data during cell configuration. Components using only Combine publishers with `DispatchQueue.main` create race conditions where cells are empty during height calculation.

**Solution**: Protocol provides both synchronous current values AND async publishers
```swift
// Protocol
var currentDisplayState: TallOddsMatchCardDisplayState { get }  // Synchronous
var displayStatePublisher: AnyPublisher<...> { get }           // Async updates

// View
private func configureImmediately(with viewModel: ViewModelProtocol) {
    render(state: viewModel.currentDisplayState)  // Immediate
}

private func setupBindings() {
    viewModel.displayStatePublisher
        .dropFirst()  // Skip initial emission (already configured)
        .receive(on: DispatchQueue.main)
        .sink { ... }
}
```

#### Cell Container Architecture
```
UITableViewCell
└── contentView (clear background)
    └── containerView (background color, rounded corners, leading: 13, trailing: -13, bottom: -1)
        └── TallOddsMatchCardView (vertical: 9, horizontal: 16 spacing)
```

#### Placeholder Market Line Pattern
When `MarketOutcomesMultiLineView` has no markets:
- Creates `MockMarketOutcomesLineViewModel` with `.single` display mode
- Single disabled outcome showing "-" value
- Maintains visual consistency with normal market cards
- Non-interactive (disabled state)

### Next Steps
1. Test scroll performance with large datasets
2. Verify memory management during rapid scrolling
3. Consider extracting container view pattern to reusable component
4. Document `.dropFirst()` pattern in TABLEVIEW_CELL_COMPONENT_PATTERN.md
5. Add placeholder pattern to UI_COMPONENT_GUIDE.md
