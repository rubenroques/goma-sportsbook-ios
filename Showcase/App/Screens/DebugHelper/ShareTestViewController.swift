//
//  ShareTestViewController.swift
//  Sportsbook
//
//  Created by Claude Code on 26/07/2025.
//

#if DEBUG

import UIKit
import Combine
import ServicesProvider

class ShareTestViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.App.backgroundPrimary
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "BrandedTicketShareView Test"
        label.font = AppFont.with(type: .bold, size: 24)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var brandedShareView: BrandedTicketShareView = {
        let view = BrandedTicketShareView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var testButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var shareImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate Share Image", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.App.highlightPrimary
        button.layer.cornerRadius = CornerRadius.button
        button.addTarget(self, action: #selector(didTapShareImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var switchDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next Bet Type", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.App.backgroundSecondary
        button.layer.cornerRadius = CornerRadius.button
        button.addTarget(self, action: #selector(didTapSwitchData), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close Test", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = CornerRadius.button
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()
    
    // Test data state - cycle through different bet types
    private var currentMockIndex = 0
    private let mockBetCreators: [() -> BetHistoryEntry] = [
        MockDataFactory.createMockOpenFootballMultiple,    // Default - open football multiple
        MockDataFactory.createMockOpenBasketballSingle,    // Open basketball single
        MockDataFactory.createMockOpenSystemBet,           // Open system bet
        MockDataFactory.createMockBetHistoryEntry,         // Won multiple bet
        MockDataFactory.createMockSingleBetHistoryEntry    // Open tennis single
    ]
    private let mockBetTitles = [
        "Open Football Multiple",
        "Open Basketball Single", 
        "Open System Bet",
        "Won Multiple Bet",
        "Open Tennis Single"
    ]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupWithTheme()
        configureBrandedShareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar for full screen experience
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWithTheme()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(brandedShareView)
        contentView.addSubview(testButtonsStackView)
        
        testButtonsStackView.addArrangedSubview(shareImageButton)
        testButtonsStackView.addArrangedSubview(switchDataButton)
        testButtonsStackView.addArrangedSubview(closeButton)
        
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // BrandedShareView
            brandedShareView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            brandedShareView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            brandedShareView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            // Test Buttons Stack
            testButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            testButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            testButtonsStackView.topAnchor.constraint(equalTo: brandedShareView.bottomAnchor, constant: 30),
            testButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Button Heights
            shareImageButton.heightAnchor.constraint(equalToConstant: 50),
            switchDataButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupWithTheme() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        scrollView.backgroundColor = UIColor.App.backgroundPrimary
        
        titleLabel.textColor = UIColor.App.textPrimary
        shareImageButton.backgroundColor = UIColor.App.highlightPrimary
        switchDataButton.backgroundColor = UIColor.App.backgroundSecondary
    }
    
    private func configureBrandedShareView() {
        let mockBetHistoryEntry = mockBetCreators[currentMockIndex]()
        let mockCountryCodes = MockDataFactory.createMockCountryCodes()
        let mockViewModel = MockDataFactory.createMockMyTicketCellViewModel(with: mockBetHistoryEntry)
        let mockWinBoost = MockDataFactory.createMockGrantedWinBoostInfo()
        
        brandedShareView.configure(
            withBetHistoryEntry: mockBetHistoryEntry,
            countryCodes: mockCountryCodes,
            viewModel: mockViewModel,
            grantedWinBoost: mockWinBoost
        )
        
        // Update title to show current bet type
        titleLabel.text = "BrandedTicketShareView Test\n\(mockBetTitles[currentMockIndex])"
    }
    
    // MARK: - Actions
    
    @objc private func didTapShareImage() {
        Logger.log("🔥 ShareTestViewController: Generating share image...")
        
        guard let shareImage = brandedShareView.generateShareImage() else {
            showAlert(title: "Error", message: "Failed to generate share image")
            return
        }
        
        Logger.log("✅ ShareTestViewController: Share image generated successfully - Size: \(shareImage.size)")
        
        let shareTitle = localized("partage_pari")
        
        let url = URL(string: TargetVariables.clientBaseUrl) ?? URL(string: "https://betsson.fr")!
        
        // Present activity controller with the generated image
        let activityViewController = UIActivityViewController(
            activityItems: [shareImage, shareTitle],
            applicationActivities: nil
        )
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = shareImageButton
            popoverController.sourceRect = shareImageButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func didTapSwitchData() {
        // Cycle to next mock bet type
        currentMockIndex = (currentMockIndex + 1) % mockBetCreators.count
        
        Logger.log("🔄 ShareTestViewController: Switching to \(mockBetTitles[currentMockIndex])")
        
        // Reconfigure with new data
        configureBrandedShareView()
    }
    
    @objc private func didTapClose() {
        Logger.log("🚪 ShareTestViewController: Closing test view")
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
        else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

#endif
