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

    var matchId: String
    var match: Match?

    var store: MatchDetailsAggregatorRepository

    var isLoadingMarketGroups: CurrentValueSubject<Bool, Never> = .init(true)
    var marketGroupsPublisher: CurrentValueSubject<[MarketGroup], Never> = .init([])
    var selectedMarketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var matchMarketGroupsPublisher: AnyCancellable?
    private var matchMarketGroupsRegister: EndpointPublisherIdentifiable?

    private var cancellables = Set<AnyCancellable>()

    init(match: Match) {
        self.match = match
        self.matchId = match.id

        self.store = MatchDetailsAggregatorRepository(matchId: match.id)

        super.init()

        self.connectPublisher()
        self.fetchMarketGroupsPublisher()
    }

    init(matchId: String) {
        self.matchId = matchId
        self.store = MatchDetailsAggregatorRepository(matchId: matchId)

        super.init()

        self.connectPublisher()
        self.fetchMarketGroupsPublisher()
    }

    func fetchMarketGroupsPublisher() {

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

    func connectPublisher() {

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
