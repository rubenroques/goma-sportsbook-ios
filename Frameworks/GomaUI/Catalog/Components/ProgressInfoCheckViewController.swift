import UIKit
import GomaUI
import Combine

class ProgressInfoCheckViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var viewModels: [MockProgressInfoCheckViewModel] = []
    private var progressInfoViews: [ProgressInfoCheckView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupProgressInfoViews()
        setupControlsSection()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Progress Info Check"
        
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
    
    private func setupProgressInfoViews() {
        // Create various progress info check configurations showcasing different scenarios
        let progressConfigurations: [(String, MockProgressInfoCheckViewModel)] = [
            ("Win Boost Progress (Default)", MockProgressInfoCheckViewModel.winBoostMock()),
            ("Completed State", MockProgressInfoCheckViewModel.completeMock()),
            ("Disabled State", MockProgressInfoCheckViewModel.disabledMock()),
            ("KYC Verification Progress", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 2, totalSegments: 4),
                headerText: "Account Verification",
                title: "Complete Your Profile",
                subtitle: "2 of 4 verification steps completed. Upload documents to continue.",
                icon: "person.badge.shield.checkmark",
                isEnabled: true
            )),
            ("Document Upload Flow", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 1, totalSegments: 3),
                headerText: "Document Upload",
                title: "Upload Required Documents",
                subtitle: "Identity verification in progress. 1 of 3 documents uploaded.",
                icon: "doc.badge.plus",
                isEnabled: true
            )),
            ("Account Setup Progress", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 3, totalSegments: 5),
                headerText: "Getting Started",
                title: "Almost Ready to Bet",
                subtitle: "Complete your account setup to start placing bets.",
                icon: "checkmark.circle.badge",
                isEnabled: true
            )),
            ("Bonus Progress Tracker", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 4, totalSegments: 6),
                headerText: "Bonus Challenge",
                title: "Unlock Welcome Bonus",
                subtitle: "Place 2 more qualifying bets to earn your bonus.",
                icon: "gift.fill",
                isEnabled: true
            )),
            ("Loyalty Level Progress", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 2, totalSegments: 3),
                headerText: "VIP Status",
                title: "Upgrade to Silver Level",
                subtitle: "Bet €500 more to unlock exclusive Silver benefits.",
                icon: "crown.fill",
                isEnabled: true
            )),
            ("Cashout Availability", MockProgressInfoCheckViewModel(
                state: .complete,
                headerText: "Cashout Ready",
                title: "Cashout Now Available",
                subtitle: "Your bet qualifies for early cashout.",
                icon: "dollarsign.circle.fill",
                isEnabled: true
            )),
            ("Bet Builder Progress", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 3, totalSegments: 4),
                headerText: "Bet Builder",
                title: "Add Final Selection",
                subtitle: "3 of 4 selections added. Complete to place your bet.",
                icon: "plus.rectangle.fill",
                isEnabled: true
            )),
            ("Responsible Gambling Limits", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 1, totalSegments: 2),
                headerText: "Daily Limit",
                title: "Spending Limit Check",
                subtitle: "€50 of €100 daily limit used. Bet responsibly.",
                icon: "shield.checkered",
                isEnabled: true
            )),
            ("Tournament Entry Progress", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 5, totalSegments: 8),
                headerText: "Tournament Entry",
                title: "Weekly Challenge",
                subtitle: "5 of 8 required bets placed. Keep going to qualify!",
                icon: "trophy.fill",
                isEnabled: true
            )),
            ("Payment Method Setup", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 0, totalSegments: 2),
                headerText: "Payment Setup",
                title: "Add Payment Method",
                subtitle: "Set up a payment method to start depositing funds.",
                icon: "creditcard.fill",
                isEnabled: true
            )),
            ("Account Suspended", MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: 0, totalSegments: 3),
                headerText: "Account Status",
                title: "Account Verification Required",
                subtitle: "Complete verification to restore betting access.",
                icon: "exclamationmark.triangle.fill",
                isEnabled: false
            ))
        ]
        
        for (title, viewModel) in progressConfigurations {
            // Add section label
            let sectionLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(sectionLabel)
            
            // Create progress info view
            let progressInfoView = ProgressInfoCheckView(viewModel: viewModel)
            progressInfoView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container for proper spacing and visual separation
            let containerView = createProgressContainer()
            containerView.addSubview(progressInfoView)
            
            NSLayoutConstraint.activate([
                progressInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                progressInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                progressInfoView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                progressInfoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
            
            stackView.addArrangedSubview(containerView)
            progressInfoViews.append(progressInfoView)
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
        let interactiveViewModel = MockProgressInfoCheckViewModel(
            state: .incomplete(completedSegments: 2, totalSegments: 5),
            headerText: "Interactive Demo",
            title: "Interactive Progress Demo",
            subtitle: "Use controls below to test different states and progress levels.",
            icon: "wand.and.stars",
            isEnabled: true
        )
        
        let interactiveView = ProgressInfoCheckView(viewModel: interactiveViewModel)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let interactiveContainer = createProgressContainer()
        interactiveContainer.addSubview(interactiveView)
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor, constant: 16),
            interactiveView.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor, constant: -16),
            interactiveView.topAnchor.constraint(equalTo: interactiveContainer.topAnchor, constant: 16),
            interactiveView.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(interactiveContainer)
        
        // Store for controls
        progressInfoViews.append(interactiveView)
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
        
        let incrementProgressButton = createControlButton(title: "Increment Progress", action: #selector(incrementProgress))
        let decrementProgressButton = createControlButton(title: "Decrement Progress", action: #selector(decrementProgress))
        let markCompleteButton = createControlButton(title: "Mark Complete", action: #selector(markComplete))
        let resetProgressButton = createControlButton(title: "Reset Progress", action: #selector(resetProgress))
        let enableButton = createControlButton(title: "Enable State", action: #selector(enableState))
        let disableButton = createControlButton(title: "Disable State", action: #selector(disableState))
        let changeHeaderButton = createControlButton(title: "Change Header", action: #selector(changeHeader))
        let changeTitleButton = createControlButton(title: "Change Title", action: #selector(changeTitle))
        let changeSubtitleButton = createControlButton(title: "Change Subtitle", action: #selector(changeSubtitle))
        let changeIconButton = createControlButton(title: "Change Icon", action: #selector(changeIcon))
        let simulateProgressFlowButton = createControlButton(title: "Simulate Progress Flow", action: #selector(simulateProgressFlow))
        let resetToDefaultButton = createControlButton(title: "Reset to Default", action: #selector(resetToDefault))
        
        buttonStackView.addArrangedSubview(incrementProgressButton)
        buttonStackView.addArrangedSubview(decrementProgressButton)
        buttonStackView.addArrangedSubview(markCompleteButton)
        buttonStackView.addArrangedSubview(resetProgressButton)
        buttonStackView.addArrangedSubview(enableButton)
        buttonStackView.addArrangedSubview(disableButton)
        buttonStackView.addArrangedSubview(changeHeaderButton)
        buttonStackView.addArrangedSubview(changeTitleButton)
        buttonStackView.addArrangedSubview(changeSubtitleButton)
        buttonStackView.addArrangedSubview(changeIconButton)
        buttonStackView.addArrangedSubview(simulateProgressFlowButton)
        buttonStackView.addArrangedSubview(resetToDefaultButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Add state observation section
        addStateObservationSection()
        
        // Add progress patterns demo section
        addProgressPatternsDemo()
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
    
    private func addProgressPatternsDemo() {
        // Add spacing
        let spacer = createSpacer(height: 24)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let patternsTitle = createSectionTitle(with: "Progress Check Patterns")
        stackView.addArrangedSubview(patternsTitle)
        
        // Add patterns description
        let patternsDescription = UILabel()
        patternsDescription.text = "Common progress check patterns used in sports betting applications:"
        patternsDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        patternsDescription.textColor = StyleProvider.Color.highlightSecondary
        patternsDescription.numberOfLines = 0
        stackView.addArrangedSubview(patternsDescription)
        
        // Create different pattern examples
        let progressPatterns: [(String, String, String, String, String?, Int, Int)] = [
            ("Onboarding Flow", "Welcome Journey", "Complete Your Profile", "3 of 5 steps completed to start betting", "person.circle.fill", 3, 5),
            ("Bet Challenges", "Daily Challenge", "Win 5 Bets Today", "2 winning bets so far. Keep it up!", "target", 2, 5),
            ("Verification Steps", "Identity Check", "Document Verification", "Upload remaining documents to complete verification", "checkmark.shield.fill", 1, 3),
            ("Loyalty Progress", "Points Collection", "Earn Loyalty Points", "Collect 200 more points to reach next level", "star.circle.fill", 3, 4),
            ("Deposit Bonus", "First Deposit Bonus", "Unlock Bonus Funds", "Complete 3 qualifying bets to release bonus", "dollarsign.square.fill", 1, 3),
            ("Tournament Entry", "Weekly Tournament", "Tournament Qualification", "Meet minimum bet requirements to enter", "trophy.circle.fill", 0, 4),
            ("Free Bet Earning", "Free Bet Challenge", "Earn Free Bet", "Place 4 more bets this week to earn free bet", "ticket.fill", 1, 5),
            ("Account Security", "Security Setup", "Secure Your Account", "Enable 2FA and verify email address", "lock.shield.fill", 1, 2)
        ]
        
        for (category, header, title, subtitle, icon, completed, total) in progressPatterns {
            // Add pattern category label
            let categoryLabel = createSectionLabel(with: category)
            stackView.addArrangedSubview(categoryLabel)
            
            // Create pattern example
            let patternViewModel = MockProgressInfoCheckViewModel(
                state: .incomplete(completedSegments: completed, totalSegments: total),
                headerText: header,
                title: title,
                subtitle: subtitle,
                icon: icon,
                isEnabled: true
            )
            
            let patternView = ProgressInfoCheckView(viewModel: patternViewModel)
            patternView.translatesAutoresizingMaskIntoConstraints = false
            
            let patternContainer = createProgressContainer()
            patternContainer.addSubview(patternView)
            
            NSLayoutConstraint.activate([
                patternView.leadingAnchor.constraint(equalTo: patternContainer.leadingAnchor, constant: 16),
                patternView.trailingAnchor.constraint(equalTo: patternContainer.trailingAnchor, constant: -16),
                patternView.topAnchor.constraint(equalTo: patternContainer.topAnchor, constant: 16),
                patternView.bottomAnchor.constraint(equalTo: patternContainer.bottomAnchor, constant: -16)
            ])
            
            stackView.addArrangedSubview(patternContainer)
            
            progressInfoViews.append(patternView)
            viewModels.append(patternViewModel)
        }
    }
    
    // MARK: - Event Handlers
    @objc private func incrementProgress() {
        guard let interactiveViewModel = viewModels.last else { return }
        let currentData = interactiveViewModel.currentData
        
        switch currentData.state {
        case .incomplete(let completed, let total):
            if completed < total {
                let newState = ProgressInfoCheckState.incomplete(completedSegments: completed + 1, totalSegments: total)
                interactiveViewModel.updateState(newState)
                
                // Update subtitle to reflect progress
                let newSubtitle = "\(completed + 1) of \(total) steps completed. \(total - completed - 1) remaining."
                interactiveViewModel.updateSubtitle(newSubtitle)
                
                // If we reached the end, mark as complete
                if completed + 1 == total {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        interactiveViewModel.updateState(.complete)
                        interactiveViewModel.updateHeaderText("Completed!")
                        interactiveViewModel.updateTitle("Progress Complete")
                        interactiveViewModel.updateSubtitle("All steps have been completed successfully!")
                        interactiveViewModel.updateIcon("checkmark.circle.fill")
                    }
                }
            }
        case .complete:
            // Already complete, show feedback
            showProgressFeedback(message: "Progress is already complete!")
        }
    }
    
    @objc private func decrementProgress() {
        guard let interactiveViewModel = viewModels.last else { return }
        let currentData = interactiveViewModel.currentData
        
        switch currentData.state {
        case .incomplete(let completed, let total):
            if completed > 0 {
                let newState = ProgressInfoCheckState.incomplete(completedSegments: completed - 1, totalSegments: total)
                interactiveViewModel.updateState(newState)
                
                // Update subtitle to reflect progress
                let newSubtitle = "\(completed - 1) of \(total) steps completed. \(total - completed + 1) remaining."
                interactiveViewModel.updateSubtitle(newSubtitle)
            }
        case .complete:
            // Reset from complete to incomplete
            interactiveViewModel.updateState(.incomplete(completedSegments: 4, totalSegments: 5))
            interactiveViewModel.updateHeaderText("Interactive Demo")
            interactiveViewModel.updateTitle("Interactive Progress Demo")
            interactiveViewModel.updateSubtitle("4 of 5 steps completed. Use controls to test.")
            interactiveViewModel.updateIcon("wand.and.stars")
        }
    }
    
    @objc private func markComplete() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateState(.complete)
        interactiveViewModel.updateHeaderText("Success!")
        interactiveViewModel.updateTitle("All Steps Complete")
        interactiveViewModel.updateSubtitle("Congratulations! You've completed all required steps.")
        interactiveViewModel.updateIcon("checkmark.circle.fill")
    }
    
    @objc private func resetProgress() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateState(.incomplete(completedSegments: 0, totalSegments: 5))
        interactiveViewModel.updateHeaderText("Starting Fresh")
        interactiveViewModel.updateTitle("Begin Your Journey")
        interactiveViewModel.updateSubtitle("0 of 5 steps completed. Let's get started!")
        interactiveViewModel.updateIcon("play.circle.fill")
    }
    
    @objc private func enableState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setEnabled(true)
    }
    
    @objc private func disableState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setEnabled(false)
    }
    
    @objc private func changeHeader() {
        guard let interactiveViewModel = viewModels.last else { return }
        let headers = [
            "Interactive Demo",
            "Progress Update",
            "Achievement Unlocked",
            "Status Check",
            "Next Steps",
            "Almost There!",
            "Keep Going!"
        ]
        
        let currentHeader = interactiveViewModel.currentData.headerText
        let currentIndex = headers.firstIndex(of: currentHeader) ?? 0
        let nextIndex = (currentIndex + 1) % headers.count
        let nextHeader = headers[nextIndex]
        
        interactiveViewModel.updateHeaderText(nextHeader)
    }
    
    @objc private func changeTitle() {
        guard let interactiveViewModel = viewModels.last else { return }
        let titles = [
            "Interactive Progress Demo",
            "Complete Your Tasks",
            "Achievement Progress",
            "Step-by-Step Guide",
            "Progress Tracker",
            "Goal Achievement",
            "Mission Progress"
        ]
        
        let currentTitle = interactiveViewModel.currentData.title
        let currentIndex = titles.firstIndex(of: currentTitle) ?? 0
        let nextIndex = (currentIndex + 1) % titles.count
        let nextTitle = titles[nextIndex]
        
        interactiveViewModel.updateTitle(nextTitle)
    }
    
    @objc private func changeSubtitle() {
        guard let interactiveViewModel = viewModels.last else { return }
        let subtitles = [
            "Use controls below to test different states and progress levels.",
            "Track your progress and complete remaining steps.",
            "Follow the steps to unlock new features and rewards.",
            "Every step brings you closer to your goal.",
            "Stay motivated and keep making progress!",
            "Complete all requirements to proceed to the next level."
        ]
        
        let currentSubtitle = interactiveViewModel.currentData.subtitle
        let currentIndex = subtitles.firstIndex(of: currentSubtitle) ?? 0
        let nextIndex = (currentIndex + 1) % subtitles.count
        let nextSubtitle = subtitles[nextIndex]
        
        interactiveViewModel.updateSubtitle(nextSubtitle)
    }
    
    @objc private func changeIcon() {
        guard let interactiveViewModel = viewModels.last else { return }
        let icons = [
            "wand.and.stars",
            "star.fill",
            "checkmark.circle.fill",
            "trophy.fill",
            "target",
            "flag.checkered",
            "medal.fill",
            "crown.fill",
            "diamond.fill",
            "heart.fill",
            "bolt.fill",
            "flame.fill",
            "sparkles"
        ]
        
        let currentIcon = interactiveViewModel.currentData.icon
        let currentIndex = icons.firstIndex(of: currentIcon ?? "") ?? 0
        let nextIndex = (currentIndex + 1) % icons.count
        let nextIcon = icons[nextIndex]
        
        interactiveViewModel.updateIcon(nextIcon)
    }
    
    @objc private func simulateProgressFlow() {
        guard let interactiveViewModel = viewModels.last else { return }
        
        // Start progress simulation
        interactiveViewModel.updateState(.incomplete(completedSegments: 0, totalSegments: 5))
        interactiveViewModel.updateHeaderText("Starting...")
        interactiveViewModel.updateTitle("Initializing Progress")
        interactiveViewModel.updateSubtitle("Beginning progress simulation...")
        interactiveViewModel.updateIcon("hourglass")
        interactiveViewModel.setEnabled(false)
        
        // Step 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            interactiveViewModel.updateState(.incomplete(completedSegments: 1, totalSegments: 5))
            interactiveViewModel.updateHeaderText("Step 1 Complete")
            interactiveViewModel.updateTitle("Profile Setup")
            interactiveViewModel.updateSubtitle("1 of 5 steps completed. Setting up your profile...")
            interactiveViewModel.updateIcon("person.fill")
        }
        
        // Step 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            interactiveViewModel.updateState(.incomplete(completedSegments: 2, totalSegments: 5))
            interactiveViewModel.updateHeaderText("Step 2 Complete")
            interactiveViewModel.updateTitle("Account Verification")
            interactiveViewModel.updateSubtitle("2 of 5 steps completed. Verifying your account...")
            interactiveViewModel.updateIcon("checkmark.shield.fill")
        }
        
        // Step 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            interactiveViewModel.updateState(.incomplete(completedSegments: 3, totalSegments: 5))
            interactiveViewModel.updateHeaderText("Step 3 Complete")
            interactiveViewModel.updateTitle("Payment Setup")
            interactiveViewModel.updateSubtitle("3 of 5 steps completed. Setting up payment method...")
            interactiveViewModel.updateIcon("creditcard.fill")
        }
        
        // Step 4
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            interactiveViewModel.updateState(.incomplete(completedSegments: 4, totalSegments: 5))
            interactiveViewModel.updateHeaderText("Almost Done")
            interactiveViewModel.updateTitle("Final Configuration")
            interactiveViewModel.updateSubtitle("4 of 5 steps completed. Final setup in progress...")
            interactiveViewModel.updateIcon("gear.badge.checkmark")
        }
        
        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            interactiveViewModel.updateState(.complete)
            interactiveViewModel.updateHeaderText("Congratulations!")
            interactiveViewModel.updateTitle("Setup Complete")
            interactiveViewModel.updateSubtitle("All steps have been completed successfully!")
            interactiveViewModel.updateIcon("party.popper.fill")
            interactiveViewModel.setEnabled(true)
            
            // Show completion feedback
            let alert = UIAlertController(
                title: "Progress Flow Complete",
                message: "The progress simulation has finished successfully!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc private func resetToDefault() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateState(.incomplete(completedSegments: 2, totalSegments: 5))
        interactiveViewModel.updateHeaderText("Interactive Demo")
        interactiveViewModel.updateTitle("Interactive Progress Demo")
        interactiveViewModel.updateSubtitle("Use controls below to test different states and progress levels.")
        interactiveViewModel.updateIcon("wand.and.stars")
        interactiveViewModel.setEnabled(true)
    }
    
    private func showProgressFeedback(message: String) {
        let alert = UIAlertController(
            title: "Progress Info",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateStateObservation(with data: ProgressInfoCheckData) {
        guard let statusLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        let stateText: String
        switch data.state {
        case .incomplete(let completed, let total):
            stateText = "INCOMPLETE (\(completed)/\(total))"
        case .complete:
            stateText = "COMPLETE"
        }
        
        let enabledText = data.isEnabled ? "ENABLED" : "DISABLED"
        let iconText = data.icon ?? "None"
        
        statusLabel.text = """
        State: \(stateText)
        Header: "\(data.headerText)"
        Title: "\(data.title)"
        Subtitle: "\(data.subtitle.prefix(50))..."
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
extension ProgressInfoCheckViewController {
    
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
        label.text = "ProgressInfoCheckView component for displaying step-by-step progress with visual indicators, icons, titles, and status information. Features segmented progress bars, customizable content, enabled/disabled states, and proper styling using StyleProvider. Perfect for onboarding flows, verification processes, achievement tracking, and multi-step user journeys in sports betting applications."
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
        label.text = "Use the controls below to interact with the progress indicator and test different states:"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.highlightSecondary
        label.numberOfLines = 0
        return label
    }
    
    private func createProgressContainer() -> UIView {
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
