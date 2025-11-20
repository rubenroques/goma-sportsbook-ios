# GomaLogger Migration Guide

This guide helps you migrate from `print()` statements to GomaLogger systematically.

## Migration Strategy

**Approach**: Gradual coexistence - GomaLogger and `print()` can coexist during migration.

### Guidelines

1. ✅ **New code**: Use GomaLogger exclusively
2. ✅ **Bug fixes**: Convert print() when modifying files
3. ✅ **No rush**: Migrate at a comfortable pace
4. ✅ **Verify**: Test logging output after conversion

## Quick Reference

### Pattern Mapping

Based on analysis of 2,560 print statements in the codebase, here are the most common patterns:

| Old Pattern | New Pattern | Count |
|-------------|-------------|-------|
| `print("[SSEDebug] ...")` | `GomaLogger.debug(.realtime, category: "SSE", "...")` | 134 |
| `print("[SERVICEPROVIDER] ...")` | `GomaLogger.debug(.networking, category: "SP", "...")` | 95 |
| `print("[LIVE_SCORE] ...")` | `GomaLogger.debug(.realtime, category: "LIVE_SCORE", "...")` | 47 |
| `print("[GOMAAPI] ...")` | `GomaLogger.debug(.networking, category: "GOMAAPI", "...")` | 29 |
| `print("BLINK_DEBUG [VC] ...")` | `GomaLogger.debug(.ui, category: "VC", "...")` | 31 |
| `print("[ODDS_BOOST] ...")` | `GomaLogger.debug(.betting, category: "ODDS_BOOST", "...")` | 12 |
| `print("[AUTH_DEBUG] ...")` | `GomaLogger.debug(.authentication, category: "AUTH", "...")` | 20 |

## Step-by-Step Migration

### Step 1: Import GomaLogger

Add import at the top of your file:

```swift
import GomaLogger
```

### Step 2: Identify Pattern

Look at your print statement and identify its pattern:

```swift
// Example patterns found in codebase:
print("[ODDS_BOOST] Fetching stairs for \(count) selections")
print("BLINK_DEBUG [MatchDetailsVC] 🔔 Market update #\(counter)")
print("[SSEDebug] 📡 Starting stream")
print("ERROR: Login failed - \(error)")
```

### Step 3: Apply Transformation

Use the pattern tables below to convert.

## Pattern Transformation Tables

### Bracket Tag Pattern: `[TAG_NAME] message`

**Before:**
```swift
print("[ODDS_BOOST] Fetching stairs for \(count) selections")
print("[BETTING_OPTIONS] Validating \(selections.count) selections")
print("[BET_PLACEMENT] Placing bet with stake \(stake)")
```

**After:**
```swift
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching stairs for \(count) selections")
GomaLogger.debug(.betting, category: "BETTING_OPTIONS", "Validating \(selections.count) selections")
GomaLogger.info(.betting, category: "BET_PLACEMENT", "Placing bet with stake \(stake)")
```

**Regex for find/replace:**
```regex
Find: print\("\[([A-Z_]+)\] (.+)"\)
Replace: GomaLogger.debug(.general, category: "$1", "$2")
```
*Note: You'll need to manually adjust the subsystem (.general → appropriate subsystem)*

---

### BLINK_DEBUG Pattern: `BLINK_DEBUG [Component] message`

**Before:**
```swift
print("BLINK_DEBUG [MatchDetailsVC] 🔔 Market groups update #\(counter)")
print("BLINK_DEBUG [MarketsTabVM] 🔄 Update #\(updateCounter)")
print("BLINK_DEBUG [MarketGroupSelectorVM] ✅ WebSocket CONNECTED")
```

**After:**
```swift
GomaLogger.debug(.ui, category: "MatchDetailsVC", "Market groups update #\(counter)")
GomaLogger.debug(.ui, category: "MarketsTabVM", "Update #\(updateCounter)")
GomaLogger.debug(.ui, category: "MarketGroupSelectorVM", "WebSocket CONNECTED")
```

*Note: Emojis are automatically added by log level, so you can remove them from messages*

---

### SSEDebug / Auth Pattern

**Before:**
```swift
print("[SSEDebug] 📡 Starting UserInfo SSE stream")
print("[SSEDebug] ✅ SSE connected - subscription ID: \(id)")
print("[SSEDebug] ❌ SSE stream error: \(error)")
print("[AUTH_DEBUG] 🔐 UserSessionStore: login() called")
```

**After:**
```swift
GomaLogger.debug(.realtime, category: "SSE", "Starting UserInfo SSE stream")
GomaLogger.debug(.realtime, category: "SSE", "SSE connected - subscription ID: \(id)")
GomaLogger.error(.realtime, category: "SSE", "SSE stream error: \(error)")
GomaLogger.debug(.authentication, category: "AUTH", "UserSessionStore: login() called")
```

---

### Socket Debug Pattern: `SocketSocialDebug: message`

**Before:**
```swift
print("SocketSocialDebug: Connected")
print("SocketSocialDebug: ⚠️ Disconnected ⚠️")
print("SocketSocialDebug: error \(data)")
print("SocketDebug: on social.chatroom.\(id): \(data)")
```

**After:**
```swift
GomaLogger.debug(.networking, category: "Socket", "Connected")
GomaLogger.error(.networking, category: "Socket", "Disconnected")
GomaLogger.error(.networking, category: "Socket", "error \(data)")
GomaLogger.debug(.networking, category: "Socket", "on social.chatroom.\(id): \(data)")
```

---

### Error Pattern: `ERROR: message` or `XXX ERROR: message`

**Before:**
```swift
print("FAVORITE EVENTS ERROR: \(error)")
print("PAYMENTS RESPONSE ERROR: \(error)")
print("PROCESS DEPOSIT RESPONSE ERROR: \(error)")
print("CHATROOMS ERROR: \(error)")
```

**After:**
```swift
GomaLogger.error(.general, "Favorite events failed", metadata: ["error": error])
GomaLogger.error(.payments, "Payment response failed", metadata: ["error": error])
GomaLogger.error(.payments, "Deposit processing failed", metadata: ["error": error])
GomaLogger.error(.social, "Chatrooms request failed", metadata: ["error": error])
```

---

### GOMAAPI Debug Pattern

**Before:**
```swift
print("[GOMAAPI][DEBUG] GomaAuthenticator loggedUserValidToken")
print("[GOMAAPI][DEBUG] New Session Token [logged] \(token)")
print("[GOMAAPI][DEBUG] Decoding Error: \(error)")
```

**After:**
```swift
GomaLogger.debug(.networking, category: "GOMAAPI", "GomaAuthenticator loggedUserValidToken")
GomaLogger.debug(.networking, category: "GOMAAPI", "New Session Token [logged] \(token.hash)")
GomaLogger.error(.networking, category: "GOMAAPI", "Decoding Error: \(error)")
```

---

### Simple/Untagged Pattern

**Before:**
```swift
print("App Started")
print("User logged in")
print("Tapped share")
```

**After:**
```swift
GomaLogger.info("App Started")
GomaLogger.debug("User logged in")
GomaLogger.debug("Tapped share")
```

---

## Choosing Log Levels

| Situation | Use Level | Example |
|-----------|-----------|---------|
| Debugging info during development | `.debug` | "Button tapped", "View appeared", "Data updated" |
| Important state changes | `.info` | "User logged in", "Bet placed", "Payment completed" |
| Errors and failures | `.error` | "API call failed", "Invalid data", "Connection error" |

**Rule of thumb:**
- If it helps you debug an issue → `.debug`
- If you'd want to see it in production logs → `.info`
- If something went wrong → `.error`

---

## Choosing Subsystems

Map your feature/module to a subsystem:

| Your Code Area | Use Subsystem | Examples |
|----------------|---------------|----------|
| Login, auth, sessions, SSE | `.authentication` | Login flow, token refresh, SSE streams |
| Betting, odds, betslip | `.betting` | Placing bets, odds updates, betslip |
| Network requests, APIs | `.networking` | API calls, HTTP requests, WebSocket |
| Live data, subscriptions | `.realtime` | Live scores, WAMP, streaming data |
| ViewControllers, Views, ViewModels | `.ui` | UI lifecycle, user interactions |
| Payments, transactions | `.payments` | Deposits, withdrawals, payment flows |
| Friends, chat, social | `.social` | Social features |
| Performance tracking | `.performance` | Timing, metrics |
| Analytics events | `.analytics` | Event tracking |
| Everything else | `.general` | General purpose |

---

## Common Subsystem + Category Combinations

Based on analysis of existing tags:

```swift
// Authentication
GomaLogger.debug(.authentication, category: "AUTH", ...)
GomaLogger.debug(.authentication, category: "SSE", ...)
GomaLogger.debug(.authentication, category: "XTREMEPUSH", ...)

// Betting
GomaLogger.debug(.betting, category: "ODDS_BOOST", ...)
GomaLogger.debug(.betting, category: "BETTING_OPTIONS", ...)
GomaLogger.debug(.betting, category: "BET_PLACEMENT", ...)
GomaLogger.debug(.betting, category: "BETSLIP_SYNC", ...)

// Networking
GomaLogger.debug(.networking, category: "GOMAAPI", ...)
GomaLogger.debug(.networking, category: "Socket", ...)
GomaLogger.debug(.networking, category: "API", ...)

// Realtime
GomaLogger.debug(.realtime, category: "LIVE_SCORE", ...)
GomaLogger.debug(.realtime, category: "LIVE_DATA", ...)
GomaLogger.debug(.realtime, category: "WAMP", ...)

// UI
GomaLogger.debug(.ui, category: "MatchDetailsVC", ...)
GomaLogger.debug(.ui, category: "MarketsTabVM", ...)
```

---

## Migration Checklist

For each file you're migrating:

- [ ] Add `import GomaLogger`
- [ ] Find all `print()` statements
- [ ] Identify pattern (bracket tag, BLINK_DEBUG, socket, error, etc.)
- [ ] Apply appropriate transformation
- [ ] Choose correct subsystem
- [ ] Choose correct category (if applicable)
- [ ] Choose correct log level (debug/info/error)
- [ ] Remove redundant emojis from message (let log level provide them)
- [ ] Test that logs appear in console
- [ ] Build and verify no compiler errors

---

## Automated Migration (Optional)

### Using find/replace regex:

**Pattern 1: Simple bracket tags**
```regex
Find: print\("\[([A-Z_]+)\]\s*(.+)"\)
Replace: GomaLogger.debug(.general, category: "$1", "$2")
```

**Pattern 2: Error patterns**
```regex
Find: print\("([A-Z\s]+)\s*ERROR:\s*(.+)"\)
Replace: GomaLogger.error(.general, "$2")
```

Then manually:
1. Adjust subsystem from `.general` to appropriate value
2. Adjust log level if needed
3. Add metadata if error objects are present

---

## Testing After Migration

After migrating a file:

1. **Run the app in DEBUG**
   - Verify logs appear in Xcode console
   - Check formatting looks correct

2. **Test with configuration**
   ```swift
   // Temporarily in AppDelegate
   GomaLogger.configure(minimumLevel: .info)
   ```
   - Verify debug logs are hidden
   - Verify info/error logs still appear

3. **Test category filtering**
   ```swift
   GomaLogger.disableCategory("YOUR_CATEGORY")
   ```
   - Verify category logs are hidden

---

## Examples from Codebase

### Example 1: BetslipManager.swift

**Before:**
```swift
print("[ODDS_BOOST] 🔐 User logged in, fetching odds boost stairs")
print("[ODDS_BOOST] Fetching odds boost for \(oddsBoostSelections.count) selections")
print("[ODDS_BOOST]  Failed: \(error)")
print("[BETTING_OPTIONS] Valid: \(options.isValid), minStake: \(options.minStake ?? 0)")
```

**After:**
```swift
GomaLogger.debug(.betting, category: "ODDS_BOOST", "User logged in, fetching odds boost stairs")
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching odds boost for \(oddsBoostSelections.count) selections")
GomaLogger.error(.betting, category: "ODDS_BOOST", "Failed", metadata: ["error": error])
GomaLogger.info(.betting, category: "BETTING_OPTIONS", "Valid: \(options.isValid), minStake: \(options.minStake ?? 0)")
```

### Example 2: UserSessionStore.swift

**Before:**
```swift
print("[SSEDebug] 🚀 UserSessionStore: Starting UserInfo SSE stream")
print("[SSEDebug] ✅ UserSessionStore: SSE connected - subscription ID: \(subscription.id)")
print("[SSEDebug] ❌ UserSessionStore: SSE stream error: \(error)")
print("[AUTH_DEBUG] 🔐 UserSessionStore: login() called with username: \(username)")
```

**After:**
```swift
GomaLogger.debug(.realtime, category: "SSE", "UserSessionStore: Starting UserInfo SSE stream")
GomaLogger.debug(.realtime, category: "SSE", "UserSessionStore: SSE connected - subscription ID: \(subscription.id)")
GomaLogger.error(.realtime, category: "SSE", "UserSessionStore: SSE stream error: \(error)")
GomaLogger.debug(.authentication, category: "AUTH", "UserSessionStore: login() called with username: \(username)")
```

### Example 3: MatchDetailsTextualViewController.swift

**Before:**
```swift
print("BLINK_DEBUG [MatchDetailsVC] 🔔 Market Groups Update #\(self.marketGroupsUpdateCounter)")
print("BLINK_DEBUG [MatchDetailsVC] ✏️  Groups CHANGED: \(currentGroupIds.joined(separator: ", "))")
print("BLINK_DEBUG [MatchDetailsVC] 🏗️  recreateMarketControllers START")
```

**After:**
```swift
GomaLogger.debug(.ui, category: "MatchDetailsVC", "Market Groups Update #\(self.marketGroupsUpdateCounter)")
GomaLogger.debug(.ui, category: "MatchDetailsVC", "Groups CHANGED: \(currentGroupIds.joined(separator: ", "))")
GomaLogger.debug(.ui, category: "MatchDetailsVC", "recreateMarketControllers START")
```

---

## FAQ

**Q: Can I keep my print() statements?**
A: Yes! GomaLogger coexists with print(). Migrate gradually.

**Q: What if I don't know which subsystem to use?**
A: Use `.general` for now, refine later.

**Q: Should I remove emojis from messages?**
A: Yes, log levels add emojis automatically. But keeping them won't break anything.

**Q: What about sensitive data (passwords, tokens)?**
A: Never log sensitive data. If you must log IDs, use hashed/truncated versions.

**Q: How do I test my migration?**
A: Run the app and check Xcode console. Try disabling categories to verify filtering works.

**Q: Can I migrate one file at a time?**
A: Absolutely! That's the recommended approach.

---

## Need Help?

- Check `README.md` for API documentation
- Review unit tests in `Tests/GomaLoggerTests/` for examples
- Ask the iOS team for guidance

Happy migrating! 🚀
