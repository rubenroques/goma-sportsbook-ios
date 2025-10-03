## Date
02 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Research how BetssonFrance PreLive screen achieves sticky footer behavior
- Convert MarketGroupCardsViewController from UICollectionView to UITableView
- Implement sticky footer using BetssonFrance's `greaterThanOrEqualTo` constraint pattern
- Ensure footer sticks to bottom when content is short, scrolls normally when content is long
- Apply solution to both NextUp and InPlay screens

### Achievements
- [x] Launched sub-agent to investigate BetssonFrance sticky footer implementation
- [x] Discovered the magic `greaterThanOrEqualTo` constraint pattern
- [x] User converted MarketGroupCardsViewController from UICollectionView to UITableView
- [x] Removed footer from table sections (moved to `tableFooterView`)
- [x] Added `footerInnerView` property with Auto Layout constraints
- [x] Implemented `setupStickyFooter()` method with magic constraint
- [x] Added `viewDidLayoutSubviews()` for dynamic height synchronization
- [x] Cleaned up all footer-related table delegate methods
- [x] Verified solution applies to both NextUp and InPlay screens automatically

### Issues / Bugs Hit
- **Initial confusion about architecture**: Proposed external footer view outside collection view
  - **User clarification**: "wait, footerContainerView, is that how Betsson France Prelive screen does this? is not a cell inside the table view?"
  - **Resolution**: Sub-agent investigation revealed BetssonFrance uses `tableFooterView` (built-in UITableView property)
- **UICollectionView limitation**: Collection views don't have `collectionFooterView` equivalent
  - **Resolution**: User converted entire controller to UITableView to enable exact BetssonFrance pattern

### Key Decisions
- **Use exact BetssonFrance pattern**: Instead of approximating with external views, match the proven implementation
  - UITableView's `tableFooterView` property (frame-based container)
  - Auto Layout `footerInnerView` inside with `greaterThanOrEqualTo` constraint
  - Dynamic height sync in `viewDidLayoutSubviews()`
- **Convert to UITableView**: Collection view couldn't support the constraint pattern
  - UICollectionView: No `tableFooterView` equivalent
  - UITableView: Perfect match for BetssonFrance architecture
- **Remove footer from sections**: Footer moved from Section 2 to `tableFooterView`
  - Cleaner architecture
  - Enables stretching behavior via constraints
- **Single source of truth**: `footerInnerView` manages all footer layout
  - `tableFooterView` is just a frame-based container
  - All constraints live on `footerInnerView`
  - `viewDidLayoutSubviews()` syncs heights

### Architecture Notes

#### BetssonFrance Sticky Footer Pattern (Discovered)

**File**: `BetssonFranceApp/Core/Screens/PreLiveEvents/PreLiveEventsViewController.swift:333-358`

**Pattern Components**:
```swift
// 1. Create frame-based container
let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
tableView.tableFooterView = tableFooterView

// 2. Add Auto Layout inner view
let footerInnerView = UIView()
footerInnerView.translatesAutoresizingMaskIntoConstraints = false
tableFooterView.addSubview(footerInnerView)

// 3. THE MAGIC CONSTRAINT
footerInnerView.bottomAnchor.constraint(
    greaterThanOrEqualTo: tableView.superview!.bottomAnchor
)

// 4. Sync heights in viewDidLayoutSubviews
if footerView.frame.size.height != footerInnerView.frame.size.height {
    footerView.frame.size.height = footerInnerView.frame.size.height
    tableView.tableFooterView = footerView  // Trigger update
}
```

#### The Magic Constraint Explained

```swift
footerInnerView.bottomAnchor.constraint(
    greaterThanOrEqualTo: tableView.superview!.bottomAnchor
)
```

**How it works**:
- **Short content**: Constraint activates, stretches `footerInnerView` vertically to reach screen bottom
- **Long content**: Constraint satisfied naturally, footer scrolls with table content
- **Result**: Footer appears "pinned" to bottom when needed, scrolls normally otherwise

#### Visual Behavior

**Short Content (2-3 matches)**:
```
┌──────────────────┐
│ Header           │
├──────────────────┤
│ Match 1          │
│ Match 2          │
│ Load More        │
│                  │ ← footerInnerView stretches
│                  │ ← to fill vertical space
│                  │
├──────────────────┤
│ Footer (80pt)    │ ← Sticks to bottom!
└──────────────────┘
```

**Long Content (20+ matches)**:
```
┌──────────────────┐
│ Header           │
├──────────────────┤
│ Match 1          │
│ Match 2          │
│ ...              │ ← Scrollable
│ Match 20         │
│ Load More        │
├──────────────────┤
│ Footer (80pt)    │ ← Scrolls with content
└──────────────────┘
```

#### Hierarchy

```
UITableView
├── Section 0: matchCards (dynamic rows)
├── Section 1: loadMoreButton (0 or 1 row)
└── tableFooterView (UIView - frame: CGRect(0,0,300,80))
    └── footerInnerView (UIView - Auto Layout)
        ├── Constraints:
        │   ├── edges → tableFooterView edges
        │   └── bottom >= tableView.superview.bottom ← MAGIC!
        └── FooterTableViewCell.contentView (80pt height)
```

### Implementation Details

#### setupStickyFooter() Method (lines 107-143)

```swift
private func setupStickyFooter() {
    // Configure inner view for Auto Layout
    footerInnerView.translatesAutoresizingMaskIntoConstraints = false
    footerInnerView.backgroundColor = .clear

    // Create frame-based container (required by UITableView API)
    let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
    tableFooterView.backgroundColor = .clear

    // Set as table footer
    tableView.tableFooterView = tableFooterView
    tableFooterView.addSubview(footerInnerView)

    // Create footer content
    let footerCell = FooterTableViewCell()
    footerCell.translatesAutoresizingMaskIntoConstraints = false
    footerInnerView.addSubview(footerCell.contentView)

    NSLayoutConstraint.activate([
        // Pin to tableFooterView edges
        footerInnerView.rightAnchor.constraint(equalTo: tableFooterView.rightAnchor),
        footerInnerView.leftAnchor.constraint(equalTo: tableFooterView.leftAnchor),
        footerInnerView.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor),

        // THE MAGIC CONSTRAINT: Stick to bottom when content is short
        footerInnerView.bottomAnchor.constraint(
            greaterThanOrEqualTo: tableView.superview!.bottomAnchor
        ),

        // Footer content (80pt fixed height)
        footerCell.contentView.leadingAnchor.constraint(equalTo: footerInnerView.leadingAnchor),
        footerCell.contentView.trailingAnchor.constraint(equalTo: footerInnerView.trailingAnchor),
        footerCell.contentView.topAnchor.constraint(equalTo: footerInnerView.topAnchor),
        footerCell.contentView.bottomAnchor.constraint(equalTo: footerInnerView.bottomAnchor),
        footerCell.contentView.heightAnchor.constraint(equalToConstant: 80)
    ])
}
```

#### viewDidLayoutSubviews() (lines 67-79)

```swift
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Sync frame-based tableFooterView height with Auto Layout footerInnerView
    if let footerView = tableView.tableFooterView {
        let size = footerInnerView.frame.size
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            tableView.tableFooterView = footerView  // Reassign triggers update
        }
    }
}
```

**Why needed**: `tableFooterView` uses frame-based layout (UITableView API requirement), but `footerInnerView` uses Auto Layout. When `footerInnerView` stretches due to `greaterThanOrEqualTo`, we must manually sync the container's frame height.

### Experiments & Notes

- **Sub-agent investigation**: Used general-purpose agent to analyze BetssonFrance codebase
  - Agent found exact file: `PreLiveEventsViewController.swift:333-358`
  - Provided code snippets and detailed explanation
  - Identified the `greaterThanOrEqualTo` constraint as the key pattern
- **UICollectionView limitation discovered**: No `collectionFooterView` property exists
  - Only sections and supplementary views (per-section headers/footers)
  - Cannot apply `greaterThanOrEqualTo: superview.bottom` to collection cells
- **Mixed layout approach**: Combining frame-based and Auto Layout requires manual sync
  - `tableFooterView` → frame-based (UITableView API)
  - `footerInnerView` → Auto Layout (for stretching behavior)
  - `viewDidLayoutSubviews()` bridges the two systems
- **Force unwrap acceptable**: `tableView.superview!` is safe because constraint activated after view hierarchy setup
- **Clear backgrounds**: All container views use `.clear` to avoid visual artifacts from stretching

### Useful Files / Links

- [MarketGroupCardsViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift) - Lines 15 (footer property), 67-79 (viewDidLayoutSubviews), 107-143 (setupStickyFooter)
- [BetssonFrance PreLiveEventsViewController.swift](../../BetssonFranceApp/Core/Screens/PreLiveEvents/PreLiveEventsViewController.swift) - Lines 333-358 (original pattern), 202-219 (viewDidLayoutSubviews)
- [FooterTableViewCell.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/FooterTableViewCell.swift) - Footer content cell
- [FooterResponsibleGamingView.swift](../../BetssonFranceApp/Core/Views/FooterResponsibleGaming/FooterResponsibleGamingView.swift) - BetssonFrance footer component

### Previous Session Reference

- [01-October-2025-dynamic-pagination-response.md](./01-October-2025-dynamic-pagination-response.md) - Dynamic pagination implementation
- [01-October-2025-live-events-pagination-implementation.md](./01-October-2025-live-events-pagination-implementation.md) - LiveMatchesPaginator implementation

### Next Steps

1. **Test in simulator**: Verify sticky footer with different content amounts
   - Short content (1-3 matches) → footer sticks to bottom
   - Medium content (5-10 matches) → transition behavior
   - Long content (20+ matches) → footer scrolls normally
2. **Verify scroll sync still works**: ComplexScroll header animation with sticky footer
3. **Check pagination interaction**: Load More button behavior with sticky footer
4. **Test on different screen sizes**: iPhone SE vs iPhone Pro Max
5. **Consider footer content**: Replace "Footer" label with real content (legal, support, etc.)
6. **Performance testing**: Check if `viewDidLayoutSubviews()` causes layout thrashing
7. **Edge cases**:
   - 0 matches (empty state)
   - Exactly enough content to fill screen
   - Orientation changes
8. **Apply to InPlay**: Verify same behavior works for live matches screen
9. **Documentation**: Add comments explaining the magic constraint for future developers
10. **Consider making footer configurable**: Allow customization of footer content per screen

### Key Learnings

1. **UITableView vs UICollectionView capabilities**: UITableView's `tableFooterView` enables patterns impossible with UICollectionView
2. **greaterThanOrEqualTo is powerful**: Single constraint creates complex "stick to bottom OR scroll" behavior
3. **Frame-based + Auto Layout mixing**: Sometimes necessary, requires manual synchronization
4. **Sub-agent effectiveness**: General-purpose agent quickly found exact implementation in large codebase
5. **User knowledge sharing**: User already converted to UITableView before I could propose it - good architectural instinct
6. **BetssonFrance as reference**: Legacy project contains proven patterns worth studying and replicating
