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
import OptimoveSDK

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

enum UserProfileStatus {
    case anonymous
    case logged
}

enum UserTrackingStatus {
    case unkown
    case skipped
    case accepted
}

class UserSessionStore {

    var isLoadingUserSessionPublisher = CurrentValueSubject<Bool, Never>(true)

    var userProfilePublisher = CurrentValueSubject<UserProfile?, Never>(nil)

    var userSessionPublisher = CurrentValueSubject<UserSession?, Never>(nil)

    var userProfileStatusPublisher: AnyPublisher<UserProfileStatus, Never> {
        return self.userProfilePublisher
            .map { profile in
                if profile != nil {
                    return UserProfileStatus.logged
                }
                else {
                    return UserProfileStatus.anonymous
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
    var userCashbackBalance = CurrentValueSubject<Double?, Never>(nil)
    var acceptedTrackingPublisher = CurrentValueSubject<UserTrackingStatus, Never>(.unkown)

    var shouldRecordUserSession = true
    var shouldSkipLimitsScreen = false

    var shouldAuthenticateUser = true
    
    var loggedUserProfile: UserProfile? {
        return self.userProfilePublisher.value
    }

    private var storedUserPassword: String? {
        if let storedUserSession = self.storedUserSession,
           let passwordData = try? KeychainInterface.readPassword(service: Env.bundleId, account: storedUserSession.userId),
           let password = String(data: passwordData, encoding: .utf8) {
            return password
        }
        else if let userSession = self.storedUserSession {
            return userSession.password
        }
        return nil
    }

    private var isRefreshingUserWallet: Bool = false
    private var storedUserSession: UserSession? {
        // There is a cached session user
        return UserDefaults.standard.userSession
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.acceptedTrackingPublisher.send(self.hasAcceptedTracking)

        self.userSessionPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSession in
                self?.saveUserSession(userSession)
            }
            .store(in: &self.cancellables)

        self.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if let userProfile = userProfile {
                    self?.refreshUserWallet()
                    
                    self?.updateDeviceIdentifier()

                    self?.isUserProfileComplete = userProfile.isRegistrationCompleted
                    self?.isUserEmailVerified = userProfile.isEmailVerified
                    self?.userKnowYourCustomerStatus = userProfile.kycStatus

                    Optimove.shared.setUserId(userProfile.userIdentifier)
                }
                else {
                    self?.isUserProfileComplete = nil
                    self?.isUserEmailVerified = nil
                    self?.userKnowYourCustomerStatus = nil
                }
            }
            .store(in: &self.cancellables)

    }

    func startUserSession() {
        self.startUserSessionIfNeeded()
    }

    func isUserLogged() -> Bool {
        // return UserDefaults.standard.userSession != nil
        return self.userProfilePublisher.value != nil
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

        UserDefaults.standard.userSession = userSession.safeUserSession
    }

    func updatePassword(newPassword password: String) {
        guard
            var session = self.storedUserSession
        else {
            return
        }

        session.password = password
        self.saveUserSession(session)
    }

    //
    func logout() {

        if !self.isUserLogged() {
            // There is no user logged in
            return
        }
        
        if let userSession = self.storedUserSession {
            try? KeychainInterface.deletePassword(service: Env.bundleId, account: userSession.userId)
        }

        UserDefaults.standard.userSession = nil

        Env.favoritesManager.clearCachedFavorites()
        Env.gomaSocialClient.clearUserChatroomsData()

        // Remove previous registration info
        UserDefaults.standard.startedUserRegisterInfo = nil
        
        //
        Env.gomaNetworkClient.reconnectSession()

        self.userProfilePublisher.send(nil)
        self.userSessionPublisher.send(nil)
        self.userWalletPublisher.send(nil)
        self.userCashbackBalance.send(nil)

        Optimove.shared.signOutUser()
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
                self?.shouldAuthenticateUser = false
                
                self?.userSessionPublisher.send(session)
                self?.userProfilePublisher.send(profile)
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
            .replaceError(with: false) // if an error occour it shouldn't show the blocking screen
            .eraseToAnyPublisher()
    }

}

extension UserSessionStore {
    
    private func updateDeviceIdentifier() {
        
        if Env.deviceFirebaseCloudMessagingToken.isNotEmpty {
            Env.servicesProvider
                .updateDeviceIdentifier(deviceIdentifier: "")
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print("UserSessionStore updateDeviceIdentifier completed: \(completion)")
                } receiveValue: { response in
                    print("UserSessionStore updateDeviceIdentifier response: \(response)")
                }
                .store(in: &self.cancellables)

        }
        
    }
    
}

extension UserSessionStore {

    func refreshUserProfile() {
        self.startUserSessionIfNeeded()
    }

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

    func getProfile() -> AnyPublisher<UserProfile?, Never> {
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
            .store(in: &self.cancellables)
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
            .store(in: &self.cancellables)
    }
    
    private func storeBettingUserSettings(bettingUserSettings: BettingUserSettings) {
        UserDefaults.standard.bettingUserSettings = bettingUserSettings
    }

}

extension UserSessionStore {

    func refreshUserWalletAfterDelay() {
        executeDelayed(0.3) {
            self.refreshUserWallet()
        }
    }

    func refreshUserWallet() {

        if Thread.isMainThread {
            // This code is running on the main thread
            // You can put your main-thread-specific logic here
            print("UserSessionStore refreshUserWallet isMainThread")
        } else {
            // This code is running on a background thread
            // You may need to dispatch UI-related tasks to the main thread if necessary
            print("UserSessionStore refreshUserWallet not isMainThread")
        }

        guard self.isUserLogged() else {
            self.isRefreshingUserWallet = false
            return
        }

        if self.isRefreshingUserWallet {
            // a refresh is in progress
            return
        }

        self.refreshCashbackBalance()
        
        self.isRefreshingUserWallet = true

        Logger.log("UserSessionStore - refreshUserWallet")

        Env.servicesProvider.getUserBalance()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.userWalletPublisher.send(nil)
                }
                self?.isRefreshingUserWallet = false
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
            .store(in: &self.cancellables)
    }

    private func refreshCashbackBalance() {

        Env.servicesProvider.getUserCashbackBalance()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.userCashbackBalance.send(nil)
                }
            }, receiveValue: { [weak self] (cashbackBalance: ServicesProvider.CashbackBalance) in
                guard
                    let balance = cashbackBalance.balance
                else {
                    self?.userCashbackBalance.send(nil)
                    return
                }
                let cashbackBalance = Double(balance)
                self?.userCashbackBalance.send(cashbackBalance)
            })
            .store(in: &self.cancellables)
    }

}

extension UserSessionStore {

    func startUserSessionIfNeeded() {

        self.isLoadingUserSessionPublisher.send(true)

        guard
            let user = self.storedUserSession,
            let userPassword = self.storedUserPassword
        else {
            Logger.log("UserSessionStore - User Session not found - login not needed")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        Logger.log("UserSessionStore - User Session found - login needed")

        // Trigger internal login
        self.login(withUsername: user.username, password: userPassword)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .invalidEmailPassword:
                        self?.logout()
                    case .quickSignUpIncomplete:
                        self?.logout()
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
            }, receiveValue: {

            })
            .store(in: &cancellables)
    }

}

extension UserSessionStore {
    
    private func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFirebaseCloudMessagingToken)

        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] value in
                Env.gomaNetworkClient.refreshAuthToken(token: value)
                Env.gomaSocialClient.connectSocket()

                Env.gomaSocialClient.getInAppMessagesCounter()

                Env.gomaSocialClient.getFollowingUsers()
            })
            .store(in: &self.cancellables)
    }

    private func signUpSimpleGomaAPI(form: ServicesProvider.SimpleSignUpForm, userId: String) {
        let deviceId = Env.deviceId
        let userRegisterForm = UserRegisterForm(username: form.username,
                                                email: form.email,
                                                mobilePrefix: form.mobilePrefix,
                                                mobile: form.mobileNumber,
                                                birthDate: form.birthDate,
                                                userProviderId: userId,
                                                deviceToken: Env.deviceFirebaseCloudMessagingToken)
        Env.gomaNetworkClient
            .requestUserRegister(deviceId: deviceId, userRegisterForm: userRegisterForm)
            .replaceError(with: MessageNetworkResponse.failed)
            .sink { [weak self] response in
                self?.loginGomaAPI(username: form.username, password: userId)
            }
            .store(in: &cancellables)
    }
    
}

extension UserSessionStore {

    static func didSkipLoginFlow() -> Bool {
        UserDefaults.standard.userSkippedLoginFlow
    }

    static func skippedLoginFlow() {
        UserDefaults.standard.userSkippedLoginFlow = true
    }

}

extension UserSessionStore {

    func disableForcedLimitsScreen() {
        self.shouldSkipLimitsScreen = true
    }

}

extension UserSessionStore {

    func setShouldRequestBiometrics(_ newValue: Bool) {
        UserDefaults.standard.biometricAuthenticationEnabled = newValue
    }

    func shouldRequestBiometrics() -> Bool {
        let hasStoredUserSession = self.storedUserSession != nil
        return hasStoredUserSession && UserDefaults.standard.biometricAuthenticationEnabled 
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
                self.acceptedTrackingPublisher.send(.accepted)
            }
        }
        else {
            self.acceptedTrackingPublisher.send(.accepted)
        }

    }

    func didSkippedTracking() {
        self.acceptedTrackingPublisher.send(.skipped)
    }

    var hasAcceptedTracking: UserTrackingStatus {
        if UserDefaults.standard.acceptedTracking {
            return .accepted
        }
        else {
            return .unkown
        }
    }

}
