# Extended List Footer Component - GomaUI Implementation

## Date
02 November 2025

## Project / Branch
sportsbook-ios / rr/live_scores

## Goals for this session
- Implement ExtendedListFooterView component in GomaUI
- Follow protocol-driven MVVM architecture with image resolver pattern
- Integrate footer in BetssonCameroonApp (NextUpEvents/InPlayEvents screens)
- Add component to GomaUIDemo app for testing
- Match Figma design specifications (colors, layout, spacing)

## Achievements
- [x] Created ExtendedListFooterView component in GomaUI with 8 sections:
  - Partnership Sponsorships (4 logos in 2×2 grid)
  - Navigation Links (8 pipe-separated links)
  - Payment Providers (MTN, Orange)
  - Social Media (X, Facebook, Instagram, YouTube)
  - Responsible Gambling (warning text + EGBA/eCOGRA badges)
  - Copyright ("© Betsson 2025")
  - License Information (Cameroon regulatory text)
- [x] Implemented protocol-based image resolver pattern (like MarketGroupTabImageResolver)
- [x] Created comprehensive data models with enums for type safety:
  - `PartnerClub` enum (.interMiami, .bocaJuniors, .racingClub, .atleticoNacional)
  - `PaymentOperator` enum (.mtn, .orange)
  - `SocialPlatform` enum (.x, .facebook, .instagram, .youtube)
  - `FooterLinkType` enum for all link types
- [x] Implemented closure-based callbacks with enum-based link types
- [x] Added SwiftUI previews with interactive tap handlers (console logging)
- [x] Integrated in BetssonCameroonApp's FooterTableViewCell
- [x] Created AppExtendedListFooterImageResolver with actual asset mappings
- [x] Added to GomaUIDemo component registry (UI Elements category)
- [x] Updated all colors to match Figma: `allDark` background, `allWhite` text
- [x] Refactored from index-based to enum-based approach for type safety

## Issues / Bugs Hit
- [x] Initial implementation used `textPrimary`/`textSecondary` colors instead of Figma's `allDark`/`allWhite`
- [x] First iteration used index-based approach for partners/operators (inconsistent with social/certification enums)
- [x] Figma MCP tools not accessible in plan mode (user manually exported assets)

## Key Decisions
- **No Combine publishers**: Content is static/hardcoded per market, doesn't update frequently
- **Enum-based image types**: Refactored from `index: Int` to enum cases for type safety and consistency
- **Image resolver pattern**: Protocol with enum → App implements custom resolver → GomaUI has SF Symbol fallbacks
- **Closure callbacks**: Used `onLinkTap: ((FooterLinkType) -> Void)?` instead of delegate pattern
- **No "App Download" or "Back to Top"**: Excluded sections 6 & 9 per iOS requirements
- **Dynamic height**: Removed fixed 80pt height constraint to allow Auto Layout-driven sizing
- **Asset naming convention**: `{name}_{category}_footer_icon` (e.g., `inter_partner_footer_icon`)

## Experiments & Notes
- Tested click handling in SwiftUI previews - works perfectly with console logging
- Verified sticky footer behavior in table view with dynamic content height
- Link tap detection uses `UIGestureRecognizer` with attributed string character index calculation
- SF Symbol fallbacks ensure graceful degradation if assets are missing

## Architecture Pattern

### Component Structure (GomaUI)
```
ExtendedListFooterView/
├── ExtendedListFooterView.swift              # Main UIView (8 sections)
├── ExtendedListFooterViewModelProtocol.swift # Protocol interface
├── MockExtendedListFooterViewModel.swift     # Mock with factory methods
├── ExtendedListFooterImageResolver.swift     # Image resolver protocol + default
├── ExtendedListFooterModels.swift            # Enums & data models
└── Documentation/
    └── ExtendedListFooterView.md             # Complete usage guide
```

### Enum-Based Type Safety
```swift
// Partner clubs (type-safe, no magic indices)
public enum PartnerClub: String, CaseIterable {
    case interMiami, bocaJuniors, racingClub, atleticoNacional
}

// Payment operators
public enum PaymentOperator: String, CaseIterable {
    case mtn, orange
}

// Image type with enums (consistent pattern)
public enum FooterImageType: Hashable {
    case partnerLogo(club: PartnerClub)
    case paymentProvider(operator: PaymentOperator)
    case socialMedia(platform: SocialPlatform)
    case certification(type: CertificationType)
}
```

### Image Resolution Flow
1. View calls `imageResolver.image(for: .partnerLogo(club: .interMiami))`
2. **GomaUI**: `DefaultExtendedListFooterImageResolver` returns SF Symbol placeholder
3. **BetssonCameroonApp**: `AppExtendedListFooterImageResolver` returns actual asset → fallback to SF Symbol

## Styling Specifications

### Colors (StyleProvider)
- Background: `StyleProvider.Color.allDark`
- All text: `StyleProvider.Color.allWhite`
- Links: `allWhite` (no underline, pipe separators)

### Typography
- Section headers: `fontWith(type: .regular, size: 14)`
- Links: `fontWith(type: .regular, size: 16)`
- Body text: `fontWith(type: .regular, size: 16)`
- Copyright: `fontWith(type: .regular, size: 14)`
- License header: `fontWith(type: .semibold, size: 16)`
- License body: `fontWith(type: .regular, size: 14)`

### Spacing
- Container padding: 48pt vertical, 16pt horizontal
- Section spacing: 32pt
- Sub-section spacing: 16pt
- Partner logos: 16pt grid gaps
- Social icons: 32pt spacing
- Payment providers: 24pt spacing

### Dimensions
- Partner logos: 168pt × 80pt
- Payment logos: 64pt × 64pt
- Social icons: 64pt × 64pt
- EGBA badge: 128pt × 80pt
- eCOGRA badge: 168pt × 80pt

## Asset Mapping (BetssonCameroonApp)

### Partner Logos
- Inter Miami → `inter_partner_footer_icon`
- Boca Juniors → `boca_partner_footer_icon`
- Racing Club → `racing_partner_footer_icon`
- Atlético Nacional → `atletico_colombia_partner_footer_icon`

### Payment Operators
- MTN → `mtn_operator_footer_icon`
- Orange → `orange_operator_footer_icon`

### Social Media
- X → `x_social_footer_icon`
- Facebook → `facebook_social_footer_icon`
- Instagram → `instagram_social_footer_icon`
- YouTube → `youtube_social_footer_icon`

### Regulators/Certifications
- EGBA → `egba_regulator_footer_icon`
- eCOGRA → `ecogra_regulator_footer_icon`

## Useful Files / Links

### GomaUI Component Files
- [ExtendedListFooterView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterView.swift)
- [ExtendedListFooterModels](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterModels.swift)
- [ExtendedListFooterImageResolver](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/ExtendedListFooterImageResolver.swift)
- [MockExtendedListFooterViewModel](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/MockExtendedListFooterViewModel.swift)
- [Component Documentation](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ExtendedListFooterView/Documentation/ExtendedListFooterView.md)

### BetssonCameroonApp Integration
- [FooterTableViewCell](../BetssonCameroonApp/App/Screens/NextUpEvents/FooterTableViewCell.swift)
- [MarketGroupCardsViewController](../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewController.swift)
- [AppExtendedListFooterImageResolver](../BetssonCameroonApp/App/Services/ImageResolvers/AppExtendedListFooterImageResolver.swift)

### GomaUIDemo Integration
- [ExtendedListFooterViewController](../Frameworks/GomaUI/Demo/ViewControllers/ExtendedListFooterViewController.swift)
- [ComponentRegistry](../Frameworks/GomaUI/Demo/Components/ComponentRegistry.swift)

### Reference Documentation
- [Web Implementation](../../CoreMasterAggregator/Documentation/Footer_Web_Implementation.md)
- [Android Implementation](../../CoreMasterAggregator/Documentation/Footer_Android_Implementation.md)
- [iOS Implementation Plan](../../CoreMasterAggregator/Documentation/Footer_iOS_Implementation_Plan.md)

### Figma Design
- [Footer Node 1](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=13326-9411&m=dev)
- [Footer Node 2](https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=13957-19514&m=dev)

## Next Steps
1. Test footer in live app build with real assets
2. Verify all link taps open correctly (Safari, Mail compose)
3. Test scrolling behavior with short vs. long event lists
4. Validate footer in both NextUpEvents and InPlayEvents screens
5. Consider adding footer to other list-based screens (Matches, Favorites)
6. Update other markets (BetssonFranceApp) to use the component when needed
7. Export actual Figma assets if Figma MCP becomes available

## Benefits of Enum-Based Refactor
- **Compile-time safety**: Typos caught immediately
- **Self-documenting code**: `.interMiami` is clearer than `index: 0`
- **Better refactoring**: Renaming enum case updates all usages
- **IDE autocomplete**: Suggests valid options
- **Exhaustive switching**: Compiler ensures all cases handled
- **Consistency**: All image types use same pattern (partner, operator, social, certification)
