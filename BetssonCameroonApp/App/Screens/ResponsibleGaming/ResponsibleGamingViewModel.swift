//
//  ResponsibleGamingViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on November 6, 2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class ResponsibleGamingViewModel {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - ExpandableSection ViewModels
    var informationSectionViewModel: ExpandableSectionViewModelProtocol
    var informationTextSectionViewModels: [TextSectionViewModelProtocol]
    var depositLimitSectionViewModel: ExpandableSectionViewModelProtocol
    var wageringLimitSectionViewModel: ExpandableSectionViewModelProtocol
    var timeOutSectionViewModel: ExpandableSectionViewModelProtocol
    var selfExclusionSectionViewModel: ExpandableSectionViewModelProtocol
    
    let configuration: ResponsibleGamingConfiguration
    
    let depositLimitOptionsViewModel: SelectOptionsViewModelProtocol
    let depositAmountTextFieldViewModel: BorderedTextFieldViewModelProtocol
    var depositLimitActionButtonViewModel: ButtonViewModelProtocol
    private var depositOptionsViewModel: ResponsibleGamingOptionsViewModel? { depositLimitOptionsViewModel as? ResponsibleGamingOptionsViewModel }
    private(set) var depositLimitCurrentValue: String
    
    let wageringLimitOptionsViewModel: SelectOptionsViewModelProtocol
    let wageringAmountTextFieldViewModel: BorderedTextFieldViewModelProtocol
    var wageringLimitActionButtonViewModel: ButtonViewModelProtocol
    private var wageringOptionsViewModel: ResponsibleGamingOptionsViewModel? { wageringLimitOptionsViewModel as? ResponsibleGamingOptionsViewModel }
    private(set) var wageringLimitCurrentValue: String
    
    let timeOutOptionsViewModel: SelectOptionsViewModelProtocol
    var timeOutActionButtonViewModel: ButtonViewModelProtocol
    private var timeOutOptionsInternal: ResponsibleGamingOptionsViewModel? { timeOutOptionsViewModel as? ResponsibleGamingOptionsViewModel }
    
    let selfExclusionOptionsViewModel: SelectOptionsViewModelProtocol
    var selfExclusionActionButtonViewModel: ButtonViewModelProtocol
    private var selfExclusionOptionsInternal: ResponsibleGamingOptionsViewModel? { selfExclusionOptionsViewModel as? ResponsibleGamingOptionsViewModel }
    
    // MARK: - Update Callbacks
    var onDepositLimitUpdated: ((String) -> Void)?
    var onWageringLimitUpdated: ((String) -> Void)?
    var onLimitSuccess: ((String) -> Void)?
    var onLimitError: ((String, String) -> Void)?
    var onTimeoutSuccess: ((String) -> Void)?
    var onTimeoutError: ((String) -> Void)?
    var onSelfExclusionSuccess: ((String) -> Void)?
    var onSelfExclusionError: ((String) -> Void)?
    var onDepositLimitCardsChanged: (([UserLimitCardViewModelProtocol]) -> Void)?
    var onWageringLimitCardsChanged: (([UserLimitCardViewModelProtocol]) -> Void)?
    
    private var fetchedLimits: [UserLimit] = []
    private(set) var depositLimitCardViewModels: [UserLimitCardViewModelProtocol] = []
    private(set) var wageringLimitCardViewModels: [UserLimitCardViewModelProtocol] = []
    
    // MARK: - Navigation Callbacks
    var onNavigateBack: (() -> Void) = { }
    
    let servicesProvider: ServicesProvider.Client
    private let userCurrency: String
    private var depositAmountValue: String = ""
    private var wageringAmountValue: String = ""
    private lazy var valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    // MARK: - Initialization
    init(
        servicesProvider: ServicesProvider.Client,
        configuration: ResponsibleGamingConfiguration = .defaultConfiguration
    ) {
        self.servicesProvider = servicesProvider
        self.configuration = configuration
        self.userCurrency = Env.userSessionStore.userProfilePublisher.value?.currency ?? ""
        
        informationSectionViewModel = MockExpandableSectionViewModel(
            title: localized("rg_information_title"),
            isExpanded: false
        )
        depositLimitSectionViewModel = MockExpandableSectionViewModel(
            title: localized("rg_deposit_limit_title"),
            isExpanded: false
        )
        wageringLimitSectionViewModel = MockExpandableSectionViewModel(
            title: localized("rg_wagering_limit_title"),
            isExpanded: false
        )
        timeOutSectionViewModel = MockExpandableSectionViewModel(
            title: localized("rg_time_out_title"),
            isExpanded: false
        )
        selfExclusionSectionViewModel = MockExpandableSectionViewModel(
            title: localized("rg_self_exclusion_title"),
            isExpanded: false
        )
        
        depositLimitCurrentValue = ""
        wageringLimitCurrentValue = ""
        
        depositLimitOptionsViewModel = ResponsibleGamingOptionsViewModel(
            title: localized("choose_time_period"),
            periods: configuration.depositLimits.periods,
            selectedPeriodValue: configuration.depositLimits.periods.defaultValue
        )
        
        depositAmountTextFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(
            id: "amount",
            placeholder: localized("enter_amount"),
            prefix: userCurrency,
            isSecure: false,
            isRequired: true,
            visualState: .idle,
            keyboardType: .numberPad,
            textContentType: .none
        ))
        
        depositLimitActionButtonViewModel = MockButtonViewModel(buttonData: ButtonData(
            id: "deposit_limit_action",
            title: localized("set_limit"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            isEnabled: false
        ))
        
        wageringLimitOptionsViewModel = ResponsibleGamingOptionsViewModel(
            title: localized("choose_time_period"),
            periods: configuration.depositLimits.periods,
            selectedPeriodValue: configuration.depositLimits.periods.defaultValue
        )
        
        wageringAmountTextFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(
            id: "wagering_amount",
            placeholder: localized("enter_amount"),
            prefix: userCurrency,
            isSecure: false,
            isRequired: true,
            visualState: .idle,
            keyboardType: .numberPad,
            textContentType: .none
        ))
        
        wageringLimitActionButtonViewModel = MockButtonViewModel(buttonData: ButtonData(
            id: "wagering_limit_action",
            title: localized("set_wagering_limit"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            isEnabled: false
        ))
        
        timeOutOptionsViewModel = ResponsibleGamingOptionsViewModel(
            title: localized("choose_time_period"),
            periods: configuration.timeout.periods,
            selectedPeriodValue: configuration.timeout.periods.defaultValue
        )
        
        timeOutActionButtonViewModel = MockButtonViewModel(buttonData: ButtonData(
            id: "timeout_action",
            title: localized("set_time_out"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            isEnabled: true
        ))
        
        selfExclusionOptionsViewModel = ResponsibleGamingOptionsViewModel(
            title: nil,
            periods: configuration.selfExclusion.periods,
            selectedPeriodValue: configuration.selfExclusion.periods.defaultValue
        )
        
        selfExclusionActionButtonViewModel = MockButtonViewModel(buttonData: ButtonData(
            id: "self_exclusion_action",
            title: localized("set_self_exclusion"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            isEnabled: true
        ))
        
        informationTextSectionViewModels = (1...15).map { index in
            let isHighlightPrimary = (12...15).contains(index)
            let titleColor = isHighlightPrimary ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary
            let descriptionColor = isHighlightPrimary ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textSecondary
            let content = TextSectionContent(
                title: localized("rg_information_title_\(index)"),
                description: localized("rg_information_description_\(index)"),
                titleTextColor: titleColor,
                descriptionTextColor: descriptionColor,
                titleFont: StyleProvider.fontWith(type: .semibold, size: 14),
                descriptionFont: StyleProvider.fontWith(type: .regular, size: 13),
                spacing: 8
            )
            return MockTextSectionViewModel(content: content)
        }
        
        refreshLimitSummaries()
        
        setupButtonCallbacks()
        setupBindings()
        fetchResponsibleGamingLimits()
    }
    
    // MARK: - Actions
    func setDepositLimit() {
        guard !isLoading.value else { return }
        guard let period = depositOptionsViewModel?.selectedPeriodApiValue() ?? depositOptionsViewModel?.selectedPeriod()?.value,
              !period.isEmpty else { return }
        guard let amountValue = Double(depositAmountValue), amountValue > 0 else { return }
        
        let existingLimit = existingLimit(forTypes: ["Deposit"], matchingPeriod: period)
        let currency = existingLimit?.currency ?? (userCurrency.isEmpty ? "XAF" : userCurrency)
        
        isLoading.send(true)
        
        let publisher: AnyPublisher<UserLimit, ServiceProviderError>
        if let existingLimit = existingLimit {
            let request = UpdateUserLimitRequest(amount: amountValue, skipCoolOff: true)
            publisher = servicesProvider.updateUserLimit(limitId: existingLimit.id, request: request)
        } else {
            publisher = servicesProvider.setUserLimit(
                period: period,
                type: "Deposit",
                amount: amountValue,
                currency: currency,
                products: ["All"],
                walletTypes: ["All"]
            )
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to set deposit limit: \(error)")
                    self?.onLimitError?("Deposit", error.localizedDescription)
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] limit in
                guard let self = self else { return }
                self.depositOptionsViewModel?.selectPeriod(matching: limit.period)
                self.updateFetchedLimit(limit)
                self.onLimitSuccess?("Deposit")
                print("[ResponsibleGaming] Deposit limits updated. Summary: \(self.depositLimitCurrentValue)")
            }
            .store(in: &cancellables)
    }
    
    func setWageringLimit() {
        guard !isLoading.value else { return }
        guard let period = wageringOptionsViewModel?.selectedPeriodApiValue() ?? wageringOptionsViewModel?.selectedPeriod()?.value,
              !period.isEmpty else { return }
        guard let amountValue = Double(wageringAmountValue), amountValue > 0 else { return }
        
        let existingLimit = existingLimit(forTypes: ["Wagering", "Loss"], matchingPeriod: period)
        let currency = existingLimit?.currency ?? (userCurrency.isEmpty ? "XAF" : userCurrency)
        
        isLoading.send(true)
        
        let publisher: AnyPublisher<UserLimit, ServiceProviderError>
        if let existingLimit = existingLimit {
            let request = UpdateUserLimitRequest(amount: amountValue, skipCoolOff: true)
            publisher = servicesProvider.updateUserLimit(limitId: existingLimit.id, request: request)
        } else {
            publisher = servicesProvider.setUserLimit(
                period: period,
                type: "Wagering",
                amount: amountValue,
                currency: currency,
                products: ["All"],
                walletTypes: ["All"]
            )
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to set wagering limit: \(error)")
                    self?.onLimitError?("Wagering", error.localizedDescription)
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] limit in
                guard let self = self else { return }
                self.wageringOptionsViewModel?.selectPeriod(matching: limit.period)
                self.updateFetchedLimit(limit)
                self.onLimitSuccess?("Wagering")
                print("[ResponsibleGaming] Wagering limits updated. Summary: \(self.wageringLimitCurrentValue)")
            }
            .store(in: &cancellables)
    }
    
    func setTimeOut() {
        guard !isLoading.value else { return }
        guard let periodValue = timeOutOptionsInternal?.selectedPeriodApiValue() ?? timeOutOptionsInternal?.selectedPeriod()?.value,
              !periodValue.isEmpty else { return }
        let selectedPeriodLabel = timeOutOptionsInternal?.selectedPeriod()?.label ?? periodValue
        isLoading.send(true)
        let request = UserTimeoutRequest(
            coolOff: UserTimeoutRequest.CoolOffPayload(
                period: periodValue,
                coolOffReason: "restrict-playing",
                coolOffDescription: "I want to restrict my playing",
                unsatisfiedReason: "customer-service",
                unsatisfiedDescription: "Customer service",
                sendNotificationEmail: true
            )
        )
        servicesProvider.setTimeOut(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to set timeout: \(error)")
                    self?.onTimeoutError?(error.localizedDescription)
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                self.onTimeoutSuccess?(selectedPeriodLabel)
                print("[ResponsibleGaming] Timeout set with period: \(periodValue)")
            }
            .store(in: &cancellables)
    }
    
    func setSelfExclusion() {
        guard !isLoading.value else { return }
        guard let periodValue = selfExclusionOptionsInternal?.selectedPeriodApiValue() ?? selfExclusionOptionsInternal?.selectedPeriod()?.value,
              !periodValue.isEmpty else { return }
        let selectedPeriodLabel = selfExclusionOptionsInternal?.selectedPeriod()?.label ?? periodValue
        isLoading.send(true)

        var expiryDate: String?
        if let period = selfExclusionOptionsInternal?.selectedPeriod(), period.isCustomDate == true,
           let periodType = period.customDatePeriodType,
           let periodValueAmount = period.customDatePeriodValue {
            expiryDate = calculateExpiryDate(periodType: periodType, value: periodValueAmount)
        }
        
        let request = SelfExclusionRequest(
            selfExclusion: SelfExclusionRequest.SelfExclusionPayload(
                period: periodValue,
                sendNotificationEmail: true,
                selfExclusionReason: "UserRequest",
                expiryDate: expiryDate
            )
        )

        servicesProvider.setSelfExclusion(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to set self exclusion: \(error)")
                    self?.onSelfExclusionError?(error.localizedDescription)
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                self.onSelfExclusionSuccess?(selectedPeriodLabel)
                print("[ResponsibleGaming] Self exclusion set with period: \(periodValue)")
            }
            .store(in: &cancellables)
    }

    func calculateExpiryDate(periodType: String, value: Int) -> String? {
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = DateComponents()
        switch periodType.lowercased() {
        case "months":
            dateComponents.month = value
        case "days":
            dateComponents.day = value
        case "years":
            dateComponents.year = value
        default:
            return nil
        }
        guard let expirationDate = calendar.date(byAdding: dateComponents, to: now) else {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: expirationDate)
    }
    
    func navigateBack() {
        onNavigateBack()
    }
}

extension ResponsibleGamingViewModel {
    func setupBindings() {
        depositAmountTextFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.depositAmountValue = trimmed
                self?.depositLimitActionButtonViewModel.setEnabled(!trimmed.isEmpty)
            }
            .store(in: &cancellables)
        
        wageringAmountTextFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.wageringAmountValue = trimmed
                self?.wageringLimitActionButtonViewModel.setEnabled(!trimmed.isEmpty)
            }
            .store(in: &cancellables)
    }
    
    func setupButtonCallbacks() {
        depositLimitActionButtonViewModel.onButtonTapped = { [weak self] in
            self?.setDepositLimit()
        }
        wageringLimitActionButtonViewModel.onButtonTapped = { [weak self] in
            self?.setWageringLimit()
        }
        timeOutActionButtonViewModel.onButtonTapped = { [weak self] in
            self?.setTimeOut()
        }
        selfExclusionActionButtonViewModel.onButtonTapped = { [weak self] in
            self?.setSelfExclusion()
        }
    }
    
    func fetchResponsibleGamingLimits() {
        isLoading.send(true)
        servicesProvider.getUserLimits(periodTypes: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to fetch limits: \(error)")
                }
                self?.isLoading.send(false)
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.fetchedLimits = response.limits
                self.applyLimits(response.limits)
            }
            .store(in: &cancellables)
    }
    
    func applyLimits(_ limits: [UserLimit]) {
        if let depositLimit = limits.first(where: { $0.type.caseInsensitiveCompare("Deposit") == .orderedSame }) {
            depositOptionsViewModel?.selectPeriod(matching: depositLimit.period)
        }
        if let wageringLimit = limits.first(where: { $0.type.caseInsensitiveCompare("Wagering") == .orderedSame || $0.type.caseInsensitiveCompare("Loss") == .orderedSame }) {
            wageringOptionsViewModel?.selectPeriod(matching: wageringLimit.period)
        }
        refreshLimitSummaries()
    }

    private func existingLimit(forTypes types: [String], matchingPeriod period: String? = nil) -> UserLimit? {
        return fetchedLimits.first { limit in
            let matchesType = types.contains(where: { limit.type.caseInsensitiveCompare($0) == .orderedSame })
            guard matchesType else { return false }
            if let period = period {
                return limit.period.caseInsensitiveCompare(period) == .orderedSame
            }
            return true
        }
    }

    private func updateFetchedLimit(_ limit: UserLimit) {
        if let index = fetchedLimits.firstIndex(where: { $0.id == limit.id }) {
            fetchedLimits[index] = limit
        } else {
            fetchedLimits.append(limit)
        }
        refreshLimitSummaries()
    }

    private func refreshLimitSummaries() {
        let depositLimits = fetchedLimits.filter { $0.type.caseInsensitiveCompare("Deposit") == .orderedSame }
        depositLimitCardViewModels = depositLimits.map { makeCardViewModel(from: $0) }
        onDepositLimitCardsChanged?(depositLimitCardViewModels)
        let depositSummary = limitSummary(forCount: depositLimitCardViewModels.count)
        depositLimitCurrentValue = depositSummary
        onDepositLimitUpdated?(depositSummary)

        let wageringLimits = fetchedLimits.filter { $0.type.caseInsensitiveCompare("Wagering") == .orderedSame || $0.type.caseInsensitiveCompare("Loss") == .orderedSame }
        wageringLimitCardViewModels = wageringLimits.map { makeCardViewModel(from: $0) }
        onWageringLimitCardsChanged?(wageringLimitCardViewModels)
        let wageringSummary = limitSummary(forCount: wageringLimitCardViewModels.count)
        wageringLimitCurrentValue = wageringSummary
        onWageringLimitUpdated?(wageringSummary)
    }

    private func limitSummary(forCount count: Int) -> String {
        return "\(localized("current_limits")): \(count) \(localized("active"))"
    }

    private func makeCardViewModel(from limit: UserLimit) -> UserLimitCardViewModelProtocol {
        let typeDisplay = displayText(for: limit.period)
        let valueDisplay = formattedValue(for: limit)
        let actionTitle = localized("remove")
        return ResponsibleGamingUserLimitCardViewModel(
            limitId: limit.id,
            typeText: typeDisplay,
            valueText: valueDisplay,
            actionTitle: actionTitle
        )
    }

    private func displayText(for period: String) -> String {
        let key = period.lowercased()
        let localizedValue = localized(key)
        return localizedValue == key ? period : localizedValue
    }

    private func formattedValue(for limit: UserLimit) -> String {
        let amountString = valueFormatter.string(from: NSNumber(value: limit.amount)) ?? String(limit.amount)
        if limit.currency.isEmpty {
            return amountString
        }
        return "\(amountString) \(limit.currency)"
    }

    func removeLimit(withId limitId: String) {
        guard !isLoading.value else { return }
        fetchedLimits.removeAll { $0.id == limitId }
        refreshLimitSummaries()
    }
}

private struct ResponsibleGamingOptionRowViewModel: SimpleOptionRowViewModelProtocol {
    let period: ResponsibleGamingPeriod
    let option: SortOption
    
    init(period: ResponsibleGamingPeriod) {
        self.period = period
        self.option = SortOption(
            id: period.value,
            icon: nil,
            title: localized(period.label),
            count: -1,
            iconTintChange: false
        )
    }
}

private extension ResponsibleGamingOptionRowViewModel {
    var lowercasedValue: String { option.id.lowercased() }
}

private final class ResponsibleGamingOptionsViewModel: SelectOptionsViewModelProtocol {
    let title: String?
    let options: [SimpleOptionRowViewModelProtocol]
    let selectedOptionId: CurrentValueSubject<String?, Never>
    private let periods: [ResponsibleGamingPeriod]
    
    init(title: String?, periods: [ResponsibleGamingPeriod], selectedPeriodValue: String?) {
        self.title = title
        self.periods = periods
        self.options = periods.map { ResponsibleGamingOptionRowViewModel(period: $0) }
        let defaultValue = selectedPeriodValue ?? periods.defaultValue
        self.selectedOptionId = CurrentValueSubject(defaultValue)
    }
    
    func selectOption(withId id: String) {
        selectedOptionId.send(id)
    }
    
    func selectedPeriod() -> ResponsibleGamingPeriod? {
        guard let selected = selectedOptionId.value else { return nil }
        return matchingPeriod(for: selected)
    }
    
    func selectedPeriodApiValue() -> String? {
        guard let period = selectedPeriod() else { return nil }
        if let apiValue = period.apiValue, !apiValue.isEmpty {
            return apiValue
        }
        return period.value
    }
    
    func selectPeriod(matching value: String) {
        let lowercased = value.lowercased()
        guard let period = periods.first(where: { $0.value.lowercased() == lowercased || $0.label.lowercased() == lowercased || periodMatchesApiValue($0, lowercased: lowercased) }) else { return }
        selectOption(withId: period.value)
    }
    
    private func matchingPeriod(for value: String) -> ResponsibleGamingPeriod? {
        let lowercased = value.lowercased()
        return periods.first { $0.value.lowercased() == lowercased || $0.label.lowercased() == lowercased || periodMatchesApiValue($0, lowercased: lowercased) }
    }
    
    private func periodMatchesApiValue(_ period: ResponsibleGamingPeriod, lowercased: String) -> Bool {
        guard let apiValue = period.apiValue?.lowercased() else { return false }
        return apiValue == lowercased
    }
}

private extension Array where Element == ResponsibleGamingPeriod {
    var defaultValue: String? {
        if let defaultItem = first(where: { $0.isDefault == true }) {
            return defaultItem.value
        }
        return first?.value
    }
}
