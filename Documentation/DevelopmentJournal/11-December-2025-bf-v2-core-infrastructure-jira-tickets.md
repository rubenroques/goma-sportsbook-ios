## Date
11 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate BetssonCameroon coordinator architecture for reference
- Investigate BetssonFrance legacy app structure and navigation
- Identify core infrastructure tasks needed for BetssonFrance V2
- Create Jira tickets for core infrastructure (8+ man-hours each)

### Achievements
- [x] Launched 4 parallel exploration agents to analyze:
  - BCM coordinator hierarchy and patterns
  - BF legacy flows (Home, Live, Betslip, MyBets, Auth)
  - BF tab/navigation structure (RootViewController analysis)
  - ServicesProvider layer configuration
- [x] Created comprehensive documentation: `BetssonFranceV2-CoreInfrastructure-JiraTickets.md`
- [x] Compared existing Jira tickets (screenshot) with new requirements
- [x] Created 9 new Jira tickets for missing core infrastructure:

| Key | Summary | SP |
|-----|---------|-----|
| SPOR-6860 | AppStateManager for boot flow | 8 |
| SPOR-6861 | MainTabBarCoordinator | 12 |
| SPOR-6862 | MainTabBarViewController | 12 |
| SPOR-6863 | MainTabBarViewModel | 4 |
| SPOR-6864 | Splash/Maintenance/Update Coordinators | 4 |
| SPOR-6865 | PreLiveEventsCoordinator + LiveEventsCoordinator | 12 |
| SPOR-6866 | MyBetsCoordinator | 8 |
| SPOR-6867 | BetslipCoordinator | 12 |
| SPOR-6868 | ProfileWalletCoordinator + BankingCoordinator | 8 |

**Total: 80 SP (~10 working days)**

### Issues / Bugs Hit
- None

### Key Decisions
- Use "LiveEventsCoordinator" naming for BF (not "InPlayEventsCoordinator" which is BCM naming)
- Exclude Chat/GroupChat/Social, Tips, and Rankings from BF-V2 scope
- All tickets use labels: `ios`, `BF`, `BF-V2`
- Description format: functional description + responsibilities + dependencies + reference (no acceptance criteria checkboxes)

### Experiments & Notes
- BF legacy `RootViewController` is ~2300 lines monolith managing 7-8 tabs
- BCM uses lazy-loaded coordinators with closure-based navigation (not delegates)
- TopBarContainerController pattern centralizes auth/profile callbacks across screens
- ServicesProvider already supports `.betssonFrance` via `cmsClientBusinessUnit`

### Useful Files / Links
- [BetssonFranceV2 Core Infrastructure Tickets](../BetssonFranceV2-CoreInfrastructure-JiraTickets.md)
- [BetssonFranceV2 Component Migration Tickets](../BetssonFranceV2-Migration-JiraTickets.md)
- [BCM AppCoordinator](/BetssonCameroonApp/App/Coordinators/AppCoordinator.swift)
- [BCM MainTabBarCoordinator](/BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift)
- [BF Legacy RootViewController](../../betssonfrance-git-worktree/Core/Screens/Root/RootViewController.swift)
- [Jira Skill Definition](/.claude/skills/jira-ios-ticket/SKILL.md)

### Next Steps
1. Review created tickets in Jira board
2. Set up dependencies/links between related tickets
3. Prioritize and assign to sprint
4. Start with SPOR-6237 (create new project) as foundation
5. Consider creating SearchCoordinator and MatchDetailsCoordinator tickets
