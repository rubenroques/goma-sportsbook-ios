## Date
09 June 2025

### Project / Branch
sportsbook-ios / main (ServicesProvider)

### Goals for this session
- Fix excessive updates in NextUpEventsViewModel causing unnecessary UI refreshes
- Optimize PreLiveMatchesPaginator to only emit list structure changes
- Improve architecture by moving entity subscription logic to paginator

### Achievements
- [x] Identified root cause: every entity update triggers full list rebuild in PreLiveMatchesPaginator
- [x] Fixed dispatch queue deadlock in EntityStore.getOrCreatePublisher() (nested sync calls)
- [x] Implemented match ID comparison logic to detect list structure changes only
- [x] Modified handleSubscriptionContent() to return nil for content-only updates
- [x] Moved individual entity subscription methods from EveryMatrixProvider to PreLiveMatchesPaginator
- [x] Updated API to use compactMap instead of tryMap to filter out nil emissions
- [x] Added comprehensive documentation clarifying subscription types

### Issues / Bugs Hit
- [x] Dispatch queue deadlock: `publisherQueue.sync(flags: .barrier)` called from within `publisherQueue.sync` context
- [x] Compilation error: function required return value but we wanted to return nil for content-only updates
- [x] Excessive view model updates: every odds change triggered complete match list rebuild

### Key Decisions
- **Match ID comparison approach**: Compare Set<String> of match IDs before/after store update to detect structural changes
- **Nil return strategy**: Modified function signature to return optional, use compactMap to filter
- **Architectural improvement**: Moved entity subscriptions to paginator for better encapsulation
- **Clear API separation**: List structure subscriptions vs individual entity subscriptions

### Experiments & Notes
- Fixed deadlock by removing redundant `sync(flags: .barrier)` call - already in queue context
- Tried caching last EventsGroups but opted for nil return approach instead
- Used `Set` comparison for O(1) match list change detection vs manual iteration

### Useful Files / Links
- [PreLiveMatchesPaginator](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PreLiveMatchesPaginator.swift) - Main optimization target
- [EveryMatrixNamespace EntityStore](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/EveryMatrixNamespace.swift) - Queue deadlock fix
- [EveryMatrixProvider](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Simplified delegation
- [Queue Deadlock Analysis](./README.md) - Documentation on avoiding nested sync calls

### Performance Impact
- **Before**: Every 2-second odds update triggered full EventsGroup rebuild + view model processMatches()
- **After**: Only match additions/removals trigger list updates, content updates handled via individual subscriptions
- **Expected reduction**: ~95% fewer unnecessary list updates

### Architecture Improvements
- **Better encapsulation**: Entity store logic now contained within paginator
- **Cleaner API**: Provider methods now delegate to paginator methods
- **Separated concerns**: List structure changes vs individual entity updates
- **Named clarity**: Documentation explains subscription types and their purposes

### Next Steps
1. Test the fix in development environment to verify reduced update frequency
2. Monitor performance metrics to confirm expected improvements
3. Consider implementing similar pattern for other paginator classes
4. Update view model tests to account for reduced update frequency
5. Document the pattern for other developers working on similar subscription logic

### Learning Notes
- **Dispatch Queue Rules**: Never call sync on a queue you're already in - causes deadlock
- **Publisher Optimization**: Use nil returns + compactMap to filter unnecessary emissions
- **Architecture Principle**: Move logic closer to the data source for better encapsulation