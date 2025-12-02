import Foundation
import Combine
import GomaUI

/// Orchestrates real-time updates across InlineMatchCardView child mocks
final class InlineMatchCardSimulator {

    // MARK: - Types

    enum Speed: CaseIterable {
        case slow      // 3.0s between updates
        case normal    // 1.5s between updates
        case fast      // 0.5s between updates

        var interval: TimeInterval {
            switch self {
            case .slow: return 3.0
            case .normal: return 1.5
            case .fast: return 0.5
            }
        }

        var title: String {
            switch self {
            case .slow: return "Slow"
            case .normal: return "Normal"
            case .fast: return "Fast"
            }
        }
    }

    enum SimulationState: Equatable {
        case idle
        case running
        case paused
    }

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<SimulationState, Never>(.idle)
    var statePublisher: AnyPublisher<SimulationState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var currentState: SimulationState {
        stateSubject.value
    }

    // MARK: - Properties

    private var updateTimer: Timer?
    private var scenario: InlineMatchCardSimulatorScenario?
    private var scenarioStep: Int = 0

    // Mocks to control
    private var headerViewModel: MockCompactMatchHeaderViewModel?
    private var outcomesViewModel: MockCompactOutcomesLineViewModel?
    private var scoreViewModel: MockInlineScoreViewModel?

    var speed: Speed = .normal

    var currentScenarioName: String {
        scenario?.name ?? "None"
    }

    // MARK: - Initialization

    init() {}

    /// Configure the simulator with view models to control
    func configure(
        headerViewModel: MockCompactMatchHeaderViewModel,
        outcomesViewModel: MockCompactOutcomesLineViewModel,
        scoreViewModel: MockInlineScoreViewModel?
    ) {
        self.headerViewModel = headerViewModel
        self.outcomesViewModel = outcomesViewModel
        self.scoreViewModel = scoreViewModel
    }

    // MARK: - Control Methods

    func start(scenario: InlineMatchCardSimulatorScenario) {
        stop()
        self.scenario = scenario
        self.scenarioStep = 0
        stateSubject.send(.running)
        print("[Simulator] Started scenario: \(scenario.name)")
        scheduleNextUpdate()
    }

    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        scenario = nil
        scenarioStep = 0
        stateSubject.send(.idle)
        print("[Simulator] Stopped")
    }

    func pause() {
        guard stateSubject.value == .running else { return }
        updateTimer?.invalidate()
        updateTimer = nil
        stateSubject.send(.paused)
        print("[Simulator] Paused")
    }

    func resume() {
        guard stateSubject.value == .paused else { return }
        stateSubject.send(.running)
        print("[Simulator] Resumed")
        scheduleNextUpdate()
    }

    func togglePlayPause() {
        switch stateSubject.value {
        case .idle:
            // Can't toggle if no scenario is set
            break
        case .running:
            pause()
        case .paused:
            resume()
        }
    }

    // MARK: - Private Methods

    private func scheduleNextUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: speed.interval,
            repeats: false
        ) { [weak self] _ in
            self?.executeNextStep()
        }
    }

    private func executeNextStep() {
        guard let scenario = scenario,
              stateSubject.value == .running else { return }

        if scenarioStep < scenario.steps.count {
            let step = scenario.steps[scenarioStep]
            executeStep(step)
            scenarioStep += 1
            scheduleNextUpdate()
        } else if scenario.repeats {
            scenarioStep = 0
            print("[Simulator] Scenario repeating...")
            scheduleNextUpdate()
        } else {
            print("[Simulator] Scenario completed")
            stop()
        }
    }

    private func executeStep(_ step: SimulationStep) {
        switch step {
        case .updateOdds(let outcomeType, let newValue, let direction):
            updateOdds(outcomeType: outcomeType, value: newValue, direction: direction)

        case .lockOutcome(let outcomeType):
            lockOutcome(outcomeType: outcomeType)

        case .unlockOutcome(let outcomeType, let value):
            unlockOutcome(outcomeType: outcomeType, value: value)

        case .updateScore(let columns):
            updateScore(columns: columns)

        case .updateHeaderMode(let mode):
            updateHeaderMode(mode)

        case .updateMarketCount(let count):
            updateMarketCount(count)

        case .selectOutcome(let outcomeType):
            selectOutcome(outcomeType: outcomeType)

        case .deselectOutcome(let outcomeType):
            deselectOutcome(outcomeType: outcomeType)

        case .clearScore:
            scoreViewModel?.setVisible(false)
            print("[Simulator] Score hidden")

        case .showScore:
            scoreViewModel?.setVisible(true)
            print("[Simulator] Score visible")
        }
    }

    // MARK: - Update Helpers

    private func updateOdds(outcomeType: OutcomeType, value: String, direction: OddsChangeDirection) {
        guard let outcomesVM = outcomesViewModel else { return }

        // Get the appropriate outcome mock
        let outcomeVM: MockOutcomeItemViewModel?
        switch outcomeType {
        case .left:
            outcomeVM = outcomesVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            outcomeVM = outcomesVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            outcomeVM = outcomesVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }

        outcomeVM?.updateValue(value, changeDirection: direction)
        print("[Simulator] Updated \(outcomeType) odds to \(value) (\(direction))")
    }

    private func lockOutcome(outcomeType: OutcomeType) {
        guard let outcomesVM = outcomesViewModel else { return }

        let outcomeVM: MockOutcomeItemViewModel?
        switch outcomeType {
        case .left:
            outcomeVM = outcomesVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            outcomeVM = outcomesVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            outcomeVM = outcomesVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }

        outcomeVM?.setDisplayState(.locked)
        print("[Simulator] Locked \(outcomeType)")
    }

    private func unlockOutcome(outcomeType: OutcomeType, value: String) {
        guard let outcomesVM = outcomesViewModel else { return }

        let outcomeVM: MockOutcomeItemViewModel?
        switch outcomeType {
        case .left:
            outcomeVM = outcomesVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            outcomeVM = outcomesVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            outcomeVM = outcomesVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }

        outcomeVM?.setDisplayState(.normal(isSelected: false, isBoosted: false))
        outcomeVM?.updateValue(value, changeDirection: .none)
        print("[Simulator] Unlocked \(outcomeType) with value \(value)")
    }

    private func updateScore(columns: [InlineScoreColumnData]) {
        scoreViewModel?.updateColumns(columns)
        print("[Simulator] Updated score: \(columns.map { "\($0.homeScore)-\($0.awayScore)" }.joined(separator: ", "))")
    }

    private func updateHeaderMode(_ mode: CompactMatchHeaderMode) {
        headerViewModel?.updateMode(mode)
        switch mode {
        case .preLive(let dateText):
            print("[Simulator] Header mode: Pre-live (\(dateText))")
        case .live(let statusText):
            print("[Simulator] Header mode: Live (\(statusText))")
        }
    }

    private func updateMarketCount(_ count: Int?) {
        headerViewModel?.updateMarketCount(count)
        print("[Simulator] Market count: \(count.map { String($0) } ?? "nil")")
    }

    private func selectOutcome(outcomeType: OutcomeType) {
        guard let outcomesVM = outcomesViewModel else { return }

        let outcomeVM: MockOutcomeItemViewModel?
        switch outcomeType {
        case .left:
            outcomeVM = outcomesVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            outcomeVM = outcomesVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            outcomeVM = outcomesVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }

        outcomeVM?.setSelected(true)
        print("[Simulator] Selected \(outcomeType)")
    }

    private func deselectOutcome(outcomeType: OutcomeType) {
        guard let outcomesVM = outcomesViewModel else { return }

        let outcomeVM: MockOutcomeItemViewModel?
        switch outcomeType {
        case .left:
            outcomeVM = outcomesVM.currentLeftOutcomeViewModel as? MockOutcomeItemViewModel
        case .middle:
            outcomeVM = outcomesVM.currentMiddleOutcomeViewModel as? MockOutcomeItemViewModel
        case .right:
            outcomeVM = outcomesVM.currentRightOutcomeViewModel as? MockOutcomeItemViewModel
        }

        outcomeVM?.setSelected(false)
        print("[Simulator] Deselected \(outcomeType)")
    }
}
