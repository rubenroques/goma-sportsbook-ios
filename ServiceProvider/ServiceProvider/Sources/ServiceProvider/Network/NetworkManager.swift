//
//  File.swift
//  
//
//  Created by Ruben Roques on 25/10/2022.
//

import Foundation
import Combine

class NetworkManager {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }

    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
       
        guard
            let request = endpoint.request()
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
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw ServiceProviderError.unknown
                }
                return result.data
            }
            // Debug helper
//            .handleEvents(receiveOutput: { data in
//                print("ServiceProvider-NetworkManager [[ requesting ]] ", request,
//                      " [[ response ]] ", String(data: data, encoding: .utf8) ?? "!?" )
//            })
            .decode(type: T.self, decoder: self.decoder)
            .mapError { error in
                // Debug helper
                // print("ServiceProvider-NetworkManager Error \(error)")
                return ServiceProviderError.invalidResponse
            }
            .eraseToAnyPublisher()
    }
    
}
