# MultiWidgetToolbarView

A configurable multi-line toolbar with dynamic widgets for logged-in and logged-out states.

## Overview

MultiWidgetToolbarView displays a configurable toolbar with multiple widget types arranged in lines. It supports two layout modes: flex (widgets sized by content) and split (widgets sized equally). The toolbar dynamically switches between logged-in and logged-out configurations, showing wallet/avatar for authenticated users or login/register buttons for guests.

## Component Relationships

### Used By (Parents)
- Main app navigation header
- Home screen header

### Uses (Children)
- `WalletWidgetView` - wallet balance and deposit button

## Features

- Multi-line widget layout
- Two layout modes: flex and split
- Logged-in state (logo, wallet, avatar)
- Logged-out state (logo, support, language, login/register buttons)
- Widget types: image, wallet, avatar, support, language switcher, buttons, space
- Brand logo with secret tap (6x tap for debug screen)
- Widget selection callbacks
- Balance and deposit tap callbacks
- Dynamic wallet balance updates
- JSON-based configuration support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
let toolbar = MultiWidgetToolbarView(viewModel: viewModel)

// Widget selection callback
toolbar.onWidgetSelected = { widgetId in
    switch widgetId {
    case .avatar: navigateToProfile()
    case .support: openSupport()
    case .languageSwitcher: showLanguageSelector()
    case .loginButton: showLogin()
    case .joinButton: showRegistration()
    default: break
    }
}

toolbar.onBalanceTapped = { _ in showWalletDetails() }
toolbar.onDepositTapped = { _ in showDeposit() }
toolbar.onLogoSecretTapped = { showDebugScreen() }

// Change login state
toolbar.setLoggedInState(true)
viewModel.setWalletBalance(balance: 1500.00)
```

## Data Model

```swift
enum WidgetType: String, Codable {
    case image
    case wallet
    case avatar
    case support
    case languageSwitcher
    case button
    case loginButton
    case signUpButton
    case space
}

enum WidgetTypeIdentifier: String, Codable, Equatable, Hashable {
    case logo
    case wallet
    case avatar
    case support
    case languageSwitcher = "language"
    case loginButton
    case joinButton
    case flexSpace
    case search
    case notifications
    case registerButton
}

struct Widget: Codable, Equatable, Hashable {
    let id: WidgetTypeIdentifier
    let type: WidgetType
    let src: String?
    let alt: String?
    let route: String?
    let container: String?
    let label: String?
    let icon: String?
    let details: [WidgetDetail]?
}

enum LayoutMode: String, Codable, Equatable, Hashable {
    case flex   // Widgets sized by content
    case split  // Widgets sized equally
}

enum LayoutState: String, Codable, Equatable {
    case loggedIn
    case loggedOut
}

struct MultiWidgetToolbarDisplayState: Equatable {
    let lines: [LineDisplayData]
    let currentState: LayoutState
}

protocol MultiWidgetToolbarViewModelProtocol {
    var displayStatePublisher: AnyPublisher<MultiWidgetToolbarDisplayState, Never> { get }
    var walletViewModel: WalletWidgetViewModelProtocol? { get set }

    func selectWidget(id: WidgetTypeIdentifier)
    func setLayoutState(_ state: LayoutState)
    func setWalletBalance(balance: Double)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.topBarGradient1` - toolbar background
- `StyleProvider.Color.highlightPrimaryContrast` - logo/icon tint
- `StyleProvider.Color.allWhite` - support icon, language text
- `StyleProvider.Color.buttonBackgroundPrimary` - sign up button background
- `StyleProvider.Color.buttonTextPrimary` - sign up button text
- `StyleProvider.Color.buttonTextSecondary` - login button text/border
- `StyleProvider.fontWith(type: .medium, size: 14)` - language label font
- `StyleProvider.fontWith(type: .medium, size: 20)` - button title font

Layout constants:
- Container padding: 16pt horizontal, 15pt vertical
- Line spacing: 14pt
- Widget spacing: 6pt (flex), 12pt (split)
- Line height: 40pt
- Logo height: 32pt
- Avatar/support size: 32pt x 32pt
- Button height: 56pt
- Button corner radius: 6pt
- Icon corner radius: 16pt

Widget sizing:
- **Space widget**: Low hugging, expands to fill
- **Other widgets (flex)**: Required hugging, sized by content
- **All widgets (split)**: Equal width distribution

## Mock ViewModels

Available presets:
- `.defaultMock` - Standard configuration with logo, wallet, avatar (logged in) or logo, support, language, login/join (logged out)
- `.complexMock` - Extended with search and notifications widgets
