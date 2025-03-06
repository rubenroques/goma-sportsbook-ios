# Sports Betting Concepts and Terminology

This document explains the key betting concepts and terminology used in the GOMA Sportsbook iOS application. Understanding these terms is essential for working with the codebase effectively.

## Core Concepts

### 1. Event Hierarchy

```
Sport
  └── Competition/League
       └── Event/Match
            └── Market
                 └── Outcome
```

- **Sport**: A category of sporting activity (e.g., Football, Tennis, Basketball)
- **Competition/League**: An organized tournament or league (e.g., English Premier League, NBA)
- **Event/Match**: A specific sporting event between participants (e.g., Manchester United vs. Liverpool)
- **Market**: A specific type of bet offered on an event (e.g., Match Winner, Total Goals)
- **Outcome**: A possible result for a market with associated odds (e.g., Home Win at 2.5)

### 2. Odds Formats

- **Decimal Odds**: Expresses the total payout relative to the stake (e.g., 2.50 means a $10 bet would return $25 total)
- **Fractional Odds**: Expresses the profit relative to the stake (e.g., 3/2 means a $10 bet would profit $15)
- **American Odds**: 
  - Positive number (+150) indicates the profit on a $100 stake
  - Negative number (-200) indicates the stake needed to profit $100

### 3. Betslip Concepts

- **Selection**: A chosen outcome from a specific market
- **Bet Type**: Format for combining selections:
  - **Single**: One selection only
  - **Multiple/Accumulator/Parlay**: Combines selections, all must win
  - **System**: Combinations of selections (e.g., Lucky 15, Trixie)
- **Stake**: The amount of money wagered
- **Potential Return**: Total amount to be received if the bet wins (stake + profit)

## Data Models

### Event Model

```swift
public class Event: Codable, Equatable {
    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sport: SportType
    public var sportIdCode: String?
    public var homeTeamScore: Int?
    public var awayTeamScore: Int?
    public var competitionId: String
    public var competitionName: String
    public var startDate: Date
    public var markets: [Market]
    public var status: EventStatus?
    public var matchTime: String?
    // Additional properties
}
```

### Market Model

```swift
public class Market: Codable, Equatable {
    public var id: String
    public var name: String
    public var marketType: String
    public var outcomes: [Outcome]
    public var suspendedReason: String?
    public var isSuspended: Bool
    // Additional properties
}
```

### Outcome Model

```swift
public class Outcome: Codable, Equatable {
    public var id: String
    public var name: String
    public var odds: Double
    public var position: Int?
    public var isDisabled: Bool
    // Additional properties
}
```

### BetTicket Model

```swift
public class BetTicket: Codable, Equatable {
    public var betType: BetType
    public var clientReference: String
    public var currency: String
    public var externalBetslipId: String?
    public var freeBetAmount: Double?
    public var selections: [BetTicketSelection]
    public var stake: Double
    public var winnings: Double?
    // Additional properties
}
```

## Event Status Types

Events can have different statuses that affect betting availability:

- **Not Started**: Event has not yet begun, all markets typically available
- **In Progress**: Event is currently being played, some markets may be suspended temporarily
- **Suspended**: Betting is temporarily unavailable, but may resume
- **Ended**: Event has finished, no more betting allowed
- **Cancelled**: Event will not take place, all bets typically refunded

## Market Types

Common market types include:

1. **Match Result (1X2)**: Bet on home win, draw, or away win
2. **Asian Handicap**: Handicap applied to balance odds between teams
3. **Over/Under**: Bet on whether a numeric value (goals, points) will be over or under a threshold
4. **Both Teams to Score**: Bet on whether both teams will score in the match
5. **Correct Score**: Bet on the exact final score
6. **Outright**: Bet on the winner of a tournament/competition

## Responsible Gaming

The application includes responsible gaming features:

- **Deposit Limits**: Maximum amount that can be deposited
- **Betting Limits**: Maximum amount that can be wagered
- **Loss Limits**: Maximum amount that can be lost
- **Session Limits**: Time-based restrictions
- **Self-Exclusion**: User-initiated blocking of account

## Betting Flows

### 1. Bet Placement Flow

```
Select Outcome → Add to Betslip → 
Enter Stake → Calculate Potential Return → 
Review Bet → Submit Bet → Bet Confirmation
```

### 2. Live Betting Flow

```
Subscribe to Event Updates → 
Receive Odds Updates → 
Place Bet → Immediate Processing → 
Quick Confirmation
```

### 3. Cashout Flow

```
Review Open Bets → 
Select Cashout → 
Calculate Cashout Value → 
Confirm Cashout → 
Process Early Settlement
```

## Promotion Types

The application supports various promotions:

- **Free Bets**: Bets provided by the operator, no stake returned in winnings
- **Boosted Odds**: Enhanced odds on specific selections
- **Cashback**: Return of a percentage of losses
- **Loyalty Bonuses**: Rewards for regular betting activity
- **Deposit Bonuses**: Bonus funds when making a deposit

## Regulatory Concepts

The application follows regulatory guidelines:

- **KYC (Know Your Customer)**: Identity verification process
- **AML (Anti-Money Laundering)**: Procedures to prevent money laundering
- **Betting Limits**: Mandatory restrictions on betting amounts
- **Age Verification**: Ensuring users are of legal age
- **Data Protection**: Handling personal information according to regulations

## Betting Provider Integration

The application integrates with betting providers through:

1. **API Authentication**: Secure token-based authentication
2. **Real-time Odds Updates**: WebSocket connection for live odds changes
3. **Bet Placement API**: Endpoint for submitting bets
4. **Bet Settlement**: Process for resolving bets after events complete
5. **User Verification**: Process for verifying user identity and eligibility 