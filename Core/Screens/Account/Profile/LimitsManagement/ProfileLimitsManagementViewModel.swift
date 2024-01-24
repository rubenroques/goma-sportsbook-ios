//
//  ProfileLimitsManagementViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2022.
//

import Foundation
import Combine
import ServicesProvider

class ProfileLimitsManagementViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
//    var depositLimit: EveryMatrix.Limit?
//    var wageringLimit: EveryMatrix.Limit?
    var wageringLimitPerDay: EveryMatrix.Limit?
    var wageringLimitPerWeek: EveryMatrix.Limit?
    var wageringLimitPerMonth: EveryMatrix.Limit?
//    var lossLimit: EveryMatrix.Limit?
    var lossLimitPerDay: EveryMatrix.Limit?
    var lossLimitPerWeek: EveryMatrix.Limit?
    var lossLimitPerMonth: EveryMatrix.Limit?

    var limitsLoadedPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var limitOptionsSet: [String] = []
    var limitOptionsCheckPublisher: CurrentValueSubject<[String], Never> = .init([])
    var limitOptionsErrorPublisher: CurrentValueSubject<String, Never> = .init("")

    var canUpdateDeposit: Bool = false
    var canUpdateWagering: Bool = false
    var canUpdateLoss: Bool = false

    var depositLimit: Limit?
    var wageringLimit: Limit?
    var lossLimit: Limit?
    var autoPayoutLimit: Limit?

    var pendingDepositLimitMessage: String?
    var pendingWageringLimitMessage: String?
    var pendingLossLimitMessage: String?

    var personalDepositLimitLoaded: CurrentValueSubject<Bool, Never> = .init(false)
    var limitsLoaded: CurrentValueSubject<Bool, Never> = .init(false)
    var responsibleGamingLimitLoaded: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var finishedUpdatingDepositLimit: CurrentValueSubject<LimitUpdateStatus, Never> = .init(.idle)
    var finishedUpdatingWageringLimit: CurrentValueSubject<LimitUpdateStatus, Never> = .init(.idle)
    var finishedUpdatingLossLimit: CurrentValueSubject<LimitUpdateStatus, Never> = .init(.idle)

    var isDepositLimitUpdated: CurrentValueSubject<Bool, Never> = .init(false)
    var isBettingLimitUpdated: CurrentValueSubject<Bool, Never> = .init(false)
    var isAutoPayoutLimitUpdated: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Cycles
    override init() {
        super.init()

        self.setupPublishers()

        self.getLimits()

    }

    private func setupPublishers() {

        Publishers.CombineLatest3(self.personalDepositLimitLoaded, self.limitsLoadedPublisher, self.responsibleGamingLimitLoaded)
            .sink(receiveValue: { [weak self] personalDepositLimitLoaded, limitsLoaded, responsibleGamingLimitLoaded in

                if personalDepositLimitLoaded && limitsLoaded && responsibleGamingLimitLoaded {
                    self?.limitsLoadedPublisher.send(true)

                    self?.personalDepositLimitLoaded.send(false)
                    self?.limitsLoaded.send(false)
                    self?.responsibleGamingLimitLoaded.send(false)
                }
            })
            .store(in: &cancellables)
    }

    func getLimits() {

        Env.servicesProvider.getPersonalDepositLimits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("DEPOSIT LIMITS ERROR: \(error)")
                    self?.personalDepositLimitLoaded.send(true)
                }

            }, receiveValue: { [weak self] personalDepositLimitsResponse in

                print("DEPOSIT LIMITS RESPONSE: \(personalDepositLimitsResponse)")

                self?.processDepositLimits(depositLimitResponse: personalDepositLimitsResponse)

            })
            .store(in: &cancellables)

        Env.servicesProvider.getLimits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("LIMITS ERROR: \(error)")
                    self?.limitsLoaded.send(true)
                }

            }, receiveValue: { [weak self] limitsResponse in

                print("LIMITS RESPONSE: \(limitsResponse)")

                self?.processLimits(limitsResponse: limitsResponse)

            })
            .store(in: &cancellables)

        Env.servicesProvider.getResponsibleGamingLimits()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("RESPONSIBLE LIMITS ERROR: \(error)")
                    self?.responsibleGamingLimitLoaded.send(true)
                }

            }, receiveValue: { [weak self] responsibleGamingLimitsResponse in

                print("RESPONSIBLE LIMITS RESPONSE: \(responsibleGamingLimitsResponse)")

                self?.processResponsibleGamingLimits(responsibleGamingLimitsResponse: responsibleGamingLimitsResponse)
            })
            .store(in: &cancellables)
    }
    
    private func getDateStringWithTimezone(dateString: String, hours: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            if let updatedDate = Calendar.current.date(byAdding: .hour, value: hours, to: date) {
                return dateFormatter.string(from: updatedDate)
            }
        }
        
        return dateString
    }
    
    func getUTCHourDifference() -> Int {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        return secondsFromGMT / 3600
    }

    private func processDepositLimits(depositLimitResponse: PersonalDepositLimitResponse) {

        let depositLimitInfo = LimitInfo(period: "weekly", currency: depositLimitResponse.currency, amount: Double(depositLimitResponse.weeklyLimit ?? "0") ?? 0)

        var depositLimit = Limit(updatable: true, current: depositLimitInfo, queued: nil)

        if let hasPendingLimit = depositLimitResponse.hasPendingWeeklyLimit, hasPendingLimit == "true" {

            let pendingLimit = depositLimitResponse.pendingWeeklyLimit ?? ""
//            let pendingLimitDate = depositLimitResponse.pendingWeeklyLimitEffectiveDate ?? ""
            let utcDifferenceHours = self.getUTCHourDifference()
            let pendingLimitDate = self.getDateStringWithTimezone(dateString: depositLimitResponse.pendingWeeklyLimitEffectiveDate ?? "", hours: utcDifferenceHours)
            let currency = depositLimitResponse.currency

            self.pendingDepositLimitMessage = localized("pending_limit_info").replacingFirstOccurrence(of: "{pendingLimit}", with: pendingLimit)
                .replacingFirstOccurrence(of: "{currency}", with: currency)
                .replacingFirstOccurrence(of: "{pendingLimitDate}", with: pendingLimitDate)

            let queuedDepositLimitInfo = LimitInfo(period: "weekly", currency: depositLimitResponse.currency, amount: Double(depositLimitResponse.pendingWeeklyLimit ?? "0") ?? 0)

            depositLimit.queued = queuedDepositLimitInfo
            depositLimit.updatable = false
        }

        self.depositLimit = depositLimit

        self.personalDepositLimitLoaded.send(true)
    }

    private func processLimits(limitsResponse: LimitsResponse) {

        let wagerLimitInfo = LimitInfo(period: "weekly", currency: limitsResponse.currency, amount: Double(limitsResponse.wagerLimit ?? "0") ?? 0)

        var wagerLimit = Limit(updatable: true, current: wagerLimitInfo, queued: nil)

        if let pendingLimit = limitsResponse.pendingWagerLimit {

//            let pendingLimitDate = pendingLimit.effectiveDate
            let utcDifferenceHours = self.getUTCHourDifference()
            let pendingLimitDate = self.getDateStringWithTimezone(dateString: pendingLimit.effectiveDate, hours: utcDifferenceHours)
            let currency = limitsResponse.currency

            self.pendingWageringLimitMessage = localized("pending_limit_info").replacingFirstOccurrence(of: "{pendingLimit}", with: "\(pendingLimit.limitNumber)")
                .replacingFirstOccurrence(of: "{currency}", with: currency)
                .replacingFirstOccurrence(of: "{pendingLimitDate}", with: pendingLimitDate)

            let queuedDepositLimitInfo = LimitInfo(period: "weekly", currency: currency, amount: pendingLimit.limitNumber)

            wagerLimit.queued = queuedDepositLimitInfo
            wagerLimit.updatable = false
        }

        self.wageringLimit = wagerLimit

        // PAYOUT NOT YET IMPLEMENTED
        //        let lossLimitInfo = LimitInfo(period: "weekly", currency: limitsResponse.currency, amount: limitsResponse.lossLimit ?? 0)
//
//        let lossLimit = Limit(updatable: true, current: lossLimitInfo)
        //self.lossLimit = Limit(updatable: false, current: nil, queued: nil)

        self.limitsLoadedPublisher.send(true)

    }

    private func processResponsibleGamingLimits(responsibleGamingLimitsResponse: ResponsibleGamingLimitsResponse) {

        if let responsibleGamingLimit = responsibleGamingLimitsResponse.limits.first(where: {
            $0.periodType == "Permanent"
        }) {

            let responsibleGamingLimitInfo = LimitInfo(period: "permanent", currency: "EUR", amount: responsibleGamingLimit.limit)

            var responsibleGamingLimit = Limit(updatable: true, current: responsibleGamingLimitInfo, queued: nil)

            if responsibleGamingLimitsResponse.limits.count > 1,
               let pendingLimit = responsibleGamingLimitsResponse.limits[safe: 1] {

                let pendingLimitValue = pendingLimit.limit
//                let pendingLimitDate = pendingLimit.effectiveDate
                let utcDifferenceHours = self.getUTCHourDifference()
                let pendingLimitDate = self.getDateStringWithTimezone(dateString: pendingLimit.effectiveDate, hours: utcDifferenceHours)
                let currency = "EUR"

                self.pendingLossLimitMessage = localized("pending_limit_info").replacingFirstOccurrence(of: "{pendingLimit}", with: "\(pendingLimitValue)")
                    .replacingFirstOccurrence(of: "{currency}", with: currency)
                    .replacingFirstOccurrence(of: "{pendingLimitDate}", with: pendingLimitDate)

                let queuedResponsibleGamingLimitInfo = LimitInfo(period: "permanent", currency: "EUR", amount: pendingLimit.limit)

                responsibleGamingLimit.queued = queuedResponsibleGamingLimitInfo
                responsibleGamingLimit.updatable = false
            }

//            if let hasPendingLimit = depositLimitResponse.hasPendingWeeklyLimit, hasPendingLimit == "true" {
//
//                let pendingLimit = depositLimitResponse.pendingWeeklyLimit ?? ""
//                let pendingLimitDate = depositLimitResponse.pendingWeeklyLimitEffectiveDate ?? ""
//                let currency = depositLimitResponse.currency
//
//                self.pendingDepositLimitMessage = "There is a pending limit of: \(pendingLimit) \(currency). The current limit is valid until: \(pendingLimitDate)"
//
//                let queuedDepositLimitInfo = LimitInfo(period: "weekly", currency: depositLimitResponse.currency, amount: Double(depositLimitResponse.pendingWeeklyLimit ?? "0") ?? 0)
//
//                depositLimit.queued = queuedDepositLimitInfo
//                depositLimit.updatable = false
//            }

            self.autoPayoutLimit = responsibleGamingLimit
        }

        self.responsibleGamingLimitLoaded.send(true)
    }

    private func setLimitsData() {

//        self.depositLimit = limitsResponse.deposit
//        self.wageringLimit = limitsResponse.wager
//        self.lossLimit = limitsResponse.loss

        self.limitsLoadedPublisher.send(true)
    }

//    private func setLimitsData(limitsResponse: EveryMatrix.LimitsResponse) {
//
//        self.depositLimit = limitsResponse.deposit
//        self.wageringLimit = limitsResponse.wagering
//        self.wageringLimitPerDay = limitsResponse.wageringPerDay
//        self.wageringLimitPerWeek = limitsResponse.wageringPerWeek
//        self.wageringLimitPerMonth = limitsResponse.wageringPerMonth
//        self.lossLimit = limitsResponse.loss
//        self.lossLimitPerDay = limitsResponse.lossPerDay
//        self.lossLimitPerWeek = limitsResponse.lossPerWeek
//        self.lossLimitPerMonth = limitsResponse.lossPerMonth
//
//        self.limitsLoadedPublisher.send(true)
//    }

    func updateDepositLimit(amount: String) {

        if let limit = Double(amount) {
//            Env.servicesProvider.updateWeeklyDepositLimits(newLimit: limit)
            Env.servicesProvider.updateResponsibleGamingLimits(newLimit: limit, limitType: "deposit")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in

                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("UPDATE DEPOSIT LIMIT ERROR: \(error)")
                        let limitErrorMessage = localized("limit_update_error_message").replacingFirstOccurrence(of: "{limitType}", with: localized("deposit"))
                        self?.limitOptionsErrorPublisher.send(limitErrorMessage)

                        self?.limitOptionsCheckPublisher.value.append("deposit")
                        self?.isDepositLimitUpdated.send(true)

                        self?.isLoadingPublisher.send(false)
                    }
                }, receiveValue: { [weak self] updateLimitResponse in

                    self?.limitOptionsCheckPublisher.value.append("deposit")

                    self?.isDepositLimitUpdated.send(true)

                })
                .store(in: &cancellables)
        }
    }

    func updateBettingLimit(amount: String) {

        if let limit = Double(amount) {
//            Env.servicesProvider.updateWeeklyBettingLimits(newLimit: limit)
            Env.servicesProvider.updateResponsibleGamingLimits(newLimit: limit, limitType: "betting")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in

                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("UPDATE DEPOSIT LIMIT ERROR: \(error)")
                        let limitErrorMessage = localized("limit_update_error_message").replacingFirstOccurrence(of: "{limitType}", with: localized("betting"))
                        self?.limitOptionsErrorPublisher.send(limitErrorMessage)

                        self?.limitOptionsCheckPublisher.value.append("wagering")
                        self?.isBettingLimitUpdated.send(true)

                        self?.isLoadingPublisher.send(false)
                    }
                }, receiveValue: { [weak self] updateLimitResponse in

                    self?.limitOptionsCheckPublisher.value.append("wagering")

                    self?.isBettingLimitUpdated.send(true)

                })
                .store(in: &cancellables)
        }
    }

    func updateResponsibleGamingLimit(amount: String) {

        if let limit = Double(amount) {
            Env.servicesProvider.updateResponsibleGamingLimits(newLimit: limit, limitType: "autoPayout")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in

                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("UPDATE RESPONSIBLE LIMIT ERROR: \(error)")
                        let limitErrorMessage = localized("limit_update_error_message").replacingFirstOccurrence(of: "{limitType}", with: localized("auto_payout"))
                        self?.limitOptionsErrorPublisher.send(limitErrorMessage)

                        self?.limitOptionsCheckPublisher.value.append("loss")
                        self?.isAutoPayoutLimitUpdated.send(true)

                        self?.isLoadingPublisher.send(false)
                    }
                }, receiveValue: { [weak self] updateLimitResponse in

                    self?.limitOptionsCheckPublisher.value.append("loss")

                    self?.isAutoPayoutLimitUpdated.send(true)

                })
                .store(in: &cancellables)
        }
    }

    func sendLimit(limitType: String, period: String, amount: String, currency: String) {
//        Env. em .setLimit(limitType: limitType, period: period, amount: amount, currency: currency)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    self?.limitOptionsErrorPublisher.send("\(error)")
//                    self?.isLoadingPublisher.send(false)
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] _ in
//                if limitType == "Deposit" {
//                    self?.limitOptionsCheckPublisher.value.append("deposit")
//                }
//                else if limitType == "Wagering" {
//                    self?.limitOptionsCheckPublisher.value.append("wagering")
//                }
//                else if limitType == "Loss" {
//                    self?.limitOptionsCheckPublisher.value.append("loss")
//                }
//            })
//            .store(in: &cancellables)
    }

    func checkLimitUpdatableStatus(limitType: String, limitAmount: String, isLimitUpdatable: Bool) {

        var limitCurrentAmountString = ""
        var limitAmountTextfieldChanged = false
        var limitCurrentObject: LimitInfo?

        var limitAmountFilter = limitAmount.filter("0123456789.,".contains)
        
        limitAmountFilter = self.normalizeAmounts(amount: limitAmountFilter)

        if limitType == "deposit" {
            limitCurrentObject = self.depositLimit?.current
        }
        else if limitType == "wagering" {
            limitCurrentObject = self.wageringLimit?.current
        }
        else if limitType == "loss" {
//            limitCurrentObject = self.lossLimit?.current
            limitCurrentObject = self.autoPayoutLimit?.current
        }

        if let limitCurrentAmount = limitCurrentObject?.amount {
            //let normalizedCurrentAmount = self.normalizeAmounts(amount: "\(limitCurrentAmount)")
            limitCurrentAmountString = "\(limitCurrentAmount)"
        }

        if limitAmountFilter != "" && limitAmountFilter != limitCurrentAmountString {
            limitAmountTextfieldChanged = true
        }

        if isLimitUpdatable && limitAmountTextfieldChanged  {

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
    
    func normalizeAmounts(amount: String) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        
        if let formattedNumber = numberFormatter.number(from: amount) {
            let numericValueString = "\(formattedNumber.doubleValue)"
            return numericValueString
        } else {
            print("Error formatting number")
        }
        
        return amount
    }

    func cleanLimitOptions() {
        self.limitOptionsSet = []
        self.limitOptionsCheckPublisher.value = []
    }
    
    func refetchLimits() {
        self.limitsLoadedPublisher.send(false)

        self.canUpdateDeposit = false
        self.canUpdateWagering = false
        self.canUpdateLoss = false

        self.depositLimit = nil
        self.wageringLimit = nil
        self.lossLimit = nil
        self.autoPayoutLimit = nil

        self.pendingDepositLimitMessage = nil
        self.pendingWageringLimitMessage = nil
        self.pendingLossLimitMessage = nil

        self.personalDepositLimitLoaded.send(false)
        self.limitsLoaded.send(false)
        self.responsibleGamingLimitLoaded.send(false)
        
        self.limitOptionsErrorPublisher.send("")
        
        self.getLimits()
    }

//    func checkLimitUpdatableStatus(limitType: String, limitAmount: String, limitPeriod: String, isLimitUpdatable: Bool) {
//
//        var limitCurrentAmountString = ""
//        var limitCurrentPeriodString = ""
//        var limitAmountTextfieldChanged = false
//        var limitPeriodChanged = false
////        var limitCurrentObject: EveryMatrix.LimitInfo?
//        var limitCurrentObject: LimitInfo?
//
//        if limitType == "deposit" {
//            limitCurrentObject = self.depositLimit?.current
//        }
//        else if limitType == "wagering" {
//            limitCurrentObject = self.wageringLimit?.current
//        }
//        else if limitType == "loss" {
//            limitCurrentObject = self.lossLimit?.current
//        }
//
//        if let limitCurrentAmount = limitCurrentObject?.amount {
//            limitCurrentAmountString = "\(limitCurrentAmount)"
//        }
//
//        if let limitCurrentPeriod = limitCurrentObject?.period {
//            limitCurrentPeriodString = "\(limitCurrentPeriod)"
//        }
//
//        if limitAmount != "" && limitAmount != limitCurrentAmountString {
//            limitAmountTextfieldChanged = true
//        }
//
//        if limitCurrentPeriodString != "" && limitPeriod != limitCurrentPeriodString {
//            limitPeriodChanged = true
//        }
//
//        if isLimitUpdatable && (limitAmountTextfieldChanged || limitPeriodChanged)  {
//
//            if limitType == "deposit" {
//                self.limitOptionsSet.append("deposit")
//                self.canUpdateDeposit = true
//            }
//            else if limitType == "wagering" {
//                self.limitOptionsSet.append("wagering")
//                self.canUpdateWagering = true
//            }
//            else if limitType == "loss" {
//                self.limitOptionsSet.append("loss")
//                self.canUpdateLoss = true
//            }
//        }
//    }

//    func getWageringOption() -> EveryMatrix.Limit? {
//
//        var wageringOption: EveryMatrix.Limit? = self.wageringLimit
//
//        if self.wageringLimitPerDay?.current != nil {
//            wageringOption = self.wageringLimitPerDay
//            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
//                return wageringOption
//            }
//        }
//        if self.wageringLimitPerWeek?.current != nil {
//            wageringOption = self.wageringLimitPerWeek
//            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
//                return wageringOption
//            }
//        }
//        if self.wageringLimitPerMonth?.current != nil {
//            wageringOption = self.wageringLimitPerMonth
//            if let wageringUpdatable = wageringOption?.updatable, !wageringUpdatable {
//                return wageringOption
//            }
//        }
//
//        return wageringOption
//    }
//
//    func getLossOption() -> EveryMatrix.Limit? {
//
//        var lossOption: EveryMatrix.Limit? = self.lossLimit
//
//        if self.lossLimitPerDay?.current != nil {
//            lossOption = self.lossLimitPerDay
//            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
//                return lossOption
//            }
//        }
//        else if self.lossLimitPerWeek?.current != nil {
//            lossOption = self.lossLimitPerWeek
//            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
//                return lossOption
//            }
//        }
//        else if self.lossLimitPerMonth?.current != nil {
//            lossOption = self.lossLimitPerMonth
//            if let lossUpdatable = lossOption?.updatable, !lossUpdatable {
//                return lossOption
//            }
//        }
//
//        return lossOption
//    }

    func removeLimit(limitType: String, period: String) {
//        Env. em .removeLimit(limitType: limitType, period: period)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    self?.limitOptionsErrorPublisher.send("\(error)")
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { _ in
//            })
//            .store(in: &cancellables)
    }

    func getAlertInfoText(alertType: String) -> String {

        var alertMessage = ""

        if alertType == "deposit" {

//            if let pendingDepositLimitMessage {
//                alertMessage = pendingDepositLimitMessage
//            }
//            else {
//                alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("deposit").lowercased())
//            }
            alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("deposit").lowercased())
        }
        else if alertType == "wagering" {

//            if let pendingWageringLimitMessage {
//                alertMessage = pendingWageringLimitMessage
//            }
//            else {
//                alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("betting").lowercased())
//            }
            alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("betting").lowercased())
        }
        else if alertType == "loss" {

//            if let pendingLossLimitMessage {
//                alertMessage = pendingLossLimitMessage
//            }
//            else {
//                alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("auto_payout").lowercased())
//            }
            alertMessage = localized("current_limit_info").replacingFirstOccurrence(of: "{limitType}", with: localized("auto_payout").lowercased())
        }

        return alertMessage
    }

}

enum LimitUpdateStatus {
    case updated
    case failed
    case idle
}
