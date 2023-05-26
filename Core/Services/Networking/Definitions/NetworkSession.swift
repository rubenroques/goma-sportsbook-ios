//
//  NetworkSession.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
//

import Foundation
import Combine

protocol NetworkSession: AnyObject {
    func publisher(for url: URL, token: AuthToken?) -> AnyPublisher<Data, Error>
    func publisher(for request: URLRequest, token: AuthToken?) -> AnyPublisher<Data, Error>
}

extension URLSession: NetworkSession {

    func publisher(for url: URL, token: AuthToken?) -> AnyPublisher<Data, Error> {
        self.publisher(for: URLRequest(url: url), token: token)
    }

    func publisher(for request: URLRequest, token: AuthToken?) -> AnyPublisher<Data, Error> {

        var request = request

        if let token = token {
            request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
        }

        return dataTaskPublisher(for: request)
            .tryMap { result in

                print("// ===== GOMA REQUEST")
                dump(request)
                print(String(data: result.data, encoding: .utf8) ?? "")
                print(" GOMA REQUEST === //")

                if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw NetworkError(errors: [.unauthorized])
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                    throw NetworkError(errors: [.forbidden])
                }
                else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    throw NetworkError(errors: [.unknown])
                }
                return result.data
            }
            .eraseToAnyPublisher()
    }

}
