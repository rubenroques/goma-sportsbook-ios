//
//  MatchLiveData.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

struct MatchLiveData: Equatable {
    
    var id: String
    var homeScore: Int?
    var awayScore: Int?
    var matchTime: String?
    var status: Match.Status?
    var detailedScores: [String: Score]?
    var activePlayerServing: Match.ActivePlayerServe?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeScore = "homeScore"
        case awayScore = "awayScore"
        case matchTime = "matchTime"
        case status = "status"
        case detailedScores
    }
    
}
