# TextSectionView

A simple title and description text section with customizable styling.

## Overview

TextSectionView displays a vertical layout with a bold title label above a regular description label. It supports full customization of fonts, colors, and spacing through the content model. The component is used for informational sections, disclaimers, and descriptive content blocks throughout the app.

## Component Relationships

### Used By (Parents)
- Information screens
- Settings sections
- Footer areas

### Uses (Children)
- None (leaf component)

## Features

- Title label with customizable font and color
- Description label with customizable font and color
- Configurable vertical spacing between labels
- Multiline support for both labels
- Dynamic content updates
- Reactive updates via Combine publishers

## Usage

```swift
let content = TextSectionContent(
    title: "One bet too many?",
    description: "We want our players to have fun while gaming at Betsson..."
)
let viewModel = MockTextSectionViewModel(content: content)
let sectionView = TextSectionView(viewModel: viewModel)

// Custom styling
let customContent = TextSectionContent(
    title: "Important Notice",
    description: "Please read carefully before proceeding.",
    titleTextColor: StyleProvider.Color.alertError,
    descriptionTextColor: StyleProvider.Color.textSecondary,
    titleFont: StyleProvider.fontWith(type: .semibold, size: 16),
    descriptionFont: StyleProvider.fontWith(type: .regular, size: 14),
    spacing: 8
)
let customView = TextSectionView(viewModel: MockTextSectionViewModel(content: customContent))

// Update content dynamically
viewModel.update(content: newContent)
```

## Data Model

```swift
struct TextSectionContent {
    let title: String
    let description: String
    let titleTextColor: UIColor
    let descriptionTextColor: UIColor
    let titleFont: UIFont
    let descriptionFont: UIFont
    let spacing: CGFloat
}

protocol TextSectionViewModelProtocol {
    var contentPublisher: AnyPublisher<TextSectionContent, Never> { get }
}
```

## Styling

Default StyleProvider properties:
- `StyleProvider.Color.textPrimary` - default title and description color
- `StyleProvider.fontWith(type: .bold, size: 12)` - default title font
- `StyleProvider.fontWith(type: .regular, size: 12)` - default description font

Layout constants:
- Stack axis: vertical
- Stack alignment: fill
- Stack distribution: fill
- Default spacing: 4pt
- Number of lines: 0 (unlimited for both labels)

All styling properties are customizable via TextSectionContent.

## Mock ViewModels

Available presets:
- `.default` - Responsible gambling message with standard styling

Factory methods:
- `custom(title:description:titleColor:descriptionColor:titleFont:descriptionFont:spacing:)` - Fully customizable

Methods:
- `update(content:)` - Update content reactively
