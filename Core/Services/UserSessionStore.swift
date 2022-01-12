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

    var shouldRecordUserSession = true
    var isUserProfileIncomplete = CurrentValueSubject<Bool, Never>(true)

    init() {

        NotificationCenter.default.publisher(for: .sessionConnected)
            .setFailureType(to: EveryMatrix.APIError.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] _ in
                self?.startUserSessionIfNeeded()
            })
            .store(in: &cancellables)


        NotificationCenter.default.publisher(for: .sessionForcedLogoutDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.logout()
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
                            isEmailVerified: sessionInfo.isEmailVerified                    )
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
                                                mobile: form.mobileNumber,
                                                birthDate: form.birthDate,
                                                userProviderId: userId,
                                                deviceToken: Env.deviceFCMToken)
        Env.gomaNetworkClient
            .requestUserRegister(deviceId: deviceId, userRegisterForm: userRegisterForm)
            .replaceError(with: MessageNetworkResponse.failed)
            .sink { registered in
                print("User registered on goma api \(registered)")
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
        TSManager.shared.getModel(router: route, decodingType: EveryMatrix.UserBalance.self)
            .sink { completion in
                print(completion)
            } receiveValue: { userBalance in
                var realWallet: EveryMatrix.UserBalanceWallet?
                for wallet in userBalance.wallets {
                    if wallet.vendor == "CasinoWallet" {
                        realWallet = wallet
                        break
                    }
                }
                self.userBalanceWallet.send(realWallet)
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
            Logger.log("User Session not found - not needed")
            self.isLoadingUserSessionPublisher.send(false)
            return
        }

        Logger.log("User Session found - login needed")

        self.loadLoggedUser()

        TSManager.shared
            .getModel(router: .login(username: user.username, password: userPassword), decodingType: LoginAccount.self)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    Env.favoritesManager.getUserMetadata()
                    self.loginGomaAPI(username: user.username, password: user.userId)
                case .failure(let error):
                    print("error \(error)")

                }
                self.isLoadingUserSessionPublisher.send(false)
            } receiveValue: { account in
                Env.userSessionStore.isUserProfileIncomplete.send(account.isProfileIncomplete)
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
