//
//  SportRadarAnalyticsProvider.swift
//
//
//  Created by Ruben Roques on 14/05/2024.
//

import Foundation
import Combine

struct SportRadarAnalyticsProvider: AnalyticsProvider {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
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
                if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                    // SUCCESS
                    return "{\"status\":\"OK\"}".data(using: .utf8) ?? Data()
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
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
            .decode(type: T.self, decoder: self.decoder)
            .mapError { error in
                // Debug helper
                print("ServiceProvider-NetworkManager Error \(error)")

                if "\(error)" == "emptyData" {
                    return ServiceProviderError.emptyData
                }

                if let typedError = error as? ServiceProviderError,
                    case .resourceUnavailableOrDeleted = typedError {
                    return typedError
                }

                if let decodingError = error as? DecodingError {
                    let errorMessage = "\(decodingError)"
                    return ServiceProviderError.decodingError(message: errorMessage)
                }

                return ServiceProviderError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    func trackEvent(_ event: AnalyticsEvent, userIdentifer: String?) -> AnyPublisher<Void, ServiceProviderError> {

        guard
            let typeEvent = event as? VaixAnalyticsEvent
        else {
            return Fail(outputType: Void.self, failure: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        let endpoint = VaixAPIClient.analyticsTrackEvent(event: typeEvent, userId: userIdentifer ?? "0")
        let publisher: AnyPublisher<BasicResponse, ServiceProviderError> = self.request(endpoint)

        return publisher
            .map({ basicResponse -> Void in
                return ()
            })
            .eraseToAnyPublisher()
    }
}
