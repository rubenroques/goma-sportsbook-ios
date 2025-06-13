//
//  EveryMatrix.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import Combine

enum EveryMatrix {

}

extension EveryMatrix {

    /// Protocol for all entities that can be stored and referenced
    protocol Entity: Codable, Identifiable {
        var id: String { get }
        static var rawType: String { get }
    }

    /// Protocol for entities that can contain references to other entities
    protocol EntityContainer {
        func getReferencedIds() -> [String: [String]]
    }

    struct SportDTO: Entity {
        let id: String
        static let rawType: String = "SPORT"
        let name: String
        let shortName: String
        let isVirtual: Bool
        let numberOfEvents: Int
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let numberOfLiveEvents: Int
        let numberOfLiveMarkets: Int
        let numberOfLiveBettingOffers: Int
        let numberOfUpcomingMatches: Int
        let numberOfMatchesWhichWillHaveLiveOdds: String
        let childrenIds: [String]
        let displayChildren: Bool
        let showEventCategory: Bool
        let isTopSport: Bool
        let hasMatches: Bool
        let hasOutrights: Bool
        let parentId: String?
        let parentName: String?
        let parentShortName: String?
    }

    struct MatchDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "MATCH"
        let typeId: String
        let sportId: String
        let parentId: String
        let parentPartId: String
        let name: String
        let startTime: Int64
        let venueId: String
        let statusId: String
        let rootPartId: String
        let allowsLiveOdds: Bool
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let typeName: String
        let sportName: String
        let shortSportName: String
        let parentName: String
        let shortParentName: String
        let parentPartName: String
        let shortParentPartName: String
        let venueName: String
        let shortVenueName: String
        let statusName: String
        let rootPartName: String
        let shortRootPartName: String
        let shortName: String
        let parentStartTime: Int64
        let parentEndTime: Int64
        let parentTemplateId: String
        let homeParticipantId: String
        let homeParticipantName: String
        let awayParticipantId: String
        let awayParticipantName: String
        let homeShortParticipantName: String
        let awayShortParticipantName: String
        let categoryId: String
        let categoryName: String
        let displayChildren: Bool
        let layoutStyle: String

        func getReferencedIds() -> [String: [String]] {
            return [
                "Sport": [sportId],
                "Location": [venueId],
                "EventCategory": [categoryId]
            ]
        }
    }

    struct MarketDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "MARKET"
        let name: String
        let shortName: String
        let displayKey: String
        let displayName: String
        let displayShortName: String
        let eventId: String
        let eventPartId: String
        let bettingTypeId: String
        let numberOfOutcomes: Int
        let scoringUnitId: String
        let isComplete: Bool
        let isClosed: Bool
        let paramFloat1: Double?
        let bettingTypeName: String
        let shortBettingTypeName: String
        let eventPartName: String
        let mainLine: Bool
        let isAvailable: Bool
        let notAvailableSince: Int64?
        let shortEventPartName: String
        let scoringUnitName: String
        let asianLine: Bool
        let labelName: String?
        let labelStyle: String?
        let allowEachWay: Bool
        let allowStartingPrice: Bool

        func getReferencedIds() -> [String: [String]] {
            return [
                "Match": [eventId]
            ]
        }
    }

    struct OutcomeDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "OUTCOME"
        let typeId: String
        let statusId: String
        let eventId: String
        let eventPartId: String
        let paramFloat1: Double?
        let paramParticipantId1: String?
        let paramScoringUnitId1: String?
        let code: String
        let typeName: String
        let translatedName: String
        let shortTranslatedName: String
        let eventPartName: String
        let paramParticipantName1: String?
        let shortParamParticipantName1: String?
        let shortEventPartName: String
        let paramScoringUnitName1: String?
        let headerName: String?
        let headerShortName: String?
        let headerNameKey: String?

        func getReferencedIds() -> [String: [String]] {
            return [
                "Match": [eventId]
            ]
        }
    }

    struct BettingOfferDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "BETTING_OFFER"
        let providerId: String
        let outcomeId: String
        let bettingTypeId: String
        let statusId: String
        let isLive: Bool
        let odds: Double
        let lastChangedTime: Int64
        let bettingTypeName: String
        let shortBettingTypeName: String
        let isAvailable: Bool

        func getReferencedIds() -> [String: [String]] {
            return [
                "Outcome": [outcomeId]
            ]
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.BettingOfferDTO.CodingKeys> = try decoder.container(keyedBy: EveryMatrix.BettingOfferDTO.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.id)
            self.providerId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.providerId)
            self.outcomeId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.outcomeId)
            self.bettingTypeId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.bettingTypeId)
            self.statusId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.statusId)
            self.isLive = try container.decode(Bool.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.isLive)
            self.odds = try container.decode(Double.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.odds)
            self.lastChangedTime = try container.decode(Int64.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.lastChangedTime)
            self.bettingTypeName = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.bettingTypeName)
            self.shortBettingTypeName = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.shortBettingTypeName)
            self.isAvailable = try container.decode(Bool.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.isAvailable)
        }

    }

    struct LocationDTO: Entity {
        let id: String
        static let rawType: String = "LOCATION"
        let typeId: String
        let name: String
        let shortName: String
        let code: String?
    }

    struct EventCategoryDTO: Entity {
        let id: String
        static let rawType: String = "EVENT_CATEGORY"
        let sportId: String
        let sportName: String
        let name: String
        let shortName: String
        let numberOfEvents: Int
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let numberOfLiveEvents: Int
        let numberOfLiveMarkets: Int
        let numberOfLiveBettingOffers: Int
        let numberOfUpcomingMatches: Int
    }

    struct MarketOutcomeRelationDTO: Entity {
        let id: String
        static let rawType: String = "MARKET_OUTCOME_RELATION"
        let marketId: String
        let outcomeId: String
    }

    struct MainMarketDTO: Entity {
        let id: String
        static let rawType: String = "MAIN_MARKET"
        let bettingTypeId: String
        let eventPartId: String
        let sportId: String
        let bettingTypeName: String
        let eventPartName: String
        let numberOfOutcomes: Int?
        let liveMarket: Bool
        let outright: Bool
    }

    // DTOs that were missing from example.txt
    struct MarketInfoDTO: Entity {
        let id: String
        static let rawType: String = "MARKET_INFO"
        let marketInfo: String
        let displayKey: String
    }

    struct NextMatchesNumberDTO: Entity {
        let id: String
        static let rawType: String = "NEXT_MATCHES_NUMBER"
        let numberOfNextEvents: Int
    }

    // MARK: - Aggregator Response
    struct AggregatorResponse: Codable {
        let version: String
        let format: String
        let messageType: String
        let records: [EntityRecord]
    }

    // MARK: - Change Types
    enum ChangeType: String, Codable {
        case create = "CREATE"
        case update = "UPDATE"
        case delete = "DELETE"
    }

    // MARK: - Entity Record with Change Support
    enum EntityRecord: Codable {
        // INITIAL_DUMP records (full entities)
        case sport(SportDTO)
        case match(MatchDTO)
        case market(MarketDTO)
        case outcome(OutcomeDTO)
        case bettingOffer(BettingOfferDTO)
        case location(LocationDTO)
        case eventCategory(EventCategoryDTO)
        case marketOutcomeRelation(MarketOutcomeRelationDTO)
        case mainMarket(MainMarketDTO)
        case marketInfo(MarketInfoDTO)
        case nextMatchesNumber(NextMatchesNumberDTO)

        // UPDATE/DELETE/CREATE records with change metadata
        case changeRecord(ChangeRecord)
        case unknown(type: String)

        private enum CodingKeys: String, CodingKey {
            case type = "_type"
            case entityType
            case changeType
            case id
            case entity
            case changedProperties
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Check if this is a change record (has changeType)
            if container.contains(.changeType) {
                let changeRecord = try ChangeRecord(from: decoder)
                self = .changeRecord(changeRecord)
                return
            }

            // Otherwise, decode as original entity type
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "SPORT":
                let sport = try SportDTO(from: decoder)
                self = .sport(sport)
            case "MATCH":
                let match = try MatchDTO(from: decoder)
                self = .match(match)
            case "MARKET":
                let market = try MarketDTO(from: decoder)
                self = .market(market)
            case "OUTCOME":
                let outcome = try OutcomeDTO(from: decoder)
                self = .outcome(outcome)
            case "BETTING_OFFER":
                let offer = try BettingOfferDTO(from: decoder)
                self = .bettingOffer(offer)
            case "LOCATION":
                let location = try LocationDTO(from: decoder)
                self = .location(location)
            case "EVENT_CATEGORY":
                let category = try EventCategoryDTO(from: decoder)
                self = .eventCategory(category)
            case "MARKET_OUTCOME_RELATION":
                let relation = try MarketOutcomeRelationDTO(from: decoder)
                self = .marketOutcomeRelation(relation)
            case "MAIN_MARKET":
                let mainMarket = try MainMarketDTO(from: decoder)
                self = .mainMarket(mainMarket)
            case "MARKET_INFO":
                let marketInfo = try MarketInfoDTO(from: decoder)
                self = .marketInfo(marketInfo)
            case "NEXT_MATCHES_NUMBER":
                let nextMatches = try NextMatchesNumberDTO(from: decoder)
                self = .nextMatchesNumber(nextMatches)
            default:
                self = .unknown(type: type)
            }
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .sport(let dto):
                try dto.encode(to: encoder)
            case .match(let dto):
                try dto.encode(to: encoder)
            case .market(let dto):
                try dto.encode(to: encoder)
            case .outcome(let dto):
                try dto.encode(to: encoder)
            case .bettingOffer(let dto):
                try dto.encode(to: encoder)
            case .location(let dto):
                try dto.encode(to: encoder)
            case .eventCategory(let dto):
                try dto.encode(to: encoder)
            case .marketOutcomeRelation(let dto):
                try dto.encode(to: encoder)
            case .mainMarket(let dto):
                try dto.encode(to: encoder)
            case .marketInfo(let dto):
                try dto.encode(to: encoder)
            case .nextMatchesNumber(let dto):
                try dto.encode(to: encoder)
            case .changeRecord(let record):
                try record.encode(to: encoder)
            case .unknown:
                var container = encoder.container(keyedBy: CodingKeys.self)
                if case .unknown(let type) = self {
                    try container.encode(type, forKey: .type)
                }
            }
        }
    }

    // MARK: - Change Record Structure
    struct ChangeRecord: Codable {
        let changeType: ChangeType
        let entityType: String
        let id: String
        let entity: EntityData?  // For CREATE operations
        let changedProperties: [String: AnyCodable]?  // For UPDATE operations

        private enum CodingKeys: String, CodingKey {
            case changeType
            case entityType
            case id
            case entity
            case changedProperties
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.ChangeRecord.CodingKeys> = try decoder.container(keyedBy: EveryMatrix.ChangeRecord.CodingKeys.self)
            self.changeType = try container.decode(EveryMatrix.ChangeType.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.changeType)
            self.entityType = try container.decode(String.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.entityType)
            self.id = try container.decode(String.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.id)
            self.entity = try container.decodeIfPresent(EveryMatrix.EntityData.self, forKey: EveryMatrix.ChangeRecord.CodingKeys.entity)
            self.changedProperties = try container.decodeIfPresent([String : EveryMatrix.AnyCodable].self, forKey: EveryMatrix.ChangeRecord.CodingKeys.changedProperties)
        }
    }

    // MARK: - Entity Data Union
    enum EntityData: Codable {
        case sport(SportDTO)
        case match(MatchDTO)
        case market(MarketDTO)
        case outcome(OutcomeDTO)
        case bettingOffer(BettingOfferDTO)
        case location(LocationDTO)
        case eventCategory(EventCategoryDTO)
        case marketOutcomeRelation(MarketOutcomeRelationDTO)
        case mainMarket(MainMarketDTO)
        case marketInfo(MarketInfoDTO)
        case nextMatchesNumber(NextMatchesNumberDTO)
        case unknown(type: String)

        private enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "SPORT":
                let sport = try SportDTO(from: decoder)
                self = .sport(sport)
            case "MATCH":
                let match = try MatchDTO(from: decoder)
                self = .match(match)
            case "MARKET":
                let market = try MarketDTO(from: decoder)
                self = .market(market)
            case "OUTCOME":
                let outcome = try OutcomeDTO(from: decoder)
                self = .outcome(outcome)
            case "BETTING_OFFER":
                let offer = try BettingOfferDTO(from: decoder)
                self = .bettingOffer(offer)
            case "LOCATION":
                let location = try LocationDTO(from: decoder)
                self = .location(location)
            case "EVENT_CATEGORY":
                let category = try EventCategoryDTO(from: decoder)
                self = .eventCategory(category)
            case "MARKET_OUTCOME_RELATION":
                let relation = try MarketOutcomeRelationDTO(from: decoder)
                self = .marketOutcomeRelation(relation)
            case "MAIN_MARKET":
                let mainMarket = try MainMarketDTO(from: decoder)
                self = .mainMarket(mainMarket)
            case "MARKET_INFO":
                let marketInfo = try MarketInfoDTO(from: decoder)
                self = .marketInfo(marketInfo)
            case "NEXT_MATCHES_NUMBER":
                let nextMatches = try NextMatchesNumberDTO(from: decoder)
                self = .nextMatchesNumber(nextMatches)
            default:
                self = .unknown(type: type)
            }
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .sport(let dto):
                try dto.encode(to: encoder)
            case .match(let dto):
                try dto.encode(to: encoder)
            case .market(let dto):
                try dto.encode(to: encoder)
            case .outcome(let dto):
                try dto.encode(to: encoder)
            case .bettingOffer(let dto):
                try dto.encode(to: encoder)
            case .location(let dto):
                try dto.encode(to: encoder)
            case .eventCategory(let dto):
                try dto.encode(to: encoder)
            case .marketOutcomeRelation(let dto):
                try dto.encode(to: encoder)
            case .mainMarket(let dto):
                try dto.encode(to: encoder)
            case .marketInfo(let dto):
                try dto.encode(to: encoder)
            case .nextMatchesNumber(let dto):
                try dto.encode(to: encoder)
            case .unknown:
                var container = encoder.container(keyedBy: CodingKeys.self)
                if case .unknown(let type) = self {
                    try container.encode(type, forKey: .type)
                }
            }
        }
    }

    // MARK: - AnyCodable for changedProperties
    struct AnyCodable: Codable, CustomStringConvertible, CustomDebugStringConvertible {
        let value: Any

        init<T>(_ value: T?) {
            self.value = value ?? ()
        }

     init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()

          // Handle nil first
          if container.decodeNil() {
              value = ()
              return
          }

          // Try string first (most specific, can't be confused with other types)
          if let string = try? container.decode(String.self) {
              value = string
              return
          }

          // For numbers, try Int first, then Double
          // This preserves integer precision when possible
          if let int = try? container.decode(Int.self) {
              value = int
              return
          }

          // If Int failed, it's either a Double or too large for Int
          if let double = try? container.decode(Double.self) {
              value = double
              return
          }

          // Try Bool LAST to avoid the numeric-as-boolean issue
          if let bool = try? container.decode(Bool.self) {
              value = bool
              return
          }

          throw DecodingError.dataCorrupted(
              DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode value")
          )
      }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch value {
            case let int as Int:
                try container.encode(int)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let bool as Bool:
                try container.encode(bool)
            default:
                try container.encodeNil()
            }
        }
        
        public var description: String {
            switch value {
            case is Void:
                return String(describing: nil as Any?)
            case let value as CustomStringConvertible:
                return value.description
            default:
                return String(describing: value)
            }
        }
        
        public var debugDescription: String {
            switch value {
            case let value as CustomDebugStringConvertible:
                return "AnyDecodable(\(value.debugDescription))"
            default:
                return "AnyDecodable(\(description))"
            }
        }
    }
    

    // MARK: - Response Parser

    struct ResponseParser {
        static func parseAndStore(response: AggregatorResponse, in store: EntityStore) {
            for record in response.records {
                switch record {
                // INITIAL_DUMP records - store full entities
                case .sport(let dto):
                    store.store(dto)
                case .match(let dto):
                    store.store(dto)
                case .market(let dto):
                    store.store(dto)
                case .outcome(let dto):
                    store.store(dto)
                case .bettingOffer(let dto):
                    store.store(dto)
                case .location(let dto):
                    store.store(dto)
                case .eventCategory(let dto):
                    store.store(dto)
                case .marketOutcomeRelation(let dto):
                    store.store(dto)
                case .mainMarket(let dto):
                    store.store(dto)
                case .marketInfo(let dto):
                    store.store(dto)
                case .nextMatchesNumber(let dto):
                    store.store(dto)

                // UPDATE/DELETE/CREATE records - handle changes
                case .changeRecord(let changeRecord):
                    handleChangeRecord(changeRecord, in: store)

                case .unknown(let type):
                    print("Unknown entity type: \(type)")
                }
            }
        }

        private static func handleChangeRecord(_ change: ChangeRecord, in store: EntityStore) {
            switch change.changeType {
            case .create:
                
                /*
                // CREATE: Store the full entity
                guard let entityData = change.entity else {
                    print("CREATE change record missing entity data for \(change.entityType):\(change.id)")
                    return
                }
                storeEntityData(entityData, in: store)
                */
                break
            case .update:
                // UPDATE: Merge changedProperties with existing entity
                guard let changedProperties = change.changedProperties else {
                    print("UPDATE change record missing changedProperties for \(change.entityType):\(change.id)")
                    return
                }
                
                if change.entityType == BettingOfferDTO.rawType && changedProperties.keys.contains("odds"){
                    store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                }
                else {
                    return
                }
                
            case .delete:
                // DELETE: Remove entity from store
                // store.deleteEntity(type: change.entityType, id: change.id)
                break
            }
        }

        private static func storeEntityData(_ entityData: EntityData, in store: EntityStore) {
            switch entityData {
            case .sport(let dto):
                store.store(dto)
            case .match(let dto):
                store.store(dto)
            case .market(let dto):
                store.store(dto)
            case .outcome(let dto):
                store.store(dto)
            case .bettingOffer(let dto):
                store.store(dto)
            case .location(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                store.store(dto)
            case .mainMarket(let dto):
                store.store(dto)
            case .marketInfo(let dto):
                store.store(dto)
            case .nextMatchesNumber(let dto):
                store.store(dto)
            case .unknown(let type):
                print("Unknown entity data type: \(type)")
            }
        }
    }

}

extension EveryMatrix {

    // MARK: -  Models (for UI)
    struct Sport: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let isVirtual: Bool?
        let numberOfEvents: Int?
        let numberOfLiveEvents: Int?
        let numberOfUpcomingMatches: Int?
        let showEventCategory: Bool?
        let isTopSport: Bool?
    }

    struct Location: Identifiable, Hashable {
        let id: String
        let typeId: String
        let name: String
        let shortName: String?
        let code: String?
    }

    struct EventCategory: Identifiable, Hashable {
        let id: String
        let sportId: String
        let sportName: String?
        let name: String
        let shortName: String?
        let numberOfEvents: Int?
        let numberOfLiveEvents: Int?
        let numberOfUpcomingMatches: Int?
    }


    struct Match: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let startTime: Date
        let sport: Sport?
        let venue: Location?
        let competitionId: String?
        let competitionName: String?
        let category: EventCategory?
        let homeParticipant: Participant?
        let awayParticipant: Participant?
        let status: MatchStatus
        let markets: [Market]
        let allowsLiveOdds: Bool?
        let numberOfMarkets: Int?
        let numberOfBettingOffers: Int?

        struct Participant: Identifiable, Hashable {
            let id: String
            let name: String
            let shortName: String
        }

        struct MatchStatus: Identifiable, Hashable {
            let id: String
            let name: String
        }
    }

    struct Market: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let displayName: String?
        let bettingType: BettingType?
        let outcomes: [Outcome]
        let isAvailable: Bool?
        let isMainLine: Bool?
        let paramFloat1: Double?

        struct BettingType: Identifiable, Hashable {
            let id: String
            let name: String
            let shortName: String
        }
    }

    struct Outcome: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let code: String
        let bettingOffers: [BettingOffer]
        let headerName: String?
        let headerNameKey: String?
    }

    struct BettingOffer: Identifiable, Hashable {
        let id: String
        let odds: Double
        let isAvailable: Bool
        let isLive: Bool
        let lastChangedTime: Date
        let providerId: String
    }

    /// Protocol for building hierarchical objects from flat data
    protocol HierarchicalBuilder {
        associatedtype FlatType: Entity
        associatedtype OutputType

        static func build(from entity: FlatType, store: EntityStore) -> OutputType?
    }

    // MARK: -  Builders
    struct MatchBuilder: HierarchicalBuilder {
        typealias FlatType = MatchDTO
        typealias OutputType = Match

        static func build(from match: MatchDTO, store: EntityStore) -> Match? {
            // Get related entities
            let sportDTO = store.get(SportDTO.self, id: match.sportId)
            let venueDTO = store.get(LocationDTO.self, id: match.venueId)
            let categoryDTO = store.get(EventCategoryDTO.self, id: match.categoryId)

            // Convert DTOs to UI models using builders
            let sport = sportDTO.flatMap { SportBuilder.build(from: $0, store: store) }
            let venue = venueDTO.flatMap { LocationBuilder.build(from: $0, store: store) }
            let category = categoryDTO.flatMap { EventCategoryBuilder.build(from: $0, store: store) }

            // Get markets for this match
            let allMarkets = store.getAll(MarketDTO.self)
            let matchMarkets = allMarkets.filter { $0.eventId == match.id }

            // Build hierarchical markets
            let hierarchicalMarkets = matchMarkets.compactMap { market in
                MarketBuilder.build(from: market, store: store)
            }

            return Match(
                id: match.id,
                name: match.name,
                shortName: match.shortName,
                startTime: Date(timeIntervalSince1970: TimeInterval(match.startTime / 1000)),
                sport: sport,
                venue: venue,
                competitionId: match.parentId,
                competitionName: match.parentName,
                category: category,
                homeParticipant: Match.Participant(
                    id: match.homeParticipantId,
                    name: match.homeParticipantName,
                    shortName: match.homeShortParticipantName
                ),
                awayParticipant: Match.Participant(
                    id: match.awayParticipantId,
                    name: match.awayParticipantName,
                    shortName: match.awayShortParticipantName
                ),
                status: Match.MatchStatus(
                    id: match.statusId,
                    name: match.statusName
                ),
                markets: hierarchicalMarkets,
                allowsLiveOdds: match.allowsLiveOdds,
                numberOfMarkets: match.numberOfMarkets,
                numberOfBettingOffers: match.numberOfBettingOffers
            )
        }
    }

    struct MarketBuilder: HierarchicalBuilder {
        typealias FlatType = MarketDTO
        typealias OutputType = Market

        static func build(from market: MarketDTO, store: EntityStore) -> Market? {
            // Get outcomes for this market
            let allOutcomes = store.getAll(OutcomeDTO.self)
            let allRelations = store.getAll(MarketOutcomeRelationDTO.self)

            // Find outcomes related to this market
            let relatedOutcomeIds = allRelations
                .filter { $0.marketId == market.id }
                .map { $0.outcomeId }

            let marketOutcomes = allOutcomes.filter { relatedOutcomeIds.contains($0.id) }

            // Build hierarchical outcomes
            let hierarchicalOutcomes = marketOutcomes.compactMap { outcome in
                OutcomeBuilder.build(from: outcome, store: store)
            }

            return Market(
                id: market.id,
                name: market.name,
                shortName: market.shortName,
                displayName: market.displayName,
                bettingType: Market.BettingType(
                    id: market.bettingTypeId,
                    name: market.bettingTypeName,
                    shortName: market.shortBettingTypeName
                ),
                outcomes: hierarchicalOutcomes,
                isAvailable: market.isAvailable,
                isMainLine: market.mainLine,
                paramFloat1: market.paramFloat1
            )
        }
    }

    struct OutcomeBuilder: HierarchicalBuilder {
        typealias FlatType = OutcomeDTO
        typealias OutputType = Outcome

        static func build(from outcome: OutcomeDTO, store: EntityStore) -> Outcome? {
            // Get betting offers for this outcome
            let allBettingOffers = store.getAll(BettingOfferDTO.self)
            let outcomeBettingOffers = allBettingOffers.filter { $0.outcomeId == outcome.id }

            // Build hierarchical betting offers
            let hierarchicalBettingOffers = outcomeBettingOffers.compactMap { offer in
                BettingOfferBuilder.build(from: offer, store: store)
            }

            return Outcome(
                id: outcome.id,
                name: outcome.translatedName,
                shortName: outcome.shortTranslatedName,
                code: outcome.code,
                bettingOffers: hierarchicalBettingOffers,
                headerName: outcome.headerName,
                headerNameKey: outcome.headerNameKey
            )
        }
    }

    struct BettingOfferBuilder: HierarchicalBuilder {
        typealias FlatType = BettingOfferDTO
        typealias OutputType = BettingOffer

        static func build(from offer: BettingOfferDTO, store: EntityStore) -> BettingOffer? {
            return BettingOffer(
                id: offer.id,
                odds: offer.odds,
                isAvailable: offer.isAvailable,
                isLive: offer.isLive,
                lastChangedTime: Date(timeIntervalSince1970: TimeInterval(offer.lastChangedTime / 1000)),
                providerId: offer.providerId
            )
        }
    }

    struct SportBuilder: HierarchicalBuilder {
        typealias FlatType = SportDTO
        typealias OutputType = Sport

        static func build(from sport: SportDTO, store: EntityStore) -> Sport? {
            return Sport(
                id: sport.id,
                name: sport.name,
                shortName: sport.shortName,
                isVirtual: sport.isVirtual,
                numberOfEvents: sport.numberOfEvents,
                numberOfLiveEvents: sport.numberOfLiveEvents,
                numberOfUpcomingMatches: sport.numberOfUpcomingMatches,
                showEventCategory: sport.showEventCategory,
                isTopSport: sport.isTopSport
            )
        }
    }

    struct LocationBuilder: HierarchicalBuilder {
        typealias FlatType = LocationDTO
        typealias OutputType = Location

        static func build(from location: LocationDTO, store: EntityStore) -> Location? {
            return Location(
                id: location.id,
                typeId: location.typeId,
                name: location.name,
                shortName: location.shortName,
                code: location.code
            )
        }
    }

    struct EventCategoryBuilder: HierarchicalBuilder {
        typealias FlatType = EventCategoryDTO
        typealias OutputType = EventCategory

        static func build(from category: EventCategoryDTO, store: EntityStore) -> EventCategory? {
            return EventCategory(
                id: category.id,
                sportId: category.sportId,
                sportName: category.sportName,
                name: category.name,
                shortName: category.shortName,
                numberOfEvents: category.numberOfEvents,
                numberOfLiveEvents: category.numberOfLiveEvents,
                numberOfUpcomingMatches: category.numberOfUpcomingMatches
            )
        }
    }

    // MARK: - Base Entity Store
    class EntityStore: ObservableObject {
        @Published private var entities: [String: [String: any Entity]] = [:]
        private let queue = DispatchQueue(label: "entity.store.queue", attributes: .concurrent)

        // MARK: - Publisher Infrastructure
        private var entityPublishers: [String: [String: CurrentValueSubject<(any Entity)?, Never>]] = [:]
        private let publisherQueue = DispatchQueue(label: "entity.publisher.queue", attributes: .concurrent)
        private var cancellables = Set<AnyCancellable>()

        // Store entity by type and id
        func store<T: Entity>(_ entity: T) {
            queue.async(flags: .barrier) { [weak self] in
                let type = T.rawType
                if self?.entities[type] == nil {
                    self?.entities[type] = [:]
                }
                self?.entities[type]?[entity.id] = entity

                // Notify observers of the change
                self?.notifyEntityChange(entity)
            }
        }

        // Retrieve entity by type and id
        func get<T: Entity>(_ type: T.Type, id: String) -> T? {
            return queue.sync {
                guard let typeDict = entities[T.rawType] else { return nil }
                return typeDict[id] as? T
            }
        }

        // Get all entities of a specific type
        func getAll<T: Entity>(_ type: T.Type) -> [T] {
            return queue.sync {
                guard let typeDict = entities[T.rawType] else { return [] }
                return typeDict.values.compactMap { $0 as? T }
            }
        }

        // Store multiple entities
        func store<T: Entity>(_ entities: [T]) {
            queue.async(flags: .barrier) { [weak self] in
                for entity in entities {
                    let type = T.rawType
                    if self?.entities[type] == nil {
                        self?.entities[type] = [:]
                    }
                    self?.entities[type]?[entity.id] = entity

                    // Notify observers of each change
                    self?.notifyEntityChange(entity)
                }
            }
        }

        // Clear all data
        func clear() {
            queue.async(flags: .barrier) { [weak self] in
                self?.entities.removeAll()
            }
        }

        // Update entity with changed properties
        func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyCodable]) {
            queue.async(flags: .barrier) { [weak self] in
                guard let existingEntity = self?.entities[entityType]?[id] else {
                    print("Cannot update entity \(entityType):\(id) - entity not found")
                    return
                }

                // Create updated entity by merging changed properties
                let updatedEntity = self?.mergeChangedProperties(entity: existingEntity, changes: changedProperties)

                if let updatedEntityValue = updatedEntity {
                    self?.entities[entityType]?[id] = updatedEntityValue

                    // Notify observers of the update
                    self?.notifyEntityChange(updatedEntityValue)
                }
            }
        }

        // Delete entity from store
        func deleteEntity(type entityType: String, id: String) {
            queue.async(flags: .barrier) { [weak self] in
                self?.entities[entityType]?[id] = nil
                
                // print("Deleted entity \(entityType):\(id)")

                // Notify observers of the deletion
                self?.notifyEntityDeletion(entityType: entityType, id: id)
            }
        }

        // Helper method to merge changed properties into existing entity
        private func mergeChangedProperties(entity: any Entity, changes: [String: AnyCodable]) -> (any Entity)? {
            // This is complex because we need to create a new instance with updated properties
            // For now, we'll use a reflection-based approach

            // Convert entity to JSON, update properties, and decode back
            do {
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()

                // Encode existing entity to JSON
                var entityData = try encoder.encode(entity)
                var json = try JSONSerialization.jsonObject(with: entityData) as? [String: Any] ?? [:]

                // Apply changed properties
                for (key, value) in changes {
                    json[key] = value.value
                }

                // Encode back to data
                entityData = try JSONSerialization.data(withJSONObject: json)

                // Decode to appropriate type based on entity type
                switch type(of: entity).rawType {
                case "SPORT":
                    return try decoder.decode(SportDTO.self, from: entityData)
                case "MATCH":
                    return try decoder.decode(MatchDTO.self, from: entityData)
                case "MARKET":
                    return try decoder.decode(MarketDTO.self, from: entityData)
                case "OUTCOME":
                    return try decoder.decode(OutcomeDTO.self, from: entityData)
                case "BETTING_OFFER":
                    return try decoder.decode(BettingOfferDTO.self, from: entityData)
                case "LOCATION":
                    return try decoder.decode(LocationDTO.self, from: entityData)
                case "EVENT_CATEGORY":
                    return try decoder.decode(EventCategoryDTO.self, from: entityData)
                case "MARKET_OUTCOME_RELATION":
                    return try decoder.decode(MarketOutcomeRelationDTO.self, from: entityData)
                case "MAIN_MARKET":
                    return try decoder.decode(MainMarketDTO.self, from: entityData)
                case "MARKET_INFO":
                    return try decoder.decode(MarketInfoDTO.self, from: entityData)
                case "NEXT_MATCHES_NUMBER":
                    return try decoder.decode(NextMatchesNumberDTO.self, from: entityData)
                default:
                    print("Unknown entity type for merge: \(type(of: entity).rawType)")
                    return nil
                }
            } catch {
                print("Failed to merge changed properties for \(type(of: entity).rawType):\(entity.id) - \(error)")
                return nil
            }
        }

        // MARK: - Entity Observation Methods

        /// Observe changes to a specific entity by type and ID
        func observeEntity<T: Entity>(_ type: T.Type, id: String) -> AnyPublisher<T?, Never> {
            return self.publisherQueue.sync { [weak self] in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }

                // Get current entity value
                let currentEntity = self.queue.sync {
                    self.entities[T.rawType]?[id] as? T
                }

                // Get or create publisher for this entity
                let publisher = self.getOrCreatePublisher(entityType: T.rawType, id: id, currentValue: currentEntity)

                // Return publisher that already has current value and future changes
                return publisher.compactMap { $0 as? T }.eraseToAnyPublisher()
            }
        }

        /// Convenience method to observe market changes
        func observeMarket(id: String) -> AnyPublisher<MarketDTO?, Never> {
            print("ManualDebug: observeMarket(id: \(id)")
            return observeEntity(MarketDTO.self, id: id)
        }

        /// Convenience method to observe outcome changes
        func observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never> {
            print("ManualDebug: observeOutcome(id: \(id)")
            return observeEntity(OutcomeDTO.self, id: id)
        }

        /// Convenience method to observe betting offer changes
        func observeBettingOffer(id: String) -> AnyPublisher<BettingOfferDTO?, Never> {
            return observeEntity(BettingOfferDTO.self, id: id)
        }

        /// Convenience method to observe match changes
        func observeMatch(id: String) -> AnyPublisher<MatchDTO?, Never> {
            return observeEntity(MatchDTO.self, id: id)
        }

        // MARK: - Publisher Management

        private func getOrCreatePublisher(entityType: String, id: String, currentValue: (any Entity)? = nil) -> CurrentValueSubject<(any Entity)?, Never> {

            if self.entityPublishers[entityType] == nil {
                self.entityPublishers[entityType] = [:]
            }

            if let existingPublisher = self.entityPublishers[entityType]?[id] {
                return existingPublisher
            }

            // Create CurrentValueSubject with current value (or nil if not found)
            let initialValue = currentValue ?? self.queue.sync {
                self.entities[entityType]?[id]
            }
            
            let newPublisher = CurrentValueSubject<(any Entity)?, Never>(initialValue)
            self.entityPublishers[entityType]?[id] = newPublisher

            print("ManualDebug: Created new publisher for \(entityType)/\(id)")
            
            return newPublisher
        }

        private func notifyEntityChange(_ entity: (any Entity)?) {
            guard let entity = entity else {
                // Handle deletion case - notify with nil
                return
            }

            let entityType = type(of: entity).rawType
            let id = entity.id

            publisherQueue.async { [weak self] in
                // Update CurrentValueSubject with new value if it exists
                if let publisher = self?.entityPublishers[entityType]?[id] {
                    // The publisher exists, something has subscribed to this
                    print("ManualDebug: Notified publisher for \(entityType)/\(id)")
                    publisher.send(entity)
                }
            }
        }

        private func notifyEntityDeletion(entityType: String, id: String) {
            publisherQueue.async { [weak self] in
                // Update CurrentValueSubject with nil to indicate deletion
                self?.entityPublishers[entityType]?[id]?.send(nil)
            }
        }

        // MARK: - Publisher Cleanup

        private func cleanupUnusedPublishers() {
            publisherQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }

                // Remove publishers with no active subscribers
                // This is a simplified cleanup - can be enhanced with subscription counting
                for (entityType, publishersDict) in self.entityPublishers {
                    let filteredDict = publishersDict.filter { (_, publisher) in
                        // Keep publishers that have active subscriptions
                        // For now, we'll keep all publishers for simplicity
                        return true
                    }
                    self.entityPublishers[entityType] = filteredDict
                }
            }
        }
    }


}


