# Development Journal Entry

## Date
07 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Reorganize partner logos in BetssonCameroonApp and GomaUI with language-specific naming
- Implement dynamic partner logo loading based on current app language (EN/FR)
- Fix profile menu to display correct current language

### Achievements
- [x] Renamed all partner logos in BetssonCameroonApp to include language suffixes (_en, _fr, _pt)
- [x] Created organized folder structure: EN/, FR/, PT/ subdirectories
- [x] Copied all renamed partner logos to GomaUI with organized Partners/EN/FR/PT structure
- [x] Updated AppExtendedListFooterImageResolver to dynamically load logos using `localized("current_language_code")`
- [x] Updated DefaultExtendedListFooterImageResolver to accept languageCode parameter
- [x] Fixed ProfileMenuListViewModel to display current language correctly
- [x] Added language display refresh on viewWillAppear to handle Settings returns

### Issues / Bugs Hit
- [x] GomaUI DefaultExtendedListFooterImageResolver didn't have access to localized() function
  - **Solution**: Added languageCode parameter to resolver initialization
- [x] Profile menu showed hardcoded "English" instead of actual current language
  - **Solution**: Used `localized("current_language_code")` in initialization and added refresh method

### Key Decisions
- **Language support**: Only implementing EN and FR for now (PT assets exist but not activated)
- **Image naming convention**: `{partner}_partner_footer_icon_{language_code}` (e.g., `inter_partner_footer_icon_en`)
- **Folder structure**: Separated by language in both BetssonCameroonApp and GomaUI for easy management
- **Language code mapping**: Created helper method to convert "en"→"English", "fr"→"Français"
- **Refresh strategy**: Update language display on viewWillAppear to catch Settings changes

### Implementation Details

#### Partner Logo Structure
```
BetssonCameroonApp/App/Resources/Assets/Media.xcassets/Footer/Partners/
├── EN/
│   ├── atletico_colombia_partner_footer_icon_en.imageset
│   ├── boca_partner_footer_icon_en.imageset
│   ├── inter_partner_footer_icon_en.imageset
│   └── racing_partner_footer_icon_en.imageset
├── FR/
│   ├── atletico_colombia_partner_footer_icon_fr.imageset
│   ├── boca_partner_footer_icon_fr.imageset
│   ├── inter_partner_footer_icon_fr.imageset
│   └── racing_partner_footer_icon_fr.imageset
└── PT/
    ├── atletico_colombia_partner_footer_icon_pt.imageset
    ├── boca_partner_footer_icon_pt.imageset
    ├── inter_partner_footer_icon_pt.imageset
    └── racing_partner_footer_icon_pt.imageset

GomaUI/Sources/GomaUI/Resources/Icons.xcassets/BetssonCameroonFooter/Partners/
├── EN/ (same structure as above)
├── FR/ (same structure as above)
└── PT/ (same structure as above)
```

#### Dynamic Logo Loading Pattern
```swift
// AppExtendedListFooterImageResolver.swift
private func partnerLogoImage(for club: PartnerClub) -> UIImage? {
    let languageCode = localized("current_language_code").lowercased()
    let imageName: String

    switch club {
    case .interMiami:
        imageName = "inter_partner_footer_icon_\(languageCode)"
    // ... other clubs
    }

    return UIImage(named: imageName) ?? fallbackPartnerLogo(for: club)
}
```

#### Language Display Refresh
```swift
// ProfileWalletViewModel.swift
func refreshLanguageDisplay() {
    let currentLanguageCode = localized("current_language_code")
    let displayName = ProfileMenuListViewModel.displayNameForLanguageCode(currentLanguageCode)
    profileMenuListViewModel.updateCurrentLanguage(displayName)
}

// ProfileWalletViewController.swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.refreshLanguageDisplay() // Refresh after Settings return
}
```

### Useful Files / Links
- [AppExtendedListFooterImageResolver.swift](../../BetssonCameroonApp/App/Services/ImageResolvers/AppExtendedListFooterImageResolver.swift)
- [DefaultExtendedListFooterImageResolver.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterImageResolver.swift)
- [ProfileMenuListViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileMenuListViewModel.swift)
- [ProfileWalletViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewModel.swift)
- [ProfileWalletViewController.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewController.swift)
- [Localization.swift](../../BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift)

### Next Steps
1. Test partner logos in both EN and FR languages to verify correct images load
2. Test profile menu language display updates when returning from iOS Settings
3. Consider implementing language selection within app instead of directing to Settings
4. Add PT (Portuguese) language support when ready to support that market
5. Update documentation to explain the localized assets pattern for future developers
