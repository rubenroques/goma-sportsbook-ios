## Date
25 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Explore cWAMP tool for testing WAMP WebSocket connections
- Understand how BetssonCameroon subscribes to live matches and odds updates
- Test real-time data flow from EveryMatrix WAMP API

### Achievements
- [x] Discovered cWAMP tool bug: `subscribe` command uses pub/sub but EveryMatrix uses REGISTER/INVOKE pattern
- [x] Mapped complete WAMP architecture flow from iOS app to ServicesProvider to WAMPManager
- [x] Documented that iOS uses `session.register()` not `session.subscribe()` for real-time updates
- [x] Verified autobahn library supports REGISTER pattern with `session.register(procedure, endpoint, options)`
- [x] Confirmed EveryMatrix sends 0 pub/sub events but does send INVOCATION messages to registered procedures
- [x] Implemented `cwamp register` command to receive real-time updates from EveryMatrix

### Issues / Bugs Hit
- [x] `cwamp subscribe` connects successfully but receives 0 events over 60 seconds
- [x] Initial confusion about operatorId (should be 4093, not 1 from examples)
- [x] EveryMatrix doesn't use WAMP pub/sub pattern for sports data topics

### Key Decisions
- Keep both `subscribe` and `register` commands in cWAMP for flexibility
- Pattern: client calls `session.register(topic)` → server INVOKEs it with data updates → autobahn auto-responds with YIELD
- Use same timeout/maxMessages pattern as subscribe for consistency

### Experiments & Notes
- Tested multiple topics: `/sports/4093/en/disciplines/LIVE/BOTH`, match-odds topics, all received 0 pub/sub events
- RPC calls work perfectly: `/sports#operatorInfo`, `/sports#matches`, `/sports#initialDump`
- Initial dump pattern works as REST-like GET: `cwamp rpc --procedure "/sports#initialDump" --kwargs '{"topic": "..."}'`
- iOS WAMPManager.registerOnEndpoint() is the key - uses REGISTER not SUBSCRIBE
- Real-time flow: Register → Server sends INVOCATION (msg type 68) → Client sends YIELD (msg type 70)

### Useful Files / Links
- [cWAMP Tool](Tools/wamp-client/)
- [WAMPClient Source](Tools/wamp-client/src/wamp-client.js)
- [cWAMP CLI](Tools/wamp-client/bin/cwamp.js)
- [WAMPManager.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPManager.swift:442-552)
- [WAMPRouter.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPRouter.swift)
- [EveryMatrixSocketConnector.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSocketConnector.swift)
- [EntityStore.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Store/EntityStore.swift)
- [SSWampSession.swift](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMP/SSWampSession.swift:187)
- [Autobahn session.js](tools/wamp-client/node_modules/autobahn/lib/session.js:1376)

### Architecture Insights

**WAMP Message Types:**
- REGISTER: 64 (client registers procedure)
- REGISTERED: 65 (server confirms)
- INVOCATION: 68 (server calls registered procedure)
- YIELD: 70 (client responds)

**iOS Real-Time Data Flow:**
```
ViewModel
  → ServicesProvider.subscribeToFilteredLiveMatches()
    → EveryMatrixEventsProvider
      → LiveMatchesPaginator
        → EveryMatrixSocketConnector.subscribe()
          → WAMPManager.registerOnEndpoint()
            → swampSession.register(topic, onSuccess, onError, onEvent)
              → onEvent receives INVOCATION messages with odds updates
                → EntityStore processes delta updates
                  → Combine publishers notify UI
```

**cWAMP Implementation:**
```javascript
// New register() method in WAMPClient
session.register(procedure, invocationHandler, options).then(
  (registration) => {
    // Connected - registration.id available
    // invocationHandler called when server INVOKEs
  }
);

// invocationHandler receives (args, kwargs, details)
// Returns value for automatic YIELD response
```

### Next Steps
1. Test `cwamp register` with live EveryMatrix topics to verify real-time updates
2. Document REGISTER vs SUBSCRIBE pattern differences in cWAMP README
3. Add example usage in EXAMPLES.md
4. Consider adding interactive mode support for register command
