# GomaLogger v1 - Production Logging Framework

## Date
20 November 2025

### Project / Branch
sportsbook-ios / Frameworks/GomaLogger / rr/match_details_score

### Goals for this session
- Analyze existing print statement patterns across codebase
- Design and implement GomaLogger v1 Swift Package
- Create comprehensive documentation and migration guides
- Build production-ready logging framework with zero-cost filtering

### Achievements
- [x] Created Python analysis tool (`tools/analyze_print_tags.py`) to scan entire codebase
- [x] Analyzed 2,560 print statements, identified 279 unique tag patterns
- [x] Designed hierarchical logging system (subsystem + category)
- [x] Implemented GomaLogger Swift Package with 3 severity levels (debug, info, error)
- [x] Built LogConfiguration with thread-safe runtime control
- [x] Implemented pluggable destination system (Console + File + Protocol)
- [x] Created FileDestination with automatic log rotation
- [x] Wrote 14 comprehensive unit tests (all passing ✓)
- [x] Wrote README.md with full API documentation
- [x] Created Migration-Guide.md with regex patterns and examples
- [x] Generated integration example for BetssonCameroonApp

### Analysis Results
**Print Statement Distribution:**
- Total prints found: 2,560
- Tagged prints: 1,130 (44%)
- Untagged prints: 1,430 (56%)
- Unique tags: 279

**Top Tag Patterns:**
1. `SSE DEBUG` - 134 occurrences (Server-Sent Events)
2. `SERVICEPROVIDER` - 95 occurrences (Backend layer)
3. `EMOJI_❌` - 64 occurrences (Error indicators)
4. `EMOJI_✅` - 55 occurrences (Success indicators)
5. `LIVE_SCORE` - 47 occurrences (Live match updates)
6. `EMOJI_⚠️` - 40 occurrences (Warnings)
7. `GOMAAPI` - 29 occurrences (Goma API debugging)

**Pattern Distribution:**
- Uppercase prefix: 159 unique tags
- Uppercase label: 74 unique tags
- Emoji-led: 23 unique patterns
- Bracket tags `[TAG]`: 16 unique tags
- BLINK_DEBUG patterns: 5 components tracked

### Key Decisions

**Architecture:**
- ✅ Static/Global API (`GomaLogger.debug(...)`) - Simplest to use, no instance management
- ✅ Standalone implementation (not OSLog-based) - Full control, no OS restrictions
- ✅ Hierarchical organization: Subsystem enum + freeform category strings
- ✅ 3 severity levels only (debug, info, error) - Keep it simple for v1
- ✅ Emoji formalization: 🔍 debug, ℹ️ info, ❌ error

**Configuration:**
- ✅ Runtime control without removing code (disable subsystems/categories)
- ✅ Per-subsystem log levels
- ✅ Auto-disable debug in production builds
- ✅ Zero-cost disabled logging (early return before @autoclosure evaluation)

**Destinations:**
- ✅ Pluggable architecture via `LogDestination` protocol
- ✅ Console destination with formatted output (timestamp, emoji, subsystem, category)
- ✅ File destination with automatic rotation (configurable size/backup count)
- ✅ Thread-safe for concurrent logging

**Migration Strategy:**
- ✅ Gradual coexistence with print() - migrate at comfortable pace
- ✅ No "big bang" conversion - new code uses GomaLogger, old code migrates gradually

### Subsystems Defined (Based on Analysis)

```swift
enum LogSubsystem {
    case authentication  // AUTH_DEBUG, SSEDebug, XTREMEPUSH
    case betting        // ODDS_BOOST, BETTING_OPTIONS, BET_PLACEMENT
    case networking     // GOMAAPI, SocketDebug
    case realtime       // LIVE_SCORE, LIVE_DATA, WAMP
    case ui             // BLINK_DEBUG patterns, ViewControllers
    case performance    // Performance tracking
    case payments       // PaymentsDropIn, transactions
    case social         // Social features, chat
    case analytics      // Event tracking
    case general        // Uncategorized
}
```

### Issues / Bugs Hit
- [x] Initial build errors: `@autoclosure` forwarding required `()` evaluation
- [x] FileDestination availability issues: iOS 13.4+ API (seekToEnd, write, close)
  - **Solution**: Added `#available` checks with fallback to legacy APIs
- [x] Warning about unused `logFilePath` variable
  - **Solution**: Changed to boolean check `guard currentLogFilePath != nil`

### Code Structure

```
Frameworks/GomaLogger/
├── Package.swift                           # Swift Package manifest
├── Sources/GomaLogger/
│   ├── GomaLogger.swift                   # Static API (270 lines)
│   ├── LogLevel.swift                     # Severity levels (40 lines)
│   ├── LogSubsystem.swift                 # 10 subsystems (63 lines)
│   ├── LogConfiguration.swift             # Runtime control (198 lines)
│   ├── Destinations/
│   │   ├── LogDestination.swift           # Protocol (47 lines)
│   │   ├── ConsoleDestination.swift       # Console output (82 lines)
│   │   └── FileDestination.swift          # File + rotation (258 lines)
├── Tests/GomaLoggerTests/
│   └── GomaLoggerTests.swift              # 14 tests (179 lines)
├── Documentation/
│   └── Migration-Guide.md                 # Comprehensive migration guide
└── README.md                              # API documentation
```

### API Examples

**Simple Logging:**
```swift
GomaLogger.debug("Button tapped")
GomaLogger.info(.authentication, "User logged in")
GomaLogger.error(.networking, "Request failed")
```

**Hierarchical Logging:**
```swift
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching stairs")
GomaLogger.info(.realtime, category: "LIVE_SCORE", "Score updated: \(score)")
```

**Structured Logging:**
```swift
GomaLogger.error(.networking, category: "API", "Request failed", metadata: [
    "endpoint": "/auth/login",
    "statusCode": 401,
    "errorCode": "INVALID_CREDENTIALS"
])
```

**Runtime Configuration:**
```swift
GomaLogger.configure(
    minimumLevel: .info,
    enabledSubsystems: [.authentication, .betting],
    disabledCategories: ["SSE", "WAMP"]
)

GomaLogger.setLevel(.debug, for: .authentication)
GomaLogger.disableCategory("LIVE_SCORE")
```

**File Logging:**
```swift
let fileDestination = FileDestination(
    filename: "app.log",
    maxFileSize: 5 * 1024 * 1024,  // 5MB
    maxBackupCount: 3
)
GomaLogger.addDestination(fileDestination)
```

### Test Results

All 14 tests passing ✓:
- ✅ Simple logging (debug, info, error)
- ✅ Subsystem and category tagging
- ✅ Minimum level filtering
- ✅ Subsystem enable/disable lists
- ✅ Per-subsystem log levels
- ✅ Category filtering
- ✅ Log level comparison and emojis
- ✅ Multiple destinations
- ✅ Zero-cost when disabled

**Build Time**: 0.67s
**Test Time**: 0.004s

### Migration Patterns Documented

**Top patterns from analysis:**

| Old Pattern | New Pattern | Count |
|-------------|-------------|-------|
| `[SSEDebug] ...` | `GomaLogger.debug(.realtime, category: "SSE", "...")` | 134 |
| `[SERVICEPROVIDER] ...` | `GomaLogger.debug(.networking, category: "SP", "...")` | 95 |
| `[LIVE_SCORE] ...` | `GomaLogger.debug(.realtime, category: "LIVE_SCORE", "...")` | 47 |
| `[GOMAAPI] ...` | `GomaLogger.debug(.networking, category: "GOMAAPI", "...")` | 29 |
| `BLINK_DEBUG [Component]` | `GomaLogger.debug(.ui, category: "Component", "...")` | 31 |
| `[ODDS_BOOST] ...` | `GomaLogger.debug(.betting, category: "ODDS_BOOST", "...")` | 12 |

**Regex patterns provided** for semi-automated migration:
```regex
# Bracket tags
Find: print\("\[([A-Z_]+)\]\s*(.+)"\)
Replace: GomaLogger.debug(.general, category: "$1", "$2")

# Error patterns
Find: print\("([A-Z\s]+)\s*ERROR:\s*(.+)"\)
Replace: GomaLogger.error(.general, "$2")
```

### Performance Characteristics

**Zero-Cost Disabled Logging:**
```swift
// If category is disabled, the closure is never evaluated
GomaLogger.debug(.ui, category: "DISABLED", expensiveComputation())
// → Early return before expensiveComputation() runs
```

**@autoclosure Benefits:**
- Lazy evaluation of message strings
- Only evaluated if log will be output
- No performance penalty for disabled logs

**Thread Safety:**
- NSLock for configuration access
- NSLock for destination management
- Safe for concurrent logging from multiple threads

### Useful Files / Links

**Core Implementation:**
- [GomaLogger.swift](../../Frameworks/GomaLogger/Sources/GomaLogger/GomaLogger.swift) - Main static API
- [LogConfiguration.swift](../../Frameworks/GomaLogger/Sources/GomaLogger/LogConfiguration.swift) - Runtime control
- [FileDestination.swift](../../Frameworks/GomaLogger/Sources/GomaLogger/Destinations/FileDestination.swift) - File logging with rotation

**Documentation:**
- [README.md](../../Frameworks/GomaLogger/README.md) - API documentation
- [Migration-Guide.md](../../Frameworks/GomaLogger/Documentation/Migration-Guide.md) - Migration patterns
- [GomaLogger-Example.md](../../Documentation/GomaLogger-Example.md) - Integration example

**Analysis:**
- [analyze_print_tags.py](../../tools/analyze_print_tags.py) - Print statement analyzer

**Tests:**
- [GomaLoggerTests.swift](../../Frameworks/GomaLogger/Tests/GomaLoggerTests/GomaLoggerTests.swift) - 14 comprehensive tests

### Experiments & Notes

**Why Not OSLog?**
- Evaluated using Apple's unified logging system (OSLog)
- Decided against: Want full control, no iOS 14+ requirement, custom features
- Standalone implementation gives flexibility for future enhancements

**@autoclosure Performance:**
- Tested lazy evaluation with side effects
- Confirmed: Message closures not evaluated when filtered out
- Critical for zero-cost disabled logging

**File Rotation Strategy:**
- Rotate by size (configurable, default 10MB)
- Keep N backup files (configurable, default 3)
- Automatic cleanup of old backups
- Thread-safe rotation

**Emoji vs Text Levels:**
- Emojis provide instant visual scanning in console
- Text levels better for file logs and parsing
- Solution: Both included (emoji + description)
- Follows existing codebase patterns (266 emoji-tagged prints found)

### Design Philosophy

1. **Simple by default** - Zero-config works out of box
2. **Powerful when needed** - Runtime control, pluggable destinations
3. **Zero cost** - No performance impact when disabled
4. **Migration friendly** - Coexist with print(), gradual adoption
5. **Production ready** - Thread-safe, tested, documented

### Statistics

**Lines of Code:**
- Implementation: ~958 lines
- Tests: 179 lines
- Documentation: ~1,200 lines

**Documentation Coverage:**
- API documentation: Complete
- Migration patterns: 279 tags mapped
- Examples: 50+ code samples
- Integration guide: Step-by-step

**Test Coverage:**
- 14 unit tests covering all major features
- Configuration filtering tested
- Multiple destinations tested
- Zero-cost behavior verified

### Next Steps

**Immediate (Tomorrow):**
1. Add GomaLogger to `Sportsbook.xcworkspace` as local package
2. Integrate into BetssonCameroonApp project
3. Configure in AppDelegate with environment-specific settings
4. Test console output in simulator

**Short-term (This Week):**
1. Migrate one screen as proof-of-concept (e.g., BetslipManager)
2. Verify production build strips debug logs
3. Test file logging and rotation in device
4. Get team feedback on API ergonomics

**Medium-term (This Sprint):**
1. Migrate high-value files (BetslipManager, UserSessionStore, MatchDetails VCs)
2. Create Xcode snippets for common patterns
3. Add to coding standards document
4. Team training session

**Long-term (Future):**
1. v2: Add remote logging destination
2. v2: Log viewer UI component
3. v2: SwiftUI preview integration
4. Consider: Privacy/redaction helpers for PII
5. Consider: Additional severity levels if needed (warning, critical)

### Migration Priority (Based on Analysis)

**High-value targets (most print statements):**
1. UserSessionStore.swift - 30+ SSE/Auth logs
2. BetslipManager.swift - 20+ betting logs
3. MatchDetailsTextualViewController.swift - 15+ UI logs
4. GomaGamingSocialServiceClient.swift - 40+ socket logs
5. GomaConnector.swift - 25+ API logs

**Quick wins (already tagged):**
- All `[ODDS_BOOST]` patterns (12)
- All `[BETTING_OPTIONS]` patterns (8)
- All `[XTREMEPUSH]` patterns (7)
- All `BLINK_DEBUG` patterns (31)

### Lessons Learned

1. **Analysis first** - Understanding existing patterns saved design time
2. **Keep it simple** - 3 severity levels sufficient for v1
3. **Zero-cost matters** - @autoclosure + early return = no production overhead
4. **Documentation == adoption** - Comprehensive migration guide critical
5. **Gradual migration** - Coexistence with print() reduces risk

### Future Enhancements Considered (Not in v1)

- ❌ Warning level - Can add later if needed
- ❌ Critical level - Can add later if needed
- ❌ Success level - Covered by info + context
- ❌ Metrics tracking - Keep logging focused
- ❌ Remote logging - v2 feature
- ❌ Log viewer UI - v2 feature
- ❌ SwiftUI integration - v2 feature

### Project Impact

**Before GomaLogger:**
- 2,560 unstructured print statements
- No runtime filtering
- No production/debug differentiation
- Difficult to find specific logs
- No log persistence

**After GomaLogger:**
- Structured, hierarchical logging
- Runtime enable/disable without code changes
- Debug logs auto-stripped in production
- Easy filtering by subsystem/category
- Optional file persistence with rotation
- Visual emoji indicators
- Zero performance impact when disabled

**Migration Scope:**
- 1,130 tagged prints can be systematically migrated
- 1,430 untagged prints need manual categorization
- Estimated: 2-4 weeks for complete migration (gradual)
- ROI: Better debugging, cleaner logs, production readiness

---

## Summary

Successfully designed and implemented **GomaLogger v1**, a production-ready logging framework for iOS with:
- ✅ Static API for simplicity
- ✅ Hierarchical organization (10 subsystems + categories)
- ✅ 3 severity levels with emojis
- ✅ Runtime configuration and filtering
- ✅ Pluggable destinations (Console + File)
- ✅ Zero-cost disabled logging
- ✅ Comprehensive tests (14/14 passing)
- ✅ Complete documentation and migration guides
- ✅ Data-driven design based on 2,560 existing print statements

Ready for integration into BetssonCameroonApp and gradual migration of existing codebase.
