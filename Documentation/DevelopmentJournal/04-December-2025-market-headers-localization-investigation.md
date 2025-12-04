# Development Journal

## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Investigate how market group headers are constructed in match details
- Trace the full data transformation pipeline from socket to UI
- Identify why some fields appear untranslated (English/French localization issue)

### Achievements
- [x] Mapped complete data transformation pipeline: Socket DTO → Builders → Hierarchical Models → ModelMapper → Domain Models → UI
- [x] Used cWAMP tool to fetch real socket data in both English (`/sports/4093/en/...`) and French (`/sports/4093/fr/...`)
- [x] Confirmed server-side localization works for most fields (name, displayName, bettingTypeName, translatedName)
- [x] Identified `bettingTypeName` as the correctly translated field for market group headers ("Over/Under" → "Plus / Moins")
- [x] Confirmed `marketTypeName` in domain model correctly maps from `bettingTypeName` in socket
- [x] Added TODO item for "All Markets" hardcoded string localization

### Issues / Bugs Hit
- [ ] 4 market types missing French translations from EveryMatrix server:
  - "Both Teams to Score in Both Halves"
  - "Half Time Or Full Time"
  - "Home Draw Away In Interval"
  - "Interval Of Goal X"
- [ ] Typo in French server data: "Deuw équipes marquent et total" (should be "Deux")

### Key Decisions
- Localization is **server-side** for market names - app sends language parameter in WAMP subscription
- No client-side localization layer for market type names - depends entirely on EveryMatrix translations
- Missing translations should be reported to EveryMatrix

### Experiments & Notes

#### Socket Data Structure for Markets
```
MARKET entity fields:
- name: "Over/Under 2.5, Ordinary Time" (includes specifier + event part)
- displayName: "Over/Under, Ordinary Time" (no specifier, includes event part)
- bettingTypeName: "Over/Under" (pure market type, no specifier, no event part) ← Used for grouping
- paramFloat1: 2.5 (numeric specifier)
```

#### Translation Comparison (cWAMP results)
| Field | English | French |
|-------|---------|--------|
| bettingTypeName | "Over/Under" | "Plus / Moins" |
| name | "Over/Under 2.5, Ordinary Time" | "Plus/moins 2.5, Temps Réglementaire" |
| displayName | "Over/Under, Ordinary Time" | "Plus/moins, Temps Réglementaire" |

#### Mapping Chain
```
Socket: MarketDTO.bettingTypeName
    ↓ (MarketBuilder)
Internal: EveryMatrix.Market.bettingType.name
    ↓ (EveryMatrixModelMapper+Events.swift:124)
Domain: Market.marketTypeName
    ↓ (MarketsTabSimpleViewModel.swift:201)
UI: groupName = firstMarket.marketTypeName ?? firstMarket.name
```

### Useful Files / Links

**Socket Layer (DTOs)**
- [MarketDTO](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/DTOs/MarketDTO.swift)
- [OutcomeDTO](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/DTOs/OutcomeDTO.swift)
- [MarketGroupDTO](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/DTOs/MarketGroupDTO.swift)

**Model Mapping**
- [EveryMatrixModelMapper+Events.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Events.swift) - Lines 118-152 for market mapping

**UI Layer**
- [MarketsTabSimpleViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MarketsTab/MarketsTabSimpleViewModel.swift) - Line 201 for group header title
- [MatchDetailsMarketGroupSelectorTabViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsMarketGroupSelectorTabViewModel.swift) - Line 270 for tab titles

**cWAMP Tool**
- [cWAMP README](../../tools/wamp-client/README.md)
- [cWAMP Examples](../../tools/wamp-client/EXAMPLES.md)

### Next Steps
1. Report missing French translations to EveryMatrix (4 market types)
2. Report typo "Deuw" → "Deux" to EveryMatrix
3. Verify language parameter is correctly set in WAMP subscription based on user preference
4. Consider adding client-side fallback translations for known missing market types (if EM can't fix)
