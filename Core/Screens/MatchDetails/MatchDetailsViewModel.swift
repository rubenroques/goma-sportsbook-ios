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

    var marketGroupsTypesDataChanged: (() -> Void)?
    var marketGroupDataChanged: (() -> Void)?

    var isLoadingData: CurrentValueSubject<Bool, Never> = .init(true)

    private var match: Match
    var store: MatchDetailsAggregatorRepository

    private var marketTypeSelectedOptionIndex: Int?

    private var expandedMarketGroupIds: Set<String> = []

    private var marketGroupOrganizers: [MarketGroupOrganizer] = [] {
        didSet {
            self.isLoadingData.send(marketGroupOrganizers.isEmpty)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    var gameSnapshot: UIImage?

    init(match: Match) {
        self.match = match
        self.store = MatchDetailsAggregatorRepository(matchId: self.match.id)

        super.init()

        self.connectPublisher()
    }

    func connectPublisher() {

        self.store.marketGroupsPublisher
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
                self?.marketTypeSelectedOptionIndex = defaultSelectedIndex
                self?.reloadCollectionViewContent()
                self?.reloadTableViewContent()
            }
            .store(in: &cancellables)

        self.store.totalMarketsPublisher
            .debounce(for: 0.7, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadTableViewContent()
            }
            .store(in: &cancellables)

    }

    func reloadCollectionViewContent() {
        self.marketGroupsTypesDataChanged?()
    }

    func reloadTableViewContent() {
        guard
            let selectedMarketGroupIndex = self.marketTypeSelectedOptionIndex,
            let selectedMarketGroup = self.store.marketGroupsPublisher.value[safe: selectedMarketGroupIndex],
            let groupKey = selectedMarketGroup.groupKey
        else {
            return
        }

        self.marketGroupOrganizers = store.marketGroupOrganizers(withGroupKey: groupKey)

        self.marketGroupDataChanged?()
    }
}

extension MatchDetailsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marketGroupOrganizers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let marketGroupOrganizer = self.marketGroupOrganizers[safe: indexPath.row]
        else {
            return UITableViewCell()
        }

        if marketGroupOrganizer.numberOfColumns == 3 {
            guard
                let cell = tableView.dequeueCellType(ThreeAwayMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.match = self.match
            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer, isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId))
            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 2 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.match = self.match
            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer, isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId))
            return cell
        }
        else if marketGroupOrganizer.numberOfColumns == 1 {
            guard
                let cell = tableView.dequeueCellType(OverUnderMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.match = self.match
            cell.didExpandCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.insert(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.didColapseCellAction = { marketGroupOrganizerId in
                self.expandedMarketGroupIds.remove(marketGroupOrganizerId)
                self.marketGroupDataChanged?()
            }
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer, isExpanded: self.expandedMarketGroupIds.contains(marketGroupOrganizer.marketId))
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(SimpleListMarketDetailTableViewCell.self)
            else {
                return UITableViewCell()
            }
            cell.match = self.match
            cell.configure(withMarketGroupOrganizer: marketGroupOrganizer)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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

        if marketTypeSelectedOptionIndex == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.marketTypeSelectedOptionIndex
        if indexPath.row != previousSelectionValue {
            self.marketTypeSelectedOptionIndex = indexPath.row

            self.reloadCollectionViewContent()
            self.reloadTableViewContent()

            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}
