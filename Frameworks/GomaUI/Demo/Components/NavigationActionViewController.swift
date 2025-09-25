import UIKit
import GomaUI
import Combine

class NavigationActionViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var viewModels: [MockNavigationActionViewModel] = []
    private var navigationActionViews: [NavigationActionView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationActionViews()
        setupControlsSection()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Navigation Action"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        initConstraints()
        
        // Add description
        let descriptionLabel = createDescriptionLabel()
        stackView.addArrangedSubview(descriptionLabel)
        
        // Add separator
        let separator = createSeparator()
        stackView.addArrangedSubview(separator)
    }
    
    private func setupNavigationActionViews() {
        // Create various navigation action configurations showcasing different states
        let actionConfigurations: [(String, MockNavigationActionViewModel)] = [
            ("Open Betslip Details (Default)", MockNavigationActionViewModel.openBetslipDetailsMock()),
            ("Share Betslip", MockNavigationActionViewModel.shareBetslipMock()),
            ("Disabled State", MockNavigationActionViewModel.disabledMock()),
            ("Custom Action (Settings)", MockNavigationActionViewModel(
                title: "Account Settings",
                icon: "gearshape.fill",
                isEnabled: true
            )),
            ("Navigation with Arrow", MockNavigationActionViewModel(
                title: "View Bet History",
                icon: "chevron.forward",
                isEnabled: true
            )),
            ("Action without Icon", MockNavigationActionViewModel(
                title: "Continue to Payment",
                icon: nil,
                isEnabled: true
            ))
        ]
        
        for (title, viewModel) in actionConfigurations {
            // Add section label
            let sectionLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(sectionLabel)
            
            // Create navigation action view
            let navigationActionView = NavigationActionView(viewModel: viewModel)
            navigationActionView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container for proper spacing and visual separation
            let containerView = createActionContainer()
            containerView.addSubview(navigationActionView)
            
            NSLayoutConstraint.activate([
                navigationActionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                navigationActionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                navigationActionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                navigationActionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
            
            stackView.addArrangedSubview(containerView)
            navigationActionViews.append(navigationActionView)
            viewModels.append(viewModel)
        }
        
        // Add interactive demo section
        addInteractiveDemoSection()
    }
    
    private func addInteractiveDemoSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let sectionTitle = createSectionTitle(with: "Interactive Demo")
        stackView.addArrangedSubview(sectionTitle)
        
        // Add description
        let descriptionLabel = createSubDescriptionLabel()
        stackView.addArrangedSubview(descriptionLabel)
        
        // Create interactive demo view
        let interactiveViewModel = MockNavigationActionViewModel(
            title: "Interactive Demo Action",
            icon: "star.fill",
            isEnabled: true
        )
        
        let interactiveView = NavigationActionView(viewModel: interactiveViewModel)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let interactiveContainer = createActionContainer()
        interactiveContainer.addSubview(interactiveView)
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor, constant: 12),
            interactiveView.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor, constant: -12),
            interactiveView.topAnchor.constraint(equalTo: interactiveContainer.topAnchor, constant: 12),
            interactiveView.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(interactiveContainer)
        
        // Store for controls
        navigationActionViews.append(interactiveView)
        viewModels.append(interactiveViewModel)
    }
    
    private func setupControlsSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let controlsTitle = createSectionTitle(with: "State Controls")
        stackView.addArrangedSubview(controlsTitle)
        
        // Add controls description
        let controlsDescription = UILabel()
        controlsDescription.text = "Test different states and interactions on the interactive demo above:"
        controlsDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        controlsDescription.textColor = StyleProvider.Color.highlightSecondary
        controlsDescription.numberOfLines = 0
        stackView.addArrangedSubview(controlsDescription)
        
        // Add control buttons
        let buttonStackView = createButtonStackView()
        
        let enableButton = createControlButton(title: "Enable Action", action: #selector(enableAction))
        let disableButton = createControlButton(title: "Disable Action", action: #selector(disableAction))
        let changeTitleButton = createControlButton(title: "Change Title", action: #selector(changeTitle))
        let changeIconButton = createControlButton(title: "Change Icon", action: #selector(changeIcon))
        let removeIconButton = createControlButton(title: "Remove Icon", action: #selector(removeIcon))
        let simulateTapButton = createControlButton(title: "Simulate Tap", action: #selector(simulateTap))
        let testNavigationFlowButton = createControlButton(title: "Test Navigation Flow", action: #selector(testNavigationFlow))
        let resetToDefaultButton = createControlButton(title: "Reset to Default", action: #selector(resetToDefault))
        
        buttonStackView.addArrangedSubview(enableButton)
        buttonStackView.addArrangedSubview(disableButton)
        buttonStackView.addArrangedSubview(changeTitleButton)
        buttonStackView.addArrangedSubview(changeIconButton)
        buttonStackView.addArrangedSubview(removeIconButton)
        buttonStackView.addArrangedSubview(simulateTapButton)
        buttonStackView.addArrangedSubview(testNavigationFlowButton)
        buttonStackView.addArrangedSubview(resetToDefaultButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Add state observation section
        addStateObservationSection()
        
        // Add navigation patterns demo section
        addNavigationPatternsDemo()
    }
    
    private func addStateObservationSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let observationTitle = createSectionTitle(with: "State Observation")
        stackView.addArrangedSubview(observationTitle)
        
        // Add status label
        let statusLabel = UILabel()
        statusLabel.tag = 999 // For easy reference
        statusLabel.text = "Watching interactive demo state changes..."
        statusLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        statusLabel.textColor = StyleProvider.Color.highlightSecondary
        statusLabel.numberOfLines = 0
        statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center
        
        // Add padding to status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        let statusContainer = UIView()
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(statusContainer)
        
        // Setup state observation for the last (interactive) view model
        if let interactiveViewModel = viewModels.last {
            interactiveViewModel.dataPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.updateStateObservation(with: data)
                }
                .store(in: &cancellables)
        }
    }
    
    private func addNavigationPatternsDemo() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let patternsTitle = createSectionTitle(with: "Navigation Patterns")
        stackView.addArrangedSubview(patternsTitle)
        
        // Add patterns description
        let patternsDescription = UILabel()
        patternsDescription.text = "Common navigation patterns used in sports betting applications:"
        patternsDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        patternsDescription.textColor = StyleProvider.Color.highlightSecondary
        patternsDescription.numberOfLines = 0
        stackView.addArrangedSubview(patternsDescription)
        
        // Create different pattern examples
        let navigationPatterns: [(String, String, String?)] = [
            ("Betslip Actions", "Open Betslip Details", "list.bullet.clipboard"),
            ("Sharing", "Share Your Bet", "square.and.arrow.up"),
            ("Profile Navigation", "View Account", "person.circle"),
            ("Settings Access", "Betting Preferences", "slider.horizontal.3"),
            ("Help & Support", "Get Help", "questionmark.circle"),
            ("Quick Actions", "Place Quick Bet", "bolt.fill"),
            ("History Review", "View Bet History", "clock.arrow.circlepath"),
            ("Payment Flow", "Add Payment Method", "creditcard"),
            ("Notifications", "Manage Alerts", "bell"),
            ("Promotions", "View Offers", "gift")
        ]
        
        for (category, title, icon) in navigationPatterns {
            // Add pattern category label
            let categoryLabel = createSectionLabel(with: category)
            stackView.addArrangedSubview(categoryLabel)
            
            // Create pattern example
            let patternViewModel = MockNavigationActionViewModel(
                title: title,
                icon: icon,
                isEnabled: true
            )
            
            let patternView = NavigationActionView(viewModel: patternViewModel)
            patternView.translatesAutoresizingMaskIntoConstraints = false
            
            let patternContainer = createActionContainer()
            patternContainer.addSubview(patternView)
            
            NSLayoutConstraint.activate([
                patternView.leadingAnchor.constraint(equalTo: patternContainer.leadingAnchor, constant: 12),
                patternView.trailingAnchor.constraint(equalTo: patternContainer.trailingAnchor, constant: -12),
                patternView.topAnchor.constraint(equalTo: patternContainer.topAnchor, constant: 12),
                patternView.bottomAnchor.constraint(equalTo: patternContainer.bottomAnchor, constant: -12)
            ])
            
            stackView.addArrangedSubview(patternContainer)
            
            navigationActionViews.append(patternView)
            viewModels.append(patternViewModel)
        }
    }
    
    // MARK: - Event Handlers
    @objc private func enableAction() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setEnabled(true)
    }
    
    @objc private func disableAction() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setEnabled(false)
    }
    
    @objc private func changeTitle() {
        guard let interactiveViewModel = viewModels.last else { return }
        let titles = [
            "Interactive Demo Action",
            "Updated Action Title",
            "New Navigation Option",
            "Modified Demo Action",
            "Test Action Button"
        ]
        
        // Find current title and get next one
        let currentTitle = interactiveViewModel.currentData.title
        let currentIndex = titles.firstIndex(of: currentTitle) ?? 0
        let nextIndex = (currentIndex + 1) % titles.count
        let nextTitle = titles[nextIndex]
        
        interactiveViewModel.updateTitle(nextTitle)
    }
    
    @objc private func changeIcon() {
        guard let interactiveViewModel = viewModels.last else { return }
        let icons = [
            "star.fill",
            "heart.fill",
            "bookmark.fill",
            "flag.fill",
            "crown.fill",
            "diamond.fill",
            "flame.fill",
            "bolt.fill"
        ]
        
        // Get current icon and select next one
        let currentIcon = interactiveViewModel.currentData.icon
        let currentIndex = icons.firstIndex(of: currentIcon ?? "") ?? 0
        let nextIndex = (currentIndex + 1) % icons.count
        let nextIcon = icons[nextIndex]
        
        interactiveViewModel.updateIcon(nextIcon)
    }
    
    @objc private func removeIcon() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateIcon(nil)
    }
    
    @objc private func simulateTap() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.onNavigationTapped()
        
        // Show visual feedback
        let alert = UIAlertController(
            title: "Navigation Action Tapped",
            message: "Action: \"\(interactiveViewModel.currentData.title)\" was tapped!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func testNavigationFlow() {
        guard let interactiveViewModel = viewModels.last else { return }
        
        // Simulate a navigation flow with state changes
        interactiveViewModel.updateTitle("Processing...")
        interactiveViewModel.setEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            interactiveViewModel.updateTitle("Navigation Ready")
            interactiveViewModel.updateIcon("checkmark.circle.fill")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            interactiveViewModel.setEnabled(true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let alert = UIAlertController(
                title: "Navigation Flow Complete",
                message: "The action is now ready for interaction!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc private func resetToDefault() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateTitle("Interactive Demo Action")
        interactiveViewModel.updateIcon("star.fill")
        interactiveViewModel.setEnabled(true)
    }
    
    private func updateStateObservation(with data: NavigationActionData) {
        guard let statusLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        let enabledText = data.isEnabled ? "ENABLED" : "DISABLED"
        let iconText = data.icon ?? "None"
        
        statusLabel.text = """
        Title: "\(data.title)"
        Icon: \(iconText)
        State: \(enabledText)
        """
        
        // Update color based on state
        if data.isEnabled {
            statusLabel.textColor = StyleProvider.Color.textPrimary
            statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        } else {
            statusLabel.textColor = StyleProvider.Color.highlightSecondary
            statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary.withAlphaComponent(0.5)
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension NavigationActionViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = "NavigationActionView component for creating navigation actions with titles, icons, and interaction states. Features tap handling, enabled/disabled states, customizable icons, and proper styling using StyleProvider. Perfect for betslip actions, sharing, settings access, and other navigation flows."
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.highlightSecondary
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func createSectionLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.highlightSecondary
        return label
    }
    
    private func createSectionTitle(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }
    
    private func createSubDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = "Tap the action to see interaction feedback, or use the controls below to modify its state:"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.highlightSecondary
        label.numberOfLines = 0
        return label
    }
    
    private func createActionContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    private func createButtonStackView() -> UIStackView {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        return buttonStackView
    }
    
    private func createControlButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 14)
        button.backgroundColor = StyleProvider.Color.backgroundPrimary
        button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return button
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
