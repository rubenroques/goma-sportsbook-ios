//
//  EverymatrixProvider.swift
//
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine
import SharedModels

class EveryMatrixEventsProvider: EventsProvider {

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connector.connectionStatePublisher.eraseToAnyPublisher()
    }

    var connector: EveryMatrixConnector

    // MARK: - Managers for different subscription types
    private var prelivePaginator: PreLiveMatchesPaginator?
    private var livePaginator: LiveMatchesPaginator?
    private var sportsManager: SportsManager?

    private var locationsManager: LocationsManager?
    private var currentSportType: SportType?

    private var popularTournamentsManager: PopularTournamentsManager?
    private var sportTournamentsManager: SportTournamentsManager?

    init(connector: EveryMatrixConnector) {
        self.connector = connector
    }

    deinit {
        prelivePaginator?.unsubscribe()
        sportsManager?.unsubscribe()
        locationsManager?.unsubscribe()
        popularTournamentsManager?.unsubscribe()
        sportTournamentsManager?.unsubscribe()
    }

    func reconnectIfNeeded() {
        self.connector.forceReconnect()
    }

    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Clean up any existing paginator
        livePaginator?.unsubscribe()

        // Use sportType ID, fallback to "1" (football) if not available
        let sportId = sportType.numericId ?? "1"

        // Create new paginator with custom configuration if provided
        let numberOfEvents = 10 // Default value, could be made configurable
        let numberOfMarkets = 5 // Default value, could be made configurable

        livePaginator = LiveMatchesPaginator(
            connector: connector,
            sportId: sportId,
            numberOfEvents: numberOfEvents,
            numberOfMarkets: numberOfMarkets
        )

        return livePaginator!.subscribe()
    }

    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        guard let paginator = livePaginator else {
            return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
        }
        
        return paginator.loadNextPage()
    }

    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Clean up any existing paginator
        prelivePaginator?.unsubscribe()

        // Use sportType ID, fallback to "1" (football) if not available
        let sportId = sportType.numericId ?? "1"

        // Create new paginator with custom configuration if provided
        let numberOfEvents = eventCount ?? 10
        let numberOfMarkets = 5 // Default value, could be made configurable

        prelivePaginator = PreLiveMatchesPaginator(
            connector: connector,
            sportId: sportId,
            numberOfEvents: numberOfEvents,
            numberOfMarkets: numberOfMarkets
        )

        return prelivePaginator!.subscribe()
    }

    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError> {
        guard let paginator = prelivePaginator else {
            return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
        }

        return paginator.loadNextPage()
    }

    func subscribeEndedMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func requestEndedMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeToMarketDetails(withId marketId: String, onEventId eventId: String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeEventSummary(eventId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeOutrightEvent(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        // Clean up any existing sports manager
        sportsManager?.unsubscribe()

        // Create new sports manager
        sportsManager = SportsManager(connector: connector)

        return sportsManager!.subscribe()
    }

    func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {
        guard let livePaginator = self.livePaginator else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        
        // Observe EVENT_INFO entities for this event from the live matches subscription
        return livePaginator.observeEventInfosForEvent(eventId: id)
            .map { eventLiveData in
                return SubscribableContent.contentUpdate(content: eventLiveData)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }

    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {
        // NOTE: This method name reflects that it subscribes to individual market updates
        // within the context of an active event list subscription, not changes to the list itself
        guard let paginator = prelivePaginator else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Paginator not active")).eraseToAnyPublisher()
        }

        // Check both paginators to find which one contains this market
        if let prelivePaginator = prelivePaginator, prelivePaginator.marketExists(id: id) {
            // Delegate to pre-live paginator's outcome subscription method
            return prelivePaginator.subscribeToMarketUpdates(withId: id)
                .handleEvents(receiveSubscription: { subscription in
                    // print("subs outcome updated. receiveSubscription (pre-live)")
                }, receiveOutput: { output in
                    // print("subs outcome updated. receiveOutput (pre-live)")
                }, receiveCompletion: { completion in
                    // print("subs outcome updated. receiveCompletion (pre-live)")
                }, receiveCancel: {
                    // print("subs outcome updated. receiveCancel (pre-live)")
                }, receiveRequest: { demand in
                    // print("subs outcome updated. receiveRequest (pre-live)")
                })
                .eraseToAnyPublisher()
        } else if let livePaginator = livePaginator, livePaginator.marketExists(id: id) {
            // Delegate to live paginator's outcome subscription method
            return livePaginator.subscribeToMarketUpdates(withId: id)
                .handleEvents(receiveSubscription: { subscription in
                    // print("subs outcome updated. receiveSubscription (live)")
                }, receiveOutput: { output in
                    // print("subs outcome updated. receiveOutput (live)")
                }, receiveCompletion: { completion in
                    // print("subs outcome updated. receiveCompletion (live)")
                }, receiveCancel: {
                    // print("subs outcome updated. receiveCancel (live)")
                }, receiveRequest: { demand in
                    // print("subs outcome updated. receiveRequest (live)")
                })
                .eraseToAnyPublisher()
        } else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Market with id \(id) not found in any active paginator")).eraseToAnyPublisher()
        }
        
    }

    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        // NOTE: This method name reflects that it subscribes to individual outcome updates
        // within the context of an active event list subscription, not changes to the list itself
        
        // Check both paginators to find which one contains this outcome
        if let prelivePaginator = prelivePaginator, prelivePaginator.outcomeExists(id: id) {
            // Delegate to pre-live paginator's outcome subscription method
            return prelivePaginator.subscribeToOutcomeUpdates(withId: id)
                .handleEvents(receiveSubscription: { subscription in
                    // print("subs outcome updated. receiveSubscription (pre-live)")
                }, receiveOutput: { output in
                    // print("subs outcome updated. receiveOutput (pre-live)")
                }, receiveCompletion: { completion in
                    // print("subs outcome updated. receiveCompletion (pre-live)")
                }, receiveCancel: {
                    // print("subs outcome updated. receiveCancel (pre-live)")
                }, receiveRequest: { demand in
                    // print("subs outcome updated. receiveRequest (pre-live)")
                })
                .eraseToAnyPublisher()
        } else if let livePaginator = livePaginator, livePaginator.outcomeExists(id: id) {
            // Delegate to live paginator's outcome subscription method
            return livePaginator.subscribeToOutcomeUpdates(withId: id)
                .handleEvents(receiveSubscription: { subscription in
                    // print("subs outcome updated. receiveSubscription (live)")
                }, receiveOutput: { output in
                    // print("subs outcome updated. receiveOutput (live)")
                }, receiveCompletion: { completion in
                    // print("subs outcome updated. receiveCompletion (live)")
                }, receiveCancel: {
                    // print("subs outcome updated. receiveCancel (live)")
                }, receiveRequest: { demand in
                    // print("subs outcome updated. receiveRequest (live)")
                })
                .eraseToAnyPublisher()
        } else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Outcome with id \(id) not found in any active paginator")).eraseToAnyPublisher()
        }
    }
    
    func subscribePopularTournaments(forSportType sportType: SportType, tournamentsCount: Int = 10) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        // Clean up any existing manager
        popularTournamentsManager?.unsubscribe()
        
        // Use sportType ID, fallback to "1" (football) if not available
        let sportId = sportType.numericId ?? "1"
        
        // Create new manager
        popularTournamentsManager = PopularTournamentsManager(
            connector: connector,
            sportId: sportId,
            tournamentsCount: tournamentsCount
        )
        
        return popularTournamentsManager!.subscribe()
    }
    
    func subscribeSportTournaments(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        // Clean up any existing manager
        sportTournamentsManager?.unsubscribe()
        
        // Use sportType ID, fallback to "1" (football) if not available
        let sportId = sportType.numericId ?? "1"
        
        // Create new manager
        sportTournamentsManager = SportTournamentsManager(
            connector: connector,
            sportId: sportId
        )
        
        return sportTournamentsManager!.subscribe()
    }

    func getMarketGroups(forEvent event: Event, includeMixMatchGroup: Bool, includeAllMarketsGroup: Bool) -> AnyPublisher<[MarketGroup], Never> {
        fatalError("notSupportedForProvider")
    }

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventSummary(forMarketId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getEventLiveData(eventId: String) -> AnyPublisher<EventLiveData, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeEventMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getHighlightedLiveEventsPointers(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<Events, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getPromotedBetslips(userId: String?) -> AnyPublisher<[PromotedBetslip], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFavoritesList() -> AnyPublisher<FavoritesListResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func addFavoritesList(name: String) -> AnyPublisher<FavoritesListAddResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func deleteFavoritesList(listId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFavoritesFromList(listId: Int) -> AnyPublisher<FavoriteEventResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func deleteFavoriteFromList(eventId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getDatesFilter(timeRange: String) -> [Date] {
        fatalError("")
    }

    func getNews() -> AnyPublisher<[News], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

}

extension EveryMatrixEventsProvider {

    // MARK: - Internal Locations Management

    /// Internal method to get locations for a specific sport
    /// Recreates manager when sport changes for efficient resource usage
    internal func getLocations(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Country]>, ServiceProviderError> {
        // Check if we need to recreate the manager for a different sport
        if currentSportType != sportType {
            // Clean up existing manager
            locationsManager?.unsubscribe()

            // Create new manager for the specified sport
            locationsManager = LocationsManager(connector: connector, sportId: sportType.numericId ?? "1")
            currentSportType = sportType
        }

        if let locationsManager {
            // Return the subscription from the current manager
            return locationsManager.subscribe()
        }
        else {
            return Fail(outputType: SubscribableContent<[Country]>.self, failure: ServiceProviderError.resourceNotFound)
                .eraseToAnyPublisher()
        }
    }    
}
