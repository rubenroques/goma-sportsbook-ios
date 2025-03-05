import Combine
import Foundation
import SharedModels

public class Client {

    public enum ProviderType {
        case everymatrix
        case sportradar
    }

    public var privilegedAccessManagerConnectionStatePublisher: AnyPublisher<ConnectorState, Never> = Just(ConnectorState.disconnected).eraseToAnyPublisher()

    public var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.eventsConnectionStateSubject.eraseToAnyPublisher()
    }
    private var eventsConnectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.disconnected)

    public var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Never> = Just(ConnectorState.disconnected).eraseToAnyPublisher()

    private var providerType: ProviderType = .everymatrix

    private var privilegedAccessManager: (any PrivilegedAccessManager)?
    private var bettingProvider: (any BettingProvider)?
    private var eventsProvider: (any EventsProvider)?
    private var promotionsProvider: (any PromotionsProvider)? // TODO: SP Merge - Use login connectors

    private var managedContentProvider: (any ManagedContentProvider)? // TODO: SP Merge - Use login connectors

    private var analyticsProvider: (any AnalyticsProvider)?

    private var cancellables = Set<AnyCancellable>()

    public var sumsubDataProvider: SumsubDataProvider?

    private var configuration = Configuration() {
        didSet {
            switch self.configuration.environment {
            case .production:
                SportRadarConfiguration.shared.environment = .production
            case .staging:
                SportRadarConfiguration.shared.environment = .staging
            case .development:
                SportRadarConfiguration.shared.environment = .development
            }

        }
    }

    public var appBaseUrl: String = SportRadarConfiguration.shared.clientBaseUrl

    public init(providerType: ProviderType, configuration: Configuration) {
        self.providerType = providerType
        self.configuration = configuration

        switch configuration.environment {
        case .production:
            SportRadarConfiguration.shared.environment = .production
        case .staging:
            SportRadarConfiguration.shared.environment = .staging
        case .development:
            SportRadarConfiguration.shared.environment = .development
        }
    }

    public func connect() {
        switch self.providerType {
        case .everymatrix:
            fatalError()
            // let everymatrixProvider = EverymatrixProvider()
            // self.privilegedAccessManager = everymatrixProvider
            // self.bettingProvider = everymatrixProvider
            // self.eventsProvider = everymatrixProvider
        case .sportradar:

            // Session Coordinator
            let sessionCoordinator = SportRadarSessionCoordinator()

            let sportRadarPrivilegedAccessManager = SportRadarPrivilegedAccessManager(sessionCoordinator: sessionCoordinator,
                                                                             connector: OmegaConnector())

            self.privilegedAccessManager = sportRadarPrivilegedAccessManager
            let eventsProvider = SportRadarEventsProvider(sessionCoordinator: sessionCoordinator,
                                                           socketConnector: SportRadarSocketConnector(),
                                                           restConnector: SportRadarRestConnector())
            self.eventsProvider = eventsProvider
            self.bettingProvider = SportRadarBettingProvider(sessionCoordinator: sessionCoordinator)

            self.managedContentProvider = SportRadarManagedContentProvider(
                sessionCoordinator: sessionCoordinator,
                eventsProvider: eventsProvider,
                gomaManagedContentProvider: GomaManagedContentProvider(gomaAPIAuthenticator: GomaAPIAuthenticator(deviceIdentifier: self.configuration.deviceUUID ?? ""))
            )

            sessionCoordinator.registerUpdater(sportRadarPrivilegedAccessManager, forKey: .launchToken)

            self.eventsProvider!.connectionStatePublisher
                .sink(receiveCompletion: { completion in

                }, receiveValue: { [weak self] connectorState in
                    self?.eventsConnectionStateSubject.send(connectorState)
                }).store(in: &self.cancellables)

            self.bettingConnectionStatePublisher = self.bettingProvider!.connectionStatePublisher

            self.sumsubDataProvider = SumsubDataProvider()

            self.analyticsProvider = SportRadarAnalyticsProvider()
        }
    }

    public func forceReconnect() {

    }

    public func disconnect() {

    }

    public func reconnectIfNeeded() {
        self.eventsProvider?.reconnectIfNeeded()
    }

}

extension Client {

    //
    // Sports
    //
    public func subscribePreLiveSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribePreLiveSportTypes(initialDate: initialDate, endDate: endDate)
    }

    public func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeLiveSportTypes()
    }

    public func subscribeAllSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeAllSportTypes()
    }

    //
    // Events
    //
    public func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeLiveMatches(forSportType: sportType)
    }

    public func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.requestLiveMatchesNextPage(forSportType: sportType)
    }

    public func subscribePreLiveMatches(forSportType sportType: SportType,
                                        initialDate: Date? = nil,
                                        endDate: Date? = nil,
                                        eventCount: Int? = nil,
                                        sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribePreLiveMatches(forSportType: sportType,
                                                      initialDate: initialDate,
                                                      endDate: endDate,
                                                      eventCount: eventCount,
                                                      sortType: sortType)
    }

    public func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date? = nil, endDate: Date? = nil, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.requestPreLiveMatchesNextPage(forSportType: sportType,
                                                      initialDate: initialDate,
                                                      endDate: endDate,
                                                      sortType: sortType)
    }

    func subscribeEndedMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeEndedMatches(forSportType: sportType)
    }

    func requestEndedMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.requestEndedMatchesNextPage(forSportType: sportType)
    }

    //
    // Creates new Subscriptions
    public func subscribeToMarketDetails(withId id: String, onEventId eventId: String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToMarketDetails(withId: id, onEventId: eventId)
    }

    public func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeEventDetails(eventId: eventId)
    }

    public func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
    }


    public func subscribeOutrightEvent(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {

        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeOutrightEvent(forMarketGroupId: marketGroupId)
    }


    public func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeOutrightMarkets(forMarketGroupId: marketGroupId)
    }

    public func subscribeEventSummary(eventId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeEventSummary(eventId: eventId)
    }

    public func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToLiveDataUpdates(forEventWithId: id)
    }

    //
    // Uses the publishers from the events list (prelive and live)
    //
    public func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToEventOnListsLiveDataUpdates(withId: id)
    }

    public func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToEventOnListsMarketUpdates(withId: id)
    }

    public func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToEventOnListsOutcomeUpdates(withId: id)
    }

    //
    //
    public func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getEventDetails(eventId: eventId)
    }

    public func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getEventSecundaryMarkets(eventId: eventId)
    }

    public func getEventLiveData(eventId : String) -> AnyPublisher<EventLiveData, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getEventLiveData(eventId: eventId)
    }

    public func subscribeEventMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeEventMarkets(eventId: eventId)
    }

    public func subscribeSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
         guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeSportTypes()
    }

    public func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.addFavoriteToList(listId: listId, eventId: eventId)
    }

    public func getAlertBanners() -> AnyPublisher<[AlertBanner], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getAlertBanners()
    }

    public func getNews() -> AnyPublisher<[News], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getNews()
    }

    public func getPromotedEventGroupsPointers() -> AnyPublisher<[EventGroupPointer], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getPromotedEventGroupsPointers()
    }

    public func getPromotedEventsGroups() -> AnyPublisher<[EventsGroup], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getPromotedEventsGroups()
    }

    public func getPromotionalSlidingTopEventsPointers() -> AnyPublisher<[EventMetadataPointer], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getPromotionalSlidingTopEventsPointers()
    }

    public func getPromotedEventsBySport() -> AnyPublisher<[SportType : Events], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getPromotedEventsBySport()
    }

    public func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.addFavoriteItem(favoriteId: favoriteId, type: type)
    }

    public func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.deleteFavoriteItem(favoriteId: favoriteId, type: type)
    }

    public func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getFeaturedTips(page: page, limit: limit, topTips: topTips, followersTips: followersTips, friendsTips: friendsTips, userId: userId, homeTips: homeTips)
    }

}

extension Client {
    public func getMarketGroups(forEvent event: Event) -> AnyPublisher<[MarketGroup], Never> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            let defaultMarketGroup = [MarketGroup.init(type: "0",
                                                       id: "0",
                                                       groupKey: "All Markets",
                                                       translatedName: "All Markets",
                                                       position: 0,
                                                       isDefault: true,
                                                       numberOfMarkets: nil,
                                                       loaded: true,
                                                       markets: event.markets)]
            return Just(defaultMarketGroup).eraseToAnyPublisher()
        }
        return eventsProvider.getMarketGroups(forEvent: event)
    }

    public func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getFieldWidgetId(eventId: eventId)
    }

    public func getFieldWidget(eventId: String, isDarkTheme: Bool? = nil) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getFieldWidget(eventId: eventId, isDarkTheme: isDarkTheme)
    }

    public func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getStatsWidget(eventId: eventId, marketTypeName: marketTypeName, isDarkTheme: isDarkTheme)
    }

    public func getAvailableSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[SportType], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getAvailableSportTypes(initialDate: initialDate, endDate: endDate)
    }

    public func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getSportRegions(sportId: sportId)
    }

    public func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getRegionCompetitions(regionId: regionId)
    }

    public func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getCompetitionMarketGroups(competitionId: competitionId)
    }

    public func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool = false) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getSearchEvents(query: query, resultLimit: resultLimit, page: page, isLive: isLive)
    }

    public func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getHomeSliders()
    }

    public func getPromotionalTopBanners() -> AnyPublisher<[PromotionalBanner], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getPromotionalTopBanners()
    }

    public func getPromotionalSlidingTopEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getPromotionalSlidingTopEvents()
    }

    public func getPromotionalTopStories() -> AnyPublisher<[PromotionalStory], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getPromotionalTopStories()
    }

    //
    //
    public func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getPromotedSports()
    }

    public func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getHomeSliders()
    }

    public func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getEventForMarketGroup(withId: marketGroupId)
    }


    public func getEventsForEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getEventsForEventGroup(withId: eventGroupId)
    }

    //
    //
    public func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getEventSummary(eventId: eventId, marketLimit: marketLimit)
    }

    public func getEventSummary(forMarketId marketId: String) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getEventSummary(forMarketId: marketId)
    }

    public func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getMarketInfo(marketId: marketId)
    }

    public func getFavoritesList() -> AnyPublisher<FavoritesListResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getFavoritesList()
    }

    public func addFavoritesList(name: String) -> AnyPublisher<FavoritesListAddResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.addFavoritesList(name: name)
    }

    public func deleteFavoritesList(listId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.deleteFavoritesList(listId: listId)
    }

    public func addFavoritesToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.addFavoriteToList(listId: listId, eventId: eventId)
    }

    public func getFavoritesFromList(listId: Int) -> AnyPublisher<FavoriteEventResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getFavoritesFromList(listId: listId)
    }

    public func deleteFavoriteFromList(eventId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {

        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.deleteFavoriteFromList(eventId: eventId)
    }

    public func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.subscribeToEventAndSecondaryMarkets(withId: id)
    }

    public func getPromotedBetslips(userId: String?) -> AnyPublisher<[PromotedBetslip], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getPromotedBetslips(userId: userId)
    }

    public func getHighlightedLiveEventsPointers(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getHighlightedLiveEventsPointers(eventCount: eventCount, userId: userId)
    }

    public func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getHighlightedLiveEvents(eventCount: eventCount, userId: userId)
    }

}


extension Client {

    //
    // PrivilegedAccessManager
    //
    public func loginUser(withUsername username: String, andPassword password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.login(username: username, password: password)
    }

    public func getProfile() -> AnyPublisher<UserProfile, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getUserProfile(withKycExpire: nil)
    }

    public func hasSecurityQuestions() -> Bool {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return false
        }
        return privilegedAccessManager.hasSecurityQuestions
    }

    public func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateUserProfile(form: form)
    }

    public func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.simpleSignUp(form: form)
    }

    public func signUp(form: SignUpForm) -> AnyPublisher<SignUpResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signUp(form: form)
    }

    public func updateExtraInfo(placeOfBirth: String?, address2: String?) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateExtraInfo(placeOfBirth: placeOfBirth, address2: address2)
    }

    public func updateDeviceIdentifier(deviceIdentifier: String, appVersion: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateDeviceIdentifier(deviceIdentifier: deviceIdentifier, appVersion: appVersion)
    }


    public func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.checkEmailRegistered(email)
    }

    public func validateUsername(_ username: String) -> AnyPublisher<UsernameValidation, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.validateUsername(username)
    }

    public func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signupConfirmation(email, confirmationCode: confirmationCode)
    }

    public func forgotPassword(email: String, secretQuestion: String? = nil, secrestAnswer: String? = nil) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.forgotPassword(email: email, secretQuestion: secretQuestion, secretAnswer: secrestAnswer)
    }

    public func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
    }

    public func getPasswordPolicy() -> AnyPublisher<PasswordPolicy, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getPasswordPolicy()
    }

    public func updateWeeklyDepositLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateWeeklyDepositLimits(newLimit: newLimit)
    }

    public func updateWeeklyBettingLimits(newLimit: Double) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateWeeklyBettingLimits(newLimit: newLimit)
    }

    public func updateResponsibleGamingLimits(newLimit: Double, limitType: String, hasRollingWeeklyLimits: Bool) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateResponsibleGamingLimits(newLimit: newLimit, limitType: limitType, hasRollingWeeklyLimits: hasRollingWeeklyLimits)
    }

    public func getPersonalDepositLimits() -> AnyPublisher<PersonalDepositLimitResponse, ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getPersonalDepositLimits()
    }

    public func getLimits() -> AnyPublisher<LimitsResponse, ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getLimits()
    }

    public func getResponsibleGamingLimits(periodTypes: String? = nil, limitTypes: String? = nil) -> AnyPublisher<ResponsibleGamingLimitsResponse, ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getResponsibleGamingLimits(periodTypes: periodTypes, limitTypes: limitTypes)
    }

    public func lockPlayer(isPermanent: Bool? = nil, lockPeriodUnit: String? = nil, lockPeriod: String? = nil) -> AnyPublisher<BasicResponse, ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.lockPlayer(isPermanent: isPermanent, lockPeriodUnit: lockPeriodUnit, lockPeriod: lockPeriod)
    }

    public func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getUserBalance()
    }

    public func getUserCashbackBalance() -> AnyPublisher<CashbackBalance, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getUserCashbackBalance()
    }

    public func signUpCompletion(form: ServicesProvider.UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signUpCompletion(form: form)
    }


    public func getMobileVerificationCode(forMobileNumber mobileNumber: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getMobileVerificationCode(forMobileNumber: mobileNumber)
    }

    public func verifyMobileCode(code: String, requestId: String) -> AnyPublisher<MobileVerifyResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.verifyMobileCode(code: code, requestId: requestId)
    }


}

extension Client {

    public func getAllCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getAllCountries()
    }

    public func getCountries() -> AnyPublisher<[SharedModels.Country], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getCountries()
    }

    public func getCurrentCountry() -> AnyPublisher<SharedModels.Country?, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getCurrentCountry()
    }

}

extension Client {

    //
    // Betslip
    //
    public func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getAllowedBetTypes(withBetTicketSelections: betTicketSelections)
    }

    public func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(outputType: BetslipPotentialReturn.self,
                        failure: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.calculatePotentialReturn(forBetTicket: betTicket)
    }

    public func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.placeBets(betTickets: betTickets, useFreebetBalance: useFreebetBalance)
    }

    public func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.confirmBoostedBet(identifier: identifier)
    }

    public func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.rejectBoostedBet(identifier: identifier)
    }

    public func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.calculateBetBuilderPotentialReturn(forBetTicket: betTicket)
    }

    public func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.placeBetBuilderBet(betTicket: betTicket, calculatedOdd: calculatedOdd)
    }

    //
    // My Bets
    //
    public func getBettingHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getBetHistory(pageIndex: pageIndex)
    }

    public func getOpenBetsHistory(pageIndex: Int, startDate: String? = nil, endDate: String? = nil) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getOpenBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
    }

    public func getResolvedBetsHistory(pageIndex: Int, startDate: String? = nil, endDate: String? = nil) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getResolvedBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
    }

    public func getWonBetsHistory(pageIndex: Int, startDate: String? = nil, endDate: String? = nil) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getWonBetsHistory(pageIndex: pageIndex, startDate: startDate, endDate: endDate)
    }

    public func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getBetDetails(identifier: identifier)
    }

    public func getBetslipSettings() -> AnyPublisher<BetslipSettings?, Never> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Just(nil).eraseToAnyPublisher()
        }

        return bettingProvider.getBetslipSettings()
    }

    public func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Just(false).eraseToAnyPublisher()
        }

        return bettingProvider.updateBetslipSettings(betslipSettings)
    }

    public func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getBetHistory(pageIndex: pageIndex)
    }

    public func updateTicketOdds(betId: String) -> AnyPublisher<Bet, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.updateTicketOdds(betId: betId)
    }

    public func getTicketQRCode(betId: String) -> AnyPublisher<BetQRCode, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getTicketQRCode(betId: betId)
    }

    public func getSocialSharedTicket(shareId: String) -> AnyPublisher<Bet, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getSocialSharedTicket(shareId: shareId)
    }

    public func deleteTicket(betId: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.deleteTicket(betId: betId)
    }

    public func updateTicket(betId: String, betTicket: BetTicket) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.updateTicket(betId: betId, betTicket: betTicket)
    }

}

// Documents
extension Client {

    public func getDocumentTypes() -> AnyPublisher<DocumentTypesResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getDocumentTypes()
    }

    public func getUserDocuments() -> AnyPublisher<UserDocumentsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getUserDocuments()
    }

    public func uploadUserDocument(documentType: String, file: Data, fileName: String) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.uploadUserDocument(documentType: documentType, file: file, fileName: fileName)
    }

    public func uploadMultipleUserDocuments(documentType: String, files: [String: Data]) -> AnyPublisher<UploadDocumentResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.uploadMultipleUserDocuments(documentType: documentType, files: files)
    }

    public func getPayments() -> AnyPublisher<SimplePaymentMethodsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getPayments()
    }

    public func processDeposit(paymentMethod: String, amount: Double, option: String) -> AnyPublisher<ProcessDepositResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.processDeposit(paymentMethod: paymentMethod, amount: amount, option: option)
    }

    public func updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?, nameOnCard: String? = nil, encryptedExpiryYear: String? = nil, encryptedExpiryMonth: String? = nil, encryptedSecurityCode: String? = nil, encryptedCardNumber: String? = nil) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.updatePayment(amount: amount, paymentId: paymentId, type: type, returnUrl: returnUrl, nameOnCard: nameOnCard, encryptedExpiryYear: encryptedExpiryYear, encryptedExpiryMonth: encryptedExpiryMonth, encryptedSecurityCode: encryptedSecurityCode, encryptedCardNumber: encryptedCardNumber)
    }

    public func cancelDeposit(paymentId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.cancelDeposit(paymentId: paymentId)
    }

    public func checkPaymentStatus(paymentMethod: String, paymentId: String) -> AnyPublisher<PaymentStatusResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.checkPaymentStatus(paymentMethod: paymentMethod, paymentId: paymentId)
    }

    public func getWithdrawalMethods() -> AnyPublisher<[WithdrawalMethod], ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getWithdrawalMethods()
    }

    public func processWithdrawal(paymentMethod: String, amount: Double, conversionId: String? = nil) -> AnyPublisher<ProcessWithdrawalResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.processWithdrawal(paymentMethod: paymentMethod, amount: amount, conversionId: conversionId)
    }

    public func prepareWithdrawal(paymentMethod: String) -> AnyPublisher<PrepareWithdrawalResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.prepareWithdrawal(paymentMethod: paymentMethod)
    }

    public func getPendingWithdrawals() -> AnyPublisher<[PendingWithdrawal], ServiceProviderError> {

        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getPendingWithdrawals()
    }

    public func cancelWithdrawal(paymentId: Int) -> AnyPublisher<CancelWithdrawalResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.cancelWithdrawal(paymentId: paymentId)
    }

    public func getPaymentInformation() -> AnyPublisher<PaymentInformation, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getPaymentInformation()
    }

    public func addPaymentInformation(type: String, fields: String) -> AnyPublisher<AddPaymentInformationResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.addPaymentInformation(type: type, fields: fields)
    }

    public func getTransactionsHistory(startDate: String, endDate: String, transactionTypes: [TransactionType]? = nil, pageNumber: Int? = nil) -> AnyPublisher<[TransactionDetail], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getTransactionsHistory(startDate: startDate, endDate: endDate, transactionTypes: transactionTypes, pageNumber: pageNumber)
    }

    public func getGrantedBonuses() -> AnyPublisher<[GrantedBonus], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getGrantedBonuses()
    }

    public func redeemBonus(code: String) -> AnyPublisher<RedeemBonusResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.redeemBonus(code: code)
    }

    public func getAvailableBonuses() -> AnyPublisher<[AvailableBonus], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getAvailableBonuses()
    }

    public func redeemAvailableBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.redeemAvailableBonus(partyId: partyId, code: code)
    }

    public func cancelBonus(bonusId: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.cancelBonus(bonusId: bonusId)
    }

    public func optOutBonus(partyId: String, code: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.optOutBonus(partyId: partyId, code: code)
    }

    public func contactUs(firstName: String, lastName: String, email: String, subject: String, message: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.contactUs(firstName: firstName, lastName: lastName, email: email, subject: subject, message: message)
    }

    public func contactSupport(userIdentifier: String, firstName: String, lastName: String, email: String, subject: String, subjectType: String, message: String, isLogged: Bool) -> AnyPublisher<SupportResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.contactSupport(userIdentifier: userIdentifier, firstName: firstName, lastName: lastName, email: email, subject: subject, subjectType: subjectType, message: message, isLogged: isLogged)
    }

    public func calculateCashout(betId: String, stakeValue: String? = nil) -> AnyPublisher<Cashout, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.calculateCashout(betId: betId, stakeValue: stakeValue)
    }

    public func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.allowedCashoutBetIds()
    }

    public func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double? = nil) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.cashoutBet(betId: betId, cashoutValue: cashoutValue, stakeValue: stakeValue)
    }

    public func getFreebet() -> AnyPublisher<FreebetBalance, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getFreebet()
    }

    public func calculateCashback(forBetTicket betTicket: BetTicket)  -> AnyPublisher<CashbackResult, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.calculateCashback(forBetTicket: betTicket)
    }

    public func getSharedTicket(betslipId: String) -> AnyPublisher<SharedTicketResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getSharedTicket(betslipId: betslipId)
    }

    public func getTicketSelection(ticketSelectionId: String) -> AnyPublisher<TicketSelection, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.getTicketSelection(ticketSelectionId: ticketSelectionId)
    }

    public func getAllConsents() -> AnyPublisher<[ConsentInfo], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getAllConsents()
    }

    public func getUserConsents() -> AnyPublisher<[UserConsent], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getUserConsents()
    }

    public func setUserConsents(consentVersionIds: [Int]? = nil, unconsetVersionIds: [Int]? = nil) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.setUserConsents(consentVersionIds: consentVersionIds, unconsenVersionIds: unconsetVersionIds)
    }

    public func getSumsubAccessToken(userId: String, levelName: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getSumsubAccessToken(userId: userId, levelName: levelName)
    }

    public func getSumsubApplicantData(userId: String) -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getSumsubApplicantData(userId: userId)
    }

    public func generateDocumentTypeToken(docType: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.generateDocumentTypeToken(docType: docType)
    }

    public func checkDocumentationData() -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.checkDocumentationData()
    }

    public func getReferralLink() -> AnyPublisher<ReferralLink, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getReferralLink()
    }

    public func getReferees() -> AnyPublisher<[Referee], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getReferees()
    }
}

// AnalyticsProvider
extension Client {

    public func trackEvent(_ event: AnalyticsTrackedEvent, userIdentifer: String?) -> AnyPublisher<Void, ServiceProviderError> {
        guard
            let analyticsProvider = self.analyticsProvider
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        let vaixAnalyticsEvent = SportRadarModelMapper.vaixAnalyticsEvent(fromAnalyticsTrackedEvent: event)

        return analyticsProvider.trackEvent(vaixAnalyticsEvent, userIdentifer: userIdentifer).eraseToAnyPublisher()
    }

}

extension Client {

    public func updateDeviceIdentifier(deviceIdentifier: String) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.updateDeviceIdentifier(deviceIdentifier: deviceIdentifier)
    }

    public func isPromotionsProviderEnabled(isEnabled: Bool) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.isPromotionsProviderEnabled(isEnabled: isEnabled)
    }

    public func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.login(username: username, password: password)
    }

    public func anonymousLogin() -> AnyPublisher<String, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.anonymousLogin()
    }

    public func logoutUser() -> AnyPublisher<String, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.logoutUser()
    }

    public func basicSignUp(form: SignUpForm) -> AnyPublisher<DetailedSignUpResponse, ServiceProviderError> {
        guard
            let promotionsProvider = self.promotionsProvider
        else {
            return Fail(error: ServiceProviderError.promotionsProviderNotFound).eraseToAnyPublisher()
        }

        return promotionsProvider.basicSignUp(form: form)
    }
}

// MARK: - ManagedContentProvider Implementation
extension Client {

    public func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.preFetchHomeContent()
    }

    public func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getHomeTemplate()
    }

    public func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getAlertBanner()
    }

    public func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getBanners()
    }

    public func getCarouselEvents() -> AnyPublisher<CarouselEvents, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getCarouselEvents()
    }

    public func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsPointer], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getBoostedOddsPointers()
    }

    public func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getBoostedOddsEvents()
    }

    public func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getHeroCardPointers()
    }

    public func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: .managedContentProviderNotFound).eraseToAnyPublisher()
        }
        return managedContentProvider.getHeroCardEvents()
    }

    public func getTopImageCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getTopImageCardEvents()
    }

    public func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getStories()
    }

    public func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
    }

    public func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }
        return managedContentProvider.getProChoiceCardPointers()
    }

    public func getProChoiceMarketCards() -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: ServiceProviderError.managedContentProviderNotFound).eraseToAnyPublisher()
        }
        return managedContentProvider.getProChoiceMarketCards()
    }

    public func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: .managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getTopCompetitionsPointers()
    }

    public func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError> {
        guard
            let managedContentProvider = self.managedContentProvider
        else {
            return Fail(error: .managedContentProviderNotFound).eraseToAnyPublisher()
        }

        return managedContentProvider.getTopCompetitions()
    }

}

// Utilities
extension Client {

    public func getDatesFilter(timeRange: String) -> [Date] {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return []
        }

        return eventsProvider.getDatesFilter(timeRange: timeRange)
    }
}
