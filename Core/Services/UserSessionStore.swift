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

        // TODO: Remove this, it shoulg detect the service provider connection state
        executeDelayed(0.15) {
            self.startUserSessionIfNeeded()
        }

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

        Env.favoritesManager.clearCachedFavorites()
        Env.gomaSocialClient.clearUserChatroomsData()

        // TODO: Migrate to UserDefaults extensions
        UserDefaults.standard.removeObject(forKey: "RegistrationFormDataKey")

        Env.gomaNetworkClient.reconnectSession()

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
                
                return UserSession(username: userProfile.username,
                                   password: password,
                                   email: userProfile.email,
                                   userId: userProfile.userIdentifier,
                                   birthDate: userProfile.birthDate.toString(),
                                   isEmailVerified: userProfile.isEmailVerified,
                                   isProfileCompleted: userProfile.isRegistrationCompleted,
                                   avatarName: userProfile.avatarName,
                                   isKycVerified: userProfile.kycStatus == "PASS" ? true : false)
            }
            .handleEvents(receiveOutput: { [weak self] userSession in
                self?.saveUserSession(userSession)
                self?.loginGomaAPI(username: userSession.username, password: userSession.userId)
                
                self?.refreshUserWallet()
                
                Env.userSessionStore.isUserProfileComplete.send(userSession.isProfileCompleted)
                Env.userSessionStore.isUserEmailVerified.send(userSession.isEmailVerified)
                Env.userSessionStore.isUserKycVerified.send(userSession.isKycVerified)
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

}

extension UserSessionStore {

    // =====================================
    //
    func requestNotificationsUserSettings() {
        Env.gomaNetworkClient.requestNotificationsUserSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.storeNotificationsUserSettings(notificationsUserSettings: NotificationsUserSettings.defaultSettings)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] notificationsUserSettings in
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
                                        totalWithdrawable: userWallet.withdrawable,
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
            }, receiveValue: { [weak self] loggedUser in
                //Env.favoritesManager.getUserFavorites()
                self?.setupFavorites()
            })
            .store(in: &cancellables)
    }

    func setupFavorites() {

        Env.servicesProvider.bettingConnectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] connectorState in

                switch connectorState {
                case .connected:
                    Env.favoritesManager.getUserFavorites()
                case .disconnected:
                    ()
                }
            })
            .store(in: &cancellables)
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

    func setShouldRequestFaceId(_ newValue: Bool) {
        UserDefaults.standard.biometricAuthenticationEnabled = newValue
    }

    func shouldRequestFaceId() -> Bool {
        return UserDefaults.standard.biometricAuthenticationEnabled
    }
    
}
