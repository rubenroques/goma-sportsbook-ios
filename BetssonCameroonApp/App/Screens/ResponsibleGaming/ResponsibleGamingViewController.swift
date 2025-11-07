//
//  ResponsibleGamingViewController.swift
//  BetssonCameroonApp
//
//  Created by Claude on November 6, 2025.
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
    }
    
    private func setupButtonActions() {
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func setupInformationExpandableSectionContent() {
        // Add subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = localized("rg_information_subtitle")
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        informationSection.contentContainer.addArrangedSubview(subtitleLabel)
        
        informationTextSections.forEach { sectionView in
            informationSection.contentContainer.addArrangedSubview(sectionView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        viewModel.navigateBack()
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
        
        // Add expandable section to inner container
        self.innerContainerView.addSubview(self.informationSection)
        
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
            self.informationSection.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor, constant: -8)
        ])
    }
}

