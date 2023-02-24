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
        
        case eventDetails(eventDetails: [SportRadarModels.Event])
        case eventGroup(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case outrightEventGroup(events: [SportRadarModels.Event])
        case eventSummary(eventDetails: [SportRadarModels.Event])

        //
        case addEvent(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event)
        case removeEvent(contentIdentifier: ContentIdentifier, eventId: String)

        case addMarket(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market)
        case removeMarket(contentIdentifier: ContentIdentifier, marketId: String)

        case updateOutcomeOdd(contentIdentifier: ContentIdentifier, selectionId: String, newOddNumerator: String?, newOddDenominator: String?)
        case updateEventState(contentIdentifier: ContentIdentifier, eventId: String, state: String)
        case updateEventScore(contentIdentifier: ContentIdentifier, eventId: String, homeScore: Int?, awayScore: Int?)
        case updateEventMarketCount(contentIdentifier: ContentIdentifier, eventId: String, newMarketCount: Int)

        enum CodingKeys: String, CodingKey {
            case data = "data"

            case content = "contentId"
            case contentType = "type"
            case contentId = "id"

            case path = "path"

            case changeType = "changeType"
            case change = "change"
        }

        enum SelectionUpdateCodingKeys: String, CodingKey {
            case oddNumerator = "currentpriceup"
            case oddDenominator = "currentpricedown"
            case selectionId = "idfoselection"
        }

        enum ScoreUpdateCodingKeys: String, CodingKey {
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
                return .liveEvents(contentIdentifier: contentIdentifier, events: events.compactMap({ $0.content }))

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
                    return .preLiveEvents(contentIdentifier: contentIdentifier, events: events.compactMap({ $0.content }) )
                }
                else {
                    return .preLiveEvents(contentIdentifier: contentIdentifier, events: [])
                }

            case .eventDetails:
                // change key is optional
                if container.contains(.change) {
                    let event: SportRadarModels.Event = try container.decode(SportRadarModels.Event.self, forKey: .change)
                    return .eventDetails(eventDetails: [event])
                }
                else {
                    return .eventDetails(eventDetails: [])
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
                    return .eventDetails(eventDetails: [event])
                }
                else {
                    return .eventDetails(eventDetails: [])
                }
            }
        }

        private static func parseUpdates(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)

            let path: String = (try? container.decode(String.self, forKey: .path)) ?? ""
            let changeType: String = (try? container.decode(String.self, forKey: .changeType)) ?? ""

            print("Path \(path)")

            if path.contains("idfoevent") && changeType.contains("added") {
                // Added a new event

            }
            // Markets
            else if path.contains("idfoevent") && path.contains("idfomarket") && changeType.contains("added") {
                // added a new Market
                let newMarket = try container.decode(SportRadarModels.Market.self, forKey: .change)
                return .addMarket(contentIdentifier: contentIdentifier, market: newMarket)
            }
            else if path.contains("idfoevent") && path.contains("idfomarket") && changeType.contains("removed"), let marketId = Self.extractMarketId(path)  {
                // removed a Market
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
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
            else if path.contains("idfoevent") && path.contains("numMarkets") && changeType.contains("updated"), let eventId = Self.extractEventId(path) {
                // Changed the number of markets for an event
                let newMarketCount = try container.decode(Int.self, forKey: .change)
                return .updateEventMarketCount(contentIdentifier: contentIdentifier, eventId: eventId, newMarketCount: newMarketCount)
            }
            else if path.contains("scores") && path.contains("liveDataSummary"), let eventId = Self.extractEventId(path) {
                // Updated score information
                let changeContainer = try container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change)
                let homeScore = try changeContainer.decodeIfPresent(Int.self, forKey: .home)
                let awayScore = try changeContainer.decodeIfPresent(Int.self, forKey: .away)
                return .updateEventScore(contentIdentifier: contentIdentifier, eventId: eventId, homeScore: homeScore, awayScore: awayScore)
            }
            else if path.contains("matchTime") && path.contains("liveDataSummary"), changeType.contains("updated"), let eventId = Self.extractEventId(path) {
                // Match time
                let matchTime = try container.decode(String.self, forKey: .change)
                let minutesPart = Self.extractMatchMinutes(from: matchTime)
                print("Event liveDataSummary matchTime \(matchTime) [\(minutesPart)] [eventId:\(eventId)]")
            }
            else if path.contains("status") && path.contains("liveDataSummary"), let eventId = Self.extractEventId(path) {
                let newStatus = try container.decode(String.self, forKey: .change)
                print("Event liveDataSummary status \(newStatus) [eventId:\(eventId)]")
            }

            let context = DecodingError.Context(codingPath: [CodingKeys.content], debugDescription: "Uknown ContentContainer \(path)")
            throw DecodingError.valueNotFound(ContentRoute.self, context)
        }


        private static func extractEventId(_ inputString: String) -> String? {
            let regex = try! NSRegularExpression(pattern: "\\[idfoevent=(\\d+(\\.\\d+)?)\\]")
            let range = NSRange(location: 0, length: inputString.utf16.count)
            if let match = regex.firstMatch(in: inputString, options: [], range: range) {
                let id = (inputString as NSString).substring(with: match.range(at: 1))
                return id
            }
            return nil
        }

        private static func extractMarketId(_ inputString: String) -> String? {
            let regex = try! NSRegularExpression(pattern: "\\[idfomarket=(\\d+(\\.\\d+)?)\\]")
            let range = NSRange(location: 0, length: inputString.utf16.count)
            if let match = regex.firstMatch(in: inputString, options: [], range: range) {
                let id = (inputString as NSString).substring(with: match.range(at: 1))
                return id
            }
            return nil
        }

        private static func extractSelectionId(_ inputString: String) -> String? {
            let regex = try! NSRegularExpression(pattern: "\\[idfoselection=(\\d+(\\.\\d+)?)\\]")
            let range = NSRange(location: 0, length: inputString.utf16.count)
            if let match = regex.firstMatch(in: inputString, options: [], range: range) {
                let id = (inputString as NSString).substring(with: match.range(at: 1))
                return id
            }
            return nil
        }

        private static func extractMatchMinutes(from matchTime: String) -> String {
            let pattern = #"(?<=^|\s)(\d{1,2}):(\d{2})(?:\s\+(\d{1,2}:\d{2}))?(?=$|\s)"#
            guard let range = matchTime.range(of: pattern, options: .regularExpression) else {
                return ""
            }

            let minuteString = String(matchTime[range])
            let components = minuteString.components(separatedBy: ":")
            let minutes = Int(components[0]) ?? 0

            if let extraTimeRange = minuteString.range(of: #"\s\+([\d:]+)"#, options: .regularExpression),
                let extraTime = Int(String(minuteString[extraTimeRange].dropFirst(2)).components(separatedBy: ":").first ?? "") {
                return "\(minutes)+\(extraTime)'"
            }

            return "\(minutes)'"
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
            
            case content = "contentId"
            case contentType = "type"
            case contentId = "id"

            case change = "change"
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
                self = .contentChanges(contents: contents.compactMap({ $0.content }))
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
