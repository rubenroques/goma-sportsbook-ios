//
//  PromotionsViewController.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import UIKit
import Combine
import ServicesProvider
import GomaUI

class PromotionsViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()

    private lazy var navigationBarView: SimpleNavigationBarView = {
        let navViewModel = BetssonCameroonNavigationBarViewModel(
            title: nil,  // No title for promotions screen
            onBackTapped: { [weak self] in
                self?.viewModel.onNavigateBack()
            }
        )
        let navBar = SimpleNavigationBarView(viewModel: navViewModel)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    private lazy var promotionalHeaderView: PromotionalHeaderView = {
        let view = PromotionalHeaderView(viewModel: viewModel.promotionalHeaderViewModel!)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var promotionSelectorBarView: PromotionSelectorBarView = {
        let view = PromotionSelectorBarView(viewModel: viewModel.promotionSelectorBarViewModel!)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    
    // Data source for promotions
    private var filteredPromotions: [PromotionInfo] = []
    private var selectedCategoryId: String?
    
    private var viewModel: PromotionsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateBaseView.isHidden = !isEmptyState
        }
    }
    
    // MARK: Lifetime and cycle
    init(viewModel: PromotionsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

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

        self.promotionalHeaderView.backgroundColor = .clear
        self.promotionSelectorBarView.backgroundColor = .clear
        self.scrollView.backgroundColor = .clear
        self.containerView.backgroundColor = .clear
        
        self.emptyStateBaseView.backgroundColor = StyleProvider.Color.backgroundPrimary

        self.emptyStateLabel.textColor = StyleProvider.Color.textPrimary
        
        self.loadingBaseView.backgroundColor = StyleProvider.Color.backgroundPrimary

    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: PromotionsViewModel) {
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                    // Set initial filtered promotions based on first category (default selection)
                    if let firstCategory = viewModel.categories.first {
                        self?.selectedCategoryId = String(firstCategory.id)
                        self?.filteredPromotions = viewModel.getPromotions(for: String(firstCategory.id))
                    } else {
                        self?.filteredPromotions = viewModel.promotions
                    }
                    self?.updatePromotionsList()
                    
                    self?.isEmptyState = self?.filteredPromotions.isEmpty ?? viewModel.promotions.isEmpty
                }
            })
            .store(in: &cancellables)
        
        viewModel.onCategorySelected = { [weak self] categoryId in
            self?.handleCategorySelection(categoryId)
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
    
    private func openPromotionURL(urlString: String) {
        viewModel.openPromotionURL(urlString: urlString)
    }
    
    private func openPromotionDetail(promotion: PromotionInfo) {
        viewModel.openPromotionDetail(promotion: promotion)
    }
    
}

// MARK: - Data Management
extension PromotionsViewController {
    
    private func updatePromotionsList() {
        // Clear existing views
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Add promotion card views
        for (index, promotion) in self.filteredPromotions.enumerated() {
            // Find the original index in ViewModel promotions to get the correct ViewModel
            guard let originalIndex = self.viewModel.promotions.firstIndex(where: { $0.id == promotion.id }),
                  let cardViewModel = self.viewModel.cardViewModel(forIndex: originalIndex) else {
                continue
            }
            
            // Setup callbacks for button actions
            if let mockCardViewModel = cardViewModel as? MockPromotionCardViewModel {
                
                mockCardViewModel.onCTATapped = { [weak self] ctaUrl in
                    self?.openPromotionURL(urlString: ctaUrl)
                }
                
                mockCardViewModel.onReadMoreTapped = { [weak self] in
                    self?.openPromotionDetail(promotion: promotion)
                }
                
                mockCardViewModel.onCardTapped = { [weak self] in
                    self?.openPromotionDetail(promotion: promotion)
                }
            }
            
            let cardView = PromotionCardView(viewModel: cardViewModel)
            self.stackView.addArrangedSubview(cardView)
        }
    }
    
    
    private func handleCategorySelection(_ categoryId: String?) {
        selectedCategoryId = categoryId
        
        // Get filtered promotions from ViewModel
        self.filteredPromotions = self.viewModel.getPromotions(for: categoryId)
        
        // Update the promotions list
        updatePromotionsList()
        
        // Update empty state
        self.isEmptyState = self.filteredPromotions.isEmpty
    }
}

extension PromotionsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }
    
    private static func createEmptyStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_tickets_logged_off_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .bold, size: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No promotions available"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBarView)

        self.view.addSubview(self.promotionSelectorBarView)
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.promotionalHeaderView)
        self.containerView.addSubview(self.stackView)
        
        self.view.addSubview(self.emptyStateBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)

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
            // Navigation Bar
            self.navigationBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBarView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),

            self.promotionSelectorBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.promotionSelectorBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.promotionSelectorBarView.topAnchor.constraint(equalTo: self.navigationBarView.bottomAnchor),
            self.promotionSelectorBarView.heightAnchor.constraint(equalToConstant: 60),
            
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.promotionSelectorBarView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
            self.promotionalHeaderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.promotionalHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.promotionalHeaderView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.promotionalHeaderView.heightAnchor.constraint(equalToConstant: 56),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.stackView.topAnchor.constraint(equalTo: self.promotionalHeaderView.bottomAnchor, constant: 16),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16)
        ])
        
        // Empty state view
        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.promotionSelectorBarView.bottomAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateBaseView.topAnchor, constant: 45),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateBaseView.leadingAnchor, constant: 35),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateBaseView.trailingAnchor, constant: -35),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24)
        ])
        
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.navigationBarView.bottomAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
