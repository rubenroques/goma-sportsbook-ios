//
//  BonusViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2022.
//

import Foundation
import Combine
import UIKit

class BonusViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // Data Sources
    private var bonusAvailableDataSource = BonusAvailableDataSource()
    private var bonusActiveDataSource = BonusActiveDataSource()
    private var bonusHistoryDataSource = BonusHistoryDataSource()

    // MARK: Public Properties
    var bonusListTypePublisher: CurrentValueSubject<BonusListType, Never> = .init(.available)
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var isBonusAvailableEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusActiveEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusHistoryEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusAvailableLoading: CurrentValueSubject<Bool, Never> = .init(false)

    enum BonusListType: Int {
        case available = 0
        case active = 1
        case history = 2
    }

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.setupPublishers()
    }

    func setBonusType(_ type: BonusListType) {
        self.bonusListTypePublisher.value = type
        print("BONUS TYPE: \(type)")
    }

    func setupPublishers() {

        self.bonusAvailableDataSource.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.shouldReloadData.send()
            })
            .store(in: &cancellables)

        self.bonusAvailableDataSource.isEmptyStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emptyState in
                self?.isBonusAvailableEmptyPublisher.send(emptyState)
            })
            .store(in: &cancellables)

        self.bonusAvailableDataSource.isBonusLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loading in
                ()
            })
            .store(in: &cancellables)

        self.bonusActiveDataSource.isEmptyStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emptyState in
                self?.isBonusActiveEmptyPublisher.send(emptyState)
            })
            .store(in: &cancellables)

        self.bonusHistoryDataSource.isEmptyStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] emptyState in
                self?.isBonusHistoryEmptyPublisher.send(emptyState)
            })
            .store(in: &cancellables)
    }
}

extension BonusViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.numberOfSections(in: tableView)
        case .active:
            return self.bonusActiveDataSource.numberOfSections(in: tableView)
        case .history:
            return self.bonusHistoryDataSource.numberOfSections(in: tableView)
        }
    }

    func hasContentForSelectedListType() -> Bool {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.bonusAvailable.isNotEmpty
        case .active:
            return self.bonusActiveDataSource.bonusActive.isNotEmpty
        case .history:
            return self.bonusHistoryDataSource.bonusHistory.isNotEmpty
        }
   }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, numberOfRowsInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, cellForRowAt: indexPath)

        case .active:
            return self.bonusActiveDataSource.tableView(tableView, cellForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, viewForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, heightForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, heightForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        switch self.bonusListTypePublisher.value {
        case .available:
            return self.bonusAvailableDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .active:
            return self.bonusActiveDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        case .history:
            return self.bonusHistoryDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

}
