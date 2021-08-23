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
           // .delay(for: .seconds(10), scheduler: DispatchQueue.main)
            .tryMap({ result in

                print("=====================")
                print(request, request.httpMethod, request.httpBody, request.allHTTPHeaderFields)
                print(String(data:result.data, encoding: .utf8) ?? "")
                if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    //Unauthorized
                    print("throw unauthorized")
                    throw NetworkErrorResponse(errors: [.unauthorized])
                } else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                    print("throw forbidden")
                    throw NetworkErrorResponse(errors: [.forbidden])
                } else if let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("throw unknown")
                    throw NetworkErrorResponse(errors: [.unknown])
                }

                return result.data
            })
            .eraseToAnyPublisher()
    }

}
