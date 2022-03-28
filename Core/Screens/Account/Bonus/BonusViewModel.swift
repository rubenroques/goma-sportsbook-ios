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
    var isBonusApplicableLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusClaimableLoading: CurrentValueSubject<Bool, Never> = .init(false)

    var bonusBannersUrlPublisher: CurrentValueSubject<[String: URL], Never> = .init([:])

    var requestBonusDetail: ((EveryMatrix.ApplicableBonus) -> Void)?
    var requestApplyBonus: ((EveryMatrix.ApplicableBonus) -> Void)?

    enum BonusListType: Int {
        case available = 0
        case active = 1
        case history = 2
    }

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.setupPublishers()

        self.getAvailableBonus()
        self.getGrantedBonus()
    }

    func setBonusType(_ type: BonusListType) {
        self.bonusListTypePublisher.value = type
    }

    func setupPublishers() {

        self.bonusAvailableDataSource.requestBonusDetail = { [weak self] bonusIndex in
            if let bonus = self?.bonusAvailableDataSource.bonusAvailable[safe: bonusIndex] {
                self?.requestBonusDetail?(bonus.bonus)
            }
        }

        self.bonusAvailableDataSource.requestApplyBonus = { [weak self] bonusIndex in
            if let bonus = self?.bonusAvailableDataSource.bonusAvailable[safe: bonusIndex] {
                self?.requestApplyBonus?(bonus.bonus)
            }
        }
    }

    func updateDataSources() {
        self.bonusAvailableDataSource.bonusAvailable = []
        self.bonusActiveDataSource.bonusActive = []
        self.bonusHistoryDataSource.bonusHistory = []

        self.getAvailableBonus()
        self.getGrantedBonus()
        
    }

    private func getAvailableBonus() {
        self.isBonusApplicableLoading.send(true)
        self.isBonusClaimableLoading.send(true)

        var gamingAccountId = ""

        if let walletGamingAccountId = Env.userSessionStore.userBalanceWallet.value?.id {
            gamingAccountId = "\(walletGamingAccountId)"
        }

        // Get Applicable Bonus
        Env.everyMatrixClient.getApplicableBonus(type: "deposit", gamingAccountId: gamingAccountId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    ()
                case .finished:
                    ()
                }
                self.isBonusApplicableLoading.send(false)
            }, receiveValue: { [weak self] bonusResponse in
                if let bonusList = bonusResponse.bonuses {
                    for bonus in bonusList {

                        let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .applicable)
                        self?.bonusAvailableDataSource.bonusAvailable.append(bonusTypeData)
                        if let url = URL(string: "https:\(bonus.assets)") {
                            self?.storeBonusBanner(url: url, bonusCode: bonus.code)
                        }

                    }
                }

            })
            .store(in: &cancellables)

        // Get Claimable Bonus
        Env.everyMatrixClient.getClaimableBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    ()
                case .finished:
                    ()
                }
                self.isBonusClaimableLoading.send(false)
            }, receiveValue: { [weak self] bonusResponse in
                for bonus in bonusResponse.locallyInjectedKey {
                    let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .claimable)
                    
                    self?.bonusAvailableDataSource.bonusAvailable.append(bonusTypeData)
                    if let url = URL(string: "https:\(bonus.assets)") {
                        self?.storeBonusBanner(url: url, bonusCode: bonus.code)
                    }

                }

            })
            .store(in: &cancellables)

        if self.bonusAvailableDataSource.bonusAvailable.isEmpty {
            self.isBonusAvailableEmptyPublisher.send(true)
        }

    }

    private func storeBonusBanner(url: URL, bonusCode: String) {

        self.bonusBannersUrlPublisher.value[bonusCode] = url
        self.bonusAvailableDataSource.bonusBannersUrl = self.bonusBannersUrlPublisher.value
        self.shouldReloadData.send()
    }

    private func getGrantedBonus() {

        Env.everyMatrixClient.getGrantedBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    ()
                case .finished:
                    ()                }
            }, receiveValue: { [weak self] bonusResponse in

                if let bonuses = bonusResponse.bonuses {
                    self?.processGrantedBonus(bonuses: bonuses)
                }
                else {
                    self?.isBonusActiveEmptyPublisher.send(true)
                    self?.isBonusHistoryEmptyPublisher.send(true)
                }

            })
            .store(in: &cancellables)
    }

    private func processGrantedBonus(bonuses: [EveryMatrix.GrantedBonus]) {

        for bonus in bonuses {
            if bonus.status == "active" {
                self.bonusActiveDataSource.bonusActive.append(bonus)
            }
            else {
                self.bonusHistoryDataSource.bonusHistory.append(bonus)
            }
        }

        if self.bonusActiveDataSource.bonusActive.isEmpty {
            self.isBonusActiveEmptyPublisher.send(true)
        }

        if self.bonusHistoryDataSource.bonusHistory.isEmpty {
            self.isBonusHistoryEmptyPublisher.send(true)
        }

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
