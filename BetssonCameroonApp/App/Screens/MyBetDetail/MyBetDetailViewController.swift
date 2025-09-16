//
//  MyBetDetailViewController.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 01/09/2025.
//

import UIKit
import Combine
import GomaUI

final class MyBetDetailViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: MyBetDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var betDetailsTitleLabel: UILabel = Self.createBetDetailsTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    
    // Content scroll view and stack view
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    // GomaUI Components
    private lazy var betDetailValuesSummaryView: BetDetailValuesSummaryView = {
        let view = BetDetailValuesSummaryView(viewModel: viewModel.betDetailValuesSummaryViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = viewModel.selectionsLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    // Removed loading/error views - data is immediately available
    
    
    
    // MARK: - Initialization
    
    init(viewModel: MyBetDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
        
        // No loading needed - all data is immediately available
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupViewHierarchy() {
        // Add custom navigation view
        view.addSubview(customNavigationView)
        view.addSubview(contentScrollView)
        
        // Content hierarchy inside scroll view
        contentScrollView.addSubview(mainStackView)
        
        // Add GomaUI components to main stack view
        mainStackView.addArrangedSubview(betDetailValuesSummaryView)
        mainStackView.addArrangedSubview(selectionsLabel)
        mainStackView.addArrangedSubview(selectionsStackView)
        
        // Populate selections stack view with result summary views
        setupSelectionsStackView()
        
        customNavigationView.addSubview(betDetailsTitleLabel)
        customNavigationView.addSubview(backButton)
    }
    
    private func setupSelectionsStackView() {
        // Clear existing views
        selectionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add BetDetailResultSummaryView for each selection
        for selectionViewModel in viewModel.betDetailResultSummaryViewModels {
            let resultSummaryView = BetDetailResultSummaryView(viewModel: selectionViewModel)
            resultSummaryView.translatesAutoresizingMaskIntoConstraints = false
            selectionsStackView.addArrangedSubview(resultSummaryView)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Navigation View (at top)
            customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),
            
            // Bet Details Title Label
            betDetailsTitleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            betDetailsTitleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            
            // Back Button (Left side)
            backButton.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Content Scroll View (below navigation)
            contentScrollView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Main Stack View (inside scroll view)
            mainStackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor, constant: -16),
            
            // Important: Set the width constraint for scroll view content
            mainStackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, constant: -32) // Account for 16pt margins on each side
        ])
    }
    
    private func setupBindings() {
        // No binding needed - content is immediately available
        // Content is already visible since we removed loading states
        
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    
    // MARK: - Rendering
    
    // No state management needed - content is immediately visible
    
    // MARK: - Actions
    
    @objc private func didTapBack() {
        viewModel.handleBackTap()
    }
    
    // No retry needed - data is immediately available
    
}

// MARK: - Factory Methods

extension MyBetDetailViewController {
    
    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Add bottom separator line
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = StyleProvider.Color.separatorLine
        
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return view
    }
    
    private static func createBetDetailsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bet Details"
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Use standard iOS back arrow icon
        let backImage = UIImage(systemName: "chevron.left")
        button.setImage(backImage, for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        
        return button
    }
    
    // Removed loading and error view factories - not needed since data is immediately available
}
