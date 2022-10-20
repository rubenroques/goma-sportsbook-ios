import Combine
import Foundation

public class ServiceProviderClient {
    
    public private(set) var text = "Hello, World!"
    
    public enum ProviderType {
        case everymatrix
        case sportradar
    }
    
    public var privilegedAccessManagerConnectionStatePublisher: AnyPublisher<ConnectorState, Error> = Just(ConnectorState.disconnected).setFailureType(to: Error.self).eraseToAnyPublisher()
    public var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Error> = Just(ConnectorState.disconnected).setFailureType(to: Error.self).eraseToAnyPublisher()
    public var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Error> = Just(ConnectorState.disconnected).setFailureType(to: Error.self).eraseToAnyPublisher()
    
    private var providerType: ProviderType = .everymatrix
    
    private var privilegedAccessManager: (any PrivilegedAccessManager)?
    private var bettingProvider: (any BettingProvider)?
    private var eventsProvider: (any EventsProvider)?
        
    public init(providerType: ProviderType) {
        self.providerType = providerType
        
        //        switch providerType {
        //        case .everymatrix:
        //            fatalError()
        //            let everymatrixProvider = EverymatrixProvider()
        //            self.privilegedAccessManager = everymatrixProvider
        //            self.bettingProvider = everymatrixProvider
        //            self.eventsProvider = everymatrixProvider
        //        case .sportradar:
        //            let sportsradarProvider = SportsradarProvider()
        //            self.privilegedAccessManager = sportsradarProvider
        //            self.bettingProvider = sportsradarProvider
        //            self.eventsProvider = sportsradarProvider
        //        }
        
        // Debug only, delete later
        // self.connect()
        //
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
            let sportRadarConnector = SportRadarConnector()
            
            self.eventsConnectionStatePublisher = sportRadarConnector.connectionStatePublisher
            
            sportRadarConnector.connect()
            
            let sportRadarProvider = SportRadarEventsProvider(connector: sportRadarConnector)
            self.privilegedAccessManager = nil // sportsradarProvider
            self.bettingProvider = nil // sportsradarProvider
            self.eventsProvider = sportRadarProvider
        }
    }
    
    public func forceReconnect() {
        
    }
    
    public func disconnect() {
        
    }
    
    public func loginUser(withUsername username: String, andPassword password: String) -> AnyPublisher<Bool, Never> {
        return Future.init { promisse in
            promisse(.success(true))
        }.eraseToAnyPublisher()
    }

    //
    // Sports
    //
    public func allSportTypes(dateRangeId: String) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        // TODO:
        //return Fail(error: ServiceProviderError.request).eraseToAnyPublisher()
        return self.eventsProvider?.allSportTypes(dateRangeId: dateRangeId) ?? nil
    }
    
    public func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>? {
        return self.eventsProvider?.liveSportTypes() ?? nil
    }
    
    public func popularSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        // TODO:
        return Fail(error: ServiceProviderError.request).eraseToAnyPublisher()
    }
    
    //
    // Events
    //
    public func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribeLiveMatches(forSportType: sportType) ?? nil
    }

    public func subscribePopularMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribePopularMatches(forSportType: sportType, dateRangeId: dateRangeId, sortType: sortType) ?? nil
    }

    public func unsubscribePopularMatches() {
        self.eventsProvider?.unsubscribePopularMatches()
    }

    public func subscribePopularOutrightCompetitionsMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }

    public func subscribeUpcomingMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribeUpcomingMatches(forSportType: sportType, dateRangeId: dateRangeId, sortType: sortType) ?? nil

    }

    public func unsubscribeUpcomingMatches() {
        self.eventsProvider?.unsubscribeUpcomingMatches()
    }

    public func subscribeCompetitions(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }

    public func subscribeCompetitionMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }
}
