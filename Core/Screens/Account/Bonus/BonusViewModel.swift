//
//  BonusViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2022.
//

import Foundation
import Combine

class BonusViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Data Sources Properties
    var bonusAvailable: [BonusTypeData] = []
    var bonusActive: [GrantedBonus] = []
    var bonusHistory: [GrantedBonus] = []
    var bonusQueued: [GrantedBonus] = []

    var bonusAvailableCellViewModels: [BonusAvailableCellViewModel] = []
    var bonusActiveCellViewModels: [BonusActiveCellViewModel] = []
    var bonusHistoryCellViewModels: [BonusHistoryCellViewModel] = []
    var bonusQueuedCellViewModels: [BonusActiveCellViewModel] = []

    // MARK: Public Properties
    var bonusListType: BonusListType

    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var isBonusAvailableEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusActiveEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusQueuedEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusHistoryEmptyPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusApplicableLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusClaimableLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusGrantedLoading: CurrentValueSubject<Bool, Never> = .init(false)

    var bonusBannersUrlPublisher: CurrentValueSubject<[String: URL], Never> = .init([:])

    var requestBonusDetail: ((EveryMatrix.ApplicableBonus) -> Void)?
    var requestApplyBonus: ((EveryMatrix.ApplicableBonus) -> Void)?

    var hasQueuedBonus: CurrentValueSubject<Bool, Never> = .init(false)
    //var shouldReloadAllBonusData: PassthroughSubject<Void, Never> = .init()
    var shouldShowAlert: ((AlertType) -> Void)?

    enum BonusListType: Int {
        case available = 0
        case active = 1
        case queued = 2
        case history = 3
    }

    // MARK: Lifetime and Cycle
    init(bonusListType: BonusListType) {
        self.bonusListType = bonusListType

        self.requestBonusForType()
    }

    func requestBonusForType() {
        switch self.bonusListType {
        case .available:
            self.getAvailableBonus()
        case .active:
            self.getGrantedBonus()
        case .queued:
            self.getGrantedBonus()
        case .history:
            self.getGrantedBonus()
        }
    }

    // MARK: Functions
    func updateDataSources() {
        self.bonusAvailable = []
        self.bonusActive = []
        self.bonusHistory = []
        self.bonusQueued = []

        self.bonusAvailableCellViewModels = []
        self.bonusActiveCellViewModels = []
        self.bonusHistoryCellViewModels = []
        self.bonusQueuedCellViewModels = []

        self.requestBonusForType()
    }

    private func getAvailableBonus() {

        self.isBonusApplicableLoading.send(true)
        self.isBonusClaimableLoading.send(true)

        Env.servicesProvider.getAvailableBonuses()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("AVAILABLE BONUSES ERROR: \(error)")
                    self?.isBonusApplicableLoading.send(false)
                    self?.isBonusClaimableLoading.send(false)
                }

            }, receiveValue: { [weak self] availableBonuses in

                let filteredAvailableBonuses = availableBonuses.filter({
                    $0.type != "CODED"
                })

                if filteredAvailableBonuses.isNotEmpty {
                    let applicableBonus = filteredAvailableBonuses.map({
                        let applicableBonus = ServiceProviderModelMapper.applicableBonus(fromServiceProviderAvailableBonus: $0)
                        return applicableBonus
                    })

                    self?.processAvailableBonus(bonuses: applicableBonus)
                }
                else {
                    self?.isBonusApplicableLoading.send(false)
                    self?.isBonusClaimableLoading.send(false)
                }

            })
            .store(in: &cancellables)
    }

//    private func getAvailableBonus() {
//        self.isBonusApplicableLoading.send(true)
//        self.isBonusClaimableLoading.send(true)
//
//        var gamingAccountId = ""
//
//        // Get Applicable Bonus
//        Env.everyMatrixClient.getApplicableBonus(type: "deposit", gamingAccountId: gamingAccountId)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    ()
//                case .finished:
//                    ()
//                }
//                self.isBonusApplicableLoading.send(false)
//            }, receiveValue: { [weak self] bonusResponse in
//                if let bonusList = bonusResponse.bonuses {
//                    for bonus in bonusList {
//
//                        let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .applicable)
//
//                        self?.bonusAvailable.append(bonusTypeData)
//
//                        if let url = URL(string: "https:\(bonus.assets)") {
//                            self?.storeBonusBanner(url: url, bonusCode: bonus.code)
//                            let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus, bonusBannerUrl: url)
//                            self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
//                        }
//                        else {
//                            let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus)
//                            self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
//                        }
//
//                    }
//                }
//
//            })
//            .store(in: &cancellables)
//
//        // Get Claimable Bonus
//        Env.everyMatrixClient.getClaimableBonus()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    ()
//                case .finished:
//                    ()
//                }
//                self.isBonusClaimableLoading.send(false)
//            }, receiveValue: { [weak self] bonusResponse in
//                for bonus in bonusResponse.locallyInjectedKey {
//                    let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .claimable)
//
//                    self?.bonusAvailable.append(bonusTypeData)
//
//                    if let url = URL(string: "https:\(bonus.assets)") {
//                        self?.storeBonusBanner(url: url, bonusCode: bonus.code)
//                        let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus, bonusBannerUrl: url)
//                        self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
//                    }
//                    else {
//                        let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus)
//                        self?.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
//                    }
//
//                }
//
//            })
//            .store(in: &cancellables)
//
//        if self.bonusAvailable.isEmpty {
//            self.isBonusAvailableEmptyPublisher.send(true)
//        }
//
//    }

    private func processAvailableBonus(bonuses: [ApplicableBonus]) {

        for bonus in bonuses {
            let bonusTypeData = BonusTypeData(bonus: bonus, bonusType: .claimable)

            self.bonusAvailable.append(bonusTypeData)

            if let assets = bonus.assets,
                let url = URL(string: "\(assets)") {
                self.storeBonusBanner(url: url, bonusCode: bonus.code)
                let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus, bonusBannerUrl: url)
                self.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
            }
            else {
                let bonusAvailableCellViewModel = BonusAvailableCellViewModel(bonus: bonus)
                self.bonusAvailableCellViewModels.append(bonusAvailableCellViewModel)
            }

        }

        self.isBonusApplicableLoading.send(false)
        self.isBonusClaimableLoading.send(false)
    }

    private func storeBonusBanner(url: URL, bonusCode: String) {

        self.bonusBannersUrlPublisher.value[bonusCode] = url
        self.shouldReloadData.send()
    }

    private func getGrantedBonus() {
        self.isBonusGrantedLoading.send(true)

        Env.servicesProvider.getGrantedBonuses()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("GRANTED BONUSES ERROR: \(error)")
                    self?.isBonusGrantedLoading.send(false)
                }

            }, receiveValue: { [weak self] grantedBonuses in

                let grantedBonus = grantedBonuses.map({
                    let grantedBonus = ServiceProviderModelMapper.grantedBonus(fromServiceProviderGrantedBonus: $0)
                    return grantedBonus
                })

                self?.processGrantedBonus(bonuses: grantedBonus)

            })
            .store(in: &cancellables)

//        Env.everyMatrixClient.getGrantedBonus()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    ()
//                case .finished:
//                    ()                }
//            }, receiveValue: { [weak self] bonusResponse in
//                if let bonuses = bonusResponse.bonuses {
//                    self?.processGrantedBonus(bonuses: bonuses)
//                }
//                else {
//                    self?.isBonusActiveEmptyPublisher.send(true)
//                    self?.isBonusHistoryEmptyPublisher.send(true)
//                }
//
//            })
//            .store(in: &cancellables)
    }

    private func processGrantedBonus(bonuses: [GrantedBonus]) {

        for bonus in bonuses {
            if bonus.status == "ACTIVE" {
                self.bonusActive.append(bonus)
                let bonusActiveCellViewModel = BonusActiveCellViewModel(bonus: bonus)

//                bonusActiveCellViewModel.shouldReloadData = { [weak self] in
//                    self?.shouldReloadAllBonusData.send()
//                }
                bonusActiveCellViewModel.shouldShowAlert = { [weak self] alertType in

                    self?.shouldShowAlert?(alertType)
                }

                self.bonusActiveCellViewModels.append(bonusActiveCellViewModel)
            }
            else if bonus.status == "QUEUED" || bonus.status == "OPTED_IN" {
                self.bonusQueued.append(bonus)
                let bonusQueuedCellViewModel = BonusActiveCellViewModel(bonus: bonus)
                self.bonusQueuedCellViewModels.append(bonusQueuedCellViewModel)
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
        else {
            self.isBonusActiveEmptyPublisher.send(false)
        }

        if self.bonusQueued.isEmpty {
            self.isBonusQueuedEmptyPublisher.send(true)
        }
        else {
            self.isBonusQueuedEmptyPublisher.send(false)
        }
//        else {
//            self.hasQueuedBonus.send(true)
//        }

        if self.bonusHistory.isEmpty {
            self.isBonusHistoryEmptyPublisher.send(true)
        }
        else {
            self.isBonusHistoryEmptyPublisher.send(false)
        }

        self.isBonusGrantedLoading.send(false)

    }

//    private func processGrantedBonus(bonuses: [EveryMatrix.GrantedBonus]) {
//
//        for bonus in bonuses {
//            if bonus.status == "active" {
//                self.bonusActive.append(bonus)
//                let bonusActiveCellViewModel = BonusActiveCellViewModel(bonus: bonus)
//                self.bonusActiveCellViewModels.append(bonusActiveCellViewModel)
//            }
//            else {
//                self.bonusHistory.append(bonus)
//                let bonusHistoryCellViewModel = BonusHistoryCellViewModel(bonus: bonus)
//                self.bonusHistoryCellViewModels.append(bonusHistoryCellViewModel)
//            }
//        }
//
//        if self.bonusActive.isEmpty {
//            self.isBonusActiveEmptyPublisher.send(true)
//        }
//
//        if self.bonusHistory.isEmpty {
//            self.isBonusHistoryEmptyPublisher.send(true)
//        }
//
//        self.isBonusGrantedLoading.send(false)
//
//    }
}
