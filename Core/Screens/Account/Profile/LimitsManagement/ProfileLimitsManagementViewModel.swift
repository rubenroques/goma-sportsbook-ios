//
//  ProfileLimitsManagementViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2022.
//

import Foundation
import Combine

class ProfileLimitsManagementViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var depositLimit: EveryMatrix.Limit?
    var wageringLimit: EveryMatrix.Limit?
    var wageringLimitPerDay: EveryMatrix.Limit?
    var wageringLimitPerWeek: EveryMatrix.Limit?
    var wageringLimitPerMonth: EveryMatrix.Limit?
    var lossLimit: EveryMatrix.Limit?
    var lossLimitPerDay: EveryMatrix.Limit?
    var lossLimitPerWeek: EveryMatrix.Limit?
    var lossLimitPerMonth: EveryMatrix.Limit?
    var limitsLoadedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var limitOptionsSet: [String] = []
    var limitOptionsCheckPublisher: CurrentValueSubject<[String], Never> = .init([])
    var limitOptionsErrorPublisher: CurrentValueSubject<String, Never> = .init("")
    var canUpdateDeposit: Bool = false
    var canUpdateWagering: Bool = false
    var canUpdateLoss: Bool = false

    // MARK: Cycles
    override init() {
        super.init()

        self.getLimits()
    }

    private func getLimits() {
        Env.everyMatrixClient.getLimits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("LIMITS ERROR: \(error)")

                case .finished:
                    print("LIMITS FINISHED")
                }
            }, receiveValue: { [weak self] limitsResponse in
                print("LIMITS: \(limitsResponse)")
                self?.setLimitsData(limitsResponse: limitsResponse)
            })
            .store(in: &cancellables)
    }

    private func setLimitsData(limitsResponse: EveryMatrix.LimitsResponse) {

        self.depositLimit = limitsResponse.deposit
        self.wageringLimit = limitsResponse.wagering
        self.wageringLimitPerDay = limitsResponse.wageringPerDay
        self.wageringLimitPerWeek = limitsResponse.wageringPerWeek
        self.wageringLimitPerMonth = limitsResponse.wageringPerMonth
        self.lossLimit = limitsResponse.loss
        self.lossLimitPerDay = limitsResponse.lossPerDay
        self.lossLimitPerWeek = limitsResponse.lossPerWeek
        self.lossLimitPerMonth = limitsResponse.lossPerMonth

        self.limitsLoadedPublisher.send(true)
    }

    func sendLimit(limitType: String, period: String, amount: String, currency: String) {
        Env.everyMatrixClient.setLimit(limitType: limitType, period: period, amount: amount, currency: currency)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):

                    print("LIMITS SET ERROR: \(error)")

                    self?.limitOptionsErrorPublisher.send("\(error)")
                case .finished:
                    print("LIMITS SET FINISHED")

                }
            }, receiveValue: { [weak self] _ in
                print("LIMITS SET!")
                if limitType == "Deposit" {
                    self?.limitOptionsCheckPublisher.value.append("deposit")
                }
                else if limitType == "Wagering" {
                    self?.limitOptionsCheckPublisher.value.append("wagering")
                }
                else if limitType == "Loss" {
                    self?.limitOptionsCheckPublisher.value.append("loss")
                }
            })
            .store(in: &cancellables)
    }

    func checkLimitUpdatableStatus(limitType: String, limitAmount: String, limitPeriod: String, isLimitUpdatable: Bool) {

        var limitCurrentAmountString = ""
        var limitCurrentPeriodString = ""
        var limitAmountTextfieldChanged = false
        var limitPeriodChanged = false
        var limitCurrentObject: EveryMatrix.LimitInfo?

        if limitType == "deposit" {
            limitCurrentObject = self.depositLimit?.current
        }
        else if limitType == "wagering" {
            limitCurrentObject = self.wageringLimit?.current
        }
        else if limitType == "loss" {
            limitCurrentObject = self.lossLimit?.current
        }

        if let limitCurrentAmount = limitCurrentObject?.amount {
            limitCurrentAmountString = "\(limitCurrentAmount)"
        }

        if let limitCurrentPeriod = limitCurrentObject?.period {
            limitCurrentPeriodString = "\(limitCurrentPeriod)"
        }

        if limitAmount != "" && limitAmount != limitCurrentAmountString {
            limitAmountTextfieldChanged = true
        }

        if limitCurrentPeriodString != "" && limitPeriod != limitCurrentPeriodString {
            limitPeriodChanged = true
        }

        if isLimitUpdatable && (limitAmountTextfieldChanged || limitPeriodChanged)  {

            if limitType == "deposit" {
                self.limitOptionsSet.append("deposit")
                self.canUpdateDeposit = true
            }
            else if limitType == "wagering" {
                self.limitOptionsSet.append("wagering")
                self.canUpdateWagering = true
            }
            else if limitType == "loss" {
                self.limitOptionsSet.append("loss")
                self.canUpdateLoss = true
            }
        }
    }

    func getWageringOption() -> EveryMatrix.Limit? {

        var wageringOption: EveryMatrix.Limit? = self.wageringLimit

        if self.wageringLimitPerDay?.current != nil {
            wageringOption = self.wageringLimitPerDay
            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
                return wageringOption
            }
        }
        if self.wageringLimitPerWeek?.current != nil {
            wageringOption = self.wageringLimitPerWeek
            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
                return wageringOption
            }
        }
        if self.wageringLimitPerMonth?.current != nil {
            wageringOption = self.wageringLimitPerMonth
            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
                return wageringOption
            }
        }

        return wageringOption
    }

    func getLossOption() -> EveryMatrix.Limit? {

        var lossOption: EveryMatrix.Limit? = self.lossLimit

        if self.lossLimitPerDay?.current != nil {
            lossOption = self.lossLimitPerDay
            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
                return lossOption
            }
        }
        else if self.lossLimitPerWeek?.current != nil {
            lossOption = self.lossLimitPerWeek
            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
                return lossOption
            }
        }
        else if self.lossLimitPerMonth?.current != nil {
            lossOption = self.lossLimitPerMonth
            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
                return lossOption
            }
        }

        return lossOption
    }

    func removeLimit(limitType: String, period: String) {
        Env.everyMatrixClient.removeLimit(limitType: limitType, period: period)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):

                    print("LIMITS REMOVE ERROR: \(error)")

                    self?.limitOptionsErrorPublisher.send("\(error)")
                case .finished:
                    print("LIMITS REMOVE FINISHED")

                }
            }, receiveValue: { [weak self] _ in
                print("LIMIT REMOVED!")
            })
            .store(in: &cancellables)
    }

}
