import UIKit
import Combine
import GomaUI

/// Demo ViewController for InlineMatchCardView with real-time simulation capabilities
final class InlineMatchCardViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let controlPanelHeight: CGFloat = 200
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 12
        static let buttonHeight: CGFloat = 44
        static let cellCount: Int = 12
    }

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let simulator = InlineMatchCardSimulator()

    // The primary view model that simulation controls
    private var primaryHeaderVM: MockCompactMatchHeaderViewModel!
    private var primaryOutcomesVM: MockCompactOutcomesLineViewModel!
    private var primaryScoreVM: MockInlineScoreViewModel!

    // All view models for the table (first one is controlled by simulator)
    private var cardViewModels: [MockInlineMatchCardViewModel] = []

    // MARK: - UI Components

    private lazy var controlPanelView: UIView = Self.createControlPanel()
    private lazy var tableView: UITableView = Self.createTableView()

    // Control Panel Elements
    private lazy var scenarioSegmentedControl: UISegmentedControl = Self.createScenarioControl()
    private lazy var speedSegmentedControl: UISegmentedControl = Self.createSpeedControl()
    private lazy var playPauseButton: UIButton = Self.createPlayPauseButton()
    private lazy var stopButton: UIButton = Self.createStopButton()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViewModels()
        setupViews()
        setupConstraints()
        setupSimulator()
        setupBindings()
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "Inline Match Card"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupViewModels() {
        // Create the primary view model that will be controlled by the simulator
        primaryHeaderVM = MockCompactMatchHeaderViewModel.preLiveToday
        primaryOutcomesVM = MockCompactOutcomesLineViewModel.threeWayMarket
        primaryScoreVM = MockInlineScoreViewModel.footballMatch

        let primaryDisplayState = InlineMatchCardDisplayState(
            matchId: "sim_primary",
            homeParticipantName: "Liverpool F.C.",
            awayParticipantName: "Manchester City",
            isLive: false
        )

        let primaryCardVM = MockInlineMatchCardViewModel(
            displayState: primaryDisplayState,
            headerViewModel: primaryHeaderVM,
            outcomesViewModel: primaryOutcomesVM,
            scoreViewModel: primaryScoreVM
        )
        cardViewModels.append(primaryCardVM)

        // Create additional view models with different states for variety
        let additionalMocks: [MockInlineMatchCardViewModel] = [
            .liveTennis,
            .liveFootball,
            .preLiveFootball,
            .withSelectedOutcome,
            .liveBasketball,
            .preLiveFutureDate,
            .productionMode,
            .lockedMarket,
            .liveTennis,
            .preLiveFootball,
            .liveFootball
        ]

        cardViewModels.append(contentsOf: additionalMocks)
    }

    private func setupViews() {
        view.addSubview(controlPanelView)
        view.addSubview(tableView)

        // Add control panel elements
        setupControlPanelElements()

        // Register cell
        tableView.register(InlineMatchCardTableViewCell.self, forCellReuseIdentifier: InlineMatchCardTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupControlPanelElements() {
        // Scenario label
        let scenarioLabel = UILabel()
        scenarioLabel.text = "Scenario:"
        scenarioLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        scenarioLabel.textColor = StyleProvider.Color.textSecondary
        scenarioLabel.translatesAutoresizingMaskIntoConstraints = false
        controlPanelView.addSubview(scenarioLabel)

        controlPanelView.addSubview(scenarioSegmentedControl)

        // Speed label
        let speedLabel = UILabel()
        speedLabel.text = "Speed:"
        speedLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        speedLabel.textColor = StyleProvider.Color.textSecondary
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        controlPanelView.addSubview(speedLabel)

        controlPanelView.addSubview(speedSegmentedControl)

        // Buttons container
        let buttonsStack = UIStackView(arrangedSubviews: [playPauseButton, stopButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 12
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        controlPanelView.addSubview(buttonsStack)

        controlPanelView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            // Scenario
            scenarioLabel.topAnchor.constraint(equalTo: controlPanelView.topAnchor, constant: 12),
            scenarioLabel.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),

            scenarioSegmentedControl.topAnchor.constraint(equalTo: scenarioLabel.bottomAnchor, constant: 4),
            scenarioSegmentedControl.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),
            scenarioSegmentedControl.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -Constants.horizontalPadding),

            // Speed
            speedLabel.topAnchor.constraint(equalTo: scenarioSegmentedControl.bottomAnchor, constant: 12),
            speedLabel.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),

            speedSegmentedControl.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 4),
            speedSegmentedControl.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),
            speedSegmentedControl.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -Constants.horizontalPadding),

            // Buttons
            buttonsStack.topAnchor.constraint(equalTo: speedSegmentedControl.bottomAnchor, constant: 12),
            buttonsStack.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),
            buttonsStack.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -Constants.horizontalPadding),
            buttonsStack.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),

            // Status
            statusLabel.topAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: Constants.horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }

    private func setupConstraints() {
        controlPanelView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controlPanelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controlPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlPanelView.heightAnchor.constraint(equalToConstant: Constants.controlPanelHeight),

            tableView.topAnchor.constraint(equalTo: controlPanelView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSimulator() {
        simulator.configure(
            headerViewModel: primaryHeaderVM,
            outcomesViewModel: primaryOutcomesVM,
            scoreViewModel: primaryScoreVM
        )

        // Set initial speed
        simulator.speed = .normal
        speedSegmentedControl.selectedSegmentIndex = 1
    }

    private func setupBindings() {
        // Bind to simulator state
        simulator.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUIForState(state)
            }
            .store(in: &cancellables)

        // Setup control actions
        scenarioSegmentedControl.addTarget(self, action: #selector(scenarioChanged), for: .valueChanged)
        speedSegmentedControl.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
    }

    // MARK: - UI Updates

    private func updateUIForState(_ state: InlineMatchCardSimulator.SimulationState) {
        switch state {
        case .idle:
            playPauseButton.setTitle("Play", for: .normal)
            playPauseButton.backgroundColor = StyleProvider.Color.highlightPrimary
            stopButton.isEnabled = false
            stopButton.alpha = 0.5
            statusLabel.text = "Status: Idle"

        case .running:
            playPauseButton.setTitle("Pause", for: .normal)
            playPauseButton.backgroundColor = .systemOrange
            stopButton.isEnabled = true
            stopButton.alpha = 1.0
            statusLabel.text = "Status: Running - \(simulator.currentScenarioName)"

        case .paused:
            playPauseButton.setTitle("Resume", for: .normal)
            playPauseButton.backgroundColor = StyleProvider.Color.highlightPrimary
            stopButton.isEnabled = true
            stopButton.alpha = 1.0
            statusLabel.text = "Status: Paused - \(simulator.currentScenarioName)"
        }
    }

    // MARK: - Actions

    @objc private func scenarioChanged() {
        // Stop current simulation when scenario changes
        simulator.stop()
    }

    @objc private func speedChanged() {
        let speeds = InlineMatchCardSimulator.Speed.allCases
        let selectedSpeed = speeds[speedSegmentedControl.selectedSegmentIndex]
        simulator.speed = selectedSpeed
        print("[Demo] Speed changed to: \(selectedSpeed.title)")
    }

    @objc private func playPauseTapped() {
        switch simulator.currentState {
        case .idle:
            // Start new simulation with selected scenario
            let scenarios = InlineMatchCardSimulatorScenario.allScenarios
            let selectedScenario = scenarios[scenarioSegmentedControl.selectedSegmentIndex]
            simulator.start(scenario: selectedScenario)

        case .running:
            simulator.pause()

        case .paused:
            simulator.resume()
        }
    }

    @objc private func stopTapped() {
        simulator.stop()
    }
}

// MARK: - UITableViewDataSource

extension InlineMatchCardViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Simulation target cell
        }
        return cardViewModels.count - 1 // Other cells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: InlineMatchCardTableViewCell.identifier,
            for: indexPath
        ) as? InlineMatchCardTableViewCell else {
            return UITableViewCell()
        }

        let viewModelIndex = indexPath.section == 0 ? 0 : indexPath.row + 1
        let viewModel = cardViewModels[viewModelIndex]

        cell.configure(with: viewModel)

        // Configure corner radius based on position
        let isFirst = indexPath.row == 0
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let isLast = indexPath.row == numberOfRows - 1
        cell.configureCellPosition(isFirst: isFirst, isLast: isLast)

        // Setup callbacks
        cell.onCardTapped = {
            print("[Demo] Card tapped at section \(indexPath.section), row \(indexPath.row)")
        }

        cell.onOutcomeSelected = { outcomeId in
            print("[Demo] Outcome selected: \(outcomeId)")
        }

        cell.onOutcomeDeselected = { outcomeId in
            print("[Demo] Outcome deselected: \(outcomeId)")
        }

        cell.onMoreMarketsTapped = {
            print("[Demo] More markets tapped")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Simulation Target (Row 0)" : "Additional Cards (Cell Reuse Test)"
    }
}

// MARK: - UITableViewDelegate

extension InlineMatchCardViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = StyleProvider.Color.textSecondary
            header.textLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
        }
    }
}

// MARK: - Factory Methods

extension InlineMatchCardViewController {

    private static func createControlPanel() -> UIView {
        let view = UIView()
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }

    private static func createTableView() -> UITableView {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = StyleProvider.Color.backgroundPrimary
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }

    private static func createScenarioControl() -> UISegmentedControl {
        let scenarios = InlineMatchCardSimulatorScenario.allScenarios
        let titles = scenarios.map { $0.name.replacingOccurrences(of: " ", with: "\n") }
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false

        // Adjust font for multi-line if needed
        let font = UIFont.systemFont(ofSize: 10, weight: .medium)
        control.setTitleTextAttributes([.font: font], for: .normal)

        return control
    }

    private static func createSpeedControl() -> UISegmentedControl {
        let speeds = InlineMatchCardSimulator.Speed.allCases.map { $0.title }
        let control = UISegmentedControl(items: speeds)
        control.selectedSegmentIndex = 1 // Normal
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }

    private static func createPlayPauseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = StyleProvider.Color.highlightPrimary
        button.layer.cornerRadius = 8
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        return button
    }

    private static func createStopButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }

    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.text = "Status: Idle"
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
