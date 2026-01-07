# BonusInfoCardView

A comprehensive card component for displaying bonus information with optional header images, status indicators, wagering progress, and expiry details.

## Overview

`BonusInfoCardView` is a production-ready GomaUI component that displays detailed bonus information in a visually appealing card layout. The component follows MVVM architecture and is fully customizable through its protocol-based interface.

## Features

- **Optional Header Image**: Display promotional imagery at the top of the card
- **Status Indicator**: Visual pill showing bonus status (Active/Released)
- **Dual Amount Display**: Shows both bonus amount and remaining balance
- **Wagering Progress**: Visual progress bar with optional remaining amount text
- **Terms & Conditions Button**: Interactive button for accessing bonus terms
- **Expiry Information**: Displays bonus expiration date with calendar icon
- **Flexible Layout**: Automatically hides optional elements when data is not available

## Component Structure

```
BonusInfoCardView/
├── BonusStatus.swift                      # Enum for bonus status types
├── BonusInfoCardView.swift                # Main view implementation
├── BonusInfoCardViewModelProtocol.swift   # Protocol interface
├── MockBonusInfoCardViewModel.swift       # Mock implementation with presets
└── README.md                              # This documentation
```

## Usage

### Basic Implementation

```swift
import GomaUI

// Create bonus data
let bonusData = BonusInfoCardData(
    id: "bonus_123",
    title: "Welcome Bonus",
    subtitle: "oddsBoost",
    status: .active,
    headerImageURL: "https://example.com/bonus-header.jpg",
    bonusAmount: "XAF 2000.00",
    remainingAmount: "XAF 3000.00",
    wageringProgress: 0.33,
    remainingToWagerText: "+ XAF 1500.00 remaining to wager",
    expiryText: "Sun 01/01 - 18:59"
)

// Create view model (production implementation)
let viewModel = MyBonusInfoCardViewModel(cardData: bonusData)

// Create and configure the view
let bonusCard = BonusInfoCardView(viewModel: viewModel)
bonusCard.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(bonusCard)

// Setup constraints
NSLayoutConstraint.activate([
    bonusCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    bonusCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    bonusCard.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
])
```

### Using Mock Data

```swift
// Use preset mocks for testing/development
let bonusCard = BonusInfoCardView(viewModel: MockBonusInfoCardViewModel.complete)

// Available presets:
// - .complete: Full bonus with all features
// - .withoutHeader: No header image
// - .withoutRemainingText: No remaining wager text
// - .released: Completed bonus
// - .minimal: Only required elements
// - .almostComplete: High progress bonus
```

### Implementing the Protocol

```swift
import Combine

class MyBonusInfoCardViewModel: BonusInfoCardViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<BonusInfoCardDisplayState, Never>
    
    var displayStatePublisher: AnyPublisher<BonusInfoCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    private let coordinator: BonusCoordinatorProtocol
    
    // MARK: - Initialization
    init(cardData: BonusInfoCardData, coordinator: BonusCoordinatorProtocol) {
        self.displayStateSubject = CurrentValueSubject(
            BonusInfoCardDisplayState(cardData: cardData)
        )
        self.coordinator = coordinator
    }
    
    // MARK: - Actions
    func didTapTermsAndConditions() {
        let currentState = displayStateSubject.value
        coordinator.showTermsAndConditions(for: currentState.id)
    }
    
    // MARK: - Configuration
    func configure(with cardData: BonusInfoCardData) {
        displayStateSubject.send(BonusInfoCardDisplayState(cardData: cardData))
    }
}

// Helper to create BonusInfoCardData from domain model
extension BonusInfoCardData {
    init(from domainBonus: Bonus) {
        self.init(
            id: domainBonus.id,
            title: domainBonus.name,
            subtitle: domainBonus.type,
            status: domainBonus.isActive ? .active : .released,
            headerImageURL: domainBonus.imageURL,
            bonusAmount: domainBonus.formattedAmount,
            remainingAmount: domainBonus.formattedRemaining,
            wageringProgress: domainBonus.wageringProgress,
            remainingToWagerText: domainBonus.remainingToWager > 0 
                ? "+ \(domainBonus.formattedRemainingToWager) remaining to wager" 
                : nil,
            expiryText: domainBonus.formattedExpiryDate
        )
    }
}
```

## Data Models

### BonusInfoCardData

The immutable data structure containing all bonus information:

```swift
public struct BonusInfoCardData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let status: BonusStatus
    public let headerImageURL: String?
    public let bonusAmount: String
    public let remainingAmount: String
    public let wageringProgress: Float
    public let remainingToWagerText: String?
    public let expiryText: String
}
```

### BonusInfoCardDisplayState

Display state wrapper with convenience properties:

```swift
public struct BonusInfoCardDisplayState: Equatable {
    public let cardData: BonusInfoCardData
    public let isVisible: Bool
    
    // Convenience properties for easier access
    public var id: String { cardData.id }
    public var title: String { cardData.title }
    // ... other properties
}
```

## Protocol Requirements

### Required Properties

- `displayStatePublisher: AnyPublisher<BonusInfoCardDisplayState, Never>` - Publisher for reactive updates

### Required Methods

- `didTapTermsAndConditions()` - Called when Terms & Conditions button is tapped
- `configure(with cardData: BonusInfoCardData)` - Update the bonus data

### BonusInfoCardData Properties

**Required:**
- `id: String` - Unique identifier
- `title: String` - Main bonus title
- `status: BonusStatus` - Current status (.active or .released)
- `bonusAmount: String` - Formatted bonus amount
- `remainingAmount: String` - Formatted remaining balance
- `wageringProgress: Float` - Progress value (0.0 to 1.0)
- `expiryText: String` - Expiry date/time text

**Optional:**
- `headerImageURL: String?` - Header image URL (card hides header if nil)
- `subtitle: String?` - Bonus type or subtitle
- `remainingToWagerText: String?` - Remaining wager text (hidden if nil)

## Optional Elements Behavior

The component intelligently handles optional elements:

| Element | When Hidden |
|---------|-------------|
| Header Image | When `headerImage` is `nil` |
| Subtitle | When `subtitle` is `nil` |
| Remaining Wager Text | When `remainingToWagerText` is `nil` |

All other elements are always visible.

## Status Types

### BonusStatus.active
- Green background pill
- Green text
- Indicates bonus is currently active and can be used

### BonusStatus.released
- Gray background pill
- Gray text
- Indicates bonus has been completed and released

## Styling

The component uses `StyleProvider` for all visual properties:

- Colors adapt to app theme automatically
- Fonts use centralized typography system
- No hardcoded visual properties
- Fully themeable without code changes

## Design Specifications

- **Card Corner Radius**: 12pt
- **Card Shadow**: Subtle shadow for elevation
- **Header Image Height**: 160pt (when present)
- **Amount Box Corner Radius**: 8pt
- **Progress Bar Height**: 8pt
- **Button Height**: 48pt
- **Expiry Section Height**: 44pt
- **Spacing**: Consistent 16pt margins, 8-20pt internal spacing

## Integration Checklist

When implementing a production ViewModel:

- [ ] Create `BonusInfoCardData` from your domain model
- [ ] Implement `BonusInfoCardViewModelProtocol` with publisher pattern
- [ ] Initialize `CurrentValueSubject<BonusInfoCardDisplayState, Never>`
- [ ] Handle optional properties correctly (set to nil when not available)
- [ ] Format currency values consistently
- [ ] Format dates in appropriate locale
- [ ] Implement `didTapTermsAndConditions()` action
- [ ] Provide header image URLs (images loaded automatically via Kingfisher)
- [ ] Validate wagering progress is between 0.0 and 1.0
- [ ] Update display state when bonus data changes via `configure(with:)`

## Dependencies

This component requires:
- **Kingfisher**: For asynchronous image loading from URLs
- **Combine**: For reactive publisher pattern

## Example Integration

```swift
// In your view controller
class BonusDetailViewController: UIViewController {
    private lazy var bonusCard = BonusInfoCardView(viewModel: viewModel)
    private let viewModel: BonusCardViewModelProtocol
    
    init(viewModel: BonusCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBonusCard()
    }
    
    private func setupBonusCard() {
        bonusCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bonusCard)
        
        NSLayoutConstraint.activate([
            bonusCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bonusCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bonusCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
}
```

## SwiftUI Previews

The component includes multiple SwiftUI preview configurations:

- Complete Bonus (with all features)
- Without Header Image
- Minimal (no optional elements)
- Released Status
- Almost Complete (high progress)

Use these previews during development to quickly iterate on the design.

## Accessibility

The component is designed with accessibility in mind:

- All text uses dynamic type through `StyleProvider`
- Interactive elements have appropriate touch targets (48pt minimum)
- Semantic colors provide good contrast ratios
- Progress bar provides visual feedback

## Performance Considerations

- Lazy property initialization for efficient memory usage
- Static factory methods for consistent object creation
- Minimal view hierarchy depth
- Efficient constraint management

## Related Components

- `BonusCardView` (existing) - Original bonus card implementation
- Consider `BonusInfoCardView` for new implementations requiring detailed bonus display

---

*Created: October 24, 2025*
*Version: 1.0.0*
*Framework: GomaUI*

