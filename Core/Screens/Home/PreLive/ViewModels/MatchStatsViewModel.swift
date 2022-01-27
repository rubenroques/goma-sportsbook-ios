//
//  MatchStatsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/01/2022.
//

import Foundation
import Combine

enum MatchStatsType {
    case lastMatchesResults
    case headToHeadResult
    case noStats
}

class MatchStatsViewModel {

    var statsTypePublisher: CurrentValueSubject<JSON?, Never> = .init(nil)

    private var match: Match
    private var requestMatchStatsCancellable: AnyCancellable?

    init(match: Match) {
        self.match = match

        self.requestStats()
    }

    private func requestStats() {

        let deviceId = Env.deviceId
        self.requestMatchStatsCancellable = Env.gomaNetworkClient.requestMatchStats(deviceId: deviceId, matchId: self.match.id)
            .sink { completion in
                print("RequestMatchStats completion ", completion)
            } receiveValue: { [weak self] json in
                if !json.isEmpty {
                    self?.statsTypePublisher.send(json)
                }
                else {
                    print("RequestMatchStats empty stats")
                }
            }
    }

}
