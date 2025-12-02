//
//  ResponsibleGamingViewModel.swift
//  BetssonCameroonApp
//
//  Created by André on 06/11/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

private enum LimitSuccessAction {
    case set
    case update
    case delete
}

private enum LimitCategory {
    case deposit
    case wagering
}

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
    var onLimitSuccess: ((ResponsibleGamingLimitSuccessInfo) -> Void)?
    var onLimitError: ((String, String) -> Void)?
    var onTimeoutSuccess: ((ResponsibleGamingLimitSuccessInfo) -> Void)?
    var onTimeoutError: ((String) -> Void)?
    var onSelfExclusionSuccess: ((ResponsibleGamingLimitSuccessInfo) -> Void)?
    var onSelfExclusionError: ((String) -> Void)?
    var onSelfExclusionConfirmationRequested: (() -> Void)?
    var onDepositLimitAmountUpdated: ((String) -> Void)?
    var onWageringLimitAmountUpdated: ((String) -> Void)?
    var onDepositLimitCardsChanged: (([UserLimitCardViewModelProtocol]) -> Void)?
    var onWageringLimitCardsChanged: (([UserLimitCardViewModelProtocol]) -> Void)?
    
    private var fetchedLimits: [UserLimit] = []
    private(set) var depositLimitCardViewModels: [UserLimitCardViewModelProtocol] = []
    private(set) var wageringLimitCardViewModels: [UserLimitCardViewModelProtocol] = []
    private(set) var depositSelectedLimitAmount: String = ""
    private(set) var wageringSelectedLimitAmount: String = ""
    
    var depositSelectedLimitAmountText: String { depositSelectedLimitAmount }
    var wageringSelectedLimitAmountText: String { wageringSelectedLimitAmount }
    
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
    
    private lazy var timeoutDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale.current
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
            title: localized("rg_information_header_title"),
            isExpanded: false
        )
        depositLimitSectionViewModel = MockExpandableSectionViewModel(
            title: localized("deposit_limit"),
            isExpanded: false
        )
        wageringLimitSectionViewModel = MockExpandableSectionViewModel(
            title: localized("wagering_limit"),
            isExpanded: false
        )
        timeOutSectionViewModel = MockExpandableSectionViewModel(
            title: localized("timeout"),
            isExpanded: false
        )
        selfExclusionSectionViewModel = MockExpandableSectionViewModel(
            title: localized("self_exclusion"),
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
            title: localized("deposit_limit_set"),
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
            title: localized("wagering_limit_set"),
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
            title: localized("apply"),
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.highlightSecondary,
            isEnabled: true
        ))
        
        selfExclusionOptionsViewModel = ResponsibleGamingOptionsViewModel(
            title: localized("choose_time_period"),
            periods: configuration.selfExclusion.periods,
            selectedPeriodValue: configuration.selfExclusion.periods.defaultValue
        )
        
        selfExclusionActionButtonViewModel = MockButtonViewModel(buttonData: ButtonData(
            id: "self_exclusion_action",
            title: localized("self_exclude_for_period"),
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
    
    // MARK: Bindings
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
        
        if let depositOptionsViewModel {
            depositOptionsViewModel.selectedOptionPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateDepositSelectedLimitAmount()
                }
                .store(in: &cancellables)
        }
        
        if let wageringOptionsViewModel {
            wageringOptionsViewModel.selectedOptionPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateWageringSelectedLimitAmount()
                }
                .store(in: &cancellables)
        }
        
        updateSelectedLimitAmounts()
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
            self?.onSelfExclusionConfirmationRequested?()
        }
    }
    
    func confirmSelfExclusion() {
        setSelfExclusion()
    }
    
    // MARK: - Endpoint Functions
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
    
    func setDepositLimit() {
        guard !isLoading.value else { return }
        
        guard let period = depositOptionsViewModel?.selectedPeriodApiValue() ?? depositOptionsViewModel?.selectedPeriod()?.value,
              !period.isEmpty else { return }
        
        guard let amountValue = Double(depositAmountValue), amountValue > 0 else { return }
        
        let existingLimit = existingLimit(forTypes: ["Deposit"], matchingPeriod: period)
        let limitAction: LimitSuccessAction = existingLimit == nil ? .set : .update
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
                    self?.onLimitError?(localized("deposit"), error.localizedDescription)
                    self?.isLoading.send(false)
                }
            } receiveValue: { [weak self] limit in
                guard let self = self else { return }
                self.depositOptionsViewModel?.selectPeriod(matching: limit.period)
                let successInfo = self.makeLimitSuccessInfo(limit: limit, action: limitAction)
                self.onLimitSuccess?(successInfo)
                self.fetchResponsibleGamingLimits()
            }
            .store(in: &cancellables)
    }
    
    func setWageringLimit() {
        guard !isLoading.value else { return }
        
        guard let period = wageringOptionsViewModel?.selectedPeriodApiValue() ?? wageringOptionsViewModel?.selectedPeriod()?.value,
              !period.isEmpty else { return }
        
        guard let amountValue = Double(wageringAmountValue), amountValue > 0 else { return }
        
        let existingLimit = existingLimit(forTypes: ["Wagering"], matchingPeriod: period)
        let limitAction: LimitSuccessAction = existingLimit == nil ? .set : .update
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
                    self?.onLimitError?(localized("wagering"), error.localizedDescription)
                    self?.isLoading.send(false)
                }
            } receiveValue: { [weak self] limit in
                guard let self = self else { return }
                self.wageringOptionsViewModel?.selectPeriod(matching: limit.period)
                let successInfo = self.makeLimitSuccessInfo(limit: limit, action: limitAction)
                self.onLimitSuccess?(successInfo)
                self.fetchResponsibleGamingLimits()
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
                let successInfo = self.makeTimeoutSuccessInfo(periodLabel: selectedPeriodLabel)
                self.onTimeoutSuccess?(successInfo)
                self.isLoading.send(false)
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
                let successInfo = self.makeSelfExclusionSuccessInfo(periodLabel: selectedPeriodLabel)
                self.onSelfExclusionSuccess?(successInfo)
                print("[ResponsibleGaming] Self exclusion set with period: \(periodValue)")
            }
            .store(in: &cancellables)
    }
    
    func removeLimit(withId limitId: String) {
        guard !isLoading.value else { return }
        
        let limitToRemove = fetchedLimits.first(where: { $0.id == limitId })
        
        isLoading.send(true)
        
        servicesProvider.deleteUserLimit(limitId: limitId, skipCoolOff: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("[ResponsibleGaming] Failed to delete limit: \(error)")
                    self?.onLimitError?("Delete", error.localizedDescription)
                    self?.isLoading.send(false)
                }
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                let successInfo = self.makeLimitRemovalSuccessInfo(limit: limitToRemove)
                self.onLimitSuccess?(successInfo)
                self.fetchResponsibleGamingLimits()
            }
            .store(in: &cancellables)
    }

    // MARK: Functions
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
        
        updateSelectedLimitAmounts()
    }

    private func limitSummary(forCount count: Int) -> String {
        return "\(localized("current_limits")): \(count) \(localized("active"))"
    }

    private func updateSelectedLimitAmounts() {
        updateDepositSelectedLimitAmount()
        updateWageringSelectedLimitAmount()
    }
    
    private func updateDepositSelectedLimitAmount() {
        let info = limitInfo(forTypes: ["Deposit"], optionsViewModel: depositOptionsViewModel)
        
        depositSelectedLimitAmount = info.amount
        onDepositLimitAmountUpdated?(info.amount)
        updateDepositActionButtonTitle(hasExistingLimit: info.hasLimit)
    }
    
    private func updateWageringSelectedLimitAmount() {
        let info = limitInfo(forTypes: ["Wagering", "Loss"], optionsViewModel: wageringOptionsViewModel)
        
        wageringSelectedLimitAmount = info.amount
        onWageringLimitAmountUpdated?(info.amount)
        updateWageringActionButtonTitle(hasExistingLimit: info.hasLimit)
    }
    
    private func limitInfo(forTypes types: [String], optionsViewModel: ResponsibleGamingOptionsViewModel?) -> (amount: String, hasLimit: Bool) {
        guard let optionsViewModel else { return ("", false) }
        
        let identifiers = optionsViewModel.selectedPeriodIdentifiers()
        
        guard let limit = fetchedLimits.first(where: { limit in
            types.contains(where: { limit.type.caseInsensitiveCompare($0) == .orderedSame }) &&
            identifiers.contains(where: { limit.period.caseInsensitiveCompare($0) == .orderedSame })
        }) else {
            return ("", false)
        }
        
        return (formattedValue(for: limit), true)
    }
    
    private func updateDepositActionButtonTitle(hasExistingLimit: Bool) {
        let titleKey = hasExistingLimit ? "update_deposit_limit" : "deposit_limit_set"
        
        depositLimitActionButtonViewModel.updateTitle(localized(titleKey))
    }
    
    private func updateWageringActionButtonTitle(hasExistingLimit: Bool) {
        let titleKey = hasExistingLimit ? "update_wagering_limit" : "wagering_limit_set"
        
        wageringLimitActionButtonViewModel.updateTitle(localized(titleKey))
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
    
    // MARK: Success Presentation
    private func makeLimitSuccessInfo(limit: UserLimit, action: LimitSuccessAction) -> ResponsibleGamingLimitSuccessInfo {
        let category = limitCategory(for: limit.type)
        let message = successMessage(for: category, action: action)
        let periodTitle = localizedValue(for: "period", fallback: "Period")
        let periodValue = displayText(for: limit.period)
        let amountTitle = localizedValue(for: "amount", fallback: "Amount")
        let amountValue = formattedValue(for: limit)
        let statusTitle = localizedValue(for: "status", fallback: "Status")
        let statusValue = statusDisplay(for: limit)
        
        return ResponsibleGamingLimitSuccessInfo(
            successMessage: message,
            periodTitle: periodTitle,
            periodValue: periodValue,
            amountTitle: amountTitle,
            amountValue: amountValue,
            statusTitle: statusTitle,
            statusValue: statusValue,
            highlightStatus: true,
            shouldLogoutOnDismiss: false
        )
    }
    
    private func makeLimitRemovalSuccessInfo(limit: UserLimit?) -> ResponsibleGamingLimitSuccessInfo {
        let category = limitCategory(for: limit?.type)
        let message = successMessage(for: category, action: .delete)
        let periodTitle = localizedValue(for: "period", fallback: "Period")
        let periodValue = limit.map { displayText(for: $0.period) } ?? ""
        let statusTitle = localizedValue(for: "status", fallback: "Status")
        let statusValue = localizedValue(for: "removed", fallback: "Removed")
        
        return ResponsibleGamingLimitSuccessInfo(
            successMessage: message,
            periodTitle: periodTitle,
            periodValue: periodValue,
            amountTitle: nil,
            amountValue: nil,
            statusTitle: statusTitle,
            statusValue: statusValue,
            highlightStatus: false,
            shouldLogoutOnDismiss: false
        )
    }
    
    private func makeTimeoutSuccessInfo(periodLabel: String) -> ResponsibleGamingLimitSuccessInfo {
        let message = localizedValue(for: "timeout_set_successfully", fallback: "Timeout set successfully")
        let periodTitle = localizedValue(for: "choose_time_period", fallback: "Choose Time Period")
        let localizedPeriod = localized(periodLabel)
        let periodValue = localizedPeriod == periodLabel ? periodLabel : localizedPeriod
        let startTitle = localizedValue(for: "timeout_started", fallback: "Timeout started")
        let startValue = timeoutDateFormatter.string(from: Date())
        let statusTitle = localizedValue(for: "status", fallback: "Status")
        let statusValue = localizedValue(for: "active", fallback: "Active")
        
        return ResponsibleGamingLimitSuccessInfo(
            successMessage: message,
            periodTitle: periodTitle,
            periodValue: periodValue,
            amountTitle: startTitle,
            amountValue: startValue,
            statusTitle: statusTitle,
            statusValue: statusValue,
            highlightStatus: true,
            shouldLogoutOnDismiss: true
        )
    }
    
    private func makeSelfExclusionSuccessInfo(periodLabel: String) -> ResponsibleGamingLimitSuccessInfo {
        let message = localizedValue(for: "self_exclusion_set_successfully", fallback: "Self-exclusion set successfully")
        let periodTitle = localizedValue(for: "exclusion_period", fallback: "Exclusion Period")
        let localizedPeriod = localized(periodLabel)
        let periodValue = localizedPeriod == periodLabel ? periodLabel : localizedPeriod
        let startTitle = localizedValue(for: "started_date", fallback: "Started Date")
        let startValue = timeoutDateFormatter.string(from: Date())
        let statusTitle = localizedValue(for: "status", fallback: "Status")
        let statusValue = localizedValue(for: "active", fallback: "Active")
        
        return ResponsibleGamingLimitSuccessInfo(
            successMessage: message,
            periodTitle: periodTitle,
            periodValue: periodValue,
            amountTitle: startTitle,
            amountValue: startValue,
            statusTitle: statusTitle,
            statusValue: statusValue,
            highlightStatus: true,
            shouldLogoutOnDismiss: true
        )
    }
    
    private func statusDisplay(for limit: UserLimit) -> String {
        if let status = limit.schedules?.last(where: { !($0.updateStatus ?? "").isEmpty })?.updateStatus {
            let key = "responsible_gaming_limit_status_\(status.lowercased())"
            let localizedStatus = localized(key)
            return localizedStatus == key ? status.capitalized : localizedStatus
        }
        
        let activeStatus = localized("active")
        
        return activeStatus == "active" ? "Active" : activeStatus
    }
    
    private func successMessage(for category: LimitCategory?, action: LimitSuccessAction) -> String {
        guard let category else {
            let localizedSuccess = localized("success")
            return localizedSuccess
        }
        
        let key = successMessageKey(for: category, action: action)
        let localizedValue = localized(key)
        
        return localizedValue
    }
    
    private func localizedValue(for key: String, fallback: String) -> String {
        let value = localized(key)
        
        return value == key ? fallback : value
    }
    
    private func successMessageKey(for category: LimitCategory, action: LimitSuccessAction) -> String {
        switch (category, action) {
        case (.deposit, .set):
            return "deposit_limit_set"
        case (.deposit, .update):
            return "deposit_limit_updated"
        case (.deposit, .delete):
            return "deposit_limit_deleted"
        case (.wagering, .set):
            return "wagering_limit_set"
        case (.wagering, .update):
            return "wagering_limit_updated"
        case (.wagering, .delete):
            return "wagering_limit_deleted"
        }
    }
    
    private func limitCategory(for type: String?) -> LimitCategory? {
        guard let type = type?.trimmingCharacters(in: .whitespacesAndNewlines), !type.isEmpty else {
            return nil
        }
        
        switch type.lowercased() {
        case "deposit":
            return .deposit
        case "wagering", "loss":
            return .wagering
        default:
            return nil
        }
    }
    
    // MARK: View model creation
    private func makeCardViewModel(from limit: UserLimit) -> UserLimitCardViewModelProtocol {
        let typeDisplay = displayText(for: limit.period)
        let valueDisplay = formattedValue(for: limit)
        let actionTitle = localized("delete")
        
        return ResponsibleGamingUserLimitCardViewModel(
            limitId: limit.id,
            typeText: typeDisplay,
            valueText: valueDisplay,
            actionTitle: actionTitle
        )
    }
    
    // MARK: Navigation
    func navigateBack() {
        onNavigateBack()
    }
}

// MARK: Other component view models structs
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
    
    func selectedPeriodIdentifiers() -> [String] {
        guard let period = selectedPeriod() else { return [] }
        var identifiers: [String] = []
        if let apiValue = period.apiValue, !apiValue.isEmpty {
            identifiers.append(apiValue)
        }
        identifiers.append(period.value)
        identifiers.append(period.label)
        return identifiers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var selectedOptionPublisher: AnyPublisher<String?, Never> {
        selectedOptionId.eraseToAnyPublisher()
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
