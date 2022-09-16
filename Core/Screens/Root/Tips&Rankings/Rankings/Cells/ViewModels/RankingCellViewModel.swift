//
//  RankingCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2022.
//

import Foundation

class RankingCellViewModel {
    private var ranking: Ranking

    init(ranking: Ranking) {
        self.ranking = ranking
    }

    func getRanking() -> String {
        return "\(self.ranking.ranking)"
    }

    func getUsername() -> String {
        return self.ranking.username
    }

    func getRankingScore() -> String {
        return "\(self.ranking.score)"
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
