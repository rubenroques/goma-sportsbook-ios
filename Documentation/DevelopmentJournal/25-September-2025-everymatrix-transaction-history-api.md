## Date
25 September 2025

### Project / Branch
sportsbook-ios / rr/virtuals

### Goals for this session
- Add user transaction history endpoints for EveryMatrix provider
- Support both wagering and banking transaction types
- Implement robust JSON parsing with FailableDecodable
- Create convenient date filter helpers for ViewModels

### Achievements
- [x] Added new API endpoints to EveryMatrixPlayerAPI for wagering and banking transactions
- [x] Created comprehensive public models (BankingTransaction, WageringTransaction) with proper optional fields
- [x] Implemented private EveryMatrix models with FailableDecodable for robust parsing
- [x] Built model mappers with proper date parsing and transaction type conversion
- [x] Added four new methods to EveryMatrixPrivilegedAccessManager with date filter helpers
- [x] Exposed all transaction history methods through ServicesProvider.Client
- [x] Added stub implementations in SportRadarPrivilegedAccessManager
- [x] Successfully tested API endpoints with curl to understand response structure

### Issues / Bugs Hit
- [x] Swift keyword conflict: Cannot use `internal` as variable name in model mapper
- [x] JSON parsing robustness: Many transaction fields could be missing or null
- [x] Date parsing: EveryMatrix uses ISO 8601 format with fractional seconds

### Key Decisions
- **Used FailableDecodable pattern**: Prevents entire array failure when individual transactions fail to decode
- **Made most fields optional**: Based on actual API responses, many fields can be null or missing
- **Created date filter enum**: TransactionDateFilter with convenient options (all/1day/1week/1month/3months)
- **Separated banking vs wagering**: Different endpoints and models for different transaction types
- **180-day API limit**: Implemented in date calculation helper (API constraint)

### Experiments & Notes
- Tested with real EveryMatrix staging API using user credentials (+237699198921/1234)
- Banking transactions use type: 0=deposit, 1=withdrawal
- Wagering transactions use transType: "1"=bet, "2"=win
- API returns pagination info for future implementation
- Session token required via X-SessionId header

### Useful Files / Links
- [PrivilegedAccessManager Protocol](Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/PrivilegedAccessManager.swift)
- [Public Transaction Models](Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Payments/UserTransactions.swift)
- [EveryMatrix Private Models](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+Transactions.swift)
- [Model Mappers](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Transactions.swift)
- [API Endpoints](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift)
- [Client Interface](Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift)

### Next Steps
1. Test integration with actual EveryMatrix environment
2. Create ViewModel consumption examples for UI team
3. Add pagination support when UI requirements are defined
4. Consider adding transaction filtering by amount/status
5. Document API usage examples for other developers