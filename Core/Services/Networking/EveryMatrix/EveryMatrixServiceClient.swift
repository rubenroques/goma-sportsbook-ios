import Foundation
import Combine
import Reachability

enum EveryMatrixServiceSocketStatus {
    case connected
    case disconnected

    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        case .disconnected:
            return false
        }
    }
}

enum EveryMatrixServiceUserSessionStatus {
    case anonymous
    case logged
}

class EveryMatrixServiceClient: ObservableObject {

    var serviceStatusPublisher: CurrentValueSubject<EveryMatrixServiceSocketStatus, Never> = .init(.disconnected)
    var userSessionStatusPublisher: CurrentValueSubject<EveryMatrixServiceUserSessionStatus, Never> = .init(.anonymous)

    //
    var manager: TSManager = TSManager()

    private var cancellable = Set<AnyCancellable>()

    private let reachability = try! Reachability() // swiftlint:disable:this force_try
    private var isInitialConnectionCheck = true

    init() {
        // The singleton init below is used to start up TS connection

        reachability.whenReachable = { [weak self] _ in
            if self?.isInitialConnectionCheck ?? true {
                self?.isInitialConnectionCheck = false
                return
            }
            self?.reconnectSocket()
        }

        do {
            try reachability.startNotifier()
        }
        catch {
            Logger.log("Reachability startNotifier error")
        }

        // =====
        // User session state
        NotificationCenter.default.publisher(for: .userSessionConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - User Session Connected")
                self?.userSessionStatusPublisher.send(.logged)
            }
            .store(in: &cancellable)

        NotificationCenter.default.publisher(for: .userSessionForcedLogoutDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - User Session Forced Logout Disconnected")
                self?.userSessionStatusPublisher.send(.anonymous)
            }
            .store(in: &cancellable)

        NotificationCenter.default.publisher(for: .userSessionDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - User Session Disconnected")
                self?.userSessionStatusPublisher.send(.anonymous)
            }
            .store(in: &cancellable)

        // =====
        // Socket state
        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - Socket Session Connected")
                self?.serviceStatusPublisher.send(.connected)
            }
            .store(in: &cancellable)

        NotificationCenter.default.publisher(for: .socketDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - Socket Session Disconnected")
                self?.serviceStatusPublisher.send(.disconnected)
                self?.reconnectSocket()
            }
            .store(in: &cancellable)

    }

    func reconnectSocket() {

        self.manager.destroySwampSession()

        manager = TSManager()
        Logger.log("EMSessionLoginFLow - Created new socket session")
    }

    static func operatorInfo() -> AnyPublisher<EveryMatrix.OperatorInfo, EveryMatrix.APIError> {
        return Env.everyMatrixClient.manager.getModel(router: .getOperatorInfo, decodingType: EveryMatrix.OperatorInfo.self)
            .handleEvents(receiveOutput: { (operatorInfo: EveryMatrix.OperatorInfo) in
                print("OperatorInfo \(operatorInfo)")
            })
            .eraseToAnyPublisher()
    }

    func login(username: String, password: String) -> AnyPublisher<LoginAccount, EveryMatrix.APIError> {
        return self.manager
            .getModel(router: .login(username: username, password: password), decodingType: LoginAccount.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func loginComplete(username: String, password: String) -> AnyPublisher<SessionInfo, EveryMatrix.APIError> {
        return self.login(username: username, password: password).flatMap { _ in
            return self.getSessionInfo()
        }
        .eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return self.manager
            .getModel(router: .logout, decodingType: Bool.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getSessionInfo() -> AnyPublisher<SessionInfo, EveryMatrix.APIError> {
        return self.manager
            .getModel(router: .getSessionInfo, decodingType: SessionInfo.self)
            .eraseToAnyPublisher()
    }

    func getOperatorInfo() -> AnyPublisher<EveryMatrix.OperatorInfo, EveryMatrix.APIError> {
        return self.manager
            .getModel(router: .getOperatorInfo, decodingType: EveryMatrix.OperatorInfo.self)
            .eraseToAnyPublisher()
    }

    func validateEmail(_ email: String) -> AnyPublisher<EveryMatrix.EmailAvailability, EveryMatrix.APIError> {
        return self.manager.getModel(router: .validateEmail(email: email), decodingType: EveryMatrix.EmailAvailability.self)
            .eraseToAnyPublisher()
    }

    func validateUsername(_ username: String) -> AnyPublisher<EveryMatrix.UsernameAvailability, EveryMatrix.APIError> {
        return self.manager.getModel(router: .validateUsername(username: username), decodingType: EveryMatrix.UsernameAvailability.self)
            .eraseToAnyPublisher()
    }

    func simpleRegister(form: EveryMatrix.SimpleRegisterForm) -> AnyPublisher<EveryMatrix.RegistrationResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .simpleRegister(form: form), decodingType: EveryMatrix.RegistrationResponse.self)
            .breakpointOnError()
            .eraseToAnyPublisher()
    }

    func updateProfile(form: EveryMatrix.ProfileForm) -> AnyPublisher<EveryMatrix.ProfileUpdateResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .profileUpdate(form: form), decodingType: EveryMatrix.ProfileUpdateResponse.self)
            .breakpointOnError()
            .eraseToAnyPublisher()
    }

    func getCountries() -> AnyPublisher<EveryMatrix.CountryListing, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getCountries, decodingType: EveryMatrix.CountryListing.self)
            .eraseToAnyPublisher()
    }

    func getProfile() -> AnyPublisher<EveryMatrix.UserProfileField, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getProfile, decodingType: EveryMatrix.UserProfileField.self)
            .eraseToAnyPublisher()
    }

    func getAccountBalanceWatcher() -> AnyPublisher<EveryMatrix.AccountBalanceWatcher, EveryMatrix.APIError> {
        return self.manager.getModel(router: .watchBalance, decodingType: EveryMatrix.AccountBalanceWatcher.self)
            .eraseToAnyPublisher()
    }

    func getPolicy() -> AnyPublisher<EveryMatrix.PasswordPolicy, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getPolicy, decodingType: EveryMatrix.PasswordPolicy.self)
            .eraseToAnyPublisher()
    }

    func getUserMetadata() -> AnyPublisher<EveryMatrix.UserMetadata, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getUserMetaData, decodingType: EveryMatrix.UserMetadata.self)
            .eraseToAnyPublisher()
    }

    func postUserMetadata(favoriteEvents: [String]) -> AnyPublisher<EveryMatrix.UserMetadata, EveryMatrix.APIError> {
        return self.manager.getModel(router: .postUserMetadata(favoriteEvents: favoriteEvents), decodingType: EveryMatrix.UserMetadata.self)
            .eraseToAnyPublisher()
    }

    func getProfileStatus() -> AnyPublisher<EveryMatrix.ProfileStatus, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getProfileStatus, decodingType: EveryMatrix.ProfileStatus.self)
            .eraseToAnyPublisher()
    }

    func changePassword(oldPassword: String,
                        newPassword: String,
                        captchaPublicKey: String?,
                        captchaChallenge: String?,
                        captchaResponse: String?) -> AnyPublisher<EveryMatrix.PasswordChange, EveryMatrix.APIError> {
        return self.manager.getModel(router: .changePassword(oldPassword: oldPassword,
                                                                              newPassword: newPassword,
                                                                              captchaPublicKey: captchaPublicKey ?? "",
                                                                              captchaChallenge: captchaChallenge ?? "",
                                                                              captchaResponse: captchaResponse ?? ""),
                                                      decodingType: EveryMatrix.PasswordChange.self)
            .eraseToAnyPublisher()
    }

    func getDisciplines(language: String) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Discipline>, EveryMatrix.APIError> {
        return self.manager.getModel(router: .disciplines(language: language) , decodingType: EveryMatrixSocketResponse<EveryMatrix.Discipline>.self)
            .eraseToAnyPublisher()
    }

    func getMatches(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Match>, EveryMatrix.APIError> {
        return self.manager.getModel(router: .matches(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
    }

    func getMatchDetails(language: String, matchId: String) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Match>, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getMatchDetails(language: language, matchId: matchId),
                                     decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
    }

    func getEvents(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<Event>, EveryMatrix.APIError> {
        return self.manager.getModel(router: .events(payload: payload), decodingType: EveryMatrixSocketResponse<Event>.self)
    }

    func getOdds(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<Odd>, EveryMatrix.APIError> {
        return self.manager.getModel(router: .odds(payload: payload), decodingType: EveryMatrixSocketResponse<Odd>.self)
    }

    func getDepositResponse(currency: String, amount: String, gamingAccountId: String)
    -> AnyPublisher<EveryMatrix.DepositResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getDepositCashier(currency: currency, amount: amount, gamingAccountId: gamingAccountId),
                                     decodingType: EveryMatrix.DepositResponse.self)
            .eraseToAnyPublisher()
    }

    func getWithdrawResponse(currency: String, amount: String, gamingAccountId: String)
    -> AnyPublisher<EveryMatrix.WithdrawResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getWithdrawCashier(currency: currency, amount: amount, gamingAccountId: gamingAccountId),
                                     decodingType: EveryMatrix.WithdrawResponse.self)
            .eraseToAnyPublisher()
    }

    func getLimits() -> AnyPublisher<EveryMatrix.LimitsResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getLimits, decodingType: EveryMatrix.LimitsResponse.self)
            .eraseToAnyPublisher()
    }

    func subscribeOdds(language: String, matchId: String) -> AnyPublisher<EveryMatrixSocketResponse<Odd>, EveryMatrix.APIError> {
        do {

            let operatorId = Env.appSession.operatorId
            let publisher = try self.manager.subscribeEndpoint(.oddsMatch(operatorId: operatorId,
                                                                              language: language,
                                                                              matchId: matchId),
                                                                   decodingType: EveryMatrixSocketResponse<Odd>.self)

                .map { (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<Odd>>) -> EveryMatrixSocketResponse<Odd>? in
                    print("subscriptionContent \(subscriptionContent)")
                    switch subscriptionContent {
                    case let .updatedContent(oddsData):
                        return oddsData
                    default:
                        return nil
                    }
                }
                .compactMap({ $0 })

            return publisher.eraseToAnyPublisher()
        }
        catch {
            return Fail.init(outputType: EveryMatrixSocketResponse<Odd>.self, failure: EveryMatrix.APIError.notConnected).eraseToAnyPublisher()
        }
    }

    func requestInitialDump(topic: String) -> AnyPublisher<String, EveryMatrix.APIError> {
        return self.manager.getModel(router: .sportsInitialDump(topic: topic), decodingType: String.self).eraseToAnyPublisher()
    }
    
    func getTransactionsHistory(type: String, startTime: String, endTime: String, pageIndex: Int, pageSize: Int) -> AnyPublisher<EveryMatrix.TransactionsHistoryResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .getTransactionHistory(type: type,
                                                                    startTime: startTime,
                                                                    endTime: endTime,
                                                                    pageIndex: pageIndex,
                                                                    pageSize: pageSize),
                                     decodingType: EveryMatrix.TransactionsHistoryResponse.self)
            .eraseToAnyPublisher()
    }

    func setLimit(limitType: String, period: String, amount: String, currency: String) -> AnyPublisher<EveryMatrix.LimitSetResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .setLimit(type: limitType, period: period, amount: amount, currency: currency), decodingType: EveryMatrix.LimitSetResponse.self)
            .eraseToAnyPublisher()
    }

    func removeLimit(limitType: String, period: String) -> AnyPublisher<EveryMatrix.LimitSetResponse, EveryMatrix.APIError> {
        return self.manager.getModel(router: .removeLimit(type: limitType, period: period), decodingType: EveryMatrix.LimitSetResponse.self)
            .eraseToAnyPublisher()
    }

}
