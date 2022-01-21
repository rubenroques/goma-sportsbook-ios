//
//  SearchViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import Foundation
import Combine
import OrderedCollections

class SearchViewModel: NSObject {

    var recentSearchesPublisher: CurrentValueSubject<[String], Never> = .init([])
    var searchMatchesPublisher: CurrentValueSubject<[String: [Match]], Never> = .init([:])
    var sportMatchesArrayPublisher: CurrentValueSubject<[SportMatches], Never> = .init([])

    var cancellables = Set<AnyCancellable>()

    var hasDoneSearch: Bool = false

    // Processed match info variables
    var marketsForMatch: [String: Set<String>] = [:]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:]
    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]
    var bettingOutcomesForMarket: [String: Set<String>] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []

    override init() {
       
    }

    func fetchSearchInfo(searchQuery: String) {

        self.hasDoneSearch = false

        self.searchMatchesPublisher.value = [:]
        self.sportMatchesArrayPublisher.value = []

        let searchRoute = TSRouter.searchV2(language: "en", limit: 5, query: searchQuery, eventInfoTypes: [1, 2])
        Env.everyMatrixClient.manager.getModel(router: searchRoute, decodingType: SearchV2Response.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"): ()
                        print("Search request error")
                    case .notConnected:
                        ()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] searchResponse in
                self?.processSearchResponse(searchResponse: searchResponse.records)

            })
            .store(in: &cancellables)

    }

    func processSearchResponse(searchResponse: [Event]) {

        for event in searchResponse {
            switch event {
            case .match(let match):
                //self.searchInfoPublisher.value[match.id] = match
                self.processRawMatch(rawMatch: match)
            case .tournament(let tournament):
                //self.searchInfoPublisher.value[tournament.id] = tournament
                ()
            default:
                ()
            }
        }

        for (key, value) in searchMatchesPublisher.value {
            let sportMatch = SportMatches(sportType: key, matches: value)
            sportMatchesArrayPublisher.value.append(sportMatch)
        }
        print("SEARCH MATCHES ARRAY: \(sportMatchesArrayPublisher.value)")
        self.searchMatchesPublisher.send(self.searchMatchesPublisher.value)
        self.hasDoneSearch = true

    }

    func processRawMatch(rawMatch: EveryMatrix.Match) {

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
                                                        value: rawBettingOffer.oddsValue ?? 0.0)

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
                                    outcomes: sortedOutcomes)
                matchMarkets.append(market)
            }

            let sortedMarkets = matchMarkets.sorted { market1, market2 in
                let position1 = mainMarketsOrder.firstIndex(of: market1.typeId) ?? 100
                let position2 = mainMarketsOrder.firstIndex(of: market2.typeId) ?? 100
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

        // Set Match
        if let searchMatch = self.searchMatchesPublisher.value[match.sportType] {
            self.searchMatchesPublisher.value[match.sportType]?.append(match)
        }
        else {
            self.searchMatchesPublisher.value[match.sportType] = [match]
        }

    }

    func location(forId id: String) -> EveryMatrix.Location? {
        return Env.everyMatrixStorage.locations[id]
    }

    func addRecentSearch(search: String) {
        recentSearchesPublisher.value.append(search)
        recentSearchesPublisher.send(recentSearchesPublisher.value)
    }

    func setHeaderSectionTitle(section: Int) -> String {

        if self.sportMatchesArrayPublisher.value[section].matches.count > 1 {

            let resultsCountTextRaw = localized("results_count")
            let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "%s", with: "\(self.sportMatchesArrayPublisher.value[section].matches.count)")

            return resultsCountText
        }
        else {
            let resultsCountTextRaw = localized("results_count_singular")
            let resultsCountText = resultsCountTextRaw.replacingOccurrences(of: "%s", with: "\(self.sportMatchesArrayPublisher.value[section].matches.count)")

            return resultsCountText
        }
        
    }
}

struct SportMatches {
    var sportType: String
    var matches: [Match]
}
