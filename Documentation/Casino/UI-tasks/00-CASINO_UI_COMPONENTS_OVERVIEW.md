# Casino UI Components Overview

## Architecture and Component Relationships

This document provides a comprehensive overview of the casino UI components needed for the iOS casino feature implementation within the GomaUI framework.

## Design Analysis

Based on the Figma designs at:
- Main Casino List: `https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=1861-98339&m=dev`
- Category Games View: `https://www.figma.com/design/oGh41UArYBfHuXB2RCSPTC/betsson.cm-Version-1.3--Goma---Copy-?node-id=1861-98390&m=dev`

## Component Hierarchy

```
Casino List Screen
├── CasinoRecentlyPlayedView (Container)
│   ├── Section Header: "Recently Played"
│   └── Horizontal Layout: CasinoRecentlyPlayedCardView instances
├── Multiple Category Sections:
│   ├── CasinoCategoryHeaderView (Leaf)
│   │   ├── Category Name (e.g., "New Games", "Live Games")
│   │   └── "All X >" Button
│   └── CasinoCategoryScrollView (Container)
│       └── CasinoGameCollectionViewCell instances
│           └── CasinoGameCardView (Leaf)
```

## Component Types

### Leaf Components (No Dependencies)
1. **CasinoCategoryHeaderView** - Category section headers
2. **CasinoGameCardView** - Individual game display cards (vertical/portrait)
3. **CasinoRecentlyPlayedCardView** - Recently played game cards (horizontal/landscape)

### Container Components (Use Other Components)
4. **CasinoRecentlyPlayedView** - Recently played games section
5. **CasinoCategoryScrollView** - Horizontal scrolling game collections

### Wrapper Components (Simple Wrappers)
6. **CasinoGameCollectionViewCell** - UICollectionViewCell wrapper for game cards

## Visual Design Elements

### CasinoGameCardView Elements (Vertical/Portrait)
- **Game Image**: Main artwork/screenshot
- **Game Title**: Bold title text (e.g., "PlinkGoal")
- **Provider Name**: Subtitle text (e.g., "Gaming Corps")
- **Star Rating**: Visual rating display (3/5 stars)
- **Min Stake**: Small text (e.g., "Min Stake: XAF 1")
- **Card Background**: Rounded corners, shadow/elevation
- **Size**: 160×220pt (portrait orientation)

### CasinoRecentlyPlayedCardView Elements (Horizontal/Landscape)
- **Game Image**: Square/landscape artwork (left side)
- **Game Title**: Bold title text (e.g., "Gonzo's Quest")
- **Provider Name**: Subtitle text (e.g., "Netent")
- **Horizontal Layout**: Image left, text content right
- **Card Background**: Rounded corners, shadow/elevation
- **Size**: 280×120pt (landscape orientation)

### CasinoCategoryHeaderView Elements
- **Category Title**: Bold section header (e.g., "New Games")
- **Count Button**: Orange button with "All X >" text
- **Horizontal Layout**: Title left, button right

### Layout Specifications
- **Game Cards**: Consistent sizing across all contexts (160×220pt portrait)
- **Recently Played Cards**: Optimized for recently played section (280×120pt landscape)
- **Horizontal Scrolling**: Smooth collection view scrolling for categories
- **Fixed Layout**: Recently played section uses stack view (no scrolling)
- **Spacing**: Consistent margins and padding throughout
- **Responsive**: Adapts to different screen sizes

## GomaUI Integration

### Following GomaUI Patterns
- **MVVM Architecture**: View, ViewModelProtocol, MockViewModel
- **Reactive Programming**: Combine publishers for state updates
- **StyleProvider Integration**: Centralized colors and fonts
- **Protocol-Based Design**: Flexible, testable implementations
- **Preview Support**: SwiftUI previews using PreviewUIView helpers

### Component Structure (Per Component)
```
ComponentName/
├── ComponentNameViewModelProtocol.swift
├── ComponentNameView.swift
├── MockComponentNameViewModel.swift
└── Documentation/
    └── README.md
```

## Data Models

### Core Data Structures
```swift
// Casino Game Data
public struct CasinoGameData: Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let provider: String
    public let imageURL: String?
    public let rating: Double
    public let minStake: String
    public let isNew: Bool
    public let category: String
}

// Category Data
public struct CasinoCategoryData: Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let gameCount: Int
    public let games: [CasinoGameData]
}

// Recently Played Data
public struct CasinoRecentlyPlayedData: Equatable {
    public let games: [CasinoGameData]
    public let lastPlayedDates: [String: Date] // Game ID to date mapping
}
```

## Implementation Strategy

### Phase 1: Leaf Components
1. Create `CasinoGameCardView` first (most fundamental)
2. Create `CasinoCategoryHeaderView` 
3. Test both components independently

### Phase 2: Container Components  
4. Create `CasinoGameCollectionViewCell` (simple wrapper)
5. Create `CasinoCategoryScrollView` (uses game cards)
6. Create `CasinoRecentlyPlayedView` (uses game cards)

### Phase 3: Integration Testing
7. Test all components together in preview environment
8. Validate design consistency with Figma specs
9. Performance testing with realistic data

## Styling Guidelines

### Colors (Via StyleProvider)
- **Card Backgrounds**: `StyleProvider.Color.backgroundColor`
- **Text Primary**: `StyleProvider.Color.textPrimary`  
- **Text Secondary**: `StyleProvider.Color.textSecondary`
- **Orange Accent**: `StyleProvider.Color.primaryColor` (for buttons)
- **Border/Shadow**: `StyleProvider.Color.borderColor`

### Typography (Via StyleProvider)
- **Game Titles**: `StyleProvider.fontWith(type: .bold, size: 16)`
- **Provider Names**: `StyleProvider.fontWith(type: .regular, size: 14)`
- **Min Stakes**: `StyleProvider.fontWith(type: .regular, size: 12)`
- **Category Headers**: `StyleProvider.fontWith(type: .bold, size: 18)`

### Layout Constants
- **Card Corner Radius**: 12pt
- **Card Margins**: 12pt horizontal, 8pt vertical
- **Internal Padding**: 16pt
- **Star Rating Size**: 16pt per star
- **Button Height**: 32pt minimum

## Reusability Requirements

### Cross-Context Usage
- **CasinoGameCardView**: Must work in any container (lists, grids, scrollviews)
- **CasinoCategoryHeaderView**: Reusable for any game category
- **Collection Components**: Configurable item sizes and spacing

### Data Flexibility
- Support for missing data (optional images, ratings)
- Graceful degradation when network images fail
- Placeholder states for loading content

## Testing Strategy

### Preview States
Each component should have previews showing:
- **Default State**: Normal appearance with sample data
- **Loading State**: While data is being fetched
- **Error State**: When data fails to load
- **Empty State**: When no games are available
- **Multiple States**: Different configurations side-by-side

### Mock Data Requirements
- Realistic game names and providers
- Various rating values (1-5 stars)
- Different stake amounts and currencies
- Mix of new and existing games
- Various image URLs (some working, some broken for testing)

## Success Criteria

### Visual Fidelity
- [ ] Matches Figma designs pixel-perfectly
- [ ] Consistent styling across all components
- [ ] Smooth animations and transitions
- [ ] Proper handling of dynamic content

### Technical Quality
- [ ] Follows GomaUI architectural patterns
- [ ] Comprehensive test coverage via mock view models
- [ ] Proper memory management (no retain cycles)
- [ ] Accessibility support (VoiceOver, Dynamic Type)

### Performance
- [ ] Smooth scrolling in collection views
- [ ] Efficient image loading and caching
- [ ] Minimal layout passes during updates
- [ ] Good performance with 100+ games

This overview serves as the foundation for detailed component specifications that follow.