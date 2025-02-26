//
//  RecommendedBetBuilders.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation
import SharedModels

public struct RecommendedBetBuilders: Codable {
    public var recommendations: [RecommendedBetBuilder]

    public init(recommendations: [RecommendedBetBuilder]) {
        self.recommendations = recommendations
    }
}

public struct RecommendedBetBuilder: Codable {
    public var selections: [RecommendedBetBuilderSelection]
    public var totalOdds: Double

    public init(selections: [RecommendedBetBuilderSelection], totalOdds: Double) {
        self.selections = selections
        self.totalOdds = totalOdds
    }
}

public struct RecommendedBetBuilderSelection: Codable {
    public var country: Country?
    public var competitionName: String

    public var eventId: String
    public var marketId: String
    public var outcomeId: String

    public var marketName: String
    public var outcomeName: String?

    public var participantIds: [String]
    public var participants: [String]
    public var sport: SportType?
    public var odd: Double

    // Additional properties
    public var leagueId: String
    public var sportId: String
    public var countryId: String
    public var homeParticipantId: String?
    public var awayParticipantId: String?

    public var eventName: String {
        return (participants.first ?? "") + " x " + (participants.last ?? "")
    }

    public init(
        countryName: String,
        competitionName: String,
        eventId: String,
        marketId: String,
        outcomeId: String,
        marketName: String,
        outcomeName: String?,
        participantIds: [String],
        participants: [String],
        sport: SportType? = nil,
        odd: Double,
        leagueId: String,
        sportId: String,
        countryId: String,
        homeParticipantId: String?,
        awayParticipantId: String?
    ) {
        self.competitionName = competitionName

        self.eventId = eventId
        self.marketId = marketId
        self.outcomeId = outcomeId

        self.marketName = marketName
        self.outcomeName = outcomeName

        self.participantIds = participantIds
        self.participants = participants
        self.sport = sport
        self.odd = odd

        // Set additional properties
        self.leagueId = leagueId
        self.sportId = sportId
        self.countryId = countryId
        self.homeParticipantId = homeParticipantId
        self.awayParticipantId = awayParticipantId

        self.country = Country.country(withName: countryName)
    }
}
