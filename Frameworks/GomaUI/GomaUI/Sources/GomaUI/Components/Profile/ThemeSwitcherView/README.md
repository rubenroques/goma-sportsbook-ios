# ThemeSwitcherView

A segmented control for switching between Light, System, and Dark themes.

## Overview

ThemeSwitcherView provides a three-segment horizontal control for selecting app theme mode. Each segment displays an icon (sun, lightbulb, moon) with a localized label. The selected segment is indicated by a sliding highlight background that animates on selection change. The component is used in settings screens for theme preference selection.

## Component Relationships

### Used By (Parents)
- Settings screens
- Theme preference panels

### Uses (Children)
- `ThemeSegmentView` (internal helper for each segment)

## Features

- Three theme modes: Light, System, Dark
- SF Symbol icons for each mode
- Animated sliding selection indicator
- Localized segment labels
- Rounded container with primary background
- Theme selection callback
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockThemeSwitcherViewModel.defaultMock
let themeSwitcher = ThemeSwitcherView(viewModel: viewModel)

// Custom initial theme
let darkVM = MockThemeSwitcherViewModel.darkThemeMock
let darkSwitcher = ThemeSwitcherView(viewModel: darkVM)

// With callback
let callbackVM = MockThemeSwitcherViewModel.customCallbackMock(
    initialTheme: .light
) { theme in
    applyTheme(theme)
}
let callbackSwitcher = ThemeSwitcherView(viewModel: callbackVM)
```

## Data Model

```swift
enum ThemeMode: String, CaseIterable {
    case light = "light"
    case system = "system"
    case dark = "dark"

    var displayName: String    // Localized
    var iconName: String       // SF Symbol name
}

protocol ThemeSwitcherViewModelProtocol {
    var selectedThemePublisher: AnyPublisher<ThemeMode, Never> { get }

    func selectTheme(_ theme: ThemeMode)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.highlightPrimary` - selection indicator

Layout constants:
- Container height: 31pt
- Container corner radius: 8pt
- Stack spacing: 0pt
- Stack distribution: fill (equal segments)

Segment icons (SF Symbols):
- Light: "sun.max.fill"
- System: "lightbulb.fill"
- Dark: "moon.fill"

Animation:
- Selection indicator slides with 0.2s animation
- Segment selection updates icon/text appearance

## Mock ViewModels

Available presets:
- `.defaultMock` - Starts with System theme
- `.lightThemeMock` - Starts with Light theme
- `.darkThemeMock` - Starts with Dark theme
- `.interactiveMock` - Demo with console feedback

Factory methods:
- `.customCallbackMock(initialTheme:onThemeSelected:)` - Custom callback

Methods:
- `selectTheme(_ theme:)` - Select a theme mode
- `setInitialTheme(_ theme:)` - Update initial theme for testing
