//
//  OmegaConnector.swift
//  
//
//  Created by Ruben Roques on 25/10/2022.
//

import Foundation
import Combine

class OmegaConnector: Connector {
    
    var token: CurrentValueSubject<OmegaSessionAccessToken?, Never> = .init(nil)
    var tokenPublisher: AnyPublisher<OmegaSessionAccessToken?, Never> {
        token.eraseToAnyPublisher()
    }
    
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Error> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private var sessionCredentials: OmegaSessionCredentials?
    private let notLoggedError = "NOT_LOGGED_IN_ERROR"
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    private func clearCacheSessionKey() {
        return self.token.send(nil)
    }
    
    private func cacheSessionKey(_ sessionKey: String) {
        return self.token.send(OmegaSessionAccessToken(sessionKey: sessionKey))
    }
    
    private func cacheLaunchKey(_ launchKey: String) {
        if let token = self.token.value {
            let accessToken = OmegaSessionAccessToken(sessionKey: token.sessionKey, launchKey: launchKey)
            return self.token.send(accessToken)
        }
    }
    
    private func retrieveSessionKey() -> String? {
        return self.token.value?.sessionKey
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        var additionalQueryItems: [URLQueryItem] = []
        if endpoint.requireSessionKey {
            if let sessionKey = self.retrieveSessionKey() {
                additionalQueryItems.append(URLQueryItem(name: "sessionKey", value: sessionKey))
            }
            else if let sessionCredentials = self.sessionCredentials {
                return self.login(username: sessionCredentials.username, password: sessionCredentials.password)
                    .flatMap { [weak self] sessionKey -> AnyPublisher<T, ServiceProviderError> in
                        guard
                            let self = self
                        else {
                            return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                        }
                        return self.request(endpoint)
                    }
                    .eraseToAnyPublisher()
            }
            else {
                return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
            }
        }
        
        guard
            let request = endpoint.request(aditionalQueryItems: additionalQueryItems)
        else {
            let error = ServiceProviderError.invalidRequestFormat
            return Fail<T, ServiceProviderError>(error: error).eraseToAnyPublisher()
        }
        
        return self.session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
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
            .mapError({ error in
                if let typedError = error as? ServiceProviderError {
                    return typedError
                }
                return ServiceProviderError.invalidResponse
            })
//            .handleEvents(receiveOutput: { data in
//                print("ServiceProvider-OmegaConnector [[ requesting ]] ", request,
//                      " [[ response ]] ", String(data: data, encoding: .utf8) ?? "!?" )
//            })
            .flatMap({ [weak self] (data: Data) -> AnyPublisher<T, ServiceProviderError> in
                guard
                    let self = self
                else {
                    return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                }
                
                if let responseStatus = try? JSONDecoder().decode(SportRadarModels.StatusResponse.self, from: data) {
                    if responseStatus.status == self.notLoggedError {
                        self.clearCacheSessionKey()
                        return self.request(endpoint)
                    }
                    else {
                        do {
                            let mappedObject = try self.decoder.decode(T.self, from: data)
                            return Just(mappedObject).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                        }
                        catch {
                            print("ServiceProvider-OmegaConnector Decoding Error \(error)")
                            return Fail(error: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
                        }
                    }
                }
                else {
                    return Fail(error: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    func login(username: String, password: String) -> AnyPublisher<SportRadarModels.LoginResponse, ServiceProviderError> {
        
        guard
            let request = OmegaAPIClient.login(username: username, password: password).request()
        else {
            return Fail(error: .invalidRequestFormat).eraseToAnyPublisher()
        }
        
        return self.session.dataTaskPublisher(for: request)
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
            .decode(type: SportRadarModels.LoginResponse.self, decoder: self.decoder)
            .mapError { error in
                print("ServiceProvider-OmegaConnector Error \(error)")
                return ServiceProviderError.invalidResponse
            }
            .flatMap({ loginResponse -> AnyPublisher<SportRadarModels.LoginResponse, ServiceProviderError> in
                if loginResponse.status == "FAIL_UN_PW" {
                    self.logout()
                    return Fail(error: ServiceProviderError.invalidEmailPassword).eraseToAnyPublisher()
                }
                else if loginResponse.status == "FAIL_QUICK_OPEN_STATUS" {
                    return Fail(error: ServiceProviderError.quickSignUpIncomplete).eraseToAnyPublisher()
                }
                else if loginResponse.status == "SUCCESS", let sessionKey = loginResponse.sessionKey {
                    self.cacheSessionKey(sessionKey)
                    self.sessionCredentials = OmegaSessionCredentials(username: username, password: password)
                    self.openSession()
                    return Just(loginResponse)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    

    func logout() {
        self.token.send(nil)
        self.sessionCredentials = nil
    }


    func openSession() {
        guard
            let sessionKey = self.retrieveSessionKey(),
            let request = OmegaAPIClient.openSession.request(aditionalQueryItems: [URLQueryItem(name: "sessionKey", value: sessionKey)])
        else {
            return
        }
        print("SESSION KEY: \(sessionKey)")
        self.session.dataTaskPublisher(for: request)
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
            .decode(type: SportRadarModels.OpenSessionResponse.self, decoder: self.decoder)
            .mapError { error in
                // Debug helper
                print("ServiceProvider-OmegaConnector Error \(error)")
                return ServiceProviderError.invalidResponse
            }
            .sink(receiveCompletion: { completion in
                    
            }, receiveValue: { [weak self] openSessionResponse in
                self?.cacheLaunchKey(openSessionResponse.launchToken)
            })
            .store(in: &cancellables)
        
//            .flatMap({ openSessionResponse -> AnyPublisher<SportRadarModels.OpenSessionResponse, ServiceProviderError> in
//                if openSessionResponse.status == "FAIL_UN_PW" {
//                    self.logout()
//                    return Fail(outputType: SportRadarModels.LoginResponse.self,
//                                failure: ServiceProviderError.invalidEmailPassword).eraseToAnyPublisher()
//                }
//                else if openSessionResponse.status == "FAIL_QUICK_OPEN_STATUS" {
//                    return Fail(outputType: SportRadarModels.LoginResponse.self,
//                                failure: ServiceProviderError.quickSignUpIncomplete).eraseToAnyPublisher()
//                }
//                else if openSessionResponse.status == "SUCCESS", let launchToken = openSessionResponse.launchToken {
//                    self.cacheLaunchKey(launchToken)
//                    return Just(loginResponse)
//                        .setFailureType(to: ServiceProviderError.self)
//                        .eraseToAnyPublisher()
//                }
//                return Fail(outputType: SportRadarModels.LoginResponse.self,
//                            failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
//            })
//            .eraseToAnyPublisher()
    }
    
    
}
