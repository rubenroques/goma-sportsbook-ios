# Session 3 Progress - 14 December 2025

## ServiceProviderError Cleanup

### Context
During the merge, `SportRadarPrivilegedAccessManager.swift` had 35+ usages of `.notImplemented` error case which needed to be classified properly.

### Error Type Distinction

| Error | Meaning |
|-------|---------|
| `notImplemented` | Feature could be implemented for this provider but hasn't been coded yet (TODO/stub) |
| `notSupportedForProvider` | Feature exists in protocol but this provider's backend doesn't support it |

### Changes Made to `SportRadarPrivilegedAccessManager.swift`

#### Changed to `notSupportedForProvider`:

**Authentication:**
- `signUp(.phone)` - Phone signup not supported by SportRadar

**User Info Streaming:**
- `subscribeUserInfoUpdates()` - SR doesn't have SSE/streaming for user info

**Banking/Transactions (EveryMatrix-specific):**
- `getBankingTransactionsHistory()` (both overloads)
- `getWageringTransactionsHistory()` (both overloads)
- `getBankingWebView()`

**Social Features (not available in SR):**
- `getFollowees()`, `getTotalFollowees()`
- `getFollowers()`, `getTotalFollowers()`
- `addFollowee()`, `removeFollowee()`
- `getTipsRankings()`
- `getUserProfileInfo()`
- `getUserNotifications()`, `updateUserNotifications()`
- `getFriendRequests()`, `getFriends()`
- `addFriends()`, `removeFriend()`
- `searchUserWithCode()`

**Chat Features (not available in SR):**
- `getChatrooms()`
- `addGroup()`, `deleteGroup()`, `editGroup()`, `leaveGroup()`
- `addUsersToGroup()`, `removeUsersToGroup()`

**Registration:**
- `getRegistrationConfig()` - SR has different registration flow

**Casino Features (SR is sports-focused):**
- `getRecentlyPlayedGames()`
- `getMostPlayedGames()`

**Booking Codes:**
- `createBookingCode()`
- `getBettingOfferIds()`

**Password Reset by Phone:**
- `getResetPasswordTokenId()`
- `validateResetPasswordCode()`
- `resetPasswordWithHashKey()`

**Odds Boost:**
- `getOddsBoostStairs()`

#### Kept as `notImplemented`:

- `depositOnWallet()` - Could be implemented but wasn't built yet

---

## Remaining Work from MERGE_PROGRESS.md

### Category 2: SportRadar Mapper Issues

#### SportRadarModelMapper+Events.swift
- Line 205: `[Banner]` vs `[EventBanner]` type mismatch
- Line 209: Extra arguments / missing `from` parameter in EventBanner init

#### SportRadarModelMapper+User.swift
- Line 148: Extra argument `externalFreeBetBalances` in UserWallet call
- Line 159: Type mismatch `Double?` vs `String?`

### Category 3: SportRadarEventsProvider.swift
- Line 992, 2354, 2403: Missing argument for parameter `loaded` in call
- Line 1575: Optional unwrapping needed for `markets` access
- Line 1843: Missing Event init parameters (homeTeamLogoUrl, etc.)

### Category 4: Protocol Conformance
- `SportRadarBettingProvider` does not conform to `BettingProvider`
- `SportRadarEventsProvider` does not conform to `EventsProvider`
- (These will resolve once other errors are fixed)

### Category 5: Missing Members
- `SportRadarManagedContentProvider.swift:418` - `customRequest` method not found on `SportRadarEventsProvider`

---

## Next Steps

- [ ] Fix SportRadar mapper type mismatches
- [ ] Fix SportRadarEventsProvider missing parameters
- [ ] Verify protocol conformance resolves after fixes
- [ ] Build and test BetssonFranceLegacy scheme
- [ ] Build and test BetssonCameroonApp scheme
