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
    private let sessionCoordinator: EveryMatrixSessionCoordinator

    // MARK: - Managers for different subscription types
    private var prelivePaginator: PreLiveMatchesPaginator?
    private var livePaginator: LiveMatchesPaginator?
    private var sportsManager: SportsManager?

    private var locationsManager: LocationsManager?
    private var currentSportType: SportType?

    private var popularTournamentsManager: PopularTournamentsManager?
    private var sportTournamentsManager: SportTournamentsManager?
    
    // MARK: - Match Details Manager
    private var matchDetailsManager: MatchDetailsManager?

    init(connector: EveryMatrixConnector, sessionCoordinator: EveryMatrixSessionCoordinator) {
        self.connector = connector
        self.sessionCoordinator = sessionCoordinator
    }

    deinit {
        prelivePaginator?.unsubscribe()
        sportsManager?.unsubscribe()
        locationsManager?.unsubscribe()
        popularTournamentsManager?.unsubscribe()
        sportTournamentsManager?.unsubscribe()
        matchDetailsManager?.unsubscribe()
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
    
    // MARK: - New Filtered Subscription Methods
    
    func subscribeToFilteredPreLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Clean up any existing paginator
        prelivePaginator?.unsubscribe()
        
        // Create new paginator with filters
        let numberOfEvents = 10 // Default value, could be made configurable
        let numberOfMarkets = 5 // Default value, could be made configurable
        
        prelivePaginator = PreLiveMatchesPaginator(
            connector: connector,
            sportId: filters.sportId,
            numberOfEvents: numberOfEvents,
            numberOfMarkets: numberOfMarkets,
            filters: filters
        )
        
        return prelivePaginator!.subscribe()
    }
    
    func subscribeToFilteredLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Clean up any existing paginator
        livePaginator?.unsubscribe()
        
        // Create new paginator with filters
        let numberOfEvents = 10 // Default value, could be made configurable
        let numberOfMarkets = 5 // Default value, could be made configurable
        
        livePaginator = LiveMatchesPaginator(
            connector: connector,
            sportId: filters.sportId,
            numberOfEvents: numberOfEvents,
            numberOfMarkets: numberOfMarkets,
            filters: filters
        )
        
        return livePaginator!.subscribe()
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
        // Clean up any existing match details manager
        matchDetailsManager?.unsubscribe()
        
        // Create new match details manager
        matchDetailsManager = MatchDetailsManager(connector: connector, matchId: eventId)
        
        return matchDetailsManager!.subscribeEventDetails()
    }
    
    func subscribeToMarketGroups(eventId: String) -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError> {
        guard let manager = matchDetailsManager else {
            return Fail(error: ServiceProviderError.matchDetailsManagerNotFound).eraseToAnyPublisher()
        }
        
        // Verify the manager is for the correct eventId
        guard manager.matchId == eventId else {
            return Fail(error: ServiceProviderError.errorMessage(message: "MatchDetailsManager eventId mismatch: expected \(eventId), found \(manager.matchId)")).eraseToAnyPublisher()
        }
        
        return manager.subscribeToMarketGroups()
    }
    
    func subscribeToMarketGroupDetails(eventId: String, marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError> {
        guard let manager = matchDetailsManager else {
            return Fail(error: ServiceProviderError.matchDetailsManagerNotFound).eraseToAnyPublisher()
        }
        
        return manager.subscribeToMarketGroupDetails(marketGroupKey: marketGroupKey)
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

        // Create new sports manager with dynamic operator ID
        let operatorId = self.sessionCoordinator.getOperatorIdOrDefault()
        sportsManager = SportsManager(connector: connector, operatorId: operatorId)

        return sportsManager!.subscribe()
    }
    
    func checkServicesHealth() -> AnyPublisher<Bool, ServiceProviderError> {
        // Back to operatorInfo but with enhanced logging
        let router = WAMPRouter.getClientIdentity
        
        return connector.request(router)
            .print("checkServicesHealth-operatorInfo")
            .map { [weak self] (response: EveryMatrix.ClientIdentityResponse) -> Bool in
                print("🏥 EveryMatrixProvider: OperatorInfo health check successful")
                
                // Extract and store UCS operator ID from response
                // let operatorId = response.operatorIdString
                // print("🏥 EveryMatrixProvider: Found UCS operator ID: \(operatorId)")
                self?.sessionCoordinator.saveCID(response.CID) 
                self?.sessionCoordinator.saveOperatorId("4093")

                return true
            }
            .mapError { error -> ServiceProviderError in
                print("❌ EveryMatrixProvider: Health check failed: \(error)")
                // Check if this is a maintenance mode error
                if case .errorDetailedMessage(_, let message) = error {
                    if message.contains("maintenance") {
                        return .maintenanceMode(message: message)
                    }
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {
        // First check if we have an active match details manager for this event
        if let matchDetailsManager = self.matchDetailsManager {
            // Use the match details manager to observe live data
//            return matchDetailsManager.observeEventInfosForEvent(eventId: id)
//                .map { eventLiveData in
//                    return SubscribableContent.contentUpdate(content: eventLiveData)
//                }
//                .setFailureType(to: ServiceProviderError.self)
//                .eraseToAnyPublisher()
            // TODO: match details manager to observe live data
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        
        // Fallback to live paginator if no match details manager
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
        
        // First check if we have an active match details manager with this market
        if let matchDetailsManager = self.matchDetailsManager {
            // Use the match details manager to observe market updates
            return matchDetailsManager.observeMarket(withId: id)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        // Fallback to checking paginators
        guard let prelivePaginator = prelivePaginator else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Paginator not active")).eraseToAnyPublisher()
        }

        // Check both paginators to find which one contains this market
        if prelivePaginator.marketExists(id: id) {
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
        
        // First check if we have an active match details manager with this outcome
        if let matchDetailsManager = self.matchDetailsManager {
            // Use the match details manager to observe outcome updates
            return matchDetailsManager.observeOutcome(withId: id)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        // Fallback to checking paginators
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
    
    // MARK: - RPC Methods for Tournaments
    
    /// Get popular tournaments via RPC call (one-time fetch)
    func getPopularTournaments(forSportType sportType: SportType, tournamentsCount: Int = 10) -> AnyPublisher<[Tournament], ServiceProviderError> {
        let sportId = sportType.numericId ?? "1"
        let language = "en" // Could be made configurable
        
        let router = WAMPRouter.getPopularTournaments(language: language, sportId: sportId, maxResults: tournamentsCount)
        
        let rpcResponsePublisher: AnyPublisher<EveryMatrix.RPCResponse, ServiceProviderError> = connector.request(router)
        return rpcResponsePublisher
            .map { [weak self] rpcResponse in
                return self?.processTournamentsFromRPCResponse(rpcResponse) ?? []
            }
            .eraseToAnyPublisher()
    }
    
    /// Get all tournaments via RPC call (one-time fetch)
    func getTournaments(forSportType sportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError> {
        let sportId = sportType.numericId ?? "1"
        let language = "en" // Could be made configurable
        
        let router = WAMPRouter.getTournaments(language: language, sportId: sportId)
        
        let rpcResponsePublisher: AnyPublisher<EveryMatrix.RPCResponse, ServiceProviderError> = connector.request(router)
        return rpcResponsePublisher
            .map { [weak self] rpcResponse in
                return self?.processTournamentsFromRPCResponse(rpcResponse) ?? []
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Tournament Processing
    
    /// Process tournaments from RPC response
    private func processTournamentsFromRPCResponse(_ response: EveryMatrix.RPCResponse) -> [Tournament] {
        // Create temporary store for processing
        let tempStore = EveryMatrix.EntityStore()
        
        // Store all entities from the response using the new bulk store method
        tempStore.storeRecords(response.records)
        
        // Get all tournaments from the store
        let tournamentsDTO = tempStore.getAllInOrder(EveryMatrix.TournamentDTO.self)
        
        // Convert DTOs to internal tournament models
        let internalTournaments = tournamentsDTO.compactMap { tournamentDTO in
            EveryMatrix.TournamentBuilder.build(from: tournamentDTO, store: tempStore)
        }
        
        // Map to domain Tournament objects
        let tournaments = internalTournaments.compactMap { internalTournament in
            EveryMatrixModelMapper.tournament(fromInternalTournament: internalTournament)
        }
        
        // Filter tournaments that have events or are active
        return tournaments.filter { tournament in
            tournament.numberOfEvents > 0
        }
    }

    func getMarketGroups(forEvent event: Event, includeMixMatchGroup: Bool, includeAllMarketsGroup: Bool) -> AnyPublisher<[MarketGroup], Never> {
        // Check if we have an active match details manager for this event
        if let matchDetailsManager = self.matchDetailsManager {
            // Get market groups from the match details manager
            let marketGroups = matchDetailsManager.getMarketGroups()
            
            if marketGroups.isEmpty {
                // Fallback to single "All Markets" group if no market groups found
                let allMarketsGroup = MarketGroup(
                    type: "0",
                    id: "all_markets",
                    groupKey: "All Markets",
                    translatedName: "All Markets",
                    position: 0,
                    isDefault: true,
                    numberOfMarkets: event.markets.count,
                    loaded: true,
                    markets: event.markets
                )
                return Just([allMarketsGroup]).eraseToAnyPublisher()
            }
            
            return Just(marketGroups).eraseToAnyPublisher()
        }
        
        // Fallback to default behavior if no match details manager
        let defaultMarketGroup = MarketGroup(
            type: "0",
            id: "0",
            groupKey: "All Markets",
            translatedName: "All Markets",
            position: 0,
            isDefault: true,
            numberOfMarkets: event.markets.count,
            loaded: true,
            markets: event.markets
        )
        
        return Just([defaultMarketGroup]).eraseToAnyPublisher()
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
//        let language = "en" // Could be made configurable
//        let operatorId = self.sessionCoordinator.getOperatorIdOrDefault()
//        let router = WAMPRouter.oddsMatch(operatorId: operatorId,
//                                          language: language,
//                                          matchId: eventId)
//
//        return connector.request(router)
//            .tryMap { (response: EveryMatrix.RPCResponse) -> Event in
//                guard let event = self.buildEvent(from: response, expectedMatchId: eventId) else {
//                    throw ServiceProviderError.decodingError(message: "Failed to build event for \(eventId)")
//                }
//                return event
//            }
//            .mapError { error -> ServiceProviderError in
//                if let serviceError = error as? ServiceProviderError {
//                    return serviceError
//                }
//                return ServiceProviderError.decodingError(message: error.localizedDescription)
//            }
//            .eraseToAnyPublisher()
        
        return self.getEventWithMainMarkets(eventId: eventId, mainMarketsCount: 1)
    }

    private func getEventWithMainMarkets(eventId: String, mainMarketsCount: Int = 1) -> AnyPublisher<Event, ServiceProviderError> {
        let language = "en" // Could be made configurable
        let operatorId = self.sessionCoordinator.getOperatorIdOrDefault()

        let router = WAMPRouter.matchWithMainMarkets(
            operatorId: operatorId,
            language: language,
            matchId: eventId,
            mainMarketsCount: mainMarketsCount
        )

        return connector.request(router)
            .tryMap { (response: EveryMatrix.AggregatorResponse) -> Event in
                guard let event = self.buildEvent(from: response, expectedMatchId: eventId) else {
                    throw ServiceProviderError.decodingError(message: "Failed to build event with main markets for \(eventId)")
                }
                return event
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.decodingError(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
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

    // MARK: - Private Helper Methods

    private func buildEvent(from response: EveryMatrix.RPCResponse, expectedMatchId: String?) -> Event? {
        let tempStore = EveryMatrix.EntityStore()
        tempStore.storeRecords(response.records)

        let matchDTO: EveryMatrix.MatchDTO?
        if let expectedMatchId,
           let dto = tempStore.get(EveryMatrix.MatchDTO.self, id: expectedMatchId) {
            matchDTO = dto
        } else {
            matchDTO = tempStore.getAllInOrder(EveryMatrix.MatchDTO.self).first
        }

        guard let matchDTO,
              let internalMatch = EveryMatrix.MatchBuilder.build(from: matchDTO, store: tempStore) else {
            return nil
        }

        return EveryMatrixModelMapper.event(fromInternalMatch: internalMatch)
    }

    private func buildEvent(from response: EveryMatrix.AggregatorResponse, expectedMatchId: String?) -> Event? {
        let tempStore = EveryMatrix.EntityStore()
        tempStore.storeRecords(response.records)

        let matchDTO: EveryMatrix.MatchDTO?
        if let expectedMatchId,
           let dto = tempStore.get(EveryMatrix.MatchDTO.self, id: expectedMatchId) {
            matchDTO = dto
        } else {
            matchDTO = tempStore.getAllInOrder(EveryMatrix.MatchDTO.self).first
        }

        guard let matchDTO,
              let internalMatch = EveryMatrix.MatchBuilder.build(from: matchDTO, store: tempStore) else {
            return nil
        }

        return EveryMatrixModelMapper.event(fromInternalMatch: internalMatch)
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
