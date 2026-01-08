## Date
08 January 2026

### Project / Branch
BetssonFranceLegacy / feature/showcase-white-label

### Goals for this session
- Rename misleading "FeaturedTip" naming to "SuggestedBet" convention after Phase 1 cleanup
- Move Tips&Rankings slider files to Home/ folder
- Clean up empty folders after file moves

### Achievements
- [x] Renamed `FeaturedTipCollectionViewModel` → `SuggestedBetCardViewModel`
- [x] Renamed `FeaturedTipSelectionViewModel` → `SuggestedBetSelectionViewModel`
- [x] Renamed `FeaturedTipLineViewModel` → `SuggestedBetCarouselViewModel`
- [x] Renamed `FeaturedTipLineTableViewCell` → `SuggestedBetCarouselTableViewCell`
- [x] Renamed `FeaturedTipCollectionViewCell` → `SuggestedBetCardCollectionViewCell`
- [x] Renamed `FeaturedTipView` → `SuggestedBetSelectionView` (moved to Home/Views/)
- [x] Renamed `TipsSliderViewController` → `SuggestedBetSliderViewController` (moved to Home/SuggestedBetSlider/)
- [x] Renamed `TipsSliderViewModel` → `SuggestedBetSliderViewModel` (moved to Home/SuggestedBetSlider/)
- [x] Updated all external references in HomeViewController, HomeViewModel, TemplateDataSources
- [x] Renamed related properties and methods (e.g., `featuredTipLineViewModel()` → `suggestedBetCarouselViewModel()`)
- [x] Renamed callbacks (`openFeaturedTipDetailAction` → `openSuggestedBetDetailAction`)
- [x] Deleted empty `Core/Views/Tips/` folder
- [x] Deleted empty `Core/Screens/Tips&Rankings/` folder
- [x] Build verified successfully

### Issues / Bugs Hit
- None - clean rename operation

### Key Decisions
- Kept model layer names unchanged (`FeaturedTip`, `FeaturedTipSelection` structs) since they represent API contract
- Created new `Home/SuggestedBetSlider/` folder for relocated slider components
- Updated local variable names in TemplateDataSources for consistency

### Experiments & Notes
- The rename was comprehensive: 6 Swift files renamed, 8 files with external references updated
- Used `replace_all` extensively for consistent renaming across files
- SourceKit showed temporary errors during rename (expected when classes are mid-rename)

### Useful Files / Links
- [SuggestedBetCardViewModel](BetssonFranceLegacy/Core/Screens/Home/Views/ViewModels/SuggestedBetCardViewModel.swift)
- [SuggestedBetCarouselTableViewCell](BetssonFranceLegacy/Core/Screens/Home/Views/SuggestedBetCarouselTableViewCell.swift)
- [SuggestedBetSliderViewController](BetssonFranceLegacy/Core/Screens/Home/SuggestedBetSlider/SuggestedBetSliderViewController.swift)
- [HomeViewController](BetssonFranceLegacy/Core/Screens/Home/HomeViewController.swift)

### File Changes Summary

**Renamed Files:**
| Old Name | New Name | New Location |
|----------|----------|--------------|
| `FeaturedTipCollectionViewModel.swift` | `SuggestedBetCardViewModel.swift` | Home/Views/ViewModels/ |
| `FeaturedTipLineTableViewCell.swift` | `SuggestedBetCarouselTableViewCell.swift` | Home/Views/ |
| `FeaturedTipCollectionViewCell.swift` | `SuggestedBetCardCollectionViewCell.swift` | Home/Views/Cells/ |
| `FeaturedTipView.swift` | `SuggestedBetSelectionView.swift` | Home/Views/ (moved from Core/Views/Tips/) |
| `TipsSliderViewController.swift` | `SuggestedBetSliderViewController.swift` | Home/SuggestedBetSlider/ (moved) |
| `TipsSliderViewModel.swift` | `SuggestedBetSliderViewModel.swift` | Home/SuggestedBetSlider/ (moved) |

**Deleted Folders:**
- `Core/Views/Tips/`
- `Core/Screens/Tips&Rankings/`

### Next Steps
1. Update Xcode project file references (manual step for legacy project format)
2. Continue with any remaining France cleanup tasks
3. Consider similar naming cleanup in other areas if needed
