## Date
28 August 2025

### Project / Branch
BetssonCameroonApp / rr/mybets_profile_features

### Goals for this session
- Create app-specific models to replace ServicesProvider models in MyBets feature
- Implement proper model mappers following established app patterns
- Remove architectural violations (UIKit imports, formatting logic in models)
- Maintain clean separation of concerns between data and presentation layers

### Achievements
- [x] Created app-specific MyBets models: MyBet, MyBetSelection, MyBettingHistory, MyBetState, MyBetResult
- [x] Implemented ServiceProviderModelMapper+MyBets.swift with full parameter naming (no abbreviations)
- [x] Updated MyBetsViewModel, MockMyBetsViewModel, and MyBetsViewController to use app models
- [x] Fixed architectural violation: Removed UIKit imports from models
- [x] Fixed architectural violation: Removed formatting methods from models
- [x] Updated BasicBetTableViewCell to use existing helper classes (CurrencyFormatter, OddFormatter)
- [x] Proper currency formatting using bet's actual currency instead of hardcoded EUR
- [x] Maintained existing GomaUI components integration and reactive architecture

### Issues / Bugs Hit
- [x] ~~Initial models contained UIKit imports and UIColor properties - removed to maintain clean architecture~~
- [x] ~~Models had formatting methods (formattedStake, formattedPotentialReturn) - moved to UI layer~~
- [x] ~~Used abbreviated parameter names in mapper - updated to full descriptive names~~

### Key Decisions
- **Clean Architecture Enforcement**: Models contain only data and business logic, no UI concerns
- **Existing Helper Classes**: Used established CurrencyFormatter and NumberFormatter instead of custom formatting
- **Full Parameter Names**: Used descriptive parameter names like `servicesProviderBettingHistory` instead of `spHistory`
- **Dynamic Currency Support**: Currency formatting respects bet's actual currency field instead of hardcoded values
- **Protocol-Driven Design**: Maintained existing MVVM protocol patterns for consistency
- **Mapper Location**: Followed established pattern placing mapper in `/ModelsMapping/` directory

### Experiments & Notes
- ServicesProvider models use SportType enum while app uses Sport struct - handled in mapping
- Currency handling: ServicesProvider.Bet doesn't have currency field, defaulted to "EUR" in mapper
- OddFormat mapping: Both frameworks use similar enum structure, direct case-by-case mapping works
- UI color mapping moved from models to BasicBetTableViewCell.colorFor(betState:) method
- NumberFormatter with dynamic currencyCode provides proper locale-aware formatting

### Useful Files / Links
- [MyBet.swift](../../BetssonCameroonApp/App/Models/Betting/MyBet.swift) - Core bet model with business logic
- [MyBetState.swift](../../BetssonCameroonApp/App/Models/Betting/MyBetState.swift) - State enum with display properties only
- [ServiceProviderModelMapper+MyBets.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift) - Mapping layer
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Updated to use app models
- [OddFormatter.swift](../../BetssonCameroonApp/App/Helpers/OddFormatter.swift) - Existing helper for odds formatting
- [CurrencyHelper.swift](../../BetssonCameroonApp/App/Helpers/CurrencyHelper.swift) - Existing helper for currency formatting
- [ServicesProvider Betting Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift) - Source models

### Next Steps
1. Test MyBets screen with real data to ensure mapping works correctly
2. Verify currency formatting works with different currencies (USD, GBP, etc.)
3. Consider creating extension on MyBetState for UI color mapping if used in multiple places
4. Add unit tests for ServiceProviderModelMapper+MyBets mapping functions
5. Evaluate if additional GomaUI components can replace BasicBetTableViewCell for better visual consistency