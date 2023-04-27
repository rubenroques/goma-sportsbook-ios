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
        case removeEvent(contentIdentifier: ContentIdentifier, eventId: String)

        case addMarket(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market)
        case enableMarket(contentIdentifier: ContentIdentifier, marketId: String)
        case removeMarket(contentIdentifier: ContentIdentifier, marketId: String)

        case updateEventState(contentIdentifier: ContentIdentifier, eventId: String, state: String)
        case updateEventTime(contentIdentifier: ContentIdentifier, eventId: String, newTime: String)
        case updateEventScore(contentIdentifier: ContentIdentifier, eventId: String, homeScore: Int?, awayScore: Int?)

        case updateMarketTradability(contentIdentifier: ContentIdentifier, marketId: String, isTradable: Bool)
        case updateEventMarketCount(contentIdentifier: ContentIdentifier, eventId: String, newMarketCount: Int)

        case updateOutcomeOdd(contentIdentifier: ContentIdentifier, selectionId: String, newOddNumerator: String?, newOddDenominator: String?)

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
            case .updateOutcomeOdd(let contentIdentifier, _, _, _):
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
        }

        private enum ScoreUpdateCodingKeys: String, CodingKey {
            case home = "home"
            case away = "away"
            case competitor = "COMPETITOR"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.path) {
                self = try Self.parseUpdates(container: container)
            }
            else {
                self = try Self.parseInitialData(container: container)
            }
        }

        func encode(to encoder: Encoder) throws {

        }

        private static func parseInitialData(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

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

        private static func parseUpdates(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)

            let path: String = (try? container.decode(String.self, forKey: .path)) ?? "empty path"
            let changeType: String = (try? container.decode(String.self, forKey: .changeType)) ?? "empty changetype"

            // print("ContentContainer recieved path [\(path)] with changeType -\(changeType)- with change -\(debugChange)-")

            if path.contains("idfomarket") && changeType.contains("added") {
                // added a new Market
                let newMarket = try container.decode(SportRadarModels.Market.self, forKey: .change)
                // print("ContentContainer 'add' market with id \(newMarket.id) :: \(path) and associated change \(changeType)")
                return .addMarket(contentIdentifier: contentIdentifier, market: newMarket)
            }
            else if path.contains("idfomarket") && changeType.contains("removed"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                // removed a Market
                // print("ContentContainer removed market with id \(marketId) :: \(path) and associated change \(changeType)")
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfomarket") && path.contains("istradable") && changeType.contains("updated"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                // removed a Market
                let newIsTradable = try container.decode(Bool.self, forKey: .change)
                // print("ContentContainer isTradable \(newIsTradable) market with id :: \(path) and associated change \(changeType)")
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }
            // Updates on Events
            else if path.contains("idfoselection") && changeType.contains("updated") {
                // Updated a selection
                let changeContainer = try container.nestedContainer(keyedBy: SelectionUpdateCodingKeys.self, forKey: .change)

                let oddNumerator = try changeContainer.decodeIfPresent(String.self, forKey: .oddNumerator)
                let oddDenominator = try changeContainer.decodeIfPresent(String.self, forKey: .oddDenominator)

                if oddNumerator == nil && oddDenominator == nil {
                    return .unknown
                }
                else {
                    let selectionId = try changeContainer.decode(String.self, forKey: .selectionId)
                    return .updateOutcomeOdd(contentIdentifier: contentIdentifier, selectionId: selectionId, newOddNumerator: oddNumerator, newOddDenominator: oddDenominator)
                }
            }
            else if path.contains("idfoevent") && path.contains("numMarkets") && changeType.contains("updated"), let eventId = SocketMessageParseHelper.extractEventId(path) {
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
            else if path.contains("matchTime") && path.contains("liveDataSummary"), changeType.contains("updated"), let eventId = SocketMessageParseHelper.extractEventId(path) {
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
            else if path.contains("istradable"), changeType.contains("updated"), let newIsTradable = try? container.decode(Bool.self, forKey: .change), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                if newIsTradable {
                    return .enableMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
                else {
                    return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
                // print("ContentContainer 'remove' market with id \(path) and associated change \(changeType)")
                // return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoevent") && changeType.contains("added"), let eventId = SocketMessageParseHelper.extractEventId(path)  {
                // Added a new event
                let newEvent = try container.decode(SportRadarModels.Event.self, forKey: .change)
                return .addEvent(contentIdentifier: contentIdentifier, event: newEvent)
            }
            else if path.contains("idfoevent") && changeType.contains("removed"), let eventId = SocketMessageParseHelper.extractEventId(path)  {
                // Removed an event
                return .removeEvent(contentIdentifier: contentIdentifier, eventId: eventId)
            }
            else if path.contains("markets") && path.contains("idfomarket") && path.contains("istradable") && changeType.contains("updated"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                print("Updated Market \(marketId)")
            }

            else if path.contains("selections") && path.contains("idfoselection") && changeType.contains("updated"), let selectionId = SocketMessageParseHelper.extractSelectionId(path) {
                print("Updated Selection \(selectionId)")
            }


            print("ContentContainer ignored update for \(path) and associated change \(changeType)")
            return .unknown // SportRadarError.ignoredContentUpdate
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
        case .updateEventState(let contentIdentifier, let eventId, let state):
            return "Update Event State (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - State: \(state)"
        case .updateEventTime(let contentIdentifier, let eventId, let newTime):
            return "Update Event Time (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Time: \(newTime)"
        case .updateEventScore(let contentIdentifier, let eventId, let homeScore, let awayScore):
            return "Update Event Score (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - Home Score: \(String(describing: homeScore)) - Away Score: \(String(describing: awayScore))"
            
        case .updateMarketTradability(let contentIdentifier, let marketId, let isTradable):
            return "Update Market Tradability (Content ID: \(contentIdentifier)) - Market ID: \(marketId) - Tradable: \(isTradable)"
        case .updateEventMarketCount(let contentIdentifier, let eventId, let newMarketCount):
            return "Update Event Market Count (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Market Count: \(newMarketCount)"
        case .updateOutcomeOdd(let contentIdentifier, let selectionId, let newOddNumerator, let newOddDenominator):
            return "Update Outcome Odd (Content ID: \(contentIdentifier)) - Selection ID: \(selectionId) - New Odd Numerator: \(String(describing: newOddNumerator)) - New Odd Denominator: \(String(describing: newOddDenominator))"
        case .unknown:
            return "Unknown ContentContainer"
        }
    }
}
