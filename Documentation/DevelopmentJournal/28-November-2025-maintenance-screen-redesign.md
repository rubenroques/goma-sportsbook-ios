## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / rr/bugfix/match_detail_blinks

### Goals for this session
- Update maintenance mode screen to match new Figma design
- Convert XIB-based screen to programmatic ViewCode
- Add SwiftUI previews for easier development iteration

### Achievements
- [x] Reviewed Figma design via MCP tools (node 16552:17167)
- [x] Converted MaintenanceViewController from XIB to programmatic ViewCode
- [x] Added proper `init()` to prevent XIB lookup after deletion
- [x] Deleted unused MaintenanceViewController.xib
- [x] Added localization keys for new copy (`maintenance_title`, `maintenance_subtitle`) in EN/FR
- [x] Added SwiftUI previews with Light/Dark mode variants
- [x] Updated colors to use `UIColor.App` theme variables

### Issues / Bugs Hit
- [ ] SwiftUI previews initially not working in BetssonCameroonApp (scheme/target issue)
- [x] Fixed by removing `import GomaUI` - using local `PreviewUIViewController` instead
- [x] Xcode needed restart to recognize previews properly

### Key Decisions
- Kept screen simple without ViewModel (static content, no user interaction)
- Used local `PreviewUIViewController` from `App/Tools/PreviewsHelper/` instead of GomaUI's version
- Both `textPrimary` used for title and subtitle (per user adjustment)

### Design Implementation
From Figma design:
- **Logo**: `betsson_logo_orange` at top (height: 20pt)
- **Illustration**: `maintenance_mode` asset (traffic cone with sports elements)
- **Title**: "Hang on, we are under maintenance" (bold, 20pt)
- **Subtitle**: "Sorry for the inconvenience, we will be right back. Thank you for your patience!" (regular, 14pt)
- **Colors**: `backgroundPrimary` for background, `textPrimary` for both labels

### Useful Files / Links
- [MaintenanceViewController.swift](../../BetssonCameroonApp/App/Screens/Maintenance/MaintenanceViewController.swift)
- [MaintenanceCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/MaintenanceCoordinator.swift)
- [PreviewUIViewController.swift](../../BetssonCameroonApp/App/Tools/PreviewsHelper/PreviewUIViewController.swift)
- [Figma Design](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=16552-17167)

### Next Steps
1. Add `maintenance_mode` image asset to asset catalog (user will do manually)
2. Test maintenance mode trigger in app to verify full flow
3. Investigate why SwiftUI previews don't work project-wide in BetssonCameroonApp (separate task)
