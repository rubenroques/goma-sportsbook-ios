# VideoBlockView

A video player block with play/pause overlay for CMS promotional content.

## Overview

VideoBlockView displays a video player with AVPlayer integration, featuring a centered play/pause button overlay. The component automatically calculates video dimensions to maintain aspect ratio and supports tap-to-play/pause interaction. It handles app lifecycle events to pause video when entering background. Used in CMS stack-based layouts for promotional video content.

## Component Relationships

### Used By (Parents)
- `StackViewBlockView` - CMS block containers
- Promotional screens
- Welcome/onboarding flows

### Uses (Children)
- None (uses AVFoundation directly)

## Features

- AVPlayer video playback
- Tap-to-play/pause interaction
- Centered play/pause button overlay
- Automatic aspect ratio calculation
- Background app state handling
- Video end detection with reset
- Dynamic height based on video dimensions
- Clear background for overlay compositions

## Usage

```swift
let viewModel = MockVideoBlockViewModel.defaultMock
let videoBlock = VideoBlockView(viewModel: viewModel)

// Control playback programmatically
videoBlock.play()
videoBlock.pause()

// With valid video URL
let validViewModel = MockVideoBlockViewModel.validUrlMock
let validVideo = VideoBlockView(viewModel: validViewModel)

// Handle nil URL gracefully
let invalidViewModel = MockVideoBlockViewModel.invalidUrlMock
let noVideoBlock = VideoBlockView(viewModel: invalidViewModel)
```

## Data Model

```swift
protocol VideoBlockViewModelProtocol {
    var videoURL: URL? { get }
}
```

## Styling

Layout constants:
- Default video height: 250pt
- Max video height: 500pt
- Container horizontal padding: 15pt
- Container vertical padding: 5pt
- Play button size: 50pt x 50pt
- Play button corner radius: 25pt (circular)

Play/pause button:
- Icon: SF Symbol "play.fill"
- Tint: white
- Background: black with 0.5 alpha
- Hidden when playing (alpha = 0)
- Visible when paused (alpha = 1)

Video container:
- Clear background
- Clips to bounds
- User interaction enabled

Video gravity: `.resizeAspectFill`

## App Lifecycle Handling

- **Background**: Automatically pauses video
- **Foreground**: Does not auto-resume (manual control)
- **Video End**: Seeks to beginning, shows play button

## Mock ViewModels

Available presets:
- `.defaultMock` - Sample 720p video URL
- `.validUrlMock` - Big Buck Bunny sample video
- `.invalidUrlMock` - nil URL (no video)

Factory initialization:
```swift
MockVideoBlockViewModel(videoURL: URL?)
```

## Video Loading

The component asynchronously loads video track metadata to:
1. Determine natural video size
2. Apply rotation transform
3. Calculate aspect ratio
4. Set height constraint maintaining ratio
5. Fall back to default height on error
