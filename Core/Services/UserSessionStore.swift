//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine

enum UserSessionError: Error {
    case invalidEmailPassword
    case serverError
}

class UserSessionStore {

    var cancellables = Set<AnyCancellable>()

    var isLoadingUserSessionPublisher = CurrentValueSubject<Bool, Never>(true)
    var userSessionPublisher = CurrentValueSubject<UserSession?, Never>(nil)
    var userBalanceWallet = CurrentValueSubject<EveryMatrix.UserBalanceWallet?, Never>(nil)
    var userBonusBalanceWallet = CurrentValueSubject<EveryMatrix.UserBalanceWallet?, Never>(nil)
    var userWalletPublisher: AnyCancellable?
    var userWalletRegister: EndpointPublisherIdentifiable?

    var shouldRecordUserSession = true
    var isUserProfileIncomplete = CurrentValueSubject<Bool, Never>(true)
    var isUserEmailVerified = CurrentValueSubject<Bool, Never>(false)

    init() {

        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] _ in
                Logger.log("EMSessionLoginFLow - Socket Connected received will login if needed")
                self?.startUserSessionIfNeeded()
            })
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userSessionForcedLogoutDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("EMSessionLoginFLow - SessionForcedLogoutDisconnected received will logout local user")
                self?.logout()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userSessionConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.subscribeAccountBalanceWatcher()
                self?.requestUserSettings()
            }
            .store(in: &cancellables)
        
    }

    static func loggedUserSession() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func storedUserPassword() -> String? {
        guard
            let storedUserSession = UserSessionStore.loggedUserSession(),
            let passwordData = try? KeychainInterface.readPassword(service: Env.bundleId, account: storedUserSession.userId),
            let password = String(data: passwordData, encoding: .utf8)
        else {
            return nil
        }
        return password
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

    func saveUserSession(_ userSession: UserSession) {
        userSessionPublisher.send(userSession)

        UserDefaults.standard.userSession = userSession

        if let password = userSession.password, let passwordData = password.data(using: .utf8) {
            do {
                try KeychainInterface.save(password: passwordData, service: Env.bundleId, account: userSession.userId)
            }
            catch {
                shouldRecordUserSession = false
            }
        }

    }

    func loadLoggedUser() {
        if let user = UserSessionStore.loggedUserSession() {
            userSessionPublisher.send(user)
        }
    }

    //
    static func isUserAnonymous() -> Bool {
        return !isUserLogged()
    }

    static func didSkipLoginFlow() -> Bool {
        UserDefaults.standard.userSkippedLoginFlow
    }

    static func skippedLoginFlow() {
        UserDefaults.standard.userSkippedLoginFlow = true
    }

    //
    func logout() {

        if let userSession = UserSessionStore.loggedUserSession() {
            try? KeychainInterface.deletePassword(service: Env.bundleId, account: userSession.userId)
        }

        UserDefaults.standard.userSession = nil
        userSessionPublisher.send(nil)
        userBalanceWallet.send(nil)
        self.unsubscribeWalletUpdates()

        Env.favoritesManager.clearCachedFavorites()

        UserDefaults.standard.removeObject(forKey: "user_betslip_settings")
        
        Env.gomaNetworkClient.reconnectSession()

        Env.everyMatrixClient
            .logout()
            .sink(receiveCompletion: { completion in
                Logger.log("User logout \(completion)")
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)

    }

    func loginUser(withUsername username: String, password: String) -> AnyPublisher<UserSession, UserSessionError> {

        let publisher = Env.everyMatrixClient
            .loginComplete(username: username, password: password)
            .mapError { (error: EveryMatrix.APIError) -> UserSessionError in
                switch error {
                case let .requestError(message) where message.contains("check your username and password"):
                    return .invalidEmailPassword
                default:
                    return .serverError
                }
            }
            .map { sessionInfo in
                UserSession(username: sessionInfo.username,
                            password: password,
                            email: sessionInfo.email,
                            userId: "\(sessionInfo.userID)",
                            birthDate: sessionInfo.birthDate,
                            isEmailVerified: sessionInfo.isEmailVerified)
            }
            .handleEvents(receiveOutput: saveUserSession)
            .eraseToAnyPublisher()

        return publisher
    }

    func registerUser(form: EveryMatrix.SimpleRegisterForm) -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Env.everyMatrixClient
            .simpleRegister(form: form)
            .map { _ in return true }
            .handleEvents(receiveOutput: { registered in
                if registered {
                    self.triggerLoginOnRegister(form: form)
                }
            })
            .eraseToAnyPublisher()
    }

    func registrationOnGomaAPI(form: EveryMatrix.SimpleRegisterForm, userId: String) {

        let deviceId = Env.deviceId
        
        let userRegisterForm = UserRegisterForm(username: form.username,
                                                email: form.email,
                                                mobilePrefix: form.mobilePrefix,
                                                mobile: form.mobileNumber,
                                                birthDate: form.birthDate,
                                                userProviderId: userId,
                                                deviceToken: Env.deviceFCMToken)
        Env.gomaNetworkClient
            .requestUserRegister(deviceId: deviceId, userRegisterForm: userRegisterForm)
            .replaceError(with: MessageNetworkResponse.failed)
            .sink { _ in

            }
            .store(in: &cancellables)
    }

    private func triggerLoginOnRegister(form: EveryMatrix.SimpleRegisterForm) {
        self.loginUser(withUsername: form.username, password: form.password)
            .map { String($0.userId) }
            .sink(receiveCompletion: { _ in

            }, receiveValue: { userId in
                self.registrationOnGomaAPI(form: form, userId: userId)
            })
            .store(in: &cancellables)
    }

}

extension UserSessionStore {

    func forceWalletUpdate() {
        let route = TSRouter.getUserBalance
        Env.everyMatrixClient.manager.getModel(router: route, decodingType: EveryMatrix.UserBalance.self)
            .sink { _ in
                
            } receiveValue: { userBalance in
                var realWallet: EveryMatrix.UserBalanceWallet?
                var bonusWallet: EveryMatrix.UserBalanceWallet?
                
                for wallet in userBalance.wallets {
                    if wallet.vendor == "CasinoWallet" {
                        realWallet = wallet
                        self.userBalanceWallet.send(realWallet)
                    }
                    else if wallet.vendor == "UBS" {
                        bonusWallet = wallet
                        self.userBonusBalanceWallet.send(bonusWallet)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func setUserSettings(userSettings: String = "", defaultSettingsFallback: Bool = false) {
        if defaultSettingsFallback {
            if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "user_betslip_settings") {
                let defaultUserSetting = Env.userBetslipSettingsSelectorList[1].key
                UserDefaults.standard.set(defaultUserSetting, forKey: "user_betslip_settings")
            }
        }
        else {
            let defaultUserSetting = userSettings
            UserDefaults.standard.set(defaultUserSetting, forKey: "user_betslip_settings")
        }
    }

    func requestUserSettings() {
        Env.gomaNetworkClient.requestUserSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("GOMA ERROR: \(error)")
                    self?.setUserSettings(defaultSettingsFallback: true)
                case .finished:
                    ()
                }
            },
                  receiveValue: { [weak self] userSettings in
                print("User Settings: \(userSettings)")
                self?.setUserSettings(userSettings: userSettings.settings.oddValidationType)
                self?.registerUserSettings(userSettings: userSettings.settings)
            })
            .store(in: &cancellables)

    }

    private func registerUserSettings(userSettings: UserSettingsGoma) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(userSettings)

            UserDefaults.standard.set(data, forKey: "gomaUserSettings")

        } catch {
            print("Unable to Encode User Settings Goma (\(error))")
        }
    }

    func subscribeAccountBalanceWatcher() {
        let route = TSRouter.getUserBalance
        Env.everyMatrixClient.manager.getModel(router: route, decodingType: EveryMatrix.UserBalance.self)
            .sink { _ in

            } receiveValue: { userBalance in
                var realWallet: EveryMatrix.UserBalanceWallet?
                for wallet in userBalance.wallets where wallet.vendor == "CasinoWallet" {
                    realWallet = wallet
                    break
                }
                self.userBalanceWallet.send(realWallet)
                self.setupAccountBalanceWatcher()
            }
            .store(in: &cancellables)
    }

    func setupAccountBalanceWatcher() {
        Env.everyMatrixClient.getAccountBalanceWatcher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] value in
                print("\(value)")
                self?.subscribeWalletUpdates()
            })
            .store(in: &cancellables)
    }

    func subscribeWalletUpdates() {
        let endpoint = TSRouter.accountBalancePublisher

        self.userWalletPublisher?.cancel()
        self.userWalletPublisher = nil

        self.userWalletPublisher = Env.everyMatrixClient.manager
            .subscribeEndpoint(endpoint, decodingType: EveryMatrix.AccountBalance.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("userWalletPublisher Error retrieving data!")
                case .finished:
                    print("userWalletPublisher Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("userWalletPublisher connect")
                    self?.userWalletRegister = publisherIdentifiable
                case .initialContent(_):
                    print("userWalletPublisher initialContent")
                case .updatedContent(let walletUpdates):
                    print("userWalletPublisher updatedContent")

                    let updatedUserBalanceWallet = Env.userSessionStore.userBalanceWallet.value?.userBalanceWalletUpdated(amount: walletUpdates.amount)
                    Env.userSessionStore.userBalanceWallet.send(updatedUserBalanceWallet)
                case .disconnect:
                    print("userWalletPublisher disconnect")
                }
            })
    }

    func unsubscribeWalletUpdates() {
        if let walletRegister = self.userWalletRegister {
            Env.everyMatrixClient.manager.unsubscribeFromEndpoint(endpointPublisherIdentifiable: walletRegister)
        }
    }

    func requestProfileStatus() {
        Env.everyMatrixClient.getProfileStatus()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in

            } receiveValue: { status in
                self.isUserProfileIncomplete.send(status.isProfileIncomplete)
            }
        .store(in: &cancellables)
    }

}

extension UserSessionStore {
    func startUserSessionIfNeeded() {

        self.isLoadingUserSessionPublisher.send(true)

        guard
            let user = UserSessionStore.loggedUserSession(),
            let userPassword = UserSessionStore.storedUserPassword()
        else {
            Logger.log("EMSessionLoginFLow - User Session not found - login not needed")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        Logger.log("EMSessionLoginFLow - User Session found - login needed")

        self.loadLoggedUser()

        Env.everyMatrixClient.manager
            .getModel(router: .login(username: user.username, password: userPassword), decodingType: LoginAccount.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    Env.favoritesManager.getUserFavorites()
                    self?.loginGomaAPI(username: user.username, password: user.userId)
                case .failure(let error):
                    print("error \(error)")
                }
                self?.isLoadingUserSessionPublisher.send(false)
            } receiveValue: { account in
                Env.userSessionStore.isUserProfileIncomplete.send(account.isProfileIncomplete)
                Env.userSessionStore.isUserEmailVerified.send(account.isEmailVerified)
            }
            .store(in: &cancellables)
    }

    func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFCMToken)

        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { value in
                Env.gomaNetworkClient.refreshAuthToken(token: value)
            })
            .store(in: &cancellables)

    }


}
