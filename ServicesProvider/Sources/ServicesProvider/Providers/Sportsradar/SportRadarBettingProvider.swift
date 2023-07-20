//
//  SportRadarBettingProvider.swift
//
//
//  Created by Ruben Roques on 16/11/2022.
//

import Foundation
import Combine

class SportRadarBettingProvider: BettingProvider, Connector {

    var sessionCoordinator: SportRadarSessionCoordinator

    private var connector: BettingConnector
    private var cancellables: Set<AnyCancellable> = []

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }
    private var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.disconnected)

    init(sessionCoordinator: SportRadarSessionCoordinator, connector: BettingConnector = BettingConnector()) {
        self.sessionCoordinator = sessionCoordinator
        self.connector = connector

        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if let launchTokenValue = launchToken  {
                    self?.connector.saveSessionKey(launchTokenValue)
                }
                else {
                    self?.connector.clearSessionKey()
                }
            }
            .store(in: &cancellables)

        self.connectionStateSubject.send(self.connector.connectionStateSubject.value)

        self.connector.requestTokenRefresher = { [weak self] in
            if let self = self, let refresher = self.sessionCoordinator.forceTokenRefresh(forKey: .launchToken) {
                return refresher
            }
            else {
                return Just(Optional<String>.none).eraseToAnyPublisher()
            }
        }
    }

    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: nil, betResult: nil, pageSize: 10)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.opened], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
    }

    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.settled, SportRadarModels.BetState.closed, SportRadarModels.BetState.cancelled], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.settled, SportRadarModels.BetState.closed, SportRadarModels.BetState.cancelled], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        let endpoint = BettingAPIClient.getAllowedBetTypes(betTicketSelections: betTicketSelections)
        let publisher: AnyPublisher<[SportRadarModels.BetType], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (sportRadarBetTypes: [SportRadarModels.BetType]) -> [BetType] in
                return sportRadarBetTypes.map(SportRadarModelMapper.betType(fromInternalBetType:))
            }
            .eraseToAnyPublisher()
    }

    func calculatePotentialReturn(forBetTicket betTicket: BetTicket)  -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateReturns(betTicket: betTicket)
        let publisher: AnyPublisher<SportRadarModels.BetslipPotentialReturnResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (betslipPotentialReturn: SportRadarModels.BetslipPotentialReturnResponse) -> BetslipPotentialReturn in
                return BetslipPotentialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                              totalStake: betslipPotentialReturn.totalStake,
                                              numberOfBets: betslipPotentialReturn.numberOfBets,
                                              totalOdd: betslipPotentialReturn.totalOdd ?? 1.0)
            }
            .eraseToAnyPublisher()
    }

    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        let endpoint = BettingAPIClient.placeBets(betTickets: betTickets, useFreebetBalance: useFreebetBalance)
        let publisher: AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .flatMap { (internalPlacedBetsResponse: SportRadarModels.PlacedBetsResponse) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> in

                if internalPlacedBetsResponse.responseCode == "1" ||
                    internalPlacedBetsResponse.responseCode == "2" ||
                    internalPlacedBetsResponse.responseCode == "3"
                {
                    let placedBetsResponse = SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: internalPlacedBetsResponse)
                    return Just( placedBetsResponse ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                else {
                    let notPlacedBetError = ServiceProviderError.notPlacedBet(message: internalPlacedBetsResponse.errorMessage ?? "")
                    return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

//    private func placeInternalBets(betTickets: [BetTicket]) -> AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> {
//        let endpoint = BettingAPIClient.placeBets(betTickets: betTickets)
//        let publisher: AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> = self.connector.request(endpoint)
//
//        return publisher
//            .tryCatch { [weak self] (error: ServiceProviderError) -> AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> in
//                guard let self = self else { throw error }
//                if case ServiceProviderError.unauthorized = error,
//                   let refresher = self.sessionCoordinator.forceTokenRefresh(forKey: .launchToken) {
//                    return refresher
//                        .setFailureType(to: ServiceProviderError.self)
//                        .flatMap({ [weak self] (newToken: String?) -> AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> in
//                            guard
//                                let self = self
//                            else {
//                                return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
//                            }
//                            return self.placeInternalBets(betTickets: betTickets).eraseToAnyPublisher()
//                        })
//                        .eraseToAnyPublisher()
//                }
//                else {
//                    throw error
//                }
//            }
//            .mapError({ error in
//                if let typedError = error as? ServiceProviderError {
//                    return typedError
//                }
//                return ServiceProviderError.invalidResponse
//            })
//            .eraseToAnyPublisher()
//    }

//    func
//
//        return publisher
//            .map({ SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: $0) })
//            .flatMap({ (statusResponse: SportRadarModels.StatusResponse) -> AnyPublisher<SignUpResponse, ServiceProviderError> in
//            if statusResponse.status == "SUCCESS" || statusResponse.status == "BONUSPLAN_NOT_FOUND" {
//                return Just( SignUpResponse(successful: true) ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
//            }
//            else if let errors = statusResponse.errors {
//                let mappedErrors = errors.map { error -> SignUpResponse.SignUpError in
//                    return SignUpResponse.SignUpError(field: error.field, error: error.error)
//                }
//                return Just( SignUpResponse(successful: false, errors: mappedErrors) ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
//            }
//            return Fail(outputType: PlacedBetsResponse.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
//        })
//        .eraseToAnyPublisher()
//
//        return publisher
//            .map({ SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: $0) })
//            .eraseToAnyPublisher()
// }

    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
//        let endpoint = BettingAPIClient.betDetails(identifier: identifier)
//        let publisher: AnyPublisher<SportRadarModels.Bet, ServiceProviderError> = self.connector.request(endpoint)
//        return publisher.map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory: <#T##SportRadarModels.BettingHistory#>)

        return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
    }

    func calculateCashout(betId: String, stakeValue: String? = nil) -> AnyPublisher<Cashout, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateCashout(betId: betId, stakeValue: stakeValue)
        let publisher: AnyPublisher<SportRadarModels.Cashout, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map( { cashout in
                let cashout = SportRadarModelMapper.cashout(fromInternalCashout: cashout)

                return cashout
            }).eraseToAnyPublisher()
    }

    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double? = nil) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        let endpoint = BettingAPIClient.cashoutBet(betId: betId, cashoutValue: cashoutValue, stakeValue: stakeValue)
        let publisher: AnyPublisher<SportRadarModels.CashoutResult, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .flatMap({ cashoutResult -> AnyPublisher<CashoutResult, ServiceProviderError> in
                if let message = cashoutResult.message {
                    return Fail(outputType: CashoutResult.self, failure: ServiceProviderError.errorMessage(message: message)).eraseToAnyPublisher()
                }
                let cashoutResult = SportRadarModelMapper.cashoutResult(fromInternalCashoutResult: cashoutResult)

                return Just(cashoutResult).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }).eraseToAnyPublisher()
    }

    func getBetslipSettings() -> AnyPublisher<BetslipSettings?, Never> {

        let endpoint = BettingAPIClient.getBetslipSettings
        let publisher: AnyPublisher<SportRadarModels.BetslipSettings, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map({ internalBetslipSettings in
                return BetslipSettings(acceptingAnyReoffer: internalBetslipSettings.acceptingAnyReoffer)
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never> {

        let endpoint = BettingAPIClient.updateBetslipSettings(acceptingReoffer: betslipSettings.acceptingAnyReoffer)
        let publisher: AnyPublisher<SportRadarModels.BetslipSettings, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .mapError({ error in
                return error
            })
            .map({ internlBetslipSettings -> Bool in
                return true
            })
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func getFreebet() -> AnyPublisher<FreebetBalance, ServiceProviderError> {

        let endpoint = BettingAPIClient.getFreebetBalance
        let publisher: AnyPublisher<SportRadarModels.FreebetResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map({ freeBet -> FreebetBalance in
                return FreebetBalance(balance: freeBet.balance)
            })
            .eraseToAnyPublisher()
    }

    func getSharedTicket(betslipId: String) -> AnyPublisher<SharedTicketResponse, ServiceProviderError> {
        let endpoint = BettingAPIClient.getSharedTicket(betslipId: betslipId)
        let publisher: AnyPublisher<SportRadarModels.SharedTicketResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (sharedTicketResponse: SportRadarModels.SharedTicketResponse) -> SharedTicketResponse in

                return SportRadarModelMapper.sharedTicketResponse(fromInternalSharedTicketResponse: sharedTicketResponse)
            }
            .eraseToAnyPublisher()
    }

    func getTicketSelection(ticketSelectionId: String) -> AnyPublisher<TicketSelection, ServiceProviderError> {
        let endpoint = BettingAPIClient.getTicketSelection(ticketSelectionId: ticketSelectionId)
        let publisher: AnyPublisher<SportRadarModels.TicketSelectionResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .flatMap { (ticketSelectionResponse: SportRadarModels.TicketSelectionResponse) -> AnyPublisher<TicketSelection, ServiceProviderError> in

                if let error = ticketSelectionResponse.errorType {
                    return Fail(outputType: TicketSelection.self, failure: ServiceProviderError.errorMessage(message: error)).eraseToAnyPublisher()
                }

                if let ticketSelection = ticketSelectionResponse.data {
                    let mappedTicketSelection = SportRadarModelMapper.ticketSelection(fromInternalTicketSelection: ticketSelection)

                    return Just(mappedTicketSelection).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                return Fail(outputType: TicketSelection.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()

            }
            .eraseToAnyPublisher()
    }

    func calculateCashback(betSelectionData: [BetTicketSelection], stakeValue: String) -> AnyPublisher<CashbackResult, ServiceProviderError> {

        let betLegs = betSelectionData.map({ betSelection in

            let betLeg = BetLeg(idFOEvent: betSelection.eventName, idFOMarket: betSelection.marketName, idFOSport: "SPORT", idFOSelection: betSelection.identifier, priceType: "CP", priceUp: "\(betSelection.odd.fractionOdd?.numerator ?? 0)", priceDown: "\(betSelection.odd.fractionOdd?.denominator ?? 0)")

            return betLeg
        })

        let betData = BetData(betLegs: betLegs, betType: "A", wunitstake: stakeValue)

        var bodyString = ""

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(betData)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                bodyString = jsonString
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }

        let endpoint = BettingAPIClient.calculateCashback(betSelectionData: bodyString)

        let publisher: AnyPublisher<[SportRadarModels.CashbackResult], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .flatMap { (cashbackResultResponse: [SportRadarModels.CashbackResult]) -> AnyPublisher<CashbackResult, ServiceProviderError> in

                if let cashbackResult = cashbackResultResponse.first {

                    let mappedCashbackResult = SportRadarModelMapper.cashbackResult(fromInternalCashbackResult: cashbackResult)

                    return Just(mappedCashbackResult).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }

                return Fail(outputType: CashbackResult.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()

            }
            .eraseToAnyPublisher()

//        return publisher
//            .map( { cashbackResultResponse in
//
//                if let cashbackResult = cashbackResultResponse.first {
//
//                    let mappedCashbackResult = SportRadarModelMapper.cashbackResult(fromInternalCashbackResult: cashbackResult)
//
//                    return mappedCashbackResult
//                }
//
//                return Fail(outputType: CashbackResult.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
//
//            }).eraseToAnyPublisher()
    }

}

