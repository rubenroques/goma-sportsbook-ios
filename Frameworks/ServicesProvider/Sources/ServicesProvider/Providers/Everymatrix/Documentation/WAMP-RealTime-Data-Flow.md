# EveryMatrix WAMP Real-Time Data Flow

## Overview

This document explains how the EveryMatrix WAMP WebSocket sends real-time data updates for betting offers, outcomes, markets, and match availability to the iOS app.

---

## WAMP Protocol: REGISTER/INVOKE Pattern

**Critical**: EveryMatrix does NOT use traditional WAMP pub/sub. Instead, it uses the **REGISTER/INVOKE** pattern.

| Pattern | Client Action | Server Action | Used by EM? |
|---------|---------------|---------------|-------------|
| Pub/Sub | `subscribe(topic)` | `publish(topic, data)` | No |
| **RPC Callee** | `register(procedure)` | `invoke(procedure, data)` | **Yes** |

### WAMP Message Types

| Type | Code | Description |
|------|------|-------------|
| REGISTER | 64 | Client registers a procedure URI |
| REGISTERED | 65 | Server confirms registration |
| INVOCATION | 68 | Server calls the registered procedure with data |
| YIELD | 70 | Client acknowledges (autobahn handles automatically) |

### Why REGISTER/INVOKE?

The server actively "calls" registered procedures on clients when data changes. This is the reverse of traditional pub/sub where clients passively receive published messages.

---

## iOS Subscription Flow

```
ViewModel (e.g., InPlayEventsViewModel)
    │
    │ servicesProvider.subscribeToFilteredLiveMatches(filters)
    ↓
EveryMatrixEventsProvider
    │
    │ LiveMatchesPaginator.subscribe()
    ↓
EveryMatrixSocketConnector.subscribe(router: WAMPRouter)
    │
    │ wampManager.registerOnEndpoint(endpoint, decodingType)
    ↓
WAMPManager.registerOnEndpoint()  [WAMPManager.swift:442]
    │
    │ swampSession.register(procedure, options, onSuccess, onError, onEvent)
    ↓
SSWampSession.register()  [SSWampSession.swift:187]
    │
    │ Sends WAMP REGISTER message (type 64) to server
    ↓
Server confirms with REGISTERED (type 65)
    │
    ↓
Initial Dump RPC call: /sports#initialDump with topic parameter
    │
    ↓
Server INVOKEs procedure with UPDATE messages (type 68)
    │
    ↓
WAMPManager.onEvent handler receives data
    │
    │ DictionaryDecoder decodes to DTO types
    ↓
EntityStore processes and stores entities
    │
    │ Combine publishers notify observers
    ↓
UI updates specific cells/views
```

---

## Message Types

### 1. INITIAL_DUMP (First Response)

When you register for a topic, the server sends a complete snapshot via RPC:

```json
{
  "version": "1764055393468",
  "format": "BASIC",
  "messageType": "INITIAL_DUMP",
  "records": [
    {
      "_type": "MATCH",
      "id": "287843935863476224",
      "name": "Hawks - Vultures",
      "sportId": "8",
      "statusId": "2",
      "statusName": "In Progress",
      "homeParticipantName": "Hawks",
      "awayParticipantName": "Vultures",
      "numberOfMarkets": 31,
      "numberOfBettingOffers": 69
    },
    {
      "_type": "MARKET",
      "id": "287854424887456768",
      "name": "Asian Handicap -6.5, 2nd Quarter",
      "eventId": "287843935863476224",
      "bettingTypeId": "48",
      "isAvailable": true,
      "mainLine": false
    },
    {
      "_type": "OUTCOME",
      "id": "287854424888504320",
      "name": "Hawks -6.5",
      "marketId": "287854424887456768",
      "bettingOfferId": "287854424890601472"
    },
    {
      "_type": "BETTING_OFFER",
      "id": "287854424890601472",
      "outcomeId": "287854424888504320",
      "odds": 1.877193,
      "isAvailable": true,
      "isLive": true,
      "statusId": "1"
    }
  ]
}
```

**Key Points**:
- Contains ALL entity types: MATCH, MARKET, OUTCOME, BETTING_OFFER, SPORT, etc.
- Entities reference each other via IDs (normalized/flat structure)
- Stored directly in EntityStore by type and ID

---

### 2. UPDATE Messages (Real-Time Changes)

After initial dump, the server sends delta updates via INVOCATION:

```json
{
  "version": "1764055448601",
  "format": "BASIC",
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "287854034288861952",
      "changedProperties": {
        "lastChangedTime": 1764055448301,
        "odds": 1.7692307
      }
    },
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "287854034288862208",
      "changedProperties": {
        "lastChangedTime": 1764055448301,
        "odds": 2.05
      }
    }
  ]
}
```

**Key Points**:
- Only `changedProperties` are sent, not the full entity
- Multiple entities can update in a single message
- Extremely bandwidth-efficient for high-frequency odds updates

---

### 3. Change Types

#### UPDATE - Property Changes
```json
{
  "changeType": "UPDATE",
  "entityType": "BETTING_OFFER",
  "id": "287854034288861952",
  "changedProperties": {
    "odds": 1.7692307,
    "lastChangedTime": 1764055448301
  }
}
```

#### CREATE - New Entity
```json
{
  "changeType": "CREATE",
  "entityType": "MARKET",
  "id": "287854424887456768",
  "entity": {
    "_type": "MARKET",
    "id": "287854424887456768",
    "name": "Asian Handicap -6.5",
    "eventId": "287843935863476224",
    "isAvailable": true
  }
}
```

#### DELETE - Entity Removed
```json
{
  "changeType": "DELETE",
  "entityType": "BETTING_OFFER",
  "id": "287854034288861952"
}
```

---

## Entity Hierarchy

EveryMatrix sends **normalized/flat data**. Entities reference each other by ID:

```
SPORT (id: "8")
    │
    └── MATCH (id: "287843935863476224", sportId: "8")
            │
            └── MARKET (id: "287854424887456768", eventId: "287843935863476224")
                    │
                    └── OUTCOME (id: "287854424888504320", marketId: "287854424887456768")
                            │
                            └── BETTING_OFFER (id: "287854424890601472", outcomeId: "287854424888504320")
```

### Why Normalized?

1. **Bandwidth Efficiency**: When odds change, only send `{ id, changedProperties: { odds: 1.82 } }` (~100 bytes) instead of entire match hierarchy (~10KB)
2. **No Duplication**: A sport referenced by 1000 matches is sent once
3. **Selective Updates**: Update one betting offer without resending markets/outcomes

---

## Common Property Changes

### Betting Offer Updates

| Property | Description | Impact |
|----------|-------------|--------|
| `odds` | Decimal odds value | UI shows new odds |
| `isAvailable` | Can be bet on | Enable/disable button |
| `statusId` | Status code (1=open, 4=suspended) | Visual indicator |
| `lastChangedTime` | Timestamp of change | Conflict resolution |

### Market Updates

| Property | Description | Impact |
|----------|-------------|--------|
| `isAvailable` | Market open for betting | Show/hide market |
| `mainLine` | Is the primary line | Sorting/display priority |
| `isClosed` | Market permanently closed | Remove from display |
| `numberOfOutcomes` | Count of outcomes | Badge/counter update |

### Match Updates

| Property | Description | Impact |
|----------|-------------|--------|
| `statusId` | 1=upcoming, 2=live, 3=ended | Match state |
| `currentPartId` | Current period/quarter | Live indicator |
| `numberOfMarkets` | Available markets count | Counter badge |
| `numberOfBettingOffers` | Available bets count | Counter badge |

---

## EntityStore Processing

### Storing Initial Dump

```swift
// EntityStore.swift
func storeFromRecord(_ record: EntityRecord) {
    switch record {
    case .bettingOffer(let dto):
        store(dto)  // Store by type + ID
    case .market(let dto):
        store(dto)
    // ... other entity types
    }
}
```

### Processing Updates

```swift
// EntityStore.swift:136-161
func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyChange]) {
    // 1. Find existing entity
    guard let existingEntity = entities[entityType]?[id] else { return }

    // 2. Merge changed properties via JSON encode/decode
    let updatedEntity = mergeChangedProperties(entity: existingEntity, changes: changedProperties)

    // 3. Store updated entity
    entities[entityType]?[id] = updatedEntity

    // 4. Notify Combine publishers
    notifyEntityChange(updatedEntity)
}
```

### Observing Changes

```swift
// UI can observe specific entities
entityStore.observeBettingOffer(id: "287854424890601472")
    .sink { bettingOffer in
        // Update UI when this specific betting offer changes
        updateOddsLabel(bettingOffer?.odds)
    }
    .store(in: &cancellables)
```

---

## WAMPRouter Endpoints

### Common Subscription Topics

```swift
// Live matches for a sport
WAMPRouter.liveMatchesPublisher(operatorId: "4093", language: "en", sportId: "1", matchesCount: 10)
// → /sports/4093/en/live-matches-aggregator-main/1/all-locations/default-event-info/10/5

// Specific match odds
WAMPRouter.oddsMatch(operatorId: "4093", language: "en", matchId: "287843935863476224")
// → /sports/4093/en/287843935863476224/match-odds

// Live sports list
WAMPRouter.liveSportsPublisher(operatorId: "4093", language: "en")
// → /sports/4093/en/disciplines/LIVE/BOTH

// Match details with market groups
WAMPRouter.matchDetailsPublisher(operatorId: "4093", language: "en", matchId: "287843935863476224")
// → /sports/4093/en/match-aggregator-groups-overview/287843935863476224/1
```

### Initial Dump Pattern

Every subscription has a corresponding RPC call for initial data:

```swift
// Subscription endpoint has initialDumpRequest computed property
case .liveMatchesPublisher:
    return .sportsInitialDump(topic: self.procedure)

// RPC call: /sports#initialDump with kwargs: { "topic": "/sports/4093/en/live-matches-..." }
```

---

## Testing with cWAMP

The `tools/wamp-client/` directory contains a Node.js CLI tool for testing WAMP connections.

### Basic Commands

```bash
# Test connection
node tools/wamp-client/bin/cwamp.js test

# RPC call
node tools/wamp-client/bin/cwamp.js rpc -p "/sports#operatorInfo" --pretty

# Register for live sports (REGISTER/INVOKE pattern)
node tools/wamp-client/bin/cwamp.js register \
  -p "/sports/4093/en/disciplines/LIVE/BOTH" \
  --initial-dump \
  -d 30000 \
  --verbose --pretty
```

### Capture Real-Time Odds Updates

```bash
# Register for specific match odds and capture updates
node tools/wamp-client/bin/cwamp.js register \
  -p "/sports/4093/en/287843935863476224/match-odds" \
  --initial-dump \
  -d 30000 \
  -m 5 \
  --verbose --pretty
```

**Output Example**:
```
CONNECTION: CONNECTED
RPC -> /sports#initialDump
RPC <- /sports#initialDump
REGISTER: /sports/4093/en/287843935863476224/match-odds
Registered (registrationId: 1670050789181467)
INVOCATION: /sports/4093/en/287843935863476224/match-odds
INVOCATION: /sports/4093/en/287843935863476224/match-odds
...
```

---

## Update Frequency

Based on live observation:

| Update Type | Typical Frequency | Message Size |
|-------------|-------------------|--------------|
| Odds changes | 2-5/sec per popular match | 80-150 bytes |
| Market availability | 1/min per match | 50-100 bytes |
| Match statistics | Every 30 sec for live matches | 100-200 bytes |
| CREATE/DELETE | Event-driven | 500-2000 bytes |

---

## Related Documentation

- [websocket-message-analysis.md](websocket-message-analysis.md) - Detailed message pattern examples
- [granular-updates-implementation.md](granular-updates-implementation.md) - EntityStore update implementation
- [WAMPExampleResponses/](WAMPExampleResponses/) - Sample WebSocket responses

## Related Code Files

| File | Purpose |
|------|---------|
| `WAMPRouter.swift` | All 60+ endpoint definitions |
| `WAMPManager.swift:442-552` | `registerOnEndpoint()` implementation |
| `EntityStore.swift:136-161` | Delta update processing |
| `EveryMatrixSocketConnector.swift:151-187` | `subscribe()` wrapper |
| `ResponseParser.swift` | Message decoding and EntityStore population |

---

## Summary

1. **Protocol**: WAMP REGISTER/INVOKE (not pub/sub)
2. **Initial Data**: RPC call to `/sports#initialDump` returns complete entity graph
3. **Updates**: Server INVOKEs registered procedures with delta `changedProperties`
4. **Efficiency**: Only changed fields transmitted (~100 bytes vs ~10KB for full entity)
5. **Processing**: EntityStore merges properties, Combine publishers notify UI
6. **Testing**: Use `cwamp register` command to observe real-time updates
