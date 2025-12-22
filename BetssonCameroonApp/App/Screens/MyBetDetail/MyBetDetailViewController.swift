//
//  MyBetDetailViewController.swift
//  BetssonCameroonApp
//
//  Created on 01/09/2025.
//

import UIKit
import Combine
import GomaUI

final class MyBetDetailViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: MyBetDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components

    private lazy var navigationBarView: SimpleNavigationBarView = {
        let viewModel = BetssonCameroonNavigationBarViewModel(
            title: localized("mybetdetail_nav_title"),
            onBackTapped: { [weak self] in
                self?.viewModel.handleBackTap()
            }
        )
        let navBar = SimpleNavigationBarView(viewModel: viewModel)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    private lazy var shareButton: UIButton = Self.createShareButton()

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
        // Add navigation bar
        view.addSubview(navigationBarView)
        view.addSubview(contentScrollView)

        // Add share button on top of navigation bar (right side)
        view.addSubview(shareButton)

        // Content hierarchy inside scroll view
        contentScrollView.addSubview(mainStackView)

        // Add GomaUI components to main stack view
        mainStackView.addArrangedSubview(betDetailValuesSummaryView)
        mainStackView.addArrangedSubview(selectionsLabel)
        mainStackView.addArrangedSubview(selectionsStackView)

        // Populate selections stack view with result summary views
        setupSelectionsStackView()
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
            // Navigation Bar (at top)
            navigationBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Share Button (right side of navigation bar)
            shareButton.trailingAnchor.constraint(equalTo: navigationBarView.trailingAnchor, constant: -16),
            shareButton.centerYAnchor.constraint(equalTo: navigationBarView.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 24),
            shareButton.heightAnchor.constraint(equalToConstant: 24),

            // Content Scroll View (below navigation)
            contentScrollView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor),
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
        // Share booking code presentation
        viewModel.onShareBookingCodeRequested = { [weak self] code in
            let shareBookingCodeViewModel = ShareBookingCodeViewModel(bookingCode: code)
            let shareBookingCodeViewController = ShareBookingCodeViewController(viewModel: shareBookingCodeViewModel)
            self?.present(shareBookingCodeViewController, animated: true)
        }

        // Booking code failure alert
        viewModel.onShareBookingCodeFailed = { [weak self] message in
            let errorMessage = localized("mybetdetail_booking_code_error_message")
                .replacingOccurrences(of: "{message}", with: message)
            let alert = UIAlertController(
                title: localized("mybetdetail_booking_code_error_title"),
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self?.present(alert, animated: true)
        }
    }
    
    private func setupActions() {
        shareButton.addTarget(self, action: #selector(didTapShare), for: .primaryActionTriggered)
    }


    // MARK: - Rendering

    // No state management needed - content is immediately visible

    // MARK: - Actions

    @objc private func didTapShare() {
        viewModel.handleShareTap()
    }
    
    // No retry needed - data is immediately available
    
}

// MARK: - Factory Methods

extension MyBetDetailViewController {

    private static func createShareButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "share_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = StyleProvider.Color.iconPrimary
        return button
    }
}
