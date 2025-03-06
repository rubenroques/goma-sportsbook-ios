# MixMatch Feature Implementation

## Overview

Based on the analysis of the codebase, MixMatch functionality is present in multiple parts of the application and has been implemented as a `SportsbookTargetFeature`. This document outlines how MixMatch has been implemented as a feature that can be enabled/disabled per target.

## Implementation Details

MixMatch functionality is related to custom betting options and is referenced in:

1. Home screen templates (`.topImageWithMixMatch` widget type)
2. Match details screens
3. Betslip functionality
4. Betting tickets
5. SportRadar provider implementation

### 1. Feature Flag Definition

The MixMatch feature is defined as a case in the `SportsbookTargetFeatures` enum in `Core/Protocols/ClientsProtocols/SportsbookTarget.swift`:

```swift
enum SportsbookTargetFeatures: Codable, CaseIterable {
    // Existing cases...
    
    // MixMatch feature
    case mixMatch
}
```

### 2. Feature Flag Configuration

The MixMatch feature is enabled in both UAT and PROD target variables files:

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

### 3. UI Components Implementation

The UI components have been updated to check for the MixMatch feature before showing MixMatch-related UI:

#### HomeViewController.swift

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

#### Home Screen Templates

```swift
// When determining widget type
var type = MatchWidgetType.topImage
if (match.markets.first?.customBetAvailable ?? false) && TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
    type = .topImageWithMixMatch
}
```

#### MatchDetailsViewController.swift

```swift
if self.showMixMatchDefault && TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
    self.currentPageViewControllerIndex = 1
}
```

#### MarketWidgetContainerTableViewCell.swift

```swift
cell.tappedMixMatchAction = { [weak self] matchId in
    if TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
        self?.tappedMixMatchIdAction(matchId)
    } else {
        // If MixMatch is not enabled, use the regular match action instead
        self?.tappedMatchIdAction(matchId)
    }
}
```

#### BetBuilderBettingTicketDataSource.swift

```swift
cell.configureWithBettingTicket(bettingTicket,
                                showInvalidView: isInvalid,
                                mixMatchMode: TargetVariables.hasFeatureEnabled(feature: .mixMatch))
```

#### PreSubmissionBetslipViewController.swift

```swift
// Only show MixMatch UI if the feature is enabled
self?.mixMatchWinningsBaseView.isHidden = !TargetVariables.hasFeatureEnabled(feature: .mixMatch)
```

### 4. Dynamic BetslipType Enum

The `BetslipType` enum has been updated to support dynamic feature toggling:

```swift
enum BetslipType: CaseIterable {
    case simple
    case multiple
    case system
    case betBuilder

    // Other properties...

    static var availableCases: [BetslipType] {
        if TargetVariables.hasFeatureEnabled(feature: .mixMatch) {
            return BetslipType.allCases
        } else {
            return BetslipType.allCases.filter { $0 != .betBuilder }
        }
    }
    
    static func indexFor(_ type: BetslipType) -> Int? {
        return BetslipType.availableCases.firstIndex(of: type)
    }
}
```

### 5. ServicesProvider Module Implementation

Since the `TargetVariables` class is not available in the ServicesProvider module, a different approach was used:

1. Added `isMixMatchEnabled` property to `SportRadarEventsProvider` class
2. Added `isMixMatchEnabled` property to `BettingConnector` class
3. Added `setMixMatchFeatureEnabled` method to `SportRadarBettingProvider` class
4. Added `setMixMatchFeatureEnabled` method to `Client` class
5. Updated `Environment.swift` to set the MixMatch feature flag on the `Client` instance

#### Client.swift

```swift
public func setMixMatchFeatureEnabled(_ enabled: Bool) {
    if let eventsProvider = self.eventsProvider as? SportRadarEventsProvider {
        eventsProvider.isMixMatchEnabled = enabled
    }
    
    if let bettingProvider = self.bettingProvider as? SportRadarBettingProvider {
        bettingProvider.setMixMatchFeatureEnabled(enabled)
    }
}
```

#### Environment.swift

```swift
// Set feature flags
client.setMixMatchFeatureEnabled(TargetVariables.hasFeatureEnabled(feature: .mixMatch))
```

## Maintenance Guidelines

When maintaining the MixMatch feature, keep the following in mind:

1. **Adding New MixMatch Functionality**
   - Always check if the MixMatch feature is enabled before showing MixMatch UI or enabling MixMatch functionality
   - Use `TargetVariables.hasFeatureEnabled(feature: .mixMatch)` to check if the feature is enabled

2. **Updating ServicesProvider Module**
   - The ServicesProvider module does not have access to `TargetVariables`, so the feature flag is passed from the app to the module
   - If you add new MixMatch functionality to the ServicesProvider module, make sure to check the `isMixMatchEnabled` property

3. **Testing**
   - Test that MixMatch functionality works correctly when the feature is enabled
   - Test that MixMatch functionality is properly disabled when the feature is not enabled
   - Test that the feature can be toggled at runtime using the developer settings

## Conclusion

The MixMatch feature has been successfully implemented as a feature flag in the codebase. The implementation follows the established pattern for feature flags in the application and ensures that MixMatch functionality is only available when the feature is enabled. The changes were made with minimal impact to the existing codebase and should be easy to maintain going forward. 