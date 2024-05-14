//
//  SecundaryMarketsService.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/11/2023.
//

import Foundation
import Combine

public struct SecundaryMarketsService {
    
    private static let subject = CurrentValueSubject<SecundarySportMarkets, Error>([])
    private static var isRequestMade = false
    private static var cancellables = Set<AnyCancellable>()
    
    public static func fetchSecundaryMarkets() -> AnyPublisher<SecundarySportMarkets, Error> {
        
        guard let urlString = TargetVariables.secundaryMarketSpecsUrl, let url = URL(string: urlString) else {
            let errorPublisher = Fail<SecundarySportMarkets, Error>(error: URLError(.badURL)).eraseToAnyPublisher()
            return errorPublisher
        }
        
        if !self.isRequestMade {
            self.isRequestMade = true
            
            var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 5)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["Content-Type": "application/json", "Accept": "application/json"]
            
            URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: SecundarySportMarkets.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.subject.send(completion: .failure(error))
                        self.isRequestMade = false
                    }
                }, receiveValue: { secundaryMarkets in
                    self.subject.send(secundaryMarkets)
                })
                .store(in: &cancellables) // Make sure to have a Set<AnyCancellable> to store this subscription
        }
        
        return subject.eraseToAnyPublisher()
        
    }
}
