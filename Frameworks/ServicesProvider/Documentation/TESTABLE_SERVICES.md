# Testable Services (Protocol Witness Pattern)

Struct-based dependency injection following the [pointfree.co](https://www.pointfree.co) Protocol Witness pattern.

## Why Protocol Witness?

Traditional protocols require mock classes. Protocol Witness uses structs with closure properties:

```swift
// Traditional - requires MockCashoutService class
protocol CashoutServiceProtocol { ... }

// Protocol Witness - just swap closures
struct CashoutService {
    var executeCashout: (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
}
```

**Benefits:**
- No mock classes needed
- Built-in factories: `.live()`, `.failing()`, `.noop`, `.mock()`
- Override individual methods easily
- Better Xcode autocomplete

---

## Services Overview

**Goal**: Break down 4 protocols (~288 methods) into ~13 focused services.

| Protocol | Methods | Services |
|----------|---------|----------|
| BettingProvider | 30 | 4 |
| PrivilegedAccessManager | 127 | 6 |
| EventsProvider | 125 | 2 |
| CasinoProvider | 6 | 1 |
| **Total** | **288** | **13** |

---

## Implementation Status

### BettingProvider Services

| Service | Status | Key Methods | Purpose |
|---------|--------|-------------|---------|
| `CashoutService` | **Done** | `subscribeToCashoutValue`, `executeCashout` | Real-time cashout |
| `BetHistoryService` | Planned | `getOpenBetsHistory`, `getResolvedBetsHistory`, `getBetDetails` | Bet history queries |
| `BetPlacementService` | Planned | `placeBets`, `calculatePotentialReturn`, `calculateUnifiedBettingOptions` | Bet validation & execution |
| `BetslipService` | Planned | `getBetslipSettings`, `getSharedTicket`, `getFreebet` | Betslip utilities |

### PrivilegedAccessManager Services

| Service | Status | Key Methods | Purpose |
|---------|--------|-------------|---------|
| `WalletService` | **Done** | `getUserBalance`, `subscribeUserInfoUpdates`, `refreshUserBalance` | Balance & real-time updates |
| `AuthService` | Planned | `login`, `forgotPassword`, `updatePassword`, `sessionStatePublisher` | Authentication |
| `ProfileService` | Planned | `getUserProfile`, `updateUserProfile`, `signUp` | Profile & registration |
| `PaymentsService` | Planned | `processDeposit`, `processWithdrawal`, `getTransactionsHistory` | Deposits, withdrawals, history |
| `LimitsService` | Planned | `getLimits`, `setUserLimit`, `lockPlayer` | Responsible gaming |
| `BonusService` | Planned | `getGrantedBonuses`, `redeemBonus`, `getOddsBoostStairs` | Promotions & bonuses |

### EventsProvider Services

| Service | Status | Key Methods | Purpose |
|---------|--------|-------------|---------|
| `SportsEventsService` | Planned | `subscribeLiveMatches`, `subscribePreLiveMatches`, `getEventDetails`, `subscribeEventMarkets` | All sports event operations |
| `FavoritesService` | Planned | `getUserFavorites`, `addUserFavorite`, `removeUserFavorite` | User favorites |

### CasinoProvider Services

| Service | Status | Key Methods | Purpose |
|---------|--------|-------------|---------|
| `CasinoService` | Planned | `getCasinoCategories`, `getGamesByCategory`, `getGameDetails`, `searchGames`, `buildGameLaunchUrl` | Casino games & launch |

---

## Done: 2 | Planned: 11

---

## Usage

### Production
```swift
let cashout = CashoutService.live(client: servicesProvider)
let wallet = WalletService.live(client: servicesProvider)
```

### Testing
```swift
// Inline closure mocking
let service = CashoutService(
    subscribeToCashoutValue: { betId in
        capturedBetIds.append(betId)
        return sseSubject.eraseToAnyPublisher()
    },
    executeCashout: { _ in
        Just(CashoutResponse.success).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }
)

// Or use built-in factories
let failing = CashoutService.failing(error: .unknown)
let noop = WalletService.noop
```

---

## Adding New Services

1. Create `Services/XxxService.swift`
2. Define struct with closure properties
3. Add `.live(client:)` factory
4. Add `.failing()`, `.noop`, `.mock()` test factories
5. Update this table

Template:
```swift
public struct XxxService {
    public var someMethod: (Input) -> AnyPublisher<Output, ServiceProviderError>

    public init(someMethod: @escaping (Input) -> AnyPublisher<Output, ServiceProviderError>) {
        self.someMethod = someMethod
    }
}

extension XxxService {
    public static func live(client: Client) -> Self {
        .init(someMethod: client.someMethod)
    }

    public static func failing(error: ServiceProviderError = .unknown) -> Self { ... }
    public static var noop: Self { ... }
    public static func mock(...) -> Self { ... }
}
```
