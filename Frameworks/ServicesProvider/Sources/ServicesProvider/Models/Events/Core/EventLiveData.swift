//
//  EventLiveData.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct EventLiveData: Equatable {

    public var id: String
    public var homeScore: Int?
    public var awayScore: Int?
    public var matchTime: String?
    public var status: EventStatus?
    public var detailedScores: [String: Score]?
    public var activePlayerServing: ActivePlayerServe?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeScore = "homeScore"
        case awayScore = "awayScore"
        case matchTime = "matchTime"
        case status = "status"
        case detailedScores = "detailedScores"
        case activePlayerServing = "activePlayerServing"
    }

    public init(id: String,
                homeScore: Int?,
                awayScore: Int?,
                matchTime: String?,
                status: EventStatus?,
                detailedScores: [String: Score]?,
                activePlayerServing: ActivePlayerServe?)
    {
        self.id = id
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.matchTime = matchTime
        self.status = status
        self.detailedScores = detailedScores
        self.activePlayerServing = activePlayerServing
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        homeScore = try container.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try container.decodeIfPresent(Int.self, forKey: .awayScore)
        matchTime = try container.decodeIfPresent(String.self, forKey: .matchTime)

        // Decode the status based on the "status" key
        let statusValue = try container.decode(String.self, forKey: .status)
        status = EventStatus(value: statusValue)

        detailedScores = try container.decodeIfPresent([String: Score].self, forKey: .detailedScores)
        activePlayerServing = try container.decodeIfPresent(ActivePlayerServe.self, forKey: .activePlayerServing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(homeScore, forKey: .homeScore)
        try container.encodeIfPresent(awayScore, forKey: .awayScore)
        try container.encodeIfPresent(matchTime, forKey: .matchTime)
        try container.encodeIfPresent(detailedScores, forKey: .detailedScores)
        try container.encodeIfPresent(activePlayerServing, forKey: .activePlayerServing)

        if let status = self.status {
            switch status {
            case .unknown:
                try container.encode("unknown", forKey: .status)
            case .notStarted:
                try container.encode("not_started", forKey: .status)
            case .inProgress(let value):
                try container.encode(value, forKey: .status)
            case .ended:
                try container.encode("ended", forKey: .status)
            }
        }
    }

}
