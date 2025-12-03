## Date
03 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Learn how Claude Code Skills work
- Create a Goma CMS API skill with tested cURL commands
- Create an EveryMatrix Player/Legislation API skill with tested cURL commands

### Achievements
- [x] Researched Claude Code Skills from official Anthropic documentation
- [x] Created `.claude/skills/goma-cms/SKILL.md` with tested endpoints
- [x] Created `.claude/skills/everymatrix-player-api/SKILL.md` with tested endpoints
- [x] Tested Goma CMS authentication flow (anonymous auth → bearer token)
- [x] Tested EveryMatrix full registration flow (config → step → register)
- [x] Verified all endpoints with actual cURL requests before documenting
- [x] Successfully created a new user via EM registration API on STG

### Issues / Bugs Hit
- [x] Several Goma CMS endpoints return `FEATURE_ACCESS_DENIED` for BetssonCameroon (documented as disabled)
- [x] EM transactions endpoint has 180-day max date range limit (documented)

### Key Decisions
- Skills placed in `.claude/skills/` (project-level) for team sharing via git
- Only documented BetssonCameroon environment for Goma CMS (GomaDemo was down)
- Included both STG and PRD environments for EveryMatrix
- All cURL commands are single-line (no line breaks) for easy copy-paste
- Description field in SKILL.md is crucial - made it specific for proper auto-discovery

### Experiments & Notes
- Skills are model-invoked (Claude auto-discovers based on description match)
- Skills differ from slash commands: auto-discovery vs explicit invocation
- EM registration creates real users on STG - created user 7158569 during testing
- Goma CMS uses `x-api-key` header for auth, EM uses `X-SessionId` header

### Useful Files / Links
- [Goma CMS Skill](.claude/skills/goma-cms/SKILL.md)
- [EveryMatrix Player API Skill](.claude/skills/everymatrix-player-api/SKILL.md)
- [GomaAPIClientConfiguration](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/GomaAPIClientConfiguration.swift)
- [GomaHomeContentAPISchema](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Subsets/ManagedHomeContent/GomaHomeContentAPISchema.swift)
- [EveryMatrixPlayerAPI](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/EveryMatrixPlayerAPI.swift)
- [EveryMatrixUnifiedConfiguration](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift)

### Tested Endpoints Summary

**Goma CMS (BetssonCameroon):**
| Endpoint | Status |
|----------|--------|
| Auth `/api/auth/v1` | Working |
| Initial Dump | Working |
| Sport Banners | Working |
| Casino Carousel | Working |
| Footer (links/sponsors/social) | Working |
| Banners, Stories, News, etc. | FEATURE_ACCESS_DENIED |

**EveryMatrix PlayerAPI:**
| Endpoint | Status |
|----------|--------|
| Login | Working (STG + PRD) |
| Registration (3-step) | Working |
| Profile/Balance | Working |
| Limits/Transactions | Working |
| Bonuses (applicable/granted) | Working |

### Next Steps
1. Consider adding more API skills (OddsMatrix betting API, Casino API)
2. Update skills when new endpoints are enabled on CMS
3. Share skills approach with team for other common API interactions
