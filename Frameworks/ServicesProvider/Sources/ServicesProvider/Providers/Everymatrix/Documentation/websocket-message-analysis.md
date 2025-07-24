# WebSocket Message Analysis - EveryMatrix Provider

## 📡 Real WebSocket Data Analysis

This document contains the actual WebSocket messages captured from EveryMatrix that led to our granular update implementation.

---

## 🔍 Message Pattern Discovery

### Pattern 1: UPDATE with changedProperties

**Single Betting Offer Odds Update**:
```json
{
  "version": "1749227447908",
  "format": "AGGREGATOR", 
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "272181284331364608",
      "changedProperties": {
        "lastChangedTime": 1749227447608,
        "odds": 1.7936507
      }
    }
  ]
}
```

**Key Insights**:
- Only the changed fields are sent (`odds` + `lastChangedTime`)
- Network efficiency: ~100 bytes vs full entity (~500+ bytes)
- Perfect for real-time odds updates

---

### Pattern 2: Market Property Updates

**Market mainLine Flag Change**:
```json
{
  "version": "1749227447313",
  "format": "AGGREGATOR",
  "messageType": "UPDATE", 
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "MARKET",
      "id": "272279121537921536",
      "changedProperties": {
        "mainLine": false
      }
    }
  ]
}
```

**Use Case**: When markets are promoted/demoted as main betting lines

---

### Pattern 3: Batch Updates

**Multiple Entity Updates in Single Message**:
```json
{
  "version": "1749227453829",
  "format": "AGGREGATOR",
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER", 
      "id": "272287761098384384",
      "changedProperties": {
        "lastChangedTime": 1749227453326,
        "odds": 4.3333335
      }
    },
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "272197240427421952", 
      "changedProperties": {
        "lastChangedTime": 1749227453328,
        "odds": 1.3703704
      }
    }
  ]
}
```

**Key Insights**:
- Multiple outcomes can update simultaneously
- Requires batched UI updates for smooth animations
- Common during high-frequency trading periods

---

### Pattern 4: Match Statistics Updates

**Match Counter Updates**:
```json
{
  "version": "1749227453343",
  "format": "AGGREGATOR",
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "MATCH",
      "id": "271874075365871616",
      "changedProperties": {
        "numberOfMarkets": 47,
        "numberOfBettingOffers": 202
      }
    }
  ]
}
```

**Use Case**: Live updates of available betting options count

---

### Pattern 5: Availability Changes

**Betting Offer Suspended**:
```json
{
  "version": "1749227455658",
  "format": "AGGREGATOR", 
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "272271961185333248",
      "changedProperties": {
        "statusId": "4",
        "isAvailable": false,
        "lastChangedTime": 1749227455477
      }
    }
  ]
}
```

**UI Impact**: 
- Odds button should become disabled
- Visual indicator of suspension
- Remove from active betting options

---

## 🗑️ DELETE Operations

**Mass Market Cleanup**:
```json
{
  "version": "1749227452646",
  "format": "AGGREGATOR",
  "messageType": "UPDATE", 
  "records": [
    {
      "changeType": "DELETE",
      "entityType": "MAIN_MARKET",
      "id": "3131045740"
    },
    {
      "changeType": "DELETE", 
      "entityType": "BETTING_OFFER",
      "id": "272216361174037760"
    },
    {
      "changeType": "DELETE",
      "entityType": "OUTCOME", 
      "id": "272041392624590592"
    },
    {
      "changeType": "DELETE",
      "entityType": "MARKET",
      "id": "272027904799797248"
    }
    // ... many more deletes
  ]
}
```

**Pattern Analysis**:
- Hierarchical cleanup: Match → Markets → Outcomes → Betting Offers
- Suggests event going off-market or time expiring
- UI should gracefully remove affected betting options

---

## ➕ CREATE Operations

**New Match Added**:
```json
{
  "changeType": "CREATE",
  "entityType": "MATCH", 
  "id": "272271959879979008",
  "entity": {
    "_type": "MATCH",
    "id": "272271959879979008",
    "name": "Mvfc Berettyoujfalu - Nyiregyhaza",
    "startTime": 1749227400000,
    "homeParticipantName": "Mvfc Berettyoujfalu",
    "awayParticipantName": "Nyiregyhaza",
    // ... full entity data
  }
}
```

**Associated Market Creation**:
```json
{
  "changeType": "CREATE", 
  "entityType": "MARKET",
  "id": "272271959988236288",
  "entity": {
    "_type": "MARKET",
    "name": "Home Draw Away",
    "eventId": "272271959879979008",
    "mainLine": false,
    // ... full market data
  }
}
```

**Pattern**: 
- Full entity data provided for CREATE operations
- Related entities created in same message batch
- Maintains referential integrity

---

## 📊 Message Frequency Analysis

From observation during active betting periods:

| Update Type | Frequency | Typical Size |
|-------------|-----------|--------------|
| Odds Updates | ~2-5/sec per popular match | 80-150 bytes |
| Market Changes | ~1/min per match | 50-100 bytes |
| Match Stats | ~30 sec per live match | 100-200 bytes |
| CREATE/DELETE | Event-driven | 500-2000 bytes |

**Performance Impact**:
- High-frequency odds updates require efficient merging
- Batch processing needed for simultaneous updates
- Memory pressure from frequent allocations

---

## 🎯 UI Update Strategy Implications

### For Odds Display:
- **High Priority**: BettingOffer odds changes
- **Medium Priority**: Availability status changes  
- **Low Priority**: Market organization changes

### For Match Cards:
- **Update counters**: numberOfMarkets, numberOfBettingOffers
- **Refresh layouts**: When markets added/removed
- **Remove cards**: When match deleted

### For Market Groups:
- **Reorder**: When mainLine status changes
- **Add/Remove**: When markets created/deleted
- **Update headers**: When market names change

---

## 🔧 Technical Implementation Notes

### Entity Relationship Updates:
```json
// When outcome gets new betting offer
{
  "changeType": "CREATE",
  "entityType": "BETTING_OFFER", 
  "entity": {
    "outcomeId": "272235037269152768",  // Links to existing outcome
    "odds": 1.877193
  }
}
```

### Timestamp Handling:
- All timestamps in milliseconds since epoch
- `lastChangedTime` used for conflict resolution
- Version string indicates message ordering

### Entity Lifecycle:
1. **INITIAL_DUMP**: Complete entity graph
2. **CREATE**: New entities with full data
3. **UPDATE**: Property patches with changedProperties
4. **DELETE**: Entity removal by type + ID

---

This analysis directly informed our Phase 1 implementation and provides the foundation for Phase 2's change notification system.