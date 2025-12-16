//
//  RankingCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2022.
//

import Foundation

class RankingCellViewModel {
    private var ranking: RankingTip

    init(ranking: RankingTip) {
        self.ranking = ranking
    }

    func getRanking() -> String {
        return "\(self.ranking.position)"
    }

    func getUsername() -> String {
        return self.ranking.username
    }

    func getRankingScore() -> String {
        let rankingIsInteger = floor(self.ranking.result) == self.ranking.result

        let valueString = rankingIsInteger ? "\(Int(self.ranking.result))" : "\(String(format: "%.2f", self.ranking.result))"

        return valueString
    }

    func getUserId() -> String {
        return "\(self.ranking.userId)"
    }
}

struct Ranking {
    var id: Int
    var ranking: Int
    var username: String
    var score: Double

    init(id: Int, ranking: Int, username: String, score: Double) {
        self.id = id
        self.ranking = ranking
        self.username = username
        self.score = score
    }
}
