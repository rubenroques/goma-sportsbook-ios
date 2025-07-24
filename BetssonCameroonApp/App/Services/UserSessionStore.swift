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

enum UserProfileStatus {
    case anonymous
    case logged
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

    var userWalletPublisher = CurrentValueSubject<UserWallet?, Never>(nil)
    var userCashbackBalance = CurrentValueSubject<Double?, Never>(nil)

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
    
    var loginFlowSuccess: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldAuthenticateUser = true
    var shouldRecordUserSession = true
    
    private var cancellables = Set<AnyCancellable>()

    init() {
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
        Env.userSessionStore.loginFlowSuccess.send(false)
        
        if !self.isUserLogged() {
            // There is no user logged in
            self.isLoadingUserSessionPublisher.send(false)
            return
        }
        
        if let userSession = self.storedUserSession {
            try? KeychainInterface.deletePassword(service: Env.bundleId, account: userSession.userId)
        }

        UserDefaults.standard.userSession = nil

        Env.favoritesManager.clearCachedFavorites()

        self.userProfilePublisher.send(nil)
        self.userSessionPublisher.send(nil)
        self.userWalletPublisher.send(nil)
        self.userCashbackBalance.send(nil)
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
                case .errorDetailedMessage(_, let message):
                    return .errorMessage(errorMessage: message)
                case .failedTempLock(let date):
                    return .failedTempLock(date: date)
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
        return Env.servicesProvider.signUp(with: .simple(form))
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


}

extension UserSessionStore {
    
    private func updateDeviceIdentifier() {
        
        var versionCode = ""
        if let buildNumber = Bundle.main.buildNumber {
            versionCode = buildNumber
        }
        
        if !Env.deviceFirebaseCloudMessagingToken.isEmpty {
            Env.servicesProvider
                .updateDeviceIdentifier(deviceIdentifier: Env.deviceFirebaseCloudMessagingToken, appVersion: versionCode)
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

    func refreshUserWalletAfterDelay() {
        executeDelayed(0.3) {
            self.refreshUserWallet()
        }
    }

    func refreshUserWallet() {
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

        print("UserSessionStore - will refreshUserWallet")

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
                    let withdrawable = userWallet.withdrawable,
                    let bonus = userWallet.bonus
                    
                else {
                    self?.userWalletPublisher.send(nil)
                    return
                }
                
                let totalBalance = withdrawable + bonus
                
                let wallet = UserWallet(total: totalBalance,
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
            print("UserSessionStore - User Session not found - login not needed")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        print("UserSessionStore - User Session found - login needed")

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
                    case .restrictedCountry:
                        break
                    case .serverError:
                        break
                    case .errorMessage:
                        break
                    case .failedTempLock:
                        break
                    }
                    print("UserSessionStore - login failed, error: \(error)")
                case .finished:
                    ()
                }
                self?.isLoadingUserSessionPublisher.send(false)
                Env.userSessionStore.loginFlowSuccess.send(true)
            }, receiveValue: {

            })
            .store(in: &cancellables)
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
