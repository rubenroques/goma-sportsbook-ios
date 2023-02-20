import Combine
import Foundation
import GomaGamingSDK
import SharedModels

public class ServicesProviderClient {

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

            self.privilegedAccessManager = SportRadarPrivilegedAccessManager(sessionCoordinator: sessionCoordinator,
                                                                             connector: OmegaConnector())
            self.eventsProvider = SportRadarEventsProvider(sessionCoordinator: sessionCoordinator,
                                                           socketConnector: SportRadarSocketConnector(),
                                                           restConnector: SportRadarRestConnector())
            self.bettingProvider = SportRadarBettingProvider(sessionCoordinator: sessionCoordinator)

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

extension ServicesProviderClient {

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

    public func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeMatchDetails(matchId: matchId)
    }

    public func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.subscribeCompetitionMatches(forMarketGroupId: marketGroupId)
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

}

extension ServicesProviderClient {
    public func getMarketFilters(event: Event) -> AnyPublisher<[MarketGroup], ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }
        return eventsProvider.getMarketsFilter(event: event)
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

    public func getSearchEvents(query: String, resultLimit: String, page: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getSearchEvents(query: query, resultLimit: resultLimit, page: page)
    }

    public func getBanners() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getBanners()
    }

    public func getEventSummary(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return Fail(error: .eventsProviderNotFound).eraseToAnyPublisher()
        }

        return eventsProvider.getEventSummary(eventId: eventId)
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
}


extension ServicesProviderClient {

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

    public func signUpCompletion(form: ServicesProvider.UpdateUserProfileForm)  -> AnyPublisher<Bool, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        return privilegedAccessManager.signUpCompletion(form: form)
    }
}

extension ServicesProviderClient {

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

extension ServicesProviderClient {

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

    public func placeBets(betTickets: [BetTicket]) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.placeBets(betTickets: betTickets)
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

    public func getOpenBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getOpenBetsHistory(pageIndex: pageIndex)
    }

    public func getResolvedBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getResolvedBetsHistory(pageIndex: pageIndex)
    }

    public func getWonBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getWonBetsHistory(pageIndex: pageIndex)
    }


    public func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
        guard
            let bettingProvider = self.bettingProvider
        else {
            return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
        }

        return bettingProvider.getBetDetails(identifier: identifier)
    }

}

// Documents
extension ServicesProviderClient {

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

    public func updatePayment(paymentMethod: String, amount: Double, paymentId: String, type: String, issuer: String) -> AnyPublisher<UpdatePaymentResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.updatePayment(paymentMethod: paymentMethod, amount: amount, paymentId: paymentId, type: type, issuer: issuer)
    }

    public func getTransactionsHistory() -> AnyPublisher<TransactionsHistoryResponse, ServiceProviderError> {
        guard
            let privilegedAccessManager = self.privilegedAccessManager
        else {
            return Fail(error: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }

        return privilegedAccessManager.getTransactionsHistory()
    }
}

// Utilities
extension ServicesProviderClient {

    public func getDatesFilter(timeRange: String) -> [Date] {
        guard
            let eventsProvider = self.eventsProvider
        else {
            return []
        }

        return eventsProvider.getDatesFilter(timeRange: timeRange)
    }
}
