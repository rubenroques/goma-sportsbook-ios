import Combine
import Foundation
import SharedModels

public class Client {

    public enum ProviderType {
        case everymatrix
        case sportradar
        case goma
    }

    public var privilegedAccessManagerConnectionStatePublisher: AnyPublisher<ConnectorState, Never> = Just(ConnectorState.disconnected).eraseToAnyPublisher()

    public var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.eventsConnectionStateSubject.eraseToAnyPublisher()
    }
    private var eventsConnectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.disconnected)

    public var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Never> = Just(ConnectorState.disconnected).eraseToAnyPublisher()

    private var providerType: ProviderType = .everymatrix

    private var privilegedAccessManager: (any PrivilegedAccessManagerProvider)?
    private var bettingProvider: (any BettingProvider)?
    private var eventsProvider: (any EventsProvider)?
    private var homeContentProvider: (any HomeContentProvider)?

    private var customerSupportProvider: (any CustomerSupportProvider)?
    private var promotionalCampaignsProvider: (any PromotionalCampaignsProvider)?
    private var downloadableContentsProvider: (any DownloadableContentsProvider)?

    private var analyticsProvider: (any AnalyticsProvider)?
    private var casinoProvider: (any CasinoProvider)?

    private var cancellables = Set<AnyCancellable>()

    private var configuration = Configuration() {
        didSet {
            switch self.configuration.environment {
            case .production:
                SportRadarConfiguration.shared.environment = .production
                EveryMatrixUnifiedConfiguration.shared.environment = .production
            case .staging:
                SportRadarConfiguration.shared.environment = .staging
                EveryMatrixUnifiedConfiguration.shared.environment = .staging
            case .development:
                SportRadarConfiguration.shared.environment = .development
                EveryMatrixUnifiedConfiguration.shared.environment = .development
            }

        }
    }

    public init(providerType: ProviderType, configuration: Configuration) {
        self.providerType = providerType
        self.configuration = configuration

        switch configuration.environment {
        case .production:
            SportRadarConfiguration.shared.environment = .production
            EveryMatrixUnifiedConfiguration.shared.environment = .production
        case .staging:
            SportRadarConfiguration.shared.environment = .staging
            EveryMatrixUnifiedConfiguration.shared.environment = .staging
        case .development:
            SportRadarConfiguration.shared.environment = .development
            EveryMatrixUnifiedConfiguration.shared.environment = .development
        }

    }

    public func connect() {
        switch self.providerType {
        case .everymatrix:
            
            // Session Coordinator
            let sessionCoordinator = EveryMatrixSessionCoordinator()
            
            // This will trigger the connection to the EM WAMP socket
            let wampConnectionManaget = WAMPManager()
            let everyMatrixConnector = EveryMatrixConnector(wampManager: wampConnectionManaget)
                        
            everyMatrixConnector.connectionStatePublisher
                .sink(receiveCompletion: { completion in

                }, receiveValue: { [weak self] connectorState in
                    self?.eventsConnectionStateSubject.send(connectorState)
                }).store(in: &self.cancellables)
            
            
            let everyMatrixEventsProvider = EveryMatrixEventsProvider(connector: everyMatrixConnector, sessionCoordinator: sessionCoordinator)
            self.eventsProvider = everyMatrixEventsProvider
            
            // Player API for privilegedAccessManager
            let everyMatrixPlayerAPIConnector = EveryMatrixPlayerAPIConnector(sessionCoordinator: sessionCoordinator)
            
            let everyMatrixPrivilegedAccessManager = EveryMatrixPrivilegedAccessManager(
                connector: everyMatrixPlayerAPIConnector,
                sessionCoordinator: sessionCoordinator
            )

            self.privilegedAccessManager = everyMatrixPrivilegedAccessManager
            
            // Casino API
            let everyMatrixCasinoConnector = EveryMatrixCasinoConnector(sessionCoordinator: sessionCoordinator)
            let everyMatrixCasinoProvider = EveryMatrixCasinoProvider(connector: everyMatrixCasinoConnector)
            self.casinoProvider = everyMatrixCasinoProvider
            
            // Betting API
            let everyMatrixBettingProvider = EveryMatrixBettingProvider(sessionCoordinator: sessionCoordinator)
            self.bettingProvider = everyMatrixBettingProvider

            // CMS/HomeContent Provider - uses Goma CMS
            // Set Goma CMS environment based on client business unit
            if let businessUnit = self.configuration.clientBusinessUnit {
                switch businessUnit {
                case .betssonFrance:
                    GomaAPIClientConfiguration.shared.environment = .betsson
                case .betssonCameroon:
                    GomaAPIClientConfiguration.shared.environment = .betssonCameroon
                case .gomaDemo:
                    GomaAPIClientConfiguration.shared.environment = .gomaDemo
                }
            } else {
                // Default to gomaDemo for backward compatibility
                GomaAPIClientConfiguration.shared.environment = .gomaDemo
            }

            let gomaAuthenticator = GomaAuthenticator(deviceIdentifier: self.configuration.deviceUUID ?? "")
            let gomaHomeContentProvider = GomaHomeContentProvider(authenticator: gomaAuthenticator)
            self.homeContentProvider = EveryMatrixManagedContentProvider(
                gomaHomeContentProvider: gomaHomeContentProvider,
                casinoProvider: everyMatrixCasinoProvider,
                eventsProvider: everyMatrixEventsProvider
            )

            // Promotional Campaigns Provider - uses Goma CMS
            let gomaPromotionalCampaignsProvider = GomaPromotionalCampaignsProvider(authenticator: gomaAuthenticator)
            self.promotionalCampaignsProvider = EveryMatrixPromotionalCampaignsProvider(
                gomaPromotionalCampaignsProvider: gomaPromotionalCampaignsProvider
            )

        //
        case .goma:
            guard let deviceUUID = self.configuration.deviceUUID else {
                fatalError("GOMA API service provider required a deviceIdentifier")
            }

            // Set GomaAPIClientConfiguration environment based on client business unit
            if let businessUnit = self.configuration.clientBusinessUnit {
                switch businessUnit {
                case .betssonFrance:
                    GomaAPIClientConfiguration.shared.environment = .betsson
                case .betssonCameroon:
                    GomaAPIClientConfiguration.shared.environment = .betssonCameroon
                case .gomaDemo:
                    GomaAPIClientConfiguration.shared.environment = .gomaDemo
                }
            } else {
                // Default to gomaDemo for backward compatibility
                GomaAPIClientConfiguration.shared.environment = .gomaDemo
            }
            let authenticator = GomaAuthenticator(deviceIdentifier: deviceUUID)
            
            let gomaConnector = GomaConnector(authenticator: authenticator)

            let gomaAPIProvider = GomaProvider(connector: gomaConnector)
            self.privilegedAccessManager = gomaAPIProvider
            self.eventsProvider = gomaAPIProvider
            self.bettingProvider = gomaAPIProvider

            let gomaManagedContentProvider = GomaHomeContentProvider(authenticator: authenticator)
            self.homeContentProvider = gomaManagedContentProvider

            let gomaDownloadableContentsProvider = GomaDownloadableContentsProvider(authenticator: authenticator)
            self.downloadableContentsProvider = gomaDownloadableContentsProvider

            self.promotionalCampaignsProvider = GomaPromotionalCampaignsProvider(authenticator: authenticator)

            gomaAPIProvider.connectionStatePublisher
                .sink(receiveCompletion: { completion in

                }, receiveValue: { [weak self] connectorState in
                    self?.eventsConnectionStateSubject.send(connectorState)
                }).store(in: &self.cancellables)

        case .sportradar:

            // Session Coordinator
            let sessionCoordinator = SportRadarSessionCoordinator()


            let omegaConnector = OmegaConnector()
            let sportRadarPrivilegedAccessManager = SportRadarPrivilegedAccessManager(sessionCoordinator: sessionCoordinator,
                                                                             connector: omegaConnector)

            self.privilegedAccessManager = sportRadarPrivilegedAccessManager
            
            // This will trigger the connection to the SR socket
            let eventsProvider = SportRadarEventsProvider(sessionCoordinator: sessionCoordinator,
                                                           socketConnector: SportRadarSocketConnector(),
                                                           restConnector: SportRadarRestConnector())
            self.eventsProvider = eventsProvider
            self.bettingProvider = SportRadarBettingProvider(sessionCoordinator: sessionCoordinator)

            // The common API Authenticator
            // All subsets of the GOMA api should share the same Authenticator, it's a shared token and connection
            GomaAPIClientConfiguration.shared.environment = .betsson

            let  gomaAuthenticator =  GomaAuthenticator(deviceIdentifier: self.configuration.deviceUUID ?? "")

            self.homeContentProvider = SportRadarManagedContentProvider(
                sessionCoordinator: sessionCoordinator,
                eventsProvider: eventsProvider,
                homeContentProvider: GomaHomeContentProvider(authenticator: gomaAuthenticator)
            )

            self.downloadableContentsProvider = SportRadarDownloadableContentsProvider(
                sessionCoordinator: sessionCoordinator,
                gomaDownloadableContentsProvider: GomaDownloadableContentsProvider(authenticator: gomaAuthenticator)
            )

            self.customerSupportProvider = SportRadarCustomerSupportProvider(connector: omegaConnector)

            self.promotionalCampaignsProvider = GomaPromotionalCampaignsProvider(authenticator: gomaAuthenticator)

            sessionCoordinator.registerUpdater(sportRadarPrivilegedAccessManager, forKey: .launchToken)

            self.eventsProvider!.connectionStatePublisher
                .sink(receiveCompletion: { completion in

                }, receiveValue: { [weak self] connectorState in
                    self?.eventsConnectionStateSubject.send(connectorState)
                }).store(in: &self.cancellables)

            self.bettingConnectionStatePublisher = self.bettingProvider!.connectionStatePublisher

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

    public func getAcessToken() -> String? {
        return self.privilegedAccessManager?.accessToken
    }
}

extension Client {

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
    
    // MARK: - New Filtered Subscription Methods
    
    /// Subscribe to filtered pre-live matches using custom-matches-aggregator
    public func subscribeToFilteredPreLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard let eventsProvider = self.eventsProvider else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToFilteredPreLiveMatches(filters: filters)
    }
    
    /// Subscribe to filtered live matches using custom-matches-aggregator
    public func subscribeToFilteredLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard let eventsProvider = self.eventsProvider else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToFilteredLiveMatches(filters: filters)
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

    // Return the full Event with all it's Markets, usually used in the Match Detail screen
    public func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeEventDetails(eventId: eventId)
    }
    
    public func subscribeToMarketGroups(eventId: String) -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToMarketGroups(eventId: eventId)
    }
    
    public func subscribeToMarketGroupDetails(eventId: String, marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeToMarketGroupDetails(eventId: eventId, marketGroupKey: marketGroupKey)
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

    // Needs refactor, this func is too vague, 
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
    
    public func subscribePopularTournaments(forSportType sportType: SportType, tournamentsCount: Int = 10) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribePopularTournaments(forSportType: sportType, tournamentsCount: tournamentsCount)
    }

    public func subscribeSportTournaments(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeSportTournaments(forSportType: sportType)
    }
    
    // MARK: - Tournament RPC Methods (one-time fetch)
    
    public func getPopularTournaments(forSportType sportType: SportType, tournamentsCount: Int = 10) -> AnyPublisher<[Tournament], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getPopularTournaments(forSportType: sportType, tournamentsCount: tournamentsCount)
    }

    public func getTournaments(forSportType sportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getTournaments(forSportType: sportType)
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
    
    public func checkServicesHealth() -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.checkServicesHealth()
    }

    public func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.addFavoriteToList(listId: listId, eventId: eventId)
    }

    public func getNews() -> AnyPublisher<[News], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getNews()
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

    public func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?)
    -> AnyPublisher<FeaturedTips, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getFeaturedTips(page: page, limit: limit, topTips: topTips, followersTips: followersTips, friendsTips: friendsTips, userId: userId, homeTips: homeTips)
    }

}

extension Client {
    
    public func getMarketGroups(forEvent event: Event, includeMixMatchGroup hasMixMatchGroup: Bool, includeAllMarketsGroup hasAllMarketsGroup: Bool)
    -> AnyPublisher<[MarketGroup], Never>
    {
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
        return eventsProvider.getMarketGroups(forEvent: event, includeMixMatchGroup: hasMixMatchGroup, includeAllMarketsGroup: hasAllMarketsGroup)
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
    
    public func getMultiSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool = false) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        
        return eventsProvider.getMultiSearchEvents(query: query, resultLimit: resultLimit, page: page, isLive: isLive)
    }
    
    public func getRecommendedMatch(userId: String, isLive: Bool, limit: Int) -> AnyPublisher<[Event], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        
        return eventsProvider.getRecommendedMatch(userId: userId, isLive: isLive, limit: limit)
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
    
    
    public func getEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        
        return eventsProvider.getEventGroup(withId: eventGroupId)
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

    public func signUp(with formType: SignUpFormType) -> AnyPublisher<SignUpResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signUp(with: formType)
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

    public func getRegistrationConfig() -> AnyPublisher<RegistrationConfigResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getRegistrationConfig()
    }

    public func getBankingWebView(parameters: CashierParameters) -> AnyPublisher<CashierWebViewResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getBankingWebView(parameters: parameters)
    }

    // MARK: - Transaction History Methods

    public func getBankingTransactionsHistory(startDate: String, endDate: String, pageNumber: Int?) -> AnyPublisher<BankingTransactionsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getBankingTransactionsHistory(startDate: startDate, endDate: endDate, pageNumber: pageNumber)
    }

    public func getWageringTransactionsHistory(startDate: String, endDate: String, pageNumber: Int?) -> AnyPublisher<WageringTransactionsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getWageringTransactionsHistory(startDate: startDate, endDate: endDate, pageNumber: pageNumber)
    }

    public func getBankingTransactionsHistory(filter: TransactionDateFilter, pageNumber: Int?) -> AnyPublisher<BankingTransactionsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getBankingTransactionsHistory(filter: filter, pageNumber: pageNumber)
    }

    public func getWageringTransactionsHistory(filter: TransactionDateFilter, pageNumber: Int?) -> AnyPublisher<WageringTransactionsResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getWageringTransactionsHistory(filter: filter, pageNumber: pageNumber)
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

    public func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String? = nil, username: String? = nil, userId: String? = nil, oddsValidationType: String? = nil) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }
        return bettingProvider.placeBets(betTickets: betTickets, useFreebetBalance: useFreebetBalance, currency: currency, username: username, userId: userId, oddsValidationType: oddsValidationType)
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

        //METADATA for AI: Intentional variable name: vaixAnalyticsEvent, not a typo.
        let vaixAnalyticsEvent = SportRadarModelMapper.vaixAnalyticsEvent(fromAnalyticsTrackedEvent: event)
        return analyticsProvider.trackEvent(vaixAnalyticsEvent, userIdentifer: userIdentifer).eraseToAnyPublisher()
    }

}

// MARK: - ManagedContentProvider Implementation
extension Client {

    public func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.preFetchHomeContent()
    }

    public func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getHomeTemplate()
    }

    public func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getAlertBanner()
    }

    public func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getBanners()
    }

    public func getCarouselEventPointers() -> AnyPublisher<CarouselEventPointers, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getCarouselEventPointers()
    }

    public func getCarouselEvents() -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getCarouselEvents()
    }

    public func getCasinoCarouselPointers() -> AnyPublisher<CasinoCarouselPointers, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getCasinoCarouselPointers()
    }

    public func getCasinoCarouselGames() -> AnyPublisher<CasinoGameBanners, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getCasinoCarouselGames()
    }

    public func getBoostedOddsBanners() -> AnyPublisher<[BoostedOddsPointer], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getBoostedOddsPointers()
    }

    public func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getBoostedOddsEvents()
    }

    public func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getHeroCardPointers()
    }

    public func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: .homeContentProviderNotFound).eraseToAnyPublisher()
        }
        return homeContentProvider.getHeroCardEvents()
    }

    public func getTopImageEvents() -> AnyPublisher<Events, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getTopImageEvents()
    }

    public func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getStories()
    }

    public func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
    }

    public func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }
        return homeContentProvider.getProChoiceCardPointers()
    }

    public func getProChoiceMarketCards() -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: ServiceProviderError.homeContentProviderNotFound).eraseToAnyPublisher()
        }
        return homeContentProvider.getProChoiceMarketCards()
    }

    public func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: .homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getTopCompetitionsPointers()
    }

    public func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError> {
        guard
            let homeContentProvider = self.homeContentProvider
        else {
            return Fail(error: .homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return homeContentProvider.getTopCompetitions()
    }

}

// Social endpoints
extension Client {

    public func getFollowees() -> AnyPublisher<[Follower], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getFollowees()
    }

    public func getTotalFollowees() -> AnyPublisher<Int, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getTotalFollowees()
    }

    public func getFollowers() -> AnyPublisher<[Follower], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getFollowers()
    }

    public func getTotalFollowers() -> AnyPublisher<Int, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getTotalFollowers()
    }

    public func addFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.addFollowee(userId: userId)
    }

    public func removeFollowee(userId: String) -> AnyPublisher<[String], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.removeFollowee(userId: userId)
    }

    public func getTipsRankings(type: String? = nil, followers: Bool? = nil) -> AnyPublisher<[TipRanking], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getTipsRankings(type: type, followers: followers)
    }

    public func getUserProfileInfo(userId: String) -> AnyPublisher<UserProfileInfo, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getUserProfileInfo(userId: userId)
    }

    public func getFriendRequests() -> AnyPublisher<[FriendRequest], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getFriendRequests()
    }

    public func getFriends() -> AnyPublisher<[UserFriend], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getFriends()
    }

    public func addFriends(userIds: [String], request: Bool = false) -> AnyPublisher<AddFriendResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.addFriends(userIds: userIds, request: request)
    }

    public func removeFriend(userId: Int) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.removeFriend(userId: userId)
    }

    public func getChatrooms() -> AnyPublisher<[ChatroomData], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getChatrooms()
    }

    public func addGroup(name: String, userIds: [String]) -> AnyPublisher<ChatroomId, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.addGroup(name: name, userIds: userIds)
    }

    public func deleteGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.deleteGroup(id: id)
    }

    public func editGroup(id: Int, name: String) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.editGroup(id: id, name: name)
    }

    public func leaveGroup(id: Int) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.deleteGroup(id: id)
    }

    public func addUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.addUsersToGroup(groupId: groupId, userIds: userIds)
    }

    public func removeUsersToGroup(groupId: Int, userIds: [String]) -> AnyPublisher<String, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.removeUsersToGroup(groupId: groupId, userIds: userIds)
    }

    public func searchUserWithCode(code: String) -> AnyPublisher<SearchUser, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.searchUserWithCode(code: code)
    }
}

extension Client {

    public func getPromotions() -> AnyPublisher<[PromotionInfo], ServiceProviderError> {
        guard
            let promotionalCampaignsProvider = self.promotionalCampaignsProvider
        else {
            return Fail(error: .promotionalCampaignsProviderNotFound).eraseToAnyPublisher()
        }
        return promotionalCampaignsProvider.getPromotions()
    }

    public func getPromotionDetails(promotionSlug: String, staticPageSlug: String) -> AnyPublisher<PromotionInfo, ServiceProviderError> {
        guard
            let promotionalCampaignsProvider = self.promotionalCampaignsProvider
        else {
            return Fail(error: .promotionalCampaignsProviderNotFound).eraseToAnyPublisher()
        }
        return promotionalCampaignsProvider.getPromotionDetails(promotionSlug: promotionSlug, staticPageSlug: staticPageSlug)
    }

}

extension Client {

    public func contactUs(form: ContactUsForm) -> AnyPublisher<BasicResponse, ServiceProviderError> {
        guard
            let customerSupportProvider = self.customerSupportProvider
        else {
            return Fail(error: ServiceProviderError.customerSupportProviderNotFound).eraseToAnyPublisher()
        }

        return customerSupportProvider.contactUs(form: form)
    }

    public func contactSupport(form: ContactSupportForm) -> AnyPublisher<SupportResponse, ServiceProviderError> {
        guard
            let customerSupportProvider = self.customerSupportProvider
        else {
            return Fail(error: ServiceProviderError.customerSupportProviderNotFound).eraseToAnyPublisher()
        }

        return customerSupportProvider.contactSupport(form: form)
    }

}

extension Client {

    public func getDownloadableContentItems() -> AnyPublisher<DownloadableContentItems, ServiceProviderError> {
        guard
            let downloadableContentsProvider = self.downloadableContentsProvider
        else {
            return Fail(error: .homeContentProviderNotFound).eraseToAnyPublisher()
        }

        return downloadableContentsProvider.getDownloadableContentItems()
    }

}

// MARK: - Casino Provider Methods
//
extension Client {

    public func getCasinoCategories(language: String? = nil, platform: String? = nil, lobbyType: CasinoLobbyType? = nil) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.casinoProviderNotFound).eraseToAnyPublisher()
        }

        return casinoProvider.getCasinoCategories(language: language, platform: platform, lobbyType: lobbyType)
    }
    
    public func getGamesByCategory(categoryId: String, language: String? = nil, platform: String? = nil, lobbyType: CasinoLobbyType? = nil, pagination: CasinoPaginationParams = CasinoPaginationParams()) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.casinoProviderNotFound).eraseToAnyPublisher()
        }

        return casinoProvider.getGamesByCategory(categoryId: categoryId, language: language, platform: platform, lobbyType: lobbyType, pagination: pagination)
    }
    
    public func getGameDetails(gameId: String, language: String? = nil, platform: String? = nil) -> AnyPublisher<CasinoGame?, ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.casinoProviderNotFound).eraseToAnyPublisher()
        }
        
        return casinoProvider.getGameDetails(gameId: gameId, language: language, platform: platform)
    }
    
    public func getRecentlyPlayedGames(playerId: String, language: String? = nil, platform: String? = nil, pagination: CasinoPaginationParams = CasinoPaginationParams()) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        guard let casinoProvider = self.privilegedAccessManager else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        
        return casinoProvider.getRecentlyPlayedGames(playerId: playerId, language: language, platform: platform, pagination: pagination)
    }
    
    public func getMostPlayedGames(playerId: String, language: String? = nil, platform: String? = nil, pagination: CasinoPaginationParams = CasinoPaginationParams()) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        guard let casinoProvider = self.privilegedAccessManager else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        
        return casinoProvider.getMostPlayedGames(playerId: playerId, language: language, platform: platform, pagination: pagination)
    }
    
    public func searchGames(language: String? = nil, platform: String? = nil, name: String) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.casinoProviderNotFound).eraseToAnyPublisher()
        }
        
        return casinoProvider.searchGames(language: language, platform: platform, name: name)
    }
    
    public func getRecommendedGames(language: String? = nil, platform: String? = nil) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        guard let casinoProvider = self.casinoProvider else {
            return Fail(error: ServiceProviderError.casinoProviderNotFound).eraseToAnyPublisher()
        }
        
        return casinoProvider.getRecommendedGames(language: language, platform: platform)
    }
    
    public func buildCasinoGameLaunchUrl(for game: CasinoGame, mode: CasinoGameMode, sessionId: String? = nil, language: String? = nil) -> String? {
        guard let casinoProvider = self.casinoProvider else {
            return nil
        }
        
        return casinoProvider.buildGameLaunchUrl(for: game, mode: mode, sessionId: sessionId, language: language)
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
