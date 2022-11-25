import Combine
import Foundation

public class ServiceProviderClient {

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

            // Session Coordinator
            let sessionCoordinator = SportRadarSessionCoordinator()

            self.privilegedAccessManager = SportRadarPrivilegedAccessManager(sessionCoordinator: sessionCoordinator, connector: OmegaConnector())
            self.eventsProvider = SportRadarEventsProvider(sessionCoordinator: sessionCoordinator, connector: SportRadarSocketConnector())
            self.bettingProvider = SportRadarBettingProvider(sessionCoordinator: sessionCoordinator)
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
    public func subscribeAvailableSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeAvailableSportTypes(initialDate: initialDate, endDate: endDate)
    }

    public func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeLiveSportTypes()
    }

    //
    // Events
    //
    public func subscribeLiveMatches(forSportType sportType: SportType, pageIndex: Int) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeLiveMatches(forSportType: sportType, pageIndex: pageIndex)
    }

    public func subscribePreLiveMatches(forSportType sportType: SportType,
                                        pageIndex: Int,
                                        initialDate: Date? = nil,
                                        endDate: Date? = nil,
                                        eventCount: Int,
                                        sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribePreLiveMatches(forSportType: sportType,
                                                      pageIndex: pageIndex,
                                                      initialDate: initialDate,
                                                      endDate: endDate,
                                                      eventCount: eventCount,
                                                      sortType: sortType)
    }

    public func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeMatchDetails(matchId: matchId)
    }

}

extension ServiceProviderClient {

    //
    // REST API Events
    //
    public func getMarketFilters() -> AnyPublisher<MarketFilter, ServiceProviderError>? {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getMarketsFilter()
    }

    public func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>? {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getFieldWidgetId(eventId: eventId)
    }

    public func getFieldWidgetURLRequest(urlString: String? = nil, widgetFile: String? = nil) -> URLRequest? {
        return self.eventsProvider?.getFieldWidgetURLRequest(urlString: urlString, widgetFile: widgetFile)
    }

    public func getFieldWidgetHtml(widgetFile: String, eventId: String, providerId: String? = nil) -> String? {
        return self.eventsProvider?.getFieldWidgetHtml(widgetFile: widgetFile, eventId: eventId, providerId: providerId)
    }

//    public func getSportsList() -> AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError> {
//        guard
//            let eventsProvider = self.eventsProvider
//        else {
//            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
//        }
//        return eventsProvider.getSportsList()
//    }

    public func getAvailableSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[SportType], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getAvailableSportTypes(initialDate: initialDate, endDate: endDate)
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
        return privilegedAccessManager.getUserProfile()
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

    public func checkEmailRegistered(_ email: String) -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.checkEmailRegistered(email)
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

    public func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getUserBalance()
    }

    public func signUpCompletion(form: ServiceProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signUpCompletion(form: form)
    }
}

extension ServiceProviderClient {

    public func getCountries() -> AnyPublisher<[Country], ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getCountries()
    }

    public func getCurrentCountry() -> AnyPublisher<Country?, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.getCurrentCountry()
    }

}

extension ServiceProviderClient {

    //
    // Betting
    //
    public func getBettingHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(outputType: BettingHistory.self,
                        failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getBetHistory(pageIndex: pageIndex)
    }

    public func calculateBetslipState(_ betslip: BetSlip)  -> AnyPublisher<BetslipState, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(outputType: BetslipState.self,
                        failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.calculateBetslipState(betslip)

    }

}

