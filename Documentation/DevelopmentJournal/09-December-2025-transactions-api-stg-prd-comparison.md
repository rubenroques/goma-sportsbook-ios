## Date
09 December 2025

### Project / Branch
sportsbook-ios / rr/issues_debug_and_test

### Goals for this session
- Debug transactions endpoints (banking and wagering)
- Compare STG vs PRD API responses
- Document any discrepancies for the team

### Achievements
- [x] Successfully authenticated to both STG and PRD environments
- [x] Tested `/v1/player/{userId}/transactions/banking` endpoint on both envs
- [x] Tested `/v1/player/{userId}/transactions/wagering` endpoint on both envs
- [x] Identified key discrepancy: `gameModel` field present in STG but missing in PRD
- [x] Drafted Teams message with cURL commands for team testing

### Issues / Bugs Hit
- [x] **`gameModel` missing in Production** - Wagering transactions in STG return full `gameModel` object with game metadata (name, thumbnails, vendor info, launch URLs), while PRD returns only basic transaction fields

### Key Decisions
- Flagged as potential backend configuration issue on EM side
- Need to verify if `gameModel` expansion is enabled for PRD operator (4374) vs STG operator (4093)

### Experiments & Notes

#### Test Credentials
| Environment | Base URL | Username | Password | Operator ID |
|-------------|----------|----------|----------|-------------|
| STG | `betsson-api.stage.norway.everymatrix.com` | +237699198923 | 1234 | 4093 |
| PRD | `betsson.nwacdn.com` | +237650888006 | 4050 | 4374 |

#### Banking Transaction Types Observed
| Type | Meaning | Status Values Seen |
|------|---------|-------------------|
| 0 | Deposit | Success, RollBack |
| 1 | Withdrawal | PendingNotification |
| 13 | Manual Credit | Success |

#### Wagering Transaction Types
| transType | transName | Meaning |
|-----------|-----------|---------|
| 1 | Debit | Bet placed |
| 2 | Credit | Win payout |

#### Response Size Difference
- **STG wagering**: ~15KB per transaction (includes full `gameModel` with thumbnails, vendor info, categories, jackpots, etc.)
- **PRD wagering**: ~500B per transaction (basic fields only)

### Useful Files / Links
- Skill reference: `.claude/skills/everymatrix-player-api/README.md`
- API models: `Frameworks/ServicesProvider/.../EveryMatrixPlayerAPI.swift`

### cURL Commands for Testing

```bash
# === STG ===
# Login
curl -s -X POST "https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/login" -H "Content-Type: application/json" -H "User-Agent: GOMA/native-app/iOS" -d '{"username":"+237699198923","password":"1234"}'

# Wagering Transactions (replace SESSION_ID)
curl -s -X GET "https://betsson-api.stage.norway.everymatrix.com/v1/player/7119816/transactions/wagering?startDate=2025-10-01T00:00:00&endDate=2025-12-09T23:59:59&page=1" -H "Content-Type: application/json" -H "User-Agent: GOMA/native-app/iOS" -H "X-SessionId: SESSION_ID"

# === PRD ===
# Login
curl -s -X POST "https://betsson.nwacdn.com/v1/player/legislation/login" -H "Content-Type: application/json" -H "User-Agent: GOMA/native-app/iOS" -d '{"username":"+237650888006","password":"4050"}'

# Wagering Transactions (replace SESSION_ID)
curl -s -X GET "https://betsson.nwacdn.com/v1/player/15036262/transactions/wagering?startDate=2025-10-01T00:00:00&endDate=2025-12-09T23:59:59&page=1" -H "Content-Type: application/json" -H "User-Agent: GOMA/native-app/iOS" -H "X-SessionId: SESSION_ID"
```

### Next Steps
1. Confirm with EM if `gameModel` expansion needs to be enabled for PRD operator
2. Check if iOS app relies on `gameModel` data from wagering transactions
3. If app needs `gameModel`, implement fallback or separate game info fetch
