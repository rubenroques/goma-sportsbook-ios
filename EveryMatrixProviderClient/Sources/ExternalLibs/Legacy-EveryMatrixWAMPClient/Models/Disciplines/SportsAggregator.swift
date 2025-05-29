//
//  SportsAggregator.swift
//  Sportsbook
//
//  Created by André Lascas on 07/01/2022.
//

import Foundation

/*
extension EveryMatrix {

    enum SportsAggregatorContentType {
        case update(content: [SportsContentUpdate])
        case initialDump(content: [SportsContent])
    }

    struct SportsAggregator: Decodable {

        var messageType: SportsAggregatorContentType

        enum CodingKeys: String, CodingKey {
            case content = "records"
            case messageType = "messageType"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let messageTypeString = try container.decode(String.self, forKey: .messageType)
            if messageTypeString == "UPDATE" {
                let rawItems = try container.decode([FailableDecodable<SportsContentUpdate>].self, forKey: .content).compactMap({ $0.base })
                let filteredItems = rawItems.filter({
                    if case .unknown = $0 {
                        return false
                      }
                      return true
                })
                messageType = .update(content: filteredItems)
            }
            else if messageTypeString == "INITIAL_DUMP" {
                let items = try container.decode([FailableDecodable<SportsContent>].self, forKey: .content).compactMap({ $0.base })
                messageType = .initialDump(content: items)
            }
            else {
                messageType = .update(content: [])
            }
        }

        var content: [SportsContent]? {
            switch self.messageType {
            case .initialDump(let content):
                return content
            default: return nil
            }
        }

        var contentUpdates: [SportsContentUpdate]? {
            switch self.messageType {
            case .update(let contents):
                return contents
            default: return nil
            }
        }
    }

    ///
    enum SportsContentUpdateError: Error {
        case uknownUpdateType
        case invalidUpdateFormat
    }

    enum SportsContentUpdate: Decodable {
        // UPDATES
        case sportUpdate(id: String, numberOfLiveEvents: Int?)
        // CREATES
        case fullSportUpdate(sport: EveryMatrix.Discipline)
        case sportDelete(sportId: String)
        case unknown(typeName: String)

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case changeType = "changeType"
            case entityType = "entityType"
            case contentId = "id"
            case oddValue = "odds"
            case changedProperties = "changedProperties"
            case entity = "entity"
        }

        enum SportsCodingKeys: String, CodingKey {
            case numberOfMarkets = "numberOfMarkets"
            case numberOfLiveMarkets = "numberOfLiveMarkets"
            case numberOfLiveEvents = "numberOfLiveEvents"
            case numberOfLiveBettingOffers = "numberOfLiveBettingOffers"
            case numberOfEvents = "numberOfEvents"
            case numberOfUpcomingMatches = "numberOfUpcomingMatches"
            case numberOfBettingOffers = "numberOfBettingOffers"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard
                let changeTypeString = try? container.decode(String.self, forKey: .changeType),
                let entityTypeString = try? container.decode(String.self, forKey: .entityType)
            else {
                throw SportsContentUpdateError.uknownUpdateType
            }

            self = .unknown(typeName: entityTypeString)

            var contentUpdateType: SportsContentUpdate?

            if changeTypeString == "UPDATE", let contentId = try? container.decode(String.self, forKey: .contentId) {

                if entityTypeString == "SPORT" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: SportsCodingKeys.self, forKey: .changedProperties) {

                        let numberOfLiveEvents = try? changedPropertiesContainer.decode(Int.self, forKey: .numberOfLiveEvents)

                        self = .sportUpdate(id: contentId, numberOfLiveEvents: numberOfLiveEvents)

                        contentUpdateType = self

                    }
                }

            }
            else if changeTypeString == "CREATE", let contentId = try? container.decode(String.self, forKey: .contentId) {
                if let sport = try? container.decode(EveryMatrix.Discipline.self, forKey: .entity) {
                    contentUpdateType = .fullSportUpdate(sport: sport)

                }
            }
            else if changeTypeString == "DELETE", let contentId = try? container.decode(String.self, forKey: .contentId) {
                contentUpdateType = .sportDelete(sportId: contentId)
            }

            if let contentUpdateTypeValue = contentUpdateType {
                self = contentUpdateTypeValue
            }
            else {
                self = .unknown(typeName: entityTypeString)
            }

        }

    }

    ///

    enum SportsContent: Decodable {

        case sport(EveryMatrix.Discipline)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum SportsContentTypeKey: String, Decodable {

            case sport = "SPORT"
            case unknown

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type = try container.decode(String.self)
                if let contentTypeKey = SportsContentTypeKey(rawValue: type) {
                    self = contentTypeKey
                }
                else {
                    self = .unknown
                }
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let type = try? container.decode(SportsContentTypeKey.self, forKey: .type) else {
                self = .unknown
                return
            }

            let objectContainer = try decoder.singleValueContainer()

            switch type {

            case .sport:
                let sport = try objectContainer.decode(EveryMatrix.Discipline.self)
                self = .sport(sport)

            case .unknown:
                self = .unknown
            }
        }
    }

}
*/
