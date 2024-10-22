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
        case allSports(sportTypes: [SportType])

        case eventDetails(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event?)
        case eventDetailsLiveData(contentIdentifier: ContentIdentifier, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended?)

        case eventGroup(contentIdentifier: ContentIdentifier, events: [SportRadarModels.Event])
        case outrightEventGroup(events: [SportRadarModels.Event])
        case eventSummary(contentIdentifier: ContentIdentifier, eventDetails: [SportRadarModels.Event])

        case marketDetails(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market?)
        case updateEventSecundaryMarkets(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event?)
        case updateEventMainMarket(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event?)

        //
        case addEvent(contentIdentifier: ContentIdentifier, event: SportRadarModels.Event)
        case addMarket(contentIdentifier: ContentIdentifier, market: SportRadarModels.Market)
        case addSelection(contentIdentifier: ContentIdentifier, selection: SportRadarModels.Outcome)
        case addSport(contentIdentifier: ContentIdentifier, sportType: SportType)

        case removeEvent(contentIdentifier: ContentIdentifier, eventId: String)
        case removeMarket(contentIdentifier: ContentIdentifier, marketId: String)
        case removeSelection(contentIdentifier: ContentIdentifier, selectionId: String)
        case removeSport(ContentIdentifier: ContentIdentifier, sportCode: String)

        case enableMarket(contentIdentifier: ContentIdentifier, marketId: String)

        case updateEventLiveDataExtended(contentIdentifier: ContentIdentifier, eventId: String, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended)

        case updateAllSportsLiveCount(ContentIdentifier: ContentIdentifier, nodeId: String, eventCount: Int)
        case updateAllSportsEventCount(ContentIdentifier: ContentIdentifier, nodeId: String, eventCount: Int)

        case updateEventState(contentIdentifier: ContentIdentifier, eventId: String, state: String)
        case updateEventTime(contentIdentifier: ContentIdentifier, eventId: String, newTime: String)
        case updateEventScore(contentIdentifier: ContentIdentifier, eventId: String, homeScore: Int?, awayScore: Int?)

        case updateActivePlayer(contentIdentifier: ContentIdentifier, eventId: String, serving: SportRadarModels.ActivePlayerServe)
        
        case updateEventDetailedScore(contentIdentifier: ContentIdentifier, eventId: String, detailedScore: SportRadarModels.Score)
        
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
            case .allSports(_):
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
                
            case .updateEventSecundaryMarkets(let contentIdentifier, _):
                return contentIdentifier
            case .updateEventMainMarket(let contentIdentifier, _):
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
            case .removeSport(let contentIdentifier, _):
                return contentIdentifier

            case .updateOutcomeOdd(let contentIdentifier, _, _, _):
                return contentIdentifier
            case .updateOutcomeTradability(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateEventLiveDataExtended(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateAllSportsLiveCount(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateAllSportsEventCount(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateEventState(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateEventTime(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateEventScore(let contentIdentifier, _, _, _):
                return contentIdentifier
            case .updateActivePlayer(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateEventMarketCount(let contentIdentifier, _, _):
                return contentIdentifier
            case .updateMarketTradability(let contentIdentifier, _, _):
                return contentIdentifier

            case .updateEventDetailedScore(let contentIdentifier, _, _):
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

            
            // let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
            // print("ServiceProviderLogs: path:\(path)")
            
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

            case .allSports:
                let sportsTypeDetails: FailableDecodable<SportRadarModels.SportsList> = try container.decode(FailableDecodable<SportRadarModels.SportsList>.self, forKey: .change)

                if let sportNodes = sportsTypeDetails.content?.sportNodes {
                    let sportTypes = sportNodes.map(SportRadarModelMapper.sportType(fromSportNode:))
                    let filteredSportTypes = sportTypes.filter({
                        $0.alphaId != "0"
                    })
                    return .allSports(sportTypes: filteredSportTypes)
                }

                return .allSports(sportTypes: [])

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
            case .eventSecundaryMarkets:
                if container.contains(.change) {
                    let event: SportRadarModels.Event = try container.decode(SportRadarModels.Event.self, forKey: .change)
                    return .updateEventSecundaryMarkets(contentIdentifier: contentIdentifier, event: event)
                }
                else {
                    return .updateEventSecundaryMarkets(contentIdentifier: contentIdentifier, event: nil)
                }
                
            case .eventDetailsLiveData:
                if container.contains(.change) {
                    let eventLiveData = try container.decodeIfPresent(SportRadarModels.EventLiveDataExtended.self, forKey: .change)
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataExtended: eventLiveData)
                }
                else {
                    return ContentContainer.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataExtended: nil)
                }
            case .eventMainMarket:
                if container.contains(.change) {
                    let event: SportRadarModels.Event = try container.decode(SportRadarModels.Event.self, forKey: .change)
                    return .updateEventMainMarket(contentIdentifier: contentIdentifier, event: event)
                }
                else {
                    return .updateEventMainMarket(contentIdentifier: contentIdentifier, event: nil)
                }
            }
        }

        private static func parseUpdated(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {
            
            let contentTypeContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
            let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
            
            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
            
            if contentType == .eventMainMarket && path.lowercased().contains("idfomarket") {
                print("parseUpdated break")
            }


            if case let ContentRoute.eventMainMarket(eventId) = contentIdentifier.contentRoute {
                if let event = try? container.decode(SportRadarModels.Event.self, forKey: .change) {
                    return .updateEventMainMarket(contentIdentifier: contentIdentifier, event: event)
                }
            }

            if case let ContentRoute.eventDetailsLiveData(eventId) = contentIdentifier.contentRoute {
                
                if let eventLiveData = try? container.decode(SportRadarModels.EventLiveDataExtended.self, forKey: .change) {
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier, eventId: eventId , eventLiveDataExtended: eventLiveData)
                }
                else if path.contains("matchTime"),
                        let matchTime = try container.decodeIfPresent(String.self, forKey: .change),
                        let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: matchTime) {
                    
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: nil,
                                                                                            awayScore: nil,
                                                                                            matchTime: minutesPart,
                                                                                            status: nil,
                                                                                            scores: [:],
                                                                                            activePlayerServing: nil)
                    
                    
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                else if path.contains("COMPLETE"),
                        path.contains("STATUS"),
                        let changeDictionary = try container.decodeIfPresent([String: [String: String]].self, forKey: .change),
                        let eventDictionary = changeDictionary["EVENT"],
                        let newStatusString = eventDictionary[""] {
                    
                    let newStatus = EventStatus.init(value: newStatusString)
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: nil,
                                                                                            awayScore: nil,
                                                                                            matchTime: nil,
                                                                                            status: newStatus,
                                                                                            scores: [:],
                                                                                            activePlayerServing: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                else if path.contains("COMPLETE"),
                        path.contains("MATCH_SCORE"),
                        let changeDictionary = try container.decodeIfPresent([String: [String: Int]].self, forKey: .change),
                        let scoreDictionary = changeDictionary["COMPETITOR"]{
                    
                    let homeScore = scoreDictionary["home"]
                    let awayScore = scoreDictionary["away"]
                    
                    var scoresDict: [String: Score] = [:]
                    if let score = Score(stringValue: "MATCH_SCORE", homeScore: homeScore, awayScore: awayScore) {
                        scoresDict[score.key] = score
                    }
                    
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: scoreDictionary["home"],
                                                                                            awayScore: scoreDictionary["away"],
                                                                                            matchTime: nil,
                                                                                            status: nil,
                                                                                            scores: scoresDict,
                                                                                            activePlayerServing: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                else if path.contains("COMPLETE"),
                        path.contains("CURRENT_SCORE"),
                        let changeDictionary = try container.decodeIfPresent([String: [String: Int]].self, forKey: .change),
                        let scoreDictionary = changeDictionary["COMPETITOR"]{
                    
                    let homeScore = scoreDictionary["home"]
                    let awayScore = scoreDictionary["away"]
                    
                    var scoresDict: [String: Score] = [:]
                    if let score = Score(stringValue: "CURRENT_SCORE", homeScore: homeScore, awayScore: awayScore) {
                        scoresDict[score.key] = score
                    }
                    
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: scoreDictionary["home"],
                                                                                            awayScore: scoreDictionary["away"],
                                                                                            matchTime: nil,
                                                                                            status: nil,
                                                                                            scores: scoresDict,
                                                                                            activePlayerServing: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                else if path.contains("COMPLETE"),
                        path.contains("GAME_SCORE"),
                        let changeDictionary = try container.decodeIfPresent([String: [String: Int]].self, forKey: .change),
                        let scoreDictionary = changeDictionary["COMPETITOR"]{
                    
                    let homeScore = scoreDictionary["home"]
                    let awayScore = scoreDictionary["away"]
                    
                    var scoresDict: [String: Score] = [:]
                    if let score = Score(stringValue: "GAME_SCORE", homeScore: homeScore, awayScore: awayScore) {
                        scoresDict[score.key] = score
                    }
                    
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: scoreDictionary["home"],
                                                                                            awayScore: scoreDictionary["away"],
                                                                                            matchTime: nil,
                                                                                            status: nil,
                                                                                            scores: scoresDict,
                                                                                            activePlayerServing: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                else if path.contains("COMPLETE"),
                        let changeDictionary = try container.decodeIfPresent([String: [String: Int]].self, forKey: .change),
                        let scoreDictionary = changeDictionary["COMPETITOR"]{
                    
                    let pathParts = path.split(separator: "|")
                    
                    let homeScore = scoreDictionary["home"]
                    let awayScore = scoreDictionary["away"]
                    
                    var scoresDict: [String: Score] = [:]
                    if let setScore = pathParts.last {
                        let setScoreString = String(setScore)
                        if let score = Score(stringValue: setScoreString, homeScore: homeScore, awayScore: awayScore) {
                            scoresDict[score.key] = score
                        }
                    }
                    
                    let eventLiveDataExtended = SportRadarModels.EventLiveDataExtended.init(id: eventId,
                                                                                            homeScore: scoreDictionary["home"],
                                                                                            awayScore: scoreDictionary["away"],
                                                                                            matchTime: nil,
                                                                                            status: nil,
                                                                                            scores: scoresDict,
                                                                                            activePlayerServing: nil)
                    return .updateEventLiveDataExtended(contentIdentifier: contentIdentifier,
                                                        eventId: eventId,
                                                        eventLiveDataExtended: eventLiveDataExtended)
                    
                }
                // SERVE TEAM / PLAYER
                else if path.split(separator: "|").last?.lowercased() == "serve" {
                    var serveCodeString: String = ""
                    
                    // Simple as Int
                    if let serveInt = try? container.decode(Int.self, forKey: .change) {
                        serveCodeString = "\(serveInt)"
                    }
                    // Simple as String
                    else if let serveString = try? container.decode(String.self, forKey: .change) {
                        serveCodeString = serveString
                    }
                    // Inside an ["Event": "": 1] struct
                    else if let serveDictionary = try container.decodeIfPresent([String: [String: Int]].self, forKey: .change),
                            let emptyDict = serveDictionary["EVENT"], let serveInt = emptyDict[""] {
                        serveCodeString = "\(serveInt)"
                    }
                                
                    if serveCodeString == "1" {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .home)
                    }
                    else if serveCodeString == "2" {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .away)
                    }
                }
                               
                return .unknown
            }

            // ===========================
            if path.contains("idfosporttype") {
                if let sportCode = SocketMessageParseHelper.extractSportCode(path) {
                    if path.contains("numEvents") {
                        let liveEventsCount = try container.decode(Int.self, forKey: .change)
                        let sportType = SportType(name: sportCode,
                                                  alphaId: sportCode,
                                                  numberEvents: liveEventsCount,
                                                  numberOutrightEvents: 0,
                                                  numberOutrightMarkets: 0,
                                                  numberLiveEvents: liveEventsCount)
                        
                        return .liveSports(sportsTypes: [sportType])
                    }
                }
            }
            
            if path.contains("bonavigationnodes") {
                if let sportId = SocketMessageParseHelper.extractNodeId(path) {
                    if path.contains("numinplayevents") {
                        let liveEventsCount = try container.decode(String.self, forKey: .change)
                        return .updateAllSportsLiveCount(ContentIdentifier: contentIdentifier,
                                                         nodeId: sportId,
                                                         eventCount: Int(liveEventsCount) ?? 0)
                    }
                    if path.contains("numevents") {
                        let eventsCount = try container.decode(String.self, forKey: .change)
                        return .updateAllSportsEventCount(ContentIdentifier: contentIdentifier,
                                                          nodeId: sportId,
                                                          eventCount: Int(eventsCount) ?? 0)
                    }
                }
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
            else if path.contains("numMarkets"), let eventId = SocketMessageParseHelper.extractEventId(path) {
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
            else if path.contains("scores"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                
                let components = path.components(separatedBy: "|")
                guard
                    let lastComponent = components.last,
                    let changeContainer = try? container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change),
                    let homeScore = try? changeContainer.decodeIfPresent(Int.self, forKey: .home),
                    let awayScore = try? changeContainer.decodeIfPresent(Int.self, forKey: .away),
                    let score = Score(stringValue: lastComponent, homeScore: homeScore, awayScore: awayScore)
                else {
                    return .unknown
                }
                
                return .updateEventDetailedScore(contentIdentifier: contentIdentifier, eventId: eventId, detailedScore: score)
            }
            else if path.contains("scores") && (path.contains("MATCH_SCORE") || path.contains("CURRENT_SCORE")), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Updated score information
                let changeContainer = try container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change)
                let homeScore = try changeContainer.decodeIfPresent(Int.self, forKey: .home)
                let awayScore = try changeContainer.decodeIfPresent(Int.self, forKey: .away)
                return .updateEventScore(contentIdentifier: contentIdentifier, eventId: eventId, homeScore: homeScore, awayScore: awayScore)
            }
            else if path.contains("serve"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                if let newIsTradableString = try? container.decode(String.self, forKey: .change) {
                    // Updated tennis serve player information
                    if newIsTradableString == "1" {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .home)
                    }
                    else if newIsTradableString == "2" {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .away)
                    }
                }
                else if let newIsTradable = try? container.decode(Int.self, forKey: .change) {
                    // Updated tennis serve player information
                    if newIsTradable == 1 {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .home)
                    }
                    else if newIsTradable == 2 {
                        return .updateActivePlayer(contentIdentifier: contentIdentifier,
                                                   eventId: eventId,
                                                   serving: .away)
                    }
                }
            }
            else if path.contains("matchTime"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                // Match time
                let matchTime = try container.decode(String.self, forKey: .change)
                if let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: matchTime) {
                    return .updateEventTime(contentIdentifier: contentIdentifier, eventId: eventId, newTime: minutesPart)
                }
            }
            else if path.contains("status"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                let newStatus = try container.decode(String.self, forKey: .change)
                return .updateEventState(contentIdentifier: contentIdentifier, eventId: eventId, state: newStatus)
            }
            else if path.contains("selections") && path.contains("idfoselection") {
                if let changeContainer = try? container.nestedContainer(keyedBy: SelectionUpdateCodingKeys.self, forKey: .change),
                   let oddNumerator = try changeContainer.decodeIfPresent(String.self, forKey: .oddNumerator),
                   let oddDenominator = try changeContainer.decodeIfPresent(String.self, forKey: .oddDenominator),
                   let selectionId = try? changeContainer.decode(String.self, forKey: .selectionId) {
                    
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
            else if path.contains("markets") && path.contains("istradable"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                let newIsTradable = (try? container.decode(Bool.self, forKey: .change)) ?? true
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }
            else if path.contains("selections"), let selectionId = SocketMessageParseHelper.extractSelectionId(path) {
                print("Updated Selection \(selectionId)")
            }
            else if contentIdentifier.contentType == .market, // Is a contentRout of market updates
                    path == "istradable", // the path is istradable
                    case .market(let marketId) = contentIdentifier.contentRoute, // extract the marketId
                    let newIsTradable = try? container.decode(Bool.self, forKey: .change) {
                
                return .updateMarketTradability(contentIdentifier: contentIdentifier, marketId: marketId, isTradable: newIsTradable)
            }
            
            // print("ContentContainer ignored update for \(path) and associated change: Updated")
            return .unknown
        }

        private static func parseAdded(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {
            let contentTypeContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
            let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
            
            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
            
            if contentType == .eventMainMarket && path.lowercased().contains("idfomarket") {
                print("parseAdded break")
            }

            if case let ContentRoute.liveSports = contentIdentifier.contentRoute {
                if path.contains("idfosporttype"),
                   let newSport = try? container.decodeIfPresent(SportRadarModels.SportTypeDetails.self, forKey: .change) {
                    let newSportType = SportType(name: newSport.sportName,
                                                 alphaId: newSport.sportType.alphaId,
                                                 numberEvents: newSport.eventsCount, numberOutrightEvents: 0, numberOutrightMarkets: 0, numberLiveEvents: newSport.eventsCount)
                    
                    return .liveSports(sportsTypes: [newSportType])
                }
                    
            }

            if path.contains("idfomarket"), let newMarket = try? container.decode(SportRadarModels.Market.self, forKey: .change) {
                return .addMarket(contentIdentifier: contentIdentifier, market: newMarket)
            }
            else if path.contains("idfoevent"), let newEvent = try? container.decode(SportRadarModels.Event.self, forKey: .change) {
                return .addEvent(contentIdentifier: contentIdentifier, event: newEvent)
            }
            else if path.contains("idfosporttype"), let newSport = try? container.decodeIfPresent(SportRadarModels.SportTypeDetails.self, forKey: .change) {
                return .addSport(contentIdentifier: contentIdentifier, sportType: newSport.sportType)
            }
            else if path.contains("status"), let eventId = SocketMessageParseHelper.extractEventId(path) {
                let newStatus = try container.decode(String.self, forKey: .change)
                return .updateEventState(contentIdentifier: contentIdentifier, eventId: eventId, state: newStatus)
            }
            else if path.contains("scores"), let eventId = SocketMessageParseHelper.extractEventId(path) {                
                let components = path.components(separatedBy: "|")
                guard
                    let lastComponent = components.last,
                    let changeContainer = try? container.nestedContainer(keyedBy: ScoreUpdateCodingKeys.self, forKey: .change),
                    let homeScore = try? changeContainer.decodeIfPresent(Int.self, forKey: .home),
                    let awayScore = try? changeContainer.decodeIfPresent(Int.self, forKey: .away),
                    let score = Score(stringValue: lastComponent, homeScore: homeScore, awayScore: awayScore)
                else {
                    return .unknown
                }
                
                return .updateEventDetailedScore(contentIdentifier: contentIdentifier, eventId: eventId, detailedScore: score)
            }
            
            // print("ContentContainer ignored update for \(path) and associated change: Added")
            return .unknown
        }

        private static func parseRemoved(container: KeyedDecodingContainer<CodingKeys>) throws -> ContentContainer {

            let contentTypeContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
            let contentType = try contentTypeContainer.decode(ContentType.self, forKey: .contentType)
            
            let contentIdentifier = try container.decode(ContentIdentifier.self, forKey: .content)
            let path: String = try container.decodeIfPresent(String.self, forKey: .path) ?? ""

            if contentType == .eventMainMarket && path.lowercased().contains("idfomarket") {
                print("parseRemoved break")
            }

            if case ContentRoute.liveSports = contentIdentifier.contentRoute {
                if path.contains("idfosporttype"),
                   let sportCode = SocketMessageParseHelper.extractSportCode(path) {
                                        
                    let sportName = SportRadarModelMapper.sportTypeName(fromAlphaCode: sportCode)
                                        
                    let removedSport = SportType(name: sportName,
                                                 alphaId: sportCode,
                                                 numberEvents: 0, numberOutrightEvents: 0, numberOutrightMarkets: 0, numberLiveEvents: 0)
                    
                    return .liveSports(sportsTypes: [removedSport])
                }
                    
            }

            if contentIdentifier.contentType == .market, case .market(let marketId) = contentIdentifier.contentRoute {
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoselection"), let selectionId = SocketMessageParseHelper.extractSelectionId(path) {
                return .removeSelection(contentIdentifier: contentIdentifier, selectionId: selectionId)
            }
            else if path.contains("idfomarket"), let marketId = SocketMessageParseHelper.extractMarketId(path) {
                return .removeMarket(contentIdentifier: contentIdentifier, marketId: marketId)
            }
            else if path.contains("idfoevent"), let eventId = SocketMessageParseHelper.extractSportCode(path)  {
                return .removeEvent(contentIdentifier: contentIdentifier, eventId: eventId)
            }
            else if path.contains("idfosporttype"), let sportCode = SocketMessageParseHelper.extractSportCode(path) {
                return .removeSport(ContentIdentifier: contentIdentifier, sportCode: sportCode)
            }

            // print("ContentContainer ignored update for \(path) and associated change: Removed")
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
        case .allSports(let sportsTypes):
            return "All Sports - Sport Types count: \(sportsTypes.count)"
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

        case .updateEventMainMarket(let contentIdentifier, let event):
            return "Update Event Main Market (Content ID: \(contentIdentifier)) - Event: \(String(describing: event))"
        case .updateEventSecundaryMarkets(let contentIdentifier, let event):
            return "Update Event Secundary Markets (Content ID: \(contentIdentifier)) - Event: \(String(describing: event))"
            
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
        case .removeSport(let contentIdentifier, let sportCode):
            return "Remove Sport (Content ID: \(contentIdentifier)) - Sport Code: \(sportCode)"

        case .updateEventLiveDataExtended(let contentIdentifier, let eventId, let eventLiveDataExtended):
            return "Update Event LiveDataExtended (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - LiveDataExtended: \(eventLiveDataExtended)"

        case .updateAllSportsLiveCount(let contentIdentifier, let nodeId, let eventCount):
            return "Update All Sports Live Count (Content ID: \(contentIdentifier)) - Node ID: \(nodeId) - Event Count: \(eventCount)"
        case .updateAllSportsEventCount(let contentIdentifier, let nodeId, let eventCount):
            return "Update All Sports Event Count (Content ID: \(contentIdentifier)) - Node ID: \(nodeId) - Event Count: \(eventCount)"
        case .updateEventState(let contentIdentifier, let eventId, let state):
            return "Update Event State (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - State: \(state)"
        case .updateEventTime(let contentIdentifier, let eventId, let newTime):
            return "Update Event Time (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Time: \(newTime)"
        case .updateEventScore(let contentIdentifier, let eventId, let homeScore, let awayScore):
            return "Update Event Score (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - Home Score: \(String(describing: homeScore)) - Away Score: \(String(describing: awayScore))"
        case .updateActivePlayer(let contentIdentifier, let eventId, let serving):
            return "Update ActivePlayer serve (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - Serve: \(serving)"
            
        case .updateEventMarketCount(let contentIdentifier, let eventId, let newMarketCount):
            return "Update Event Market Count (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - New Market Count: \(newMarketCount)"

        case .updateMarketTradability(let contentIdentifier, let marketId, let isTradable):
            return "Update Market Tradability (Content ID: \(contentIdentifier)) - Market ID: \(marketId) - Tradable: \(isTradable)"

        case .updateOutcomeOdd(let contentIdentifier, let selectionId, let newOddNumerator, let newOddDenominator):
            return "Update Outcome Odd (Content ID: \(contentIdentifier)) - Selection ID: \(selectionId) - New Odd Numerator: \(String(describing: newOddNumerator)) - New Odd Denominator: \(String(describing: newOddDenominator))"
        case .updateOutcomeTradability(let contentIdentifier, let selectionId, let isTradable):
            return "Update Outcome Tradability (Content ID: \(contentIdentifier)) - Market ID: \(selectionId) - Tradable: \(isTradable)"

        case .updateEventDetailedScore(let contentIdentifier, let eventId, let detailedScore):
            return "Update Event Detailed Score (Content ID: \(contentIdentifier)) - Event ID: \(eventId) - Detailed Score: \(detailedScore)"
            
        case .unknown:
            return "Unknown ContentContainer"
        }
    }
}
