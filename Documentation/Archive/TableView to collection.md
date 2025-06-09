# Migration Guide: UITableView to UICollectionView for Highlights

## Overview
This guide explains how to migrate from a complex `UITableView` implementation with multiple presentation modes to a more maintainable `UICollectionView` with compositional layouts.

## Current Implementation Issues
- Complex branching logic for different presentation modes
- Separate row count calculations for each mode
- Different view model creation paths
- Difficult to maintain and extend

## New Implementation Benefits
✅ Single data source for all layouts
✅ Eliminates presentation mode branching
✅ Easier to add new layout types
✅ Better performance with diffable data sources
✅ Smooth animated transitions between layouts

## Step 1: Data Model Changes

### Old Model
```swift
// Multiple separate arrays
private var highlightsVisualImageMatches: [Match]
private var highlightsBoostedMatches: [Match]
private var highlightedMarkets: [Market]
```

### New Model
```swift
// Unified section-based model
enum HighlightSection: Hashable {
    case visualImageMatches([Match])
    case boostedMatches([Match])
    case proChoiceMarkets([Market])
}

struct HighlightItem: Hashable {
    let id: String
    let content: AnyHashable // Match or Market
}
```

## Step 2: Layout Configuration

### Create Layout Options
```swift
enum HighlightsLayoutStyle {
    case groupedHorizontal  // Items in horizontal scroll views
    case verticalList       // Traditional table view style

    func createLayout() -> UICollectionViewLayout {
        // Implementation as shown earlier
    }
}
```

## Step 3: Data Source Setup

### Key Changes:
1. Replace `UITableViewDataSource` with `UICollectionViewDiffableDataSource`
2. Use cell registration instead of dequeuing
3. Unified supplementary view handling

```swift
class HighlightsDataSource {
    private var dataSource: UICollectionViewDiffableDataSource<HighlightSection, HighlightItem>!

    func configure(with collectionView: UICollectionView) {
        // 1. Cell registrations
        // 2. Header registration
        // 3. Data source initialization
    }

    func applySnapshot(sections: [HighlightSection]) {
        // Create and apply snapshot
    }
}
```

## Step 4: View Controller Changes

### Migration Steps:
1. Replace `UITableView` with `UICollectionView`
2. Initialize with compositional layout
3. Connect new data source
4. Add layout toggle capability

```swift
// Before:
let tableView = UITableView()
tableView.dataSource = self

// After:
let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: currentLayout.createLayout()
)
dataSource.configure(with: collectionView)
```

## Step 5: Cell Migration

### UITableViewCell → UICollectionViewListCell
```swift
// Before:
class MatchTableViewCell: UITableViewCell {
    func configure(with match: Match) { ... }
}

// After:
class MatchCollectionViewCell: UICollectionViewListCell {
    func configure(with match: Match) {
        var content = defaultContentConfiguration()
        content.text = match.name
        contentConfiguration = content
    }
}
```

## Step 6: Layout Switching

### Implementation:
```swift
func toggleLayout() {
    let newLayout: HighlightsLayoutStyle = currentLayout == .groupedHorizontal
        ? .verticalList
        : .groupedHorizontal

    collectionView.setCollectionViewLayout(
        newLayout.createLayout(),
        animated: true
    )
    currentLayout = newLayout
}
```

## Testing Checklist
1. Verify all data displays correctly in both layouts
2. Test layout transitions are smooth
3. Check cell selection behavior
4. Validate supplementary views (headers)
5. Test performance with large datasets

## Performance Considerations
- Use `UICellConfigurationState` for efficient updates
- Prefer estimated sizes for dynamic content
- Implement `shouldInvalidateLayout` for rotation support
- Consider prefetching for large datasets

## Common Pitfalls
⚠️ Forgetting to update diffable snapshots after data changes
⚠️ Not properly handling cell reuse in horizontal layout
⚠️ Missing hashable implementations for custom types
⚠️ Overlooking content inset adjustments between layouts

## Example Migration Timeline
1. Day 1: Setup new data model and data source
2. Day 2: Implement vertical list layout
3. Day 3: Add horizontal grouped layout
4. Day 4: Implement layout switching
5. Day 5: Testing and refinement