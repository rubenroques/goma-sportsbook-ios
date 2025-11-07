//
//  BonusViewController.swift
//  BetssonCameroonApp
//
//  Created by Claude on 23/10/2025.
//

import UIKit
import Combine
import ServicesProvider
import GomaUI

class BonusViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    
    private lazy var depositWithoutBonusButton: ButtonView = {
        let button = ButtonView(viewModel: viewModel.depositWithoutBonusButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var bonusSelectorBarView: PromotionSelectorBarView? = {
        guard let bonusSelectorBarViewModel = viewModel.bonusSelectorBarViewModel else {
            return nil
        }
        let view = PromotionSelectorBarView(viewModel: bonusSelectorBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var innerContainerView: UIView = Self.createInnerContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var refreshButton: ButtonView = {
        let button = ButtonView(viewModel: viewModel.refreshButtonViewModel)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var viewModel: BonusViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(viewModel: BonusViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch viewModel.displayType {
        case .register:
            self.titleLabel.text = localized("select_bonus")
        case .history:
            self.titleLabel.text = localized("bonuses")
        }

        self.setupSubviews()
        self.setupWithTheme()
        self.setupButtonActions()
        self.bind(toViewModel: self.viewModel)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = StyleProvider.Color.backgroundTertiary

        self.topSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.bottomSafeAreaView.backgroundColor = StyleProvider.Color.backgroundTertiary

        self.navigationView.backgroundColor = StyleProvider.Color.backgroundTertiary
        self.titleLabel.textColor = StyleProvider.Color.textPrimary
        self.closeButton.tintColor = StyleProvider.Color.highlightPrimary
        
        self.scrollView.backgroundColor = .clear
        self.containerView.backgroundColor = .clear
        self.innerContainerView.backgroundColor = StyleProvider.Color.backgroundPrimary

        self.loadingBaseView.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        self.emptyStateView.backgroundColor = .clear
        self.emptyStateLabel.textColor = StyleProvider.Color.textSecondary

    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: BonusViewModel) {
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                    self?.updateBonusesList()
                }
            })
            .store(in: &cancellables)
        
        // Bind to tab selection events
        viewModel.onBonusTabSelected = { [weak self] tab in
            self?.updateBonusesList()
        }
        
        viewModel.onTermsURLRequested = { [weak self] actionUrl in
            self?.openExternalURL(url: actionUrl ?? "")
        }
        
    }
    
    // MARK: Functions
    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }
    
    private func setupButtonActions() {
        // Setup close button action
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    private func openExternalURL(url: String) {
        
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
        else {
            print("Invalid url: \(url)")
        }
    }
    
    // MARK: Actions
    @objc private func didTapCloseButton() {
        self.viewModel.navigateBack()
    }
}

// MARK: - Data Management
extension BonusViewController {
    
    private func updateBonusesList() {
        // Clear existing views
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Get count based on display type and selected tab
        let count = self.viewModel.getBonusCount()
        
        // Show/hide empty state
        if count == 0 {
            self.emptyStateView.isHidden = false
            self.stackView.isHidden = true
            return
        } else {
            self.emptyStateView.isHidden = true
            self.stackView.isHidden = false
        }
        
        // Determine if we're showing granted bonuses
        let showingGrantedBonuses = viewModel.displayType == .history && 
                                    viewModel.getBonusTabSelection() == .granted
        
        // Add bonus card views
        for index in 0..<count {
            if showingGrantedBonuses {
                // Create BonusInfoCardView for granted bonuses
                guard let cardViewModel = self.viewModel.grantedCardViewModel(forIndex: index) else {
                    continue
                }
                
                let cardView = BonusInfoCardView(viewModel: cardViewModel)
                cardView.translatesAutoresizingMaskIntoConstraints = false
                self.stackView.addArrangedSubview(cardView)
                
            } else {
                // Create BonusCardView for available bonuses
                guard let cardViewModel = self.viewModel.cardViewModel(forIndex: index) else {
                    continue
                }
                
                let cardView = BonusCardView(viewModel: cardViewModel)
                cardView.translatesAutoresizingMaskIntoConstraints = false
                self.stackView.addArrangedSubview(cardView)
            }
        }
    }
}

extension BonusViewController {

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
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textAlignment = .center
        label.text = localized("select_bonus")
        return label
    }
    
    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cancel_search_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .scaleAspectFit
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
        view.layer.cornerRadius = 8
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }
    
    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }
    
    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textAlignment = .center
        label.text = localized("no_bonuses_found")
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)
        
        // Add deposit button or selector bar based on display type
        if viewModel.displayType == .register {
            self.view.addSubview(self.depositWithoutBonusButton)
            self.depositWithoutBonusButton.isHidden = false
        } else if let selectorBar = self.bonusSelectorBarView {
            self.view.addSubview(selectorBar)
            selectorBar.isHidden = false
            self.depositWithoutBonusButton.isHidden = true
        }
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.innerContainerView)
        self.innerContainerView.addSubview(self.stackView)
        
        // Add empty state view
        self.innerContainerView.addSubview(self.emptyStateView)
        self.emptyStateView.addSubview(self.emptyStateLabel)
        self.emptyStateView.addSubview(self.refreshButton)

        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            // Title label
            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            
            // Close button
            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 24),
            self.closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Conditionally add constraints based on display type
        if viewModel.displayType == .register {
            NSLayoutConstraint.activate([
                self.depositWithoutBonusButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                self.depositWithoutBonusButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                self.depositWithoutBonusButton.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 16),
                
                self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.scrollView.topAnchor.constraint(equalTo: self.depositWithoutBonusButton.bottomAnchor, constant: 16),
                self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
            ])
        } else if let selectorBar = self.bonusSelectorBarView {
            NSLayoutConstraint.activate([
                selectorBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                selectorBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                selectorBar.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 8),
                selectorBar.heightAnchor.constraint(equalToConstant: 60),
                
                self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.scrollView.topAnchor.constraint(equalTo: selectorBar.bottomAnchor, constant: 8),
                self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            
            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
            self.innerContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.innerContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.innerContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
            self.innerContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 8),
            self.stackView.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -8),
            self.stackView.topAnchor.constraint(equalTo: self.innerContainerView.topAnchor, constant: 8),
            self.stackView.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.navigationView.bottomAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])
        
        // Empty state view constraints
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.innerContainerView.topAnchor, constant: 40),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor, constant: -40),
            
            // Empty state label
            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 20),
            
            // Refresh button
            self.refreshButton.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),
            self.refreshButton.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 15),
            self.refreshButton.bottomAnchor.constraint(equalTo: self.emptyStateView.bottomAnchor, constant: -20),
            self.refreshButton.heightAnchor.constraint(equalToConstant: 36),
            self.refreshButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

    }

}

