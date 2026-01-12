## Date
12 January 2026

### Project / Branch
sportsbook-ios / main (Jira ticket management session)

### Goals for this session
- Connect to Jira via MCP and list BF/V2 sprint tasks
- Read ClassicMatchCardRefactoring documentation
- Create proper specifications for 13 placeholder Jira tickets
- Assign tickets to team members with balanced workload

### Achievements
- [x] Connected to Jira MCP (gomagaming.atlassian.net) and queried sprint tasks using labels `BF` + `iOS`
- [x] Read all documentation under `Documentation/ClassicMatchCardRefactoring/`
- [x] Created comprehensive specs file `JIRA_TICKETS_SPECS.md` with 13 component specifications
- [x] Matched components to existing tickets by story points (preserved original estimates)
- [x] Updated all 13 Jira tickets with proper titles and detailed descriptions
- [x] Adjusted story points for 3 tickets: SPOR-6816 (8→4), SPOR-6815 (2→6), SPOR-6827 (2→6)
- [x] Assigned tickets using leaf-first strategy for non-blocking parallel work
- [x] André Lascas  5 tickets, 30 SP
- [x] Leonardo Soares  8 tickets, 32 SP

### Issues / Bugs Hit
- [x] Initial JQL query for project "BF" returned no results → switched to label-based search
- [x] 401 Unauthorized error mid-execution → user reconnected MCP with `/mcp` command
- [x] Story points field not in initial response → found it's `customfield_10016`

### Key Decisions
- **Leaf-first split strategy**: Building blocks (7) in Phase 1, Card composites (6) in Phase 2
- **Zero blocking**: Both devs can work in parallel since leaves have no inter-dependencies
- **Protocol-first approach**: Day 1 pair programming to define all VM protocols, then work independently with mocks
- **SP rebalancing**: Moved complexity to OutrightCardView (2→6) and BackgroundImageMatchCardView (2→6), reduced OutcomesLineView (8→4)

### Experiments & Notes
- Used 7 parallel Task agents to research legacy code across different aspects
- MCP Atlassian integration worked well for batch Jira updates
- Total refactoring scope: 62 SP for 13 components (7 building blocks + 6 card composites)

### Useful Files / Links
- [JIRA Tickets Specs](../ClassicMatchCardRefactoring/JIRA_TICKETS_SPECS.md)
- [ClassicMatchCardRefactoring README](../ClassicMatchCardRefactoring/README.md)
- [Legacy Cell](../../BetssonFranceLegacy/Core/Screens/PreLive/Cells/MatchWidgetCollectionViewCell.swift) - 2700+ lines being refactored
- [Parent Epic SPOR-6232](https://gomagaming.atlassian.net/browse/SPOR-6232) - V1 to V2 Migration

### Jira Tickets Updated

**André Lascas  - 30 SP:**
| Ticket | Component | SP |
|--------|-----------|-----|
| SPOR-6807 | ClassicMatchCardHeaderBarView | 6 |
| SPOR-6816 | ClassicMatchCardOutcomesLineView | 4 |
| SPOR-6817 | ClassicMatchCardDetailedScoreView | 6 |
| SPOR-6803 | ClassicLiveMatchCardView | 8 |
| SPOR-6815 | ClassicOutrightCardView | 6 |

**Leonardo Soares  - 32 SP:**
| Ticket | Component | SP |
|--------|-----------|-----|
| SPOR-6811 | ClassicMatchCardTeamsView | 4 |
| SPOR-6810 | ClassicMatchCardDateTimeView | 2 |
| SPOR-6812 | ClassicMatchCardLiveIndicatorView | 4 |
| SPOR-6813 | ClassicMatchCardMarketPillView | 2 |
| SPOR-6806 | ClassicPreLiveMatchCardView | 4 |
| SPOR-6809 | ClassicTopImageMatchCardView | 4 |
| SPOR-6804 | ClassicBoostedMatchCardView | 6 |
| SPOR-6827 | ClassicBackgroundImageMatchCardView | 6 |

### Next Steps
1. Team kickoff: Pair program to define all 7 building block protocols (2-3 hours)
2. Each dev creates mock implementations for components they don't own
3. Phase 1: Both devs build building blocks in parallel
4. Phase 2: Both devs build card composites (all building blocks ready)
5. Integration testing at end of sprint
