//
//  UrlSchemaManager.swift
//  Sportsbook
//
//  Created by André Lascas on 03/02/2022.
//

import Foundation
import Combine

class URLSchemaManager {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var isSharedBet: Bool = false

    // MARK: Public Properties
    var redirectPublisher: CurrentValueSubject<[String: String], Never>

    var ticketPublisher: AnyCancellable?
    var shouldShowBetslipPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and Cycle
    init() {
        self.redirectPublisher = .init([:])
    }

    // MARK: General functions
    func setRedirect(subject: [String: String]) {
        self.redirectPublisher.value = subject
    }

    // Bet shares related functions
    func getBetslipTicketData(betToken: String) {
        self.isSharedBet = true

//        let betDataRoute = em .getSharedBetData(betToken: betToken)
//
//        Env. em  .getModel(router: betDataRoute, decodingType: SharedBetDataResponse.self)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let apiError):
//                    switch apiError {
//                    case .requestError(let value):
//                        print("Bet token request error: \(value)")
//                    case .notConnected:
//                        ()
//                    default:
//                        ()
//                    }
//                case .finished:
//                    ()
//                }
//            },
//                  receiveValue: { [weak self] betDataResponse in
//                self?.addBetDataTickets(betData: betDataResponse.sharedBetData)
//
//            })
//            .store(in: &cancellables)
        
    }

}
