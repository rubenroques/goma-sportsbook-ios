//
//  File.swift
//  
//
//  Created by Ruben Roques on 25/10/2022.
//

import Foundation
import Combine

class SportRadarRestConnector {
    
    private let session: URLSession
    private let decoder: JSONDecoder

    var token: SportRadarSessionAccessToken?
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
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
            //let request = endpoint.request()
            let request = endpoint.request(aditionalHeaders: additionalHeaders)
        else {
            let error = ServiceProviderError.invalidRequestFormat
            return AnyPublisher(Fail<T, ServiceProviderError>(error: error))
        }
        return self.session.dataTaskPublisher(for: request)
            .tryMap { result in
                if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw ServiceProviderError.unauthorized
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                    throw ServiceProviderError.forbidden
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    // SUCCESS EMPTY DATA
                    throw ServiceProviderError.emptyData
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw ServiceProviderError.unknown
                }
                return result.data
            }
            // Debug helper
            .handleEvents(receiveOutput: { data in
                print("ServiceProvider-NetworkManager [[ requesting ]] ", request,
                      " [[ response ]] ", String(data: data, encoding: .utf8) ?? "!?" )
            })
            .decode(type: T.self, decoder: self.decoder)
            .mapError { error in
                // Debug helper
                print("ServiceProvider-NetworkManager Error \(error)")
                
                if "\(error)" == "emptyData" {
                    return ServiceProviderError.emptyData
                }

                return ServiceProviderError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    func clearSessionKey() {
        return self.token = nil
    }

    func saveSessionKey(_ sessionKey: String) {
        return self.token = SportRadarSessionAccessToken(hash: sessionKey)
    }

    func retrieveSessionKey() -> String? {
        return self.token?.hash
    }
}
