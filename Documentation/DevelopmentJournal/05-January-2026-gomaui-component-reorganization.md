## Date
05 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests

### Goals for this session
- Identify and organize GomaUI components belonging to "Promotions" feature
- Reorganize ~130 GomaUI components from flat structure into feature-based category folders
- Update ComponentCategory enum and ComponentRegistry to match new structure

### Achievements
- [x] Created 11 category folders for GomaUI components (MatchCards, Betting, Casino, Promotions, Wallet, Filters, Navigation, Forms, Profile, Status, UIElements)
- [x] Moved ~130 components using `git mv` to preserve history
- [x] Created comprehensive README files for each category folder
- [x] Restructured PromotionsContentBlocks → Promotions/ContentBlocks subfolder
- [x] Updated `ComponentCategory.swift` with new category names (`bettingSports` → `betting`, `matchDisplay` → `matchCards`)
- [x] Updated `ComponentRegistry.swift` with reorganized component arrays
- [x] Removed duplicate MatchBanner from promotionalComponents array
- [x] Verified GomaUICatalog build succeeds

### Issues / Bugs Hit
- None - smooth reorganization

### Key Decisions
- **StatisticsWidgetView → UIElements** (not MatchCards) - web-based widget is more generic
- **DepositBonusInfoView → Wallet** (not Promotions) - belongs with financial components
- **MatchBanner moved to MatchCards** - it's a match card sub-component, not a promotional component
- Split old `matchDisplay` and `bettingSports` categories into distinct `matchCards` and `betting` categories for clarity

### Experiments & Notes
- Swift Package Manager automatically detects files in subdirectories - no Package.swift changes needed
- Component ViewControllers import GomaUI, not direct file paths - catalog continues to work after moves
- Using `git mv` preserves file history through reorganization

### Useful Files / Links
- [ComponentCategory.swift](../../Frameworks/GomaUI/Catalog/Components/ComponentCategory.swift)
- [ComponentRegistry.swift](../../Frameworks/GomaUI/Catalog/Components/ComponentRegistry.swift)
- [MatchCards README](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchCards/README.md)
- [Betting README](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/README.md)
- [Casino README](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Casino/README.md)

### Component Distribution Summary
| Category | Count |
|----------|-------|
| MatchCards | 11 |
| Betting | 26 |
| Casino | 9 |
| Promotions | 10 + 12 ContentBlocks |
| Wallet | 9 |
| Filters | 14 |
| Navigation | 6 |
| Forms | 12 |
| Profile | 5 |
| Status | 9 |
| UIElements | 15 |

### Next Steps
1. Consider adding component count to each category's README
2. Update COMPONENT_MAP.json if needed for documentation
3. Review if any components should be moved between categories based on actual usage
