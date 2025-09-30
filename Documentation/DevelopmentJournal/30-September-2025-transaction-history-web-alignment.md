## Date
30 September 2025

### Project / Branch
sportsbook-ios / rr/virtuals

### Goals for this session
- Analyze current Transaction History implementation vs web production spec
- Align iOS implementation with web team's battle-tested logic
- Fix transaction type mappings, status normalization, and display fields
- Implement proper pagination and request locking

### Achievements
- [x] Added 2 new banking transaction types (systemDeposit, systemWithdrawal)
- [x] Added 3 new wagering transaction types (cancel, batchAmountsDebit, batchAmountsCredit)
- [x] Created `BankingTransactionStatus` enum with raw status normalization
- [x] Created `WageringTransactionStatus` enum with transType mapping
- [x] Fixed critical date field bug: Banking now uses `completed` not `created`
- [x] Fixed critical amount field bug: Wagering now uses `totalAmount` not `realAmount`
- [x] Implemented request locking to prevent concurrent filter changes
- [x] Implemented proper pagination using actual API `pagination.next` field
- [x] Updated status badge logic to match web (banking shows badge only for cancelled/pending)
- [x] Added `amountIndicator` field (+/- based on transaction type, not amount sign)
- [x] Updated all 3 mapping layers (EveryMatrix → ServicesProvider → App)

### Issues / Bugs Hit
- None - implementation went smoothly

### Key Decisions
- **Date field selection**: Web uses `completed` for banking (not `created`), keeps `ins` for wagering
- **Amount field selection**: Web uses `totalAmount` for wagering (not `realAmount`), keeps `realAmount` for banking
- **Status normalization**: Banking maps raw API strings to 3 states (cancelled/pending/success), wagering derives from transType
- **Amount indicator logic**: Based on transaction type for banking, based on `transName` field for wagering (not amount sign)
- **Pagination strategy**: Combined hasMore logic - true if EITHER banking OR wagering has `pagination.next`
- **Badge display**: Banking only shows badge for non-success states (empty string = success), wagering always shows status

### Experiments & Notes
- Discovered web implementation uses comprehensive transaction type mappings we were missing
- Web has clever status normalization reducing API complexity for UI layer
- Web's `displayAmountIndicator` approach is more accurate than amount sign (handles system transactions correctly)
- Pagination was completely disabled (hardcoded `false`) - now functional

### Useful Files / Links
**Web Implementation Reference:**
- [Web Transactions Mapper](/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/src/api/everymatrix/mappers/transactions.mapper.js)
- [Web Transaction Store](/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/src/stores/transactions.js)
- [Web Composable](/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/src/composables/transactions/useTransactionsHistory.js)

**iOS Files Modified (13 files total):**

*ServicesProvider Package (3):*
- [EveryMatrixModelMapper+Transactions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Transactions.swift)
- [EveryMatrix+Transactions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+Transactions.swift)
- [UserTransactions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/UserTransactions.swift)

*BetssonCameroonApp (8):*
- [BankingTransaction.swift](../../BetssonCameroonApp/App/Models/Transactions/BankingTransaction.swift)
- [WageringTransaction.swift](../../BetssonCameroonApp/App/Models/Transactions/WageringTransaction.swift)
- [BankingTransactionStatus.swift](../../BetssonCameroonApp/App/Models/Transactions/BankingTransactionStatus.swift) - NEW
- [WageringTransactionStatus.swift](../../BetssonCameroonApp/App/Models/Transactions/WageringTransactionStatus.swift) - NEW
- [ServiceProviderModelMapper+Transactions.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Transactions.swift)
- [TransactionHistoryItem.swift](../../BetssonCameroonApp/App/Screens/TransactionHistory/TransactionHistoryItem.swift)
- [TransactionHistoryViewModel.swift](../../BetssonCameroonApp/App/Screens/TransactionHistory/TransactionHistoryViewModel.swift)
- [TransactionItemViewModel.swift](../../BetssonCameroonApp/App/Screens/TransactionHistory/ViewModels/TransactionItemViewModel.swift)

*GomaUI Package (1):*
- [TransactionItemData.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TransactionItemView/TransactionItemData.swift)

### Architecture Pattern
Maintained clean 3-layer architecture throughout:
```
EveryMatrix API (raw types: 0,1,13,14 / "1","2","3","4","5")
  ↓
ServicesProvider (domain models with enums)
  ↓
App Models (computed display properties)
  ↓
TransactionHistoryItem (unified display model)
  ↓
GomaUI Components (presentation)
```

### Implementation Phases
**Phase 1: Core Model & Mapping Fixes**
- Extended transaction type enums
- Created status normalization logic
- Fixed date/amount field selection
- Added computed display properties

**Phase 2: ViewModel Business Logic**
- Implemented request locking (guard loading state)
- Fixed pagination (use actual API response)
- Updated status badge mapping

**Phase 3: UI Display Updates**
- Added amountIndicator to GomaUI
- Wired display fields through entire stack

### Next Steps
1. **Testing**: Verify all transaction types display correctly in simulator
2. **QA Checklist**:
   - System deposits/withdrawals show correct labels
   - Banking statuses: Success=no badge, Pending/Cancelled=show badge
   - Wagering statuses: Placed/Won/Cancel badges correct
   - Amount indicators: "+" for credits, "-" for debits
   - Wagering shows totalAmount (not realAmount)
   - Banking shows completed date (not created)
   - Pagination hasMoreData reflects API state
3. **Edge Cases**: Test with pending/cancelled transactions from API
4. **Build**: Run full workspace build to ensure no compilation errors
5. **PR**: Create pull request with comprehensive testing notes