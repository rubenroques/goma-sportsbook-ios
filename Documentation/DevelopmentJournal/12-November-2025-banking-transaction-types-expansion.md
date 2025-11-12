## Date
12 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Filter out system banking transactions (type 13 and 14) from EveryMatrix provider
- Expand ServicesProvider enum to support all EveryMatrix transaction types (0-12)
- Maintain app-level filtering to only display deposit/withdrawal

### Achievements
- [x] Explored transactions/banking endpoint architecture across all layers
- [x] Documented complete data flow: API → DTO → Domain → App models
- [x] Filtered out system transactions (type 13, 14) in EveryMatrix mapper
- [x] Added 10 new transaction types to ServicesProvider.BankingTransactionType enum
- [x] Updated EveryMatrix mapper to accept types 0-12 (filter 13-14)
- [x] Updated app mapper to filter unsupported types (2-12) while keeping deposit/withdrawal

### Issues / Bugs Hit
- [x] Initial confusion: `debitName` filter vs type-based filtering - realized type 13/14 correlate with `debitName: "System"`
- [x] Clarification needed: ServicesProvider enum vs app-level enum requirements

### Key Decisions
- **Filtering Strategy**: Filter by transaction type codes (13, 14) rather than `debitName` field - cleaner and more reliable
- **Enum Expansion**: Added all 13 transaction types to ServicesProvider enum for API completeness, even though app only supports 2 types currently
- **App-Level Filtering**: App mapper returns `nil` for unsupported types (2-12), allowing future feature expansion without API changes
- **JIRA Summary**: "Filtered out system transactions (type 13 and 14) from EveryMatrix `/transactions/banking` endpoint in the provider mapper, so only user-initiated deposits (type 0) and withdrawals (type 1) are displayed in the transaction history."

### Experiments & Notes
- Analyzed real API response showing type 13 with `"debitName": "System"` correlation
- Discovered that ServicesProvider has complete enum with display names, making it the single source of truth
- App mapper acts as feature gate - can enable new types by just updating one switch statement
- Types 13-14 kept in enum definition but filtered out in mapper

### Useful Files / Links
- [EveryMatrixModelMapper+Transactions](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Transactions.swift:27-60)
- [ServicesProvider BankingTransactionType](Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/UserTransactions.swift:66-117)
- [ServiceProviderModelMapper+Transactions](BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Transactions.swift:19-33)
- [EveryMatrix+Transactions (Internal Models)](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/EveryMatrix+Transactions.swift:39-59)
- [BankingTransaction (App Model)](BetssonCameroonApp/App/Models/Transactions/BankingTransaction.swift:48-84)

### API Transaction Type Reference
EveryMatrix provides 15 banking transaction types:
- **0-1**: User transactions (Deposit, Withdrawal) - ✅ Supported in app
- **2-12**: Special transactions (Transfer, User2User, Vendor2User, User2Vendor, WalletCredit, WalletDebit, Refund, Reversal, Vendor2Vendor, User2Agent, Agent2User) - ✅ Supported in SP, ❌ Filtered in app
- **13-14**: System transactions (SystemDeposit, SystemWithdraw) - ❌ Filtered in mapper

### Data Flow Architecture
```
API Response (types 0-14)
  ↓
EveryMatrixModelMapper (accepts 0-12, filters 13-14)
  ↓
ServicesProvider.BankingTransaction (types 0-12)
  ↓
ServiceProviderModelMapper (accepts 0-1, filters 2-12)
  ↓
App BankingTransaction (deposit/withdrawal only)
  ↓
Transaction History UI
```

### Next Steps
1. Test transaction history screen to verify system transactions no longer appear
2. Monitor if any edge cases exist where type 0/1 has `debitName: "System"`
3. When app needs to support additional transaction types, update app mapper switch
4. Consider adding UI designs for types 2-12 if product wants to display them
