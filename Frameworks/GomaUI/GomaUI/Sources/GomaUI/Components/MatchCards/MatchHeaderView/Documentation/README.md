# MatchHeaderView

A sports competition header component that displays competition name, country flag, sport icon, and favorite toggle functionality.

## Overview

`MatchHeaderView` is a horizontal layout component designed for sports applications that need to display competition information with interactive elements. It follows the GomaUI architecture with protocol-based design, reactive data flow, and unified visual state management.

## Features

- **Competition Display**: Shows competition name with proper text styling
- **Country Flag**: Circular country flag image with border
- **Sport Icon**: Circular sport-specific icon 
- **Favorite Toggle**: Interactive heart icon for favorite competitions
- **Visual States**: Multiple display modes for different contexts
- **Reactive Updates**: Real-time data updates through Combine publishers
- **Accessibility**: Full accessibility support with proper labels
- **Theming**: Consistent styling through StyleProvider integration

## Visual States

### Standard
Shows all elements (favorite icon, sport icon, country flag, competition name) with full interactivity.

### Disabled  
Shows all elements but with reduced opacity (60%) and disabled interactions.

### Favorite Only
Shows only the favorite icon and competition name, hiding country flag and sport icon.

### Minimal
Shows only the competition name, hiding all icons for space-constrained layouts.

## Basic Usage

```swift


// Create with mock data (uses default system icons)
let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
let headerView = MatchHeaderView(viewModel: viewModel)

// Create with custom image resolver
let customImageResolver = YourAppImageResolver()
let headerView = MatchHeaderView(viewModel: viewModel, imageResolver: customImageResolver)

// Or configure existing view
let headerView = MatchHeaderView()
headerView.configure(with: viewModel)

// Add to your view hierarchy
view.addSubview(headerView)
headerView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
])
```

## Available Mock ViewModels

```swift
// Standard headers with different leagues
MockMatchHeaderViewModel.premierLeagueHeader
MockMatchHeaderViewModel.laLigaFavoriteHeader
MockMatchHeaderViewModel.serieABasketballHeader

// Different visual states
MockMatchHeaderViewModel.disabledNBAHeader
MockMatchHeaderViewModel.minimalModeHeader
MockMatchHeaderViewModel.favoriteOnlyHeader

// Edge cases
MockMatchHeaderViewModel.longNameHeader
MockMatchHeaderViewModel.basicHeader
```

## Custom Image Resolution

```swift
// Create your own image resolver
struct AppImageResolver: MatchHeaderImageResolver {
    func countryFlagImage(for countryCode: String) -> UIImage? {
        return UIImage(named: "flag_\(countryCode)", in: .main, compatibleWith: nil)
    }
    
    func sportIconImage(for sportId: String) -> UIImage? {
        return UIImage(named: "sport_\(sportId)", in: .main, compatibleWith: nil)
    }
    
    func favoriteIcon(isFavorite: Bool) -> UIImage? {
        let imageName = isFavorite ? "star_filled" : "star_outline"
        return UIImage(named: imageName, in: .main, compatibleWith: nil)
    }
    
    func liveIndicatorIcon() -> UIImage? {
        return UIImage(named: "live_play_icon", in: .main, compatibleWith: nil)
    }
}

// Use with custom resolver
let imageResolver = AppImageResolver()
let headerView = MatchHeaderView(viewModel: viewModel, imageResolver: imageResolver)
```

## Custom ViewModel Implementation

```swift
// Create your own view model
class CustomMatchHeaderViewModel: MatchHeaderViewModelProtocol {
    private let competitionNameSubject = CurrentValueSubject<String, Never>("")
    // ... implement other publishers and methods (without UIKit dependencies)
}

// Configure with custom data
let customViewModel = CustomMatchHeaderViewModel()
customViewModel.updateData(MatchHeaderData(
    id: "custom_league",
    competitionName: "My Custom League",
    countryFlagImageName: "GB",  // String identifier, not UIImage
    sportIconImageName: "1",     // String identifier, not UIImage
    isFavorite: true,
    visualState: .standard
))
```

## Interactive Features

```swift
// Handle favorite toggle events
let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
viewModel.favoriteToggleCallback = { isFavorite in
    print("Favorite toggled: \(isFavorite)")
    // Update your data model
    updateUserFavorites(competitionId: "premier_league", isFavorite: isFavorite)
}

// Programmatically toggle favorite
viewModel.toggleFavorite()

// Change visual state
viewModel.setVisualState(.minimal)
viewModel.setEnabled(false)
```

## Reactive Updates

```swift
// Listen to changes
viewModel.isFavoritePublisher
    .sink { isFavorite in
        // React to favorite changes
    }
    .store(in: &cancellables)

viewModel.visualStatePublisher
    .sink { state in
        // React to visual state changes
    }
    .store(in: &cancellables)

// Update data dynamically
viewModel.updateCompetitionName("New Competition Name")
viewModel.updateCountryFlag("GB")
viewModel.updateSportIcon("1")
```

## Integration with Table/Collection Views

```swift
// In your cell configuration
class MatchCell: UITableViewCell {
    private let imageResolver = AppImageResolver() // Reuse the same resolver
    private lazy var matchHeaderView = MatchHeaderView(viewModel: MockMatchHeaderViewModel.defaultMock, imageResolver: imageResolver)
    
    override func configure(with competition: Competition) {
        let viewModel = createViewModel(from: competition)
        matchHeaderView.configure(with: viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        matchHeaderView.cleanupForReuse() // ImageResolver is preserved
    }
    
    private func createViewModel(from competition: Competition) -> MatchHeaderViewModelProtocol {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: competition.id,
                competitionName: competition.name,
                countryFlagImageName: competition.countryCode,
                sportIconImageName: competition.sportId,
                isFavorite: competition.isFavorite,
                visualState: .standard
            )
        )
    }
}
```

## Layout Considerations

- **Fixed Height**: Component has a fixed height of 17 points
- **Horizontal Layout**: Elements are arranged horizontally with 7pt spacing
- **Touch Target**: Favorite button has 40x40pt touch area for accessibility
- **Intrinsic Size**: Width expands to fill available space, height is fixed

## Image Resolution

The component uses the `MatchHeaderImageResolver` protocol to resolve images. You have two options:

### Default System Icons (DefaultMatchHeaderImageResolver)
- Country flags: `globe` system icon
- Sport icons: `soccerball` system icon  
- Favorite icons: `star` and `star.fill` system icons
- Live indicator: `play.fill` system icon

### Custom Images (Your Implementation)
Implement `MatchHeaderImageResolver` to provide your own images:
- Country flag images (e.g., "GB", "ES", "IT", "US")
- Sport icons (e.g., "1" for football, "8" for basketball, "5" for tennis)
- Custom favorite and live indicator icons

**Important**: The ViewModel protocol no longer includes UIKit dependencies. It only provides string identifiers that your ImageResolver converts to UIImages.

## Styling Customization

```swift
// Customize colors through StyleProvider
StyleProvider.Color.customize(
    textColor: UIColor.label,
    primaryColor: UIColor.systemBlue
)

// Customize fonts
StyleProvider.setFontProvider { type, size in
    switch type {
    case .medium:
        return UIFont(name: "YourCustomFont-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    default:
        return .systemFont(ofSize: size, weight: type.systemWeight)
    }
}
```

## Testing

```swift
import XCTest
@testable 

class MatchHeaderViewTests: XCTestCase {
    func testFavoriteToggle() {
        let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
        let expectation = XCTestExpectation(description: "Favorite toggled")
        
        viewModel.favoriteToggleCallback = { isFavorite in
            XCTAssertTrue(isFavorite)
            expectation.fulfill()
        }
        
        viewModel.toggleFavorite()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testVisualStateChanges() {
        let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
        viewModel.setVisualState(.disabled)
        XCTAssertEqual(viewModel.currentVisualState, .disabled)
    }
}
```

## Migration from Legacy

If migrating from the legacy `MatchHeaderView`, follow these steps:

1. **Replace ViewModel**: Replace concrete `MatchHeaderViewModel` with protocol-based approach
2. **Update Styling**: Replace hardcoded colors with `StyleProvider` calls
3. **Simplify State**: Replace individual visibility publishers with unified visual state
4. **Update Bindings**: Use new publisher structure for reactive updates

```swift
// Legacy approach
let viewModel = MatchHeaderViewModel(
    competitionName: "Premier League",
    countryImageName: "GB",
    isFavorite: false,
    sportImageName: "1"
)

// New GomaUI approach
let viewModel = MockMatchHeaderViewModel(
    matchHeaderData: MatchHeaderData(
        id: "premier_league",
        competitionName: "Premier League", 
        countryFlagImageName: "GB",
        sportIconImageName: "1",
        isFavorite: false,
        visualState: .standard
    )
)
``` 
