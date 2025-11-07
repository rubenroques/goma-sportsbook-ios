//
//  SportsBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class SportsBetslipViewModel: SportsBetslipViewModelProtocol {
    
    // MARK: - Properties
    private let ticketsSubject = CurrentValueSubject<[BettingTicket], Never>([])
    private var cancellables = Set<AnyCancellable>()
    private var environment: Environment
    
    // Store ticket view models to track odds changes
    private var ticketViewModels: [String: MockBetslipTicketViewModel] = [:]
    
    // Track combined tickets state (invalid state + bet builder data)
    private let ticketsStateSubject = CurrentValueSubject<BetslipTicketsState, Never>(.default)
    public var ticketsStatePublisher: AnyPublisher<BetslipTicketsState, Never> {
        return ticketsStateSubject.eraseToAnyPublisher()
    }
    public var ticketsState: BetslipTicketsState {
        return ticketsStateSubject.value
    }
    
    // Convenience accessors for backward compatibility
    public var ticketsInvalidState: TicketsInvalidState {
        return ticketsStateSubject.value.invalidState
    }
    
    public var betBuilderData: BetBuilderData? {
        return ticketsStateSubject.value.betBuilderData
    }
    
    // MARK: - Child View Models
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    public var oddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol
    public var codeInputViewModel: CodeInputViewModelProtocol
    public var loginButtonViewModel: ButtonViewModelProtocol
    public var betslipOddsBoostHeaderViewModel: BetslipOddsBoostHeaderViewModelProtocol
    
    // MARK: - Publishers
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return ticketsSubject.eraseToAnyPublisher()
    }
    
    public var currentTickets: [BettingTicket] {
        return ticketsSubject.value
    }
    
    public var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)

    public var betslipLoggedState: ((BetslipLoggedState) -> Void)?
    public var showPlacedBetState: ((BetPlacedState) -> Void)?
    public var showLoginScreen: (() -> Void)?
    public var showToastMessage: ((String) -> Void)?
    
    // MARK: - Recommended Matches
    public var suggestedBetsViewModel: SuggestedBetsExpandedViewModelProtocol
    public let toasterViewModel: ToasterViewModelProtocol

    // MARK: - Odds Boost Header Visibility
    private let oddsBoostHeaderVisibilitySubject = CurrentValueSubject<Bool, Never>(false)

    public var oddsBoostHeaderVisibilityPublisher: AnyPublisher<Bool, Never> {
        return oddsBoostHeaderVisibilitySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(environment: Environment) {
        self.environment = environment
        // Initialize child view models
        self.bookingCodeButtonViewModel = MockButtonIconViewModel(
            title: "Booking Code",
            icon: "doc.text",
            layoutType: .iconLeft
        )
        
        self.clearBetslipButtonViewModel = MockButtonIconViewModel(
            title: "Clear Betslip",
            icon: "trash_icon",
            layoutType: .iconLeft
        )
        
        self.emptyStateViewModel = MockEmptyStateActionViewModel(state: .loggedOut, title: "You need at least 1 selection\nin your betslip to place a bet", actionButtonTitle: "Log in to bet", image: "empty_betslip_icon")
        
        // Initialize with default currency, will be updated when user profile is available
        let currency = environment.userSessionStore.userWalletPublisher.value?.currency ?? "XAF"
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel(currency: currency)
        self.oddsAcceptanceViewModel = MockOddsAcceptanceViewModel.acceptedMock()
        self.codeInputViewModel = MockCodeInputViewModel()
        
        
        self.loginButtonViewModel = MockButtonViewModel(buttonData:
                                                            ButtonData(id: "login", title: "Login", style: .solidBackground)
        )
        
        // Initialize suggested bets view model
        self.suggestedBetsViewModel = MockSuggestedBetsExpandedViewModel(
            title: "Explore more bets",
            isExpanded: false,
            matchCardViewModels: []
        )
        
        // Initialize Toaster view model
        self.toasterViewModel = AppToasterViewModel()
        

        // Initialize odds boost header view model
        self.betslipOddsBoostHeaderViewModel = BetslipOddsBoostHeaderViewModel()

        // Setup real data subscription
        setupPublishers()
        getRecommendedMatches()

        // Wire CodeInputView submission to screen-level logic
        self.codeInputViewModel.onSubmitRequested = { [weak self] code in
            self?.getBettingTicketsFromCode(code: code)
        }
    }
    
    private func getRecommendedMatches() {
                
        let userId = environment.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
        
        environment.servicesProvider.getRecommendedMatch(userId: userId, isLive: false, limit: 5)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("RECOMMENDED ERROR: \(error)")
//                    self?.isLoadingSubject.send(false)
                }
            }, receiveValue: { [weak self] events in
                guard let self = self else { return }
                let matches = ServiceProviderModelMapper.matches(fromEvents: events)
                
                let items: [TallOddsMatchCardViewModelProtocol] = matches.map { match in
                    let tallOddsMatchCardViewModel = TallOddsMatchCardViewModel.create(from: match, relevantMarkets: match.markets, marketTypeId: match.markets.first?.typeId ?? "", matchCardContext: .search)
                    return tallOddsMatchCardViewModel
                }
                
                // Update suggested bets view model with matches
                if let mockViewModel = self.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel {
                    mockViewModel.updateMatches(items)
                }
                                
                self.isLoadingSubject.send(false)
            })
            .store(in: &cancellables)
    }

    // MARK: - Booking code loading
    private func getBettingTicketsFromCode(code: String) {
        // Trigger loading state in the component
        codeInputViewModel.setLoading(true)

        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            codeInputViewModel.setLoading(false)
            codeInputViewModel.setError("Booking Code can't be found. It either doesn't exist or expired.")
            return
        }

        // Call loadEventsFromBookingCode to get full Events with markets and outcomes
        environment.servicesProvider.loadEventsFromBookingCode(bookingCode: trimmed)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.codeInputViewModel.setLoading(false)
                    if case .failure(let error) = completion {
                        self.codeInputViewModel.setError("Booking Code can't be found. It either doesn't exist or expired.")
                        print("[BOOKING_CODE] Error loading events: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] events in
                    guard let self = self else { return }
                    self.codeInputViewModel.clearError()
                    print("[BOOKING_CODE] Retrieved \(events.count) events for code: \(trimmed)")

                    // Convert Events to Matches using ServiceProviderModelMapper
                    let matches = ServiceProviderModelMapper.matches(fromEvents: events)
                    print("[BOOKING_CODE] Converted to \(matches.count) matches")

                    // Create BettingTickets from each match's first market's first outcome
                    var addedTicketsCount = 0
                    for match in matches {
                        // Each Event should have one market with one outcome (single betting offer)
                        guard let market = match.markets.first,
                              let outcome = market.outcomes.first else {
                            print("[BOOKING_CODE] Warning: Match \(match.id) has no market/outcome")
                            continue
                        }

                        let ticket = BettingTicket(match: match, market: market, outcome: outcome)
                        self.environment.betslipManager.addBettingTicket(ticket)
                        addedTicketsCount += 1
                        print("[BOOKING_CODE] Added ticket: \(match.homeParticipant.name) vs \(match.awayParticipant.name) - \(outcome.translatedName) @ \(outcome.bettingOffer.decimalOdd)")
                    }

                    self.codeInputViewModel.updateCode("")
                    self.showToastMessage?("Booking Code Loaded (\(addedTicketsCount) selections)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    public func removeTicket(_ ticket: BettingTicket) {
        environment.betslipManager.removeBettingTicket(ticket)
        // Clean up the view model when ticket is removed
        ticketViewModels.removeValue(forKey: ticket.id)
    }
    
    public func clearAllTickets() {
        environment.betslipManager.clearAllBettingTickets()
        // Clean up all view models when clearing betslip
        ticketViewModels.removeAll()
    }
    
    /// Gets or creates a ticket view model, tracking odds changes
    public func getTicketViewModel(
        for ticket: BettingTicket,
        isEnabled: Bool,
        disabledMessage: String?,
        formattedDate: String?
    ) -> MockBetslipTicketViewModel {
        let ticketId = ticket.id
        let newOddsValue = String(format: "%.2f", ticket.decimalOdd)
        
        // Check if we already have a view model for this ticket
        if let existingViewModel = ticketViewModels[ticketId] {
            // Compare old odds with new odds to determine change state
            let oldOddsValue = existingViewModel.currentData.oddsValue
            let oldOdds = Double(oldOddsValue) ?? 0.0
            let newOdds = ticket.decimalOdd
            
            let oddsChangeState: OddsChangeState
            if abs(newOdds - oldOdds) < 0.01 {
                // No significant change
                oddsChangeState = .none
            } else if newOdds > oldOdds {
                // Odds increased
                oddsChangeState = .increased
            } else {
                // Odds decreased
                oddsChangeState = .decreased
            }
            
            // Update the existing view model in place
            existingViewModel.updateOddsValue(newOddsValue)
            print("Updating VM Odds...")
            existingViewModel.updateOddsChangeState(oddsChangeState)
            
            existingViewModel.setEnabled(isEnabled)
            
            // Update other fields that might have changed
            if let date = formattedDate {
                existingViewModel.updateStartDate(date)
            }
            
            return existingViewModel
        } else {
            // Create new view model
            let viewModel = MockBetslipTicketViewModel(
                leagueName: ticket.competition ?? "Unknown League",
                startDate: formattedDate ?? "Unknown Date",
                homeTeam: ticket.homeParticipantName ?? "Home Team",
                awayTeam: ticket.awayParticipantName ?? "Away Team",
                selectedTeam: ticket.outcomeDescription,
                oddsValue: newOddsValue,
                oddsChangeState: .none,
                isEnabled: isEnabled,
                bettingOfferId: ticket.id,
                disabledMessage: disabledMessage
            )
            
            // Store it for future updates
            ticketViewModels[ticketId] = viewModel
            
            return viewModel
        }
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        // Subscribe to real betslip data from the manager
        environment.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                guard let self = self else { return }
                
                self.ticketsSubject.send(tickets)

                // Forward selected outcomes to suggested bets VM (for cell selection state)
                if let mockSuggested = self.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel {
                    let selectedOutcomeIds = Set(tickets.map { String($0.outcomeId) })
                    mockSuggested.updateSelectedOutcomeIds(selectedOutcomeIds)
                }
                
                // Clean up view models for tickets that no longer exist
                let currentTicketIds = Set(tickets.map { $0.id })
                let storedTicketIds = Set(self.ticketViewModels.keys)
                let removedTicketIds = storedTicketIds.subtracting(currentTicketIds)
                
                for removedId in removedTicketIds {
                    self.ticketViewModels.removeValue(forKey: removedId)
                }
                
                // Update valid tickets state
                self.updateValidTicketsState()
            }
            .store(in: &cancellables)
        
        environment.betslipManager.bettingOptionsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingOptions in
                guard let self = self else { return }
                
                // Extract odds from LoadableContent
                if case .loaded(let options) = bettingOptions {
                    // Determine tickets invalid state
                    let invalidState: TicketsInvalidState
                    
                    if !options.forbiddenCombinations.isEmpty {
                        invalidState = .forbidden
                        print("⚠️ FORBIDDEN COMBINATIONS DETECTED - All tickets are forbidden")
                    } else if options.totalOdds == nil || options.totalOdds == 0.0 {
                        invalidState = .invalid
                        print("⚠️ INVALID SELECTION DETECTED - totalOdds is nil or 0")
                    } else {
                        invalidState = .none
                    }
                    
                    var betBuilderOdds: Double? = nil
                    
                    // Extract betBuilder selections (betting offer IDs that should be enabled)
                    var betBuilderOfferIds = Set<String>()
                    for betBuilder in options.betBuilders {
                        
                        // Set first set of betBuilder odds only
                        if betBuilderOdds == nil {
                            betBuilderOdds = betBuilder.betBuilderOdds
                        }
                        
                        for selection in betBuilder.selections {
                            if let bettingOfferId = selection.bettingOfferId {
                                betBuilderOfferIds.insert(bettingOfferId)
                            }
                        }
                    }
                    
                    // Create BetBuilderData if we have betBuilder data
                    let betBuilderData: BetBuilderData?
                    if let betBuilderOdds = betBuilderOdds, !betBuilderOfferIds.isEmpty {
                        betBuilderData = BetBuilderData(
                            totalOdds: betBuilderOdds,
                            bettingOfferIds: Array(betBuilderOfferIds)
                        )
                        print("✅ BET BUILDER DETECTED with \(betBuilderOfferIds.count) valid selections @ \(betBuilderOdds)")
                    } else {
                        betBuilderData = nil
                    }
                    
                    // Send combined state in a single update
                    let ticketsState = BetslipTicketsState(
                        invalidState: invalidState,
                        betBuilderData: betBuilderData
                    )
                    self.ticketsStateSubject.send(ticketsState)
                    
                    // Update odds and calculate potential winnings with priority order
                    let stake = self.betInfoSubmissionViewModel.currentData.amount
                    
                    if let betBuilderOdds {
                        // Priority 1: Use betBuilder odds if present
                        self.updateOdds(totalOdds: betBuilderOdds)
                        self.calculatePotentialWinnings(totalOdds: betBuilderOdds, stake: stake)
                    } else if invalidState != .none {
                        // Priority 2: Set to 0 if invalid or forbidden
                        self.updateOdds(totalOdds: 0.0)
                        self.calculatePotentialWinnings(totalOdds: 0.0, stake: stake)
                    } else if let totalOdds = options.totalOdds {
                        // Priority 3: Use regular totalOdds
                        self.updateOdds(totalOdds: totalOdds)
                        self.calculatePotentialWinnings(totalOdds: totalOdds, stake: stake)
                    } else {
                        // Priority 4: Default to 0 if all else fails
                        self.updateOdds(totalOdds: 0.0)
                        self.calculatePotentialWinnings(totalOdds: 0.0, stake: stake)
                    }
                    
                    // Update valid tickets state after processing betting options
                    self.updateValidTicketsState()
                }
                
                print("Betting Options fetched")
            })
            .store(in: &cancellables)
        
        environment.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.emptyStateViewModel.updateState(.loggedIn)
                } else {
                    self?.emptyStateViewModel.updateState(.loggedOut)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(environment.betslipManager.bettingTicketsPublisher, environment.userSessionStore.userProfilePublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets, userProfile in

                if userProfile == nil {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedOut)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedOut)
                    }
                }
                else {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedIn)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedIn)
                    }
                }

            })
            .store(in: &cancellables)

        // Subscribe to odds boost header visibility requirements
        Publishers.CombineLatest3(
            environment.betslipManager.bettingTicketsPublisher,
            environment.userSessionStore.userProfilePublisher,
            environment.betslipManager.oddsBoostStairsPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] tickets, userProfile, oddsBoostState in
            let hasTickets = !tickets.isEmpty
            let isLoggedIn = userProfile != nil
            let hasOddsBoost = oddsBoostState != nil

            // Show header when: has tickets + logged in + odds boost available
            let shouldShow = hasTickets && isLoggedIn && hasOddsBoost
            self?.oddsBoostHeaderVisibilitySubject.send(shouldShow)
        }
        .store(in: &cancellables)
        
        betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
            self?.placeBet()
        }
        
        betInfoSubmissionViewModel.amountChanged = { [weak self] in
            if let amountDouble = Double(self?.betInfoSubmissionViewModel.currentData.amount ?? "") {
                self?.environment.betslipManager.validateBettingOptions(withStake: amountDouble)
            }
            else {
                self?.calculatePotentialWinnings(totalOdds: 0.0, stake: "0")
            }
        }
        
        
        loginButtonViewModel.onButtonTapped = { [weak self] in
            self?.showLoginScreen?()
        }
    }
    
    private func placeBet() {

        let stake = convertToDouble(betInfoSubmissionViewModel.currentData.amount)

        let oddsValidationType = oddsAcceptanceViewModel.currentData.state == .accepted ? "ACCEPT_ANY" : "ACCEPT_HIGHER"
        
        let betBuilderOdds = self.ticketsStateSubject.value.betBuilderData?.totalOdds

        // Capture current tickets before clearing
        let placedTickets = currentTickets
        print("[BET_PLACEMENT] 📋 Placing bet with \(placedTickets.count) tickets")
        placedTickets.enumerated().forEach { index, ticket in
            print("[BET_PLACEMENT]   [\(index+1)] \(ticket.matchDescription) - \(ticket.outcomeDescription) @ \(ticket.decimalOdd)")
        }

        // Show loading state
        self.isLoadingSubject.send(true)

        environment.betslipManager.placeBet(withStake: stake, useFreebetBalance: false, oddsValidationType: oddsValidationType, betBuilderOdds: betBuilderOdds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // Hide loading state
                switch completion {
                case .finished:
                    print("[BET_PLACEMENT] ✅ Placement request completed")
                case .failure(let error):
                    print("[BET_PLACEMENT] ❌ Placement failed: \(error)")
                    self?.showPlacedBetState?(.error(message: "Bet couldn't be placed. Please try again later!"))
                }

                self?.isLoadingSubject.send(false)

            }, receiveValue: { [weak self] betPlacedDetails in
                print("[BET_PLACEMENT] 🎉 Received response with \(betPlacedDetails.count) items")

                // Debug full response
                betPlacedDetails.enumerated().forEach { index, detail in
                    let response = detail.response
                    print("[BET_PLACEMENT]   Response[\(index)]:")
                    print("[BET_PLACEMENT]     betId: \(response.betId ?? "nil")")
                    print("[BET_PLACEMENT]     betslipId: \(response.betslipId ?? "nil")")
                    print("[BET_PLACEMENT]     betSucceed: \(response.betSucceed?.description ?? "nil")")
                    print("[BET_PLACEMENT]     selections count: \(response.selections?.count ?? 0)")
                }

                let firstResponse = betPlacedDetails.first?.response
                let betId = firstResponse?.betId
                let betslipId = firstResponse?.betslipId

                print("[BET_PLACEMENT] 🏷️ Extracted IDs - betId: \(betId ?? "nil"), betslipId: \(betslipId ?? "nil")")

                self?.showPlacedBetState?(.success(
                    betId: betId,
                    betslipId: betslipId,
                    bettingTickets: placedTickets
                ))

            })
            .store(in: &cancellables)
    }
    
    private func calculatePotentialWinnings(totalOdds: Double, stake: String) {

        guard let amount = Double(stake), amount > 0 else {
            // If no amount or invalid amount, set potential winnings to 0
            let currency = betInfoSubmissionViewModel.currentData.currency
            betInfoSubmissionViewModel.updatePotentialWinnings("\(currency) 0")
            return
        }
        
        // Calculate potential winnings: amount * total odds
        let potentialWinnings = amount * totalOdds
        
        // Get the currency from the bet info submission view model
        let currency = betInfoSubmissionViewModel.currentData.currency
        
        // Format the potential winnings with the correct currency
        let formattedWinnings = String(format: "%@ %.2f", currency, potentialWinnings)
        
        // Update the potential winnings in the bet info submission view model
        betInfoSubmissionViewModel.updatePotentialWinnings(formattedWinnings)
        
        print("Calculated potential winnings: \(formattedWinnings) (Amount: \(amount) × Total Odds: \(totalOdds))")
    }
    
    private func updateOdds(totalOdds: Double) {
        
        let formattedOdds = String(format: "%.2f", totalOdds)

        betInfoSubmissionViewModel.updateOdds(formattedOdds)
        
    }
    
    func convertToDouble(_ string: String) -> Double {
        // Remove any whitespace
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else { return 0.0 }
        
        let normalizedString = trimmed.replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedString) ?? 0.0
    }
    
    /// Evaluates if all tickets are valid/enabled and updates the bet info submission view model
    private func updateValidTicketsState() {
        let tickets = currentTickets
        
        // If no tickets, consider it as valid (allow button to be controlled by amount only)
        guard !tickets.isEmpty else {
            betInfoSubmissionViewModel.updateHasValidTickets(true)
            return
        }
        
        let betBuilderData = self.betBuilderData
        
        // Check if all tickets are enabled
        let allTicketsValid = tickets.allSatisfy { ticket in
            if let betBuilderData = betBuilderData, !betBuilderData.bettingOfferIds.isEmpty {
                // For betBuilder, ticket is valid if it's in the betBuilder offer IDs
                return betBuilderData.bettingOfferIds.contains(ticket.id)
            } else {
                // For regular bets, ticket is valid if there's no invalid state
                return ticketsInvalidState == .none
            }
        }
        
        betInfoSubmissionViewModel.updateHasValidTickets(allTicketsValid)
    }
}

public enum TicketsInvalidState: Equatable {
    case none
    case invalid
    case forbidden
}

public enum BetslipLoggedState {
    case noTicketsLoggedOut
    case ticketsLoggedOut
    case noTicketsLoggedIn
    case ticketsLoggedIn
}

public enum BetPlacedState {
    case success(betId: String?, betslipId: String?, bettingTickets: [BettingTicket])
    case error(message: String)
}
