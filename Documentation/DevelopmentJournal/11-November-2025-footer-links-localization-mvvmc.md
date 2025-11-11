# Footer Links Localization & MVVM-C Architecture Fix

## Date
11 November 2025

## Project / Branch
sportsbook-ios / betsson-cm

## Goals for this session
- Replace hardcoded footer link URLs with localized translation keys
- Fix MVVM-C architecture violations (footer links opening Safari directly from cells)
- Ensure footer links open in external Safari (not SFSafariViewController)
- Connect footer ViewModels to Coordinators for proper URL handling

## Achievements
- [x] Updated `FooterLinkType+URL.swift` to read URLs from `Localizable.strings` keys
- [x] Updated `SocialPlatform` extension to use localized social media URLs
- [x] Added URL/email opening methods to screen coordinators (NextUpEvents, InPlay, SportsSearch)
- [x] Wired `MarketGroupCardsViewModel` footer closures to view controllers
- [x] Connected view controllers to coordinators via MVVM-C closures
- [x] Removed duplicate URL handling methods from `AppCoordinator`
- [x] Verified all three screens (NextUpEvents, InPlay, SportsSearch) follow same pattern

## Issues / Bugs Hit
- Initial plan included adding methods to `AppCoordinator`, but this created duplication
- **Resolution**: Kept URL handling in child coordinators only (NextUpEvents, InPlay, SportsSearch) per Option 2

## Key Decisions
- **Localization strategy**: All footer URLs stored in `Localizable.strings` (not CMS)
  - Translation keys: `footer_tc_link`, `footer_affiliates_link`, `footer_privacy_policy_link`, etc.
  - Email: `footer_betsson_mail`
  - Social media: `footer_twitter_link`, `footer_facebook_link`, etc.
- **URL opening behavior**: Use `UIApplication.shared.open()` to open in **external Safari**, not `SFSafariViewController`
- **Architecture pattern**: Follow existing MVVM-C - child coordinators handle URL opening, not AppCoordinator
- **Duplication handling**: Kept URL opening methods in 3 child coordinators (simpler than protocol extension)

## Architecture Flow
```
User taps footer link
  ↓
ExtendedListFooterView (GomaUI component)
  ↓
ExtendedListFooterViewModel.onLinkTap()
  ↓
FooterLinkType+URL extension (reads localized("footer_*_link"))
  ↓
MarketGroupCardsViewModel.onURLOpenRequested/onEmailComposeRequested
  ↓
ViewController (NextUpEvents/InPlay/SportsSearch).openURL/openEmailCompose
  ↓
Coordinator (NextUpEvents/InPlay/SportsSearch).openExternalURL/openEmailClient
  ↓
UIApplication.shared.open() - Opens in external Safari/Mail app
```

## Files Modified

### Core Changes
1. **BetssonCameroonApp/App/Extensions/FooterLinkType+URL.swift**
   - Replaced all hardcoded URLs with `localized()` calls
   - `.termsAndConditions` → `localized("footer_tc_link")`
   - `.contactUs` → `localized("footer_betsson_mail")` (email)
   - Social platforms: `localized("footer_twitter_link")`, etc.

### Coordinators Updated
2. **BetssonCameroonApp/App/Coordinators/SportsSearchCoordinator.swift**
   - Added `openExternalURL(_:)` method (lines 42-51)
   - Added `openEmailClient(email:)` method (lines 54-68)
   - Wired closures to `SportsSearchViewController` (lines 80-86)

3. **BetssonCameroonApp/App/Coordinators/AppCoordinator.swift**
   - **Removed** duplicate URL/email methods (unnecessary in root coordinator)

### ViewControllers Updated
4. **BetssonCameroonApp/App/Screens/SportsSearch/SportsSearchViewController.swift**
   - Added `onURLOpenRequested` and `onEmailRequested` closures (lines 20-21)
   - Added `openURL(_:)` and `openEmailCompose(email:)` delegation methods (lines 577-584)
   - Wired `MarketGroupCardsViewModel` closures in `updateMarketGroupControllers()` (lines 434-440)

### Existing Architecture (Verified Working)
- **NextUpEventsCoordinator** - Already had URL/email methods (lines 64-93)
- **InPlayEventsCoordinator** - Already had URL/email methods (lines 59-88)
- **NextUpEventsViewController** - Already wired footer closures (lines 373-379)
- **InPlayEventsViewController** - Already wired footer closures (lines 346-351)
- **MarketGroupCardsViewModel** - Already had closure forwarding (lines 75-81)

## Translation Keys Used

### Footer Links
| Link Type            | Translation Key                  | Example URL                                            |
|----------------------|----------------------------------|--------------------------------------------------------|
| Terms & Conditions   | `footer_tc_link`                 | https://www.betsson.com/en/terms-and-conditions        |
| Affiliates           | `footer_affiliates_link`         | https://www.betssongroupaffiliates.com/                |
| Privacy Policy       | `footer_privacy_policy_link`     | https://www.betsson.com/en/privacy-policy              |
| Cookie Policy        | `footer_cookie_policy_link`      | https://www.betsson.com/en/cookie-policy               |
| Responsible Gambling | `footer_responsible_gambling_link` | https://www.betsson.com/en/responsible-gaming/information |
| Game Rules           | `footer_game_rules_link`         | https://www.betsson.com/en/game-rules                  |
| Help Center          | `footer_help_center_link`        | https://support.betsson.com/                           |
| Contact Us           | `footer_betsson_mail`            | support-en@betsson.com                                 |

### Social Media Links
| Platform  | Translation Key       | Example URL                   |
|-----------|-----------------------|-------------------------------|
| Twitter/X | `footer_twitter_link` | https://twitter.com/betsson   |
| Facebook  | `footer_facebook_link` | https://facebook.com/betsson  |
| Instagram | `footer_instagram_link` | https://instagram.com/betsson |
| YouTube   | `footer_youtube_link` | https://youtube.com/betsson   |

## Useful Files / Links
- [FooterLinkType+URL Extension](BetssonCameroonApp/App/Extensions/FooterLinkType+URL.swift)
- [NextUpEventsCoordinator](BetssonCameroonApp/App/Coordinators/NextUpEventsCoordinator.swift)
- [InPlayEventsCoordinator](BetssonCameroonApp/App/Coordinators/InPlayEventsCoordinator.swift)
- [SportsSearchCoordinator](BetssonCameroonApp/App/Coordinators/SportsSearchCoordinator.swift)
- [MarketGroupCardsViewModel](BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift)
- [ExtendedListFooterViewModel](BetssonCameroonApp/App/ViewModels/ExtendedListFooterViewModel.swift)
- [GomaUI ExtendedListFooterView](Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/)
- [EN Localizable.strings](BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings)
- [FR Localizable.strings](BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings)

## Next Steps
1. Test footer links on physical device to verify external Safari opens correctly
2. Verify all URLs are correct in both EN and FR localization files
3. Test email link opens default mail client (or prompts to set one)
4. Consider extracting URL/email opening methods to base Coordinator protocol extension if more screens need it
5. Update Phrase translation platform if any URLs need to change per market
