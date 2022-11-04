//
//  MatchDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/11/2021.
//

import Foundation
import UIKit
import Combine

class MatchDetailsViewModel: NSObject {

    enum MatchMode {
        case preLive
        case live
    }

    var matchId: String
    var homeRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")
    var awayRedCardsScorePublisher: CurrentValueSubject<String, Never> = .init("0")

    var store: MatchDetailsAggregatorRepository

    var isLoadingMarketGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var matchModePublisher: CurrentValueSubject<MatchMode, Never> = .init(.preLive)
    var matchPublisher: CurrentValueSubject<LoadableContent<Match>, Never> = .init(.idle)

    var marketGroupsPublisher: CurrentValueSubject<[MarketGroup], Never> = .init([])
    var selectedMarketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    var matchStatsUpdatedPublisher = PassthroughSubject<Void, Never>.init()
 
    private var goalsRegister: EndpointPublisherIdentifiable?
    private var goalsSubscription: AnyCancellable?

    var match: Match? {
        switch matchPublisher.value {
        case .loaded(let match):
            return match
        default:
            return nil
        }
    }

    private var matchMarketGroupsPublisher: AnyCancellable?
    private var matchMarketGroupsRegister: EndpointPublisherIdentifiable?

    private var matchDetailsRegister: EndpointPublisherIdentifiable?
    private var matchDetailsAggregatorPublisher: AnyCancellable?

    private var statsJSON: JSON?
    let matchStatsViewModel: MatchStatsViewModel

    private var cancellables = Set<AnyCancellable>()

    init(matchMode: MatchMode = .preLive, match: Match) {

        self.matchId = match.id

        self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)

        self.store = MatchDetailsAggregatorRepository(matchId: match.id)
        self.matchPublisher.send(.idle) // .loaded(match))

        self.matchModePublisher.send(matchMode)

        super.init()

        self.connectPublishers()
        self.requestRedCards(forMatchWithId: match.id)
    }

    init(matchMode: MatchMode = .preLive, matchId: String) {
        self.matchId = matchId

        self.matchStatsViewModel = MatchStatsViewModel(matchId: matchId)

        self.matchModePublisher.send(matchMode)

        self.store = MatchDetailsAggregatorRepository(matchId: matchId)

        super.init()

        self.connectPublishers()
        
        self.requestRedCards(forMatchWithId: matchId)
        
    }

    deinit {
        if let matchDetailsRegister = matchDetailsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchDetailsRegister)
        }
    }

    func connectPublishers() {

        self.marketGroupsPublisher
            .receive(on: DispatchQueue.main)
            .map { marketGroups -> Int in
                var index = 0
                var defaultFound = false
                for group in marketGroups {
                    if group.isDefault ?? false {
                        defaultFound = true
                        break
                    }
                    index += 1
                }
                return defaultFound ? index : 0
            }
            .sink { [weak self] defaultSelectedIndex in
                self?.selectedMarketTypeIndexPublisher.send(defaultSelectedIndex)
            }
            .store(in: &cancellables)

        Env.everyMatrixClient.serviceStatusPublisher
            .filter({ $0 == .connected })
            .sink(receiveValue: { _ in
                self.fetchMatchData()
            })
            .store(in: &cancellables)

        self.matchStatsViewModel.statsTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statsJSON in
                self?.statsJSON = statsJSON
                self?.matchStatsUpdatedPublisher.send()
            }
            .store(in: &cancellables)
    }

    func fetchMatchData() {
        self.fetchLocations()
            .sink { [weak self] locations in
                self?.store.storeLocations(locations: locations)
                self?.fetchMatchDetailsPublisher()
            }
            .store(in: &cancellables)
    }
    
    func fetchLocations() -> AnyPublisher<[EveryMatrix.Location], Never> {
        let router = TSRouter.getLocations(language: "en", sortByPopularity: false)
        return Env.everyMatrixClient.manager.getModel(router: router, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .map(\.records)
            .compactMap({$0})
            .replaceError(with: [EveryMatrix.Location]())
            .eraseToAnyPublisher()

    }

    func fetchMatchDetailsPublisher() {
        if let matchDetailsRegister = matchDetailsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchDetailsRegister)
        }

        let endpoint = TSRouter.matchDetailsAggregatorPublisher(operatorId: Env.appSession.operatorId,
                                                                language: "en",
                                                                matchId: self.matchId)

        self.matchDetailsAggregatorPublisher?.cancel()
        self.matchDetailsAggregatorPublisher = nil

        self.matchDetailsAggregatorPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving match detail data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher connect")
                    self?.matchDetailsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher initialContent")
                    self?.setupMatchDetailAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher updatedContent")
                    self?.updateMatchDetailAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("MatchDetailsAggregator matchDetailsAggregatorPublisher disconnect")
                }
            })
    }

    private func setupMatchDetailAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {

        self.store.processAggregatorForMatchDetail(aggregator)

        if let match = self.store.match {
            if !self.store.matchesInfoForMatch.isEmpty {
                self.matchModePublisher.send(.live)
            }
            self.matchPublisher.send(.loaded(match))

            self.fetchMarketGroupsPublisher()
        }
        else {
            self.matchPublisher.send(.failed)
        }

    }

    private func updateMatchDetailAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.processContentUpdateAggregatorForMatchDetail(aggregator)
        if !self.store.matchesInfoForMatch.isEmpty {
            self.matchModePublisher.send(.live)
        }
    }

    //
    //
    private func fetchMarketGroupsPublisher() {

        self.isLoadingMarketGroups.send(true)

        let language = "en"
        let mainMarketsEndpoint = TSRouter.matchMarketGroupsPublisher(operatorId: Env.appSession.operatorId,
                                                                   language: language,
                                                                      matchId: self.matchId)

        if let matchMarketGroupsRegister = self.matchMarketGroupsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: matchMarketGroupsRegister)
        }

        self.matchMarketGroupsPublisher?.cancel()
        self.matchMarketGroupsPublisher = nil

        self.matchMarketGroupsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(mainMarketsEndpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingMarketGroups.send(false)

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MatchDetailsViewModel competitionsMatchesPublisher connect")
                    self?.matchMarketGroupsRegister = publisherIdentifiable

                case .initialContent(let aggregator):
                    print("MatchDetailsViewModel competitionsMatchesPublisher initialContent")
                    self?.storeMarketGroups(fromAggregator: aggregator)

                case .updatedContent:
                    print("MatchDetailsViewModel competitionsMatchesPublisher updatedContent")

                case .disconnect:
                    print("MatchDetailsViewModel competitionsMatchesPublisher disconnect")
                }
            })
    }

    func storeMarketGroups(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.storeMarketGroups(fromAggregator: aggregator)

        let marketGroups = self.store.marketGroupsArray().map { rawMarketGroup in
            MarketGroup(id: rawMarketGroup.id,
                        type: rawMarketGroup.type,
                        groupKey: rawMarketGroup.groupKey,
                        translatedName: rawMarketGroup.translatedName,
                        isDefault: rawMarketGroup.isDefault)
        }

        self.isLoadingMarketGroups.send(false)

        self.marketGroupsPublisher.send(marketGroups)
    }

    func selectMarketType(atIndex index: Int) {
        self.selectedMarketTypeIndexPublisher.send(index)
    }
    
}

extension MatchDetailsViewModel: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.store.marketGroupsPublisher.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath),
            let item = self.store.marketGroupsPublisher.value[safe: indexPath.row]
        else {
            fatalError()
        }

        cell.setupWithTitle(item.translatedName ?? localized("market"))

        if let index = self.selectedMarketTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.selectedMarketTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.selectedMarketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

extension MatchDetailsViewModel {

    func numberOfStatsSections() -> Int {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array {
            return eventPartsArray.count
        }

        return 0
    }

    func numberOfStatsRows(forSection section: Int) -> Int {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: section],
           let bettintTypesArray = partDict["betting_types"].array {
            return bettintTypesArray.count
        }

        return 0
    }

    func jsonData(forIndexPath indexPath: IndexPath) -> JSON? {

        guard
            let json = self.statsJSON
        else {
            return 0
        }

        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: indexPath.section],
           let bettintTypesArray = partDict["betting_types"].array,
           let statsJSON = bettintTypesArray[safe: indexPath.row] {
            return JSON(statsJSON)
        }

        return nil
    }

    func marketStatsTitle(forIndexPath indexPath: IndexPath) -> String? {

        guard
            let json = self.statsJSON
        else {
            return nil
        }
        if let eventPartsArray =  json["event_parts"].array,
           let partDict = eventPartsArray[safe: indexPath.section],
           let bettintTypesArray = partDict["betting_types"].array,
           let statsJSON = bettintTypesArray[safe: indexPath.row] {
            return "\(statsJSON["name"].string ?? "") - \(partDict["name"].string ?? "")"
        }

        return nil
    }
    
    func requestRedCards(forMatchWithId id: String) {
        
        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil

        if let goalsRegister = goalsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: goalsRegister)
        }
        
        let endpoint = TSRouter.eventPartScoresPublisher(operatorId: Env.appSession.operatorId, language: "en", matchId: id)
        
        self.goalsSubscription = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
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
                    print("%%\(publisherIdentifiable)")
                    self?.goalsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyBets cashoutPublisher initialContent")
                    for content in (aggregator.content ?? []) {
                       switch content {
                        case .eventPartScore(let eventPartScore):
                            if let eventInfoTypeId = eventPartScore.eventInfoTypeID, eventInfoTypeId == "4" {
                                if let homeScore = eventPartScore.homeScore {
                                    self?.homeRedCardsScorePublisher.send(homeScore)
                                    
                                }
                                if let awayscore = eventPartScore.awayScore {
                                    self?.awayRedCardsScorePublisher.send(awayscore)
                                    
                                }
                            }
                        default: ()
                        }
                    }
                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                case .disconnect:
                    print("MyBets cashoutPublisher disconnect")
                }
            })
    }
}
