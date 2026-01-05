# ExtendedListFooterView

A comprehensive footer component with sponsors, navigation links, payment providers, social media, and legal information.

## Overview

ExtendedListFooterView displays a full-featured footer suitable for app list endings. It includes partnership sponsor logos, navigation links (Terms, Privacy, etc.), payment provider icons, social media links, responsible gambling warnings, copyright text, and license information. The component supports both CMS-driven content and fallback static content.

## Component Relationships

### Used By (Parents)
- None (standalone footer component)

### Uses (Children)
- `GradientView` - internal use for backgrounds
- Kingfisher - for remote image loading

## Features

- Partnership sponsor logos section (2-column grid, tappable)
- Navigation links section (Terms, Affiliates, Privacy, Cookie, etc.)
- Payment provider icons (MTN, Orange, etc.)
- Social media links section (4-column grid, CMS or static)
- Responsible gambling warning and advice text
- EGBA and eCOGRA certification badges
- Copyright text
- License header and body text
- Dark background (allDark)
- 48pt vertical padding, 16pt horizontal padding
- 32pt section spacing
- Dynamic content updates via callbacks
- Image loading with Kingfisher
- Tap gesture handling for sponsors and social links

## Usage

```swift
let viewModel = MockExtendedListFooterViewModel.cameroonFooter
let footerView = ExtendedListFooterView(viewModel: viewModel)

viewModel.onLinkTap = { linkType in
    switch linkType {
    case .termsAndConditions:
        print("Navigate to Terms")
    case .socialMedia(let platform):
        print("Open \(platform.displayName)")
    default:
        break
    }
}
```

## Data Model

```swift
protocol ExtendedListFooterViewModelProtocol {
    var paymentOperators: [PaymentOperator] { get }
    var socialMediaPlatforms: [SocialPlatform] { get }
    var socialLinks: [FooterSocialLink] { get }
    var partnerClubs: [PartnerClub] { get }
    var sponsors: [FooterSponsor] { get }
    var navigationLinks: [FooterLink] { get }
    var responsibleGamblingText: ResponsibleGamblingText { get }
    var copyrightText: String { get }
    var licenseHeaderText: String { get }
    var licenseBodyText: String { get }
    var partnershipHeaderText: String { get }
    var socialMediaHeaderText: String { get }
    var imageResolver: ExtendedListFooterImageResolver { get }

    var onLinkTap: ((FooterLinkType) -> Void)? { get set }
    var onSponsorsUpdated: (([FooterSponsor]) -> Void)? { get set }
    var onSocialLinksUpdated: (([FooterSocialLink]) -> Void)? { get set }
    var onNavigationLinksUpdated: (([FooterLink]) -> Void)? { get set }

    func handleSponsorTap(_ sponsor: FooterSponsor)
    func handleSocialLinkTap(_ link: FooterSocialLink)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.allDark` - background color
- `StyleProvider.Color.allWhite` - text and icon colors
- `StyleProvider.fontWith(type: .regular, size: 14)` - section headers
- `StyleProvider.fontWith(type: .regular, size: 16)` - body text, navigation links
- `StyleProvider.fontWith(type: .semibold, size: 16)` - license header

Layout constants:
- Container padding: 48pt vertical, 16pt horizontal
- Section spacing: 32pt
- Sub-section spacing: 16pt
- Partner logo size: 168x80pt
- Payment logo size: 64pt
- Social icon size: 64pt
- EGBA badge: 128x80pt
- eCOGRA badge: 168x80pt
- License max width: 672pt

## Mock ViewModels

Available presets:
- `.cameroonFooter` - full Cameroon footer with all content
- `.minimalFooter` - reduced content (fewer sponsors, fewer links)
- `.noLinksFooter` - footer without navigation links
- `.threePartnersFooter` - 3 sponsors (tests odd grid count)
- `.singlePartnerFooter` - 1 sponsor (tests single layout)
- `.fivePartnersFooter` - 5 sponsors (tests 3 rows: 2+2+1)
