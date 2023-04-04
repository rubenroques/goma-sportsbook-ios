//
//  SportRadarModels.swift
//  
//
//  Created by Ruben Roques on 05/10/2022.
//

import Foundation

enum SportRadarModels {
    
}

extension SportRadarModels {

    enum ContentContainer: Codable {
        
        case liveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case preLiveEvents(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        
        case liveSports(sportsTypes: [SportType])
        case preLiveSports(sportsTypes: [SportType]) 
        
        case eventDetails(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event?)
        case eventDetailsLiveData(contentIdentifier: ContentIdentifier, eventLiveDataSummary: SportRadarModels.EventLiveDataSummary?)

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
                    let eventLiveData = try container.decodeIfPresent(SportRadarModels.EventLiveDataSummary.self, forKey: .change)
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataSummary: eventLiveData)
                }
                else {
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataSummary: nil)
                }
            }
        }

        private static func parseUpdates(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)

            let path: String = (try? container.decode(String.self, forKey: .path)) ?? ""
            let changeType: String = (try? container.decode(String.self, forKey: .changeType)) ?? ""

            // print("ContentContainer recieved path \(path) with change \(changeType)")

            if path.contains("idfoevent") && path.contains("idfomarket") && changeType.contains("added") {
                // added a new Market
                let newMarket = try container.decode(SportRadarModels.Market.self, forKey: .change)
                // print("ContentContainer 'add' market with id \(newMarket.id) :: \(path) and associated change \(changeType)")
                return .addMarket(contentIdentifier: contentIdentifier, market: newMarket)
            }
            else if path.contains("idfoevent") && path.contains("idfomarket") && changeType.contains("removed"),
                        let marketId = SocketMessageParseHelper.extractMarketId(path) {
                // removed a Market
                // print("ContentContainer removed market with id \(marketId) :: \(path) and associated change \(changeType)")
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoevent") && path.contains("idfomarket") && path.contains("istradable") && changeType.contains("updated"),
                    let marketId = SocketMessageParseHelper.extractMarketId(path) {
                // removed a Market
                let newIsTradable = try container.decode(Bool.self, forKey: .change)
                // print("ContentContainer isTradable \(newIsTradable) market with id :: \(path) and associated change \(changeType)")
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }
            // Updates on Events
            else if path.contains("idfoevent") && path.contains("idfomarket") && path.contains("idfoselection") && changeType.contains("updated") {
                // Updated a selection
                let changeContainer = try container.nestedContainer(keyedBy: SelectionUpdateCodingKeys.self, forKey: .change)

                let oddNumerator = try changeContainer.decodeIfPresent(String.self, forKey: .oddNumerator)
                let oddDenominator = try changeContainer.decodeIfPresent(String.self, forKey: .oddDenominator)
                let selectionId = try changeContainer.decode(String.self, forKey: .selectionId)
                return .updateOutcomeOdd(contentIdentifier: contentIdentifier, selectionId: selectionId, newOddNumerator: oddNumerator, newOddDenominator: oddDenominator)
            }
            else if path.contains("idfoevent") && path.contains("numMarkets") && changeType.contains("updated"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Changed the number of markets for an event
                let newMarketCount = try container.decode(Int.self, forKey: .change)
                return .updateEventMarketCount(contentIdentifier: contentIdentifier, eventId: eventId, newMarketCount: newMarketCount)
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
                   let selectionId = try? changeContainer.decode(String.self, forKey: .selectionId),
                   let marketId = try? changeContainer.decode(String.self, forKey: .marketId) {

                    // print("ContentContainer updated market odd with id \(marketId) and associated change \(changeType)")
                    return .updateOutcomeOdd(contentIdentifier: contentIdentifier,
                                             selectionId: selectionId,
                                             newOddNumerator: oddNumerator,
                                             newOddDenominator: oddDenominator)
                }
            }
            else if path.contains("istradable"),
                        changeType.contains("updated"),
                        let newIsTradable = try? container.decode(Bool.self, forKey: .change),
                        case let .market(marketId: marketId) = contentIdentifier.contentRoute {
                if newIsTradable {
                    return .enableMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
                else {
                    return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
                }
                // print("ContentContainer 'remove' market with id \(path) and associated change \(changeType)")
                // return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoevent") && changeType.contains("added") {
                // Added a new event
            }
            else if path.contains("idfoevent") && changeType.contains("removed") {
                // Added a new event
            }

            print("ContentContainer ignored update for \(path) and associated change \(changeType)")
            throw SportRadarError.ignoredContentUpdate
        }


    }

}


extension SportRadarModels {
    
    enum NotificationType: Codable {
        
        case listeningStarted(sessionTokenId: String)
        case contentChanges(contents: [ContentContainer])
        case unknown

        enum CodingKeys: String, CodingKey {
            case notificationType = "notificationType"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let typeString = try container.decode(String.self, forKey: .notificationType)
            
            switch typeString {
            case "LISTENING_STARTED":
                let sessionTokenId = try container.decode(String.self, forKey: .data)
                self = .listeningStarted(sessionTokenId: sessionTokenId)
            case "CONTENT_CHANGES":
                let contents = try container.decode([FailableDecodable<SportRadarModels.ContentContainer>].self, forKey: .data)
                let validContents = contents.compactMap({ $0.content })
                self = .contentChanges(contents: validContents)
            default:
                self = .unknown
            }
        }
        
        func encode(to encoder: Encoder) throws {
            
        }

    }

}



extension SportRadarModels {

    struct RestResponse<T: Codable>: Codable {
        let data: T?
        enum CodingKeys: String, CodingKey {
            case data = "data"
        }
    }

}
