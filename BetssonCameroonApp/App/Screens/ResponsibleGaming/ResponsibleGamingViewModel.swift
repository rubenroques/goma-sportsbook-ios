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
    
    // MARK: - Navigation Callbacks
    var onNavigateBack: (() -> Void) = { }
    
    let servicesProvider: ServicesProvider.Client
    private let userCurrency: String
    private var depositAmountValue: String = ""
    private var wageringAmountValue: String = ""
    
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
        
        depositLimitCurrentValue = "None"
        wageringLimitCurrentValue = "None"
        
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
        
        setupButtonCallbacks()
        setupBindings()
    }
    
    // MARK: - Actions
    func setDepositLimit() {
        guard !isLoading.value else { return }
        isLoading.send(true)
        let amount = depositAmountValue
        let currencyPrefix = userCurrency.isEmpty ? "" : "\(userCurrency) "
        let selectedPeriod = depositOptionsViewModel?.selectedPeriod()?.label ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if amount.isEmpty {
                self.depositLimitCurrentValue = "None"
            } else {
                self.depositLimitCurrentValue = "\(currencyPrefix)\(amount)"
            }
            self.onDepositLimitUpdated?(self.depositLimitCurrentValue)
            self.isLoading.send(false)
            print("[ResponsibleGaming] Deposit limit set for period: \(selectedPeriod) amount: \(self.depositLimitCurrentValue)")
        }
    }
    
    func setWageringLimit() {
        guard !isLoading.value else { return }
        isLoading.send(true)
        let amount = wageringAmountValue
        let currencyPrefix = userCurrency.isEmpty ? "" : "\(userCurrency) "
        let selectedPeriod = wageringOptionsViewModel?.selectedPeriod()?.label ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if amount.isEmpty {
                self.wageringLimitCurrentValue = "None"
            } else {
                self.wageringLimitCurrentValue = "\(currencyPrefix)\(amount)"
            }
            self.onWageringLimitUpdated?(self.wageringLimitCurrentValue)
            self.isLoading.send(false)
            print("[ResponsibleGaming] Wagering limit set for period: \(selectedPeriod) amount: \(self.wageringLimitCurrentValue)")
        }
    }
    
    func setTimeOut() {
        guard !isLoading.value else { return }
        isLoading.send(true)
        let selectedPeriod = timeOutOptionsInternal?.selectedPeriod()?.value ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading.send(false)
            print("[ResponsibleGaming] Timeout set with period: \(selectedPeriod)")
        }
    }
    
    func setSelfExclusion() {
        guard !isLoading.value else { return }
        isLoading.send(true)
        let selectedPeriod = selfExclusionOptionsInternal?.selectedPeriod()?.value ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading.send(false)
            print("[ResponsibleGaming] Self exclusion set with period: \(selectedPeriod)")
        }
    }
    
    func navigateBack() {
        onNavigateBack()
    }
}

private extension ResponsibleGamingViewModel {
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
        return periods.first { $0.value == selected }
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
