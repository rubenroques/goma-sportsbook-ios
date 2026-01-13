## Date
13 January 2026

### Project / Branch
sportsbook-ios / rr/gomaui_snapshot_test

### Goals for this session
- Audit COMPONENT_MAP.json for missing snapshot tests
- Analyze testability of components without snapshot coverage
- Document exclusion reasons for untestable components

### Achievements
- [x] Identified 4 components missing snapshot tests in COMPONENT_MAP.json
- [x] Analyzed each component's architecture for snapshot testability
- [x] Updated COMPONENT_MAP.json with `has_snapshot_tests: false` and `snapshot_excluded_reason` for all 4 components

### Issues / Bugs Hit
- None - analysis work only

### Key Decisions
- **ProgressSegments** excluded: Internal helper view (`final class`, not `public`), no ViewModel protocol pattern - not a standalone public component
- **StatisticsWidgetView** excluded: Uses `WKWebView` with async HTML loading, mock auto-loads with delays (0.1s-2.0s), non-deterministic rendering
- **VideoBlockView** excluded: Uses `AVPlayer`/`AVPlayerLayer` with remote URLs, async video dimension loading via `Task`/`await`
- **VideoSectionView** excluded: Same as VideoBlockView - `AVPlayer` with network-dependent video loading

### Experiments & Notes
- All 4 components require network access or have non-deterministic async rendering
- Would need significant refactoring to support static/placeholder modes for testing
- 134 of 138 components (97%) now have snapshot test coverage

### Useful Files / Links
- [COMPONENT_MAP.json](../../Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json)
- [StatisticsWidgetView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/UIElements/StatisticsWidgetView/)
- [VideoBlockView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Promotions/ContentBlocks/VideoBlockView/)
- [VideoSectionView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Promotions/ContentBlocks/VideoSectionView/)
- [ProgressSegmentView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Status/ProgressSegments/)

### Next Steps
1. Consider adding placeholder/static rendering mode for video components if snapshot coverage becomes critical
2. StatisticsWidgetView could potentially snapshot just the tab selector (MarketGroupSelectorTabView) which is already tested
3. Monitor if these 4 components cause visual regressions in production
