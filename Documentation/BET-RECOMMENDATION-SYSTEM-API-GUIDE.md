# Bet Recommendation System API Integration Guide

## Overview

The Bet Recommendation System (REC-SYS) provides personalized betting suggestions to users based on their historical betting patterns. The system consists of three distinct APIs, each serving different recommendation purposes.

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Prerequisites](#prerequisites)
3. [API Endpoints](#api-endpoints)
4. [Complete Integration Flow](#complete-integration-flow)
5. [API Response Formats](#api-response-formats)
6. [Testing Guide](#testing-guide)
7. [Troubleshooting](#troubleshooting)

## System Architecture

### How It Works
1. **User Profiling**: System analyzes user's betting history (last 60 days)
2. **Pattern Recognition**: Identifies preferences for sports, leagues, betting types, and odds ranges
3. **Risk Calculation**: Uses formula: `stake * SQRT(odds - 1)` to determine interest scores
4. **Caching**: Active users' recommendations are pre-cached every 24 hours at 20:00 UTC
5. **Recommendation Generation**: ML models (Linear Regression/XGBoost) predict interest scores

### Supported Sports
- Football (ID: 1)
- Basketball (ID: 8)
- Tennis (ID: 3)
- Table Tennis (ID: 63)
- Volleyball (ID: 20)
- Ice Hockey (ID: 6)
- FIFA (ID: 121)
- NBA2k (ID: 106)
- CS:GO (ID: 98)
- Price Boost (ID: 101)

## Prerequisites

### 1. User Registration & Authentication
Users must be registered and authenticated through the PAM (Player Account Management) API.

#### Registration Flow
```bash
# Step 1: Initialize registration
curl 'https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/registration/step' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw '{
    "Step":"Step1",
    "RegistrationId":"unique-registration-id",
    "RegisterUserDto":{
      "Mobile":"666444002",
      "Password":"1234",
      "TermsAndConditions":true,
      "MobilePrefix":"+237"
    }
  }'

# Step 2: Complete registration
curl 'https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/register' \
  -X 'PUT' \
  -H 'content-type: application/json' \
  --data-raw '{"registrationId":"unique-registration-id"}'
```

#### Login Flow
```bash
curl 'https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login' \
  -H 'content-type: application/json' \
  --data-raw '{
    "username":"+237666444002",
    "password":"1234"
  }'
```

Response:
```json
{
  "sessionId": "2db9d915-b966-4059-8345-e7327fe8e666",
  "userId": 7014240,
  "sessionBlockers": [],
  "hasToAcceptTC": false
}
```

### 2. User Must Have Betting History
For personalized recommendations, users need:
- At least one placed bet in the last 60 days
- Bets must be accepted/settled
- Without history, users receive default popular recommendations

## API Endpoints

### 1. Single Bets Recommendation API

**Purpose**: Provides personalized single bet recommendations based on historical patterns.

**Endpoints**:
- Test: `https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations`
- Production: TBD (requires production setup)

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| domain_id | INTEGER | Yes | Operator/client ID (e.g., 4093 for Betsson Cameroon) |
| user_id | INTEGER | Yes | User ID from PAM system |
| is_live | BOOLEAN | No | Legacy parameter (currently unused) |
| terminal_type | INTEGER | No | 1=Desktop, 2=Mobile (legacy) |
| key | STRING | Yes | API key for authentication |

**Example Request**:
```bash
curl -X GET "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations?\
domain_id=4093&\
user_id=7014240&\
is_live=false&\
terminal_type=1&\
key=AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho"
```

### 2. Combo Bets Recommendation API

**Purpose**: Recommends 50 events with selected outcomes for constructing combo bets.

**Endpoints**:
- Test: `https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev/recommendations`
- Production: `https://recsys-combo-api-gateway-prod-bshwjrve.ew.gateway.dev/recommendations`

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| domain_id | INTEGER | Yes | Operator/client ID |
| user_id | INTEGER | Yes | User ID from PAM system |
| key | STRING | Yes | Specific API key (see credentials repo) |

**Note**: Requires different API key than single bets API. Check credentials at:
`https://git.everymatrix.com/quants-oddsmatrix/combo-recsys/-/tree/main/credentials`

### 3. Player Performance API

**Purpose**: Provides profit/loss analytics and historic win patterns.

**Endpoints**: TBD (requires proper API key configuration)

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| domain_id | INTEGER | Yes | Operator/client ID |
| user_id | INTEGER | Yes | User ID from PAM system |
| specifier | STRING | Yes | Options: sport, league, participant, market_type, historic_wins |
| utc_timezone | STRING | No | User timezone (e.g., "UTC+3") |
| key | STRING | Yes | Specific API key |

## Complete Integration Flow

### Step 1: User Registration/Login
```javascript
// 1. Register or login user
const loginResponse = await fetch('https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: "+237666444002",
    password: "1234"
  })
});

const { userId, sessionId } = await loginResponse.json();
```

### Step 2: Get User Profile
```javascript
// 2. Fetch user details
const userDetails = await fetch(`https://betsson-api.stage.norway.everymatrix.com/v1/player/${userId}/details`, {
  headers: {
    'x-sessionid': sessionId
  }
});
```

### Step 3: Fetch Recommendations
```javascript
// 3. Get personalized recommendations
const recommendations = await fetch(`https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations?domain_id=4093&user_id=${userId}&is_live=false&terminal_type=1&key=YOUR_API_KEY`);

const data = await recommendations.json();
```

### Step 4: Process Recommendations
```javascript
// 4. Process and display recommendations
data.recommendations_list.forEach(event => {
  console.log(`Event ${event.eventId}: Interest Score ${event.interestScore}`);
  
  event.BetsRecommendationsList.forEach(bet => {
    console.log(`  - Market ${bet.marketId}, Betting Type ${bet.bettingTypeId}, Score: ${bet.interestScore}`);
  });
});
```

## API Response Formats

### Single Bets Recommendation Response
```json
{
  "is_live": false,
  "user_id": 7014240,
  "domain_id": 4093,
  "utm_content": "om_recsys_stage_2_test",
  "terminal_type": 1,
  "expiration_date": "2025-09-05 10:56:05.376408",
  "generation_date": "2025-09-05 10:49:05.376408",
  "recommendations_list": [
    {
      "eventId": "278269974795128832",
      "interestScore": 1.0,
      "expirationDate": "2025-09-05 10:56:05.376408",
      "BetsRecommendationsList": [
        {
          "marketId": "278269975017682944",
          "bettingTypeId": 69,
          "eventPartId": 3,
          "interestScore": 1.0
        },
        {
          "marketId": "278270654435162624",
          "bettingTypeId": 693,
          "eventPartId": 3,
          "interestScore": 0.9091
        }
      ]
    }
  ]
}
```

### Combo Bets Recommendation Response
```json
{
  "user_id": 123456789,
  "domain_id": 4093,
  "utm_content": "om_recsys_combo_test",
  "generation_date": "2025-03-28 12:25:50",
  "recommendations_list": [
    {
      "eventId": "1368184143312466",
      "marketId": "2675673814010919",
      "bettingTypeId": 69,
      "outcomeId": "2725343840723206",
      "outcomeTypeId": 10,
      "eventPartId": 3,
      "interestScore": 1.0
    }
  ]
}
```

### Player Performance Response (Sport)
```json
{
  "user_id": 123456789,
  "domain_id": 4093,
  "profit_and_loss_sport": [
    {
      "best": [
        {
          "sport_id": 8,
          "profit_eur": 275.50
        }
      ]
    },
    {
      "worst": [
        {
          "sport_id": 121,
          "profit_eur": -629.90
        }
      ]
    }
  ]
}
```

## Testing Guide

### Test Users (Betsson Cameroon Stage)
Available test users with betting history:
- **+237666999005** (Password: 4050) - Most bets, User ID: 7005274
- **+237666999007** (Password: 4050) - User ID: 7010350  
- **+237666999010** (Password: 4050)
- **+237666999001** (Password: 4050) - Older user, User ID: 6974909

### Testing Scenarios

#### 1. New User (Default Recommendations)
```bash
# Use non-existent user ID
curl -X GET "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations?\
domain_id=4093&user_id=999999999&is_live=false&terminal_type=1&\
key=AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho"
```
Result: Returns top 100 most popular Tier 1 & 2 events

#### 2. Active User (Personalized)
```bash
# Use user with betting history
curl -X GET "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations?\
domain_id=4093&user_id=7005274&is_live=false&terminal_type=1&\
key=AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho"
```
Result: Returns personalized recommendations based on betting history

### Manual Test Data Setup (BigQuery)

#### Add Test User to Active Users
```sql
DECLARE target_user STRING;
SET target_user = "123456789@@9999";
INSERT INTO `om-quants.RecSys_dev.active_users_testing`
VALUES (target_user);
```

#### Add Test Bets
```sql
DECLARE target_user STRING;
SET target_user = "123456789@@9999";

-- Add sample bets
INSERT INTO `om-quants.RecSys_dev.active_user_bets_testing` 
(cross_domain_user_id, sport_id, event_id, market_id, odds, bet_stake_amount_selection_share_eur)
VALUES 
(target_user, 1, 238106877471657984, 69, 2.33, 7.5),
(target_user, 1, 238110694741282816, 69, 1.80, 1.0);
```

Note: Precaching runs at 20:00 UTC daily. Test users will be included in next cache cycle.

## Troubleshooting

### Common Issues

#### 1. Getting Default Recommendations Instead of Personalized
**Causes**:
- User not in active users cache (no bets in last 60 days)
- User not enabled for personalized recommendations in production
- Domain not included in caching process

**Solution**:
- Verify user has recent betting history
- Check if domain_id is included in scheduled queries
- Wait for next cache cycle (20:00 UTC)

#### 2. API Returns 403 Permission Denied
**Cause**: Wrong API key for specific endpoint

**Solution**:
- Single Bets API: Use test key `AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho`
- Combo/Performance APIs: Check credentials repository for specific keys

#### 3. Empty or Minimal Recommendations
**Causes**:
- No upcoming events matching user profile
- Limited events in next 18-24 hour window

**Solution**: System falls back to default popular events automatically

### Interest Score Interpretation
- **1.0**: Highest interest, perfect match with user profile
- **0.5-0.99**: Strong match, recommended
- **0.1-0.49**: Moderate match
- **< 0.1**: Weak match, filler recommendation

### Performance Considerations
- Recommendations cached for 7 minutes (`expiration_date` - `generation_date`)
- Cache refreshed twice daily for active users
- API response includes up to 100 events with multiple markets each

## Production Deployment

### Enable Client for Production
1. Add domain_id to BigQuery scheduled query:
   - Navigate to: BigQuery → Scheduled queries → RecSys Cacher
   - Edit line 15: Add domain_id to list (e.g., `domain_id IN (2003, 2096, 4093)`)
   
2. Configure schedule:
   - Repeats: Every 24 hours
   - Run time: 20:00 UTC
   - Location: Multi-region EU
   - Service account: RecSys

3. Wait for first cache generation (may take several hours for new domains with many users)

## Additional Resources
- [RecSys 2nd Stage Overview](https://everymatrix.atlassian.net/wiki/spaces/OQ/pages/3955228822/RecSys+2nd+Stage+Overview)
- [Combo RecSys Documentation](https://everymatrix.atlassian.net/wiki/spaces/OQ/pages/5045059924/Combo+RecSys)
- [Player Performance API](https://everymatrix.atlassian.net/wiki/spaces/OQ/pages/4801036359/Player+Performance+API)

## Contact & Support
For API keys, production access, or technical support, contact the OM Quants team through internal channels.