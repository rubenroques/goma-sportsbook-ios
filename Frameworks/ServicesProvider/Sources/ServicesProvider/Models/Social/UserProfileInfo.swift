//
//  UserProfileInfo.swift
//
//
//  Created by André Lascas on 26/02/2024.
//

import Foundation


public struct UserProfileInfo: Codable {

    public var name: String
    public var avatar: String?
    public var following: Int
    public var followers: Int
    public var rankings: UserProfileRanking
    public var sportsPerc: [UserProfileSportsData]

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case avatar = "avatar"
        case following = "following"
        case followers = "followers"
        case rankings = "rankings"
        case sportsPerc = "sports_perc"
    }
}

public struct UserProfileRanking: Codable {

    public var consecutiveWins: Int
    public var accumulatedWins: Double
    public var highestOdd: Double

    enum CodingKeys: String, CodingKey {
        case consecutiveWins = "consecutive_wins"
        case accumulatedWins = "accumulated_wins"
        case highestOdd = "highest_odd"
    }
}

public struct UserProfileSportsData: Codable {
    public var sportId: Int
    public var percentage: Double
    public var sportIdIcon: String

    enum CodingKeys: String, CodingKey {
        case sportId = "sport_id"
        case percentage = "percentage"
        case sportIdIcon = "sport_id_icon"
    }
}
