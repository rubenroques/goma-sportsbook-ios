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
    private var bettingTicket: BettingTicket
    private var cancellables = Set<AnyCancellable>()

    private var oddUpdatesPublisher: AnyCancellable?
    private var oddUpdatesRegister: EndpointPublisherIdentifiable?

    // MARK: Public Properties
    var oddValuePublisher: CurrentValueSubject<String, Never> = .init("")
    var currentAmountInteger: Int = 0 {
        didSet {
            self.finalBetAmountPublisher.value = Double(currentAmountInteger)/Double(100)
        }
    }
    var finalBetAmountPublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    var returnAmountValue: CurrentValueSubject<Double, Never> = .init(0.0)
    var maxBetStake: Double = 0.0
    var priceValueFactor: Double = 0.0

    var oddStatusPublisher: CurrentValueSubject<OddStatusType, Never> = .init(.same)

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldShowBetError: ((String) -> Void)?
    var shouldShowBetSuccess: (() -> Void)?

    init(bettingTicket: BettingTicket) {
        self.bettingTicket = bettingTicket

        self.requestSimpleBetSelectionState()

        self.setupPublishers()
    }

    deinit {
        self.oddUpdatesPublisher?.cancel()
        self.oddUpdatesPublisher = nil

        if let oddUpdatesRegister = oddUpdatesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: oddUpdatesRegister)
        }
    }

    private func setupPublishers() {

        let endpoint = TSRouter.bettingOfferPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      bettingOfferId: bettingTicket.bettingId)

        self.oddUpdatesPublisher = Env.everyMatrixClient.manager.registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let oddUpdatesRegister):
                    self?.oddUpdatesRegister = oddUpdatesRegister

                case .initialContent(let aggregator):

                    if let content = aggregator.content {
                        for contentType in content {
                            if case let .bettingOffer(bettingOffer) = contentType, let oddsValue = bettingOffer.oddsValue {

                                self?.updateBettingOffer(value: oddsValue)
                                break
                            }
                        }
                    }

                case .updatedContent(let aggregatorUpdates):

                    if let content = aggregatorUpdates.contentUpdates {
                        for contentType in content {
                            if case let .bettingOfferUpdate(_, statusId, odd, _, isAvailable) = contentType {

                                if let newOddValue = odd {
                                    self?.updateBettingOffer(value: newOddValue)
                                }
                            }
                        }
                    }

                case .disconnect:
                    ()
                }
            })
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

    func requestSimpleBetSelectionState() {
        let ticketSelection = EveryMatrix.BetslipTicketSelection(id: self.bettingTicket.id, currentOdd: self.bettingTicket.value)

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .single,
                                                     tickets: [ticketSelection], oddsBoostPercentage: nil)

        Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("QUICKBET STATE ERROR: \(error)")
                case .finished:
                    print("QUICKBET STATE FINISHED")
                }
            } receiveValue: { [weak self] betslipSelectionState in

                if let maxStake = betslipSelectionState.maxStake {
                    self?.maxBetStake = maxStake

                }
            }
            .store(in: &cancellables)
    }

    private func updateBettingOffer(value: Double) {
        let currentOddValue = self.priceValueFactor

        self.oddValuePublisher.value = OddConverter.stringForValue(value, format: UserDefaults.standard.userOddsFormat)

        self.priceValueFactor = value

        if currentAmountInteger != 0 {

            let returnAmount = self.finalBetAmountPublisher.value * value

            self.returnAmountValue.send(returnAmount)

        }

        if currentOddValue != 0 {
            if value > currentOddValue {
                self.oddStatusPublisher.send(.up)
            }
            else if value < currentOddValue {
                self.oddStatusPublisher.send(.down)
            }
            else {
                self.oddStatusPublisher.send(.same)
            }
        }

    }

    func placeBet() {

        self.isLoadingPublisher.send(true)

        let betAmount = self.finalBetAmountPublisher.value

        let ticketSelection = EveryMatrix.BetslipTicketSelection(id: self.bettingTicket.id, currentOdd: self.bettingTicket.value)

        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")

        let route = TSRouter.placeBet(language: "en",
                                      amount: betAmount,
                                      betType: .single,
                                      tickets: [ticketSelection], oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY",
                                      freeBet: false,
                                      ubsWalletId: "")

        Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Quickbet error: \(error)")
                    self?.shouldShowBetError?(error.localizedDescription)
                case .finished:
                    print("Quickbet finished!")
                }

                self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                self?.processBetResponse(response: response)
            })
            .store(in: &cancellables)
    }

    func processBetResponse(response: BetslipPlaceBetResponse) {

        if let betSucceed = response.betSucceed {
            if !betSucceed {
                if let errorMessage = response.errorMessage {
                    self.shouldShowBetError?(errorMessage)
                }
            }
            else {
                self.shouldShowBetSuccess?()
            }
        }
    }

}
