//
//  BettingConnector.swift
//
//
//  Created by Ruben Roques on 12/11/2022.
//

import Foundation
import Combine

class BettingConnector: Connector {

    var token: BettingSessionAccessToken?
    
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return connectionStateSubject.eraseToAnyPublisher()
    }

    var requestTokenRefresher: () -> AnyPublisher<String?, Never> = { Just(Optional<String>.none).eraseToAnyPublisher() }

    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss'.0'" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    func clearSessionKey() {
        return self.token = nil
    }
    
    func saveSessionKey(_ sessionKey: String) {
        return self.token = BettingSessionAccessToken(hash: sessionKey)
    }
    
    func retrieveSessionKey() -> String? {
        return self.token?.hash
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        var additionalHeaders: HTTP.Headers?
        if endpoint.requireSessionKey {
            if let sessionKey = self.retrieveSessionKey() {
                additionalHeaders = ["Authorization": sessionKey]
            }
            else {
                return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
            }
        }
        
        guard
            let request = endpoint.request(aditionalHeaders: additionalHeaders)
        else {
            let error = ServiceProviderError.invalidRequestFormat
            return Fail<T, ServiceProviderError>(error: error).eraseToAnyPublisher()
        }

        print("Betting request: \(request.cURL(pretty: true))")
        
        return self.session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw ServiceProviderError.unauthorized
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                    throw ServiceProviderError.forbidden
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 500 {
                    throw ServiceProviderError.internalServerError
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw ServiceProviderError.unknown
                }
                return result.data
            }
            .decode(type: T.self, decoder: self.decoder)
            .mapError({ error -> ServiceProviderError in
                if let typedError = error as? ServiceProviderError {
                    return typedError
                }
                else if let decodingError = error as? DecodingError {
                    let errorMessage = "\(decodingError)"
                    return ServiceProviderError.decodingError(message: errorMessage)
                }
                return ServiceProviderError.invalidResponse
            })
            .catch({ [weak self] (error: ServiceProviderError) -> AnyPublisher<T, ServiceProviderError> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher()  }
                if case ServiceProviderError.unauthorized = error {
                    return self.requestTokenRefresher()
                        .setFailureType(to: ServiceProviderError.self)
                        .flatMap({ [weak self] (newToken: String?) -> AnyPublisher<T, ServiceProviderError> in
                            guard
                                let weakSelf = self,
                                let newTokenValue = newToken
                            else {
                                return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                            }
                            weakSelf.saveSessionKey(newTokenValue)
                            return weakSelf.request(endpoint).eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                }
                else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
        
}

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            let escaped = bodyString.replacingOccurrences(of: "'", with: "'\\''")   // important to escape ' so it become '\'' that would work in command line
            data = "--data '\(escaped)'"
        }
        cURL += method + url + header + data
        cURL = cURL.replacingOccurrences(of: "\n", with: "")
        return cURL
    }
}
