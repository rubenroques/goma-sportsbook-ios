import UIKit
import Combine
import GomaUI

/// Demo ViewController for CompactOutcomesLineView showing different market types
final class CompactOutcomesLineViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 20
    }

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    private var interactiveVM: MockCompactOutcomesLineViewModel!

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var interactiveOutcomesView: CompactOutcomesLineView!
    private var eventLabel: UILabel!

    // Control elements
    private lazy var modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["3-Way (1X2)", "2-Way (1 2)"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private lazy var outcomeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Left", "Middle", "Right"])
        control.selectedSegmentIndex = 0
        return control
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupConstraints()
        setupComponents()
        setupControls()
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "Compact Outcomes Line"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.padding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.padding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.padding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.padding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Constants.padding)
        ])
    }

    private func setupComponents() {
        // Interactive outcomes
        addSection(title: "Interactive Outcomes", description: "Use controls below to modify") {
            self.interactiveVM = MockCompactOutcomesLineViewModel.threeWayMarket
            self.interactiveOutcomesView = CompactOutcomesLineView(viewModel: self.interactiveVM)
            self.setupOutcomesCallbacks(self.interactiveOutcomesView, name: "Interactive")
            return self.interactiveOutcomesView
        }

        // 3-Way examples
        addSection(title: "3-Way Market (Football)", description: "Home, Draw, Away outcomes") {
            let view = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.threeWayMarket)
            self.setupOutcomesCallbacks(view, name: "3-Way")
            return view
        }

        // 2-Way examples
        addSection(title: "2-Way Market (Tennis)", description: "Player 1, Player 2 outcomes") {
            let view = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.twoWayMarket)
            self.setupOutcomesCallbacks(view, name: "2-Way")
            return view
        }

        // With selection
        addSection(title: "With Selected Outcome", description: "Left outcome is selected") {
            let view = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.withSelectedOutcome)
            self.setupOutcomesCallbacks(view, name: "Selected")
            return view
        }

        // Locked market
        addSection(title: "Locked Market", description: "All outcomes locked (suspended)") {
            CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.lockedMarket)
        }

        // With odds changes
        addSection(title: "With Odds Changes", description: "Shows up/down direction indicators") {
            let view = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.withOddsChanges)
            self.setupOutcomesCallbacks(view, name: "OddsChanges")
            return view
        }
    }

    private func setupOutcomesCallbacks(_ view: CompactOutcomesLineView, name: String) {
        view.onOutcomeSelected = { [weak self] outcomeId, outcomeType in
            self?.updateEventLabel("Selected \(outcomeType) in \(name) (ID: \(outcomeId))")
        }

        view.onOutcomeDeselected = { [weak self] outcomeId, outcomeType in
            self?.updateEventLabel("Deselected \(outcomeType) in \(name) (ID: \(outcomeId))")
        }
    }

    private func setupControls() {
        addSeparator()

        // Event label
        eventLabel = UILabel()
        eventLabel.text = "Tap an outcome to see events here"
        eventLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        eventLabel.textColor = StyleProvider.Color.textSecondary
        eventLabel.textAlignment = .center
        eventLabel.numberOfLines = 0
        eventLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        eventLabel.layer.cornerRadius = 8
        eventLabel.layer.masksToBounds = true

        let eventContainer = UIView()
        eventContainer.addSubview(eventLabel)
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventLabel.topAnchor.constraint(equalTo: eventContainer.topAnchor, constant: 12),
            eventLabel.leadingAnchor.constraint(equalTo: eventContainer.leadingAnchor, constant: 12),
            eventLabel.trailingAnchor.constraint(equalTo: eventContainer.trailingAnchor, constant: -12),
            eventLabel.bottomAnchor.constraint(equalTo: eventContainer.bottomAnchor, constant: -12)
        ])
        stackView.addArrangedSubview(eventContainer)

        addSeparator()

        // Controls title
        let controlsTitle = UILabel()
        controlsTitle.text = "Interactive Controls"
        controlsTitle.font = StyleProvider.fontWith(type: .semibold, size: 18)
        controlsTitle.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(controlsTitle)

        // Mode selector
        let modeLabel = UILabel()
        modeLabel.text = "Market Type:"
        modeLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        modeLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(modeLabel)

        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        stackView.addArrangedSubview(modeSegmentedControl)

        // Outcome selector
        let outcomeLabel = UILabel()
        outcomeLabel.text = "Target Outcome:"
        outcomeLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        outcomeLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(outcomeLabel)

        stackView.addArrangedSubview(outcomeSegmentedControl)

        // Action buttons
        let updateOddsButton = createButton(title: "Update Selected Odds (Random)")
        updateOddsButton.addTarget(self, action: #selector(updateOddsTapped), for: .touchUpInside)
        stackView.addArrangedSubview(updateOddsButton)

        let lockButton = createButton(title: "Lock Selected Outcome", color: .systemOrange)
        lockButton.addTarget(self, action: #selector(lockOutcomeTapped), for: .touchUpInside)
        stackView.addArrangedSubview(lockButton)

        let unlockButton = createButton(title: "Unlock Selected Outcome", color: .systemGreen)
        unlockButton.addTarget(self, action: #selector(unlockOutcomeTapped), for: .touchUpInside)
        stackView.addArrangedSubview(unlockButton)

        let toggleSelectionButton = createButton(title: "Toggle Selection State", color: .systemPurple)
        toggleSelectionButton.addTarget(self, action: #selector(toggleSelectionTapped), for: .touchUpInside)
        stackView.addArrangedSubview(toggleSelectionButton)
    }

    // MARK: - Helpers

    private func addSection(title: String, description: String, componentFactory: () -> UIView) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descLabel.textColor = StyleProvider.Color.textSecondary
        descLabel.numberOfLines = 0
        stackView.addArrangedSubview(descLabel)

        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundSecondary
        container.layer.cornerRadius = 8

        let component = componentFactory()
        component.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(component)

        NSLayoutConstraint.activate([
            component.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            component.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            component.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            component.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            component.heightAnchor.constraint(equalToConstant: 48)
        ])

        stackView.addArrangedSubview(container)
    }

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.separatorLine
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }

    private func createButton(title: String, color: UIColor = StyleProvider.Color.highlightPrimary) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    private func updateEventLabel(_ message: String) {
        eventLabel.text = message

        UIView.animate(withDuration: 0.2, animations: {
            self.eventLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.eventLabel.transform = .identity
            }
        }
    }

    private func getSelectedOutcomeType() -> OutcomeType {
        switch outcomeSegmentedControl.selectedSegmentIndex {
        case 0: return .left
        case 1: return .middle
        case 2: return .right
        default: return .left
        }
    }

    private func getOutcomeVM(for type: OutcomeType) -> MockOutcomeItemViewModel? {
        switch type {
        case .left:
            return interactiveVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            return interactiveVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            return interactiveVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }
    }

    // MARK: - Actions

    @objc private func modeChanged() {
        // Recreate with new mode
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            interactiveVM = MockCompactOutcomesLineViewModel.threeWayMarket
            outcomeSegmentedControl.setEnabled(true, forSegmentAt: 1) // Enable middle
        } else {
            interactiveVM = MockCompactOutcomesLineViewModel.twoWayMarket
            outcomeSegmentedControl.setEnabled(false, forSegmentAt: 1) // Disable middle
            if outcomeSegmentedControl.selectedSegmentIndex == 1 {
                outcomeSegmentedControl.selectedSegmentIndex = 0
            }
        }

        interactiveOutcomesView.configure(with: interactiveVM)
        setupOutcomesCallbacks(interactiveOutcomesView, name: "Interactive")
        updateEventLabel("Mode changed to \(modeSegmentedControl.selectedSegmentIndex == 0 ? "3-Way" : "2-Way")")
    }

    @objc private func updateOddsTapped() {
        let outcomeType = getSelectedOutcomeType()
        guard let outcomeVM = getOutcomeVM(for: outcomeType) else { return }

        let newOdds = String(format: "%.2f", Double.random(in: 1.5...5.0))
        let direction: OddsChangeDirection = Bool.random() ? .up : .down

        outcomeVM.updateValue(newOdds, changeDirection: direction)
        updateEventLabel("Updated \(outcomeType) odds to \(newOdds) (\(direction))")
    }

    @objc private func lockOutcomeTapped() {
        let outcomeType = getSelectedOutcomeType()
        guard let outcomeVM = getOutcomeVM(for: outcomeType) else { return }

        outcomeVM.setDisplayState(.locked)
        updateEventLabel("Locked \(outcomeType)")
    }

    @objc private func unlockOutcomeTapped() {
        let outcomeType = getSelectedOutcomeType()
        guard let outcomeVM = getOutcomeVM(for: outcomeType) else { return }

        let newOdds = String(format: "%.2f", Double.random(in: 1.5...5.0))
        outcomeVM.setDisplayState(.normal(isSelected: false, isBoosted: false))
        outcomeVM.updateValue(newOdds, changeDirection: .none)
        updateEventLabel("Unlocked \(outcomeType) with odds \(newOdds)")
    }

    @objc private func toggleSelectionTapped() {
        let outcomeType = getSelectedOutcomeType()
        guard let outcomeVM = getOutcomeVM(for: outcomeType) else { return }

        let currentlySelected = outcomeVM.outcomeDataSubject.value.isSelected
        outcomeVM.setSelected(!currentlySelected)
        updateEventLabel("\(outcomeType) selection: \(!currentlySelected)")
    }

    // MARK: - Factory Methods

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing
        stackView.alignment = .fill
        return stackView
    }
}
