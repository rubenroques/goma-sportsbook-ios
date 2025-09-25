import UIKit
import Combine
import GomaUI

class SingleButtonBannerViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let controlsContainer = UIView()
    private let bannersContainer = UIView()
    
    // Control elements
    private let segmentedControl = UISegmentedControl(items: ["Default", "No Button", "Custom Style", "Disabled"])
    private let visibilitySwitch = UISwitch()
    private let visibilityLabel = UILabel()
    private let enabledSwitch = UISwitch()
    private let enabledLabel = UILabel()
    
    // Banner views
    private var currentBannerView: SingleButtonBannerView?
    private var currentViewModel: MockSingleButtonBannerViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupInitialBanner()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        // Setup controls container
        setupControlsContainer()
        
        // Setup banners container
        setupBannersContainer()
        
        // Add to stack view
        contentStackView.addArrangedSubview(controlsContainer)
        contentStackView.addArrangedSubview(bannersContainer)
        
        setupConstraints()
    }
    
    private func setupControlsContainer() {
        controlsContainer.backgroundColor = StyleProvider.Color.backgroundPrimary
        controlsContainer.layer.cornerRadius = 12
        controlsContainer.layer.borderWidth = 1
        controlsContainer.layer.borderColor = UIColor.separator.cgColor
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Banner Controls"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(bannerTypeChanged), for: .valueChanged)
        
        // Visibility controls
        visibilityLabel.text = "Visible"
        visibilityLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        visibilityLabel.textColor = StyleProvider.Color.textPrimary
        
        visibilitySwitch.isOn = true
        visibilitySwitch.addTarget(self, action: #selector(visibilityChanged), for: .valueChanged)
        
        let visibilityStack = UIStackView(arrangedSubviews: [visibilityLabel, visibilitySwitch])
        visibilityStack.axis = .horizontal
        visibilityStack.spacing = 8
        visibilityStack.alignment = .center
        
        // Enabled controls
        enabledLabel.text = "Button Enabled"
        enabledLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        enabledLabel.textColor = StyleProvider.Color.textPrimary
        
        enabledSwitch.isOn = true
        enabledSwitch.addTarget(self, action: #selector(enabledChanged), for: .valueChanged)
        
        let enabledStack = UIStackView(arrangedSubviews: [enabledLabel, enabledSwitch])
        enabledStack.axis = .horizontal
        enabledStack.spacing = 8
        enabledStack.alignment = .center
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            segmentedControl,
            visibilityStack,
            enabledStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        controlsContainer.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBannersContainer() {
        bannersContainer.backgroundColor = UIColor.clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupInitialBanner() {
        showBanner(type: .default)
    }
    
    private func setupBindings() {
        // No additional bindings needed for this demo
    }
    
    // MARK: - Banner Management
    private enum BannerType {
        case `default`
        case noButton
        case customStyle
        case disabled
    }
    
    private func showBanner(type: BannerType) {
        // Remove existing banner
        currentBannerView?.removeFromSuperview()
        
        // Create new banner based on type
        let viewModel: MockSingleButtonBannerViewModel
        
        switch type {
        case .default:
            viewModel = MockSingleButtonBannerViewModel.defaultMock
        case .noButton:
            viewModel = MockSingleButtonBannerViewModel.noButtonMock
        case .customStyle:
            viewModel = MockSingleButtonBannerViewModel.customStyledMock
        case .disabled:
            viewModel = MockSingleButtonBannerViewModel.disabledMock
        }
        
        currentViewModel = viewModel
        
        // Create banner view
        let bannerView = SingleButtonBannerView(viewModel: viewModel)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle button taps
        bannerView.onButtonTapped = {
            print("Banner Button Tapped")
        }
        
        // Add to container
        bannersContainer.addSubview(bannerView)
        currentBannerView = bannerView
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: bannersContainer.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: bannersContainer.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: bannersContainer.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bannersContainer.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Update controls based on banner type
        updateControlsForBannerType(type)
    }
    
    private func updateControlsForBannerType(_ type: BannerType) {
        // Update enabled switch availability based on banner type
        switch type {
        case .noButton:
            enabledSwitch.isEnabled = false
            enabledLabel.textColor = StyleProvider.Color.textPrimary.withAlphaComponent(0.5)
        default:
            enabledSwitch.isEnabled = true
            enabledLabel.textColor = StyleProvider.Color.textPrimary
        }
    }
    
    
    // MARK: - Actions
    @objc private func bannerTypeChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let bannerType: BannerType
        
        switch selectedIndex {
        case 0: bannerType = .default
        case 1: bannerType = .noButton
        case 2: bannerType = .customStyle
        case 3: bannerType = .disabled
        default: bannerType = .default
        }
        
        showBanner(type: bannerType)
    }
    
    @objc private func visibilityChanged() {
        // For visibility, we would typically update the view model
        // For this demo, we'll just hide/show the banner view
        currentBannerView?.isHidden = !visibilitySwitch.isOn
    }
    
    @objc private func enabledChanged() {
        currentViewModel?.updateButtonEnabled(enabledSwitch.isOn)
    }
} 
