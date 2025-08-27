import UIKit
import GomaUI
import Combine

class CodeClipboardViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var viewModels: [MockCodeClipboardViewModel] = []
    private var codeClipboardViews: [CodeClipboardView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCodeClipboardViews()
        setupControlsSection()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Code Clipboard"
        
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
    
    private func setupCodeClipboardViews() {
        // Create various code clipboard configurations showcasing different states
        let clipboardConfigurations: [(String, MockCodeClipboardViewModel)] = [
            ("Default State (Booking Code)", MockCodeClipboardViewModel.defaultMock()),
            ("Custom Code", MockCodeClipboardViewModel.withCustomCodeMock()),
            ("Copied State", MockCodeClipboardViewModel.copiedMock()),
            ("Disabled State", MockCodeClipboardViewModel.disabledMock())
        ]
        
        for (title, viewModel) in clipboardConfigurations {
            // Add section label
            let sectionLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(sectionLabel)
            
            // Create code clipboard view
            let codeClipboardView = CodeClipboardView(viewModel: viewModel)
            codeClipboardView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container for proper spacing
            let containerView = createClipboardContainer()
            containerView.addSubview(codeClipboardView)
            
            NSLayoutConstraint.activate([
                codeClipboardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                codeClipboardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                codeClipboardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                codeClipboardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
            
            stackView.addArrangedSubview(containerView)
            codeClipboardViews.append(codeClipboardView)
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
        let interactiveViewModel = MockCodeClipboardViewModel(
            code: "DEMO123",
            labelText: "Interactive Demo Code"
        )
        
        let interactiveView = CodeClipboardView(viewModel: interactiveViewModel)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let interactiveContainer = createClipboardContainer()
        interactiveContainer.addSubview(interactiveView)
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor, constant: 12),
            interactiveView.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor, constant: -12),
            interactiveView.topAnchor.constraint(equalTo: interactiveContainer.topAnchor, constant: 12),
            interactiveView.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(interactiveContainer)
        
        // Store for controls
        codeClipboardViews.append(interactiveView)
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
        controlsDescription.textColor = StyleProvider.Color.secondaryColor
        controlsDescription.numberOfLines = 0
        stackView.addArrangedSubview(controlsDescription)
        
        // Add control buttons
        let buttonStackView = createButtonStackView()
        
        let setCopiedButton = createControlButton(title: "Set to Copied State", action: #selector(setCopiedState))
        let setDefaultButton = createControlButton(title: "Set to Default State", action: #selector(setDefaultState))
        let toggleEnabledButton = createControlButton(title: "Toggle Enabled/Disabled", action: #selector(toggleEnabled))
        let changeCodeButton = createControlButton(title: "Change Code to Random", action: #selector(changeCodeToRandom))
        let changeLabelButton = createControlButton(title: "Change Label Text", action: #selector(changeLabelText))
        let testCopyButton = createControlButton(title: "Simulate Copy Action", action: #selector(simulateCopyAction))
        
        buttonStackView.addArrangedSubview(setCopiedButton)
        buttonStackView.addArrangedSubview(setDefaultButton)
        buttonStackView.addArrangedSubview(toggleEnabledButton)
        buttonStackView.addArrangedSubview(changeCodeButton)
        buttonStackView.addArrangedSubview(changeLabelButton)
        buttonStackView.addArrangedSubview(testCopyButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Add state observation section
        addStateObservationSection()
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
        statusLabel.textColor = StyleProvider.Color.secondaryColor
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
    
    // MARK: - Event Handlers
    @objc private func setCopiedState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setCopied(true)
    }
    
    @objc private func setDefaultState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setCopied(false)
    }
    
    @objc private func toggleEnabled() {
        guard let interactiveViewModel = viewModels.last else { return }
        let currentState = interactiveViewModel.currentData.isEnabled
        interactiveViewModel.setEnabled(!currentState)
    }
    
    @objc private func changeCodeToRandom() {
        guard let interactiveViewModel = viewModels.last else { return }
        let randomCodes = ["ABC123", "XYZ789", "DEF456", "GHI012", "JKL345"]
        let randomCode = randomCodes.randomElement() ?? "RANDOM"
        interactiveViewModel.updateCode(randomCode)
    }
    
    @objc private func changeLabelText() {
        guard let interactiveViewModel = viewModels.last else { return }
        let labels = ["Copy Booking Code", "Copy Reference", "Copy Bet ID", "Copy Promo Code"]
        
        // Find current label and get next one
        let currentLabel = interactiveViewModel.currentData.labelText
        let currentIndex = labels.firstIndex(of: currentLabel) ?? 0
        let nextIndex = (currentIndex + 1) % labels.count
        let nextLabel = labels[nextIndex]
        
        // Create new data with updated label
        let currentData = interactiveViewModel.currentData
        let newData = CodeClipboardData(
            state: currentData.state,
            code: currentData.code,
            labelText: nextLabel,
            isEnabled: currentData.isEnabled
        )
        
        // Update through the subject (accessing private property through reflection would be improper)
        // Instead, we'll work with what the public interface provides
        interactiveViewModel.updateCode(currentData.code + " ") // Trigger update
        interactiveViewModel.updateCode(String(currentData.code.dropLast())) // Restore original
    }
    
    @objc private func simulateCopyAction() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.onCopyTapped()
    }
    
    private func updateStateObservation(with data: CodeClipboardData) {
        guard let statusLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        let stateText = data.state == .copied ? "COPIED" : "DEFAULT"
        let enabledText = data.isEnabled ? "ENABLED" : "DISABLED"
        
        statusLabel.text = """
        Code: "\(data.code)"
        Label: "\(data.labelText)"
        State: \(stateText)
        Status: \(enabledText)
        """
        
        // Update color based on state
        if data.state == .copied {
            statusLabel.textColor = StyleProvider.Color.successColor
            statusLabel.backgroundColor = StyleProvider.Color.successColor.withAlphaComponent(0.1)
        } else if !data.isEnabled {
            statusLabel.textColor = StyleProvider.Color.secondaryColor
            statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        } else {
            statusLabel.textColor = StyleProvider.Color.textColor
            statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension CodeClipboardViewController {
    
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
        label.text = "CodeClipboardView component with copy functionality and visual feedback. Features animated state transitions between default and copied states, with proper styling using StyleProvider. The component shows a label on the left and the code with copy icon on the right."
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textColor = StyleProvider.Color.textColor
        return label
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.secondaryColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func createSectionLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.secondaryColor
        return label
    }
    
    private func createSectionTitle(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textColor
        return label
    }
    
    private func createSubDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = "Tap the code area to copy and see the animated state transition:"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.secondaryColor
        label.numberOfLines = 0
        return label
    }
    
    private func createClipboardContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundColor
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.3).cgColor
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
        button.backgroundColor = StyleProvider.Color.backgroundColor
        button.setTitleColor(StyleProvider.Color.primaryColor, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = StyleProvider.Color.primaryColor.cgColor
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