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

    func bettingOfferPublisher(withId id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>?

    func matchesInfoForMatchListPublisher() ->
    CurrentValueSubject<[String], Never>?

    func hasMatchesInfoForMatch(withId id: String) -> Bool

    func matchesInfoForMatchList() -> [String: Set<String>]

    func matchesInfoList() -> [String: EveryMatrix.MatchInfo]
}
