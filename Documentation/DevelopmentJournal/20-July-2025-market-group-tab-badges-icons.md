## Date
20 July 2025

### Project / Branch
sportsbook-ios / main (match details enhancement)

### Goals for this session
- Add badge count display to MarketGroupSelectorTabView items showing number of markets
- Implement icon display for BetBuilder and Fast market groups
- Integrate with existing ServicesProvider data structure

### Achievements
- [x] Analyzed ServicesProvider MarketGroup model structure for badge count data
- [x] Updated MatchDetailsMarketGroupSelectorTabViewModel with badge count calculation
- [x] Implemented icon type logic for isBetBuilder and isFast market group flags
- [x] Enhanced MarketGroupTabItemData creation with both badge and icon support
- [x] Leveraged existing AppMarketGroupTabImageResolver for bet_builder_info and most_popular_info icons

### Issues / Bugs Hit
- [ ] None encountered during implementation

### Key Decisions
- **Badge count priority**: Use `numberOfMarkets` property first, fallback to `markets?.count`
- **Icon precedence**: BetBuilder takes priority over Fast when both flags are true
- **Data integration**: Use real ServicesProvider data rather than hardcoded values
- **Architecture pattern**: Keep calculation logic in view model, UI resolution in image resolver

### Experiments & Notes
- GomaUI MarketGroupTabItemData already supported `badgeCount: Int?` and `iconTypeName: String?`
- AppMarketGroupTabImageResolver already had mappings for "betbuilder" → "bet_builder_info" and "fast" → "most_popular_info"
- ServicesProvider MarketGroup model contains `isBetBuilder: Bool?`, `isFast: Bool?`, and `numberOfMarkets: Int?`
- Property name changed from `iconType` to `iconTypeName` during implementation (noted in system reminder)

### Useful Files / Links
- [MatchDetailsMarketGroupSelectorTabViewModel](../Core/Screens/MatchDetailsTextual/MatchDetailsMarketGroupSelectorTabViewModel.swift) - Main implementation
- [AppMarketGroupTabImageResolver](../Core/Services/ImageResolvers/AppMarketGroupTabImageResolver.swift) - Icon resolution
- [MarketGroupTabItemViewModelProtocol](../GomaUI/GomaUI/Sources/GomaUI/Components/MarketGroupTabItemView/MarketGroupTabItemViewModelProtocol.swift) - Data model
- [MarketGroupSelectorTabView README](../GomaUI/GomaUI/Sources/GomaUI/Components/MarketGroupSelectorTabView/Documentation/README.md) - Component documentation

### Code Changes Made
```swift
// Added badge count calculation
private func calculateBadgeCount(for marketGroup: MarketGroup) -> Int? {
    if let numberOfMarkets = marketGroup.numberOfMarkets, numberOfMarkets > 0 {
        return numberOfMarkets
    }
    if let markets = marketGroup.markets, !markets.isEmpty {
        return markets.count
    }
    return nil
}

// Added icon type determination
private func determineIconType(for marketGroup: MarketGroup) -> String? {
    if marketGroup.isBetBuilder == true {
        return "betbuilder"  // → bet_builder_info icon
    }
    if marketGroup.isFast == true {
        return "fast"        // → most_popular_info icon
    }
    return nil
}
```

### Next Steps
1. Test implementation with real match data from ServicesProvider
2. Verify icon display works correctly in UI
3. Consider adding more market group type icons if needed
4. Monitor performance impact of badge count calculations