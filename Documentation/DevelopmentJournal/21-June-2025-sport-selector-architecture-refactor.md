## Date
21 June 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Fix SportTypeSelectorViewModelProtocol missing selectSport method
- Implement proper MVVM architecture for sport selection
- Add default icon fallback for sports without custom icons
- Simplify overly complex PillSelectorBarViewModel
- Add filter button to pill selector layout

### Achievements
- [x] Added `selectSport(_ sport: SportTypeData)` method to SportTypeSelectorViewModelProtocol
- [x] Updated MockSportTypeSelectorViewModel to implement new protocol method
- [x] Fixed SportTypeSelectorViewController to properly communicate with ViewModel (line 76)
- [x] Removed redundant external callback wiring from ViewControllers
- [x] Implemented icon fallback logic in SportSelectorViewModel.sportToSportTypeData()
- [x] Added same icon fallback to PillSelectorBarViewModel.updateCurrentSport()
- [x] Simplified PillSelectorBarViewModel from 241 lines to 150 lines (removed unused complexity)
- [x] Created horizontal stack layout with pills + filter button
- [x] Added red debug container with PillItemView filter button (80px width, 40px height, 8px padding)
- [x] Updated both NextUpEventsViewController and InPlayEventsViewController layouts
- [x] Added empty presentFilters() methods ready for implementation

### Issues / Bugs Hit
- [x] Sport selector button only worked first time due to missing protocol method
- [x] Memory corruption from long-lived SportSelectorViewModel subscriptions (fixed with on-demand creation)
- [x] SportTypeSelectorViewModelProtocol was incomplete - couldn't receive selections from UI
- [x] Two-way Sport ↔ SportTypeData conversion losing data (fixed with originalSportsMap)
- [x] PillSelectorBarViewModel had unnecessary complexity for static pill display

### Key Decisions
- **On-demand SportSelectorViewModel creation**: Create fresh ViewModel when modal opens instead of storing in parent
- **Protocol extension over adapter pattern**: Extended SportTypeSelectorViewModelProtocol instead of creating separate adapter
- **Icon fallback at conversion time**: Check icon existence when creating SportTypeData, use "sport_type_icon_default" if missing
- **Simplified PillSelectorBarViewModel**: Removed dynamic pill management, kept only sport selector functionality
- **Horizontal stack layout**: Pills + filter button side by side, filter in fixed 80px container

### Experiments & Notes
- Tried SportTypeSelectorAdapter approach but realized existing SportSelectorViewModel already serves as adapter
- Investigated memory corruption - was caused by Combine subscription updating deallocating objects
- Tested icon fallback logic - works for both SportSelectorViewModel and PillSelectorBarViewModel
- Simplified ViewModel removes ~90 lines of unused protocol methods (now no-ops)

### Useful Files / Links
- [SportTypeSelectorViewModelProtocol](../../GomaUI/GomaUI/Sources/GomaUI/Components/SportTypeSelectorView/SportTypeSelectorViewModelProtocol.swift) - Added selectSport method
- [SportSelectorViewModel](../../Core/ViewModels/SportSelectorViewModel.swift) - Icon fallback logic, on-demand creation
- [PillSelectorBarViewModel](../../Core/ViewModels/PillSelectorBarViewModel.swift) - Simplified implementation
- [NextUpEventsViewController](../../Core/Screens/NextUpEvents/NextUpEventsViewController.swift) - New stack layout
- [InPlayEventsViewController](../../Core/Screens/InPlayEvents/InPlayEventsViewController.swift) - New stack layout
- [SportSelectorArchitecture.md](../../SportSelectorArchitecture.md) - Architecture diagrams
- [MVVM Guidelines](../../../MVVM.md) - Architecture principles followed

### Root Cause Analysis
**Problem**: Sport selector button stopped working after first use
**Symptoms**: Button tap had no effect, no modal presentation
**Root Cause**: SportTypeSelectorViewModelProtocol missing `selectSport` method - UI couldn't communicate selection to ViewModel
**Investigation**: Found incomplete protocol, SportTypeSelectorViewController line 76 had `self.viewModel.` with no method to call
**Solution**: Extended protocol, updated implementations, removed external callback wiring

### Architecture Improvements
**Before**: ViewControllers manually connected UI callbacks to ViewModel methods
**After**: Proper MVVM flow - View → ViewController → ViewModel internally
**Benefit**: Cleaner separation of concerns, no external wiring needed

### Next Steps
1. Test new filter button layout and functionality
2. Implement actual filter modal presentation logic
3. Remove red debug background from filter container
4. Consider implementing Coordinator pattern for sport selection navigation
5. Add unit tests for simplified PillSelectorBarViewModel
6. Verify icon fallback logic works with all sport types in production