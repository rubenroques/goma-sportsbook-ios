## Date
25 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Add WAMP REGISTER command to cWAMP tool
- Fix missing real-time data updates (subscribe was returning 0 events)
- Update cWAMP documentation

### Achievements
- [x] Discovered EveryMatrix uses REGISTER/INVOKE pattern, not pub/sub
- [x] Added `registrations` Map to WAMPClient constructor
- [x] Implemented `register()` method in wamp-client.js
- [x] Implemented `unregister()` method in wamp-client.js
- [x] Updated `disconnect()` to unregister all procedures on cleanup
- [x] Added `cwamp register` CLI command with full options
- [x] Verified real-time data streaming works (multiple invocations received)
- [x] Updated README.md with register command documentation
- [x] Updated EXAMPLES.md with register examples and troubleshooting

### Issues / Bugs Hit
- [x] Initial `cwamp subscribe` returned 0 events - SOLVED: EveryMatrix doesn't use pub/sub
- [x] First `cwamp register` test returned 0 invocations - SOLVED: timing/activity issue, worked on retry

### Key Decisions
- Keep both `subscribe` and `register` commands (user preference from previous session)
- Use same options pattern as `subscribe` (`-p/--procedure`, `-d/--duration`, `-m/--max-messages`, `--initial-dump`)
- Follow existing WAMPClient patterns for consistency
- Document that EveryMatrix uses REGISTER/INVOKE, not pub/sub

### Experiments & Notes
- `session.subscribe()` connects successfully but receives 0 events from EveryMatrix
- `session.register()` receives real-time INVOKE messages with UPDATE data
- iOS app uses `WAMPManager.registerOnEndpoint()` → `swampSession.register()` for real-time updates
- Initial dump via RPC (`/sports#initialDump`) + register = complete iOS app pattern

### Useful Files / Links
- [wamp-client.js](../../tools/wamp-client/src/wamp-client.js) - WAMPClient class with new register/unregister methods
- [cwamp.js](../../tools/wamp-client/bin/cwamp.js) - CLI with new register command
- [README.md](../../tools/wamp-client/README.md) - Updated documentation
- [EXAMPLES.md](../../tools/wamp-client/EXAMPLES.md) - Updated examples
- [Plan file](~/.claude/plans/scalable-crunching-hickey.md) - Implementation plan

### Next Steps
1. Test register command with more procedure URIs (match-odds, live-matches-aggregator, etc.)
2. Consider adding register to interactive mode
3. Explore other EveryMatrix WAMP patterns if needed
