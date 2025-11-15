import Foundation
import UIKit
import Combine
import GomaUI
import ServicesProvider

/// Production implementation of BetInfoSubmissionViewModelProtocol
/// Calculates odds, potential winnings, win boost, and payout from real betting options data
final class BetInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetInfoSubmissionData, Never>
    private let currency: String
    private var hasValidTickets: Bool = true
    private var cancellables = Set<AnyCancellable>()

    // Current betting options data
    private var currentTotalOdds: Double = 0.0
    private var currentOddsBoostStairs: OddsBoostStairsState?

    // Child view models
    var oddsRowViewModel: BetSummaryRowViewModelProtocol
    var potentialWinningsRowViewModel: BetSummaryRowViewModelProtocol
    var winBonusRowViewModel: BetSummaryRowViewModelProtocol
    var payoutRowViewModel: BetSummaryRowViewModelProtocol
    var amount100ButtonViewModel: QuickAddButtonViewModelProtocol
    var amount250ButtonViewModel: QuickAddButtonViewModelProtocol
    var amount500ButtonViewModel: QuickAddButtonViewModelProtocol
    var amountTextFieldViewModel: BorderedTextFieldViewModelProtocol
    var placeBetButtonViewModel: ButtonViewModelProtocol

    // Callback closures
    var onPlaceBetTapped: (() -> Void)?
    var onAmountReturnKeyTapped: (() -> Void)?
    var amountChanged: (() -> Void)?

    var dataPublisher: AnyPublisher<BetInfoSubmissionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    var currentData: BetInfoSubmissionData {
        dataSubject.value
    }

    // MARK: - Initialization
    init(
        currency: String,
        bettingOptionsPublisher: AnyPublisher<LoadableContent<UnifiedBettingOptions>, Never>,
        oddsBoostStairsPublisher: AnyPublisher<OddsBoostStairsState?, Never>
    ) {
        self.currency = currency

        // Initialize with default data
        let initialData = BetInfoSubmissionData(
            odds: "0.00",
            potentialWinnings: "\(currency) 0",
            winBonus: "\(currency) 0",
            payout: "\(currency) 0",
            amount: "",
            placeBetAmount: LocalizationProvider.string("place_bet_with_amount")
                .replacingOccurrences(of: "{currency}", with: currency)
                .replacingOccurrences(of: "{amount}", with: "0"),
            isEnabled: true,
            currency: currency
        )
        self.dataSubject = CurrentValueSubject(initialData)

        // Initialize child view models with production implementations
        self.oddsRowViewModel = BetSummaryRowViewModel.odds()
        self.potentialWinningsRowViewModel = BetSummaryRowViewModel.potentialWinnings()
        self.winBonusRowViewModel = BetSummaryRowViewModel.winBonus()
        self.payoutRowViewModel = BetSummaryRowViewModel.payout()
        self.amount100ButtonViewModel = QuickAddButtonViewModel.amount100()
        self.amount250ButtonViewModel = QuickAddButtonViewModel.amount250()
        self.amount500ButtonViewModel = QuickAddButtonViewModel.amount500()
        self.amountTextFieldViewModel = AmountBorderedTextFieldViewModel.amountInput()
        self.placeBetButtonViewModel = PlaceBetButtonViewModel.placeBet(currency: currency)

        // Setup callbacks
        setupQuickAddButtonCallbacks()
        setupReturnKeyCallback()
        updateChildViewModels()
        updatePlaceBetButtonState()

        // Subscribe to betting options for automatic updates
        setupBettingOptionsSubscription(bettingOptionsPublisher: bettingOptionsPublisher)

        // Subscribe to odds boost stairs for win bonus calculation
        setupOddsBoostStairsSubscription(oddsBoostStairsPublisher: oddsBoostStairsPublisher)
    }

    // MARK: - Reactive Subscriptions
    private func setupBettingOptionsSubscription(
        bettingOptionsPublisher: AnyPublisher<LoadableContent<UnifiedBettingOptions>, Never>
    ) {
        bettingOptionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadableOptions in
                guard let self = self else { return }

                // Extract betting options from LoadableContent
                if case .loaded(let options) = loadableOptions {
                    // Update total odds
                    self.currentTotalOdds = options.totalOdds ?? 0.0

                    // Note: Odds boost info comes from oddsBoostStairsPublisher, not here

                    // Recalculate all values
                    self.recalculateAllValues()
                }
            }
            .store(in: &cancellables)
    }

    private func setupOddsBoostStairsSubscription(
        oddsBoostStairsPublisher: AnyPublisher<OddsBoostStairsState?, Never>
    ) {
        oddsBoostStairsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] oddsBoostStairs in
                guard let self = self else { return }

                // Store current odds boost stairs
                self.currentOddsBoostStairs = oddsBoostStairs

                // Update win bonus label with percentage
                self.updateWinBonusLabel()

                // Recalculate all values (win boost depends on this)
                self.recalculateAllValues()
            }
            .store(in: &cancellables)
    }

    /// Updates the win bonus label to show current active boost percentage
    /// e.g., "WIN BOOST (10%)" or "WIN BOOST (NONE)"
    private func updateWinBonusLabel() {
        let percentage = currentOddsBoostStairs?.currentTier?.percentage ?? 0

        let title: String
        if percentage > 0 {
            let percentageInt = Int(percentage * 100)
            title = "WIN BOOST (\(percentageInt)%)"
        } else {
            let noneText = LocalizationProvider.string("none").uppercased()
            title = "WIN BOOST (\(noneText))"
        }

        winBonusRowViewModel.updateTitle(title)
    }

    // MARK: - Calculations (Web App Logic)

    /// Recalculates all values based on current stake, odds, and boost
    private func recalculateAllValues() {
        let stake = Double(currentData.amount) ?? 0.0

        // Step 1: Update ODDS (use CurrencyHelper for consistent 2-decimal formatting)
        let formattedOdds = CurrencyHelper.formatAmount(currentTotalOdds)
        updateOdds(formattedOdds)

        // Step 2: Calculate POTENTIAL WINNINGS = stake × totalOdds
        let potentialWinnings = stake * currentTotalOdds
        let formattedPotentialWinnings = CurrencyHelper.formatAmountWithCurrency(
            potentialWinnings,
            currency: currency
        )
        updatePotentialWinnings(formattedPotentialWinnings)

        // Step 3: Calculate WIN BOOST = min(potentialWinnings × percentage, capAmount)
        let winBoost = calculateWinBoost(potentialWinnings: potentialWinnings)
        let formattedWinBoost = CurrencyHelper.formatAmountWithCurrency(
            winBoost,
            currency: currency
        )
        updateWinBonus(formattedWinBoost)

        // Step 4: Calculate PAYOUT = potentialWinnings + winBoost
        let payout = potentialWinnings + winBoost
        let formattedPayout = CurrencyHelper.formatAmountWithCurrency(
            payout,
            currency: currency
        )
        updatePayout(formattedPayout)
    }

    /// Calculates win boost based on potential winnings and boost percentage/cap
    /// Formula from web app: min(potentialWinnings × percentage, capAmount[currency])
    private func calculateWinBoost(potentialWinnings: Double) -> Double {
        // Get current tier from odds boost stairs (not from betting options!)
        guard let currentTier = currentOddsBoostStairs?.currentTier else {
            return 0.0
        }

        let percentage = currentTier.percentage  // Already a Double (0.5 = 50%)
        let capAmount = currentTier.capAmount    // Already in user's currency

        // Calculate raw boost: potentialWinnings × percentage
        let rawBoost = potentialWinnings * percentage

        // Apply monetary cap: min(rawBoost, capAmount)
        let finalBoost = min(rawBoost, capAmount)

        return finalBoost
    }

    // MARK: - Protocol Methods

    func updateOdds(_ odds: String) {
        let newData = BetInfoSubmissionData(
            odds: odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        oddsRowViewModel.updateValue(odds)
    }

    func updatePotentialWinnings(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: amount,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        potentialWinningsRowViewModel.updateValue(amount)
    }

    func updateWinBonus(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: amount,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        winBonusRowViewModel.updateValue(amount)
    }

    func updatePayout(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: amount,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        payoutRowViewModel.updateValue(amount)
    }

    func updateAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        amountTextFieldViewModel.updateText(amount)
        updatePlaceBetButtonState()

        // Recalculate potential winnings, win boost, and payout when amount changes
        recalculateAllValues()
    }

    func updatePlaceBetAmount(_ amount: String) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: amount,
            isEnabled: currentData.isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)
        placeBetButtonViewModel.updateTitle(amount)
    }

    func setEnabled(_ isEnabled: Bool) {
        let newData = BetInfoSubmissionData(
            odds: currentData.odds,
            potentialWinnings: currentData.potentialWinnings,
            winBonus: currentData.winBonus,
            payout: currentData.payout,
            amount: currentData.amount,
            placeBetAmount: currentData.placeBetAmount,
            isEnabled: isEnabled,
            currency: currentData.currency
        )
        dataSubject.send(newData)

        // Update child view models
        oddsRowViewModel.setEnabled(isEnabled)
        potentialWinningsRowViewModel.setEnabled(isEnabled)
        winBonusRowViewModel.setEnabled(isEnabled)
        payoutRowViewModel.setEnabled(isEnabled)
        amount100ButtonViewModel.setEnabled(isEnabled)
        amount250ButtonViewModel.setEnabled(isEnabled)
        amount500ButtonViewModel.setEnabled(isEnabled)
        amountTextFieldViewModel.setEnabled(isEnabled)
        placeBetButtonViewModel.setEnabled(isEnabled)
    }

    func updateHasValidTickets(_ hasValidTickets: Bool) {
        self.hasValidTickets = hasValidTickets
        updatePlaceBetButtonState()
    }

    func onQuickAddTapped(_ amount: Int) {
        // Get the current amount and add the new amount
        let currentAmountString = currentData.amount
        let currentAmount = Double(currentAmountString) ?? 0.0
        let newTotalAmount = currentAmount + Double(amount)
        let newTotalAmountString = "\(Int(newTotalAmount))"

        updateAmount(newTotalAmountString)
        updatePlaceBetAmount(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: newTotalAmountString))

        // Update child view models
        amountTextFieldViewModel.updateText(newTotalAmountString)
        placeBetButtonViewModel.updateTitle(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: newTotalAmountString))
        placeBetButtonViewModel.setEnabled(true)
    }

    func onAmountChanged(_ amount: String) {
        updateAmount(amount)
        updatePlaceBetButtonState()
        amountChanged?()
        placeBetButtonViewModel.updateTitle(LocalizationProvider.string("place_bet_with_amount")
            .replacingOccurrences(of: "{currency}", with: currency)
            .replacingOccurrences(of: "{amount}", with: amount))
    }

    // MARK: - Private Methods

    private func setupQuickAddButtonCallbacks() {
        // Wire quick add button callbacks to our onQuickAddTapped method
        amount100ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(100)
        }

        amount250ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(250)
        }

        amount500ButtonViewModel.onButtonTapped = { [weak self] in
            self?.onQuickAddTapped(500)
        }
    }

    private func setupReturnKeyCallback() {
        // Wire the text field's return key callback to trigger the parent callback
        if let amountViewModel = amountTextFieldViewModel as? AmountBorderedTextFieldViewModel {
            amountViewModel.onReturnKeyTappedCallback = { [weak self] in
                self?.onAmountReturnKeyTapped?()
            }
        }
    }

    private func updateChildViewModels() {
        oddsRowViewModel.updateValue(currentData.odds)
        potentialWinningsRowViewModel.updateValue(currentData.potentialWinnings)
        winBonusRowViewModel.updateValue(currentData.winBonus)
        payoutRowViewModel.updateValue(currentData.payout)
        amountTextFieldViewModel.updateText(currentData.amount)
        placeBetButtonViewModel.updateTitle(currentData.placeBetAmount)
        placeBetButtonViewModel.setEnabled(currentData.isEnabled)
    }

    private func updatePlaceBetButtonState() {
        // Button is only enabled if we have an amount AND all tickets are valid
        let isEnabled = !currentData.amount.isEmpty && hasValidTickets
        placeBetButtonViewModel.setEnabled(isEnabled)
    }
}
