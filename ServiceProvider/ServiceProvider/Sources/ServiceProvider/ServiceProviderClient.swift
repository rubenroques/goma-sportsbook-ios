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
            let sportRadarConnector = SportRadarSocketConnector()
            self.eventsConnectionStatePublisher = sportRadarConnector.connectionStatePublisher
            sportRadarConnector.connect()
            
            self.privilegedAccessManager = SportRadarPrivilegedAccessManager(connector: OmegaConnector())
            self.eventsProvider = SportRadarEventsProvider(connector: sportRadarConnector)
            self.bettingProvider = nil // sportsradarProvider
        }
    }
    
    public func forceReconnect() {
        
    }
    
    public func disconnect() {
        
    }
    
}

extension ServiceProviderClient {
    //
    // Sports
    //
    public func allSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        return self.eventsProvider?.allSportTypes(initialDate: initialDate, endDate: endDate) ?? nil
    }

    public func unsubscribeAllSportTypes() {
        self.eventsProvider?.unsubscribeAllSportTypes()
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

    public func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date? = nil, endDate: Date? = nil, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribePreLiveMatches(forSportType: sportType, initialDate: initialDate, endDate: endDate, sortType: sortType) ?? nil
    }

    public func unsubscribePreLiveMatches() {
        self.eventsProvider?.unsubscribePreLiveMatches()
    }

    public func subscribePopularOutrightCompetitionsMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }

//    public func subscribeUpcomingMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
//        return self.eventsProvider?.subscribeUpcomingMatches(forSportType: sportType, dateRangeId: dateRangeId, sortType: sortType) ?? nil
//
//    }
//
//    public func unsubscribeUpcomingMatches() {
//        self.eventsProvider?.unsubscribeUpcomingMatches()
//    }

    public func subscribeCompetitions(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }

    public func subscribeCompetitionMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return nil
    }

    public func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        return self.eventsProvider?.subscribeMatchDetails(matchId: matchId)
    }

}

/* REST API Events
 */
extension ServiceProviderClient {
    public func getMarketFilters() -> AnyPublisher<MarketFilter, ServiceProviderError>? {
        return self.eventsProvider?.getMarketsFilter()
    }
}


extension ServiceProviderClient {
    
    //
    // PrivilegedAccessManager
    //
    public func loginUser(withUsername username: String, andPassword password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
        
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }        
        return privilegedAccessManager.login(username: username, password: password)
    }
    
    public func getProfile() -> AnyPublisher<UserProfile, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: UserProfile.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getUserProfile()
    }
    
    public func updateUserProfile(form: UpdateUserProfileForm) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updateUserProfile(form: form)
    }
    
    public func simpleSignUp(form: SimpleSignUpForm) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.simpleSignUp(form: form)
    }
        
    public func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.checkEmailRegistered(email)
    }
  
    public func signupConfirmation(_ email: String, confirmationCode: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signupConfirmation(email, confirmationCode: confirmationCode)
    }

    public func forgotPassword(email: String, secretQuestion: String? = nil, secrestAnswer: String? = nil) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.forgotPassword(email: email, secretQuestion: secretQuestion, secretAnswer: secrestAnswer)
    }

    public func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
}

extension ServiceProviderClient {
    
    public func getCountries() -> AnyPublisher<[Country], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: [Country].self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        
        return privilegedAccessManager.getCountries()
    }
    
    public func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(outputType: Country?.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getCurrentCountry()
    }
    
}
