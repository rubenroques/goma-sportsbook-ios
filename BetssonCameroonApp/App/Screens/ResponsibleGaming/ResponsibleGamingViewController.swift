//
//  ResponsibleGamingViewController.swift
//  BetssonCameroonApp
//
//  Created by André on 07/11/2025.
//

import UIKit
import Combine
import ServicesProvider
import GomaUI

class ResponsibleGamingViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var innerContainerView: UIView = Self.createInnerContainerView()
    
    private lazy var informationSection: ExpandableSectionView = {
        let view = ExpandableSectionView(viewModel: viewModel.informationSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var informationTextSections: [TextSectionView] = {
        return viewModel.informationTextSectionViewModels.map { viewModel in
            let view = TextSectionView(viewModel: viewModel)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
    }()
    
    private lazy var depositLimitSection: ExpandableSectionView = {
        let view = ExpandableSectionView(viewModel: viewModel.depositLimitSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var depositLimitCardsStackView: UIStackView = Self.createLimitCardsStackView()

    private lazy var depositLimitOptionsView: SelectOptionsView = {
        let view = SelectOptionsView(viewModel: viewModel.depositLimitOptionsViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let depositCurrentLimitValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    private lazy var depositLimitAmountTitleLabel: UILabel = Self.createLimitAmountTitleLabel()
    private lazy var depositLimitAmountValueLabel: UILabel = Self.createLimitAmountValueLabel()
    private lazy var depositLimitAmountView: UIView = Self.createLimitAmountContainer(
        titleLabel: depositLimitAmountTitleLabel,
        valueLabel: depositLimitAmountValueLabel
    )
    
    private lazy var depositAmountTextField: BorderedTextFieldView = {
        let view = BorderedTextFieldView(viewModel: viewModel.depositAmountTextFieldViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var depositLimitActionButton: ButtonView = {
        let view = ButtonView(viewModel: viewModel.depositLimitActionButtonViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    private lazy var wageringLimitSection: ExpandableSectionView = {
        let view = ExpandableSectionView(viewModel: viewModel.wageringLimitSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var wageringLimitCardsStackView: UIStackView = Self.createLimitCardsStackView()

    private lazy var wageringLimitOptionsView: SelectOptionsView = {
        let view = SelectOptionsView(viewModel: viewModel.wageringLimitOptionsViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let wageringCurrentLimitValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    private lazy var wageringLimitAmountTitleLabel: UILabel = Self.createLimitAmountTitleLabel()
    private lazy var wageringLimitAmountValueLabel: UILabel = Self.createLimitAmountValueLabel()
    private lazy var wageringLimitAmountView: UIView = Self.createLimitAmountContainer(
        titleLabel: wageringLimitAmountTitleLabel,
        valueLabel: wageringLimitAmountValueLabel
    )
    
    private lazy var wageringAmountTextField: BorderedTextFieldView = {
        let view = BorderedTextFieldView(viewModel: viewModel.wageringAmountTextFieldViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var wageringLimitActionButton: ButtonView = {
        let view = ButtonView(viewModel: viewModel.wageringLimitActionButtonViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeOutSection: ExpandableSectionView = {
        let view = ExpandableSectionView(viewModel: viewModel.timeOutSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeOutOptionsView: SelectOptionsView = {
        let view = SelectOptionsView(viewModel: viewModel.timeOutOptionsViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeOutActionButton: ButtonView = {
        let view = ButtonView(viewModel: viewModel.timeOutActionButtonViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selfExclusionSection: ExpandableSectionView = {
        let view = ExpandableSectionView(viewModel: viewModel.selfExclusionSectionViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selfExclusionOptionsView: SelectOptionsView = {
        let view = SelectOptionsView(viewModel: viewModel.selfExclusionOptionsViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selfExclusionActionButton: ButtonView = {
        let view = ButtonView(viewModel: viewModel.selfExclusionActionButtonViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingOverlayView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        container.isHidden = true
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        container.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }()
    
    private var viewModel: ResponsibleGamingViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: ResponsibleGamingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = localized("responsible_gaming")
        
        self.setupSubviews()
        self.setupWithTheme()
        self.setupButtonActions()
        self.setupInformationExpandableSectionContent()
        self.setupDepositLimitSectionContent()
        self.setupWageringLimitSectionContent()
        self.setupTimeOutSectionContent()
        self.setupSelfExclusionSectionContent()
        self.setupLoadingOverlay()
        self.setupViewModelCallbacks()
        self.bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.innerContainerView.layer.cornerRadius = 8
    }

    // MARK: - Setup Methods
    
    private func setupWithTheme() {
        self.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.topSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.navigationView.backgroundColor = .clear
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.backButton.tintColor = StyleProvider.Color.textPrimary
        self.containerView.backgroundColor = .clear
        self.innerContainerView.backgroundColor = StyleProvider.Color.backgroundPrimary
        self.depositLimitAmountTitleLabel.textColor = StyleProvider.Color.textPrimary
        self.depositLimitAmountValueLabel.textColor = StyleProvider.Color.textSecondary
        self.wageringLimitAmountTitleLabel.textColor = StyleProvider.Color.textPrimary
        self.wageringLimitAmountValueLabel.textColor = StyleProvider.Color.textSecondary
    }
    
    private func setupButtonActions() {
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func setupInformationExpandableSectionContent() {
        // Add subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = localized("rg_information_subtitle")
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        informationSection.contentContainer.addArrangedSubview(subtitleLabel)
        
        informationTextSections.forEach { sectionView in
            informationSection.contentContainer.addArrangedSubview(sectionView)
        }
    }
    
    private func setupDepositLimitSectionContent() {
        let subtitleLabel = UILabel()
        subtitleLabel.text = localized("choose_new_deposit_limit")
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        subtitleLabel.numberOfLines = 0
        depositLimitSection.contentContainer.addArrangedSubview(subtitleLabel)
        
        depositCurrentLimitValueLabel.text = viewModel.depositLimitCurrentValue
        depositLimitSection.contentContainer.addArrangedSubview(depositCurrentLimitValueLabel)
        depositLimitCardsStackView.isHidden = true
        depositLimitSection.contentContainer.addArrangedSubview(depositLimitCardsStackView)
        
        depositLimitSection.contentContainer.addArrangedSubview(depositLimitOptionsView)
        
        depositLimitAmountTitleLabel.text = localized("deposit_limit_amount")
        depositLimitAmountValueLabel.text = viewModel.depositSelectedLimitAmountText
        depositLimitSection.contentContainer.addArrangedSubview(depositLimitAmountView)
        
        depositLimitSection.contentContainer.addArrangedSubview(depositAmountTextField)
        depositLimitSection.contentContainer.addArrangedSubview(depositLimitActionButton)
    }
    
    private func setupWageringLimitSectionContent() {
        let subtitleLabel = UILabel()
        subtitleLabel.text = localized("choose_new_wagering_limit")
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        subtitleLabel.numberOfLines = 0
        wageringLimitSection.contentContainer.addArrangedSubview(subtitleLabel)
        
        wageringCurrentLimitValueLabel.text = viewModel.wageringLimitCurrentValue
        wageringLimitSection.contentContainer.addArrangedSubview(wageringCurrentLimitValueLabel)
        wageringLimitCardsStackView.isHidden = true
        wageringLimitSection.contentContainer.addArrangedSubview(wageringLimitCardsStackView)
        wageringLimitSection.contentContainer.addArrangedSubview(wageringLimitOptionsView)
        
        wageringLimitAmountTitleLabel.text = localized("wagering_limit_amount")
        wageringLimitAmountValueLabel.text = viewModel.wageringSelectedLimitAmountText
        wageringLimitSection.contentContainer.addArrangedSubview(wageringLimitAmountView)
        
        wageringLimitSection.contentContainer.addArrangedSubview(wageringAmountTextField)
        wageringLimitSection.contentContainer.addArrangedSubview(wageringLimitActionButton)
    }
    
    private func setupTimeOutSectionContent() {
        let subtitleLabel = UILabel()
        subtitleLabel.text = localized("timeout_description")
        subtitleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        subtitleLabel.numberOfLines = 0
        timeOutSection.contentContainer.addArrangedSubview(subtitleLabel)
        
        timeOutSection.contentContainer.addArrangedSubview(timeOutOptionsView)
        timeOutSection.contentContainer.addArrangedSubview(timeOutActionButton)
    }
    
    private func setupSelfExclusionSectionContent() {
        selfExclusionSection.contentContainer.addArrangedSubview(selfExclusionOptionsView)
        selfExclusionSection.contentContainer.addArrangedSubview(selfExclusionActionButton)
    }
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlayView)
        NSLayoutConstraint.activate([
            loadingOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(loadingOverlayView)
    }
    
    private func setupViewModelCallbacks() {
        depositCurrentLimitValueLabel.text = viewModel.depositLimitCurrentValue
        wageringCurrentLimitValueLabel.text = viewModel.wageringLimitCurrentValue
        viewModel.onDepositLimitUpdated = { [weak self] updatedValue in
            self?.depositCurrentLimitValueLabel.text = updatedValue
        }
        viewModel.onDepositLimitAmountUpdated = { [weak self] amount in
            self?.depositLimitAmountValueLabel.text = amount
        }
        viewModel.onWageringLimitUpdated = { [weak self] updatedValue in
            self?.wageringCurrentLimitValueLabel.text = updatedValue
        }
        viewModel.onWageringLimitAmountUpdated = { [weak self] amount in
            self?.wageringLimitAmountValueLabel.text = amount
        }
        viewModel.onLimitError = { [weak self] limitType, errorDescription in
            let message = localized("\(limitType.lowercased())_limit_error_message")
            
            self?.presentAlert(
                title: localized("\(limitType.lowercased())_limit_error_title"),
                message: message
            )
        }
        viewModel.onTimeoutError = { [weak self] errorDescription in
            let message = localized("timeout_error_message")
            self?.presentAlert(
                title: localized("timeout_error_title"),
                message: message
            )
        }
        viewModel.onSelfExclusionError = { [weak self] errorDescription in
            let message = localized("self_exclusion_error_message")
            self?.presentAlert(
                title: localized("self_exclusion_error_title"),
                message: message
            )
        }
        viewModel.onSelfExclusionConfirmationRequested = { [weak self] in
            self?.presentSelfExclusionConfirmation()
        }
        viewModel.onDepositLimitCardsChanged = { [weak self] cardViewModels in
            guard let self else { return }
            self.renderUserLimitCards(in: self.depositLimitCardsStackView, with: cardViewModels)
        }
        viewModel.onWageringLimitCardsChanged = { [weak self] cardViewModels in
            guard let self else { return }
            self.renderUserLimitCards(in: self.wageringLimitCardsStackView, with: cardViewModels)
        }
        
        renderUserLimitCards(in: depositLimitCardsStackView, with: viewModel.depositLimitCardViewModels)
        renderUserLimitCards(in: wageringLimitCardsStackView, with: viewModel.wageringLimitCardViewModels)
    }
    
    private func bindViewModel() {
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingOverlayView.isHidden = !isLoading
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        viewModel.navigateBack()
    }
}

private extension ResponsibleGamingViewController {
    func presentSelfExclusionConfirmation() {
        let alertController = UIAlertController(
            title: localized("confirm_self_exclusion"),
            message: localized("self_exclusion_warning_message"),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: localized("confirm"), style: .destructive) { [weak self] _ in
            self?.viewModel.confirmSelfExclusion()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: localized("ok"), style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func presentExclusionAlert(title: String, periodLocalizationKey: String, messageFormatKey: String) {
        let periodText = localized(periodLocalizationKey)
        let message = String(format: localized(messageFormatKey), periodText)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: localized("ok"), style: .default) { [weak self] _ in
            self?.logoutUser()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func logoutUser() {
        Env.userSessionStore.logout()
        viewModel.navigateBack()
    }

    static func createLimitCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }

    func renderUserLimitCards(in stackView: UIStackView, with viewModels: [UserLimitCardViewModelProtocol]) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if !viewModels.isEmpty {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = StyleProvider.fontWith(type: .bold, size: 12)
            titleLabel.textColor = StyleProvider.Color.textPrimary
            titleLabel.numberOfLines = 1
            
            if stackView == depositLimitCardsStackView {
                titleLabel.text = localized("active_deposit_limits")
            } else {
                titleLabel.text = localized("active_wagering_limits")
            }
            
            stackView.addArrangedSubview(titleLabel)
        }
        
        viewModels.forEach { cardViewModel in
            let cardView = UserLimitCardView(viewModel: cardViewModel)
            cardView.onActionTapped = { [weak self] limitId in
                self?.viewModel.removeLimit(withId: limitId)
            }
            stackView.addArrangedSubview(cardView)
        }
        
        stackView.isHidden = viewModels.isEmpty
    }
}

// MARK: - Subviews Initialization and Setup
extension ResponsibleGamingViewController {
    
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 18)
        label.textAlignment = .center
        return label
    }
    
    private static func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImage(systemName: "chevron.left")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        )
        button.setImage(icon, for: .normal)
        
        return button
    }
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createInnerContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createLimitAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createLimitAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    private static func createLimitAmountContainer(titleLabel: UILabel, valueLabel: UILabel) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: view.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    private func setupSubviews() {
        // Add top safe area view
        self.view.addSubview(self.topSafeAreaView)
        
        // Add navigation view
        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.backButton)
        
        // Add scroll view
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        
        // Add inner container
        self.containerView.addSubview(self.innerContainerView)
        
        // Add expandable sections to inner container
        self.innerContainerView.addSubview(self.informationSection)
        self.innerContainerView.addSubview(self.depositLimitSection)
        self.innerContainerView.addSubview(self.wageringLimitSection)
        self.innerContainerView.addSubview(self.timeOutSection)
        self.innerContainerView.addSubview(self.selfExclusionSection)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Top Safe Area View
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            
            // Navigation View
            self.navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 56),
            
            // Back Button
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 16),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 44),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title Label
            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.backButton.trailingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.navigationView.trailingAnchor, constant: -16),
            
            // Scroll View
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            // Container View
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),
            
            // Inner Container View
            self.innerContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.innerContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.innerContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.innerContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),
            
            // Information Section
            self.informationSection.topAnchor.constraint(equalTo: self.innerContainerView.topAnchor, constant: 8),
            self.informationSection.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.informationSection.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            
            // Deposit Limit Section
            self.depositLimitSection.topAnchor.constraint(equalTo: self.informationSection.bottomAnchor, constant: 12),
            self.depositLimitSection.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.depositLimitSection.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            
            // Wagering Limit Section
            self.wageringLimitSection.topAnchor.constraint(equalTo: self.depositLimitSection.bottomAnchor, constant: 12),
            self.wageringLimitSection.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.wageringLimitSection.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            
            // Time Out Section
            self.timeOutSection.topAnchor.constraint(equalTo: self.wageringLimitSection.bottomAnchor, constant: 12),
            self.timeOutSection.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.timeOutSection.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            
            // Self Exclusion Section
            self.selfExclusionSection.topAnchor.constraint(equalTo: self.timeOutSection.bottomAnchor, constant: 12),
            self.selfExclusionSection.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.selfExclusionSection.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            self.selfExclusionSection.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor, constant: -8)
        ])
    }
}

