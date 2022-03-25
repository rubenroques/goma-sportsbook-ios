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

    var store: MatchDetailsAggregatorRepository

    var isLoadingMarketGroups: CurrentValueSubject<Bool, Never> = .init(true)

    var matchModePublisher: CurrentValueSubject<MatchMode, Never> = .init(.preLive)
    var matchPublisher: CurrentValueSubject<LoadableContent<Match>, Never> = .init(.idle)

    var marketGroupsPublisher: CurrentValueSubject<[MarketGroup], Never> = .init([])
    var selectedMarketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

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

    private var cancellables = Set<AnyCancellable>()

    init(matchMode: MatchMode = .preLive, match: Match) {

        self.matchId = match.id

        self.store = MatchDetailsAggregatorRepository(matchId: match.id)
        self.matchPublisher.send(.loaded(match))

        self.matchModePublisher.send(matchMode)

        super.init()

        self.connectPublishers()
        self.fetchMarketGroupsPublisher()
    }

    init(matchMode: MatchMode = .preLive, matchId: String) {
        self.matchId = matchId

        self.matchModePublisher.send(matchMode)

        self.store = MatchDetailsAggregatorRepository(matchId: matchId)

        super.init()

        self.connectPublishers()
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
                self.fetchMatchDetailsPublisher()
                self.fetchMarketGroupsPublisher()
            })
            .store(in: &cancellables)
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
