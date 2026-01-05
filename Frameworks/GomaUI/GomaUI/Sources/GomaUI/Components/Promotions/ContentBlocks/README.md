# Promotions Content Blocks

This folder contains reusable UI components designed for rendering CMS-driven rich content in promotion detail pages. These components work together to display dynamic content sections including text, images, videos, lists, and action buttons.

## Primary Usage

These components are used by `PromotionDetailViewController` (in BetssonCameroonApp) to render `StaticPage` content sections. The CMS provides structured content that maps to these block types, allowing flexible promotion page layouts without code changes.

## Component Hierarchy

```
StackViewBlockView (container)
    |
    +-- TitleBlockView (leaf)
    +-- DescriptionBlockView (leaf)
    +-- ImageBlockView (leaf)
    +-- VideoBlockView (leaf)
    +-- ActionButtonBlockView (leaf)
    +-- BulletItemBlockView (leaf)
    +-- ListBlockView (composite - contains other blocks)

ImageSectionView (standalone banner)
VideoSectionView (standalone banner)
GradientHeaderView (standalone header)
TextSectionView (standalone text section)
```

## Components

### Container Components

| Component | Description |
|-----------|-------------|
| `StackViewBlockView` | Vertical container that groups multiple content blocks with consistent spacing |

### Leaf Components (Content Blocks)

| Component | Description |
|-----------|-------------|
| `TitleBlockView` | Displays section titles with customizable alignment and highlight styling |
| `DescriptionBlockView` | Multi-line text component for promotional descriptions |
| `ImageBlockView` | Inline image with centered layout and rounded corners |
| `VideoBlockView` | Video player with play/pause controls and dynamic height |
| `ActionButtonBlockView` | CTA button with customizable title and action handling |
| `BulletItemBlockView` | Single bullet point with highlighted bullet symbol |

### Composite Components

| Component | Description |
|-----------|-------------|
| `ListBlockView` | List item container with optional icon/counter and nested content blocks |

### Section Components (Full-Width)

| Component | Description |
|-----------|-------------|
| `ImageSectionView` | Full-width banner image for header/separator sections |
| `VideoSectionView` | Full-width banner video with fixed height |
| `GradientHeaderView` | Gradient background header with centered title text |
| `TextSectionView` | Full-width text section component |

## Usage Example

```swift
// From PromotionDetailViewController.setupSections()

// Create content blocks for a text section
var blockViews = [UIView]()

// Add title
let titleViewModel = MockTitleBlockViewModel(title: "Welcome Bonus")
blockViews.append(TitleBlockView(viewModel: titleViewModel))

// Add description
let descViewModel = MockDescriptionBlockViewModel(description: "Get 100% up to...")
blockViews.append(DescriptionBlockView(viewModel: descViewModel))

// Add CTA button
let buttonViewModel = MockActionButtonBlockViewModel(
    title: "Claim Now",
    actionName: "claim",
    actionURL: "https://..."
)
blockViews.append(ActionButtonBlockView(viewModel: buttonViewModel))

// Wrap in container
let stackViewModel = MockStackViewBlockViewModel(views: blockViews)
let stackView = StackViewBlockView(viewModel: stackViewModel)
```

## Section Types

The components support three main section types from the CMS:

1. **Text Sections** (`.text`) - Use `StackViewBlockView` containing leaf blocks
2. **List Sections** (`.list`) - Use `ListBlockView` for numbered/icon lists
3. **Banner Sections** (`.banner`) - Use `ImageSectionView` or `VideoSectionView`

## Architecture

All components follow GomaUI's standard MVVM pattern:
- Protocol-driven ViewModels (`*ViewModelProtocol`)
- Mock implementations for testing and previews (`Mock*ViewModel`)
- Combine-based reactive bindings
- StyleProvider theming support
