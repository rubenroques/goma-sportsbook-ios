# ImageBlockView

A simple image display component for promotional content blocks.

## Overview

ImageBlockView displays a single image with rounded corners, centered horizontally with padding. It's designed for promotional content, banner images, or any image that needs to be displayed within a content block with consistent styling.

## Component Relationships

### Used By (Parents)
- None (standalone image block component)

### Uses (Children)
- None (leaf component)

## Features

- Centered image with horizontal padding
- 8pt corner radius on image
- Aspect fill content mode with clipping
- Clear background
- URL-based image source
- 15pt horizontal padding (minimum)
- 5pt vertical padding

## Usage

```swift
let viewModel = MockImageBlockViewModel.defaultMock
let imageBlockView = ImageBlockView(viewModel: viewModel)

// With custom URL
let customViewModel = MockImageBlockViewModel(imageUrl: "https://example.com/promo.jpg")
let customView = ImageBlockView(viewModel: customViewModel)
```

## Data Model

```swift
protocol ImageBlockViewModelProtocol {
    var imageUrl: String { get }
}
```

## Styling

Layout constants:
- Image corner radius: 8pt
- Horizontal padding: 15pt (minimum, image centered)
- Vertical padding: 5pt top and bottom
- Content mode: scaleAspectFill
- Background: clear

Note: Currently uses placeholder system image. In production, integrate with Kingfisher or similar image loading library for URL-based images.

## Mock ViewModels

Available presets:
- `.defaultMock` - example promo image URL
- `.validUrlMock` - picsum.photos test URL (400x200)
- `.invalidUrlMock` - invalid URL for testing error states
