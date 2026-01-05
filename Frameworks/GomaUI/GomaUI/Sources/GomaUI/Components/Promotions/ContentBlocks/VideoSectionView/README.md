# VideoSectionView

A full-height video section with AVPlayer integration and tap-to-play/pause control.

## Overview

VideoSectionView displays a video player with a fixed 400pt height, featuring a centered play/pause button overlay. The component handles app lifecycle events to pause video when entering background and resets to the beginning when playback completes. Used for prominent video content sections in promotional or onboarding screens.

## Component Relationships

### Used By (Parents)
- Promotional screens
- Welcome/onboarding flows
- Full-screen content sections

### Uses (Children)
- None (uses AVFoundation directly)

## Features

- AVPlayer video playback
- Fixed 400pt height
- Tap-to-play/pause interaction
- Centered play/pause button overlay
- Background app state handling
- Video end detection with reset
- Clear background for overlay compositions

## Usage

```swift
let viewModel = MockVideoSectionViewModel.defaultMock
let videoSection = VideoSectionView(viewModel: viewModel)

// Control playback programmatically
videoSection.play()
videoSection.pause()

// With valid video URL
let validViewModel = MockVideoSectionViewModel.validUrlMock
let validVideo = VideoSectionView(viewModel: validViewModel)

// Handle nil URL gracefully
let invalidViewModel = MockVideoSectionViewModel.invalidUrlMock
let noVideoSection = VideoSectionView(viewModel: invalidViewModel)
```

## Data Model

```swift
protocol VideoSectionViewModelProtocol {
    var videoURL: URL? { get }
}
```

## Styling

Layout constants:
- Video height: 400pt (fixed)
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
MockVideoSectionViewModel(videoURL: URL?)
```
