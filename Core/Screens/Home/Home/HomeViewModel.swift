//
//  HomeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class HomeViewModel {

    enum Content {
        case userMessage
        case userFavorites
        case bannerLine
        case sport(Sport)
    }

    var dataChangedPublisher = PassthroughSubject<Void, Never>.init()

    var title = CurrentValueSubject<String, Never>.init("Init")

    private var userMessages: [String] = []
    private var userFavorites: [String] = []
    private var banners: [BannerInfo] = []

    private var sportsToFetch: [Sport] = []

    private var viewModelsDictionary: [String: SportLineViewModel] = [:]

    //
    // EM Registers
    private var bannersInfoRegister: EndpointPublisherIdentifiable?

    // Combine Publishers
    private var bannersInfoPublisher: AnyCancellable?

    // Updatable Storage
    private var store: HomeStore = HomeStore()

    private var cancellables: Set<AnyCancellable> = []

    var testSportLineViewModel: SportLineViewModel

    // MARK: - Life Cycle
    init() {
        title.send("Home")

        self.testSportLineViewModel = SportLineViewModel(sport: Sport.football, matchesType: SportLineViewModel.MatchesType.topCompetition, store: self.store)
        self.requestSports()
    }

    func requestSports() {

        let language = "en"
        Env.everyMatrixClient.getDisciplines(language: language)
            .map(\.records)
            .compactMap({ $0 })
            .sink(receiveCompletion: { _ in

            }, receiveValue: { response in
                self.sportsToFetch = Array(response.map(Sport.init(discipline:)).prefix(10))
                self.dataChangedPublisher.send()
            })
            .store(in: &cancellables)
    }

    // Banners
    func stopBannerUpdates() {
        if let bannersInfoRegister = bannersInfoRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: bannersInfoRegister)
        }

        self.bannersInfoPublisher?.cancel()
        self.bannersInfoPublisher = nil
    }

    func fetchBanners() {

        self.stopBannerUpdates()

        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")

        self.bannersInfoPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.bannersInfoRegister = publisherIdentifiable
                case .initialContent(let responde):
                    print("HomeViewModel bannersInfo initialContent")
                    let sortedBanners = (responde.records ?? []).sorted {
                        $0.priorityOrder ?? 0 < $1.priorityOrder ?? 1
                    }
                    self?.banners = sortedBanners.map({
                        BannerInfo(type: $0.type,
                                   id: $0.id,
                                   matchId: $0.matchID,
                                   imageURL: $0.imageURL,
                                   priorityOrder: $0.priorityOrder)
                    })
                    self?.stopBannerUpdates()
                case .updatedContent:
                    ()
                case .disconnect:
                    ()
                }
            })
    }

}

extension HomeViewModel {

    func numberOfSections() -> Int {
        return 3 + sportsToFetch.count
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-3] {
                return 3
            }
            else {
                return 0
            }
        }
    }

    func title(forSection section: Int) -> String? {
        switch section {
        case 0, 1: return nil
        case 2: return "My Games"
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-3] {
                return sportForIndex.name
            }
            else {
                return nil
            }
        }
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        switch section {
        case 0: return HomeViewModel.Content.userMessage
        case 1: return HomeViewModel.Content.bannerLine
        case 2: return HomeViewModel.Content.userFavorites
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-3] {
                return HomeViewModel.Content.sport(sportForIndex)
            }
            else {
                return nil
            }
        }
    }
}

class SportLineViewModel {

    enum MatchesType {
        case popular
        case live
        case topCompetition
    }

    private var sport: Sport
    private var matchesType: MatchesType

    private var competition: Competition?

    private var popularMatchesPublisher: AnyCancellable?
    private var liveMatchesPublisher: AnyCancellable?
    private var competitionsMatchesPublisher: AnyCancellable?

    private var popularMatchesRegister: EndpointPublisherIdentifiable?
    private var liveMatchesRegister: EndpointPublisherIdentifiable?
    private var competitionMatchesRegister: EndpointPublisherIdentifiable?

    private var matchesIds: [String] = []

    private var store: HomeStore

    private var cancellables: Set<AnyCancellable> = []

    init(sport: Sport, matchesType: MatchesType, store: HomeStore) {

        self.sport = sport
        self.matchesType = matchesType
        self.store = store

        Env.everyMatrixClient.serviceStatusPublisher
            .sink { _ in

            } receiveValue: { status in
                switch status {
                case .connected:
                    self.requestMatches()
                case .disconnected:
                    ()
                }
            }
            .store(in: &cancellables)
    }

    private func requestMatches() {
        switch self.matchesType {
        case .popular:
            self.fetchPopularMatches()
        case .live:
            self.fetchLiveMatches()
        case .topCompetition:
            self.fetchTopCompetitionMatches()
        }
    }

    private func fetchPopularMatches() {

        if let popularMatchesRegister = popularMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: popularMatchesRegister)
        }

        let endpoint = TSRouter.popularMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                        language: "en",
                                                        sportId: self.sport.id,
                                                        matchesCount: 2)
        self.popularMatchesPublisher?.cancel()
        self.popularMatchesPublisher = nil

        self.popularMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }

    private func fetchLiveMatches() {

        if let liveMatchesRegister = liveMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: liveMatchesRegister)
        }

        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                     language: "en",
                                                     sportId: self.sport.id,
                                                     matchesCount: 2)
        self.liveMatchesPublisher?.cancel()
        self.liveMatchesPublisher = nil

        self.liveMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.popularMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeMatches(fromAggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                case .disconnect:
                    ()
                }
            })
    }


    func fetchTopCompetitionMatches() {

        let language = "en"
       let endpoint = TSRouter.getCustomTournaments(language: language, sportId: self.sport.id)

        Env.everyMatrixClient.manager
            .getModel(router: endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
            .map(\.records)
            .compactMap({ $0 })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: {  [weak self] tournaments in
                if let topCompetition = tournaments.first(where: { $0.sportId == self?.sport.id }) {
                    self?.competition = Competition(id: topCompetition.id, name: topCompetition.name ?? "")
                    self?.fetchCompetitionsWithId(topCompetition.id)
                }
            })
            .store(in: &cancellables)

//        let popularTournamentsEndpoint = TSRouter.getPopularTournaments(language: language, sportId: self.sport.id)
//        Env.everyMatrixClient.manager.getModel(router: popularTournamentsEndpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
//            .map(\.records)
//            .compactMap({ $0 })
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//            }, receiveValue: {  [weak self] tournaments in
//                if let topCompetition = tournaments.first(where: { $0.sportId == self?.sport.id }) {
//                    print("topCompetition: \(topCompetition)")
//                    self?.fetchCompetitionsWithIds([topCompetition.id])
//                }
//            })
//            .store(in: &cancellables)

    }

    func fetchCompetitionsWithId(_ id: String) {

        if let competitionMatchesRegister = competitionMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionMatchesRegister)
        }

        let language = "en"
        let endpoint = TSRouter.competitionsMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                             language: language,
                                                             sportId: self.sport.id,
                                                             events: [id])

        self.competitionsMatchesPublisher?.cancel()
        self.competitionsMatchesPublisher = nil

        self.competitionsMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher connect")
                    self?.competitionMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher initialContent")
                    self?.storeMatches(fromAggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateMatches(fromAggregator: aggregatorUpdates)
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher updatedContent")
                case .disconnect:
                    print("fetchCompetitionsWithIds competitionsMatchesPublisher disconnect")
                }
            })
    }

    func storeMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.matchesIds = []
        for content in aggregator.content ?? [] {
            switch content {
            case .match(let matchContent):
                self.matchesIds.append(matchContent.id)
            default:
                ()
            }
        }
        self.matchesIds = Array(self.matchesIds.prefix(2))
        self.store.storeContent(fromAggregator: aggregator)
    }

    func updateMatches(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }

}

class HomeStore {

    private var matches: [String: EveryMatrix.Match] = [:]

    private var marketsForMatch: [String: Set<String>] = [:]   // [Match ID: [Markets IDs] ]
    private var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]     // [Market: Content]
    private var bettingOffers: [String: EveryMatrix.BettingOffer] = [:] // [OutcomeId: Content]

    private var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    private var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    private var bettingOutcomesForMarket: [String: Set<String>] = [:]

    private var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    private var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    private var mainMarketsOrder: OrderedSet<String> = []

    private var locations: OrderedDictionary<String, EveryMatrix.Location> = [:]
//    private var tournamentsForLocation: [String: [String] ] = [:]
//    private var tournamentsForCategory: [String: [String] ] = [:]
//
    private var tournaments: [String: EveryMatrix.Tournament] = [:]
//    private var popularTournaments: OrderedDictionary<String, EveryMatrix.Tournament> = [:]
//
    private var matchesInfo: [String: EveryMatrix.MatchInfo] = [:]
    private var matchesInfoForMatch: [String: Set<String> ] = [:]
    private var matchesInfoForMatchPublisher: CurrentValueSubject<[String], Never> = .init([])

    func storeContent(fromAggregator aggregator: EveryMatrix.Aggregator) {

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament(let tournamentContent):
                tournaments[tournamentContent.id] = tournamentContent

            case .match(let matchContent):
                matches[matchContent.id] = matchContent

            case .matchInfo(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                        var matchIdArray = matchesInfoForMatchPublisher.value
                        matchIdArray.append(matchId)
                        matchesInfoForMatchPublisher.send(matchIdArray)
                    }
                }

            case .market(let marketContent):
                marketsPublishers[marketContent.id] = CurrentValueSubject<EveryMatrix.Market, Never>.init(marketContent)

                if let matchId = marketContent.eventId {
                    if var marketsForIterationMatch = marketsForMatch[matchId] {
                        marketsForIterationMatch.insert(marketContent.id)
                        marketsForMatch[matchId] = marketsForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(marketContent.id)
                        marketsForMatch[matchId] = newSet
                    }
                }
            case .betOutcome(let betOutcomeContent):
                betOutcomes[betOutcomeContent.id] = betOutcomeContent

            case .bettingOffer(let bettingOfferContent):
                if let outcomeIdValue = bettingOfferContent.outcomeId {
                    bettingOffers[outcomeIdValue] = bettingOfferContent
                }
                bettingOfferPublishers[bettingOfferContent.id] = CurrentValueSubject<EveryMatrix.BettingOffer, Never>.init(bettingOfferContent)

            case .mainMarket(let market):
                mainMarkets[market.id] = market
                mainMarketsOrder.append(market.bettingTypeId ?? "")

            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                marketOutcomeRelations[marketOutcomeRelationContent.id] = marketOutcomeRelationContent

                if let marketId = marketOutcomeRelationContent.marketId, let outcomeId = marketOutcomeRelationContent.outcomeId {
                    if var outcomesForMatch = bettingOutcomesForMarket[marketId] {
                        outcomesForMatch.insert(outcomeId)
                        bettingOutcomesForMarket[marketId] = outcomesForMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(outcomeId)
                        bettingOutcomesForMarket[marketId] = newSet
                    }
                }
            case .location(let location):
                self.locations[location.id] = location

            default:
                ()
            }
        }
    }

    func updateContent(fromAggregator aggregator: EveryMatrix.Aggregator) {
        guard
            let contentUpdates = aggregator.contentUpdates
        else {
            return
        }

        for update in contentUpdates {
            switch update {
            case .bettingOfferUpdate(let id, let statusId, let odd, let isLive, let isAvailable):
                if let publisher = bettingOfferPublishers[id] {
                    let bettingOffer = publisher.value
                    let updatedBettingOffer = bettingOffer.bettingOfferUpdated(withOdd: odd,
                                                                               statusId: statusId,
                                                                               isLive: isLive,
                                                                               isAvailable: isAvailable)
                    publisher.send(updatedBettingOffer)
                }
            case .marketUpdate(let id, let isAvailable, let isClosed):
                if let marketPublisher = marketsPublishers[id] {
                    let market = marketPublisher.value
                    let updatedMarket = market.martketUpdated(withAvailability: isAvailable, isCLosed: isClosed)
                    marketPublisher.send(updatedMarket)
                }
            case .matchInfo(let id, let paramFloat1, let paramFloat2, let paramEventPartName1):
                for matchInfoForMatch in matchesInfoForMatch {
                    for matchInfoId in matchInfoForMatch.value {
                        if let matchInfo = matchesInfo[id] {
                            matchesInfo[id] = matchInfo.matchInfoUpdated(paramFloat1: paramFloat1,
                                                                         paramFloat2: paramFloat2,
                                                                         paramEventPartName1: paramEventPartName1)
                        }
                    }
                }
            case .fullMatchInfoUpdate(let matchInfo):
                matchesInfo[matchInfo.id] = matchInfo

                if let matchId = matchInfo.matchId {
                    if var matchInfoForIterationMatch = matchesInfoForMatch[matchId] {
                        matchInfoForIterationMatch.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = matchInfoForIterationMatch
                    }
                    else {
                        var newSet = Set<String>.init()
                        newSet.insert(matchInfo.id)
                        matchesInfoForMatch[matchId] = newSet
                    }
                    var matchIdArray = matchesInfoForMatchPublisher.value
                    matchIdArray.append(matchId)
                    matchesInfoForMatchPublisher.send(matchIdArray)
                }
            default:
                ()
            }
        }
    }

    func bettingOfferPublisher(withId id: String) -> AnyPublisher<EveryMatrix.BettingOffer, Never>? {
        return bettingOfferPublishers[id]?.eraseToAnyPublisher()
    }

    func marketPublisher(withId id: String) -> AnyPublisher<EveryMatrix.Market, Never>? {
        return marketsPublishers[id]?.eraseToAnyPublisher()
    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return self.locations[id]
    }

    func matchWithId(id: String) -> Match? {

        if let rawMatch = matches[id] {

            var matchMarkets: [Market] = []

            let marketsIds = self.marketsForMatch[rawMatch.id] ?? []
            let rawMarketsList = marketsIds.map { id in
                return self.marketsPublishers[id]?.value
            }
                .compactMap({$0})

            for rawMarket  in rawMarketsList {

                let rawOutcomeIds = self.bettingOutcomesForMarket[rawMarket.id] ?? []

                let rawOutcomesList = rawOutcomeIds.map { id in
                    return self.betOutcomes[id]
                }
                    .compactMap({$0})

                var outcomes: [Outcome] = []
                for rawOutcome in rawOutcomesList {

                    if let rawBettingOffer = self.bettingOffers[rawOutcome.id] {
                        let bettingOffer = BettingOffer(id: rawBettingOffer.id,
                                                        value: rawBettingOffer.oddsValue ?? 0.0,
                                                        statusId: rawBettingOffer.statusId ?? "1",
                                                        isLive: rawBettingOffer.isLive ?? false,
                                                        isAvailable: rawBettingOffer.isAvailable ?? true)

                        let outcome = Outcome(id: rawOutcome.id,
                                              codeName: rawOutcome.headerNameKey ?? "",
                                              typeName: rawOutcome.headerName ?? "",
                                              translatedName: rawOutcome.translatedName ?? "",
                                              nameDigit1: rawOutcome.paramFloat1,
                                              nameDigit2: rawOutcome.paramFloat2,
                                              nameDigit3: rawOutcome.paramFloat3,
                                              paramBoolean1: rawOutcome.paramBoolean1,
                                              marketName: rawMarket.shortName ?? "",
                                              marketId: rawMarket.id,
                                              bettingOffer: bettingOffer)
                        outcomes.append(outcome)
                    }
                }

                let sortedOutcomes = outcomes.sorted { out1, out2 in
                    let out1Value = OddOutcomesSortingHelper.sortValueForOutcome(out1.codeName)
                    let out2Value = OddOutcomesSortingHelper.sortValueForOutcome(out2.codeName)
                    return out1Value < out2Value
                }

                let market = Market(id: rawMarket.id,
                                    typeId: rawMarket.bettingTypeId ?? "",
                                    name: rawMarket.shortName ?? "",
                                    nameDigit1: rawMarket.paramFloat1,
                                    nameDigit2: rawMarket.paramFloat2,
                                    nameDigit3: rawMarket.paramFloat3,
                                    eventPartId: rawMarket.eventPartId,
                                    bettingTypeId: rawMarket.bettingTypeId,
                                    outcomes: sortedOutcomes)
                matchMarkets.append(market)
            }

            let sortedMarkets = matchMarkets.sorted { market1, market2 in
                let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 10000
                let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 10000
                return position1 < position2
            }

            var location: Location?
            if let rawLocation = self.location(forId: rawMatch.venueId ?? "") {
                location = Location(id: rawLocation.id, name: rawLocation.name ?? "", isoCode: rawLocation.code ?? "")
            }

            let match = Match(id: rawMatch.id,
                              competitionId: rawMatch.parentId ?? "",
                              competitionName: rawMatch.parentName ?? "",
                              homeParticipant: Participant(id: rawMatch.homeParticipantId ?? "",
                                                           name: rawMatch.homeParticipantName ?? ""),
                              awayParticipant: Participant(id: rawMatch.awayParticipantId ?? "",
                                                           name: rawMatch.awayParticipantName ?? ""),
                              date: rawMatch.startDate ?? Date(timeIntervalSince1970: 0),
                              sportType: rawMatch.sportId ?? "",
                              venue: location,
                              numberTotalOfMarkets: rawMatch.numberOfMarkets ?? 0,
                              markets: sortedMarkets,
                              rootPartId: rawMatch.rootPartId ?? "")

            return match
        }
        return nil
    }
/*


    func storeLocations(locations: [EveryMatrix.Location]) {
        self.locations = [:]
        for location in locations {
            self.locations[location.id] = location
        }
    }

    func storeTournaments(tournaments: [EveryMatrix.Tournament]) {
        self.tournaments = [:]
        for tournament in tournaments {
            self.tournaments[tournament.id] = tournament

            if let venueId = tournament.venueId {
                if var tournamentsForLocationWithId = self.tournamentsForLocation[venueId] {
                    tournamentsForLocationWithId.append(tournament.id)
                    self.tournamentsForLocation[venueId] = tournamentsForLocationWithId
                }
                else {
                    self.tournamentsForLocation[venueId] = [tournament.id]
                }
            }

            if let categoryId = tournament.categoryId {
                if var tournamentsForCategoryWithId = self.tournamentsForCategory[categoryId] {
                    tournamentsForCategoryWithId.append(tournament.id)
                    self.tournamentsForCategory[categoryId] = tournamentsForCategoryWithId
                }
                else {
                    self.tournamentsForCategory[categoryId] = [tournament.id]
                }
            }
        }
    }

    func storePopularTournaments(tournaments: [EveryMatrix.Tournament]) {
        self.popularTournaments = [:]
        for tournament in tournaments {
            self.popularTournaments[tournament.id] = tournament
        }
    }
*/

}
