## Date
14 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Merge `betsson-fr-releases` branch content into `main` branch
- Reorganize folder structure to match main's architecture
- Configure BetssonFranceLegacy to use shared Frameworks

### Achievements
- [x] Created backup branch `backup-main-before-france-merge` for safety
- [x] Used `git read-tree --prefix=BetssonFranceApp/` to import betsson-fr-releases content
- [x] Removed duplicate framework folders from BetssonFranceLegacy (they live in Frameworks/)
- [x] Renamed `BetssonFranceApp/` to `BetssonFranceLegacy/`
- [x] Renamed Xcode project from `Sportsbook2.xcodeproj` to `BetssonFranceLegacy.xcodeproj`
- [x] Updated `Sportsbook.xcworkspace` to point to new project location
- [x] Updated Sportsradar provider in `Frameworks/ServicesProvider/` with betsson-fr-releases version
- [x] Restored 4 main-only files in Sportsradar (SportRadarCustomerSupportProvider, SportRadarDownloadableContentsProvider, SportRadarManagedContentProvider, SportsMerger)
- [x] Fixed package paths in `project.pbxproj` to point to `../Frameworks/<PackageName>`

### Issues / Bugs Hit
- [ ] `git read-tree` failed initially due to untracked files in working directory - solved by cleaning first
- [ ] `git mv` failed for folder rename due to staged deletions - solved by using `mv` + `git add -A`
- [ ] User accidentally removed framework references in Xcode - reverted with `git restore`

### Key Decisions
- **Used `git read-tree` approach** instead of manual copy - preserves some git history connection
- **Keep 4 main-only Sportsradar files** - SportRadarCustomerSupportProvider, SportRadarDownloadableContentsProvider, SportRadarManagedContentProvider, SportsMerger were intentionally kept from main
- **Fix paths instead of converting to new Xcode style** - BetssonFranceLegacy uses old-style explicit file references, too risky to migrate to new folder-reference style
- **Package path format**: `../Frameworks/<PackageName>` relative to project location

### Experiments & Notes
- Learned about `git read-tree --prefix=` for subtree merges
- kdiff3 will be used for future 3-way merge of ServicesProvider/Client.swift
- BetssonCameroonApp uses new Xcode style (automatic file discovery), BetssonFranceLegacy uses old style (explicit PBXFileReference)

### Useful Files / Links
- [Workspace Config](../../Sportsbook.xcworkspace/contents.xcworkspacedata)
- [BetssonFranceLegacy project.pbxproj](../../BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj)
- [Sportsradar Provider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/)
- Backup branch: `backup-main-before-france-merge`
- Worktree location: `/Users/rroques/Desktop/GOMA/iOS/betssonfrance-git-worktree`

### Final Folder Structure
```
sportsbook-ios/
├── Sportsbook.xcworkspace      # Main entry point
├── BetssonCameroonApp/         # Modern iOS app
├── BetssonFranceLegacy/        # Legacy iOS app (from betsson-fr-releases)
│   ├── BetssonFranceLegacy.xcodeproj
│   ├── Core/
│   ├── Clients/
│   └── ...
├── Frameworks/                 # Shared Swift Packages
│   ├── ServicesProvider/       # Updated Sportsradar provider
│   ├── GomaUI/
│   ├── Extensions/
│   └── ...
└── ...
```

### Packages with Updated Paths
| Package | New Path |
|---------|----------|
| ServicesProvider | `../Frameworks/ServicesProvider` |
| Extensions | `../Frameworks/Extensions` |
| AdresseFrancaise | `../Frameworks/AdresseFrancaise` |
| CountrySelectionFeature | `../Frameworks/CountrySelectionFeature` |
| SharedModels | `../Frameworks/SharedModels` |
| Theming | `../Frameworks/Theming` |
| RegisterFlow | `../Frameworks/RegisterFlow` |
| HeaderTextField | `../Frameworks/HeaderTextField` |

### Next Steps
1. Test build of BetssonFranceLegacy in Xcode (manually by user)
2. Use kdiff3 to merge ServicesProvider/Client.swift between main and betsson-fr-releases
3. Commit all staged changes once build is verified
4. Consider cleaning up the git worktree after merge is complete
