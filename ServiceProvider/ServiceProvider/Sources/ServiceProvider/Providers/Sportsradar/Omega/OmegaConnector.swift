//
//  OmegaConnector.swift
//  
//
//  Created by Ruben Roques on 25/10/2022.
//

import Foundation
import Combine

class OmegaConnector: Connector {
    
    var token: SessionAccessToken?
    
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Error> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
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
    
    func connect() {
        
    }
    
    func refreshConnection() {
        
    }
    
    func disconnect() {
        
    }
    
    private func clearCacheSessionKey() {
        return self.token = nil
    }
    
    private func cacheSessionKey(_ sessionKey: String) {
        return self.token = OmegaSessionAccessToken(hash: sessionKey)
    }
    
    private func retrieveSessionKey() -> String? {
        return self.token?.hash
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
                            return Fail(outputType: T.self, failure: ServiceProviderError.unknown)
                                .eraseToAnyPublisher()
                        }
                        return self.request(endpoint)
                    }
                    .eraseToAnyPublisher()
            }
            else {
                return Fail(outputType: T.self, failure: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
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
            .handleEvents(receiveOutput: { data in
                print("ServiceProvider-NetworkManager [[ requesting ]] ", request,
                      " [[ response ]] ", String(data: data, encoding: .utf8) ?? "!?" )
            })
            .flatMap({ [weak self] (data: Data) -> AnyPublisher<T, ServiceProviderError> in
                guard
                    let self = self
                else {
                    return Fail(outputType: T.self, failure: ServiceProviderError.unknown)
                        .eraseToAnyPublisher()
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
                            print("ServiceProvider-NetworkManager Decoding Error \(error)")
                            return Fail(outputType: T.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
                        }
                    }
                }
                else {
                    return Fail(outputType: T.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    func login(username: String, password: String) -> AnyPublisher<SportRadarModels.LoginResponse, ServiceProviderError> {
        
        guard
            let request = OmegaAPIClient.login(username: username, password: password).request()
        else {
            return Fail<SportRadarModels.LoginResponse, ServiceProviderError>(error: .invalidRequestFormat)
                .eraseToAnyPublisher()
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
                // Debug helper
                print("ServiceProvider-NetworkManager Error \(error)")
                return ServiceProviderError.invalidResponse
            }
            .flatMap({ loginResponse -> AnyPublisher<SportRadarModels.LoginResponse, ServiceProviderError> in
                if loginResponse.status == "FAIL_UN_PW" {
                    self.logout()
                    return Fail(outputType: SportRadarModels.LoginResponse.self,
                                failure: ServiceProviderError.invalidEmailPassword).eraseToAnyPublisher()
                }
                else if loginResponse.status == "FAIL_QUICK_OPEN_STATUS" {
                    return Fail(outputType: SportRadarModels.LoginResponse.self,
                                failure: ServiceProviderError.quickSignUpIncomplete).eraseToAnyPublisher()
                }
                else if loginResponse.status == "SUCCESS", let sessionKey = loginResponse.sessionKey {
                    self.cacheSessionKey(sessionKey)
                    self.sessionCredentials = OmegaSessionCredentials(username: username, password: password)
                    return Just(loginResponse)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                }
                return Fail(outputType: SportRadarModels.LoginResponse.self,
                            failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    

    func logout() {
        self.token = nil
        self.sessionCredentials = nil
    }
    
}
