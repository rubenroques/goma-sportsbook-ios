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

    var userSessionPublisher = CurrentValueSubject<UserSession?, Never>(nil)

    static func loggedUserSession() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

    func saveUserSession(_ userSession: UserSession) {
        userSessionPublisher.send(userSession)

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
        UserDefaults.standard.userSession = nil

        userSessionPublisher.send(nil)

        Env.everyMatrixAPIClient
            .logout()
            .sink(receiveCompletion: { completion in
                Logger.log("User logout \(completion)")
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)
    }

    func loginUser(withUsername username: String, password: String) -> AnyPublisher<UserSession, UserSessionError> {

        let publisher = Env.everyMatrixAPIClient
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
                            email: sessionInfo.email,
                            userId: "\(sessionInfo.userID)",
                            birthDate: sessionInfo.birthDate
                    )
            }
            .handleEvents(receiveOutput: saveUserSession)
            .eraseToAnyPublisher()

        return publisher
    }

    func registerUser(form: EveryMatrix.SimpleRegisterForm) -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Env.everyMatrixAPIClient
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
                                                userProviderId: userId)
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
