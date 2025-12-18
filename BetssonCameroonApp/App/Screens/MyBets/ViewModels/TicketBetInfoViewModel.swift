import Foundation
import Combine
import GomaUI
import ServicesProvider

final class TicketBetInfoViewModel: TicketBetInfoViewModelProtocol {
    
    // MARK: - Properties
    
    private let myBet: MyBet
    private let servicesProvider: ServicesProvider.Client
    private let betInfoSubject: CurrentValueSubject<TicketBetInfoData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels

    var rebetButtonViewModel: ButtonIconViewModelProtocol
    var cashoutButtonViewModel: ButtonIconViewModelProtocol

    // MARK: - Cashout Component ViewModels
    private(set) var cashoutSliderViewModel: CashoutSliderViewModelProtocol?
    private(set) var cashoutAmountViewModel: CashoutAmountViewModelProtocol?

    // Internal references for updates
    private var _cashoutSliderVM: CashoutSliderViewModel?
    private var _cashoutAmountVM: CashoutAmountViewModel?

    // Store values for calculations
    private var fullCashoutValue: Double = 0.0
    private var remainingStake: Double = 0.0

    // SSE subscription for real-time cashout value updates
    private var sseSubscription: AnyCancellable?

    // MARK: - Cashout Execution State Machine
    private let cashoutStateSubject = CurrentValueSubject<CashoutExecutionState, Never>(.idle)
    private var lastCashoutRequest: CashoutRequest?

    // MARK: - Publishers
    
    var currentBetInfo: TicketBetInfoData {
        betInfoSubject.value
    }
    
    var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> {
        betInfoSubject.eraseToAnyPublisher()
    }

    var isCashoutLoading: Bool {
        cashoutStateSubject.value.isLoading
    }

    var isCashoutLoadingPublisher: AnyPublisher<Bool, Never> {
        cashoutStateSubject
            .map { $0.isLoading }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var cashoutStatePublisher: AnyPublisher<CashoutExecutionState, Never> {
        cashoutStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Callbacks
    
    var onNavigationTap: ((MyBet) -> Void)?
    var onRebetTap: ((MyBet) -> Void)?
    var onCashoutTap: ((MyBet) -> Void)?

    /// Called when cashout completes: (betId, isFullCashout, error?)
    var onCashoutCompleted: ((String, Bool, CashoutExecutionError?) -> Void)?

    /// Called to show error alert: (message, retryAction)
    var onCashoutError: ((String, @escaping () -> Void) -> Void)?

    // MARK: - Initialization
    
    init(myBet: MyBet, servicesProvider: ServicesProvider.Client) {
        self.myBet = myBet
        self.servicesProvider = servicesProvider
        
        // Create initial ticket bet info data using proper patterns
        let initialBetInfo = Self.createTicketBetInfoData(from: myBet)
        self.betInfoSubject = CurrentValueSubject(initialBetInfo)
        
        self.rebetButtonViewModel = ButtonIconViewModel.rebetButton(
            isEnabled: false
        )
        
        self.cashoutButtonViewModel = ButtonIconViewModel.cashoutButton(
            isEnabled: false
        )

        setupButtonsActions(bet: myBet)
        setupCashoutViewModels(for: myBet)

        // Subscribe to SSE for real-time cashout value updates
        if myBet.canCashOut {
            subscribeToCashoutUpdates()
        }
    }

    deinit {
        sseSubscription?.cancel()
    }
    
    // MARK: - Protocol Methods
    
    func handleNavigationTap() {
        onNavigationTap?(myBet)
    }
    
    func handleRebetTap() {
        guard canRebet(myBet) else { return }
        onRebetTap?(myBet)
    }
    
    func handleCashoutTap() {
        guard canCashout(myBet) else { return }
        onCashoutTap?(myBet)
    }
    
    // MARK: - Public Methods
    
    func updateBetInfo(_ updatedBet: MyBet) {
        let updatedBetInfo = Self.createTicketBetInfoData(from: updatedBet)
        betInfoSubject.send(updatedBetInfo)
        
        // Update button states - cast to concrete types to access setEnabled
        if let rebetVM = rebetButtonViewModel as? ButtonIconViewModel {
            rebetVM.setEnabled(canRebet(updatedBet))
        }
        if let cashoutVM = cashoutButtonViewModel as? ButtonIconViewModel {
            cashoutVM.setEnabled(canCashout(updatedBet))
        }
    }
    
    // MARK: - Private Methods
    private func setupButtonsActions(bet: MyBet) {
        
        // Create button view models
        rebetButtonViewModel.setEnabled(canRebet(bet))
        
        rebetButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleRebetTap()
        }
                
        cashoutButtonViewModel.setEnabled(canCashout(bet))
        
        cashoutButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
        
    }
    
    private func canRebet(_ bet: MyBet) -> Bool {
        // Can rebet if bet open
        return !bet.isSettled
    }
    
    private func canCashout(_ bet: MyBet) -> Bool {
        // Can cashout if bet is active and has cashout value
        return bet.canCashOut && bet.isActive
    }

    // MARK: - Cashout ViewModels Setup

    private func setupCashoutViewModels(for bet: MyBet) {
        guard bet.canCashOut, let fullCashout = bet.partialCashoutReturn else {
            cashoutSliderViewModel = nil
            cashoutAmountViewModel = nil
            return
        }

        // Store values for calculations
        self.fullCashoutValue = fullCashout
        self.remainingStake = bet.partialCashoutStake ?? bet.stake

        // Slider bounds (stake amount, not cashout value)
        let minStake: Float = 0.1
        let maxStake = Float(remainingStake)
        let initialStake = maxStake * 0.8  // 80% per Web/Android

        // Create slider ViewModel
        let sliderVM = CashoutSliderViewModel(
            title: localized("mybets_choose_cashout_amount"),
            minimumValue: minStake,
            maximumValue: maxStake,
            currentValue: initialStake,
            currency: bet.currency,
            isEnabled: true
        )

        // Wire cashout button tap
        sliderVM.onCashoutRequested = { [weak self] stakeValue in
            self?.handleCashoutRequest(forStakeValue: stakeValue)
        }

        self._cashoutSliderVM = sliderVM
        self.cashoutSliderViewModel = sliderVM

        // Create amount ViewModel with initial calculated value
        let initialCashoutValue = calculatePartialCashout(forStakeValue: initialStake)
        let amountVM = CashoutAmountViewModel.create(
            title: localized("mybets_partial_cashout"),
            amount: initialCashoutValue,
            currency: bet.currency
        )

        self._cashoutAmountVM = amountVM
        self.cashoutAmountViewModel = amountVM

        // Subscribe to slider changes
        subscribeToSliderChanges()
    }

    // MARK: - Cashout Calculations

    /// Formula: partialCashoutValue = (fullCashoutValue * stakeValue) / totalRemainingStake
    private func calculatePartialCashout(forStakeValue stakeValue: Float) -> Double {
        guard remainingStake > 0 else { return 0 }
        return (fullCashoutValue * Double(stakeValue)) / remainingStake
    }

    private func isFullCashout(forStakeValue stakeValue: Float) -> Bool {
        return Double(stakeValue) >= (remainingStake - 0.01)
    }

    private func subscribeToSliderChanges() {
        guard let sliderVM = _cashoutSliderVM else { return }

        sliderVM.dataPublisher
            .dropFirst()  // Skip initial (already set)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sliderData in
                self?.updateCashoutAmount(forStakeValue: sliderData.currentValue)
            }
            .store(in: &cancellables)
    }

    // MARK: - SSE Subscription

    private func subscribeToCashoutUpdates() {
        sseSubscription = servicesProvider.subscribeToCashoutValue(betId: myBet.identifier)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Cashout SSE error for bet \(self?.myBet.identifier ?? ""): \(error)")
                    }
                },
                receiveValue: { [weak self] content in
                    switch content {
                    case .connected:
                        print("✅ Cashout SSE connected for bet \(self?.myBet.identifier ?? "")")
                    case .contentUpdate(let cashoutValue):
                        self?.handleCashoutUpdate(cashoutValue)
                    case .disconnected:
                        print("🔌 Cashout SSE disconnected for bet \(self?.myBet.identifier ?? "")")
                    }
                }
            )
    }

    private func handleCashoutUpdate(_ cashoutValue: CashoutValue) {
        guard let newCashoutAmount = cashoutValue.cashoutValue else { return }

        // Update stored full cashout value
        self.fullCashoutValue = newCashoutAmount

        // Get current slider position to recalculate partial cashout
        if let sliderVM = _cashoutSliderVM {
            let currentStake = sliderVM.dataPublisher
                .first()
                .map { $0.currentValue }

            // Recalculate and update displayed amount based on current slider position
            currentStake
                .sink { [weak self] stakeValue in
                    self?.updateCashoutAmount(forStakeValue: stakeValue)
                }
                .store(in: &cancellables)
        }

        print("💰 Cashout value updated for bet \(myBet.identifier): \(newCashoutAmount)")
    }

    private func updateCashoutAmount(forStakeValue stakeValue: Float) {
        guard let amountVM = _cashoutAmountVM else { return }

        let cashoutValue = calculatePartialCashout(forStakeValue: stakeValue)
        let formattedAmount = Self.formatCurrency(cashoutValue, currency: myBet.currency)

        // Update title based on full vs partial
        let title = isFullCashout(forStakeValue: stakeValue)
            ? localized("mybets_full_cashout")
            : localized("mybets_partial_cashout")

        amountVM.updateTitle(title)
        amountVM.updateAmount(formattedAmount)
    }

    // MARK: - Cashout Execution State Machine

    private func handleCashoutRequest(forStakeValue stakeValue: Float) {
        guard case .idle = cashoutStateSubject.value else { return }

        let isFullCashoutRequest = isFullCashout(forStakeValue: stakeValue)
        let cashoutValue = calculatePartialCashout(forStakeValue: stakeValue)

        let request = CashoutRequest(
            betId: myBet.identifier,
            cashoutValue: cashoutValue,
            cashoutType: isFullCashoutRequest ? .full : .partial,
            partialCashoutStake: isFullCashoutRequest ? nil : Double(stakeValue),
            cashoutChangeAcceptanceType: "ACCEPT_ANY"
        )

        lastCashoutRequest = request
        executeCashoutRequest(request)
    }

    private func executeCashoutRequest(_ request: CashoutRequest) {
        cashoutStateSubject.send(.loading)
        _cashoutSliderVM?.setEnabled(false)

        servicesProvider.executeCashout(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleCashoutFailure(error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleCashoutSuccess(response)
                }
            )
            .store(in: &cancellables)
    }

    private func handleCashoutSuccess(_ response: CashoutResponse) {
        if response.isFullCashout {
            cashoutStateSubject.send(.fullCashoutSuccess(payout: response.cashoutPayout))
            onCashoutCompleted?(myBet.identifier, true, nil)
        } else {
            let newRemainingStake = remainingStake - (response.partialCashoutStake ?? 0)
            cashoutStateSubject.send(.partialCashoutSuccess(payout: response.cashoutPayout, remainingStake: newRemainingStake))
            onCashoutCompleted?(myBet.identifier, false, nil)
            _cashoutSliderVM?.setEnabled(true)

            // Reset to idle after brief delay for partial cashout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.cashoutStateSubject.send(.idle)
            }
        }
    }

    private func handleCashoutFailure(_ error: ServiceProviderError) {
        let cashoutError = CashoutExecutionError.fromServiceError(error)
        cashoutStateSubject.send(.failed(cashoutError))
        _cashoutSliderVM?.setEnabled(true)

        onCashoutError?(cashoutError.message) { [weak self] in
            self?.retryCashout()
        }
    }

    func retryCashout() {
        guard let request = lastCashoutRequest else {
            cashoutStateSubject.send(.idle)
            return
        }
        executeCashoutRequest(request)
    }

    func cancelCashout() {
        cashoutStateSubject.send(.idle)
        _cashoutSliderVM?.setEnabled(true)
        lastCashoutRequest = nil
    }

    // MARK: - Action Implementations

    private func executeRebet() {
        guard myBet.isSettled else {
            print("⚠️ TicketBetInfoViewModel: Bet is not settled, cannot rebet")
            return
        }
        
        // Convert bet selections to bet ticket selections for rebetting
        // This would require mapping MyBetSelection back to BetTicketSelection
        // For now, we'll just notify the parent
        onRebetTap?(myBet)
    }
    
    // MARK: - Data Creation (Following Established Patterns)
    
    private static func createTicketBetInfoData(from myBet: MyBet, overrideCashoutValue: Double? = nil) -> TicketBetInfoData {
        let ticketSelections = myBet.selections.map { createTicketSelectionData(from: $0) }

        // Use override value (from SSE) if provided, otherwise use API value
        let cashoutAmount = overrideCashoutValue ?? myBet.partialCashoutReturn

        // Format cashout values only if bet can be cashed out
        let partialCashoutValue: String? = myBet.canCashOut ? cashoutAmount.map { formatCurrency($0, currency: myBet.currency) } : nil
        let cashoutTotalAmount: String? = myBet.canCashOut ? cashoutAmount.map { formatCurrency($0, currency: myBet.currency) } : nil

        return TicketBetInfoData(
            id: myBet.identifier,
            title: formatBetTitle(myBet),
            betDetails: formatBetDetails(myBet),
            tickets: ticketSelections,
            totalOdds: formatOdds(myBet.totalOdd),
            betAmount: formatCurrency(myBet.stake, currency: myBet.currency),
            possibleWinnings: formatPossibleWinnings(myBet),
            partialCashoutValue: partialCashoutValue,
            cashoutTotalAmount: cashoutTotalAmount,
            betStatus: createBetStatus(from: myBet),
            isSettled: myBet.isSettled
        )
    }
    
    private static func createTicketSelectionData(from selection: MyBetSelection) -> TicketSelectionData {
        return TicketSelectionData(
            id: selection.identifier,
            competitionName: selection.tournamentName,
            homeTeamName: selection.homeTeamName ?? "",
            awayTeamName: selection.awayTeamName ?? "",
            homeScore: parseScore(selection.homeResult),
            awayScore: parseScore(selection.awayResult),
            matchDate: formatEventDate(selection.eventDate),
            isLive: isLiveMatch(selection),
            sportIcon: extractSportIcon(from: selection),
            countryFlag: extractCountryFlag(from: selection),
            marketName: selection.marketName,
            selectionName: selection.outcomeName,
            oddsValue: formatOdds(selection.odd)
        )
    }
    
    // MARK: - Formatting Helper Methods
    
    private static func formatBetTitle(_ myBet: MyBet) -> String {
        return myBet.typeDescription
    }
    
    private static func formatBetDetails(_ myBet: MyBet) -> String {
        return "Ticket: \(myBet.displayTicketReference)"
    }
    
    private static func formatOdds(_ oddFormat: OddFormat) -> String {
        return OddConverter.stringForValue(oddFormat.decimalValue, format: .europe)
    }
    
    private static func formatOdds(_ odds: Double) -> String {
        return OddConverter.stringForValue(odds, format: .europe)
    }
    
    private static func formatCurrency(_ amount: Double, currency: String) -> String {
        // Format amount with currency code using comma thousand separator
        return CurrencyHelper.formatAmountWithCurrency(amount, currency: currency)
    }
    
    private static func formatPossibleWinnings(_ myBet: MyBet) -> String {
        guard let potentialReturn = myBet.potentialReturn else {
            return formatCurrency(0.0, currency: myBet.currency)
        }
        return formatCurrency(potentialReturn, currency: myBet.currency)
    }
    
    private static func createBetStatus(from myBet: MyBet) -> BetTicketStatusData? {
        // Only provide status data if bet is settled
        guard myBet.isSettled else { return nil }
        
        let ticketStatus: BetTicketStatus
        switch myBet.result {
        case .won:
            ticketStatus = .won
        case .lost:
            ticketStatus = .lost
        case .drawn:
            ticketStatus = .draw
        default:
            // For other states like void, pending, etc., don't show status
            return nil
        }
        
        return BetTicketStatusData(status: ticketStatus)
    }
    
    // MARK: - Selection Helper Methods
    
    private static func parseScore(_ scoreString: String?) -> Int {
        guard let scoreString = scoreString else { return 0 }
        return Int(scoreString) ?? 0
    }
    
    private static func formatEventDate(_ eventDate: Date?) -> String {
        guard let eventDate = eventDate else {
            return "TBD"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: eventDate)
            return localized("date_today_time").replacingOccurrences(of: "{time}", with: timeString)
        } else if calendar.isDateInTomorrow(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: eventDate)
            return localized("date_tomorrow_time").replacingOccurrences(of: "{time}", with: timeString)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM HH:mm"
            return formatter.string(from: eventDate)
        }
    }
    
    private static func isLiveMatch(_ selection: MyBetSelection) -> Bool {
        return selection.state == .opened && 
               selection.homeResult != nil && 
               selection.awayResult != nil
    }
    
    // MARK: - Image Resolution (Using Existing Systems)
    
    private static func extractSportIcon(from selection: MyBetSelection) -> String? {
        // Use the sport's alphaId or numeric ID, following existing pattern
        guard let sport = selection.sport else { return nil }
        return sport.alphaId ?? sport.numericId ?? "1"
    }
    
    private static func extractCountryFlag(from selection: MyBetSelection) -> String? {
        // Use the country's ISO code, following existing pattern
        guard let country = selection.country else { return nil }
        return country.iso2Code
    }
    
}

// MARK: - Factory Methods

extension TicketBetInfoViewModel {
    
    static func create(from myBet: MyBet, servicesProvider: ServicesProvider.Client) -> TicketBetInfoViewModel {
        return TicketBetInfoViewModel(myBet: myBet, servicesProvider: servicesProvider)
    }
}
