## Date
27 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Migrate CasinoCategoryGamesListViewController to use CasinoGameImageView (simple square cards) instead of CasinoGameCardView (tall cards with metadata)
- Implement 3-column fixed grid layout with 100x100 square cards
- Fix triple navigation bug when tapping category "All" button

### Achievements
- [x] Created `CasinoGameImageCollectionViewCell` wrapper in GomaUI for standalone grid usage
- [x] Updated `CasinoCategoryGamesListViewController` to use new cell type with 3-column layout
- [x] Updated `CasinoCategoryGamesListViewModel` to use `CasinoGameImageViewModel` instead of `MockCasinoGameCardViewModel`
- [x] Made `CasinoGameImageView.Constants.cardSize` public static (100pt) as single source of truth
- [x] Updated `CasinoGameImagePairView` to reference `CasinoGameImageView.Constants.cardSize` instead of own constant
- [x] Updated `CasinoGameImageGridSectionView` to reference shared card size constant
- [x] Fixed triple navigation bug - removed redundant callback in ViewController (ViewModel already wires callbacks)
- [x] Fixed pair view height collapse issue - use `alpha = 0` instead of `isHidden = true` for empty bottom slot

### Issues / Bugs Hit
- [x] Triple navigation when tapping "All" button - three callback paths were triggering: ViewController callback, ViewModel callback, and CasinoCategoryBarViewModel callback. Fixed by removing redundant ViewController callback.
- [x] Pair view collapsing to 100pt when bottom game is nil - UIStackView collapses hidden views. Fixed by using alpha=0 instead of isHidden=true to maintain layout.
- [x] Size mismatch between components - `CasinoGameImagePairView` had cardSize=164, `CasinoGameImageGridSectionView` had cardSize=100. Fixed by centralizing to `CasinoGameImageView.Constants.cardSize`.

### Key Decisions
- **Fixed 100x100 card size**: CasinoGameImageView always renders at 100x100, no flexible sizing. Simplifies layout and ensures consistency across all usages.
- **Single source of truth**: `CasinoGameImageView.Constants.cardSize` is public static and all parent views reference it for sizing calculations.
- **Alpha vs Hidden**: Use `alpha = 0` for empty bottom card slot to maintain stack view height while hiding content.
- **Callback ownership**: ViewModel layer owns navigation callbacks, not ViewController. Removed redundant callback setup in `CasinoCategoriesListViewController.configureCategoryCell()`.

### Experiments & Notes
- The original plan was adaptive 3/2-column layout based on screen width, but user preferred fixed 100x100 cards everywhere
- Triple navigation bug was caused by:
  1. `CasinoCategoriesListViewController` setting `cell.onCategoryButtonTapped`
  2. `CasinoCategoriesListViewModel` setting `sectionViewModel.onCategoryButtonTapped`
  3. `CasinoGameImageGridSectionView` calling both `onCategoryButtonTapped` AND `viewModel?.categoryButtonTapped()`

### Useful Files / Links
- [CasinoGameImageView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameImageView/CasinoGameImageView.swift)
- [CasinoGameImageCollectionViewCell](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameImageView/CasinoGameImageCollectionViewCell.swift)
- [CasinoGameImagePairView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameImagePairView/CasinoGameImagePairView.swift)
- [CasinoGameImageGridSectionView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameImageGridSectionView/CasinoGameImageGridSectionView.swift)
- [CasinoCategoryGamesListViewController](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewController.swift)
- [CasinoCategoryGamesListViewModel](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewModel.swift)
- [CasinoCategoriesListViewController](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewController.swift)
- [Previous Session: Grid Components](./27-November-2025-casino-grid-integration-betsson-cameroon.md)

### Next Steps
1. Build and verify all changes compile
2. Test CasinoCategoriesListViewController horizontal grid displays correctly
3. Test CasinoCategoryGamesListViewController 3-column grid with 100x100 cards
4. Verify single navigation when tapping "All" button
5. Test odd game count scenarios (e.g., Greyhound Racing with 1 game)
