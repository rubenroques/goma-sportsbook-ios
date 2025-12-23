## Date
19 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Connect to Jira via Atlassian MCP and audit December changelog entries
- Find BC (client Jira) numbers for SPOR tickets missing them
- Create missing SPOR tickets for December changelog entries
- Ensure all changelog entries have proper Jira ticket references

### Achievements

#### Phase 1: BC Number Audit
- [x] Connected to Jira via Atlassian MCP (gomagaming.atlassian.net)
- [x] Audited 6 SPOR tickets from changelog for BC associations:

| SPOR | Title | BC Number |
|------|-------|-----------|
| SPOR-6122 | Mybets - Settle - falta tags lost/won | None |
| SPOR-5738 | Casino Backgrounds - variaveis erradas | None |
| SPOR-6895 | Sync Resp. Gaming strings with web | None |
| SPOR-6637 | Registration flow - missing strings | **BC-216** (found!) |
| SPOR-6672 | Bonus t&c deeplink | BC-296 (already had) |
| SPOR-6994 | Available/Granted Bonus not displayed | BC-435 (already had) |

#### Phase 2: Hosted Cashier Investigation
- [x] Searched for "hosted cashier" equivalent across iOS/Android/Web
- [x] Found **SPOR-6673** (Web) - "Implement the new Cashier Page - Deposit + Withdraw"
- [x] Confirmed no iOS equivalent existed

#### Phase 3: Individual Ticket Creation (5 tickets)
Created tickets for specific changelog entries:

| Key | Type | Summary |
|-----|------|---------|
| **SPOR-7001** | Story | Integrate the new Cashier Page - Deposit + Withdraw |
| **SPOR-7002** | Bug | Implement hybrid Phrase OTA + local bundle fallback for localization |
| **SPOR-7003** | Story | Add per-environment app icons with visual badges |
| **SPOR-7004** | Story | Add snapshot testing infrastructure for GomaUI components |
| **SPOR-7019** | Story | Change default filter from 'Popular' to 'Upcoming' with 24h time period |

#### Phase 4: Batch Ticket Creation (27 tickets)
Launched agent to extract all December changelog entries without SPOR references, then batch-created 27 tickets:

**Stories (5 tickets: SPOR-7020 to SPOR-7024)**
| Key | Summary |
|-----|---------|
| SPOR-7020 | Complete partial cashout implementation with state machine and SSE |
| SPOR-7021 | Add Widget cashier deposit/withdraw screens with WebView bridge |
| SPOR-7022 | Merge BetssonFrance into unified single codebase |
| SPOR-7023 | Convert VersionUpdateViewController from XIB to ViewCode |
| SPOR-7024 | Add GomaLogger debugging to RealtimeSocketClient |

**Bugs (18 tickets: SPOR-7025 to SPOR-7042)**
| Key | Summary |
|-----|---------|
| SPOR-7025 | Fixed granted bonus not displaying, tweaked UI |
| SPOR-7026 | Change default appearance mode from dark to system |
| SPOR-7027 | Fixed tab-bar animation cancellation |
| SPOR-7028 | Fixed available and granted bonus models parsing |
| SPOR-7029 | Add GmLegislation error code mappings for login errors |
| SPOR-7030 | Standardize language parameter across all API calls |
| SPOR-7031 | Fix language indicator showing EN instead of FR |
| SPOR-7032 | Fix market group tabs flickering to All Markets |
| SPOR-7033 | Add support for Forbidden_TooManyAttempts error code |
| SPOR-7034 | Add NSBluetoothAlwaysUsageDescription to Info.plist |
| SPOR-7035 | Add language parameter to banner CMS endpoints |
| SPOR-7036 | Re-enable SSE for wallet updates and add REST fallback |
| SPOR-7037 | Use LanguageManager for profile language subtitle |
| SPOR-7038 | Adopt UIScene lifecycle with SceneDelegate |
| SPOR-7039 | Fix GoogleService-Info.plist missing in archive builds |
| SPOR-7040 | Show friendly empty state in MyBets when not logged in |
| SPOR-7041 | Refactor OutcomeItemView selection to MVVM pattern |
| SPOR-7042 | Change priority on localization for registration validation |

**Tasks (4 tickets: SPOR-7043 to SPOR-7046)**
| Key | Summary |
|-----|---------|
| SPOR-7043 | Rename GomaUIDemo to GomaUICatalog |
| SPOR-7044 | Abstract language configuration behind ServicesProvider API |
| SPOR-7045 | Optimize tag validation step from 4min to 10sec |
| SPOR-7046 | Use generic release notes for Firebase distribution |

### Issues / Bugs Hit
- [x] Atlassian MCP connection unstable - required multiple `/mcp` reconnections
- [x] Parallel batch creation (5+ tickets) caused timeouts - switched to smaller batches (3-4)
- [x] Auth errors required MCP reconnection mid-batch

### Key Decisions
- Created iOS cashier ticket (SPOR-7001) referencing Web equivalent (SPOR-6673)
- Used "Integrate" wording for iOS (vs "Implement" for Web) since iOS embeds hosted solution
- Categorized entries: feat/feature → Story, fix → Bug, chore/refactor/ci → Task
- All tickets labeled with `["BA", "ios"]` for consistency

### Experiments & Notes
- Atlassian MCP search supports JQL queries
- Batch creation works best with 3-4 parallel calls max
- Used `getJiraIssue` to inspect existing ticket structure before creating similar ones

### Useful Files / Links
- [Changelog YAML](../../BetssonCameroonApp/CHANGELOG.yml)
- [SPOR-6673 Web Cashier](https://gomagaming.atlassian.net/browse/SPOR-6673)
- [SPOR-7001 iOS Cashier](https://gomagaming.atlassian.net/browse/SPOR-7001)
- [Sprint 50 Board](https://gomagaming.atlassian.net/jira/software/projects/SPOR/boards/1)

### Statistics
| Metric | Count |
|--------|-------|
| Tickets audited for BC numbers | 6 |
| Individual tickets created | 5 |
| Batch tickets created | 27 |
| **Total tickets created** | **32** |
| MCP reconnections required | ~5 |

### Next Steps
1. Update CHANGELOG.yml entries with newly created SPOR references
2. Link related tickets (e.g., SPOR-7020 cashout to SPOR-7001 cashier)
3. Move completed tickets to appropriate sprint/status
4. Consider adding BC numbers to tickets missing client references
