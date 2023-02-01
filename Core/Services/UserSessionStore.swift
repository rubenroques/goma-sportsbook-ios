//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine
import ServicesProvider

enum UserSessionError: Error {
    case invalidEmailPassword
    case restrictedCountry(errorMessage: String)
    case serverError
    case quickSignUpIncomplete
}

enum RegisterUserError: Error {
    case usernameInvalid
    case emailInvalid
    case passwordInvalid
    case usernameAlreadyUsed
    case emailAlreadyUsed
    case passwordWeak
    case serverError
}

enum UserSessionStatus {
    case anonymous
    case logged
}

class UserSessionStore {

    var cancellables = Set<AnyCancellable>()

    var isLoadingUserSessionPublisher = CurrentValueSubject<Bool, Never>(true)
    var userSessionPublisher = CurrentValueSubject<UserSession?, Never>(nil)
    var userSessionStatusPublisher: AnyPublisher<UserSessionStatus, Never> {
        return self.userSessionPublisher
            .map { session in
                if session != nil {
                    return UserSessionStatus.logged
                }
                else {
                    return UserSessionStatus.anonymous
                }
            }
            .eraseToAnyPublisher()
    }

    var userWalletPublisher = CurrentValueSubject<UserWallet?, Never>(nil)
    
    var hasGomaUserSessionPublisher = CurrentValueSubject<Bool, Never>(false)
    
    var shouldRecordUserSession = true

    var isUserProfileComplete = CurrentValueSubject<Bool?, Never>(nil)
    var isUserEmailVerified = CurrentValueSubject<Bool?, Never>(nil)
    var isUserKycVerified = CurrentValueSubject<Bool?, Never>(nil)

    private var pendingSignUpUserForm: ServicesProvider.SimpleSignUpForm?

    var userProfilePublisher = CurrentValueSubject<UserProfile?, Never>(nil)
    
    init() {

        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] _ in
                Logger.log("UserSessionStore - Socket Connected received will login if needed")
                self?.startUserSessionIfNeeded()
            })
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userSessionForcedLogoutDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log("UserSessionStore - SessionForcedLogoutDisconnected received will logout local user")
                self?.logout()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userSessionConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // self?.subscribeAccountBalanceWatcher()
                
                self?.requestNotificationsUserSettings()
                self?.requestBettingUserSettings()
            }
            .store(in: &cancellables)
        
    }

    static func loggedUserSession() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func storedUserPassword() -> String? {
        if
            let storedUserSession = UserSessionStore.loggedUserSession(),
            let passwordData = try? KeychainInterface.readPassword(service: Env.bundleId, account: storedUserSession.userId),
            let password = String(data: passwordData, encoding: .utf8)
        {
            return password
        }
        else if let userSession = Self.loggedUserSession() {
            return userSession.password
        }
        return nil
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

    func isUserLogged() -> Bool {
        return Self.isUserLogged()
    }

    func saveUserSession(_ userSession: UserSession) {

        if UserDefaults.standard.userSession != nil {
            return
        }

        if let password = userSession.password, let passwordData = password.data(using: .utf8) {
            do {
                try KeychainInterface.save(password: passwordData, service: Env.bundleId, account: userSession.userId)
            }
            catch {
                shouldRecordUserSession = false
            }
        }

        UserDefaults.standard.userSession = userSession

        userSessionPublisher.send(userSession)
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
        // self.unsubscribeWalletUpdates()

        Env.favoritesManager.clearCachedFavorites()
        Env.gomaSocialClient.clearUserChatroomsData()

        // TODO: Migrate to UserDefaults extensions
        UserDefaults.standard.removeObject(forKey: "betslipOddValidationType")
        UserDefaults.standard.removeObject(forKey: "shouldRequestBiometrics")
        UserDefaults.standard.removeObject(forKey: "RegistrationFormDataKey")

        Env.gomaNetworkClient.reconnectSession()

        Env.everyMatrixClient
            .logout()
            .sink(receiveCompletion: { completion in
                Logger.log("User logout \(completion)")
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)

        self.userSessionPublisher.send(nil)

        self.isUserProfileComplete.send(nil)
        self.isUserEmailVerified.send(nil)
        self.isUserKycVerified.send(nil)

        self.userWalletPublisher.send(nil)
        
        self.hasGomaUserSessionPublisher.send(false)
    }

    func login(withUsername username: String, password: String) -> AnyPublisher<UserSession, UserSessionError> {

        let publisher = Env.servicesProvider.loginUser(withUsername: username, andPassword: password)
            .mapError { (error: ServiceProviderError) -> UserSessionError in
                switch error {
                case .invalidEmailPassword:
                    return .invalidEmailPassword
                case .quickSignUpIncomplete:
                    return .quickSignUpIncomplete
                default:
                    return .serverError
                }
            }
            .map({ (serviceProviderProfile: ServicesProvider.UserProfile) in
                return ServiceProviderModelMapper.userProfile(serviceProviderProfile)
            })
            .map { (userProfile: UserProfile) -> UserSession in
                self.userProfilePublisher.send(userProfile)

                if userProfile.kycStatus == "PASS" {
                    self.isUserKycVerified.send(true)
                }
                else {
                    self.isUserKycVerified.send(false)
                }
                
                return UserSession(username: userProfile.username,
                                   password: password,
                                   email: userProfile.email,
                                   userId: userProfile.userIdentifier,
                                   birthDate: userProfile.birthDate.toString(),
                                   isEmailVerified: userProfile.isEmailVerified,
                                   isProfileCompleted: userProfile.isRegistrationCompleted,
                                   avatarName: userProfile.avatarName)
            }
            .handleEvents(receiveOutput: { [weak self] userSession in
                self?.saveUserSession(userSession)
                self?.loginGomaAPI(username: userSession.username, password: userSession.userId)
                
                self?.refreshUserWallet()
                
                Env.userSessionStore.isUserProfileComplete.send(userSession.isProfileCompleted)
                Env.userSessionStore.isUserEmailVerified.send(userSession.isEmailVerified)
            })
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    func registerUser(form: ServicesProvider.SimpleSignUpForm) -> AnyPublisher<Bool, RegisterUserError> {
        return Env.servicesProvider.simpleSignUp(form: form)
            .mapError { (error: ServiceProviderError) -> RegisterUserError in
                switch error {
                case ServiceProviderError.invalidSignUpUsername:
                    return RegisterUserError.usernameInvalid
                case ServiceProviderError.invalidSignUpEmail:
                    return RegisterUserError.emailInvalid
                case ServiceProviderError.invalidSignUpPassword:
                    return RegisterUserError.passwordInvalid
                case ServiceProviderError.invalidResponse:
                    return RegisterUserError.serverError
                default:
                    return RegisterUserError.serverError
                }
            }
            .handleEvents(receiveOutput: { [weak self] registered in
                self?.pendingSignUpUserForm = form
            }).eraseToAnyPublisher()
        
//        Env.everyMatrixClient
//            .simpleRegister(form: form)
//            .map { _ in return true }
//            .handleEvents(receiveOutput: { registered in
//                if registered {
//                    self.triggerLoginOnRegister(form: form)
//                }
//            })
//            .eraseToAnyPublisher()
    }

    func triggerPendingLoginAfterRegister() -> AnyPublisher<Bool, UserSessionError> {
        if let pendingSignUpUserForm = self.pendingSignUpUserForm {
            return self.login(withUsername: pendingSignUpUserForm.username, password: pendingSignUpUserForm.password)
                .handleEvents(receiveOutput: { userSession in
                    self.signUpSimpleGomaAPI(form: pendingSignUpUserForm, userId: userSession.userId)
                }, receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure:
                        self?.logout()
                    case .finished:
                        ()
                    }
                })
                .flatMap { (userSession: UserSession) -> AnyPublisher<Bool, UserSessionError> in
                    return Just(true).setFailureType(to: UserSessionError.self).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        else {
            return Just(false).setFailureType(to: UserSessionError.self).eraseToAnyPublisher()
        }
    }
//    private func triggerLoginAfterRegister(form: ServicesProvider.SimpleSignUpForm) {
//        self.login(withUsername: form.username, password: form.password)
//            .map { String($0.userId) }
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.logout()
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { userId in
//                self.signUpSimpleGomaAPI(form: form, userId: userId)
//            })
//            .store(in: &cancellables)
//    }

}

extension UserSessionStore {
    
    /*
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
    */
    
    // =====================================
    //
    func requestNotificationsUserSettings() {
        Env.gomaNetworkClient.requestNotificationsUserSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("GOMA SETTINGS ERROR: \(error)")
                    self?.storeNotificationsUserSettings(notificationsUserSettings: NotificationsUserSettings.defaultSettings)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] notificationsUserSettings in
                print("GOMA SETTINGS RESPONSE: \(notificationsUserSettings)")
                self?.storeNotificationsUserSettings(notificationsUserSettings: notificationsUserSettings)
            })
            .store(in: &cancellables)
    }

    private func storeNotificationsUserSettings(notificationsUserSettings: NotificationsUserSettings) {
        UserDefaults.standard.notificationsUserSettings = notificationsUserSettings
    }
    
    func requestBettingUserSettings() {
        Env.gomaNetworkClient.requestBettingUserSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.storeBettingUserSettings(bettingUserSettings: BettingUserSettings.defaultSettings)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] bettingUserSettings in
                self?.storeBettingUserSettings(bettingUserSettings: bettingUserSettings)
            })
            .store(in: &cancellables)
    }
    
    private func storeBettingUserSettings(bettingUserSettings: BettingUserSettings) {
        UserDefaults.standard.bettingUserSettings = bettingUserSettings
    }
/*
    // =====================================
    //
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
*/
    
    func refreshUserWallet() {
        Env.servicesProvider.getUserBalance()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    self.userWalletPublisher.send(nil)
                }
            }, receiveValue: { [weak self] (userWallet: ServicesProvider.UserWallet) in
                guard
                    let currency = userWallet.currency,
                    let total = userWallet.total
                else {
                    self?.userWalletPublisher.send(nil)
                    return
                }
                let wallet = UserWallet(total: total,
                                        bonus: userWallet.bonus,
                                        totalWithdrawable: userWallet.totalWithdrawable,
                                        currency: currency)
                self?.userWalletPublisher.send(wallet)
            })
            .store(in: &cancellables)
    }
    
    func refreshUserProfile() {
        self.startUserSessionIfNeeded()
    }

}

extension UserSessionStore {

    func startUserSessionIfNeeded() {

        self.isLoadingUserSessionPublisher.send(true)

        guard
            let user = UserSessionStore.loggedUserSession(),
            let userPassword = UserSessionStore.storedUserPassword()
        else {
            Logger.log("UserSessionStore - User Session not found - login not needed")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        Logger.log("UserSessionStore - User Session found - login needed")

        self.loadLoggedUser()

        // Trigger internal login
        self.login(withUsername: user.username, password: userPassword)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .invalidEmailPassword:
                        self?.logout()
                    case .quickSignUpIncomplete:
                        self?.logout() // TODO: Finish Quick Sign up code completion
                    case .restrictedCountry(let errorMessage):
                        ()
                    case .serverError:
                        ()
                    }
                    print("UserSessionStore login failed, error: \(error)")
                case .finished:
                    ()
                }
                self?.isLoadingUserSessionPublisher.send(false)
            }, receiveValue: { loggedUser in
                // Env.favoritesManager.getUserFavorites()
            })
            .store(in: &cancellables)
        
//        Env.everyMatrixClient.login(username: user.username, password: userPassword)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                switch completion {
//                case .finished:
//                    Env.favoritesManager.getUserFavorites()
//                    self?.loginGomaAPI(username: user.username, password: user.userId)
//                case .failure(let error):
//                    if error.localizedDescription.lowercased().contains("you are already logged in") {
//                        Env.favoritesManager.getUserFavorites()
//                        self?.loginGomaAPI(username: user.username, password: user.userId)
//                    }
//                    print("error \(error)")
//                }
//                self?.isLoadingUserSessionPublisher.send(false)
//            } receiveValue: { account in
//                Env.userSessionStore.isUserProfileIncomplete.send(account.isProfileIncomplete)
//                Env.userSessionStore.isUserEmailVerified.send(account.isEmailVerified)
//            }
//            .store(in: &cancellables)
    }

}

extension UserSessionStore {
    
    private func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFCMToken)

        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] value in
                Env.gomaNetworkClient.refreshAuthToken(token: value)
                Env.gomaSocialClient.connectSocket()
                
                self?.hasGomaUserSessionPublisher.send(true)

                Env.gomaSocialClient.getInAppMessagesCounter()

                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    func signUpSimpleGomaAPI(form: ServicesProvider.SimpleSignUpForm, userId: String) {
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
            .sink { [weak self] response in
                self?.loginGomaAPI(username: form.username, password: userId)
                print("signUpSimpleGomaAPI \(response)")
            }
            .store(in: &cancellables)
    }
    
}

extension UserSessionStore {

    func setShouldRequestFaceId(_ request: Bool) {
        UserDefaults.standard.set(request, forKey: "shouldRequestBiometrics")
        UserDefaults.standard.synchronize()
    }

    func shouldRequestFaceId() -> Bool {
        let shouldRequest = UserDefaults.standard.bool(forKey: "shouldRequestBiometrics")
        return shouldRequest && UserSessionStore.isUserLogged()
    }
    
}
