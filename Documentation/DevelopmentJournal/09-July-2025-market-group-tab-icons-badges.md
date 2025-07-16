## Date
09 July 2025

### Project / Branch
sportsbook-ios / GomaUI MarketGroupSelectorTab Enhancement

### Goals for this session
- Enhance MarketGroupSelectorTab component with icon and badge support
- Implement ImageResolver pattern for clean MVVM separation
- Add dark theme support for match event screens
- Update preview configurations to use PreviewUIViewController

### Achievements
- [x] Added MarketGroupTabImageResolver protocol with DefaultMarketGroupTabImageResolver
- [x] Extended MarketGroupTabItemData to support iconType and badgeCount properties
- [x] Updated MarketGroupTabItemView with horizontal UIStackView layout (title + icon + badge)
- [x] Implemented circular orange badges with white count text (16x16 size)
- [x] Added icon support (18x18 size) with proper ImageResolver integration
- [x] Created MarketGroupSelectorBackgroundStyle enum for light/dark themes
- [x] Added dark theme support (#03061b background from Figma)
- [x] Updated all MockMarketGroupTabItemViewModel factory methods
- [x] Created AppMarketGroupTabImageResolver in Core/Services/ImageResolvers/
- [x] Converted all previews to use PreviewUIViewController for better rendering
- [x] Added comprehensive preview configurations including icon/badge combinations
- [x] Removed icon tint color logic to preserve original icon colors

### Issues / Bugs Hit
- [x] Initially used UIColor(hex:) instead of UIColor(hexString:) for dark background
- [x] Preview configurations using PreviewUIView didn't render intrinsic content size properly

### Key Decisions
- **ImageResolver Pattern**: Followed established pattern from MatchHeaderView refactor for clean MVVM separation
- **Stack View Layout**: Used horizontal UIStackView with title, icon, badge for flexible arrangement
- **Badge Design**: Circular orange badges matching Figma design (#FF6600 background, white text)
- **Icon Colors**: Removed tinting to preserve original icon colors per user request
- **Dark Theme**: Added dedicated background style enum instead of modifying existing API
- **Preview System**: Switched to PreviewUIViewController for better component testing

### Experiments & Notes
- Tested icon tinting with highlightPrimary/textPrimary colors but removed for better visual consistency
- Explored using system icons as fallbacks in DefaultMarketGroupTabImageResolver
- Badge sizing: 16x16 minimum with dynamic width for larger numbers (3px padding)
- Dark theme hex color: #03061b matches Figma design exactly

### Useful Files / Links
- [MarketGroupTabItemView](GomaUI/GomaUI/Sources/GomaUI/Components/MarketGroupTabItemView/MarketGroupTabItemView.swift)
- [MarketGroupSelectorTabView](GomaUI/GomaUI/Sources/GomaUI/Components/MarketGroupSelectorTabView/MarketGroupSelectorTabView.swift)
- [AppMarketGroupTabImageResolver](Core/Services/ImageResolvers/AppMarketGroupTabImageResolver.swift)
- [MatchHeaderImageResolver Pattern](Documentation/DevelopmentJournal/28-June-2025-matchheader-imageresolver-refactor.md)
- [Figma Market Category Tabs](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=7171-7044&m=dev)
- [PreviewUIViewController Helper](GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIViewController.swift)

### Next Steps
1. Test implementation in DemoGomaUI app to verify icon/badge rendering
2. Consider adding custom icon assets for production use (currently using system icons)
3. Integrate enhanced component into match event detail screens
4. Update any existing usage of MarketGroupSelectorTab to leverage new features