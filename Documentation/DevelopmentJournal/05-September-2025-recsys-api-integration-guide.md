## Date
05 September 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Investigate RecSys (Recommendation System) API integration
- Document how to connect RecSys recommendations to real-time odds via WAMP
- Create frontend integration guide for the team
- Test complete RecSys → WAMP pipeline

### Achievements
- [x] Discovered and tested 3 RecSys APIs: Single Bets, Combo Bets, Player Performance
- [x] Successfully connected RecSys event IDs to WAMP WebSocket subscriptions
- [x] Created comprehensive BET-RECOMMENDATION-SYSTEM-API-GUIDE.md with full technical specs
- [x] Created frontend-focused RecSys-Frontend-Integration-Guide.md for development teams
- [x] Tested complete integration pipeline: RecSys → Event ID → WAMP subscription → Real-time odds
- [x] Documented all API keys, endpoints, and subscription topic patterns
- [x] Verified working cURL commands for both RecSys APIs

### Issues / Bugs Hit
- [x] Initial RecSys API calls failed due to missing required parameters (is_live, terminal_type)
- [x] Combo Bets API returned 403 errors - required different API key than Single Bets
- [x] Player Performance API inaccessible - needs separate API key configuration
- [x] WAMP subscriptions returned empty messages - stage environment has no live streaming data
- [x] WAMP initial dump RPC calls failing - server-side issue, not integration problem

### Key Decisions
- **API Integration Architecture**: RecSys provides event/market IDs → WAMP provides real-time odds updates
- **Dual API Approach**: Single Bets API (up to 100 events with multiple markets) vs Combo Bets API (exactly 50 specific outcomes)
- **Documentation Strategy**: Created both technical (complete API specs) and frontend-focused (integration-only) guides
- **Test Environment Validation**: Used Betsson Cameroon stage environment with real test users
- **WAMP Topic Pattern**: `/sports/1/en/{eventId}/match-odds` for real-time odds subscriptions

### Experiments & Notes
- **RecSys Interest Scoring**: Formula is `stake * SQRT(odds - 1)` - normalized 0-1 for ML models
- **WAMP Client Tool**: Used existing `Tools/wamp-client` (cWAMP) for WebSocket testing - works perfectly
- **Cache Timing**: RecSys recommendations expire after 7 minutes, refresh twice daily
- **User Personalization**: Requires betting history in last 60 days, otherwise serves default popular recommendations
- **ML Models**: System uses Linear Regression/XGBoost for prediction based on user profiles

### Useful Files / Links
- [BET-RECOMMENDATION-SYSTEM-API-GUIDE.md](../BET-RECOMMENDATION-SYSTEM-API-GUIDE.md) - Complete technical documentation
- [RecSys-Frontend-Integration-Guide.md](../RecSys-Frontend-Integration-Guide.md) - Frontend team integration guide
- [Tools/wamp-client](../../Tools/wamp-client/) - WAMP WebSocket client for testing
- [CLAUDE.md](../../CLAUDE.md#cwamp---websocket-wamp-client-tool) - cWAMP tool documentation

### API Endpoints Discovered
**RecSys APIs:**
- Single Bets: `https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev/recommendations`
- Combo Bets: `https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev/recommendations` 
- API Keys: `AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho` (Single), `AIzaSyAQog-N-vXGDNWldHPfM9qzR5vOMeJDspE` (Combo)

**WAMP WebSocket:**
- URL: `wss://sportsapi-betsson-stage.everymatrix.com/v2`
- Realm: `www.betsson.cm`
- Working RPC: `/sports#matches`, `/sports#odds`
- Working Topics: `/sports/1/en/{eventId}/match-odds`

### Test Data Used
- Domain ID: 4093 (Betsson Cameroon)
- Test User IDs: 7005274, 7010350, 6974909
- Sample Event ID: 278269974795128832 (Ukraine vs France, Jan 16 2025)
- Working Integration: RecSys → WAMP subscription confirmed functional

### Next Steps  
1. Share RecSys-Frontend-Integration-Guide.md with frontend team
2. Obtain production API keys and endpoints from RecSys team
3. Test integration with live events when available
4. Implement caching strategy for RecSys recommendations in frontend
5. Consider Player Performance API integration once access keys are available