## Date
16 December 2025

### Project / Branch
GomaUI / main

### Goals for this session
- Add swift-snapshot-testing library to GomaUI Swift Package
- Create snapshot test infrastructure with standardized patterns
- Test multiple component states in a single snapshot

### Achievements
- [x] Added `swift-snapshot-testing` (v1.18.0+) to GomaUI Package.swift
- [x] Created `SnapshotTestConfig.swift` with centralized settings (device, size, record flag)
- [x] Established snapshot VC pattern: title label, vertical stack with labeled variants, `.backgroundTestColor`
- [x] Created snapshot tests for 3 components:
  - `PillItemView` - 4 states (selected, unselected, text only, long text)
  - `InlineScoreView` - 5 states (tennis, football, football tied, basketball, empty)
  - `OutcomeItemView` - 9 states (normal, selected, boosted, odds up/down, loading, locked, unavailable)
- [x] Identified async Combine rendering issue - components using `.receive(on: DispatchQueue.main)` need RunLoop workaround
- [x] Documented workaround with comments referencing proper pattern (`currentDisplayState`)

### Issues / Bugs Hit
- [x] Snapshot VCs in test target can't use SwiftUI previews - moved to Sources
- [x] Components relying solely on async Combine bindings render empty in snapshots - added RunLoop delay workaround
- [x] Loading/Locked/Unavailable OutcomeItemView states had collapsed height - fixed with explicit height constraint

### Key Decisions
- Snapshot VCs live in **Sources** (inside component folder) not Tests - enables previews and proper resource access
- Each component has its own `{ComponentName}SnapshotViewController.swift` - no shared generic wrapper
- Pattern documented but not enforced via shared class - flexibility for different component needs
- `SnapshotTestConfig.record` flag controls all tests - single source of truth for recording mode
- Fixed size (414x736, iPhone 8) for consistent snapshots across runs

### Experiments & Notes
- `assertSnapshot(of:as:.image(layout:))` is for SwiftUI, use `.image(on:size:)` for UIViewController
- Components with `currentDisplayState` + synchronous initial render work without RunLoop hack
- Components like `InlineScoreView`, `CompactOutcomesLineView` follow proper pattern
- Components like `PillItemView`, `OutcomeItemView` need refactoring to add synchronous state

### Useful Files / Links
- [SnapshotTestConfig](../../Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift)
- [PillItemViewSnapshotViewController](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/PillItemView/PillItemViewSnapshotViewController.swift)
- [InlineScoreViewSnapshotViewController](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/InlineScoreView/InlineScoreViewSnapshotViewController.swift)
- [OutcomeItemViewSnapshotViewController](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/OutcomeItemViewSnapshotViewController.swift)
- [swift-snapshot-testing GitHub](https://github.com/pointfreeco/swift-snapshot-testing)
- [UIColor.backgroundTestColor](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/UIColor+PreviewBackground.swift)

### Next Steps
1. Run all snapshot tests and commit reference images to git
2. Refactor `PillItemView` to add `currentDisplayState` and remove RunLoop workaround
3. Add snapshot tests for more components (ButtonView, MarketOutcomesLineView, CompactMatchHeaderView)
4. Consider CI integration - standardize simulator for consistent snapshots
