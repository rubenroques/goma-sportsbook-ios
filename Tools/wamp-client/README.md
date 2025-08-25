# cWAMP - cURL for WAMP Protocol

A command-line tool for interacting with WAMP (Web Application Messaging Protocol) servers, inspired by cURL. Just as cURL is for HTTP, cWAMP is for WAMP WebSocket connections.

## Installation

### Global Installation (Recommended)

```bash
# From the project directory
cd tools/wamp-client
npm install -g .

# Or directly
npm install -g /path/to/tools/wamp-client
```

### Local Installation

```bash
cd tools/wamp-client
npm install
```

## Configuration

cWAMP looks for configuration in the following locations (in order):
1. `.cwamp.env` in current directory
2. `.env` in current directory  
3. `.cwamp.env` in home directory
4. `.env` in the package directory

Create your configuration file:

```bash
# For global config
cp .env.example ~/.cwamp.env

# Or for project-specific config
cp .env.example .cwamp.env
```

Edit the configuration with your server details:

```env
WAMP_URL=wss://sportsapi-betsson-stage.everymatrix.com/v2
WAMP_REALM=www.betsson.cm
WAMP_ORIGIN=https://sportsbook-stage.gomagaming.com
```

## Usage

### Command-Line Interface

#### Test Connection

```bash
cwamp test
```

#### RPC Calls

Make RPC calls to the WAMP server:

```bash
# Get operator info
cwamp rpc --procedure "/sports#operatorInfo"

# Get tournaments with parameters
cwamp rpc \
  --procedure "/sports#tournaments" \
  --kwargs '{"lang":"en","sportId":"1"}'

# Get match details
cwamp rpc \
  --procedure "/sports#matches" \
  --kwargs '{"lang":"en","matchId":"12345"}'

# Search
cwamp rpc \
  --procedure "/sports#searchV2" \
  --kwargs '{"lang":"en","limit":10,"query":"barcelona","eventStatuses":[1,2],"include":["matches"],"bettingTypeIds":[1],"dataWithoutOdds":false}'
```

#### Subscriptions

Subscribe to real-time updates:

```bash
# Subscribe to live matches
cwamp subscribe \
  --topic "/sports/1/en/live-matches-aggregator-main/1/all-locations/default-event-info/10/5" \
  --duration 5000 \
  --max-messages 10

# Subscribe with initial dump
cwamp subscribe \
  --topic "/sports/1/en/popular-matches-aggregator-main/1/10/5" \
  --initial-dump \
  --duration 10000

# Subscribe to match details
cwamp subscribe \
  --topic "/sports/1/en/match-aggregator-groups-overview/12345/1" \
  --duration 30000
```

#### Interactive Mode

Start an interactive session:

```bash
cwamp interactive
```

Commands in interactive mode:
- `rpc <procedure> [args] [kwargs]` - Make RPC call
- `subscribe <topic>` - Subscribe to topic
- `unsubscribe <topic>` - Unsubscribe from topic
- `status` - Show connection status
- `help` - Show available commands
- `exit` - Disconnect and quit

### Options

Global options available for all commands:

- `--debug` - Enable debug output
- `--pretty` - Pretty print JSON output
- `--timeout <ms>` - Set operation timeout (for RPC calls)
- `--duration <ms>` - Set listening duration (for subscriptions)
- `--max-messages <count>` - Maximum messages to collect (for subscriptions)

## Examples for Claude Code

### Getting Tournament Data

```bash
# Get all tournaments for football (sportId: 1)
cwamp rpc \
  --procedure "/sports#tournaments" \
  --kwargs '{"lang":"en","sportId":"1","liveStatus":"BOTH","sortByPopularity":true}' \
  --pretty

# Get popular tournaments
cwamp rpc \
  --procedure "/sports#popularTournaments" \
  --kwargs '{"lang":"en","sportId":"1","maxResults":10}' \
  --pretty
```

### Getting Match Data

```bash
# Get match details
cwamp rpc \
  --procedure "/sports#matches" \
  --kwargs '{"lang":"en","matchId":"123456"}' \
  --pretty

# Get match odds
cwamp rpc \
  --procedure "/sports#odds" \
  --kwargs '{"lang":"en","matchId":"123456","bettingTypeId":"1"}' \
  --pretty
```

### Subscribing to Live Updates

```bash
# Live matches for football
cwamp subscribe \
  --topic "/sports/1/en/live-matches-aggregator-main/1/all-locations/default-event-info/20/5" \
  --duration 10000 \
  --pretty

# Popular matches with initial data
cwamp subscribe \
  --topic "/sports/1/en/popular-matches-aggregator-main/1/10/5" \
  --initial-dump \
  --duration 5000 \
  --pretty

# Match odds updates
cwamp subscribe \
  --topic "/sports/1/en/123456/match-odds" \
  --duration 30000 \
  --pretty
```

## EveryMatrix-Specific Endpoints

### RPC Procedures

- `/sports#operatorInfo` - Get operator information
- `/sports#disciplines` - Get available sports
- `/sports#locations` - Get locations/countries
- `/sports#tournaments` - Get tournaments
- `/sports#popularTournaments` - Get popular tournaments
- `/sports#matches` - Get match details
- `/sports#popularMatches` - Get popular matches
- `/sports#todayMatches` - Get today's matches
- `/sports#nextMatches` - Get upcoming matches
- `/sports#odds` - Get odds for a match
- `/sports#searchV2` - Search for events
- `/sports#initialDump` - Get initial data for a subscription topic

### Subscription Topics

Topics follow the pattern: `/sports/{operatorId}/{language}/{type}/{parameters}`

Examples:
- `/sports/1/en/live-matches-aggregator-main/{sportId}/{locationId}/{eventInfo}/{eventLimit}/{marketLimit}`
- `/sports/1/en/popular-matches-aggregator-main/{sportId}/{eventLimit}/{marketLimit}`
- `/sports/1/en/match-aggregator-groups-overview/{matchId}/{groupLevel}`
- `/sports/1/en/{matchId}/match-odds`

## Troubleshooting

### Connection Issues

1. Check `.env` configuration
2. Verify WebSocket URL is accessible
3. Ensure realm matches server configuration
4. Check for firewall/proxy issues

### Debug Mode

Enable debug mode to see detailed messages:

```bash
cwamp rpc --procedure "/sports#operatorInfo" --debug
```

Or set in `.env`:

```env
WAMP_DEBUG=true
```

### Common Error Messages

- `Connection timeout` - Server not reachable or slow response
- `RPC call timeout` - Request took too long, increase timeout
- `Invalid realm` - Check WAMP_REALM configuration
- `Not authorized` - Authentication required or invalid credentials

## Development

### Running Tests

```bash
npm test
```

### Project Structure

```
tools/wamp-client/
├── bin/
│   └── wamp-cli.js          # CLI interface
├── src/
│   ├── wamp-client.js       # Main WAMP client
│   ├── message-formatter.js # WAMP protocol messages
│   └── config.js            # Configuration loader
├── test/
│   └── test-connection.js   # Test suite
├── .env.example             # Example configuration
└── package.json             # Dependencies
```

## License

MIT