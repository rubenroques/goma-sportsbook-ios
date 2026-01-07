# ImageSectionView

A full-width image section with dynamic aspect ratio preservation.

## Overview

ImageSectionView displays a full-width image that automatically adjusts its height to preserve the original image's aspect ratio. It uses Kingfisher for image loading and dynamically creates constraints based on the loaded image dimensions.

## Component Relationships

### Used By (Parents)
- None (standalone image section component)

### Uses (Children)
- None (leaf component, uses Kingfisher)

## Features

- Full-width image display (edge to edge)
- Dynamic height based on image aspect ratio
- Automatic aspect ratio calculation after image loads
- Kingfisher integration for async image loading
- Aspect fill content mode with clipping
- Clear background
- Constraint updates on image load

## Usage

```swift
let viewModel = MockImageSectionViewModel.defaultMock
let imageSectionView = ImageSectionView(viewModel: viewModel)

// With custom URL
let customViewModel = MockImageSectionViewModel(imageUrl: "https://example.com/hero-image.jpg")
let customView = ImageSectionView(viewModel: customViewModel)
```

## Data Model

```swift
protocol ImageSectionViewModelProtocol {
    var imageUrl: String { get }
}
```

## Styling

Layout constants:
- Leading/trailing: 0 (full width)
- Top/bottom: 0 (no padding)
- Content mode: scaleAspectFill
- Background: clear
- Height: dynamic based on image aspect ratio

## Implementation Details

The view calculates the aspect ratio when the image loads:
```swift
aspectRatio = image.size.width / image.size.height
```

Then creates a constraint:
```swift
height = width * (1 / aspectRatio)
```

This ensures the image displays at its natural proportions regardless of the container width.

## Mock ViewModels

Available presets:
- `.defaultMock` - example section image URL
- `.validUrlMock` - picsum.photos test URL (600x300)
- `.invalidUrlMock` - invalid URL for testing error states
