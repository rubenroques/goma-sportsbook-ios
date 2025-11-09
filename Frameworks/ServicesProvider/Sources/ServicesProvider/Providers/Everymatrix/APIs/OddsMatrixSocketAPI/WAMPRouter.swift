//
//  Router.swift
//  EveryMatrix Provider
//
//  Created by Ruben Roques on 21/03/2025.
//

import Foundation

// swiftlint:disable type_body_length
enum WAMPRouter {
    // MARK: - Session
    case sessionStateChange

    // MARK: - RPC Endpoints
    // Operator & General Info
    case getOperatorInfo
    
    case getClientIdentity

    // Locations & Tournaments
    case getLocations(language: String, sortByPopularity: Bool = false)
    case getCustomTournaments(language: String, sportId: String)
    case getTournaments(language: String, sportId: String, liveStatus: String = "BOTH", sortByPopularity: Bool = true)
    case getPopularTournaments(language: String, sportId: String, liveStatus: String = "BOTH", sortByPopularity: Bool = true, maxResults: Int = 10)

    // Matches & Odds
    case getMatchDetails(language: String, matchId: String)
    case getMatchOdds(language: String, matchId: String, bettingTypeId: String)
    case matchWithMainMarkets(operatorId: String, language: String, matchId: String, mainMarketsCount: Int = 1)

    // Betting Offer Reference (for Rebet)
    case getBettingOfferReference(outcomeId: String)

    // Betting Offer (for single outcome fetch)
    case getBettingOffer(operatorId: String, language: String, bettingOfferId: String)

    // Betting Options V2 (validate bet selections and get constraints)
    case getBettingOptionsV2(type: BetGroupingType, selections: [EveryMatrix.BettingOptionsCalculateSelection], stakeAmount: Double?, language: String)

    // Shared Bets
    case getSharedBetTokens(betId: String)
    case getSharedBetData(betToken: String)

    // Search
    case searchV2(language: String, limit: Int, query: String, eventStatuses: [Int], eventTypes: [String], include: [String], bettingTypeIds: [Int], dataWithoutOdds: Bool)
    case multiSearch(language: String, limit: Int, query: String, eventTypes: [String], include: [String])

    // MARK: - Subscription Publishers
    // Core Topics
    case sportsInitialDump(topic: String)
    case sportsPublisher(operatorId: String, language: String)
    case sportsStatus(operatorId: String, language: String, sportId: String)
    case oddsMatch(operatorId: String, language: String, matchId: String)

    // Betting Offer
    case bettingOfferPublisher(operatorId: String, language: String, bettingOfferId: String)

    // Matches
    case liveMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)
    case popularMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)
    case todayMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)
    case todayMatchesFilterPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int, timeRange: String)
    case customMatchesAggregatorPublisher(
        operatorId: String,
        language: String,
        sportId: String,
        locationId: String,
        tournamentId: String,
        hoursInterval: String,
        sortEventsBy: String,
        liveStatus: String,
        eventLimit: Int,
        mainMarketsLimit: Int,
        optionalUserId: String?
    )
    case matchDetailsPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketGroupsPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketGroupDetailsPublisher(operatorId: String, language: String, matchId: String, marketGroupName: String)
    case matchDetailsAggregatorPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketOdds(operatorId: String, language: String, matchId: String, bettingType: String, eventPartId: String)
    case matchBalancedMarketOdds(operatorId: String, language: String, matchId: String, bettingType: String, eventPartId: String)
    case eventPartScoresPublisher(operatorId: String, language: String, matchId: String)
    case competitionsMatchesPublisher(operatorId: String, language: String, sportId: String, events: [String])

    // Tournaments & Locations
    case locationsPublisher(operatorId: String, language: String, sportId: String)
    case tournamentsPublisher(operatorId: String, language: String, sportId: String)
    case popularTournamentsPublisher(operatorId: String, language: String, sportId: String, tournamentsCount: Int)
    case upcomingTournamentsPublisher(operatorId: String, language: String, sportId: String)
    case liveSportsPublisher(operatorId: String, language: String)
    case eventCategoryBySport(operatorId: String, language: String, sportId: String)

    // UI & Marketing
    case bannersInfoPublisher(operatorId: String, language: String)

    // User & Account
    case favoriteMatchesPublisher(operatorId: String, language: String, userId: String)
    case accountBalancePublisher
    case cashoutPublisher(operatorId: String, language: String, betId: String)

    // Tournament Odds
    case tournamentOddsPublisher(operatorId: String, language: String, eventId: String)

    // MARK: - Data Fetch (Payload‑Based)
    case eventsDetails(operatorId: String, language: String, events: [String])

    case disciplines(language: String)
    case locations(payload: [String: Any]?)
    case tournaments(payload: [String: Any]?)
    case popularTournaments(payload: [String: Any]?)
    case matches(payload: [String: Any]?)
    case popularMatches(payload: [String: Any]?)
    case todayMatches(payload: [String: Any]?)
    case nextMatches(payload: [String: Any]?)
    case events(payload: [String: Any]?)
    case odds(payload: [String: Any]?)

    var procedure: String {
        switch self {

        // RPCs
        case .getOperatorInfo:
            return "/sports#operatorInfo"
        case .getClientIdentity:
            return "/connection#getClientIdentity"
            
        case .getMatchDetails:
            return "/sports#matches"
        case .matchWithMainMarkets:
            return "/sports#initialDump"
        case .getLocations:
            return "/sports#locations"
        case .getCustomTournaments:
            return "/sports#customEvents"
        case .getTournaments:
            return "/sports#tournaments"
        case .getPopularTournaments:
            return "/sports#popularTournaments"
        case .getMatchOdds:
            return "/sports#odds"
        case .getBettingOfferReference:
            return "/sports#oddsByOutcomes"
        case .getBettingOffer:
            return "/sports#initialDump"
        case .searchV2:
            return "/sports#searchV2"
        case .multiSearch:
            return "/sports#multiSearch"
        case .getBettingOptionsV2:
            return "/sports#bettingOptionsV2"
        case .getSharedBetTokens:
            return "/sports#sharedBetTokens"
        case .getSharedBetData:
            return "/sports#sharedBetData"

        // Subscriptions
        case .sportsInitialDump:
            return "/sports#initialDump"
        case .oddsMatch(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds"
        case .sportsStatus(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/sport/\(sportId)"
        case .sportsPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/disciplines/BOTH/BOTH"

        case .bettingOfferPublisher(let operatorId, let language, let bettingOfferId):
            return "/sports/\(operatorId)/\(language)/bettingOffers/\(bettingOfferId)"

        case .liveMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/live-matches-aggregator-main/\(sportId)/all-locations/default-event-info/\(matchesCount)/\(marketsCount)"

        case .popularMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/popular-matches-aggregator-main/\(sportId)/\(matchesCount)/\(marketsCount)"

        case .todayMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/next-matches-aggregator-main/\(sportId)/\(matchesCount)/\(marketsCount)"
        case .todayMatchesFilterPublisher(let operatorId, let language, let sportId, let matchesCount, let timeRange):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/next-matches-aggregator-main/\(sportId)/\(timeRange)/\(matchesCount)/\(marketsCount)"
        case .customMatchesAggregatorPublisher(let operatorId, let language, let sportId, let locationId, let tournamentId, let hoursInterval, let sortEventsBy, let liveStatus, let eventLimit, let mainMarketsLimit, let optionalUserId):
            if let userId = optionalUserId {
                return "/sports/\(operatorId)/\(language)/custom-matches-aggregator/\(sportId)/\(locationId)/\(tournamentId)/\(hoursInterval)/\(sortEventsBy)/\(liveStatus)/\(eventLimit)/\(mainMarketsLimit)/\(userId)"
            } else {
                return "/sports/\(operatorId)/\(language)/custom-matches-aggregator/\(sportId)/\(locationId)/\(tournamentId)/\(hoursInterval)/\(sortEventsBy)/\(liveStatus)/\(eventLimit)/\(mainMarketsLimit)"
            }
        case .competitionsMatchesPublisher(let operatorId, let language, _, let events):
            let marketsCount = 5
            let eventsIds = events.joined(separator: ",")
            return "/sports/\(operatorId)/\(language)/tournament-aggregator-main/\(eventsIds)/default-event-info/\(marketsCount)"
        
        case .bannersInfoPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/sportsBannerData"
        case .locationsPublisher(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/locations/\(sportId)"
        case .tournamentsPublisher(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/tournaments/\(sportId)"
        case .favoriteMatchesPublisher(let operatorId, let language, let userId):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/user-favorite-events-aggregator/\(userId)/\(marketsCount)"
        case .cashoutPublisher(let operatorId, let language, let betId):
            return "/sports/\(operatorId)/\(language)/cashout/\(betId)"
        case .matchMarketOdds(let operatorId, let language, let matchId, let bettingType, let eventPartId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds/\(bettingType)/\(eventPartId)"
        case .matchBalancedMarketOdds(let operatorId, let language, let matchId, let bettingType, let eventPartId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds/\(bettingType)-\(eventPartId)"

        case .popularTournamentsPublisher(let operatorId, let language, let sportId, let tournamentsCount):
            return "/sports/\(operatorId)/\(language)/popular-tournaments/\(sportId)/\(tournamentsCount)"
        case .upcomingTournamentsPublisher(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/tournaments/\(sportId)"

        case .eventPartScoresPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/eventPartScores/small"

        case .liveSportsPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/disciplines/LIVE/BOTH"

        case .accountBalancePublisher:
            return "/account/balanceChanged"
        case .eventCategoryBySport(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/event-category-by-sport/\(sportId)/BOTH"

        case .matchDetailsPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/match-aggregator-groups-overview/\(matchId)/1"
        case .matchMarketGroupsPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/event/\(matchId)/market-groups"
        case .matchMarketGroupDetailsPublisher(let operatorId, let language, let matchId, let marketGroupName):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds/market-group/\(marketGroupName)"
        case .matchDetailsAggregatorPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/match-aggregator-groups-overview/\(matchId)/1"
        case .tournamentOddsPublisher(let operatorId, let language, let eventId):
            return "/sports/\(operatorId)/\(language)/\(eventId)/tournament-odds"

        case .eventsDetails:
            return "/sports#events"
        
        //
        case .disciplines:
            return "/sports#disciplines"
        case .locations:
            return "/sports#locations"
        case .tournaments:
            return "/sports#tournaments"
        case .popularTournaments:
            return "/sports#popularTournaments"
        case .matches:
            return "/sports#matches"
        case .popularMatches:
            return "/sports#popularMatches"
        case .todayMatches:
            return "/sports#todayMatches"
        case .nextMatches:
            return "/sports#nextMatches"
        case .events:
            return "/sports#events"
        case .odds:
            return "/sports#odds"

        case .sessionStateChange:
            return "/sessionStateChange"

        }
    }
    
    var args: [Any]? {
        return nil
    }
    
    var kwargs: [String: Any]? {
        switch self {

        case .getOperatorInfo:
            return nil
            
        case .getClientIdentity:
            return nil
            
        case .getMatchDetails(let language, let matchId):
            return ["lang": language,
                    "matchId": matchId]
        case .matchWithMainMarkets(let operatorId, let language, let matchId, let mainMarketsCount):
            let topic = "/sports/\(operatorId)/\(language)/match-aggregator/\(matchId)/\(mainMarketsCount)"
            return ["topic": topic]
        case .getLocations(let language, let sortByPopularity):
            let sortByPopularityString = String(sortByPopularity)
            return ["lang": language,
                    "sortByPopularity": sortByPopularityString]

        case .getCustomTournaments(let language, _):
            return ["lang": language]
        case .getTournaments(let language, let sportId, let liveStatus, let sortByPopularity):
            return ["lang": language,
                    "sportId": sportId,
                    "liveStatus": liveStatus,
                    "sortByPopularity": sortByPopularity]
        case .getPopularTournaments(let language, let sportId, let liveStatus, let sortByPopularity, let maxResults):
            return ["lang": language,
                    "sportId": sportId,
                    "liveStatus": liveStatus,
                    "sortByPopularity": sortByPopularity,
                    "maxResults": maxResults]
        
        case .getMatchOdds(let language, let matchId, let bettingTypeId):
            return ["lang": language,
                    "matchId": matchId,
                    "bettingTypeId": bettingTypeId]

        case .getBettingOfferReference(let outcomeId):
            return ["lang": EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
                    "outcomeIds": [outcomeId]]

        case .getBettingOffer(let operatorId, let language, let bettingOfferId):
            let topic = "/sports/\(operatorId)/\(language)/bettingOffers/\(bettingOfferId)"
            return ["topic": topic]

        case .searchV2(let language, let limit, let query, let eventStatuses, let eventTypes, let include, let bettingTypeIds, let dataWithoutOdds):
            return ["lang": language,
                    "limit": limit,
                    "query": query,
                    "eventStatuses": eventStatuses,
                    "eventTypes": eventTypes,
                    "include": include,
                    "bettingTypeIds": bettingTypeIds,
                    "dataWithoutOdds": dataWithoutOdds]
            
        case .multiSearch(let language, let limit, let query, let eventTypes, let include):
            return ["searchMap": [
                "MATCH": [
                    "eventTypes": eventTypes,
                    "query": query,
                    "limit": limit,
                    "mainMarketsLimit": 3,
                    "include": include,
                    "searchQuery": query
                ]
            ],
                    "lang": language
            ]

        case .getBettingOptionsV2(let type, let selections, let stakeAmount, let language):
            // Convert BetGroupingType to String
            let typeString: String
            switch type {
            case .single:
                typeString = "SINGLE"
            case .multiple:
                typeString = "MULTIPLE"
            case .system:
                typeString = "SYSTEM"
            }

            // Convert selections to [[String: Any]]
            let selectionsArray = selections.map { selection -> [String: Any] in
                return [
                    "bettingOfferId": selection.bettingOfferId,
                    "priceValue": selection.priceValue
                ]
            }

            return [
                "type": typeString,
                "systemBetType": NSNull(),
                "eachWay": false,
                "selections": selectionsArray,
                "stakeAmount": stakeAmount ?? NSNull(),
                "terminalType": "DESKTOP",
                "lang": language
            ]

        case .getSharedBetTokens(let betId):
            return ["betId": betId]

        case .getSharedBetData(let betToken):
            return ["betToken": betToken]

        case .eventsDetails(_, let language, let events):
            let data: [String: Any]? = ["lang": language, "eventIds": events]
            return data
         
        // EM Subscription
        case .sportsInitialDump(let topic):
            return ["topic": topic]

        // Others
        case .disciplines(let language):
            return ["lang": language]

        case .locations(payload: let payload):
            return payload
        case .tournaments(payload: let payload):
            return payload
        case .popularTournaments(payload: let payload):
            return payload
        case .matches(payload: let payload):
            return payload
        case .popularMatches(payload: let payload):
            return payload
        case .todayMatches(payload: let payload):
            return payload
        case .nextMatches(payload: let payload):
            return payload
        case .events(payload: let payload):
            return payload
        case.odds(payload: let payload):
            return payload

        default:
            return nil
        }
    }

    var intiailDumpRequest: WAMPRouter? {

        switch self {
        case .bettingOfferPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .liveMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .popularMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .popularTournamentsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .todayMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .todayMatchesFilterPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .customMatchesAggregatorPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .bannersInfoPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .competitionsMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .locationsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .tournamentsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchDetailsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketGroupsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketGroupDetailsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .favoriteMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .cashoutPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchDetailsAggregatorPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketOdds:
            return .sportsInitialDump(topic: self.procedure)
        case .matchBalancedMarketOdds:
            return .sportsInitialDump(topic: self.procedure)
        case .tournamentOddsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .eventPartScoresPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .liveSportsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .eventCategoryBySport:
            return .sportsInitialDump(topic: self.procedure)
            
        case .sportsPublisher:
            return .sportsInitialDump(topic: self.procedure)
            
        default:
            return nil
        }
    }
}

//
// DOCUMENTATION
//
//      Cliente                                           EM Server
//         |                                                  |
//         |              -------------------->               |
//         |                                                  |
//         |                                                  |
//         |        RPC                         EM            |
//         |         |           ->             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |                          |             |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |    Subscribe                       EM            |
//         |         |           ->             |             |
//         |         |           <-             |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |                          |             |
//         |         |           ->             |             |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |            <--------------------                 |
//         |                                                  |
//         |                                                  |

//
//
//         |             -------------------->                |
//         |             <--------------------                |
//
//
//         |             -------------------->                |
//         |             <--------------------                |
//
//
//

// SOCKET
//          Client                      Servidor
// RPC
//
//      nextMatches ---------------------------->
//
//      estrutura de dados  <--------------------
//
//
//
//
//
//
//

// SOCKET
//
// PUBLISHERS
//
//          Client                                     Servidor
//
//         wallet  ------------------------------------->
//
//     connect <------------------- (connect [id: 1234566] )
//
//     dados de update da wallet <------------------- (initial dump)
//
//     dados de update da wallet <------------------- (updates)
//
//     dados de update da wallet <------------------- (updates)
//
//
//     dados de update da wallet <------------------- (updates)
//
//
//     unregister [id: 1234566] ----------------------->
//
//
