//
//  BonusViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2022.
//

import Foundation
import Combine

class BonusViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Data Sources Properties
    var bonusAvailable: [BonusTypeData] = []
    var bonusActive: [EveryMatrix.GrantedBonus] = []
    var bonusHistory: [EveryMatrix.GrantedBonus] = []

    var bonusAvailableCellViewModels: [BonusAvailableCellViewModel] = []
    var bonusActiveCellViewModels: [BonusActiveCellViewModel] = []
    var bonusHistoryCellViewModels: [BonusHistoryCellViewModel] = []

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

    }

    //MARK: Functions
    func setBonusType(_ type: BonusListType) {
        self.bonusListTypePublisher.value = type
    }

    private func setupPublishers() {

        self.getAvailableBonus()
        self.getGrantedBonus()

    }

    func updateDataSources() {
        self.bonusAvailable = []
        self.bonusActive = []
        self.bonusHistory = []

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
                case .failure:
                    ()
                case .finished:
                    ()
                }
                self.isBonusApplicableLoading.send(false)
            }, receiveValue: { [weak self] bonusResponse in
                if let bonusList = bonusResponse.bonuses {
                    for bonus in bonusList {

                        let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .applicable)

                        self?.bonusAvailable.append(bonusTypeData)

                        if let url = URL(string: "https:\(bonus.assets)") {
                            self?.storeBonusBanner(url: url, bonusCode: bonus.code)
                            let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus, bonusBannerUrl: url)
                            self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
                        }
                        else {
                            let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus)
                            self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
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
                case .failure:
                    ()
                case .finished:
                    ()
                }
                self.isBonusClaimableLoading.send(false)
            }, receiveValue: { [weak self] bonusResponse in
                for bonus in bonusResponse.locallyInjectedKey {
                    let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .claimable)
                    
                    self?.bonusAvailable.append(bonusTypeData)

                    if let url = URL(string: "https:\(bonus.assets)") {
                        self?.storeBonusBanner(url: url, bonusCode: bonus.code)
                        let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus, bonusBannerUrl: url)
                        self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
                    }
                    else {
                        let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus)
                        self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
                    }

                }

            })
            .store(in: &cancellables)

        if self.bonusAvailable.isEmpty {
            self.isBonusAvailableEmptyPublisher.send(true)
        }

    }

    private func storeBonusBanner(url: URL, bonusCode: String) {

        self.bonusBannersUrlPublisher.value[bonusCode] = url
        self.shouldReloadData.send()
    }

    private func getGrantedBonus() {

        Env.everyMatrixClient.getGrantedBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
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
                self.bonusActive.append(bonus)
                let bonusActiveCellViewModel = BonusActiveCellViewModel(bonus: bonus)
                self.bonusActiveCellViewModels.append(bonusActiveCellViewModel)
            }
            else {
                self.bonusHistory.append(bonus)
                let bonusHistoryCellViewModel = BonusHistoryCellViewModel(bonus: bonus)
                self.bonusHistoryCellViewModels.append(bonusHistoryCellViewModel)
            }
        }

        if self.bonusActive.isEmpty {
            self.isBonusActiveEmptyPublisher.send(true)
        }

        if self.bonusHistory.isEmpty {
            self.isBonusHistoryEmptyPublisher.send(true)
        }

    }
}
