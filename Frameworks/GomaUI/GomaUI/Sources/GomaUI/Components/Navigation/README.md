# Navigation Components

This folder contains UI components for app navigation, tab bars, and toolbars.

## Components

| Component | Description |
|-----------|-------------|
| `AdaptiveTabBarView` | Dynamic tab bar with multiple configurations and nested navigation |
| `QuickLinksTabBar` | Simple horizontal bar with tap actions for quick access |
| `CustomNavigationView` | Customizable navigation bar with back button and title |
| `SimpleNavigationBarView` | Simple navigation bar with back button and optional title |
| `NavigationActionView` | Interactive navigation action button with icons and states |
| `MultiWidgetToolbarView` | Highly configurable toolbar with various widgets |

## Usage

These components are used in:
- Main tab bar navigation
- Screen headers
- Quick access toolbars
- Custom navigation flows

## Component Hierarchy

```
AdaptiveTabBarView (composite)
└── Tab items with icons and labels

MultiWidgetToolbarView (composite)
└── Multiple widget configurations
```

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
