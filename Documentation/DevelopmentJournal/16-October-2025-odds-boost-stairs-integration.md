# Odds Boost Stairs Integration

## Date
16 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Integrate EveryMatrix Unified Bonus System (UBS) Odds Boost feature into ServicesProvider
- Implement "stair" system for progressive bonus tiers based on betslip selections
- Follow established 3-layer architecture: EveryMatrix internal models → Domain models → App models
- Enable UI to display current/next bonus tiers to motivate users to add more selections

### Achievements
- [x] Created complete EveryMatrix internal models for odds boost API (`EveryMatrix+OddsBoost.swift`)
  - Request/response structures matching `/v1/bonus/wallets/sports` API spec
  - Includes `BonusWalletItem`, `OddsBoostInfo`, `OddsBoostStair` models
  - Added critical `currentStair` field (was missing from initial spec analysis)
- [x] Created domain models (`OddsBoostStairs.swift`)
  - `OddsBoostStairsResponse`: Provider-agnostic response with currentStair, nextStair, ubsWalletId
  - `OddsBoostStair`: Single tier model with helper methods (`calculateBonus()`, `percentageDisplay`)
  - Helper methods: `isMaxTierReached`, `selectionsNeededForNextTier()`
- [x] Added API endpoint to EveryMatrixPlayerAPI
  - Case: `getSportsBonusWallets(request: EveryMatrix.OddsBoostWalletRequest)`
  - Method: PUT (not GET!) to `/v1/bonus/wallets/sports`
  - Requires authentication (`requireSessionKey: true`)
- [x] Created model mapper (`EveryMatrixModelMapper+OddsBoost.swift`)
  - Maps EveryMatrix response to domain models
  - Extracts cap amount for user's specific currency from multi-currency dict
  - Returns nil gracefully when no bonus available
- [x] Added protocol method to `PrivilegedAccessManager`
  - `getOddsBoostStairs()` with comprehensive documentation
  - Clear usage pattern: call on betslip changes (stake/selections)
  - Warning about critical `ubsWalletId` needed for bet placement
- [x] Implemented in `EveryMatrixPrivilegedAccessManager`
  - Full implementation with BetTicketSelection → EveryMatrix.BetSelection mapping
  - Handles missing fields (tournamentId, locationId) with sensible defaults
  - Comprehensive logging for debugging (current tier, next tier, ubsWalletId)

### Issues / Bugs Hit
- [ ] `BetTicketSelection` model lacks several fields needed by API (tournamentId, locationId, venueId, eventPartId, liveMatch)
  - **Workaround**: Used defaults (tournamentId: 0, locationId: 0, eventPartId: 3, liveMatch: false)
  - **Impact**: Acceptable for v1 - backend still calculates bonus correctly based on eventId/marketId/outcomeId
  - **Future**: Consider extending BetTicketSelection or creating richer model for odds boost calls

### Key Decisions
- **Method location**: Placed in `PrivilegedAccessManager` (not `BettingProvider`)
  - Reason: User-specific bonus wallet, requires authentication, part of user wallet/bonus system
  - Considered BettingProvider but this is about user's available bonuses, not bet operations
- **Return type**: `OddsBoostStairsResponse?` (nullable)
  - User might not have bonus wallet configured
  - Selections might not qualify for any tier
  - API returns empty items array in both cases
- **UbsWalletId extraction**: Store as String ID in response
  - **CRITICAL**: Must be passed to bet placement request to apply bonus
  - Web implementation stores this and includes in placeBet call
  - Missing this = bet placed without bonus even though user qualified
- **Currency handling**: Extract cap from multi-currency dict
  - Response has: `capAmount: { "XAF": 100, "EUR": 0.1 }`
  - Method extracts correct value based on user's currency parameter
  - Returns nil for entire stair if user's currency not in dict
- **Terminal type**: Hardcoded "mobile" for iOS
  - Web sends "desktop" or "mobile"
  - iOS = mobile terminal type

### Experiments & Notes
- Performed 3 curl requests to understand API behavior:
  1. **No selections** (odds only): Returns config but no `oddsBoost` object at top level
  2. **3 selections** (qualifying): Returns `oddsBoost` with `currentStair` and `nextStair`
  3. **5 selections** (max tier): Returns `oddsBoost` with `currentStair` only (`nextStair: null`)
- Web documentation highly detailed - included full request/response structures and calculation formulas
  - Bonus formula: `min(potentialWinnings × percentage, capAmount)`
  - Example tiers: 2 selections = 10%, 3 selections = 15%, 4 selections = 20%
- Response structure differs based on whether combination parameter provided:
  - **Without combination**: Only configuration returned (sportsBoostStairs array)
  - **With combination**: Adds top-level `oddsBoost` object with currentStair/nextStair
- EventID mapping in response uses dict: `odds: { "eventId1": {}, "eventId2": {} }`
  - Empty objects per event - just tracking which events are eligible

### Useful Files / Links
- [Web Documentation](../../../Web/sportsbook-frontend/sportsbook-frontend-demo/Documentation/Features/OddsBoost-BonusSystem.md) - Complete feature spec
- [EveryMatrix Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+OddsBoost.swift)
- [Domain Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/OddsBoost/OddsBoostStairs.swift)
- [Model Mapper](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+OddsBoost.swift)
- [API Endpoint](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift)
- [Protocol](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/PrivilegedAccessManager.swift)
- [Implementation](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Managers/EveryMatrixPrivilegedAccessManager.swift)
- [API Dev Guide](../Core/API_DEVELOPMENT_GUIDE.md) - 3-layer architecture reference

### Next Steps
1. **UI Integration**: Create ViewModel to call `getOddsBoostStairs()` when betslip changes
2. **Betslip Integration**: Store `ubsWalletId` from response and pass to bet placement
3. **GomaUI Component**: Design/implement odds boost progress UI (pills, percentages, "add X more" messaging)
4. **Testing**: Test with different selection counts, currencies, and qualifying/non-qualifying bets
5. **Edge Cases**: Handle nil response, max tier reached, currency not in capAmount dict
6. **BetTicketSelection Enhancement**: Consider adding missing fields (tournamentId, locationId) if needed
7. **Documentation**: Update app-level docs with odds boost feature usage patterns

### Implementation Pattern Used
Followed standard 3-layer EveryMatrix integration:
1. **Layer 1**: Internal EveryMatrix models (request/response structs)
2. **Layer 2**: Domain models (provider-agnostic)
3. **Layer 3**: Model mapper (EveryMatrix → Domain transformation)

Plus standard REST API integration:
- API enum case with endpoint/method/body
- Protocol method signature
- Provider implementation calling connector → mapper → domain model

### Feature Context
**Business Goal**: Motivate users to add more selections to betslips by showing progressive bonus rewards

**User Flow**:
1. User adds 2 selections → API returns 10% bonus, shows "Add 1 more for 15%"
2. User adds 3rd selection → API returns 15% bonus, shows "Add 1 more for 20%"
3. User adds 4th selection → API returns 20% bonus, shows "Max bonus reached!"
4. User places bet → Backend applies bonus using `ubsWalletId` from response

**Formula**: `bonusAmount = min(potentialWinnings × percentage, capAmount)`
- Example: 1000 XAF potential winnings × 10% = 100 XAF bonus (if cap is 100+)
- If cap is 50 XAF → actual bonus = 50 XAF (capped)
