# RecSys Frontend Integration Guide

## Overview

The Bet Recommendation System (RecSys) provides personalized betting suggestions that can be connected to real-time odds updates via WAMP WebSocket.

Flow: `RecSys API → Event/Market IDs → WAMP WebSocket → Live Odds`

## RecSys System Description

### Single Bets API
The Single Bets RecSys analyzes user betting history to deliver personalized recommendations. It uses machine learning models (Linear Regression/XGBoost) to predict interest scores based on user profiles built from betting patterns. The system processes user data across 10 sports, 50 leagues, 10 betting types, and 6 odds ranges. It returns up to 100 recommended events grouped by event, with multiple markets per event ranked by predicted interest score. Interest score formula: `stake * SQRT(odds - 1)`. Active users (bet placed in last 60 days) get personalized recommendations, while new users receive default popular recommendations. Cache refreshes twice daily for events in next 18 hours.

| Feature | Single Bets API |
|---------|-----------------|
| Returns | Up to 100 events with multiple markets each |
| Structure | Events → Markets → Betting Types |
| Personalization | ML-based user profiling |
| Cache | 18-hour window, refreshed twice daily |
| Default fallback | Top 100 popular Tier 1/2 events |

### Combo Bets API  
The Combo RecSys is designed specifically for combination betting. It analyzes user context (sport, league, participant, outcome type, event part, odds group) to find matching betting offers in the next 24 hours. Uses sophisticated fallback matching: complete context → participant-only → league-only → sport+outcome only. Always returns exactly 50 specific outcomes (not events) with precise outcome IDs for building combo bets. Ranking prioritizes complete context matches, then partial matches, with default popular matches as backup.

| Feature | Combo Bets API |
|---------|-----------------|
| Returns | Exactly 50 specific outcomes |
| Structure | Individual outcomes with specific IDs |
| Matching | Context-based with fallback levels |
| Cache | 24-hour window |
| Focus | Pre-selected outcomes for combo construction |

### Supported Sports

| ID | Sport |
|----|-------|
| 1 | Football |
| 8 | Basketball |  
| 121 | FIFA |
| 101 | Price boost |
| 3 | Tennis |
| 63 | Table Tennis |
| 106 | NBA2k |
| 20 | Volleyball |
| 6 | Ice Hockey |
| 98 | CS:GO |

## API Endpoints

| API | URL | Key |
|-----|-----|-----|
| Single Bets | `https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations` | `AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho` |
| Combo Bets | `https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev/recommendations` | `AIzaSyAQog-N-vXGDNWldHPfM9qzR5vOMeJDspE` |

## WAMP WebSocket Connection

| Parameter | Value |
|-----------|-------|
| URL | `wss://sportsapi-betsson-stage.everymatrix.com/v2` |
| Realm | `www.betsson.cm` |
| Client ID | `STAGE_2-STAGE_2r5IxUlPqfCgPlWiXbAJdsHM` |
| Origin | `https://clientsample-sports-stage.everymatrix.com` |

## Single Bets API

### cURL Example
```bash
curl "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations?domain_id=4093&user_id=7005274&is_live=false&terminal_type=1&key=AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho"
```

### Parameters
| Parameter | Value | Description |
|-----------|-------|-------------|
| domain_id | 4093 | Betsson Cameroon |
| user_id | From PAM | User ID from authentication |
| is_live | false/true | Pre-match/live recommendations |
| terminal_type | 1/2 | Desktop/mobile |

### Response Structure
```json
{
  "user_id": 7005274,
  "domain_id": 4093,
  "expiration_date": "2025-09-05 14:11:18.646690",
  "recommendations_list": [
    {
      "eventId": "278269974795128832",
      "interestScore": 1.0,
      "BetsRecommendationsList": [
        {
          "marketId": "280287284081062912",
          "bettingTypeId": 182,
          "eventPartId": 3,
          "interestScore": 1.0
        }
      ]
    }
  ]
}
```

## Combo Bets API

### cURL Example
```bash
curl "https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev/recommendations?domain_id=4093&user_id=7005274&key=AIzaSyAQog-N-vXGDNWldHPfM9qzR5vOMeJDspE"
```

### Response Structure
```json
{
  "user_id": 7005274,
  "recommendations_list": [
    {
      "eventId": "278269653524025344",
      "marketId": "278269653732949504", 
      "bettingTypeId": 69,
      "outcomeId": "278269653635461120",
      "interestScore": 1.0
    }
  ]
}
```

## WAMP Integration

### RPC Calls

| Procedure | Parameters | Purpose |
|-----------|------------|---------|
| `/sports#matches` | `{lang: "en", matchId: "EVENT_ID"}` | Get event details |
| `/sports#odds` | `{lang: "en", matchId: "EVENT_ID", bettingTypeId: "BETTING_TYPE"}` | Get market odds |

### Subscription Topics

| Topic Pattern | Purpose |
|---------------|---------|
| `/sports/1/en/EVENT_ID/match-odds` | Real-time odds for specific event |

### Event Details Response
```json
{
  "id": "278269974795128832",
  "name": "Ukraine - France", 
  "startTime": 1757097900000,
  "sportName": "Football",
  "homeParticipantName": "Ukraine",
  "awayParticipantName": "France"
}
```

### Odds Response
```json
{
  "records": [
    {
      "_type": "BETTING_OFFER",
      "id": "278270654087705344",
      "outcomeId": "278269974913692416",
      "bettingTypeId": "69",
      "odds": 1.3571428,
      "bettingTypeName": "Home Draw Away"
    }
  ]
}
```

## Data Mapping

| RecSys Field | WAMP Usage |
|--------------|------------|
| `eventId` | Match details RPC call |
| `eventId` | Odds subscription topic |
| `marketId` | Market filtering |
| `bettingTypeId` | Odds RPC parameter |
| `interestScore` | UI sorting/priority |

## Test Data

### Test Users (Betsson Cameroon Stage)
| User ID | Phone | Password |
|---------|-------|----------|
| 7005274 | +237666999005 | 4050 |
| 7010350 | +237666999007 | 4050 |
| 6974909 | +237666999001 | 4050 |

### Working Example
1. RecSys returns event `278269974795128832` 
2. WAMP RPC `/sports#matches` returns "Ukraine - France"
3. WAMP subscription `/sports/1/en/278269974795128832/match-odds` receives real-time odds

## Error Responses

| HTTP Code | Description |
|-----------|-------------|
| 400 | Bad Request - missing parameters |
| 403 | Permission Denied - wrong API key |

## Cache Timing
- RecSys recommendations expire after 7 minutes
- Refresh before expiration to maintain real-time data