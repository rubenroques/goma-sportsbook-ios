//
//  AggregatorStore.swift
//  Sportsbook
//
//  Created by André Lascas on 15/02/2022.
//

import Foundation
import Combine

protocol AggregatorStore {
    func marketPublisher(withId id: String) -> CurrentValueSubject<EveryMatrix.Market, Never>?

    func bettingOfferPublisher(_ id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>?

    func matchesInfoForMatchListPublisher() ->
    CurrentValueSubject<[String], Never>?

    func hasMatchesInfoForMatch(_ id: String) -> Bool

    func matchesInfoForMatchList() -> [String: Set<String>]

    func matchesInfoList() -> [String: EveryMatrix.MatchInfo]
}
