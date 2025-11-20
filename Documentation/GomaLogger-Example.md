# GomaLogger Usage Example

This document shows how to integrate and use GomaLogger in BetssonCameroonApp.

## Integration Steps

### 1. Add GomaLogger to BetssonCameroonApp Project

In Xcode:
1. Open `Sportsbook.xcworkspace`
2. Select the `BetssonCameroonApp` project in the navigator
3. Select the `BetssonCameroonApp` target
4. Go to "Frameworks, Libraries, and Embedded Content"
5. Click the "+" button
6. Select "Add Other..." → "Add Package Dependency..."
7. Choose "Add Local..." and select `Frameworks/GomaLogger`

OR manually add to `BetssonCameroonApp.xcodeproj`:
- Add GomaLogger as a local Swift Package dependency

### 2. Configure GomaLogger at App Startup

In `AppDelegate.swift` or your app's initialization:

```swift
import GomaLogger

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure GomaLogger
        configureLogging()

        // ... rest of your app setup

        return true
    }

    private func configureLogging() {
        #if DEBUG
        // Development: Show all logs
        GomaLogger.configure(
            minimumLevel: .debug,
            enabledSubsystems: nil  // nil = all enabled
        )

        // Optionally add file logging for debugging
        let fileDestination = FileDestination(
            filename: "betsson-cameroon-debug.log",
            maxFileSize: 5 * 1024 * 1024  // 5MB
        )
        GomaLogger.addDestination(fileDestination)

        #else
        // Production: Info and errors only
        GomaLogger.configure(
            minimumLevel: .info,
            enabledSubsystems: [.authentication, .betting, .networking, .payments]
        )

        // Disable noisy categories in production
        GomaLogger.disableCategory("SSE")
        GomaLogger.disableCategory("WAMP")
        #endif

        GomaLogger.info("App started - GomaLogger configured")
    }
}
```

### 3. Replace Existing Print Statements

#### Example 1: BetslipManager.swift

**Before:**
```swift
print("[ODDS_BOOST] 🔐 User logged in, fetching odds boost stairs")
print("[ODDS_BOOST] Fetching odds boost for \(oddsBoostSelections.count) selections")
print("[BETTING_OPTIONS] Valid: \(options.isValid), minStake: \(options.minStake ?? 0)")
```

**After:**
```swift
import GomaLogger

// In your class:
GomaLogger.debug(.betting, category: "ODDS_BOOST", "User logged in, fetching odds boost stairs")
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching odds boost for \(oddsBoostSelections.count) selections")
GomaLogger.info(.betting, category: "BETTING_OPTIONS", "Valid: \(options.isValid), minStake: \(options.minStake ?? 0)")
```

#### Example 2: UserSessionStore.swift

**Before:**
```swift
print("[SSEDebug] 🚀 UserSessionStore: Starting UserInfo SSE stream")
print("[SSEDebug] ✅ UserSessionStore: SSE connected - subscription ID: \(subscription.id)")
print("[SSEDebug] ❌ UserSessionStore: SSE stream error: \(error)")
print("[AUTH_DEBUG] 🔐 UserSessionStore: login() called with username: \(username)")
```

**After:**
```swift
import GomaLogger

GomaLogger.debug(.realtime, category: "SSE", "UserSessionStore: Starting UserInfo SSE stream")
GomaLogger.debug(.realtime, category: "SSE", "UserSessionStore: SSE connected - subscription ID: \(subscription.id)")
GomaLogger.error(.realtime, category: "SSE", "UserSessionStore: SSE stream error: \(error)")
GomaLogger.debug(.authentication, category: "AUTH", "UserSessionStore: login() called with username: \(username)")
```

#### Example 3: MatchDetailsTextualViewController.swift

**Before:**
```swift
print("BLINK_DEBUG [MatchDetailsVC] 🔔 Market Groups Update #\(self.marketGroupsUpdateCounter)")
print("BLINK_DEBUG [MatchDetailsVC] ✏️  Groups CHANGED: \(currentGroupIds.joined(separator: ", "))")
```

**After:**
```swift
import GomaLogger

GomaLogger.debug(.ui, category: "MatchDetailsVC", "Market Groups Update #\(self.marketGroupsUpdateCounter)")
GomaLogger.debug(.ui, category: "MatchDetailsVC", "Groups CHANGED: \(currentGroupIds.joined(separator: ", "))")
```

### 4. Using Structured Logging (Metadata)

For errors and complex events, use metadata:

```swift
import GomaLogger

// Network errors
GomaLogger.error(.networking, category: "API", "Request failed", metadata: [
    "endpoint": "/auth/login",
    "statusCode": 401,
    "errorCode": "INVALID_CREDENTIALS"
])

// Betting events
GomaLogger.info(.betting, category: "BET_PLACEMENT", "Bet placed successfully", metadata: [
    "betType": betGroupingType,
    "selections": betSelections.count,
    "stake": stake,
    "potentialReturn": potentialReturn
])
```

### 5. Runtime Control

You can dynamically control logging based on user preferences or debug settings:

```swift
import GomaLogger

// In your debug/developer menu:
func enableVerboseLogging() {
    GomaLogger.setLevel(.debug, for: .authentication)
    GomaLogger.setLevel(.debug, for: .realtime)
    GomaLogger.enableCategory("SSE")
    GomaLogger.enableCategory("LIVE_SCORE")
}

func disableNoisyLogs() {
    GomaLogger.disableCategory("WAMP")
    GomaLogger.disable(.social)
}
```

## Expected Console Output

With GomaLogger configured, you'll see formatted output like:

```
2025-11-20 02:15:32.123 ℹ️ App started - GomaLogger configured
2025-11-20 02:15:33.456 🔍 [Authentication/AUTH] UserSessionStore: login() called with username: user@example.com
2025-11-20 02:15:34.789 🔍 [Betting/ODDS_BOOST] Fetching odds boost for 5 selections
2025-11-20 02:15:35.012 ℹ️ [Betting/BET_PLACEMENT] Bet placed successfully {betType=single, selections=1, stake=100}
2025-11-20 02:15:36.345 ❌ [Networking/API] Request failed {endpoint=/auth/login, statusCode=401}
2025-11-20 02:15:37.678 🔍 [Realtime/SSE] UserSessionStore: SSE connected - subscription ID: abc123
```

## Migration Checklist

For BetssonCameroonApp:

- [ ] Add GomaLogger package dependency to project
- [ ] Configure GomaLogger in AppDelegate
- [ ] Add `import GomaLogger` to files being migrated
- [ ] Convert `[ODDS_BOOST]` patterns (12 occurrences)
- [ ] Convert `[BETTING_OPTIONS]` patterns (8 occurrences)
- [ ] Convert `[SSEDebug]` patterns (30 occurrences)
- [ ] Convert `[AUTH_DEBUG]` patterns (20 occurrences)
- [ ] Convert `BLINK_DEBUG` patterns (31 occurrences)
- [ ] Convert `[XTREMEPUSH]` patterns (7 occurrences)
- [ ] Test in simulator
- [ ] Verify production build works

## Testing

After integration:

1. **Run the app in DEBUG mode**
   ```bash
   xcodebuild -workspace Sportsbook.xcworkspace \
              -scheme BetssonCameroonApp \
              -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
              build
   ```

2. **Check console output** - You should see formatted logs with emojis

3. **Test filtering**:
   - Set minimum level to `.info` → debug logs should disappear
   - Disable a category → those logs should disappear
   - Disable a subsystem → no logs from that subsystem

4. **Test file logging** (if enabled):
   ```swift
   // In a test or debug screen:
   if let fileDestination = /* get your file destination */ {
       print("Log file: \(fileDestination.logFilePath ?? "none")")
       print("All logs: \(fileDestination.allLogFilePaths)")
   }
   ```

## Performance Notes

- ✅ Zero overhead when category/subsystem is disabled (early return before string evaluation)
- ✅ Message strings only evaluated if log will be output (thanks to `@autoclosure`)
- ✅ Minimal impact in production (debug logs stripped out)

## Troubleshooting

**Problem**: "No such module 'GomaLogger'"
**Solution**: Ensure GomaLogger is added to the project's Frameworks and Libraries

**Problem**: Logs not appearing
**Solution**: Check minimum log level and enabled subsystems/categories

**Problem**: Too many logs
**Solution**: Increase minimum level or disable specific categories

## Next Steps

1. Start with one file/screen as a proof-of-concept
2. Verify logging works correctly
3. Gradually migrate more files
4. Eventually deprecate `print()` usage

---

**Package Location**: `Frameworks/GomaLogger/`
**Documentation**: See `Frameworks/GomaLogger/README.md`
**Migration Guide**: See `Frameworks/GomaLogger/Documentation/Migration-Guide.md`
