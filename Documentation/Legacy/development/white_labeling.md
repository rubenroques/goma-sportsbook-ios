# White-Labeling Guide for GOMA Sportsbook iOS

## Overview

The GOMA Sportsbook iOS application is designed with a comprehensive white-labeling architecture that allows for creating multiple branded versions of the app from a single codebase. This guide explains the white-labeling approach, architecture, and implementation process.

## White-Labeling Architecture

The white-labeling strategy is built on several key architectural components:

```
┌─────────────────────────────────────────────────────────────────┐
│                     Core Shared Components                      │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────┐  │
│  │ Core Logic  │  │ Base UI     │  │ Services    │  │ Tools  │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│               Client Customization Components                   │
│                                                                 │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────┐  ┌────────┐  │
│  │ Client      │  │ Theme      │  │ Configuration│  │ Assets │  │
│  │ Variables   │  │ Overrides  │  │ Settings     │  │        │  │
│  └─────────────┘  └────────────┘  └──────────────┘  └────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Different Brand Implementations                 │
│                                                                 │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │ Brand A    │  │ Brand B    │  │ Brand C    │  │ Brand D    │ │
│  │ App Target │  │ App Target │  │ App Target │  │ App Target │ │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 1. Core Framework

The Core Framework provides functionality shared across all client implementations:

- Business logic
- Base UI components
- Service integrations
- Utilities and helpers

### 2. Client Layer

Each client implementation resides in the `Clients` directory and represents a specific branded version of the app:

- **ATP**: Tennis-focused client
- **Betsson**: Betting operator implementation
- **Crocobet**: Georgian market implementation
- **DAZN**: Sports streaming service integration
- **EveryMatrix**: Betting platform
- **GOMASports**: Main implementation
- **SportRadar**: Sports data provider implementation
- **Showcase**: Demo client (template for new clients)

## Customization Points

The white-labeling system allows for customization at several levels:

### 1. Visual Customization

- **Colors**: Client-specific color schemes
- **Fonts**: Custom typography
- **Assets**: Client-specific images, icons, and visual resources
- **Layout**: Minor layout adjustments

### 2. Functional Customization

- **Feature Flags**: Enabling or disabling specific features
- **Service Configuration**: API endpoints, parameters, and capabilities
- **Content Filtering**: Showing or hiding specific sports, markets, or promotions
- **User Experience**: Adjusting flows and interactions

### 3. Environment Customization

- **Development** (DEV): Development environment settings
- **User Acceptance Testing** (UAT): Testing environment settings
- **Production** (PROD): Live environment settings

## Implementation Structure

### Client Directory Structure

Each client has a standard structure:

```
Clients/[ClientName]/
├── Assets/
│   ├── ClientAssets.xcassets
│   └── [ClientName].xcassets
├── ClientVariables.swift
├── LaunchScreen/
│   ├── LaunchScreen.storyboard
│   └── LaunchScreenViewController.swift
├── Misc-PROD/
│   ├── Info.plist
│   └── Configuration files
├── Misc-UAT/
│   ├── Info.plist
│   └── Configuration files
├── TargetVariables-PROD.swift
└── TargetVariables-UAT.swift
```

### Key Configuration Files

#### ClientVariables.swift

This file defines client-specific variables that override the default Core values:

```swift
import Core
import UIKit
import Foundation

extension ClientVariable {
    
    // App identity
    static let appName = "Brand Name Sportsbook"
    static let appId = "com.brand.sportsbook"
    
    // Visual styling
    static let brandPrimaryColor = UIColor(hex: "#FF5500")
    static let brandSecondaryColor = UIColor(hex: "#004477")
    
    // Feature flags
    static let enableCasino = true
    static let enableLiveBetting = true
    static let enableBetBuilder = true
    
    // Configuration parameters
    static let defaultSportFilter = SportType.football
    static let defaultOddsFormat = OddsFormat.decimal
    
    // Custom client functions
    static func customOnboarding() -> Bool {
        return true
    }
}
```

#### TargetVariables-[ENV].swift

Environment-specific variables for each build configuration:

```swift
import Foundation
import Core

extension TargetVariables {
    
    // API endpoints
    static let apiBaseURL = "https://api-prod.brand.com"
    static let websocketURL = "wss://ws-prod.brand.com"
    
    // Authentication settings
    static let authTokenLifetime: TimeInterval = 3600
    
    // Analytics
    static let analyticsEnabled = true
    static let analyticsKey = "prod-analytics-key"
    
    // Other environment-specific settings
    static let cacheExpiryTime: TimeInterval = 300
}
```

## Theming System

The theming system allows for brand-specific visual styling:

### Theme.swift

```swift
import UIKit

struct Theme {
    // Colors
    static var primaryColor: UIColor {
        return ClientVariable.brandPrimaryColor
    }
    
    static var secondaryColor: UIColor {
        return ClientVariable.brandSecondaryColor
    }
    
    // Typography
    static var headingFont: UIFont {
        return ClientVariable.customFontEnabled ? 
               UIFont(name: ClientVariable.headingFontName, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold) :
               UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    // Metrics
    static var standardCornerRadius: CGFloat {
        return ClientVariable.standardCornerRadius
    }
    
    // Apply theme to common UI elements
    static func applyTheme() {
        // Apply global UI styles
        UINavigationBar.appearance().tintColor = primaryColor
        UITabBar.appearance().tintColor = primaryColor
        // More global styling
    }
}
```

## Creating a New Client

Follow these steps to create a new white-labeled client:

### 1. Duplicate the Showcase Template

```bash
cp -R Clients/Showcase Clients/NewBrandName
```

### 2. Update Client Information

Edit the `ClientVariables.swift` file with the new brand's details:

```swift
static let appName = "New Brand Sportsbook"
static let appId = "com.newbrand.sportsbook"
```

### 3. Customize Visual Assets

- Replace images in the Assets folder
- Update the app icon and launch screen
- Adjust colors, fonts, and theme elements

### 4. Configure Environment Variables

Update the `TargetVariables-PROD.swift` and `TargetVariables-UAT.swift` files with the appropriate settings for each environment.

### 5. Adjust Feature Flags

Enable or disable features based on the client's requirements:

```swift
static let enableCasino = false
static let enableLiveBetting = true
```

### 6. Create Build Configuration

Add the new client to the Xcode project by:

1. Creating a new target using the existing target as a template
2. Setting the bundle identifier
3. Configuring provisioning profiles
4. Setting the correct Info.plist file
5. Adding the client-specific build settings

## Best Practices for White-Labeling

### 1. Feature Detection

Always use feature flags to detect and enable/disable features:

```swift
if ClientVariable.enableFeatureX {
    // Implement feature X
} else {
    // Alternative implementation or hide the feature
}
```

### 2. Theme Consistency

Always reference theme properties rather than hard-coding values:

```swift
// GOOD
button.backgroundColor = Theme.primaryColor

// BAD
button.backgroundColor = UIColor(hex: "#FF5500")
```

### 3. Asset Naming

Use descriptive and consistent naming for assets across all clients:

```swift
// GOOD
let icon = UIImage(named: "icon_home_betting")

// BAD
let icon = UIImage(named: "homeBetIcon")
```

### 4. String Localization

Use localization keys for all user-facing strings:

```swift
// GOOD
label.text = NSLocalizedString("betting.place_bet_button", comment: "Text for the place bet button")

// BAD
label.text = "Place Bet"
```

### 5. Client-Specific Logic

Isolate client-specific logic in extensions or specific files:

```swift
// In ClientSpecificLogic.swift
extension RegistrationViewController {
    func clientSpecificValidation() -> Bool {
        // Custom validation logic for this client
        return true
    }
}
```

## Testing White-Labeled Builds

### 1. Visual Inspection Testing

- Verify all branded elements appear correctly
- Check for any Core styling that might override client styling
- Test in different device sizes and orientations

### 2. Functional Testing

- Verify all features are correctly enabled/disabled
- Test client-specific functionality
- Verify API endpoints are correctly configured

### 3. Regression Testing

- Ensure changes to the Core don't break client implementations
- Test all clients after major Core updates

## Troubleshooting White-Label Issues

### Common Issues and Solutions

1. **Theme Not Applied**: Ensure `Theme.applyTheme()` is called at app startup
2. **Assets Missing**: Verify asset catalogs are properly included in the build
3. **Feature Flag Inconsistencies**: Check for conflicting feature flag definitions
4. **Environment Configuration**: Verify the correct environment variables are loaded 