import UIKit
import GomaUI
import Combine

class EmptyStateActionViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var viewModels: [MockEmptyStateActionViewModel] = []
    private var emptyStateViews: [EmptyStateActionView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupEmptyStateViews()
        setupControlsSection()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Empty State Action"
        
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
    
    private func setupEmptyStateViews() {
        // Create various empty state configurations showcasing different scenarios
        let emptyStateConfigurations: [(String, MockEmptyStateActionViewModel)] = [
            ("Logged Out - Default Betslip", MockEmptyStateActionViewModel.loggedOutMock()),
            ("Logged In - Default Betslip", MockEmptyStateActionViewModel.loggedInMock()),
            ("Disabled State", MockEmptyStateActionViewModel.disabledMock()),
            ("No Search Results", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "No matches found\nTry adjusting your search criteria",
                actionButtonTitle: "Browse All Sports",
                image: "magnifyingglass",
                isEnabled: true
            )),
            ("No Favorites Yet", MockEmptyStateActionViewModel(
                state: .loggedOut,
                title: "No favorites saved yet\nStart adding your favorite teams and matches",
                actionButtonTitle: "Log in to save favorites",
                image: "heart",
                isEnabled: true
            )),
            ("No Bet History", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "No bets placed yet\nYour betting history will appear here",
                actionButtonTitle: "Start Betting",
                image: "clock.arrow.circlepath",
                isEnabled: true
            )),
            ("No Live Matches", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "No live matches available\nCheck back later for live betting",
                actionButtonTitle: "View Upcoming Matches",
                image: "tv",
                isEnabled: true
            )),
            ("Connection Error", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "Unable to load content\nPlease check your internet connection",
                actionButtonTitle: "Try Again",
                image: "wifi.slash",
                isEnabled: true
            )),
            ("Service Maintenance", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "Service temporarily unavailable\nWe're performing scheduled maintenance",
                actionButtonTitle: "Check Status",
                image: "wrench.and.screwdriver",
                isEnabled: false
            )),
            ("No Notifications", MockEmptyStateActionViewModel(
                state: .loggedIn,
                title: "No new notifications\nWe'll notify you about important updates",
                actionButtonTitle: "Manage Notifications",
                image: "bell.slash",
                isEnabled: true
            )),
            ("Account Verification Needed", MockEmptyStateActionViewModel(
                state: .loggedOut,
                title: "Account verification required\nComplete your profile to start betting",
                actionButtonTitle: "Verify Account",
                image: "person.badge.shield.checkmark",
                isEnabled: true
            )),
            ("Age Verification", MockEmptyStateActionViewModel(
                state: .loggedOut,
                title: "Age verification required\nYou must be 18+ to access betting features",
                actionButtonTitle: "Verify Age",
                image: "calendar.badge.exclamationmark",
                isEnabled: true
            ))
        ]
        
        for (title, viewModel) in emptyStateConfigurations {
            // Add section label
            let sectionLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(sectionLabel)
            
            // Create empty state view
            let emptyStateView = EmptyStateActionView(viewModel: viewModel)
            emptyStateView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container for proper spacing and visual separation
            let containerView = createEmptyStateContainer()
            containerView.addSubview(emptyStateView)
            
            NSLayoutConstraint.activate([
                emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                emptyStateView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
            
            stackView.addArrangedSubview(containerView)
            emptyStateViews.append(emptyStateView)
            viewModels.append(viewModel)
        }
        
        // Add interactive demo section
        addInteractiveDemoSection()
    }
    
    private func addInteractiveDemoSection() {
        // Add spacing
        let spacer = createSpacer(height: 24)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let sectionTitle = createSectionTitle(with: "Interactive Demo")
        stackView.addArrangedSubview(sectionTitle)
        
        // Add description
        let descriptionLabel = createSubDescriptionLabel()
        stackView.addArrangedSubview(descriptionLabel)
        
        // Create interactive demo view
        let interactiveViewModel = MockEmptyStateActionViewModel(
            state: .loggedOut,
            title: "Interactive Demo State\nUse controls below to test different states",
            actionButtonTitle: "Demo Action",
            image: "wand.and.stars",
            isEnabled: true
        )
        
        // Add action callback for demo purposes
        interactiveViewModel.onActionButtonTapped = { [weak self] in
            self?.showActionFeedback(for: interactiveViewModel)
        }
        
        let interactiveView = EmptyStateActionView(viewModel: interactiveViewModel)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let interactiveContainer = createEmptyStateContainer()
        interactiveContainer.addSubview(interactiveView)
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor, constant: 16),
            interactiveView.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor, constant: -16),
            interactiveView.topAnchor.constraint(equalTo: interactiveContainer.topAnchor, constant: 16),
            interactiveView.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(interactiveContainer)
        
        // Store for controls
        emptyStateViews.append(interactiveView)
        viewModels.append(interactiveViewModel)
    }
    
    private func setupControlsSection() {
        // Add spacing
        let spacer = createSpacer(height: 24)
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
        
        let toggleStateButton = createControlButton(title: "Toggle Login State", action: #selector(toggleLoginState))
        let enableButton = createControlButton(title: "Enable Action", action: #selector(enableAction))
        let disableButton = createControlButton(title: "Disable Action", action: #selector(disableAction))
        let changeTitleButton = createControlButton(title: "Change Title", action: #selector(changeTitle))
        let changeActionButton = createControlButton(title: "Change Action Title", action: #selector(changeActionTitle))
        let changeIconButton = createControlButton(title: "Change Icon", action: #selector(changeIcon))
        let removeIconButton = createControlButton(title: "Remove Icon", action: #selector(removeIcon))
        let simulateTapButton = createControlButton(title: "Simulate Tap", action: #selector(simulateTap))
        let testLoadingFlowButton = createControlButton(title: "Test Loading Flow", action: #selector(testLoadingFlow))
        let resetToDefaultButton = createControlButton(title: "Reset to Default", action: #selector(resetToDefault))
        
        buttonStackView.addArrangedSubview(toggleStateButton)
        buttonStackView.addArrangedSubview(enableButton)
        buttonStackView.addArrangedSubview(disableButton)
        buttonStackView.addArrangedSubview(changeTitleButton)
        buttonStackView.addArrangedSubview(changeActionButton)
        buttonStackView.addArrangedSubview(changeIconButton)
        buttonStackView.addArrangedSubview(removeIconButton)
        buttonStackView.addArrangedSubview(simulateTapButton)
        buttonStackView.addArrangedSubview(testLoadingFlowButton)
        buttonStackView.addArrangedSubview(resetToDefaultButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Add state observation section
        addStateObservationSection()
        
        // Add empty state patterns demo section
        addEmptyStatePatternsDemo()
    }
    
    private func addStateObservationSection() {
        // Add spacing
        let spacer = createSpacer(height: 24)
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
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -16),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -16)
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
    
    private func addEmptyStatePatternsDemo() {
        // Add spacing
        let spacer = createSpacer(height: 24)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let patternsTitle = createSectionTitle(with: "Empty State Patterns")
        stackView.addArrangedSubview(patternsTitle)
        
        // Add patterns description
        let patternsDescription = UILabel()
        patternsDescription.text = "Common empty state patterns used in sports betting applications:"
        patternsDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        patternsDescription.textColor = StyleProvider.Color.highlightSecondary
        patternsDescription.numberOfLines = 0
        stackView.addArrangedSubview(patternsDescription)
        
        // Create different pattern examples
        let emptyStatePatterns: [(String, String, String, String?)] = [
            ("First Time User", "Welcome to Sports Betting", "Get Started", "hand.wave"),
            ("Empty Cart", "Your betslip is empty", "Browse Sports", "cart.badge.plus"),
            ("No Internet", "You're offline", "Retry", "wifi.exclamationmark"),
            ("Location Restricted", "Service unavailable in your area", "Learn More", "location.slash"),
            ("Account Suspended", "Account temporarily suspended", "Contact Support", "person.crop.circle.badge.exclamationmark"),
            ("Insufficient Balance", "Insufficient funds to place bet", "Add Funds", "creditcard.circle"),
            ("Bet Limits Reached", "Daily betting limit reached", "View Limits", "exclamationmark.triangle"),
            ("Game Unavailable", "This game is currently unavailable", "Browse Other Games", "gamecontroller.fill"),
            ("Maintenance Mode", "Scheduled maintenance in progress", "Check Updates", "hammer.circle"),
            ("Session Expired", "Your session has expired", "Log In Again", "clock.badge.exclamationmark")
        ]
        
        for (category, title, actionTitle, icon) in emptyStatePatterns {
            // Add pattern category label
            let categoryLabel = createSectionLabel(with: category)
            stackView.addArrangedSubview(categoryLabel)
            
            // Create pattern example
            let patternViewModel = MockEmptyStateActionViewModel(
                state: .loggedOut,
                title: title,
                actionButtonTitle: actionTitle,
                image: icon,
                isEnabled: true
            )
            
            // Add tap callback for demonstration
            patternViewModel.onActionButtonTapped = { [weak self] in
                self?.showActionFeedback(for: patternViewModel, actionTitle: actionTitle)
            }
            
            let patternView = EmptyStateActionView(viewModel: patternViewModel)
            patternView.translatesAutoresizingMaskIntoConstraints = false
            
            let patternContainer = createEmptyStateContainer()
            patternContainer.addSubview(patternView)
            
            NSLayoutConstraint.activate([
                patternView.leadingAnchor.constraint(equalTo: patternContainer.leadingAnchor, constant: 16),
                patternView.trailingAnchor.constraint(equalTo: patternContainer.trailingAnchor, constant: -16),
                patternView.topAnchor.constraint(equalTo: patternContainer.topAnchor, constant: 16),
                patternView.bottomAnchor.constraint(equalTo: patternContainer.bottomAnchor, constant: -16)
            ])
            
            stackView.addArrangedSubview(patternContainer)
            
            emptyStateViews.append(patternView)
            viewModels.append(patternViewModel)
        }
    }
    
    // MARK: - Event Handlers
    @objc private func toggleLoginState() {
        guard let interactiveViewModel = viewModels.last else { return }
        let currentState = interactiveViewModel.currentData.state
        let newState: EmptyStateActionState = currentState == .loggedOut ? .loggedIn : .loggedOut
        interactiveViewModel.updateState(newState)
        
        // Update action button title based on state
        let newActionTitle = newState == .loggedOut ? "Log In to Continue" : "Continue"
        interactiveViewModel.updateActionButtonTitle(newActionTitle)
    }
    
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
            "Interactive Demo State\nUse controls below to test different states",
            "Title Changed Successfully\nThis demonstrates dynamic title updates",
            "Another Title Example\nTitles can be multi-line and informative",
            "Short Title",
            "Very Long Title Example That Shows How The Component Handles Extended Text Content That May Wrap To Multiple Lines",
            "Empty State Demo\nTesting various scenarios and states"
        ]
        
        // Find current title and get next one
        let currentTitle = interactiveViewModel.currentData.title
        let currentIndex = titles.firstIndex(of: currentTitle) ?? 0
        let nextIndex = (currentIndex + 1) % titles.count
        let nextTitle = titles[nextIndex]
        
        interactiveViewModel.updateTitle(nextTitle)
    }
    
    @objc private func changeActionTitle() {
        guard let interactiveViewModel = viewModels.last else { return }
        let actionTitles = [
            "Demo Action",
            "Get Started",
            "Try Now",
            "Continue",
            "Learn More",
            "Start Betting",
            "Sign Up",
            "Reload",
            "Browse",
            "Contact Support"
        ]
        
        // Get current action title and select next one
        let currentActionTitle = interactiveViewModel.currentData.actionButtonTitle
        let currentIndex = actionTitles.firstIndex(of: currentActionTitle) ?? 0
        let nextIndex = (currentIndex + 1) % actionTitles.count
        let nextActionTitle = actionTitles[nextIndex]
        
        interactiveViewModel.updateActionButtonTitle(nextActionTitle)
    }
    
    @objc private func changeIcon() {
        guard let interactiveViewModel = viewModels.last else { return }
        let icons = [
            "wand.and.stars",
            "star.fill",
            "heart.fill",
            "bookmark.fill",
            "flag.fill",
            "crown.fill",
            "diamond.fill",
            "flame.fill",
            "bolt.fill",
            "sparkles",
            "gift.fill",
            "trophy.fill",
            "medal.fill",
            "target",
            "gamecontroller.fill"
        ]
        
        // Get current icon and select next one
        let currentIcon = interactiveViewModel.currentData.image
        let currentIndex = icons.firstIndex(of: currentIcon ?? "") ?? 0
        let nextIndex = (currentIndex + 1) % icons.count
        let nextIcon = icons[nextIndex]
        
        interactiveViewModel.updateImage(nextIcon)
    }
    
    @objc private func removeIcon() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateImage(nil)
    }
    
    @objc private func simulateTap() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.onActionButtonTapped?()
    }
    
    @objc private func testLoadingFlow() {
        guard let interactiveViewModel = viewModels.last else { return }
        
        // Simulate a loading flow with state changes
        interactiveViewModel.updateTitle("Loading...")
        interactiveViewModel.updateActionButtonTitle("Please wait")
        interactiveViewModel.updateImage("hourglass")
        interactiveViewModel.setEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            interactiveViewModel.updateTitle("Loading Complete!")
            interactiveViewModel.updateActionButtonTitle("Success")
            interactiveViewModel.updateImage("checkmark.circle.fill")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            interactiveViewModel.setEnabled(true)
            interactiveViewModel.updateActionButtonTitle("Try Again")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let alert = UIAlertController(
                title: "Loading Flow Complete",
                message: "The empty state has completed its loading simulation!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc private func resetToDefault() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateState(.loggedOut)
        interactiveViewModel.updateTitle("Interactive Demo State\nUse controls below to test different states")
        interactiveViewModel.updateActionButtonTitle("Demo Action")
        interactiveViewModel.updateImage("wand.and.stars")
        interactiveViewModel.setEnabled(true)
    }
    
    private func showActionFeedback(for viewModel: MockEmptyStateActionViewModel, actionTitle: String? = nil) {
        let title = actionTitle ?? viewModel.currentData.actionButtonTitle
        let message = "Action '\(title)' was tapped!"
        
        let alert = UIAlertController(
            title: "Empty State Action",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateStateObservation(with data: EmptyStateActionData) {
        guard let statusLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        let stateText = data.state == .loggedOut ? "LOGGED OUT" : "LOGGED IN"
        let enabledText = data.isEnabled ? "ENABLED" : "DISABLED"
        let iconText = data.image ?? "None"
        
        statusLabel.text = """
        State: \(stateText)
        Title: "\(data.title.replacingOccurrences(of: "\n", with: " "))"
        Action: "\(data.actionButtonTitle)"
        Icon: \(iconText)
        Status: \(enabledText)
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
extension EmptyStateActionViewController {
    
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
        label.text = "EmptyStateActionView component for displaying empty states with images, titles, and optional action buttons. Features different states (logged in/out), customizable content, enabled/disabled modes, and proper styling using StyleProvider. Perfect for betslips, search results, favorites, bet history, and various empty content scenarios."
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
        label.text = "Tap the action button to see interaction feedback, or use the controls below to modify its state:"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.highlightSecondary
        label.numberOfLines = 0
        return label
    }
    
    private func createEmptyStateContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.2).cgColor
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
