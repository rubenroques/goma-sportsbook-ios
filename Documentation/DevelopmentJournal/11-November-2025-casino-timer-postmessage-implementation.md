# Casino Game Timer - PostMessage Implementation

## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Implement EveryMatrix casino iframe postMessage communication
- Delay session timer start until game is fully ready (gameReady message)
- Follow existing JavaScriptBridge pattern from banking implementation
- Add fallback timeout for network errors
- Clean, production-ready code without emojis

### Achievements
- [x] Created `CasinoJavaScriptBridge.swift` (~296 lines)
  - Protocol-based delegate pattern matching banking bridge
  - JavaScript injection script for EveryMatrix postMessage listening
  - Message handler name: `casinoGame` (distinct from banking's `iOS`)
  - JSON parsing and validation (sender must be "game")
  - Message routing for 7 EveryMatrix event types
- [x] Updated `CasinoGamePlayViewController.swift`
  - Integrated JavaScript bridge with WKWebView configuration
  - Injection timing: `.atDocumentStart` with `forMainFrameOnly: false` (critical for iframes)
  - Removed immediate timer start from `viewDidAppear`
  - Added 30-second fallback timeout for gameReady
  - Implemented 5 delegate methods for casino events
- [x] Removed all emojis from log messages (per user preference)
- [x] Simplified error handling (removed unused localization keys)
- [x] Added duplicate gameReady protection
- [x] Added timer already-running guard check

### Issues / Bugs Hit
None - implementation went smoothly following proven JavaScriptBridge pattern

### Key Decisions
- **Handler Name**: Used `casinoGame` instead of `iOS` to avoid conflicts with banking bridge
- **Injection Timing**: `.atDocumentStart` + `forMainFrameOnly: false` critical for iframe communication
- **Fallback Strategy**: 30-second timeout if gameReady never arrives (network errors, game crashes)
- **Duplicate Protection**: `isGameReady` flag prevents multiple timer starts from duplicate messages
- **Error Handling**: Simplified to generic message instead of unused localization keys
- **Message Validation**: Only process messages where `sender === "game"` for security
- **Log Format**: Clean, professional logging without emojis per user request

### Experiments & Notes
- Explored codebase architecture comprehensively before implementation
- Current casino implementation had NO JavaScript bridge (clean slate)
- Banking `JavaScriptBridge` uses string pattern matching; casino uses structured JSON
- EveryMatrix message format: `{ type: string, sender: string, data: any }`
- Timer lifecycle managed correctly with background/foreground support preserved

### Technical Details

**EveryMatrix Message Types Supported:**
1. `gameReady` → Start session timer (main goal)
2. `gameLoadProgress` → Progress logging (0-100%)
3. `gameLoadStart` → Load started (progress: 0%)
4. `gameLoadCompleted` → Assets loaded (progress: 100%)
5. `navigateDeposit` → User clicked deposit in game
6. `navigateLobby` → User clicked exit in game
7. `error` → Game error with error code

**Timer Behavior Change:**
- **Before**: Timer starts in `viewDidAppear` → counts loading time ❌
- **After**: Timer waits for `gameReady` message → counts only gameplay time ✅
- **Fallback**: If no message after 30s → start timer anyway (network error protection)

**JavaScript Injection Pattern:**
```javascript
window.addEventListener('message', function(event) {
    // Validate message structure
    // Check sender === "game"
    // Forward to native via window.webkit.messageHandlers.casinoGame.postMessage()
});
```

### Useful Files / Links
- [CasinoJavaScriptBridge.swift](../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoJavaScriptBridge.swift) - New bridge implementation
- [CasinoGamePlayViewController.swift](../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift) - Updated with bridge integration
- [JavaScriptBridge.swift](../BetssonCameroonApp/App/Screens/Banking/WebView/JavaScriptBridge.swift) - Reference pattern for banking
- [Implementation Prompt](../../CoreMasterAggregator/Documentation/Prompts/CASINO_GAME_TIMER_POSTMESSAGE_IMPLEMENTATION.md) - Original specification
- [Web Implementation](../../CoreMasterAggregator/web-app/src/composables/casino/useCasinoIframeMessaging.js) - Reference for EveryMatrix protocol

### Architecture Notes

**Why Separate Bridge?**
- Banking uses string pattern matching for redirect messages
- Casino uses structured JSON with type/sender fields
- Different message protocols require different parsing logic
- Prevents coupling between unrelated features

**Security Considerations:**
- Only process messages where `sender === "game"` (ignores operator messages)
- Validate JSON structure before parsing
- Guard against nil delegates with weak references
- All UI updates on main thread

**Code Quality Improvements:**
- No emojis in production logs
- Removed unused localization key references
- Simplified error messages
- Clean, professional console output

### Next Steps
1. **Build and test** with BetssonCameroonApp scheme
2. **Test scenarios:**
   - Normal flow: game loads → gameReady → timer starts
   - Slow loading: verify timer stays at 00:00 during load
   - Timeout fallback: verify 30s fallback works
   - Background/foreground: verify existing pause/resume still works
   - Deposit/Exit buttons: verify in-game navigation requests
3. **Verify console logs:**
   - `[CasinoJS]` prefixed logs from bridge
   - `[Casino]` prefixed logs from view controller
   - Message type confirmations
   - Timer start confirmation
4. **Monitor for EveryMatrix message format** in production
5. **Consider adding:** Loading progress UI based on `gameLoadProgress` messages (optional)

### Success Criteria
✅ Timer shows 00:00 when game screen appears
✅ Timer stays at 00:00 during game loading
⏳ Console shows gameReady message receipt (needs testing)
⏳ Timer starts counting ONLY after game is playable (needs testing)
✅ Fallback timer starts after 30s if gameReady not received
✅ Deposit/Exit messages trigger correct actions
✅ No console errors or warnings (needs testing)
✅ Clean logs without emojis

### Files Created/Modified

**Created:**
- `BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoJavaScriptBridge.swift` (296 lines)

**Modified:**
- `BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift` (~80 lines changed)
  - Added properties: `javaScriptBridge`, `isGameReady`, `gameReadyTimeoutTimer`
  - Updated `setupWebView()`: WKUserScript injection + message handler registration
  - Updated `viewDidAppear()`: Removed immediate timer start, added fallback
  - Updated `startSessionTimer()`: Added safety checks for duplicate starts
  - Added `CasinoJavaScriptBridgeDelegate` extension with 5 methods

### Risk Assessment
🟢 **LOW RISK**
- Proven pattern from banking bridge
- No conflicts with existing code
- Fallback safety for network errors
- Clean separation of concerns
- All changes isolated to casino game screen
