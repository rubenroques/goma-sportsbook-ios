import Combine
import Foundation

public class ServiceProviderClient {
    
    public private(set) var text = "Hello, World!"
    
    public enum ProviderType {
        case everymatrix
        case sportradar
    }
    
    var privilegedAccessManagerConnectionStatePublisher: AnyPublisher<ConnectorState, Error>?
    var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Error>?
    var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Error>?
    
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
            //            let everymatrixProvider = EverymatrixProvider()
            //            self.privilegedAccessManager = everymatrixProvider
            //            self.bettingProvider = everymatrixProvider
            //            self.eventsProvider = everymatrixProvider
        case .sportradar:
            let sportRadarConnector = SportRadarConnector()
            
            self.eventsConnectionStatePublisher = sportRadarConnector.connectionStatePublisher
            
            sportRadarConnector.connect()
            
            let sportRadarProvider = SportRadarProvider(connector: sportRadarConnector)
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

    
    public func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribeLiveMatches(forSportType: sportType) ?? nil
    }
    
}
