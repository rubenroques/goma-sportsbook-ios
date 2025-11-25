# cWAMP - Usage Examples

cURL for WAMP Protocol - Just as cURL is for HTTP, cWAMP is for WAMP WebSocket connections.

## Quick Start

### Global Installation

```bash
npm install -g /path/to/tools/wamp-client
# Create config
echo "WAMP_URL=wss://your-server.com/v2" > ~/.cwamp.env
echo "WAMP_REALM=your.domain.com" >> ~/.cwamp.env
echo "WAMP_CID=your-client-id" >> ~/.cwamp.env
```

### Test Connection

```bash
cwamp test
```

## Basic Commands

### 1. Test Connection

```bash
cwamp test
```

Expected output:
```
✓ Connection successful
Session ID: 434876467897206
✓ RPC call successful
✓ Disconnection successful
```

### 2. RPC Calls

#### Get Operator Information
```bash
cwamp rpc \
  --procedure "/sports#operatorInfo" \
  --pretty
```

#### Get Tournaments
```bash
cwamp rpc \
  --procedure "/sports#tournaments" \
  --kwargs '{"lang":"en","sportId":"1"}' \
  --pretty
```

#### Get Popular Tournaments
```bash
cwamp rpc \
  --procedure "/sports#popularTournaments" \
  --kwargs '{"lang":"en","sportId":"1","maxResults":5}' \
  --pretty
```

#### Search Events
```bash
cwamp rpc \
  --procedure "/sports#searchV2" \
  --kwargs '{"lang":"en","limit":5,"query":"barcelona","eventStatuses":[1,2],"include":["matches"],"bettingTypeIds":[1],"dataWithoutOdds":false}' \
  --pretty
```

### 3. Register for Real-Time Data (Recommended for EveryMatrix)

EveryMatrix uses WAMP REGISTER/INVOKE pattern. Use `register` to receive real-time updates:

#### Register for Live Sports Updates
```bash
cwamp register \
  --procedure "/sports/4093/en/disciplines/LIVE/BOTH" \
  --duration 30000 \
  --pretty
```

Expected output:
```json
{
  "status": "success",
  "procedure": "/sports/4093/en/disciplines/LIVE/BOTH",
  "invocations": [
    {
      "timestamp": 1732500000000,
      "kwargs": {
        "version": "1764033303918",
        "format": "BASIC",
        "messageType": "UPDATE",
        "records": [
          {
            "changeType": "UPDATE",
            "entityType": "SPORT",
            "id": "1",
            "changedProperties": {
              "numberOfLiveEvents": 5,
              "numberOfLiveMarkets": 357
            }
          }
        ]
      }
    }
  ],
  "duration": 30000
}
```

#### Register with Initial Dump (Recommended)
```bash
cwamp register \
  --procedure "/sports/4093/en/disciplines/LIVE/BOTH" \
  --initial-dump \
  --duration 30000 \
  --pretty
```

This fetches the current state first (via RPC), then registers for updates - exactly like the iOS app.

#### Register for Match Odds Updates
```bash
cwamp register \
  --procedure "/sports/4093/en/287742034424664064/match-odds" \
  --initial-dump \
  --duration 60000 \
  --verbose
```

#### Collect Limited Invocations
```bash
# Exit after receiving 5 updates
cwamp register \
  --procedure "/sports/4093/en/disciplines/LIVE/BOTH" \
  --max-messages 5 \
  --pretty
```

### 4. Subscriptions (Pub/Sub - Limited Use)

> **Note**: EveryMatrix doesn't use pub/sub for most data. Use `register` instead.

#### Subscribe to Live Sports (may receive 0 events)
```bash
cwamp subscribe \
  --topic "/sports/1/en/disciplines/LIVE/BOTH" \
  --duration 5000 \
  --max-messages 3 \
  --pretty
```

#### Subscribe with Initial Dump
```bash
cwamp subscribe \
  --topic "/sports/1/en/popular-matches-aggregator-main/1/10/5" \
  --initial-dump \
  --duration 5000 \
  --pretty
```

### 5. Interactive Mode

Start an interactive WAMP session:

```bash
cwamp interactive
```

Commands in interactive mode:
- `rpc <procedure> [args] [kwargs]` - Make RPC call
- `subscribe <topic>` - Subscribe to topic
- `status` - Show connection status
- `help` - Show available commands
- `exit` - Disconnect and quit

## Advanced Examples

### Get Match Details

```bash
# Replace 123456 with actual match ID
cwamp rpc \
  --procedure "/sports#matches" \
  --kwargs '{"lang":"en","matchId":"123456"}' \
  --pretty
```

### Get Match Odds

```bash
cwamp rpc \
  --procedure "/sports#odds" \
  --kwargs '{"lang":"en","matchId":"123456","bettingTypeId":"1"}' \
  --pretty
```

### Subscribe to Match Updates

```bash
# Replace 123456 with actual match ID
cwamp subscribe \
  --topic "/sports/1/en/123456/match-odds" \
  --duration 30000 \
  --pretty
```

### Get Locations (Countries)

```bash
cwamp rpc \
  --procedure "/sports#locations" \
  --kwargs '{"lang":"en","sortByPopularity":"true"}' \
  --pretty
```

## Using in Scripts

### Bash Script Example

```bash
#!/bin/bash

# Get tournaments and save to file
cwamp rpc \
  --procedure "/sports#tournaments" \
  --kwargs '{"lang":"en","sportId":"1"}' \
  --pretty > tournaments.json

# Process with jq
cat tournaments.json | jq '.result.kwargs.records[0:5]'
```

### Node.js Script Example

```javascript
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function getTournaments() {
  const { stdout } = await execPromise(
    `cwamp rpc --procedure "/sports#tournaments" --kwargs '{"lang":"en","sportId":"1"}'`
  );
  
  const result = JSON.parse(stdout);
  return result.result.kwargs.records;
}

getTournaments().then(tournaments => {
  console.log(`Found ${tournaments.length} tournaments`);
});
```

## Environment Variables

Create a `.env` file with:

```env
# WAMP Connection
WAMP_URL=wss://sportsapi-betsson-stage.everymatrix.com/v2
WAMP_CID=STAGE_2-STAGE_2r5IxUlPqfCgPlWiXbAJdsHM
WAMP_REALM=www.betsson.cm
WAMP_ORIGIN=https://clientsample-sports-stage.everymatrix.com

# Timeouts (milliseconds)
WAMP_TIMEOUT_CONNECTION=5000
WAMP_TIMEOUT_RPC=10000
WAMP_TIMEOUT_SUBSCRIPTION=30000

# Debug mode
WAMP_DEBUG=false
```

## EveryMatrix API Reference

### Common RPC Procedures

| Procedure | Description | Parameters |
|-----------|-------------|------------|
| `/sports#operatorInfo` | Get operator information | None |
| `/sports#disciplines` | Get available sports | `lang` |
| `/sports#locations` | Get locations/countries | `lang`, `sortByPopularity` |
| `/sports#tournaments` | Get tournaments | `lang`, `sportId`, `liveStatus`, `sortByPopularity` |
| `/sports#popularTournaments` | Get popular tournaments | `lang`, `sportId`, `maxResults` |
| `/sports#matches` | Get match details | `lang`, `matchId` |
| `/sports#popularMatches` | Get popular matches | `lang`, `sportId` |
| `/sports#todayMatches` | Get today's matches | `lang`, `sportId` |
| `/sports#odds` | Get odds for match | `lang`, `matchId`, `bettingTypeId` |
| `/sports#searchV2` | Search events | `lang`, `limit`, `query`, `eventStatuses`, `include`, `bettingTypeIds` |
| `/sports#initialDump` | Get initial data for topic | `topic` |

### Register Procedures (Real-Time Updates)

Use with `cwamp register` to receive real-time INVOKE messages:

| Procedure Pattern | Description |
|-------------------|-------------|
| `/sports/{operatorId}/{lang}/disciplines/LIVE/BOTH` | Live sports with real-time updates |
| `/sports/{operatorId}/{lang}/disciplines/BOTH/BOTH` | All sports (live + prematch) |
| `/sports/{operatorId}/{lang}/{matchId}/match-odds` | Match odds real-time updates |
| `/sports/{operatorId}/{lang}/live-matches-aggregator-main/{sportId}/...` | Live matches for a sport |

**Operator ID**: `4093` (Betsson Cameroon staging)

### Common Subscription Topics (Pub/Sub - Limited Use)

| Topic Pattern | Description |
|---------------|-------------|
| `/sports/{operatorId}/{lang}/live-matches-aggregator-main/{sportId}/{locationId}/{eventInfo}/{eventLimit}/{marketLimit}` | Live matches |
| `/sports/{operatorId}/{lang}/popular-matches-aggregator-main/{sportId}/{eventLimit}/{marketLimit}` | Popular matches |
| `/sports/{operatorId}/{lang}/next-matches-aggregator-main/{sportId}/{eventLimit}/{marketLimit}` | Upcoming matches |
| `/sports/{operatorId}/{lang}/match-aggregator-groups-overview/{matchId}/{groupLevel}` | Match details |
| `/sports/{operatorId}/{lang}/{matchId}/match-odds` | Match odds updates |
| `/sports/{operatorId}/{lang}/disciplines/LIVE/BOTH` | Live sports |

### Sport IDs

- `1` - Football
- `2` - Tennis  
- `3` - Basketball
- `4` - Ice Hockey
- `5` - American Football
- `6` - Baseball
- `7` - Handball
- `8` - Rugby Union
- `9` - Volleyball

## Troubleshooting

### Connection Issues

1. **Check CID is valid**: The client ID in `.env` must be active
2. **Verify realm**: Should be `www.betsson.cm` for this environment
3. **Enable debug mode**: Set `WAMP_DEBUG=true` in `.env`

### Common Errors

| Error | Solution |
|-------|----------|
| `Unrecognized domain` | Check WAMP_REALM in .env |
| `Connection timeout` | Increase WAMP_TIMEOUT_CONNECTION |
| `RPC call timeout` | Increase WAMP_TIMEOUT_RPC |
| `No messages received` | Topic may not have active data |
| `subscribe` returns 0 events | Use `register` instead - EveryMatrix uses REGISTER/INVOKE pattern |
| `register` returns 0 invocations | Check procedure URI format, ensure operatorId (4093) is correct |

## For Claude Code

When using this tool with Claude Code, you can execute commands directly:

```bash
# Get live match data via RPC
cd tools/wamp-client && cwamp rpc --procedure "/sports#matches" --kwargs '{"lang":"en","matchId":"123"}' --pretty

# Register for real-time updates (RECOMMENDED for EveryMatrix)
cd tools/wamp-client && cwamp register --procedure "/sports/4093/en/disciplines/LIVE/BOTH" --initial-dump --duration 30000 --pretty

# Register with verbose logging to see each update
cd tools/wamp-client && cwamp register --procedure "/sports/4093/en/disciplines/LIVE/BOTH" --duration 30000 --verbose

# Subscribe to topics (pub/sub - may receive 0 events from EveryMatrix)
cd tools/wamp-client && cwamp subscribe --topic "/sports/1/en/disciplines/LIVE/BOTH" --duration 10000 --pretty
```

**Key difference:**
- `cwamp rpc` - One-time request/response
- `cwamp register` - Real-time streaming via INVOKE (use this for live data)
- `cwamp subscribe` - Pub/sub pattern (EveryMatrix doesn't use this)

The tool outputs JSON, making it easy to parse and use the data in your automation scripts.