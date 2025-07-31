import UIKit
import Combine
import GomaUI

class TopBannerSliderViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let controlsContainer = UIView()
    private let slidersContainer = UIView()
    
    // Control elements
    private let sliderTypeSegmentedControl = UISegmentedControl(items: ["Default", "Single", "Auto-Scroll", "No Indicators", "Disabled"])
    private let autoScrollSwitch = UISwitch()
    private let autoScrollLabel = UILabel()
    private let pageIndicatorsSwitch = UISwitch()
    private let pageIndicatorsLabel = UILabel()
    private let userInteractionSwitch = UISwitch()
    private let userInteractionLabel = UILabel()
    private let currentPageLabel = UILabel()
    private let bannerCountLabel = UILabel()
    
    // Slider views
    private var currentSliderView: TopBannerSliderView?
    private var currentViewModel: MockTopBannerSliderViewModel?
    
    // State tracking
    private var currentDisplayState: TopBannerSliderDisplayState?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupInitialSlider()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
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
        
        // Setup sliders container
        setupSlidersContainer()
        
        // Add to stack view
        contentStackView.addArrangedSubview(controlsContainer)
        contentStackView.addArrangedSubview(slidersContainer)
        
        setupConstraints()
    }
    
    private func setupControlsContainer() {
        controlsContainer.backgroundColor = StyleProvider.Color.backgroundColor
        controlsContainer.layer.cornerRadius = 12
        controlsContainer.layer.borderWidth = 1
        controlsContainer.layer.borderColor = UIColor.separator.cgColor
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Slider Controls"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        // Slider type segmented control
        sliderTypeSegmentedControl.selectedSegmentIndex = 0
        sliderTypeSegmentedControl.addTarget(self, action: #selector(sliderTypeChanged), for: .valueChanged)
        
        // Auto-scroll controls
        autoScrollLabel.text = "Auto-Scroll"
        autoScrollLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        autoScrollLabel.textColor = StyleProvider.Color.textPrimary
        
        autoScrollSwitch.isOn = false
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollChanged), for: .valueChanged)
        
        let autoScrollStack = UIStackView(arrangedSubviews: [autoScrollLabel, autoScrollSwitch])
        autoScrollStack.axis = .horizontal
        autoScrollStack.spacing = 8
        autoScrollStack.alignment = .center
        
        // Page indicators controls
        pageIndicatorsLabel.text = "Page Indicators"
        pageIndicatorsLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        pageIndicatorsLabel.textColor = StyleProvider.Color.textPrimary
        
        pageIndicatorsSwitch.isOn = true
        pageIndicatorsSwitch.addTarget(self, action: #selector(pageIndicatorsChanged), for: .valueChanged)
        
        let pageIndicatorsStack = UIStackView(arrangedSubviews: [pageIndicatorsLabel, pageIndicatorsSwitch])
        pageIndicatorsStack.axis = .horizontal
        pageIndicatorsStack.spacing = 8
        pageIndicatorsStack.alignment = .center
        
        // User interaction controls
        userInteractionLabel.text = "User Interaction"
        userInteractionLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        userInteractionLabel.textColor = StyleProvider.Color.textPrimary
        
        userInteractionSwitch.isOn = true
        userInteractionSwitch.addTarget(self, action: #selector(userInteractionChanged), for: .valueChanged)
        
        let userInteractionStack = UIStackView(arrangedSubviews: [userInteractionLabel, userInteractionSwitch])
        userInteractionStack.axis = .horizontal
        userInteractionStack.spacing = 8
        userInteractionStack.alignment = .center
        
        // Status labels
        currentPageLabel.text = "Current Page: 0"
        currentPageLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        currentPageLabel.textColor = StyleProvider.Color.textSecondary
        
        bannerCountLabel.text = "Banner Count: 0"
        bannerCountLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        bannerCountLabel.textColor = StyleProvider.Color.textSecondary
        
        let statusStack = UIStackView(arrangedSubviews: [currentPageLabel, bannerCountLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 16
        statusStack.distribution = .fillEqually
        
        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            sliderTypeSegmentedControl,
            autoScrollStack,
            pageIndicatorsStack,
            userInteractionStack,
            statusStack
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
    
    private func setupSlidersContainer() {
        slidersContainer.backgroundColor = UIColor.clear
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
    
    private func setupInitialSlider() {
        showSlider(type: .default)
    }
    
    private func setupBindings() {
        guard let viewModel = currentViewModel else { return }
        
        // Subscribe to display state changes
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.currentDisplayState = displayState
                self?.updateStatusLabels(with: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Slider Management
    private enum SliderType {
        case `default`
        case single
        case autoScroll
        case noIndicators
        case disabled
    }
    
    private func showSlider(type: SliderType) {
        // Clear existing bindings
        cancellables.removeAll()
        
        // Remove existing slider
        currentSliderView?.removeFromSuperview()
        
        // Create new slider based on type
        let viewModel: MockTopBannerSliderViewModel
        
        switch type {
        case .default:
            viewModel = MockTopBannerSliderViewModel.defaultMock
        case .single:
            viewModel = MockTopBannerSliderViewModel.singleBannerMock
        case .autoScroll:
            viewModel = MockTopBannerSliderViewModel.autoScrollMock
        case .noIndicators:
            viewModel = MockTopBannerSliderViewModel.noIndicatorsMock
        case .disabled:
            viewModel = MockTopBannerSliderViewModel.disabledInteractionMock
        }
        
        currentViewModel = viewModel
        
        // Create slider view
        let sliderView = TopBannerSliderView(viewModel: viewModel)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle events
        sliderView.onBannerTapped = { [weak self] index in
            print("Banner at index \(index) was tapped")
            self?.showBannerTappedAlert(index: index)
        }
        
        sliderView.onPageChanged = { [weak self] pageIndex in
            print("Scrolled to page: \(pageIndex)")
            self?.updateCurrentPageLabel(pageIndex)
        }
        
        // Add to container
        slidersContainer.addSubview(sliderView)
        currentSliderView = sliderView
        
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: slidersContainer.topAnchor),
            sliderView.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: slidersContainer.trailingAnchor),
            sliderView.bottomAnchor.constraint(equalTo: slidersContainer.bottomAnchor),
            sliderView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Update controls based on slider type
        updateControlsForSliderType(type)
        
        // Setup bindings for the new view model
        setupBindings()
    }
    
    private func updateControlsForSliderType(_ type: SliderType) {
        // Update control states based on slider type
        switch type {
        case .autoScroll:
            autoScrollSwitch.isOn = true
            autoScrollSwitch.isEnabled = true
            autoScrollLabel.textColor = StyleProvider.Color.textPrimary
        case .disabled:
            userInteractionSwitch.isOn = false
            userInteractionSwitch.isEnabled = true
            userInteractionLabel.textColor = StyleProvider.Color.textPrimary
        case .noIndicators:
            pageIndicatorsSwitch.isOn = false
            pageIndicatorsSwitch.isEnabled = true
            pageIndicatorsLabel.textColor = StyleProvider.Color.textPrimary
        case .single:
            // Single banner - page indicators automatically hidden
            pageIndicatorsSwitch.isEnabled = false
            pageIndicatorsLabel.textColor = StyleProvider.Color.textPrimary.withAlphaComponent(0.5)
        default:
            // Reset all controls to default state
            autoScrollSwitch.isOn = false
            autoScrollSwitch.isEnabled = true
            autoScrollLabel.textColor = StyleProvider.Color.textPrimary
            
            pageIndicatorsSwitch.isOn = true
            pageIndicatorsSwitch.isEnabled = true
            pageIndicatorsLabel.textColor = StyleProvider.Color.textPrimary
            
            userInteractionSwitch.isOn = true
            userInteractionSwitch.isEnabled = true
            userInteractionLabel.textColor = StyleProvider.Color.textPrimary
        }
    }
    
    private func updateStatusLabels(with displayState: TopBannerSliderDisplayState) {
        let bannerCount = displayState.sliderData.bannerViewFactories.count
        let currentPage = displayState.sliderData.currentPageIndex
        
        bannerCountLabel.text = "Banner Count: \(bannerCount)"
        currentPageLabel.text = "Current Page: \(currentPage)"
    }
    
    private func updateCurrentPageLabel(_ pageIndex: Int) {
        currentPageLabel.text = "Current Page: \(pageIndex)"
    }
    
    private func showBannerTappedAlert(index: Int) {
        let alert = UIAlertController(
            title: "Banner Tapped",
            message: "You tapped banner at index \(index)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func sliderTypeChanged() {
        let selectedIndex = sliderTypeSegmentedControl.selectedSegmentIndex
        let sliderType: SliderType
        
        switch selectedIndex {
        case 0: sliderType = .default
        case 1: sliderType = .single
        case 2: sliderType = .autoScroll
        case 3: sliderType = .noIndicators
        case 4: sliderType = .disabled
        default: sliderType = .default
        }
        
        showSlider(type: sliderType)
    }
    
    @objc private func autoScrollChanged() {
        guard let viewModel = currentViewModel,
              let currentState = currentDisplayState else { return }
        
        let newSliderData = TopBannerSliderData(
            bannerViewFactories: currentState.sliderData.bannerViewFactories,
            isAutoScrollEnabled: autoScrollSwitch.isOn,
            autoScrollInterval: currentState.sliderData.autoScrollInterval,
            showPageIndicators: currentState.sliderData.showPageIndicators,
            currentPageIndex: currentState.sliderData.currentPageIndex
        )
        
        viewModel.updateSliderData(newSliderData)
        
        if autoScrollSwitch.isOn {
            currentSliderView?.startAutoScroll()
        } else {
            currentSliderView?.stopAutoScroll()
        }
    }
    
    @objc private func pageIndicatorsChanged() {
        guard let viewModel = currentViewModel,
              let currentState = currentDisplayState else { return }
        
        let newSliderData = TopBannerSliderData(
            bannerViewFactories: currentState.sliderData.bannerViewFactories,
            isAutoScrollEnabled: currentState.sliderData.isAutoScrollEnabled,
            autoScrollInterval: currentState.sliderData.autoScrollInterval,
            showPageIndicators: pageIndicatorsSwitch.isOn,
            currentPageIndex: currentState.sliderData.currentPageIndex
        )
        
        viewModel.updateSliderData(newSliderData)
    }
    
    @objc private func userInteractionChanged() {
        guard let viewModel = currentViewModel else { return }
        
        viewModel.updateUserInteraction(userInteractionSwitch.isOn)
    }
} 
