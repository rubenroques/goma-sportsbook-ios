//
//  EveryMatrix.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation

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

    enum EntityRecord: Codable {
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

    // MARK: - Response Parser

    struct ResponseParser {
        static func parseAndStore(response: AggregatorResponse, in store: EntityStore) {
            for record in response.records {
                switch record {
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
                    print("Unknown entity type: \(type)")
                }
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

        // Store entity by type and id
        func store<T: Entity>(_ entity: T) {
            queue.async(flags: .barrier) { [weak self] in
                let type = T.rawType
                if self?.entities[type] == nil {
                    self?.entities[type] = [:]
                }
                self?.entities[type]?[entity.id] = entity
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
                }
            }
        }

        // Clear all data
        func clear() {
            queue.async(flags: .barrier) { [weak self] in
                self?.entities.removeAll()
            }
        }
    }


}


