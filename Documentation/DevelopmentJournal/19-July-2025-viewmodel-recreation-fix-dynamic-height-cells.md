## Date
19 July 2025

### Project / Branch
sportsbook-ios / main (no specific branch - direct fixes)

### Goals for this session
- Fix ViewModel recreation issue in MatchDetailsTextualViewModel where MarketGroupSelectorTabViewModel was being recreated instead of updated
- Resolve dynamic height collection view cell rendering issues in MarketsTabSimpleViewController
- Implement proper data flow without unnecessary object recreation

### Achievements
- [x] Fixed ViewModel recreation by adding `updateMatch()` method to MatchDetailsMarketGroupSelectorTabViewModel
- [x] Refactored MatchDetailsTextualViewModel to use `updateMatch()` instead of recreating view model instance
- [x] Consolidated loading coordination bindings into single `setupBindings()` method
- [x] Fixed dynamic height collection view cells by restructuring MarketTypeGroupCollectionViewCell
- [x] Implemented static view structure with dynamic content updates using `MarketOutcomesMultiLineView.configure()`
- [x] Added proper constraint chain establishment during cell initialization
- [x] Enhanced collection view layout invalidation for better height recalculation

### Issues / Bugs Hit
- [x] ViewModel recreation causing state loss and unnecessary subscription re-setup
- [x] Dynamic height collection view cells rendering with collapsed heights initially, requiring scroll to fix
- [ ] Minor visual "flash" still occurs when cells transition from loading state to correct height

### Key Decisions
- **Avoided protocol pollution**: Kept `updateMatch()` method app-specific in concrete implementation rather than adding to GomaUI protocol
- **Followed tutorial pattern**: Restructured cell to match working dynamic height tutorial - static view structure with dynamic content
- **Used existing infrastructure**: Leveraged `MarketOutcomesMultiLineView.configure()` and `MockMarketOutcomesMultiLineViewModel.loadingMarketGroup`
- **Maintained architectural boundaries**: GomaUI components remain model-agnostic while app layer handles business logic updates

### Experiments & Notes
- Discovered that `MarketOutcomesMultiLineView` already had perfect `configure(with:)` method for view reuse
- Root cause of height issues was incomplete constraint chain during initial cell sizing
- Collection view was calculating size before dynamic content was added, falling back to estimated height
- Tutorial comparison revealed the importance of establishing complete constraint chains during initialization

### Useful Files / Links
- [MarketDetailsTextualViewModel.swift](../Core/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Main view model with recreation fix
- [MatchDetailsMarketGroupSelectorTabViewModel.swift](../Core/Screens/MatchDetailsTextual/MatchDetailsMarketGroupSelectorTabViewModel.swift) - Added updateMatch() method
- [MarketTypeGroupCollectionViewCell.swift](../Core/Screens/MatchDetailsTextual/MarketsTab/MarketTypeGroupCollectionViewCell.swift) - Restructured for proper dynamic height
- [MarketsTabSimpleViewController.swift](../Core/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewController.swift) - Enhanced layout invalidation
- [MarketOutcomesMultiLineView.swift](../GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesMultiLineView/MarketOutcomesMultiLineView.swift) - Line 64: configure() method
- [MockMarketOutcomesMultiLineViewModel.swift](../GomaUI/GomaUI/Sources/GomaUI/Components/MarketOutcomesMultiLineView/MockMarketOutcomesMultiLineViewModel.swift) - Line 447: loadingMarketGroup

### Next Steps
1. **Eliminate visual flash**: Implement `preferredLayoutAttributesFitting` override to force synchronous layout calculation
2. **Test with various data sizes**: Verify behavior with different market group configurations (2-outcome vs 3-outcome)
3. **Performance validation**: Monitor scrolling performance with the new layout invalidation calls
4. **Code cleanup**: Remove any unused view management code that's no longer needed after restructuring
5. **Documentation**: Update component documentation to reflect the proper usage patterns discovered