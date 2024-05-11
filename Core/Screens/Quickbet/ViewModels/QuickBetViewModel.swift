//
//  QuickBetViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 24/08/2022.
//

import Foundation
import Combine

class QuickBetViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var bettingTicket: BettingTicket

    var oddValuePublisher: CurrentValueSubject<String, Never> = .init("")
    var currentAmountInteger: Int = 0 {
        didSet {
            self.finalBetAmountPublisher.value = Double(currentAmountInteger)/Double(100)
        }
    }
    var finalBetAmountPublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    var returnAmountValue: CurrentValueSubject<Double, Never> = .init(0.0)
    var maxBetStake: Double = 0.0
    var priceValueFactor: Double = 1.0

    var oddStatusPublisher: CurrentValueSubject<OddStatusType, Never> = .init(.same)

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isAvailableOdd: CurrentValueSubject<Bool, Never> = .init(true)

    var shouldShowBetError: ((String) -> Void)?
    var shouldShowBetSuccess: (([BetPlacedDetails]) -> Void)?

    init(bettingTicket: BettingTicket) {
        self.bettingTicket = bettingTicket

        self.setupPublishers()
    }


    private func setupPublishers() {
        // TODO: Watch odd updates on quick bet view
    }

    func getOutcome() -> String {
        return bettingTicket.outcomeDescription
    }

    func getMarket() -> String {
        return bettingTicket.marketDescription
    }

    func getMatch() -> String {
        return bettingTicket.matchDescription
    }

    func updateBetAmountValue(amount: String, isInput: Bool = false, isMaxStake: Bool = false) {

        var currentValue = self.currentAmountInteger

        if isInput {

            if let insertedDigit = Int(amount) {
                currentValue = currentValue * 10 + insertedDigit
            }
            if amount == "" {
                currentValue /= 10
            }

            let calculatedAmount = (Double(currentValue/100) + Double(currentValue%100)/100)

            self.currentAmountInteger = currentValue

            self.finalBetAmountPublisher.send(calculatedAmount)

            let returnAmount = calculatedAmount * self.priceValueFactor

            self.returnAmountValue.send(returnAmount)
        }
        else {

            if let addedAmount = Double(amount) {

                if !isMaxStake {
                    currentValue += Int(addedAmount * 100.0)
                }
                else {
                    currentValue = Int(addedAmount * 100.0)
                }
            }

            let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100

            self.currentAmountInteger = currentValue

            self.finalBetAmountPublisher.send(calculatedAmount)

            let returnAmount = calculatedAmount * self.priceValueFactor

            self.returnAmountValue.send(returnAmount)
        }
    }

    private func updateBettingOffer(value: Double?, isAvailable: Bool?, statusId: String?) {

        let isOddAvailable = (statusId ?? "1") == "1" && isAvailable ?? true

        if isOddAvailable {
            self.isAvailableOdd.send(true)

            if let newOddValue = value {

                let currentOddValue = self.priceValueFactor

//                self.oddValuePublisher.value = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                self.oddValuePublisher.value = OddFormatter.formatOdd(withValue: newOddValue)

                self.priceValueFactor = newOddValue

                if currentAmountInteger != 0 {

                    let returnAmount = self.finalBetAmountPublisher.value * newOddValue

                    self.returnAmountValue.send(returnAmount)

                }

                if currentOddValue != 0 {
                    if newOddValue > currentOddValue {
                        self.oddStatusPublisher.send(.up)
                    }
                    else if newOddValue < currentOddValue {
                        self.oddStatusPublisher.send(.down)
                    }
                    else {
                        self.oddStatusPublisher.send(.same)
                    }
                }
            }
        }
        else {
            self.isAvailableOdd.send(false)
        }

    }

    func placeBet() {

        self.isLoadingPublisher.send(true)

        let betAmount = self.finalBetAmountPublisher.value
        let ticketSelection = EveryMatrix.BetslipTicketSelection(id: self.bettingTicket.id, currentOdd: self.bettingTicket.decimalOdd)

        Env.betslipManager.placeQuickBet(bettingTicket: self.bettingTicket, amount: betAmount, useFreebetBalance: false)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    var message = ""
                    switch error {
                    case .betPlacementDetailedError(let detailedMessage):
                        message = detailedMessage
                    default:
                        message = localized("error_placing_bet")
                    }
                    self?.shouldShowBetError?(message)
                default: ()
                }
                self?.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] betPlacedDetails in
                if betPlacedDetails.first?.response.betSucceed ?? false {
                    self?.shouldShowBetSuccess?(betPlacedDetails)
                }
                else {
                    let defaultError = localized("error_placing_bet")
                    self?.shouldShowBetError?(defaultError)
                }
                Env.userSessionStore.refreshUserWallet()
            })
            .store(in: &cancellables)
    }
}
