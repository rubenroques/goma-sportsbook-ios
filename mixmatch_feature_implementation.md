# MixMatch Feature Implementation

## Overview

Based on the analysis of the codebase, MixMatch functionality is present in multiple parts of the application but is not currently defined as a `SportsbookTargetFeature`. This document outlines how to properly implement MixMatch as a feature that can be enabled/disabled per target.

## Current Implementation

MixMatch functionality appears to be related to custom betting options and is referenced in:

1. Home screen templates (`.topImageWithMixMatch` widget type)
2. Match details screens
3. Betslip functionality
4. Betting tickets
5. SportRadar provider implementation

## Required Changes

### 1. Add MixMatch to SportsbookTargetFeatures

Add a new case to the `SportsbookTargetFeatures` enum in `Core/Protocols/ClientsProtocols/SportsbookTarget.swift`:

```swift
enum SportsbookTargetFeatures: Codable, CaseIterable {
    // Existing cases...
    case homeBanners
    case homePopUps
    
    case getLocationLimits
    
    case favoriteEvents
    case favoriteCompetitions
    
    case eventStats
    case eventListFilters
    
    case betsNotifications
    case eventsNotifications
    
    case chat
    case tips
    
    case suggestedBets
    case cashout
    case cashback
    case freebets
    
    case casino
    
    case responsibleGamingForm
    case legalAgeWarning
    
    // New case for MixMatch
    case mixMatch
}
```

### 2. Update Target Variables Files

Update the `features` array in both UAT and PROD target variables files to include the MixMatch feature:

#### TargetVariables-UAT.swift

```swift
static var features: [SportsbookTargetFeatures] {
    return [.cashback, .legalAgeWarning, .mixMatch]
}
```

#### TargetVariables-PROD.swift

```swift
static var features: [SportsbookTargetFeatures] {
    return [.cashback, .mixMatch]
}
```

### 3. Conditional Feature Implementation

Update relevant parts of the code to check for the MixMatch feature before enabling related functionality:

#### Example in HomeViewController:

```swift
private func openMatchDetails(matchId: String, isMixMatch: Bool = false) {
    // Only enable MixMatch if the feature is enabled
    let showMixMatch = isMixMatch && TargetVariables.hasFeatureEnabled(feature: .mixMatch)
    
    let matchDetailsViewController = MatchDetailsViewController()
    let matchDetailsViewModel = MatchDetailsViewModel(matchId: matchId)
    
    if showMixMatch {
        matchDetailsViewController.showMixMatchDefault = true
        matchDetailsViewModel.showMixMatchDefault = true
    }
    
    // Rest of the implementation...
}
```

#### Example in MatchWidgetType:

```swift
// When determining widget type
var type = MatchWidgetType.topImage
if match.markets.first?.customBetAvailable ?? false && TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
    type = .topImageWithMixMatch
}
```

## Testing

After implementing these changes, you should test:

1. That MixMatch functionality works correctly when the feature is enabled
2. That MixMatch functionality is properly disabled when the feature is not enabled
3. That the feature can be toggled at runtime using the developer settings (if applicable)

## Conclusion

Adding MixMatch as a `SportsbookTargetFeature` will allow for better control over this functionality across different environments and clients. It follows the existing pattern used for other features in the application and ensures consistent behavior. 