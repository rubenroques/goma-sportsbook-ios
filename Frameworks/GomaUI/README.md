# GomaUI

GomaUI is a modular, reusable UI component library for iOS applications, built with a focus on consistency, testability, and customization.

## Overview

The GomaUI library follows the MVVM (Model-View-ViewModel) architectural pattern and leverages Swift Package Manager for distribution. Components are designed to be:

- **Reusable** - Can be used across multiple applications
- **Customizable** - Support theming and style customization
- **Testable** - Easy to test through protocol-based design
- **Well-documented** - Clear usage examples and documentation

## Design Rationale

GomaUI was developed to address specific architectural challenges in multi-client mobile application development:

### Challenges Addressed

- **Client Divergence**: Applications for different clients exhibit increasing customization requirements, making a unified codebase impractical due to divergent UI/UX specifications.

- **Codebase Maintainability**: Alternative approaches presented significant drawbacks:
  - Multiple discrete projects: Leading to code duplication and increased maintenance overhead
  - Single monolithic project: Resulting in excessive conditional logic, reduced readability, and complex navigation flows

### Technical Solution

GomaUI is one part of a modular architecture that works alongside an existing Service Provider Library:

1. **Service Provider Library**: A separate library within GOMA that abstracts data access and business logic through a protocol-based interface, enabling client-specific implementations.

2. **GomaUI (UI Component Library)**: Contains platform-agnostic UI widgets that can be shared across client applications while allowing for customization points.

This architecture enables client-specific features (such as specialized UI elements) to be implemented discretely without affecting the shared codebase.

### Implementation Strategy

- **Protocol-Driven Design**: ViewModels are defined through protocols, allowing client-specific implementations with varying logic while maintaining a consistent interface.

- **Service Provider Agnosticism**: UI components are designed to be independent of data sources, communicating exclusively through defined protocol interfaces.

- **Incremental Migration**: The technical roadmap involves gradually transitioning existing custom views into the GomaUI framework, enhancing maintainability while preserving application functionality.

## Available Components

GomaUI includes **138+ production-ready components** organized into categories:

| Category | Components | Description |
|----------|------------|-------------|
| **Betting** | OutcomeItemView, MarketOutcomesLineView, BetslipOddsBoostHeader | Odds, markets, betslip |
| **Match Cards** | TallOddsMatchCardView, InlineMatchCardView, MatchHeaderCompact | Match displays |
| **Casino** | CasinoGameCardView, CasinoCategoryBarView, RecentlyPlayedGamesView | Casino games |
| **Navigation** | AdaptiveTabBarView, QuickLinksTabBar, CustomNavigationView | Tab bars, headers |
| **Forms** | BorderedTextFieldView, PinDigitEntryView, CustomSliderView | Input fields |
| **Filters** | SportGamesFilterView, TimeSliderView, PillSelectorBarView | Selection controls |
| **Promotions** | TopBannerSliderView, PromotionCardView, BonusCardView | Banners, offers |
| **Wallet** | WalletWidgetView, TransactionItemView, AmountPillsView | Financial displays |
| **Profile** | ProfileMenuListView, ThemeSwitcherView, LanguageSelectorView | User settings |
| **Status** | ToasterView, EmptyStateActionView, FloatingOverlayView | Notifications, feedback |
| **UI Elements** | ButtonView, InfoRowView, ExpandableSectionView | Building blocks |

Run the **GomaUICatalog** app to explore all components interactively.

## Architecture

GomaUI uses a consistent architectural approach across all components:

### MVVM Pattern

- **View** - UIKit views that handle rendering and user interaction
- **ViewModel Protocol** - Defines the interface for the view model
- **Mock ViewModel** - Provides sample implementations for testing and previews

### Reactive Programming

Components use Combine framework publishers to communicate state changes:

```swift
viewModel.displayStatePublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] displayState in
        self?.render(state: displayState)
    }
    .store(in: &cancellables)
```

### Style Customization

Styling is centralized through the `StyleProvider` class:

```swift
// Colors
StyleProvider.Color.customize(
    primaryColor: .systemBlue,
    accentColor: .systemOrange,
    toolbarBackgroundColor: .systemOrange
)

// Fonts
StyleProvider.setFontProvider { type, size in
    // Custom font implementation
}
```

## StyleProvider

The `StyleProvider` is a key part of GomaUI's architecture that enables consistent styling across all components while allowing for client-specific theming:

### Features

- **Centralized Color Management**: Provides a single source of truth for all colors used in the UI components
- **Font Consistency**: Offers a unified approach to typography with support for different font weights and sizes
- **Customization API**: Allows complete theme customization without modifying the component internals
- **Default Values**: Ships with sensible defaults that work out of the box

### Implementation

The StyleProvider consists of two main parts:

1. **Color System**: A static struct with predefined color properties and a customization method:
   ```swift
   // Access colors
   backgroundColor = StyleProvider.Color.backgroundColor
   button.tintColor = StyleProvider.Color.primaryColor

   // Customize colors
   StyleProvider.Color.customize(
       primaryColor: UIColor(named: "BrandPrimary"),
       toolbarBackgroundColor: UIColor(named: "ToolbarBackground")
   )
   ```

2. **Typography System**: A font provider pattern that can be customized to use any font library:
   ```swift
   // Access fonts
   label.font = StyleProvider.fontWith(type: .medium, size: 14)

   // Customize with custom fonts
   StyleProvider.setFontProvider { type, size in
       switch type {
       case .bold:
           return UIFont(name: "CustomFont-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
       case .regular:
           return UIFont(name: "CustomFont-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
       // other cases...
       }
   }
   ```

This approach ensures that visual consistency is maintained while giving clients the flexibility to implement their brand guidelines without modifying the component code.

## Integration

To integrate GomaUI into your project:

1. Add the package to your Swift Package Manager dependencies:
   ```swift
   dependencies: [
       .package(url: "https://github.com/gomagaming/GomaUI-iOS.git", from: "1.0.0")
   ]
   ```

2. Import the module in your Swift files:
   ```swift
   import GomaUI
   ```

3. Create and use components in your view controllers:
   ```swift
   let viewModel = MockAdaptiveTabBarViewModel.defaultMock
   let tabBar = AdaptiveTabBarView(viewModel: viewModel)
   view.addSubview(tabBar)
   ```

## Contributing

Want to add a new component? See the **[Contributing Guide](CONTRIBUTING.md)** for:

- Complete component creation workflow
- File structure requirements
- Snapshot testing setup
- Catalog integration steps
- Pre-submission checklist

For detailed technical guides, see:
- [Component Creation Guide](Documentation/Guides/COMPONENT_CREATION.md)
- [Snapshot Testing Guide](Documentation/Guides/SNAPSHOT_TESTING.md)
- [UIKit Code Organization](Documentation/Guides/UIKIT_CODE_ORGANIZATION.md)
- [Adding to Catalog](Documentation/Guides/ADDING_CATALOG_COMPONENTS.md)

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## License

[License details would go here]