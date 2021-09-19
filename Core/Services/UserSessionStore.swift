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

struct UserSessionStore {


    static func loggedUserSession() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

    func cacheUserSession(_ userSession: UserSession) {
        UserDefaults.standard.userSession = userSession
    }

    //
    static func isUserAnonymous() -> Bool {
        return UserDefaults.standard.userSkippedLoginFlow
    }

    static func skippedLoginFlow() {
        UserDefaults.standard.userSkippedLoginFlow = true
    }

    //
    func logout() {
        UserDefaults.standard.userSession = nil
    }

    func loginUser(with email: String, password: String) -> AnyPublisher<UserSession, UserSessionError> {

        let publisher = Env.everyMatrixAPIClient
            .loginComplete(username: email, password: password)
            .mapError { (error: EveryMatrixSocketAPIError) -> UserSessionError in
                switch error {
                case let .requestError(message) where message.contains("check your username and password"):
                    return .invalidEmailPassword
                default:
                    return .serverError
                }
            }
            .map({ sessionInfo in
                UserSession(username: sessionInfo.username,
                            email: sessionInfo.email,
                            userId: "\(sessionInfo.userID)")
            })
            .handleEvents(receiveOutput: cacheUserSession)
            .eraseToAnyPublisher()

        return publisher
    }

}
