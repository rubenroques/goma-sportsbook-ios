//
//  GomaSuggestedBets.swift
//  Sportsbook
//
//  Created by André Lascas on 09/12/2021.
//

import Foundation

struct GomaSuggestedBets: Codable {

    let matchId: Int
    let matchName: String
    let competitionName: String
    let bettingType: Int
    let eventPartId: Int
    let venueId: Int
    let bettingName: String
    let bettingOption: String
    let paramFloat: String?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case matchName = "match_name"
        case competitionName = "competition_name"
        case bettingType = "betting_type"
        case eventPartId = "event_part_id"
        case venueId = "venue_id"
        case bettingName = "betting_name"
        case bettingOption = "betting_option"
        case paramFloat = "param_float"
    }

}
