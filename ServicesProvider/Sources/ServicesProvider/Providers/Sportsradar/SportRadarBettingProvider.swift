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
        let publisher: AnyPublisher<[FailableDecodable<SportRadarModels.Bet>], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map { failableBets in
                // Filter out any nil contents (failed decodes)
                let validBets = failableBets.compactMap { $0.content }
                return SportRadarModels.BettingHistory(bets: validBets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
    }

    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.opened], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)

        let publisher: AnyPublisher<[FailableDecodable<SportRadarModels.Bet>], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map { failableBets in
                // Filter out any nil contents (failed decodes)
                let validBets = failableBets.compactMap { $0.content }
                return SportRadarModels.BettingHistory(bets: validBets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
    }

    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.settled, SportRadarModels.BetState.closed, SportRadarModels.BetState.cancelled], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)
        let publisher: AnyPublisher<[FailableDecodable<SportRadarModels.Bet>], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map { failableBets in
                // Filter out any nil contents (failed decodes)
                let validBets = failableBets.compactMap { $0.content }
                return SportRadarModels.BettingHistory(bets: validBets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
    }

    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: startDate, endDate: endDate, betState: [SportRadarModels.BetState.settled, SportRadarModels.BetState.closed, SportRadarModels.BetState.cancelled], betResult: [SportRadarModels.BetResult.notSpecified], pageSize: 20)
        let publisher: AnyPublisher<[FailableDecodable<SportRadarModels.Bet>], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .map { failableBets in
                // Filter out any nil contents (failed decodes)
                let validBets = failableBets.compactMap { $0.content }
                return SportRadarModels.BettingHistory(bets: validBets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
    }

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        let endpoint = BettingAPIClient.getAllowedBetTypes(betTicketSelections: betTicketSelections)
        let publisher: AnyPublisher<[SportRadarModels.BetType], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (sportRadarBetTypes: [SportRadarModels.BetType]) -> [BetType] in
                let mappedBetTypes = sportRadarBetTypes.map(SportRadarModelMapper.betType(fromInternalBetType:))
                return mappedBetTypes
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

//                if internalPlacedBetsResponse.responseCode == "1" ||
//                    internalPlacedBetsResponse.responseCode == "2" ||
//                    internalPlacedBetsResponse.responseCode == "3"

                if internalPlacedBetsResponse.responseCode == "2" {
                    let placedBetsResponse = SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: internalPlacedBetsResponse)
                    return Just( placedBetsResponse ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                else if internalPlacedBetsResponse.responseCode == "1" && internalPlacedBetsResponse.detailedResponseCode == "66" {
                    var placedBetsResponse = SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: internalPlacedBetsResponse)
                    placedBetsResponse.requiredConfirmation = true

                    let notPlacedBetError = ServiceProviderError.betNeedsUserConfirmation(betDetails: placedBetsResponse)
                    return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                        .eraseToAnyPublisher()
                }
                else {

                    if internalPlacedBetsResponse.responseCode == "4",
                       let message = internalPlacedBetsResponse.errorMessage,
                       message.contains("wager limit") {

                        let notPlacedBetError = ServiceProviderError.notPlacedBet(message: "bet_error_wager_limit")
                        return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                            .eraseToAnyPublisher()
                    }

                    let notPlacedBetError = ServiceProviderError.notPlacedBet(message: internalPlacedBetsResponse.errorMessage ?? "")
                    return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = BettingAPIClient.confirmBoostedBet(identifier: identifier)
        let publisher: AnyPublisher<SportRadarModels.ConfirmBetPlaceResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .mapError { error in
                return ServiceProviderError.invalidResponse
            }
            .map({ confirmBetPlaceResponse -> Bool in
                return confirmBetPlaceResponse.state == 2
            })
            .eraseToAnyPublisher()
    }

    func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = BettingAPIClient.rejectBoostedBet(identifier: identifier)
        let publisher: AnyPublisher<NoReply, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .tryCatch { error -> AnyPublisher<NoReply, ServiceProviderError> in
                guard
                    case .decodingError = error
                else {
                    throw ServiceProviderError.invalidResponse
                }

                return Just( NoReply() )
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
            .mapError { _ in
                return ServiceProviderError.invalidResponse
            }
            .map({ noReplay -> Bool in
                return true
            })
            .eraseToAnyPublisher()
    }

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

    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError> {
        let endpoint = BettingAPIClient.getAllowedCashoutBetIds
        let publisher: AnyPublisher<[Double], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map({ idsArray in
                let mappedDoubles = idsArray.map { value in
                    return String(format: "%.2f", value)
                }
                return mappedDoubles
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
                return BetslipSettings(oddChangeLegacy: internalBetslipSettings.oddChangeLegacy,
                                       oddChangeRunningOrPreMatch: internalBetslipSettings.oddChangeRunningOrPreMatch)
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never> {

        if let oddChangeRunningOrPreMatch = betslipSettings.oddChangeRunningOrPreMatch {
            let endpointPreMatch = BettingAPIClient.updateBetslipSettingsPreMatch(oddChange: oddChangeRunningOrPreMatch)
            let publisherPreMatch: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpointPreMatch)

            let endpointRunning = BettingAPIClient.updateBetslipSettingsRunning(oddChange: oddChangeRunningOrPreMatch)
            let publisherRunning: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpointRunning)

            return Publishers.CombineLatest(publisherPreMatch, publisherRunning)
                .map({ publisherPreMatchResponse, publisherRunningResponse -> Bool in
                    return true
                })
                .replaceError(with: false)
                .eraseToAnyPublisher()
        }
        else if let oddChangeLegacy = betslipSettings.oddChangeLegacy {
            let endpointLegacy = BettingAPIClient.updateBetslipSettings(oddChange: oddChangeLegacy)
            let publisherLegacy: AnyPublisher<String, ServiceProviderError> = self.connector.request(endpointLegacy)
            return publisherLegacy
                .mapError({ error in
                    return error
                })
                .map({ internlBetslipSettings -> Bool in
                    return true
                })
                .replaceError(with: false)
                .eraseToAnyPublisher()
        }
        else {
            return Just(false).eraseToAnyPublisher()
        }


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

    func calculateCashback(forBetTicket betTicket: BetTicket)  -> AnyPublisher<CashbackResult, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateCashback(betTicket: betTicket)
        let publisher: AnyPublisher<[SportRadarModels.CashbackResult], ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .mapError({ error in
                print("CASHBACK ERROR: \(error)")
                return error
            })
            .flatMap { (cashbackResultResponse: [SportRadarModels.CashbackResult]) -> AnyPublisher<CashbackResult, ServiceProviderError> in
                if let cashbackResult = cashbackResultResponse.first {
                    let mappedCashbackResult = SportRadarModelMapper.cashbackResult(fromInternalCashbackResult: cashbackResult)
                    return Just(mappedCashbackResult).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                return Fail(outputType: CashbackResult.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

    }

    func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket)  -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateBetBuilderReturn(betTicket: betTicket)
        let publisher: AnyPublisher<SportRadarModels.BetBuilderPotentialReturn, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (betslipPotentialReturn: SportRadarModels.BetBuilderPotentialReturn) -> BetBuilderPotentialReturn in
                return BetBuilderPotentialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                                 calculatedOdds: betslipPotentialReturn.calculatedOdds)
            }
            .mapError({ serviceProviderError in
                print("calculateBetBuilderPotentialReturn error: \(serviceProviderError)")
                return serviceProviderError
            })
            .eraseToAnyPublisher()
    }

    func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double, useFreebetBalance: Bool) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        let endpoint = BettingAPIClient.placeBetBuilderBet(betTicket: betTicket, calculatedOdd: calculatedOdd, useFreebetBalance: useFreebetBalance)
        let publisher: AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> = self.connector.request(endpoint)

        return publisher
            .flatMap { (internalPlacedBetsResponse: SportRadarModels.PlacedBetsResponse) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> in
                if internalPlacedBetsResponse.responseCode == "2" {
                    let placedBetsResponse = SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: internalPlacedBetsResponse)
                    return Just( placedBetsResponse ).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                else if internalPlacedBetsResponse.responseCode == "1" && internalPlacedBetsResponse.detailedResponseCode == "66" {
                    var placedBetsResponse = SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: internalPlacedBetsResponse)
                    placedBetsResponse.requiredConfirmation = true

                    let notPlacedBetError = ServiceProviderError.betNeedsUserConfirmation(betDetails: placedBetsResponse)
                    return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                        .eraseToAnyPublisher()
                }
                else {

                    if internalPlacedBetsResponse.responseCode == "4",
                       let message = internalPlacedBetsResponse.errorMessage,
                       message.contains("wager limit") {

                        let notPlacedBetError = ServiceProviderError.notPlacedBet(message: "bet_error_wager_limit")
                        return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                            .eraseToAnyPublisher()
                    }

                    let notPlacedBetError = ServiceProviderError.notPlacedBet(message: internalPlacedBetsResponse.errorMessage ?? "")
                    return Fail(outputType: PlacedBetsResponse.self, failure: notPlacedBetError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

