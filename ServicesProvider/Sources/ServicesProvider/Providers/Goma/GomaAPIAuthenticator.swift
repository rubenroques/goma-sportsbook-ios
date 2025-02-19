//
//  GomaAPIAuthenticator.swift
//
//
//  Created by Ruben Roques on 18/12/2023.
//

import Foundation
import Combine

class GomaAPIAuthenticator {

    var deviceIdentifier: String
    
    private let session: URLSession
    
    var pushNotificationsToken: String?
    
    private var token: GomaSessionAccessToken?
    private var credentials: GomaUserCredentials?
    
    private let queue = DispatchQueue(label: "GomaAPIAuthenticator.\(UUID().uuidString)")

    // This publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<GomaSessionAccessToken, Error>?

    init(deviceIdentifier: String, session: URLSession = URLSession.shared) {
        self.deviceIdentifier = deviceIdentifier
        self.session = session
    }
    
    func getToken() -> String? {
        return self.token?.hash
    }

    func updateToken(newToken: String?) {
        if let newToken = newToken {
            self.token = GomaSessionAccessToken(hash: newToken, type: "")
        }
        else {
            self.token = nil
        }
    }
    
    func updateCredentials(credentials: GomaUserCredentials?) {
        self.credentials = credentials
    }
    
    func updatePushNotificationToken(newToken: String?) {
        var shouldForceUpdateToken = (self.pushNotificationsToken == nil && newToken != nil )
        self.pushNotificationsToken = newToken
        
        // We need to force an auth or login in the next requests so we can send the PushToken
        if shouldForceUpdateToken {
            self.token = nil
        }
    }
    
    
    func publisherWithValidToken(forceRefresh: Bool = false) -> AnyPublisher<GomaSessionAccessToken, Error> {
        if let loggedUserCredentials = self.credentials {
            return self.loggedUserValidToken(deviceId: self.deviceIdentifier,
                                             pushToken: self.pushNotificationsToken,
                                             forceRefresh: forceRefresh,
                                             loggedUser: loggedUserCredentials)
        }
        else {
            return self.anonymousValidToken(deviceId: self.deviceIdentifier,
                                            pushToken: self.pushNotificationsToken,
                                            forceRefresh: forceRefresh)
        }
    }

    private func loggedUserValidToken(deviceId: String, pushToken: String?, forceRefresh: Bool = false, loggedUser: GomaUserCredentials) -> AnyPublisher<GomaSessionAccessToken, Error> {
        return self.queue.sync(execute: { [weak self] in
            
            var shouldForceRefresh = forceRefresh
            
            // We're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }
            
            // We don't have a token so we override the forceRefresh
            if let selfValue = self, selfValue.token == nil {
                shouldForceRefresh = true
            }
            
            
            // We already have a valid token and don't want to force a refresh
            if let selfValue = self, let token = selfValue.token, !shouldForceRefresh {
                return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            
            let endpoint = GomaAPIClient.login(username: loggedUser.username,
                                               password: loggedUser.password,
                                               pushToken: pushToken)
            
            guard
                let weakSelf = self,
                let request = endpoint.request()
            else {
                return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
            }
            
            let publisher = weakSelf.session.dataTaskPublisher(for: request)
                .tryMap { result in
                    if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                        throw ServiceProviderError.unauthorized
                    }
                    else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                        throw ServiceProviderError.forbidden
                    }
                    else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        throw ServiceProviderError.unknown
                    }
                    return result.data
                }
                .share()
                .decode(type: GomaSessionAccessToken.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.token = token
                    print("GGAPI New Session Token [logged] \(token)")
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()
            
            self?.refreshPublisher = publisher
            
            return publisher
        })
    }

    private func anonymousValidToken(deviceId: String,
                                     pushToken: String?,
                                     forceRefresh: Bool = false) -> AnyPublisher<GomaSessionAccessToken, Error> {
        return self.queue.sync(execute: { [weak self] in

            var shouldForceRefresh = forceRefresh

            // We're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // We don't have a token so we override the forceRefresh
            if let selfValue = self, selfValue.token == nil {
                shouldForceRefresh = true
            }

            // We already have a valid token and don't want to force a refresh
            if let selfValue = self, let token = selfValue.token, !shouldForceRefresh {
                return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            let endpoint = GomaAPIClient.anonymousAuth(deviceId: deviceId,
                                                       pushToken: pushToken)
            
            guard
                let weakSelf = self,
                let request = endpoint.request()
            else {
                return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
            }
            
            let publisher = weakSelf.session.dataTaskPublisher(for: request)
                .tryMap { result in
                    if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                        throw ServiceProviderError.unauthorized
                    }
                    else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                        throw ServiceProviderError.forbidden
                    }
                    else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        throw ServiceProviderError.unknown
                    }
                    return result.data
                }
            
                .share()
                .decode(type: GomaSessionAccessToken.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.token = token
                    print("GGAPI New Session Token [anon] \(token)")
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher

        })
    }

}
