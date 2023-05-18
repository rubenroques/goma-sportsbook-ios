//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/04/2023.
//

import Foundation

extension SportRadarModels {

    enum ContentContainer: Codable {

        case liveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case preLiveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])

        case liveSports(sportsTypes: [SportType])
        case preLiveSports(sportsTypes: [SportType])

        case eventDetails(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event?)
        case eventDetailsLiveData(contentIdentifier: ContentIdentifier, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended?)

        case eventGroup(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case outrightEventGroup(events: [SportRadarModels.Event])
        case eventSummary(contentIdentifier: ContentIdentifier, eventDetails: [SportRadarModels.Event])

        case marketDetails(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market?)
        //
        case addEvent(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event)
        case addMarket(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market)
        case addSelection(contentIdentifier: ContentIdentifier, selection: SportRadarModels.Outcome)
        case addSport(contentIdentifier: ContentIdentifier, sportType: SportType)

        case removeEvent(contentIdentifier: ContentIdentifier, eventId: String)
        case removeMarket(contentIdentifier: ContentIdentifier, marketId: String)
        case removeSelection(contentIdentifier: ContentIdentifier, selectionId: String)

        case enableMarket(contentIdentifier: ContentIdentifier, marketId: String)

        case updateEventLiveDataExtended(contentIdentifier: ContentIdentifier, eventId: String, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended)

        case updateEventState(contentIdentifier: ContentIdentifier, eventId: String, state: String)
        case updateEventTime(contentIdentifier: ContentIdentifier, eventId: String, newTime: String)
        case updateEventScore(contentIdentifier: ContentIdentifier, eventId: String, homeScore: Int?, awayScore: Int?)

        case updateMarketTradability(contentIdentifier: ContentIdentifier, marketId: String, isTradable: Bool)
        case updateEventMarketCount(contentIdentifier: ContentIdentifier, eventId: String, newMarketCount: Int)

        case updateOutcomeOdd(contentIdentifier: ContentIdentifier, selectionId: String, newOddNumerator: String?, newOddDenominator: String?)

        case updateOutcomeTradability(contentIdentifier: ContentIdentifier, selectionId: String, isTradable: Bool)

        case unknown

        var contentIdentifier: ContentIdentifier? {
            switch self {
            case .liveEvents(let contentIdentifier, _):
                return contentIdentifier
            case .preLiveEvents(let contentIdentifier, _):
                return contentIdentifier
            case .liveSports(_):
                return nil
            case .preLiveSports(_):
                return nil

            case .eventDetails(let contentIdentifier, _):
                return contentIdentifier

            case .eventDetailsLiveData(let contentIdentifier, _):
                return contentIdentifier

            case .eventGroup(let contentIdentifier, _):
                return contentIdentifier
            case .outrightEventGroup(_):
                return nil
            case .eventSummary(let contentIdentifier, _):
                return contentIdentifier
            case .marketDetails(let contentIdentifier, _):
                return contentIdentifier

            case .addEvent(let contentIdentifier, _):
                return contentIdentifier
            case .removeEvent(let contentIdentifier, _):
                return contentIdentifier

            case .addMarket(let contentIdentifier, _):
                return contentIdentifier
            case .enableMarket(let contentIdentifier, _):
                return contentIdentifier
            case .removeMarket(let contentIdentifier, _):
                return contentIdentifier

            case .addSelection(let contentIdentifier, _):
                return contentIdentifier
            case .removeSelection(let contentIdentifier, _):
                return contentIdentifier

            case .addSport(let contentIdentifier, _):
                return contentIdentifier

            case .updateOutcomeOdd(let contentIdentifier, _, _, _):
                return contentIdentifier
            case .updateOutcomeTradability(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateEventLiveDataExtended(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateEventState(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateEventTime(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateEventScore(let contentIdentifier, _, _, _):
                return contentIdentifier
            case .updateEventMarketCount(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateMarketTradability(let contentIdentifier, _, _):
                return contentIdentifier

            case .unknown:
                return nil

            }
        }

        private enum CodingKeys: String, CodingKey {
            case data = "data"

            case content = "contentId"
            case contentType = "type"
            case contentId = "id"

            case path = "path"

            case changeType = "changeType"
            case change = "change"
        }

        private enum SelectionUpdateCodingKeys: String, CodingKey {
            case oddNumerator = "currentpriceup"
            case oddDenominator = "currentpricedown"
            case selectionId = "idfoselection"
            case marketId = "idfomarket"
            case suspensionType = "idfoselectionsuspensiontype"
        }

        private enum ScoreUpdateCodingKeys: String, CodingKey {
            case home = "home"
            case away = "away"
            case competitor = "COMPETITOR"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let changeType: String = (try? container.decode(String.self, forKey: .changeType)) ?? ""

            switch changeType.lowercased() {
            case "refreshed":
                self = try Self.parseRefreshed(container: container)
            case "updated":
                self = try Self.parseUpdated(container: container)
            case "added":
                self = try Self.parseAdded(container: container)
            case "removed":
                self = try Self.parseRemoved(container: container)
            default:
                self = try Self.parseRefreshed(container: container)
            }

        }

        func encode(to encoder: Encoder) throws {

        }

        private static func parseRefreshed(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentTypeContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
            let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)

            switch contentType {
            case .liveEvents:
                let events: [FailableDecodable<SportRadarModels.Event>] = try container.decode([FailableDecodable<SportRadarModels.Event>].self, forKey: .change)
                let validEvents = events.compactMap({ $0.content })
                return .liveEvents(contentIdentifier: contentIdentifier, events: validEvents)

            case .liveSports:
                let sportsTypeDetails: [FailableDecodable<SportRadarModels.SportTypeDetails>] = try container.decode([FailableDecodable<SportRadarModels.SportTypeDetails>].self, forKey: .change)
                let sportsTypes = sportsTypeDetails.compactMap({ $0.content }).map(\.sportType)
                return .liveSports(sportsTypes: sportsTypes)

            case .preLiveSports:
                // change key is optional
                if container.contains(.change) {
                    let sportsTypes: [FailableDecodable<SportRadarModels.SportType>] = try container.decode([FailableDecodable<SportRadarModels.SportType>].self, forKey: .change)
                    return .preLiveSports(sportsTypes: sportsTypes.compactMap({ $0.content }))
                }
                else {
                    let sportsTypes: [SportType] = []
                    return .preLiveSports(sportsTypes: sportsTypes)
                }

            case .preLiveEvents:
                // change key is optional
                if container.contains(.change) {
                    let events: [FailableDecodable<SportRadarModels.Event>] = try container.decode([FailableDecodable<SportRadarModels.Event>].self, forKey: .change)
                    let validEvents = events.compactMap({ $0.content })
                    return .preLiveEvents(contentIdentifier: contentIdentifier, events: validEvents)
                }
                else {
                    return .preLiveEvents(contentIdentifier: contentIdentifier, events: [])
                }

            case .eventDetails:
                // change key is optional
                if container.contains(.change) {
                    let event: SportRadarModels.Event = try container.decode(SportRadarModels.Event.self, forKey: .change)
                    return .eventDetails(contentIdentifier: contentIdentifier, event: event)
                }
                else {
                    return .eventDetails(contentIdentifier: contentIdentifier, event: nil)
                }
            case .eventGroup:
                if container.contains(.change) {
                    let marketGroup: SportRadarModels.CompetitionMarketGroup = try container.decode(SportRadarModels.CompetitionMarketGroup.self, forKey: .change)
                    let events = marketGroup.events
                    return .eventGroup(contentIdentifier: contentIdentifier, events: events)
                }
                else {
                    return .eventGroup(contentIdentifier: contentIdentifier, events: [])
                }

            case .eventSummary:
                // change key is optional
                if container.contains(.change) {
                    let event: SportRadarModels.Event = try container.decode(SportRadarModels.Event.self, forKey: .change)
                    return .eventSummary(contentIdentifier: contentIdentifier, eventDetails: [event])
                }
                else {
                    return .eventSummary(contentIdentifier: contentIdentifier, eventDetails: [])
                }
            case .market:
                if container.contains(.change) {
                    let market: SportRadarModels.Market? = try container.decodeIfPresent(SportRadarModels.Market.self, forKey: .change)
                    return .marketDetails(contentIdentifier: contentIdentifier, market: market)
                }
                else {
                    return .marketDetails(contentIdentifier: contentIdentifier, market: nil)
                }
            case .eventDetailsLiveData:
                if container.contains(.change) {
                    let eventLiveData = try container.decodeIfPresent(SportRadarModels.EventLiveDataExtended.self, forKey: .change)
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataExtended: eventLiveData)
                }
                else {
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataExtended: nil)
                }
            }
        }

        private static func parseUpdated(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""


            if case let ContentRoute.eventDetailsLiveData(eventId) = contentIdentifier.contentRoute {
                if let eventLiveData = (try? container.decode(SportRadarModels.EventLiveDataExtended.self, forKey: .change)) {
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier, eventId: eventId , eventLiveDataExtended: eventLiveData)
                }
                else if path.lowercased().contains("matchtime"), let matchTime = try container.decodeIfPresent(String.self, forKey: .change) {
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId, homeScore: nil, awayScore: nil, matchTime: matchTime, status: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier, eventId: eventId, eventLiveDataExtended: eventLiveDataExtended)
                }
                return .unknown
            }

            if path.contains("idfomarket") && path.contains("istradable"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                // removed a Market
                let newIsTradable = try container.decode(Bool.self, forKey: .change)
                // print("ContentContainer isTradable \(newIsTradable) market with id :: \(path) and associated change \(changeType)")
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }
            // Updates on Events
            else if path.contains("idfoselection") {
                // Updated a selection
                let changeContainer = try container.nestedContainer(keyedBy: SelectionUpdateCodingKeys.self, forKey: .change)

                let oddNumerator = try changeContainer.decodeIfPresent(String.self, forKey: .oddNumerator)
                let oddDenominator = try changeContainer.decodeIfPresent(String.self, forKey: .oddDenominator)

                let selectionId = try changeContainer.decode(String.self, forKey: .selectionId)

                if oddNumerator == nil && oddDenominator == nil {
                    if changeContainer.contains(.suspensionType) {
                        if let selectionSuspentionType = try changeContainer.decodeIfPresent(String.self, forKey: .suspensionType),
                           selectionSuspentionType == "N/O" {
                            return .updateOutcomeTradability(contentIdentifier: contentIdentifier,
                                                             selectionId: selectionId,
                                                             isTradable: false)
                        }
                        else {
                            return .updateOutcomeTradability(contentIdentifier: contentIdentifier,
                                                             selectionId: selectionId,
                                                             isTradable: true)
                        }
                    }
                    else {
                        return .unknown
                    }
                }
                else {
                    return .updateOutcomeOdd(contentIdentifier: contentIdentifier, selectionId: selectionId, newOddNumerator: oddNumerator, newOddDenominator: oddDenominator)
                }
            }
            else if path.contains("idfoevent") && path.contains("numMarkets"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Changed the number of markets for an event
                let newMarketCount = try container.decode(Int.self, forKey: .change)
                return .updateEventMarketCount(contentIdentifier: contentIdentifier, eventId: eventId, newMarketCount: newMarketCount)
            }
            else if path.contains("attributes") && path.contains("COMPLETE") && path.contains("CURRENT_SCORE") {
                let changeContainer = try container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change)
                let competitorContainer = try changeContainer.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .competitor)

                let homeScore = try competitorContainer.decodeIfPresent(Int.self, forKey: .home)
                let awayScore = try competitorContainer.decodeIfPresent(Int.self, forKey: .away)

                let eventIdContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)

                let eventId = try eventIdContainer.decode(String.self, forKey: .contentId)

                return .updateEventScore(contentIdentifier: contentIdentifier, eventId: eventId, homeScore: homeScore, awayScore: awayScore)
            }
            else if path.contains("scores") && path.contains("liveDataSummary") && (path.contains("MATCH_SCORE") || path.contains("CURRENT_SCORE")), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Updated score information
                let changeContainer = try container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change)
                let homeScore = try changeContainer.decodeIfPresent(Int.self, forKey: .home)
                let awayScore = try changeContainer.decodeIfPresent(Int.self, forKey: .away)
                return .updateEventScore(contentIdentifier: contentIdentifier, eventId: eventId, homeScore: homeScore, awayScore: awayScore)
            }
            else if path.contains("matchTime") && path.contains("liveDataSummary"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Match time
                let matchTime = try container.decode(String.self, forKey: .change)
                if let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: matchTime) {
                    return .updateEventTime(contentIdentifier: contentIdentifier, eventId: eventId, newTime: minutesPart)
                }
            }
            else if path.contains("status") && path.contains("liveDataSummary"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                let newStatus = try container.decode(String.self, forKey: .change)
                return .updateEventState(contentIdentifier: contentIdentifier, eventId: eventId, state: newStatus)
            }
            else if path.contains("selections") && path.contains("idfoselection") {
                if let changeContainer = try? container.nestedContainer(keyedBy: SelectionUpdateCodingKeys.self, forKey: .change),
                   let oddNumerator = try changeContainer.decodeIfPresent(String.self, forKey: .oddNumerator),
                   let oddDenominator = try changeContainer.decodeIfPresent(String.self, forKey: .oddDenominator),
                   let selectionId = try? changeContainer.decode(String.self, forKey: .selectionId) {

                    // print("ContentContainer updated market odd with id \(marketId) and associated change \(changeType)")
                    return .updateOutcomeOdd(contentIdentifier: contentIdentifier,
                                             selectionId: selectionId,
                                             newOddNumerator: oddNumerator,
                                             newOddDenominator: oddDenominator)
                }
            }
            else if path.contains("istradable"), let newIsTradable = try? container.decode(Bool.self, forKey: .change), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                if newIsTradable {
                    return .enableMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
                else {
                    return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
            }
            else if path.contains("istradable"), let newIsTradable = try? container.decode(Bool.self, forKey: .change) {
                if contentIdentifier.contentType == .market, case .market(let marketId) = contentIdentifier.contentRoute {
                    if newIsTradable {
                        return .enableMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                    }
                    else {
                        return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                    }
                }
            }
            else if path.contains("markets") && path.contains("idfomarket") && path.contains("istradable"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                let newIsTradable = (try? container.decode(Bool.self, forKey: .change)) ?? true
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }

            else if path.contains("selections") && path.contains("idfoselection"), let selectionId = SocketMessageParseHelper.extractSelectionId(path) {
                print("Updated Selection \(selectionId)")
            }
            else if contentIdentifier.contentType == .market, // Is a contentRout of market updates
                    path == "istradable", // the path is istradable
                    case .market(let marketId) = contentIdentifier.contentRoute, // extract the marketId
                    let newIsTradable = try? container.decode(Bool.self, forKey: .change) {

                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }

            print("ContentContainer ignored update for \(path) and associated change: Updated")
            return .unknown
        }

        private static func parseAdded(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""

            if path.contains("idfomarket"), let newMarket = try? container.decode(SportRadarModels.Market.self, forKey: .change) {
                return .addMarket(contentIdentifier: contentIdentifier, market: newMarket)
            }
            else if path.contains("idfoevent"), let newEvent = try? container.decode(SportRadarModels.Event.self, forKey: .change) {
                return .addEvent(contentIdentifier: contentIdentifier, event: newEvent)
            }
            else if path.contains("idfosporttype"), let newSport = try? container.decodeIfPresent(SportRadarModels.SportTypeDetails.self, forKey: .change) {
                return .addSport(contentIdentifier: contentIdentifier, sportType: newSport.sportType)
            }
            
            print("ContentContainer ignored update for \(path) and associated change: Added")
            return .unknown
        }

        private static func parseRemoved(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""

            if contentIdentifier.contentType == .market, case .market(let marketId) = contentIdentifier.contentRoute {
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoselection"), let selectionId = SocketMessageParseHelper.extractSelectionId(path) {
                return .removeSelection(contentIdentifier: contentIdentifier, selectionId: selectionId)
            }
            else if path.contains("idfomarket"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoevent"), let eventId = SocketMessageParseHelper.extractEventId(path)  {
                return .removeEvent(contentIdentifier: contentIdentifier, eventId: eventId)
            }

            print("ContentContainer ignored update for \(path) and associated change: Removed")
            return .unknown
        }

    }

}



extension SportRadarModels.ContentContainer: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .liveEvents(let contentIdentifier, let events):
            return "Live Events (Content ID: \(contentIdentifier)) - Event count: \(events.count)"
        case .preLiveEvents(let contentIdentifier, let events):
            return "Pre-live Events (Content ID: \(contentIdentifier)) - Event count: \(events.count)"
        case .liveSports(let sportsTypes):
            return "Live Sports - Sport Types count: \(sportsTypes.count)"
        case .preLiveSports(let sportsTypes):
            return "Pre-live Sports - Sport Types count: \(sportsTypes.count)"
        case .eventDetails(let contentIdentifier, let event):
            return "Event Details (Content ID: \(contentIdentifier)) - Event: \(String(describing: event))"
        case .eventDetailsLiveData(let contentIdentifier, let eventLiveDataExtended):
            return "Event Details Live Data (Content ID: \(contentIdentifier)) - Event Live Data Extended: \(String(describing: eventLiveDataExtended))"
        case .eventGroup(let contentIdentifier, let events):
            return "Event Group (Content ID: \(contentIdentifier)) - Event count: \(events.count)"
        case .outrightEventGroup(let events):
            return "Outright Event Group - Event count: \(events.count)"
        case .eventSummary(let contentIdentifier, let eventDetails):
            return "Event Summary (Content ID: \(contentIdentifier)) - Event Details count: \(eventDetails.count)"
        case .marketDetails(let contentIdentifier, let market):
            return "Market Details (Content ID: \(contentIdentifier)) - Market: \(String(describing: market))"

        case .addEvent(let contentIdentifier, let event):
            return "Add Event (Content ID: \(contentIdentifier)) - Event: \(event)"
        case .removeEvent(let contentIdentifier, let eventId):
            return "Remove Event (Content ID: \(contentIdentifier)) - Event ID: \(eventId)"

        case .addMarket(let contentIdentifier, let market):
            return "Add Market (Content ID: \(contentIdentifier)) - Market: \(market)"
        case .enableMarket(let contentIdentifier, let marketId):
            return "Enable Market (Content ID: \(contentIdentifier)) - Market ID: \(marketId)"
        case .removeMarket(let contentIdentifier, let marketId):
            return "Remove Market (Content ID: \(contentIdentifier)) - Market ID: \(marketId)"

        case .addSelection(let contentIdentifier, let selection):
            return "Add Selection (Content ID: \(contentIdentifier)) - Selection: \(selection)"
        case .removeSelection(let contentIdentifier, let selectionId):
            return "Remove Selection (Content ID: \(contentIdentifier)) - Selection ID: \(selectionId)"

        case .addSport(let contentIdentifier, let sportType):
            return "Add Sport (Content ID: \(contentIdentifier)) - Sport ID: \(sportType)"

        case .updateEventLiveDataExtended(let contentIdentifier, let eventId, let eventLiveDataExtended):
            return "Update Event LiveDataExtended (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - LiveDataExtended: \(eventLiveDataExtended)"

        case .updateEventState(let contentIdentifier, let eventId, let state):
            return "Update Event State (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - State: \(state)"
        case .updateEventTime(let contentIdentifier, let eventId, let newTime):
            return "Update Event Time (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Time: \(newTime)"
        case .updateEventScore(let contentIdentifier, let eventId, let homeScore, let awayScore):
            return "Update Event Score (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - Home Score: \(String(describing: homeScore)) - Away Score: \(String(describing: awayScore))"
        case .updateEventMarketCount(let contentIdentifier, let eventId, let newMarketCount):
            return "Update Event Market Count (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Market Count: \(newMarketCount)"

        case .updateMarketTradability(let contentIdentifier, let marketId, let isTradable):
            return "Update Market Tradability (Content ID: \(contentIdentifier)) - Market ID: \(marketId) - Tradable: \(isTradable)"

        case .updateOutcomeOdd(let contentIdentifier, let selectionId, let newOddNumerator, let newOddDenominator):
            return "Update Outcome Odd (Content ID: \(contentIdentifier)) - Selection ID: \(selectionId) - New Odd Numerator: \(String(describing: newOddNumerator)) - New Odd Denominator: \(String(describing: newOddDenominator))"
        case .updateOutcomeTradability(let contentIdentifier, let selectionId, let isTradable):
            return "Update Outcome Tradability (Content ID: \(contentIdentifier)) - Market ID: \(selectionId) - Tradable: \(isTradable)"

        case .unknown:
            return "Unknown ContentContainer"
        }
    }
}
