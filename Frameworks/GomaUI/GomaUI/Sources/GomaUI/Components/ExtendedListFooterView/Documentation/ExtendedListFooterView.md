# ExtendedListFooterView

A comprehensive footer component for displaying partnership information, legal links, payment providers, social media, responsible gambling messages, and licensing information at the bottom of event list screens.

## Overview

`ExtendedListFooterView` is designed to be displayed at the bottom of scrollable event lists (Pre-match/Next Up and Live/In-Play screens). It provides users with access to legal information, social media channels, payment partner logos, and responsible gambling resources.

## Features

- **Partnership Sponsorships**: Displays 4 sports team logos in a 2×2 grid
- **Navigation Links**: 8 pipe-separated links to legal/policy pages
- **Payment Providers**: Shows local payment partner logos (MTN, Orange)
- **Social Media**: Icons linking to X, Facebook, Instagram, YouTube
- **Responsible Gambling**: Warning messages with certification badges (EGBA, eCOGRA)
- **Copyright Information**: Displays copyright notice
- **License Details**: Full regulatory license text
- **Image Resolution Pattern**: Uses protocol-based image resolver for flexible asset management

## Usage

### Basic Implementation

```swift
import GomaUI

// 1. Create or provide an image resolver
let imageResolver = DefaultExtendedListFooterImageResolver()

// 2. Create a view model
let viewModel = MockExtendedListFooterViewModel(
    imageResolver: imageResolver
)

// 3. Create the footer view
let footerView = ExtendedListFooterView(viewModel: viewModel)

// 4. Set up link tap handling
viewModel.onLinkTap = { linkType in
    switch linkType {
    case .termsAndConditions:
        // Open terms URL
    case .socialMedia(let platform):
        // Open social media URL
    case .contactUs:
        // Open mail compose
    default:
        // Handle other link types
    }
}

// 5. Add to your view hierarchy
view.addSubview(footerView)
NSLayoutConstraint.activate([
    footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])
```

### Custom Image Resolver

```swift
// Create your own resolver for production assets
struct AppExtendedListFooterImageResolver: ExtendedListFooterImageResolver {
    func image(for imageType: FooterImageType) -> UIImage? {
        switch imageType {
        case .partnerLogo(let index):
            let logos = ["inter", "boca", "racing", "atletico"]
            return UIImage(named: logos[safe: index] ?? "")

        case .paymentProvider(let index):
            let providers = ["mtn", "orange"]
            return UIImage(named: providers[safe: index] ?? "")

        case .socialMedia(let platform):
            return UIImage(named: "social_\(platform.rawValue)")

        case .certification(let type):
            return UIImage(named: type.rawValue)
        }
    }
}
```

## Architecture

### Components

**ExtendedListFooterView.swift**
- Main UIView implementation with 8 vertical sections
- Uses UIStackView for section layout
- Handles link tap detection via UIGestureRecognizer
- Auto Layout-driven with intrinsic content size

**ExtendedListFooterViewModelProtocol.swift**
- Defines content properties (logo counts, links, text)
- Provides image resolver reference
- Includes link tap closure callback

**MockExtendedListFooterViewModel.swift**
- Production-ready mock with Cameroon-specific content
- Factory methods: `.cameroonFooter`, `.minimalFooter`, `.noLinksFooter`
- Uses `DefaultExtendedListFooterImageResolver` with SF Symbols

**ExtendedListFooterImageResolver.swift**
- Protocol for resolving footer images by type
- Default implementation using SF Symbols as placeholders
- Supports partner logos, payment providers, social icons, certifications

**ExtendedListFooterModels.swift**
- `FooterLinkType` enum: Defines all link types
- `SocialPlatform` enum: X, Facebook, Instagram, YouTube
- `FooterLink` struct: Link title + type
- `FooterImageType` enum: All image types with associated values
- `ResponsibleGamblingText` struct: Warning + advice text

### Section Breakdown

1. **Partnership Sponsorships** (Header + 2×2 logo grid)
2. **Navigation Links** (Pipe-separated links with tap detection)
3. **Payment Providers** (Horizontal logo row)
4. **Social Media** (Header + icon buttons)
5. **Responsible Gambling** (Warning + advice + 2 certification badges)
6. **Copyright** (Single line text)
7. **License** (Header + body text with max width constraint)

## Configuration

### ViewModel Properties

```swift
public protocol ExtendedListFooterViewModelProtocol {
    // Content
    var partnerLogosCount: Int { get }
    var paymentProvidersCount: Int { get }
    var socialMediaPlatforms: [SocialPlatform] { get }
    var navigationLinks: [FooterLink] { get }
    var responsibleGamblingText: ResponsibleGamblingText { get }
    var copyrightText: String { get }
    var licenseHeaderText: String { get }
    var licenseBodyText: String { get }
    var partnershipHeaderText: String { get }
    var socialMediaHeaderText: String { get }

    // Image resolution
    var imageResolver: ExtendedListFooterImageResolver { get }

    // Interaction
    var onLinkTap: ((FooterLinkType) -> Void)? { get set }
}
```

### Styling

All visual styling is controlled via `StyleProvider`:

- **Background**: `StyleProvider.Color.backgroundSecondary`
- **Primary text**: `StyleProvider.Color.textPrimary` (white)
- **Secondary text**: `StyleProvider.Color.textSecondary` (gray)
- **Link text**: `StyleProvider.Color.textPrimary` (white, no underline)

### Typography

- Section headers: `StyleProvider.fontWith(type: .regular, size: 14)`
- Navigation links: `StyleProvider.fontWith(type: .regular, size: 16)`
- Body text: `StyleProvider.fontWith(type: .regular, size: 16)`
- Copyright: `StyleProvider.fontWith(type: .regular, size: 14)`
- License header: `StyleProvider.fontWith(type: .semibold, size: 16)`
- License body: `StyleProvider.fontWith(type: .regular, size: 14)`

### Spacing

- Container padding: 48pt vertical, 16pt horizontal
- Section spacing: 32pt
- Sub-section spacing: 16pt
- Partner logo grid: 16pt horizontal/vertical gaps
- Social icons: 32pt spacing
- Payment providers: 24pt spacing

### Dimensions

- Partner logos: 168pt × 80pt
- Payment logos: 64pt × 64pt
- Social icons: 64pt × 64pt
- EGBA badge: 128pt × 80pt
- eCOGRA badge: 168pt × 80pt
- License max width: 672pt

## Link Handling

### FooterLinkType Enum

```swift
public enum FooterLinkType {
    case termsAndConditions
    case affiliates
    case privacyPolicy
    case cookiePolicy
    case responsibleGambling
    case gameRules
    case helpCenter
    case contactUs
    case socialMedia(SocialPlatform)
}
```

### Example Link Handler

```swift
viewModel.onLinkTap = { [weak self] linkType in
    guard let self = self else { return }

    switch linkType {
    case .termsAndConditions:
        self.openURL("https://www.betsson.com/en/terms-and-conditions")

    case .affiliates:
        self.openURL("https://www.betssongroupaffiliates.com/")

    case .privacyPolicy:
        self.openURL("https://www.betsson.com/en/privacy-policy")

    case .cookiePolicy:
        self.openURL("https://www.betsson.com/en/cookie-policy")

    case .responsibleGambling:
        self.openURL("https://www.betsson.com/en/responsible-gaming/information")

    case .gameRules:
        self.openURL("https://www.betsson.com/en/game-rules")

    case .helpCenter:
        self.openURL("https://support.betsson.com/")

    case .contactUs:
        self.openMailCompose(to: "support-en@betsson.com")

    case .socialMedia(let platform):
        let urls: [SocialPlatform: String] = [
            .x: "https://twitter.com/betsson",
            .facebook: "https://facebook.com/betsson",
            .instagram: "https://instagram.com/betsson",
            .youtube: "https://youtube.com/betsson"
        ]
        if let url = urls[platform] {
            self.openURL(url)
        }
    }
}
```

## Mock Presets

```swift
// Full Cameroon footer with all content
let cameroonFooter = MockExtendedListFooterViewModel.cameroonFooter

// Minimal footer for testing
let minimalFooter = MockExtendedListFooterViewModel.minimalFooter

// Footer without navigation links
let noLinksFooter = MockExtendedListFooterViewModel.noLinksFooter
```

## SwiftUI Previews

Three preview variations are included:

1. **Full Cameroon Footer**: Complete footer in scrollable container
2. **Minimal Footer**: Reduced content for testing
3. **No Links Footer**: Footer without navigation links section

Access previews in Xcode Canvas when viewing `ExtendedListFooterView.swift`.

## Integration Example: Table View Cell

```swift
// FooterTableViewCell.swift
final class FooterTableViewCell: UITableViewCell {
    private lazy var footerView: ExtendedListFooterView = {
        let resolver = AppExtendedListFooterImageResolver()
        let viewModel = MockExtendedListFooterViewModel(imageResolver: resolver)
        viewModel.onLinkTap = { [weak self] linkType in
            self?.handleLinkTap(linkType)
        }
        return ExtendedListFooterView(viewModel: viewModel)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    private func setupSubviews() {
        contentView.addSubview(footerView)

        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func handleLinkTap(_ linkType: FooterLinkType) {
        // Handle link navigation
    }
}
```

## Requirements

- iOS 13.0+
- Swift 5.0+
- GomaUI Framework

## Notes

- Component uses intrinsic content size based on content layout
- All images are resolved via the image resolver protocol
- Link tap detection uses `UIGestureRecognizer` with attributed string position calculation
- Component is fully self-contained and works with mock implementation
- No App Download or Back to Top sections (excluded per design requirements)

## Related Components

- `ActionButtonBlockView`: Simple button component pattern
- `MarketGroupTabItemView`: Component using image resolver pattern
- `CasinoCategorySectionView`: Composite component with multiple sections
