## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Break down the monolithic Events.swift file (1,169 lines) into organized, searchable individual files
- Create a logical directory structure for 42+ event-related models
- Maintain all functionality while improving discoverability

### Achievements
- [x] Analyzed Events.swift and identified all 42 types to be extracted
- [x] Created organized 9-category directory structure:
  - `Core/` - Main event models (Event, EventType, EventStatus, EventLiveData, etc.)
  - `Markets/` - Market-related models (Market, Outcome, MainMarket, HighlightMarket, etc.)
  - `Highlights/` - Generic highlight wrapper (ImageHighlightedContent)
  - `Sports/` - Sports hierarchy (Tournament, SportNodeInfo, SportRegion, SportCompetition, etc.)
  - `Favorites/` - Favorites functionality (7 models for lists, responses, events)
  - `Banners/` - Banner models (BannerResponse, EventBanner)
  - `Stats/` - Statistics models (Stats, ParticipantStats, Score)
  - `Widgets/` - Widget rendering (FieldWidget, FieldWidgetRenderData, etc.)
  - `Supporting/` - Utility models (ActivePlayerServe, HighlightedEventPointer)
- [x] Created 42 individual Swift files, one per model
- [x] Preserved all original functionality, imports, and protocols
- [x] Deleted original monolithic Events.swift file

### Issues / Bugs Hit
- None - clean extraction without compilation issues

### Key Decisions
- **Organized by domain responsibility** rather than alphabetically
  - Makes it intuitive to find related models
  - Core event models separated from market models, stats, widgets, etc.
- **One model per file** for maximum searchability
  - Easy to find with Xcode/grep: just search for the type name
  - Follows modern Swift package conventions
- **Preserved all imports and dependencies**
  - Each file imports only Foundation and required dependencies (SharedModels where needed)
  - Maintains exact same public API surface

### Experiments & Notes
- The original file had grown to 1,169 lines with 42 different types mixed together
- Separation revealed clear domain boundaries:
  - 7 Core event models
  - 7 Market models
  - 7 Sports hierarchy models
  - 7 Favorites models
  - Plus supporting categories for stats, widgets, banners, etc.
- This structure makes it trivial to:
  - Search by model name in IDE
  - Understand model relationships by folder structure
  - Maintain and extend individual models without scrolling through unrelated code

### Useful Files / Links
- [New Events Models Directory](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/)
- [Core Event Models](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Core/)
- [Market Models](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Events/Markets/)

### Next Steps
1. Verify the build compiles successfully across all schemes
2. Consider applying same organization pattern to other large model files in ServicesProvider
3. Update any documentation that references the old Events.swift file path
