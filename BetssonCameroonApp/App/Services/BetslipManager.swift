//
//  BetslipManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections
import ServicesProvider

class BetslipManager: NSObject {

    var newBetsPlacedPublisher = PassthroughSubject<Void, Never>.init()
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>

    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>
    private var bettingTicketPublisher: [String: CurrentValueSubject<BettingTicket, Never>]
    private var oddsBoostStairsSubject = CurrentValueSubject<OddsBoostStairsState?, Never>(nil)
    private var bettingOptionsSubject = CurrentValueSubject<LoadableContent<UnifiedBettingOptions>, Never>(.idle)

    private var serviceProviderSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var bettingTicketsCancellables: [String: AnyCancellable] = [:]

    private var cancellables: Set<AnyCancellable> = []

    var oddsBoostStairsPublisher: AnyPublisher<OddsBoostStairsState?, Never> {
        return oddsBoostStairsSubject.eraseToAnyPublisher()
    }

    var bettingOptionsPublisher: AnyPublisher<LoadableContent<UnifiedBettingOptions>, Never> {
        return bettingOptionsSubject.eraseToAnyPublisher()
    }
    
    override init() {
        self.bettingTicketsPublisher = .init([])
        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketPublisher = [:]
        
        super.init()
    }
    
    func start() {
        var cachedBetslipTicketsDictionary: OrderedDictionary<String, BettingTicket> = [:]
        for ticket in UserDefaults.standard.cachedBetslipTickets {
            cachedBetslipTicketsDictionary[ticket.id] = ticket
        }
        self.bettingTicketsDictionaryPublisher.send(cachedBetslipTicketsDictionary)
        
        Env.servicesProvider.eventsConnectionStatePublisher
            .filter({ $0 == .connected })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] _ in
                self?.reconnectBettingTicketsUpdates()
            })
            .store(in: &self.cancellables)
        
        self.bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &self.cancellables)
        
        self.bettingTicketsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { tickets in
                UserDefaults.standard.cachedBetslipTickets = tickets
            }
            .store(in: &self.cancellables)
        
        self.bettingTicketsPublisher
            .removeDuplicates(by: { left, right in
                left.map(\.id) == right.map(\.id)
            })
            .filter({ return !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingTickets in
                self?.requestAllowedBetTypes(withBettingTickets: bettingTickets)
            })
            .store(in: &self.cancellables)
        
        self.bettingTicketsPublisher
            .removeDuplicates(by: { left, right in
                left.map(\.id) == right.map(\.id)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingTickets in
                self?.fetchOddsBoostStairs()
            })
            .store(in: &self.cancellables)

        // Track user login state changes for odds boost
        Env.userSessionStore.userProfileStatusPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
                switch status {
                case .logged:
                    // User just logged in, fetch odds boost if there are tickets
                    print("[ODDS_BOOST] 🔐 User logged in, fetching odds boost stairs")
                    self?.fetchOddsBoostStairs()
                case .anonymous:
                    // User logged out, clear odds boost
                    print("[ODDS_BOOST] 👋 User logged out, clearing odds boost stairs")
                    self?.oddsBoostStairsSubject.send(nil)
                }
            })
            .store(in: &self.cancellables)

        // Track wallet changes to handle auto-login race condition
        // When user auto-logs in (FaceID), profile loads first but wallet loads slightly later
        // This subscription ensures we fetch odds boost once wallet becomes available
        Env.userSessionStore.userWalletPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                guard let self = self else { return }

                // Only fetch when all conditions are met:
                // 1. Wallet just became available (currency is present)
                // 2. User has tickets in betslip
                // 3. User is logged in
                guard wallet?.currency != nil,
                      !self.bettingTicketsPublisher.value.isEmpty,
                      Env.userSessionStore.userProfilePublisher.value != nil else {
                    return
                }

                print("[ODDS_BOOST] 💳 Wallet loaded, fetching odds boost for auto-login scenario")
                self.fetchOddsBoostStairs()
            })
            .store(in: &self.cancellables)

        // Auto-validate betting options when tickets change
        self.bettingTicketsPublisher
            .removeDuplicates(by: { left, right in
                left.map(\.id) == right.map(\.id)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.validateBettingOptions()
            })
            .store(in: &self.cancellables)

        // Re-validate when user logs in (affects bonus eligibility)
        Env.userSessionStore.userProfileStatusPublisher
            .removeDuplicates()
            .filter { $0 == .logged }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                print("[BETTING_OPTIONS] 🔐 User logged in, re-validating betting options")
                self?.validateBettingOptions()
            })
            .store(in: &self.cancellables)

    }
    
    func addBettingTicket(_ bettingTicket: BettingTicket) {
        self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket
        self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
    }
    
    func removeBettingTicket(_ bettingTicket: BettingTicket) {
        self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil
        self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
    }
    
    func removeBettingTicket(withId id: String) {
        self.bettingTicketsDictionaryPublisher.value[id] = nil
        self.unsubscribeBettingTicketPublisher(withId: id)
    }
    
    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }
    
    func hasBettingTicket(withId id: String) -> Bool {
        return self.bettingTicketsDictionaryPublisher.value[id] != nil
    }
    
    func clearAllBettingTickets() {
        for bettingTicket in self.bettingTicketsDictionaryPublisher.value.values {
            self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
        }
        self.bettingTicketsDictionaryPublisher.send([:])
        self.oddsBoostStairsSubject.send(nil)
    }
    
    private func reconnectBettingTicketsUpdates() {
        for bettingTicket in self.bettingTicketsPublisher.value {
            self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
        }
    }
    
    private func unsubscribeBettingTicketPublisher(withId id: String) {
        // Cancel the subscription
        self.serviceProviderSubscriptions[id] = nil
        
        // Cancel combine
        if let subscriber = self.bettingTicketsCancellables[id] {
            subscriber.cancel()
            self.bettingTicketsCancellables.removeValue(forKey: id)
        }
        
        self.bettingTicketPublisher.removeValue(forKey: id)
    }
    
    private func subscribeBettingTicketPublisher(bettingTicket: BettingTicket) {

        if let publisher = self.bettingTicketPublisher[bettingTicket.id] {
            publisher.send(bettingTicket)
        }
        else {
            self.bettingTicketPublisher[bettingTicket.id] = .init(bettingTicket)
        }

        // Subscribe to single outcome updates using the new API
        // bettingTicket.id is the bettingOfferId (outcomeId in EveryMatrix)
        let bettingTicketSubscriber = Env.servicesProvider.subscribeToEventWithSingleOutcome(
            eventId: bettingTicket.matchId,
            outcomeId: bettingTicket.id
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .resourceUnavailableOrDeleted:
                        self?.disableBettingTicket(bettingTicket)
                    default:
                        print("Error retrieving single outcome subscription: \(error)")
                    }
                case .finished:
                    print("Single outcome subscription completed")
                }
            } receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.serviceProviderSubscriptions[bettingTicket.id] = subscription
                case .contentUpdate(let event):
                    // Extract the single market from the event
                    guard let market = event.markets.first else {
                        print("⚠️ BetslipManager: No market found in single outcome event")
                        return
                    }
                    let internalMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)
                    print("Updating market: \(market)")
                    self?.updateBettingTickets(ofMarket: internalMarket)
                case .disconnected:
                    print("Single outcome subscription disconnected")
                }
            }
        self.bettingTicketsCancellables[bettingTicket.id] = bettingTicketSubscriber

    }
    
    private func disableBettingTicket(_ bettingTicket: BettingTicket) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] {
            let newAvailablity = false
            let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                 outcomeId: bettingTicket.outcomeId,
                                                 marketId: bettingTicket.marketId,
                                                 matchId: bettingTicket.matchId,
                                                 marketTypeId: bettingTicket.marketTypeId,
                                                 isAvailable: newAvailablity,
                                                 matchDescription: bettingTicket.matchDescription,
                                                 marketDescription: bettingTicket.marketDescription,
                                                 outcomeDescription: bettingTicket.outcomeDescription,
                                                 homeParticipantName: bettingTicket.homeParticipantName,
                                                 awayParticipantName: bettingTicket.awayParticipantName,
                                                 sport: bettingTicket.sport,
                                                 sportIdCode: bettingTicket.sportIdCode,
                                                 venue: bettingTicket.venue,
                                                 competition: bettingTicket.competition,
                                                 date: bettingTicket.date,
                                                 odd: bettingTicket.odd,
                                                 isFromBetBuilderMarket: bettingTicket.isFromBetBuilderMarket)
            
            self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = newBettingTicket
            self.bettingTicketPublisher[bettingTicket.id]?.send(newBettingTicket)
        }
    }
    
    private func updateBettingTickets(ofMarket market: Market) {
        
        for outcome in market.outcomes {
            if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[outcome.bettingOffer.id] {
                let newAvailablity = market.isAvailable
                let newOdd = outcome.bettingOffer.odd
                let outcomeDescription = outcome.codeName != outcome.typeName ? "\(outcome.codeName) (\(outcome.typeName))" : outcome.codeName
                
                let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                     outcomeId: bettingTicket.outcomeId,
                                                     marketId: bettingTicket.marketId,
                                                     matchId: bettingTicket.matchId,
                                                     marketTypeId: bettingTicket.marketTypeId,
                                                     isAvailable: newAvailablity,
                                                     matchDescription: market.eventName ?? bettingTicket.matchDescription,
                                                     marketDescription: outcome.marketName ?? bettingTicket.marketDescription,
                                                     outcomeDescription: outcomeDescription,
                                                     homeParticipantName: market.homeParticipant ?? bettingTicket.homeParticipantName,
                                                     awayParticipantName: market.awayParticipant ?? bettingTicket.awayParticipantName,
                                                     sport: market.sport ?? bettingTicket.sport,
                                                     sportIdCode: market.sportIdCode ?? bettingTicket.sportIdCode,
                                                     venue: bettingTicket.venue,
                                                     competition: bettingTicket.competition,
                                                     date: market.startDate ?? bettingTicket.date,
                                                     odd: newOdd,
                                                     isFromBetBuilderMarket: bettingTicket.isFromBetBuilderMarket)

                self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = newBettingTicket
                self.bettingTicketPublisher[bettingTicket.id]?.send(newBettingTicket)
                self.validateBettingOptions()
            }
        }
    }
    
    func bettingTicketPublisher(withId id: String) -> AnyPublisher<BettingTicket, Never>? {
        if let bettingTicketPublisher = self.bettingTicketPublisher[id] {
            return bettingTicketPublisher.eraseToAnyPublisher()
        }
        return nil
    }
    
    func getBettingTickets() -> [BettingTicket] {
        return self.bettingTicketsPublisher.value
    }
    
}

//
extension BetslipManager {
    
    func refreshAllowedBetTypes() {
        self.requestAllowedBetTypes(withBettingTickets: self.bettingTicketsPublisher.value)
    }
    
    func requestAllowedBetTypes(withBettingTickets bettingTickets: [BettingTicket]) {

    }

    private func fetchOddsBoostStairs() {
        // Early return if no tickets
        guard !bettingTicketsPublisher.value.isEmpty else {
            print("[ODDS_BOOST] ⚠️ No tickets, skipping odds boost fetch")
            oddsBoostStairsSubject.send(nil)
            return
        }

        // Get currency from user wallet
        guard let currency = Env.userSessionStore.userWalletPublisher.value?.currency else {
            print("[ODDS_BOOST] ⚠️ No user currency, skipping odds boost fetch")
            oddsBoostStairsSubject.send(nil)
            return
        }

        
        
        // Map tickets to OddsBoostStairsSelections
        let oddsBoostSelections = bettingTicketsPublisher.value.map { ticket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: ticket.odd)
            return ServicesProvider.OddsBoostStairsSelection(
                outcomeId: ticket.id,
                eventId: ticket.matchId,
                marketId: ticket.marketId,
                odds: odd
            )
        }

        print("[ODDS_BOOST] Fetching odds boost for \(oddsBoostSelections.count) selections, currency: \(currency)")

        // Call SP method (stake is optional, passing nil)
        Env.servicesProvider.getOddsBoostStairs(
            currency: currency,
            stakeAmount: nil,
            selections: oddsBoostSelections
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("[ODDS_BOOST]  Failed: \(error)")
            }
        }, receiveValue: { [weak self] oddsBoostStairsResponse in
            guard let oddsBoostStairsResponseValue = oddsBoostStairsResponse else {
                print("[ODDS_BOOST]  No bonus available")
                self?.oddsBoostStairsSubject.send(nil)
                return
            }

            // Map SP model to App model
            let oddsBoostStairsState = ServiceProviderModelMapper.oddsBoostStairsState(
                fromServiceProviderResponse: oddsBoostStairsResponseValue
            )

            let currentPercentage = oddsBoostStairsState.currentTier?.percentage ?? 0
            let nextPercentage = oddsBoostStairsState.nextTier?.percentage ?? 0
            print("[ODDS_BOOST] Current: \(currentPercentage * 100)% | Next: \(nextPercentage * 100)%")
            print("[ODDS_BOOST] UBS Wallet ID: \(oddsBoostStairsState.ubsWalletId)")

            if let nextTier = oddsBoostStairsState.nextTier {
                let selectionsNeeded = max(0, nextTier.minSelections - oddsBoostSelections.count)
                if selectionsNeeded > 0 {
                    let qualifier = selectionsNeeded == 1 ? "event" : "events"
                    print("[ODDS_BOOST] Add \(selectionsNeeded) more qualifying \(qualifier) to get a \(Int(nextPercentage * 100))% win boost")
                }
            } else if oddsBoostStairsState.currentTier != nil {
                print("[ODDS_BOOST] Maximum boost reached!")
            }

            self?.oddsBoostStairsSubject.send(oddsBoostStairsState)
        })
        .store(in: &cancellables)
    }

    // MARK: - Betting Options Validation

    private func validateBettingOptions(stakeAmount: Double? = nil) {
        // Early return if no tickets
        guard !bettingTicketsPublisher.value.isEmpty else {
            print("[BETTING_OPTIONS] No tickets, clearing betting options")
            bettingOptionsSubject.send(.idle)
            return
        }

        // Determine bet type (same logic as placeBet method)
        let tickets = bettingTicketsPublisher.value
        let betGroupingType: BetGroupingType = tickets.count == 1
            ? .single(identifier: tickets[0].id)
            : .multiple(identifier: "M")

        // Convert BettingTicket → BetSelection (same pattern as placeBet)
        let betSelections = tickets.map { ticket -> ServicesProvider.BettingOptionsCalculateSelection in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: ticket.odd)
            return ServicesProvider.BettingOptionsCalculateSelection(bettingOfferId: ticket.id, oddFormat: odd)
        }

        print("[BETTING_OPTIONS] Validating \(betSelections.count) selections, betType: \(betGroupingType)")

        // Set loading state
        bettingOptionsSubject.send(.loading)

        // Call betting provider
        Env.servicesProvider.calculateUnifiedBettingOptions(
            betType: betGroupingType,
            selections: betSelections,
            stakeAmount: stakeAmount
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                print("[BETTING_OPTIONS] Failed: \(error)")
                self?.bettingOptionsSubject.send(.failed)
            }
        }, receiveValue: { [weak self] options in
            print("[BETTING_OPTIONS] Valid: \(options.isValid), minStake: \(options.minStake ?? 0), maxStake: \(options.maxStake?.description ?? "nil"), odds: \(options.totalOdds ?? 0)")

            // Show available bonuses
            if !options.availableFreeBets.isEmpty {
                print("[BETTING_OPTIONS] Free bets available: \(options.availableFreeBets.count)")
            }
            if !options.availableOddsBoosts.isEmpty {
                print("[BETTING_OPTIONS] Odds boosts available: \(options.availableOddsBoosts.count)")
            }
            if !options.availableStakeBacks.isEmpty {
                print("[BETTING_OPTIONS] Stake backs available: \(options.availableStakeBacks.count)")
            }

            self?.bettingOptionsSubject.send(.loaded(options))
        })
        .store(in: &cancellables)
    }

    /// Public method to validate betting options with specific stake amount
    func validateBettingOptions(withStake stake: Double) {
        validateBettingOptions(stakeAmount: stake)
    }

    /// Refresh betting options validation
    func refreshBettingOptions() {
        validateBettingOptions()
    }

    func placeBet(withStake stake: Double, useFreebetBalance: Bool, oddsValidationType: String?, betBuilderOdds: Double? = nil) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        guard
            self.bettingTicketsPublisher.value.isNotEmpty
        else {
            return Fail(error: BetslipErrorType.emptyBetslip).eraseToAnyPublisher()
        }
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: bettingTicket.matchDescription,
                                                                         homeTeamName: bettingTicket.homeParticipantName ?? "",
                                                                         awayTeamName: bettingTicket.awayParticipantName ?? "",
                                                                         marketName: bettingTicket.marketId,
                                                                         outcomeName: bettingTicket.outcomeDescription,
                                                                         odd: odd,
                                                                         stake: stake,
                                                                         sportIdCode: bettingTicket.sportIdCode,
                                                                         eventId: bettingTicket.matchId,
                                                                         marketId: bettingTicket.marketId,
                                                                         outcomeId: bettingTicket.id,
                                                                         marketTypeId: bettingTicket.marketTypeId)
            return betTicketSelection
        }
        
        var betGroupingType: BetGroupingType = .single(identifier: "S")
        
        if betTicketSelections.count > 1 {
            betGroupingType = .multiple(identifier: "M")
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections, stake: stake, betGroupingType: betGroupingType)

        let userCurrency = Env.userSessionStore.userProfilePublisher.value?.currency
        let username = Env.userSessionStore.userProfilePublisher.value?.username
        let userId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier

        // Extract ubsWalletId from odds boost state for bonus application
        let ubsWalletId: String? = oddsBoostStairsSubject.value?.ubsWalletId

        let publisher = Env.servicesProvider.placeBets(
            betTickets: [betTicket],
            useFreebetBalance: useFreebetBalance,
            currency: userCurrency,
            username: username,
            userId: userId,
            oddsValidationType: oddsValidationType,
            ubsWalletId: ubsWalletId,
            betBuilderOdds: betBuilderOdds
        )
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenRequest
                case .errorMessage(let message):

                    if message.contains("bet_error") || message == "no_funds" {
                        return BetslipErrorType.betPlacementDetailedError(message: localized(message))
                    }

                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    if message.contains("bet_error") || message == "no_funds" {
                        return BetslipErrorType.betPlacementDetailedError(message: localized(message))
                    }
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .betNeedsUserConfirmation(let betDetails):
                    return BetslipErrorType.betNeedsUserConfirmation(betDetails: betDetails)
                default:
                    return BetslipErrorType.betPlacementError
                }

            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                
                print("Placed bet response: \(placedBetsResponse)")
                
                // Transform PlacedBetsResponse to [BetPlacedDetails]
                let betPlacedDetailsArray: [BetPlacedDetails]
                
                // Prefer detailedBets if available (contains full Bet objects with selections)
                if let detailedBets = placedBetsResponse.detailedBets, !detailedBets.isEmpty {
                    betPlacedDetailsArray = detailedBets.map { bet in
                        // Map BetSelection to BetslipPlaceEntry
                        let selections = bet.selections.map { selection in
                            BetslipPlaceEntry(
                                id: selection.identifier,
                                outcomeId: selection.outcomeId,
                                eventId: selection.eventId,
                                priceValue: selection.odd.decimalOdd
                            )
                        }
                        
                        let response = BetslipPlaceBetResponse(
                            betId: bet.identifier,
                            betSucceed: true,
                            totalPriceValue: bet.totalOdd,
                            amount: bet.stake,
                            type: bet.type,
                            maxWinning: bet.potentialReturn,
                            selections: selections,
                            betslipId: placedBetsResponse.identifier
                        )
                        
                        return BetPlacedDetails(response: response)
                    }
                } else {
                    // Fallback to bets array (PlacedBetEntry objects)
                    betPlacedDetailsArray = placedBetsResponse.bets.map { placedBetEntry in
                        // For PlacedBetEntry, we don't have selection details, so create minimal entries
                        let selections: [BetslipPlaceEntry] = placedBetEntry.betLegs.map { leg in
                            BetslipPlaceEntry(
                                id: leg.identifier,
                                outcomeId: nil,
                                eventId: nil,
                                priceValue: leg.odd
                            )
                        }
                        
                        let response = BetslipPlaceBetResponse(
                            betId: placedBetEntry.identifier,
                            betSucceed: true,
                            totalPriceValue: placedBetEntry.betLegs.map { $0.odd }.reduce(1.0, *),
                            amount: placedBetEntry.totalStake,
                            type: placedBetEntry.type,
                            maxWinning: placedBetEntry.potentialReturn,
                            selections: selections,
                            betslipId: placedBetsResponse.identifier
                        )
                        
                        return BetPlacedDetails(response: response)
                    }
                }
                
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
                
            })
            .handleEvents(receiveOutput: { betPlacedDetailsArray in
                let shouldUpdate: Bool = betPlacedDetailsArray.map(\.response.betSucceed).compactMap({ $0 }).allSatisfy { $0 }
                if shouldUpdate {
                    self.newBetsPlacedPublisher.send()
                    Env.userSessionStore.refreshUserWallet()
                }
            })
            .eraseToAnyPublisher()
        
        return publisher
    }
    
}
