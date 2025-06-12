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
import GomaUI

// Create with mock data
let viewModel = MockMatchHeaderViewModel.premierLeagueHeader
let headerView = MatchHeaderView(viewModel: viewModel)

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

## Custom Implementation

```swift
// Create your own view model
class CustomMatchHeaderViewModel: MatchHeaderViewModelProtocol {
    private let competitionNameSubject = CurrentValueSubject<String, Never>("")
    // ... implement other publishers and methods
}

// Configure with custom data
let customViewModel = CustomMatchHeaderViewModel()
customViewModel.updateData(MatchHeaderData(
    id: "custom_league",
    competitionName: "My Custom League",
    countryFlagImageName: "custom_flag",
    sportIconImageName: "custom_sport",
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
override func configure(with competition: Competition) {
    let viewModel = createViewModel(from: competition)
    matchHeaderView.configure(with: viewModel)
}

override func prepareForReuse() {
    super.prepareForReuse()
    matchHeaderView.cleanupForReuse()
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
```

## Layout Considerations

- **Fixed Height**: Component has a fixed height of 17 points
- **Horizontal Layout**: Elements are arranged horizontally with 7pt spacing
- **Touch Target**: Favorite button has 40x40pt touch area for accessibility
- **Intrinsic Size**: Width expands to fill available space, height is fixed

## Image Asset Requirements

The component expects these image assets in your bundle:

- `selected_favorite_icon` - Filled heart icon for favorited state
- `unselected_favorite_icon` - Empty heart icon for non-favorited state
- Country flag images (e.g., "GB", "ES", "IT", "US")
- Sport icons (e.g., "1" for football, "8" for basketball, "5" for tennis)

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
@testable import GomaUI

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