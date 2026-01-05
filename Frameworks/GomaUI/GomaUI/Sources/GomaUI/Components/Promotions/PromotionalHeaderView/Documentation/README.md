# PromotionalHeaderView

A clean, information-only promotional header component built with UIKit and Combine that displays promotional content with an icon, title, and optional subtitle. The component is designed for showcasing promotional information, announcements, and informational messages in a visually appealing header format.

## Overview

The `PromotionalHeaderView` is designed to display promotional and informational content in a prominent, card-like header format. It features an icon on the left, title text (required), and optional subtitle text, all within a rounded container with customizable background colors. The component follows MVVM architecture and uses reactive programming with Combine for state management. This is a purely informational component with no interactive actions.

## Architecture

### Component Structure
```
PromotionalHeaderView/
├── PromotionalHeaderView.swift                # Main component view
├── PromotionalHeaderViewModelProtocol.swift   # View model protocol and data models
├── MockPromotionalHeaderViewModel.swift       # Mock implementation
└── Documentation/
    └── README.md                              # This documentation
```

### MVVM Pattern
- **View**: `PromotionalHeaderView` - Main UI component with header layout
- **ViewModel**: `PromotionalHeaderViewModelProtocol` - State management
- **Model**: `PromotionalHeaderData` & `PromotionalHeaderDisplayState` - Data structures

## Key Features

### Visual Design
- **Rounded Container**: 12pt corner radius for modern card appearance
- **Icon Support**: System icons or custom images with orange tint color
- **Typography Hierarchy**: Bold 16pt title, regular 14pt subtitle
- **Flexible Layout**: Adapts to content with or without subtitle
- **Custom Background**: Customizable background colors for different promotions

### Display Properties
- **Information Only**: Pure display component with no user interactions
- **Responsive Design**: Adapts to different content lengths
- **Optional Elements**: Subtitle can be hidden when not provided
- **Visibility Control**: Can be shown or hidden programmatically

### Layout Structure
- **Horizontal Layout**: Icon and text content arranged horizontally
- **Vertical Text Stack**: Title and subtitle stacked vertically
- **Consistent Spacing**: Proper spacing between elements
- **Auto-sizing**: Height adjusts based on content

## Models

### PromotionalHeaderData
```swift
public struct PromotionalHeaderData: Equatable, Hashable {
    public let id: String
    public let icon: String
    public let title: String
    public let subtitle: String?
    public let backgroundColor: UIColor?
}
```

**Properties:**
- `id`: Unique identifier for the header
- `icon`: System icon name or custom image name
- `title`: Main promotional message (required)
- `subtitle`: Secondary description text (optional)
- `backgroundColor`: Custom background color (optional)

### PromotionalHeaderDisplayState
```swift
public struct PromotionalHeaderDisplayState: Equatable {
    public let headerData: PromotionalHeaderData
    public let isVisible: Bool
}
```

**Properties:**
- `headerData`: The header content and styling information
- `isVisible`: Controls header visibility

## Protocols

### PromotionalHeaderViewModelProtocol
```swift
public protocol PromotionalHeaderViewModelProtocol {
    var displayStatePublisher: AnyPublisher<PromotionalHeaderDisplayState, Never> { get }
    
    func setHeaderVisibility(_ isVisible: Bool)
}
```

**Key Methods:**
- `setHeaderVisibility(_:)`: Controls header visibility

## Usage Examples

### Basic Implementation
```swift
// Create header data
let headerData = PromotionalHeaderData(
    id: "deposit_bonus",
    icon: "dollarsign.circle.fill",
    title: "Claim a first deposit bonus!",
    subtitle: "Select a first deposit bonus of your choosing...",
    backgroundColor: UIColor.systemOrange.withAlphaComponent(0.1)
)

// Create view model
let viewModel = MockPromotionalHeaderViewModel(headerData: headerData)

// Create header view
let headerView = PromotionalHeaderView(viewModel: viewModel)

// Add to view hierarchy
parentView.addSubview(headerView)
headerView.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
    headerView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 16),
    headerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    headerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16)
])
```

### Header Without Subtitle
```swift
let headerData = PromotionalHeaderData(
    id: "welcome_bonus",
    icon: "gift.fill",
    title: "Welcome Bonus Available!",
    subtitle: nil,  // No subtitle
    backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)
)

let viewModel = MockPromotionalHeaderViewModel(headerData: headerData)
let headerView = PromotionalHeaderView(viewModel: viewModel)
```

### Custom ViewModel Implementation
```swift
class InfoHeaderViewModel: PromotionalHeaderViewModelProtocol {
    private let displayStateSubject: CurrentValueSubject<PromotionalHeaderDisplayState, Never>
    var displayStatePublisher: AnyPublisher<PromotionalHeaderDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    private let analyticsService: AnalyticsService
    
    init(headerData: PromotionalHeaderData, analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
        
        let initialState = PromotionalHeaderDisplayState(headerData: headerData)
        self.displayStateSubject = CurrentValueSubject(initialState)
        
        // Track header display
        analyticsService.track("promotional_header_displayed", properties: [
            "header_id": headerData.id,
            "header_title": headerData.title
        ])
    }
    
    func setHeaderVisibility(_ isVisible: Bool) {
        let currentState = displayStateSubject.value
        let newState = PromotionalHeaderDisplayState(
            headerData: currentState.headerData,
            isVisible: isVisible
        )
        displayStateSubject.send(newState)
        
        // Track visibility changes
        analyticsService.track("promotional_header_visibility_changed", properties: [
            "header_id": currentState.headerData.id,
            "is_visible": isVisible
        ])
    }
}
```

### Multiple Header Types
```swift
class PromotionHeaderFactory {
    static func createDepositHeader() -> PromotionalHeaderView {
        let data = PromotionalHeaderData(
            id: "deposit_bonus",
            icon: "dollarsign.circle.fill",
            title: "Claim a first deposit bonus!",
            subtitle: "Select a first deposit bonus of your choosing...",
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.1)
        )
        let viewModel = MockPromotionalHeaderViewModel(headerData: data)
        return PromotionalHeaderView(viewModel: viewModel)
    }
    
    static func createTournamentHeader() -> PromotionalHeaderView {
        let data = PromotionalHeaderData(
            id: "tournament_info",
            icon: "trophy.fill",
            title: "Weekly Tournament",
            subtitle: "Join our weekly poker tournament for a chance to win big!",
            backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1)
        )
        let viewModel = MockPromotionalHeaderViewModel(headerData: data)
        return PromotionalHeaderView(viewModel: viewModel)
    }
    
    static func createGameUpdateHeader() -> PromotionalHeaderView {
        let data = PromotionalHeaderData(
            id: "game_update",
            icon: "gamecontroller.fill",
            title: "New Games Added",
            subtitle: "Check out our latest slot games with exciting themes!",
            backgroundColor: UIColor.systemMint.withAlphaComponent(0.1)
        )
        let viewModel = MockPromotionalHeaderViewModel(headerData: data)
        return PromotionalHeaderView(viewModel: viewModel)
    }
}
```

### Dynamic Header Updates
```swift
class DynamicHeaderViewController: UIViewController {
    private var headerView: PromotionalHeaderView!
    private var viewModel: MockPromotionalHeaderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MockPromotionalHeaderViewModel.defaultMock
        headerView = PromotionalHeaderView(viewModel: viewModel)
        
        setupHeaderConstraints()
        
        // Update header content after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.updateHeaderContent()
        }
    }
    
    private func updateHeaderContent() {
        let newData = PromotionalHeaderData(
            id: "updated_promo",
            icon: "star.fill",
            title: "Special Weekend Offer!",
            subtitle: "Limited time promotion available now.",
            backgroundColor: UIColor.systemPurple.withAlphaComponent(0.1)
        )
        
        viewModel.updateHeaderData(newData)
    }
}
```

## Component Behavior

### Layout Behavior
- **Icon Size**: Fixed 40x40pt for consistent appearance
- **Container Padding**: 16pt padding around content
- **Text Stack Spacing**: 4pt between title and subtitle
- **Horizontal Spacing**: 12pt between icon and text
- **Corner Radius**: 12pt for modern card appearance

### Optional Subtitle Handling
- **With Subtitle**: Both title and subtitle are displayed
- **Without Subtitle**: Only title is shown, subtitle label is hidden
- **Dynamic Updates**: Subtitle visibility updates reactively

### Visual States
- **Visible State**: Component is displayed normally
- **Hidden State**: Component is completely hidden
- **Custom Background**: Supports various background colors

## Styling Integration

The component integrates with `StyleProvider` for consistent theming:

- **Colors**:
  - `highlightPrimary`: Icon tint color
  - `textPrimary`: Title text color
  - `textSecondary`: Subtitle text color
  - `backgroundColor`: Default background color
- **Typography**:
  - Bold 16pt for header titles
  - Regular 14pt for subtitles
- **Layout**:
  - 12pt corner radius
  - Consistent padding and spacing

## Accessibility Features

- **Clear Content**: Descriptive titles and subtitles
- **Visual Hierarchy**: Clear typography distinction between title and subtitle
- **Screen Reader Support**: Proper accessibility labels
- **Optional Content**: Graceful handling of missing subtitle
- **Semantic Structure**: Proper use of headings and content structure

## Use Cases

### Promotional Information
```swift
let promoHeader = PromotionalHeaderData(
    id: "weekend_bonus",
    icon: "percent",
    title: "Weekend Bonus Active",
    subtitle: "Get 25% extra on all deposits this weekend!",
    backgroundColor: UIColor.systemOrange.withAlphaComponent(0.1)
)
```

### Tournament Announcements
```swift
let tournamentHeader = PromotionalHeaderData(
    id: "poker_tournament",
    icon: "trophy.fill",
    title: "Poker Tournament Starting",
    subtitle: "Buy-in: $50 | Prize Pool: $10,000",
    backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1)
)
```

### Game Updates
```swift
let gameUpdateHeader = PromotionalHeaderData(
    id: "new_slots",
    icon: "gamecontroller.fill",
    title: "New Slot Games",
    subtitle: nil,
    backgroundColor: UIColor.systemMint.withAlphaComponent(0.1)
)
```

### Account Information
```swift
let accountHeader = PromotionalHeaderData(
    id: "loyalty_status",
    icon: "crown.fill",
    title: "VIP Gold Member",
    subtitle: "Enjoy exclusive benefits and higher limits.",
    backgroundColor: UIColor.systemYellow.withAlphaComponent(0.1)
)
```

### System Announcements
```swift
let maintenanceHeader = PromotionalHeaderData(
    id: "maintenance_notice",
    icon: "wrench.fill",
    title: "Scheduled Maintenance",
    subtitle: "System will be offline from 2:00 AM - 4:00 AM PST.",
    backgroundColor: UIColor.systemGray.withAlphaComponent(0.1)
)
```

## Technical Implementation

### Memory Management
- Weak references in closures to prevent retain cycles
- Proper Combine cancellable storage
- Efficient view hierarchy with minimal nesting

### Performance Considerations
- Lightweight view structure for smooth scrolling
- Efficient constraint setup
- Optimized for dynamic content updates
- Small memory footprint

### State Management
- Reactive updates with Combine
- Clean separation of concerns
- Predictable state changes

## Error Handling

### Defensive Programming
- Safe unwrapping of optional subtitle
- Graceful fallbacks for missing icons
- Proper handling of empty content
- Safe background color handling

### Data Validation
- Non-empty title validation
- Valid icon name verification
- Proper state management

## Dependencies

- **UIKit**: Core UI framework
- **Combine**: Reactive programming and state management
- **StyleProvider**: Internal styling and theming system
- **Foundation**: Basic data structures

## Best Practices

1. **Content Quality**: Use clear, descriptive messages
2. **Icon Selection**: Choose appropriate system icons for each content type
3. **Background Colors**: Use subtle, branded colors that enhance readability
4. **Subtitle Usage**: Keep subtitles concise and informative
5. **Consistent Styling**: Follow the design system guidelines
6. **Performance**: Keep headers lightweight for list performance
7. **Accessibility**: Ensure proper content structure and labeling

## Integration Patterns

### With Content Management System
```swift
class ContentHeaderViewController: UIViewController {
    private var headerView: PromotionalHeaderView?
    private let contentService: ContentService
    
    func displayFeaturedContent() {
        contentService.getFeaturedPromotion { [weak self] content in
            guard let content = content else { return }
            
            let headerData = PromotionalHeaderData(
                id: content.id,
                icon: content.iconName,
                title: content.title,
                subtitle: content.description,
                backgroundColor: content.brandColor
            )
            
            let viewModel = MockPromotionalHeaderViewModel(headerData: headerData)
            self?.headerView = PromotionalHeaderView(viewModel: viewModel)
            self?.setupHeaderConstraints()
        }
    }
}
```

### In Table View Headers
```swift
class PromotionalTableViewController: UITableViewController {
    private var headerViewModel: MockPromotionalHeaderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create header
        headerViewModel = MockPromotionalHeaderViewModel.defaultMock
        let headerView = PromotionalHeaderView(viewModel: headerViewModel)
        
        // Set as table header
        tableView.tableHeaderView = headerView
        
        // Configure constraints
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
        
        // Update table header view layout
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
    }
}
```

### In Collection View Supplementary Views
```swift
class PromotionalCollectionViewController: UICollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "PromotionalHeader",
                for: indexPath
            ) as! PromotionalCollectionHeader
            
            let viewModel = MockPromotionalHeaderViewModel.defaultMock
            headerView.configure(with: viewModel)
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
}
```

## Future Enhancements

- Support for custom fonts and typography scales
- Animation effects for content changes
- Support for action buttons within the header
- Timer display for time-sensitive information
- Progress indicators for ongoing promotions
- Image support alongside or instead of icons
- Custom corner radius and shadow options
- Rich text support for formatted content
- Swipe gestures for additional interactions
- Localization support for multi-language content
- Dark mode optimization
- Dynamic type support for accessibility

This component provides a clean, flexible solution for displaying informational and promotional content throughout the application while maintaining consistency with the GomaUI design system and focusing purely on information display without any interactive complexity. 