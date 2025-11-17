# Development Journal

## Date
17 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Update support URLs to use localized Cameroon support pages
- Ensure both profile menu '?' button and footer help center link use language-specific URLs

### Achievements
- [x] Updated English localization to use `https://support.betsson.cm/en`
- [x] Updated French localization to use `https://support.betsson.cm/fr`
- [x] Modified TargetVariables.swift to dynamically use localized URLs instead of hardcoded values
- [x] Verified both profile menu and footer now use the same localized support URL pattern

### Issues / Bugs Hit
None encountered during this session.

### Key Decisions
- **Chose Option 1 (Localized Strings Approach)**: Instead of programmatically appending language codes, used the existing localization infrastructure to centrally manage language-specific URLs
  - More maintainable: All URLs live in `Localizable.strings` files
  - Consistent with existing architecture: Footer already used `localized("footer_help_center_link")`
  - Single source of truth: Both profile menu and footer reference the same localization key

### Experiments & Notes
- Identified two touch points for help center URLs:
  1. **Profile Menu '?' Button** → `ProfileWalletCoordinator.swift:204-224` → Uses `Env.linksProvider.links.getURL(for: .helpCenter)` → Pulls from `TargetVariables.swift`
  2. **Footer Help Center Link** → `FooterLinkType+URL.swift:38-39` → Uses `localized("footer_help_center_link")`
- Changed `TargetVariables.swift` from hardcoded `"https://support.betsson.com/"` to `localized("footer_help_center_link")`
- Also updated `customerSupport` URL to use the same localization key for consistency

### Useful Files / Links
- [English Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings:1227)
- [French Localizable.strings](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings:1227)
- [TargetVariables.swift](../../BetssonCameroonApp/App/SupportingFiles/TargetVariables.swift:98-102)
- [ProfileWalletCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift:204-224)
- [FooterLinkType+URL.swift](../../BetssonCameroonApp/App/Extensions/FooterLinkType+URL.swift:38-39)

### Next Steps
1. Test in simulator with both English and French language settings to verify correct URLs open
2. Verify URLEndpoint.Support structure is correctly resolving localized strings at runtime
3. Consider updating other support-related URLs (zendesk, customerSupport) if they need localization in the future
