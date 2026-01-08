## Date
08 January 2026

### Project / Branch
sportsbook-ios / feature/showcase-white-label

### Goals for this session
- Continue Showcase white-label setup from previous session
- Archive deprecated clients from BetssonFranceLegacy
- Fix Showcase build errors
- Sync color assets between Betsson and Showcase

### Achievements
- [x] Archived 8 deprecated clients from BetssonFranceLegacy to new `ArchivedClients/` root folder
  - ATP, Crocobet, DAZN, EveryMatrix, GOMASportRadar, GOMASports, Showcase, SportRadar
  - Only Betsson (France) client remains in BetssonFranceLegacy/Clients/
- [x] Diagnosed and fixed Showcase build failure (122 duplicate symbol errors)
  - Root cause: All 4 Adjust SDK products linked simultaneously (AdjustSdk, AdjustUnsigned, AdjustWebBridge, AdjustGoogleOdm)
  - Fix: User removed duplicates in Xcode, keeping only AdjustSdk
- [x] Added 10 missing colors to Showcase Colors.xcassets:
  - backgroundHeader, backgroundOddsHeroCard, buttonTextDisableSecondary
  - highlightTertiary, iconSportsHeroCard, inputBorderDisabled
  - separatorLineHighlightPrimary, separatorLineHighlightSecondary
  - textHeroCard, textSecondaryHeroCard
- [x] Fixed color naming issues (removed " 1" suffix from separator colors)
- [x] Removed duplicate inputBorderDisable colorset
- [x] Created Gradients.xcassets for Showcase with 14 blue-themed gradients:
  - backgroundGradient1/2, backgroundHeaderGradient1/2
  - headerGradient1/2/3, cardBorderLineGradient1/2/3
  - liveBorderGradient1/2/3

### Issues / Bugs Hit
- [x] Adjust SDK duplicate symbols (122 errors) - caused by linking mutually exclusive SDK variants
- [x] Color naming mismatches between Showcase and Betsson (inputBorderDisable vs inputBorderDisabled)
- [x] Initially copied Betsson's orange gradients instead of creating blue-themed ones for Showcase

### Key Decisions
- **Archive location**: Created `ArchivedClients/` at repo root for deprecated client configurations
- **Adjust SDK**: Keep only `AdjustSdk` product, remove other variants (Unsigned, WebBridge, GoogleOdm)
- **Showcase blue theme**: Primary color #00A5DB with gradient palette:
  - Dark Navy: #003D5C
  - Medium Blue: #0077A3
  - Primary Blue: #00A5DB
  - Light Cyan: #33C4F2
  - Pale Cyan: #66D4F7

### Experiments & Notes
- Modern Xcode projects (PBXFileSystemSynchronizedRootGroup) auto-include all files in folders
- Adjust SDK products are mutually exclusive - linking multiple causes duplicate ObjC symbols
- Journal from previous session renamed folder from "Core" to "App" after documentation

### Useful Files / Links
- [Previous Session Journal](./08-January-2026-showcase-white-label-setup.md)
- [Showcase Colors.xcassets](../../Showcase/Clients/Showcase/Assets/Colors.xcassets/)
- [Showcase Gradients.xcassets](../../Showcase/Clients/Showcase/Assets/Gradients.xcassets/)
- [ArchivedClients/](../../ArchivedClients/)
- [BetssonFranceLegacy/Clients/Betsson/](../../BetssonFranceLegacy/Clients/Betsson/)

### Next Steps
1. Build and run Showcase scheme to verify all assets load correctly
2. Test both light and dark mode gradient rendering
3. Verify BetssonFranceLegacy still builds after client archival (targets may have broken references)
4. Update BetssonFranceLegacy Xcode project to remove archived client targets
5. Consider adding DAZN client back to Showcase/Clients if needed for demo
