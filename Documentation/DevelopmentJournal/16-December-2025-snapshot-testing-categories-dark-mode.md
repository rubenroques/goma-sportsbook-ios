## Date
16 December 2025

### Project / Branch
sportsbook-ios / rr/cashout_fixes

### Goals for this session
- Launch sub-agents to create snapshot tests for ButtonView, CapsuleView, BetDetailRowView, CashoutAmountView, BetSummaryRowView
- Fix ButtonView not rendering in snapshots
- Split ButtonView tests into categories for better organization
- Add light/dark mode testing support
- Create snapshot testing documentation

### Achievements
- [x] Fixed ButtonView rendering by adding `currentButtonData` to protocol (synchronous state access pattern)
- [x] Updated all `ButtonViewModelProtocol` implementations:
  - `MockButtonViewModel` (GomaUI)
  - `ButtonViewModel` (BetssonCameroonApp)
  - `PlaceBetButtonViewModel` (BetssonCameroonApp)
- [x] Added `configureImmediately()` pattern to `ButtonView.swift` with `.dropFirst()` in bindings
- [x] Created `ButtonSnapshotCategory` enum with 6 categories (basicStyles, disabledStates, commonActions, customColors, themeVariants, fontCustomization)
- [x] Refactored `ButtonViewSnapshotViewController` to accept category parameter
- [x] Split tests into 12 functions (6 categories × 2 themes: Light/Dark)
- [x] Added `lightTraits` and `darkTraits` to `SnapshotTestConfig`
- [x] Changed `backgroundTestColor` from red-tinted to neutral gray (#E0E0E0 light / #1C1C1C dark)
- [x] Created `SNAPSHOT_TESTING_GUIDE.md` documentation

### Issues / Bugs Hit
- [x] Sub-agents got stuck trying to run xcodebuild - killed 7 agents
- [x] ButtonView components not rendering (blank) - fixed with synchronous rendering pattern
- [x] Light gray background too light (#F5F5F5) - changed to #E0E0E0

### Key Decisions
- Sub-agents should NOT run builds - only create files and stop
- Components with many variants (10+) should use category enum pattern
- All snapshot tests must include both `_Light` and `_Dark` variants
- Use `.dropFirst()` in bindings to avoid double-render after `configureImmediately()`

### Useful Files / Links
- [ButtonViewSnapshotViewController](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ButtonView/ButtonViewSnapshotViewController.swift)
- [ButtonViewSnapshotTests](../../Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/ButtonView/ButtonViewSnapshotTests.swift)
- [SnapshotTestConfig](../../Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift)
- [ButtonViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ButtonView/ButtonViewModelProtocol.swift)
- [UIColor+PreviewBackground](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/UIColor+PreviewBackground.swift)
- [SNAPSHOT_TESTING_GUIDE](../../Frameworks/GomaUI/GomaUI/Documentation/SNAPSHOT_TESTING_GUIDE.md)
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)

### Next Steps
1. Run tests to generate reference images for ButtonView (12 images)
2. Update other snapshot tests (CapsuleView, etc.) to use light/dark pattern
3. Update gomaui-snapshot-test skill with new patterns (categories, light/dark)
4. Consider refactoring other components to support `currentDisplayState`
