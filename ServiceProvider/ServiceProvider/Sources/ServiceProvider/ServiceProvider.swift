import Combine
import Foundation

public class ServiceProvider {
    
    public private(set) var text = "Hello, World!"

    public enum ProviderType {
        case everymatrix
        case sportsradar
    }
    
    private var providerType: ProviderType = .everymatrix
    
    private var privilegedAccessManager: PrivilegedAccessManager
    private var bettingProvider: BettingProvider
    private var eventsProvider: EventsProvider
    
    public init(providerType: ProviderType) {
        self.providerType = providerType
        switch providerType {
        case .everymatrix:
            let everymatrixProvider = EverymatrixProvider()
            self.privilegedAccessManager = everymatrixProvider
            self.bettingProvider = everymatrixProvider
            self.eventsProvider = everymatrixProvider
        case .sportsradar:
            let sportsradarProvider = SportsradarProvider()
            self.privilegedAccessManager = sportsradarProvider
            self.bettingProvider = sportsradarProvider
            self.eventsProvider = sportsradarProvider
        }
        
        
        // Debug only, delete later
        // self.connect()
        //
        
    }
    
    public func connect() {
        self.eventsProvider.connect()
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
    
}
