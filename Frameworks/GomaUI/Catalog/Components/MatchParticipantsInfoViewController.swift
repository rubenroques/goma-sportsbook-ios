import UIKit
import GomaUI

class MatchParticipantsInfoViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView = Self.createScrollView()
    private lazy var contentStackView = Self.createContentStackView()
    private lazy var layoutModeSegmentedControl = Self.createLayoutModeSegmentedControl()
    private lazy var componentView: MatchParticipantsInfoView = {
        return MatchParticipantsInfoView(viewModel: self.viewModel)
    }()
    
    // MARK: - Mock Examples
    private let mockExamples: [(title: String, viewModel: MockMatchParticipantsInfoViewModel)] = [
        ("Horizontal - Pre-Live", MockMatchParticipantsInfoViewModel.horizontalPreLive),
        ("Horizontal - Live", MockMatchParticipantsInfoViewModel.horizontalLive),
        ("Horizontal - Ended", MockMatchParticipantsInfoViewModel.horizontalEnded),
        ("Vertical - Tennis Live", MockMatchParticipantsInfoViewModel.verticalTennisLive),
        ("Vertical - Basketball", MockMatchParticipantsInfoViewModel.verticalBasketballLive),
        ("Vertical - Volleyball", MockMatchParticipantsInfoViewModel.verticalVolleyballLive),
        ("Vertical - Football Pre-Live", MockMatchParticipantsInfoViewModel.verticalFootballPreLive),
        ("Long Team Names", MockMatchParticipantsInfoViewModel.longTeamNames),
        ("Live Without Time", MockMatchParticipantsInfoViewModel.liveWithoutTime)
    ]
    
    private var currentExampleIndex = 0
    private let viewModel = MockMatchParticipantsInfoViewModel.defaultMock
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        loadCurrentExample()
    }
    
    private func setupViews() {
        title = "Match Participants Info"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Add controls
        let controlsContainer = Self.createControlsContainer()
        
        let layoutModeLabel = Self.createSectionLabel()
        layoutModeLabel.text = "Layout Mode"
        
        let exampleLabel = Self.createSectionLabel()
        exampleLabel.text = "Examples"
        
        let exampleSelector = Self.createExampleSelector()
        exampleSelector.addTarget(self, action: #selector(previousExampleTapped), for: .touchUpInside)
        
        let nextExampleButton = Self.createExampleSelector()
        nextExampleButton.setTitle("Next Example", for: .normal)
        nextExampleButton.addTarget(self, action: #selector(nextExampleTapped), for: .touchUpInside)
        
        let currentExampleLabel = Self.createCurrentExampleLabel()
        currentExampleLabel.tag = 100 // For easy reference
        
        // Build hierarchy
        controlsContainer.addArrangedSubview(layoutModeLabel)
        controlsContainer.addArrangedSubview(layoutModeSegmentedControl)
        controlsContainer.addArrangedSubview(Self.createSpacerView())
        controlsContainer.addArrangedSubview(exampleLabel)
        controlsContainer.addArrangedSubview(currentExampleLabel)
        
        let buttonsStack = Self.createButtonsStackView()
        exampleSelector.setTitle("Previous", for: .normal)
        buttonsStack.addArrangedSubview(exampleSelector)
        buttonsStack.addArrangedSubview(nextExampleButton)
        controlsContainer.addArrangedSubview(buttonsStack)
        
        contentStackView.addArrangedSubview(controlsContainer)
        contentStackView.addArrangedSubview(Self.createSpacerView())
        contentStackView.addArrangedSubview(componentView)
        contentStackView.addArrangedSubview(Self.createSpacerView())
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            componentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }
    
    private func setupActions() {
        layoutModeSegmentedControl.addTarget(
            self,
            action: #selector(layoutModeChanged(_:)),
            for: .valueChanged
        )
    }
    
    private func loadCurrentExample() {
        let example = mockExamples[currentExampleIndex]
        
        // Get the current state from the mock and update our view model
        if let mockViewModel = example.viewModel as? MockMatchParticipantsInfoViewModel {
            let currentState = mockViewModel.currentDisplayState
            viewModel.updateDisplayState(currentState)
            
            // Update current example label
            if let label = view.viewWithTag(100) as? UILabel {
                label.text = "\(currentExampleIndex + 1)/\(mockExamples.count): \(example.title)"
            }
            
            // Update segmented control to match current mode
            layoutModeSegmentedControl.selectedSegmentIndex = currentState.displayMode == .horizontal ? 0 : 1
        }
    }
    
    // MARK: - Actions
    @objc private func layoutModeChanged(_ sender: UISegmentedControl) {
        let mode: MatchDisplayMode = sender.selectedSegmentIndex == 0 ? .horizontal : .vertical
        viewModel.setDisplayMode(mode)
    }
    
    @objc private func previousExampleTapped() {
        currentExampleIndex = currentExampleIndex > 0 ? currentExampleIndex - 1 : mockExamples.count - 1
        loadCurrentExample()
    }
    
    @objc private func nextExampleTapped() {
        currentExampleIndex = (currentExampleIndex + 1) % mockExamples.count
        loadCurrentExample()
    }
}

// MARK: - Factory Methods
extension MatchParticipantsInfoViewController {
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }
    
    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }
    
    private static func createLayoutModeSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: ["Horizontal", "Vertical"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }
    
    private static func createControlsContainer() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = 12
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.systemGray4.cgColor
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return stackView
    }
    
    private static func createSectionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }
    
    private static func createCurrentExampleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
    
    private static func createExampleSelector() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }
    
    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }
    
    private static func createSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 8)
        ])
        return view
    }
}