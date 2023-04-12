//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine
import AppTrackingTransparency
import AdSupport
import ServicesProvider

enum UserSessionError: Error {
    case invalidEmailPassword
    case restrictedCountry(errorMessage: String)
    case serverError
    case quickSignUpIncomplete
    case errorMessage(errorMessage: String)
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

    var isLoadingUserSessionPublisher = CurrentValueSubject<Bool, Never>(true)

    var userProfilePublisher = CurrentValueSubject<UserProfile?, Never>(nil)

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

    var isUserProfileComplete: Bool?
    var isUserProfileCompletePublisher: AnyPublisher<Bool?, Never> {
        return self.userProfilePublisher
            .map { $0?.isRegistrationCompleted }
            .eraseToAnyPublisher()
    }
    
    var isUserEmailVerified: Bool?
    var isUserEmailVerifiedPublisher: AnyPublisher<Bool?, Never> {
        return self.userProfilePublisher
            .map { $0?.isEmailVerified }
            .eraseToAnyPublisher()
    }

    var userKnowYourCustomerStatus: KnowYourCustomerStatus?
    var userKnowYourCustomerStatusPublisher: AnyPublisher<KnowYourCustomerStatus?, Never> {
        return self.userProfilePublisher
            .map { $0?.kycStatus }
            .eraseToAnyPublisher()
    }

    var userWalletPublisher = CurrentValueSubject<UserWallet?, Never>(nil)
    var acceptedTrackingPublisher = CurrentValueSubject<Bool?, Never>(false)

    var shouldRecordUserSession = true
    var shouldSkipLimitsScreen = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.acceptedTrackingPublisher.send(self.hasAcceptedTracking())

        self.userSessionPublisher.compactMap({ $0 })
            .sink { [weak self] userSession in
                self?.saveUserSession(userSession)
            }
            .store(in: &self.cancellables)

        self.userProfilePublisher
            .sink { [weak self] userSession in
                if let userSession = userSession {
                    self?.isUserProfileComplete = userSession.isRegistrationCompleted
                    self?.isUserEmailVerified = userSession.isEmailVerified
                    self?.userKnowYourCustomerStatus = userSession.kycStatus
                }
                else {
                    self?.isUserProfileComplete = nil
                    self?.isUserEmailVerified = nil
                    self?.userKnowYourCustomerStatus = nil
                }
            }
            .store(in: &self.cancellables)

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

        self.userProfilePublisher.send(nil)
        self.userSessionPublisher.send(nil)
        self.userWalletPublisher.send(nil)        
    }

    func login(withUsername username: String, password: String) -> AnyPublisher<Void, UserSessionError> {

        let publisher = Env.servicesProvider.loginUser(withUsername: username, andPassword: password)
            .mapError { (error: ServiceProviderError) -> UserSessionError in
                switch error {
                case .invalidEmailPassword:
                    return .invalidEmailPassword
                case .quickSignUpIncomplete:
                    return .quickSignUpIncomplete
                case .errorMessage(let message):
                    return .errorMessage(errorMessage: message)
                default:
                    return .serverError
                }
            }
            .map({ (serviceProviderProfile: ServicesProvider.UserProfile) in
                return ServiceProviderModelMapper.userProfile(serviceProviderProfile)
            })
            .map { (userProfile: UserProfile) -> (UserSession, UserProfile) in
                let session = UserSession(username: userProfile.username,
                                          password: password,
                                          email: userProfile.email,
                                          userId: userProfile.userIdentifier,
                                          birthDate: userProfile.birthDate.toString(),
                                          avatarName: userProfile.avatarName)

                return (session, userProfile)
            }
            .handleEvents(receiveOutput: { [weak self] session, profile in
                self?.userProfilePublisher.send(profile)
                self?.userSessionPublisher.send(session)

                self?.loginGomaAPI(username: session.username, password: session.userId)
                
                self?.refreshUserWallet()
            })
            .map({ _ in
                return ()
            })
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    func registerUser(form: ServicesProvider.SimpleSignUpForm) -> AnyPublisher<Void, RegisterUserError> {
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
            .map { _ in return () }
            .eraseToAnyPublisher()

    }

    func shouldRequestLimits() -> AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(Env.servicesProvider.getPersonalDepositLimits(), Env.servicesProvider.getLimits())
            .map {  [weak self] depositLimitResponse, bettingLimitsResponse in

                if self?.shouldSkipLimitsScreen ?? false {
                    return false
                }

                let hasLimitsDefined = depositLimitResponse.weeklyLimit != nil
                let hasBettingLimitsDefined = bettingLimitsResponse.wagerLimit != nil

                if hasLimitsDefined && hasBettingLimitsDefined {
                    return false
                }
                else {
                    return true
                }
            }
            .replaceError(with: false) // if an error occour don't show
            .eraseToAnyPublisher()
    }

}

extension UserSessionStore {

    func refreshProfile() {
        Env.servicesProvider.getProfile()
            .map(ServiceProviderModelMapper.userProfile(_:))
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let serviceProviderError):
                    print("UserSessionStore refreshProfile error: \(serviceProviderError)")
                }
            } receiveValue: { [weak self] userProfile in
                self?.userProfilePublisher.send(userProfile)
            }
            .store(in: &self.cancellables)
    }

    func getProfile() -> AnyPublisher<UserProfile?, Never>  {
        return Env.servicesProvider.getProfile()
            .map(ServiceProviderModelMapper.userProfile(_:))
            .handleEvents(receiveOutput: { [weak self] userProfile in
                self?.userProfilePublisher.send(userProfile)
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
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

    func refreshUserWalletAfterDelay() {
        executeDelayed(0.3) {
            self.refreshUserWallet()
        }
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
                    case .errorMessage(let errorMessage):
                        ()
                    }
                    print("UserSessionStore login failed, error: \(error)")
                case .finished:
                    ()
                }
                self?.isLoadingUserSessionPublisher.send(false)
            }, receiveValue: { [weak self] loggedUser in
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

                Env.gomaSocialClient.getInAppMessagesCounter()

                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &cancellables)
    }

    private func signUpSimpleGomaAPI(form: ServicesProvider.SimpleSignUpForm, userId: String) {
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

    func disableForcedLimitsScreen() {
        self.shouldSkipLimitsScreen = true
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

extension UserSessionStore {

    func didAcceptedTracking() {

        UserDefaults.standard.acceptedTracking = true

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown and we are authorized
                    print("Authorized")
                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    print("Denied") // Tracking authorization dialog was shown and permission is denied
                case .notDetermined:
                    print("Not Determined") // Tracking authorization dialog has not been shown
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
                self.acceptedTrackingPublisher.send(true)
            }
        }
        else {
            self.acceptedTrackingPublisher.send(true)
        }

    }

    func didSkipedTracking() {
        self.acceptedTrackingPublisher.send(nil)
    }

    func hasAcceptedTracking() -> Bool {
        return UserDefaults.standard.acceptedTracking
    }

}

