//
//  Event.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import SharedModels

public typealias Events = [Event]

public class Event: Codable, Hashable, Identifiable {

    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sport: SportType
    public var sportIdCode: String?

    public var homeTeamScore: Int?
    public var awayTeamScore: Int?
    public var homeTeamLogoUrl: String?
    public var awayTeamLogoUrl: String?

    public var competitionId: String
    public var competitionName: String
    public var startDate: Date

    public var markets: [Market]

    public var venueCountry: Country?
    public var numberMarkets: Int?

    public var name: String?

    public var status: EventStatus?

    public var matchTime: String?

    public var promoImageURL: String?
    public var oldMainMarketId: String?

    public var trackableReference: String?

    public var activePlayerServing: ActivePlayerServe?

    public var boostedMarket: Market?

    public var type: EventType {
        if self.homeTeamName.isEmpty && self.awayTeamName.isEmpty {
            return .competition
        }
        else {
            return .match
        }
    }

    public var scores: [String: Score]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeTeamName = "homeName"
        case awayTeamName = "awayName"
        case competitionId = "competitionId"
        case competitionName = "competitionName"
        case sport = "sport"
        case sportIdCode = "sportIdCode"
        case startDate = "startDate"
        case markets = "markets"
        case venueCountry = "venueCountry"
        case numberMarkets = "numMarkets"
        case scores = "scores"
        case trackableReference = "trackableReference"
        case activePlayerServing = "activePlayerServing"
        case homeTeamLogoUrl = "homeTeamLogoUrl"
        case awayTeamLogoUrl = "awayTeamLogoUrl"
        case promoImageURL = "promoImageURL"
        case boostedMarket = "boostedMarket"
    }

    public init(id: String,
                homeTeamName: String,
                awayTeamName: String,
                homeTeamScore: Int?,
                awayTeamScore: Int?,
                homeTeamLogoUrl: String?,
                awayTeamLogoUrl: String?,
                competitionId: String,
                competitionName: String,
                sport: SportType,
                sportIdCode: String?,
                startDate: Date,
                markets: [Market],
                venueCountry: Country? = nil,
                numberMarkets: Int? = nil,
                name: String? = nil,
                trackableReference: String?,
                status: EventStatus?,
                matchTime: String?,
                activePlayerServing: ActivePlayerServe?,
                boostedMarket: Market?,
                promoImageURL: String?,
                scores: [String: Score]) {

        self.id = id
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName

        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.homeTeamLogoUrl = homeTeamLogoUrl
        self.awayTeamLogoUrl = awayTeamLogoUrl

        self.competitionId = competitionId
        self.competitionName = competitionName

        self.sport = sport
        self.sportIdCode = sportIdCode

        self.trackableReference = trackableReference

        self.startDate = startDate
        self.markets = markets
        self.venueCountry = venueCountry
        self.numberMarkets = numberMarkets

        self.name = name
        self.status = status
        self.matchTime = matchTime

        self.promoImageURL = promoImageURL
        self.oldMainMarketId = nil

        self.activePlayerServing = activePlayerServing

        self.boostedMarket = boostedMarket

        self.scores = scores
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.homeTeamName = try container.decode(String.self, forKey: .homeTeamName)
        self.awayTeamName = try container.decode(String.self, forKey: .awayTeamName)
        self.competitionId = try container.decode(String.self, forKey: .competitionId)
        self.competitionName = try container.decode(String.self, forKey: .competitionName)
        self.sport = try container.decode(SportType.self, forKey: .sport)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.markets = try container.decode([Market].self, forKey: .markets)
        self.venueCountry = try container.decodeIfPresent(Country.self, forKey: .venueCountry)
        self.numberMarkets = try container.decodeIfPresent(Int.self, forKey: .numberMarkets)
        self.sportIdCode = try container.decodeIfPresent(String.self, forKey: .sportIdCode)
        self.trackableReference = try container.decodeIfPresent(String.self, forKey: .trackableReference)
        self.activePlayerServing = try container.decodeIfPresent(ActivePlayerServe.self, forKey: .activePlayerServing)
        self.boostedMarket = try container.decodeIfPresent(Market.self, forKey: .boostedMarket)
        self.scores = (try? container.decode([String: Score].self, forKey: .scores)) ?? [:]

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.homeTeamName, forKey: .homeTeamName)
        try container.encode(self.awayTeamName, forKey: .awayTeamName)
        try container.encode(self.competitionId, forKey: .competitionId)
        try container.encode(self.competitionName, forKey: .competitionName)
        try container.encode(self.sport, forKey: .sport)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.markets, forKey: .markets)
        try container.encodeIfPresent(self.venueCountry, forKey: .venueCountry)
        try container.encodeIfPresent(self.numberMarkets, forKey: .numberMarkets)
        try container.encodeIfPresent(self.sportIdCode, forKey: .sportIdCode)
        try container.encodeIfPresent(self.trackableReference, forKey: .trackableReference)
        try container.encodeIfPresent(self.activePlayerServing, forKey: .activePlayerServing)
        try container.encodeIfPresent(self.boostedMarket, forKey: .boostedMarket)
    }

    public static func == (lhs: Event, rhs: Event) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.homeTeamName == rhs.homeTeamName &&
        lhs.awayTeamName == rhs.awayTeamName &&
        lhs.homeTeamScore == rhs.homeTeamScore &&
        lhs.awayTeamScore == rhs.awayTeamScore &&
        lhs.competitionId == rhs.competitionId &&
        lhs.competitionName == rhs.competitionName &&
        lhs.sport == rhs.sport &&
        lhs.startDate == rhs.startDate &&
        lhs.markets == rhs.markets &&
        lhs.venueCountry == rhs.venueCountry &&
        lhs.numberMarkets == rhs.numberMarkets &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status &&
        lhs.matchTime == rhs.matchTime &&
        lhs.trackableReference == rhs.trackableReference &&
        lhs.scores == rhs.scores &&
        lhs.activePlayerServing == rhs.activePlayerServing
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(homeTeamName)
        hasher.combine(awayTeamName)
        hasher.combine(homeTeamScore)
        hasher.combine(awayTeamScore)
        hasher.combine(competitionId)
        hasher.combine(competitionName)
        hasher.combine(sport)
        hasher.combine(startDate)
        hasher.combine(markets)
        hasher.combine(venueCountry)
        hasher.combine(numberMarkets)
        hasher.combine(name)
        hasher.combine(status)
        hasher.combine(matchTime)
        hasher.combine(trackableReference)
        hasher.combine(scores)
        hasher.combine(activePlayerServing)
    }
}
