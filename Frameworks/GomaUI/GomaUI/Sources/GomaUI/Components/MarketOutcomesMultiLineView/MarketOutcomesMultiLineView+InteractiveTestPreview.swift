//
//  MarketOutcomesMultiLineView+InteractiveTestPreview.swift
//  GomaUI
//
//  Interactive test suite for MarketOutcomesMultiLineView
//  Tests cell reuse, odds updates, market states, and all component behaviors
//

#if DEBUG
import UIKit
import Combine
import SwiftUI

/// Interactive test controller for comprehensively testing MarketOutcomesMultiLineView
/// Use this to verify cell reuse fix, odds animations, state changes, and all component behaviors
final class MarketOutcomesMultiLineInteractiveTestViewController: UIViewController {

    // MARK: - UI Components

    // Component under test
    private lazy var multiLineView = MarketOutcomesMultiLineView(viewModel: multiLineViewModel)
    private lazy var stateLabel: UILabel = Self.createStateLabel()
    private lazy var componentContainer: UIView = Self.createComponentContainer()

    // Scroll container
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()

    // Control sections
    private lazy var displayStateSection: UIStackView = Self.createControlSection(title: "1. Display State")
    private lazy var structureSection: UIStackView = Self.createControlSection(title: "2. Structure Controls")
    private lazy var lineControlSection: UIStackView = Self.createControlSection(title: "3. Line-Level Controls")
    private lazy var outcomeControlSection: UIStackView = Self.createControlSection(title: "4. Outcome-Level Controls")
    private lazy var cellReuseSection: UIStackView = Self.createControlSection(title: "5. Cell Reuse Simulation ⭐")
    private lazy var betslipSection: UIStackView = Self.createControlSection(title: "6. Betslip Sync")
    private lazy var animationSection: UIStackView = Self.createControlSection(title: "7. Batch Animation Testing")

    // Event log
    private lazy var eventLogTextView: UITextView = Self.createEventLogTextView()
    private lazy var clearLogButton: UIButton = Self.createButton(title: "Clear Log", backgroundColor: .systemGray)

    // State inspector
    private lazy var stateInspectorTextView: UITextView = Self.createStateInspectorTextView()

    // Line/Outcome selectors
    private lazy var lineSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Line 0", "Line 1", "Line 2"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(lineSelectionChanged), for: .valueChanged)
        return control
    }()

    private lazy var outcomeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Left", "Middle", "Right"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private lazy var animationSpeedSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 2.0
        slider.value = 0.5
        return slider
    }()

    private lazy var animationSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = "Delay: 0.5s"
        return label
    }()

    // MARK: - Properties

    private var lineViewModels: [MockMarketOutcomesLineViewModel] = []
    private var multiLineViewModel: MockMarketOutcomesMultiLineViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var selectedLineIndex: Int = 0
    private var callbacksRestored = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViewModels()
        setupView()
        setupBindings()
        setupCallbacks()
        updateStateInspector()
        logEvent("🚀 Interactive test suite loaded")
    }

    // MARK: - Setup

    private func setupInitialViewModels() {
        // Create 3 line ViewModels with different configurations
        let line0 = MockMarketOutcomesLineViewModel.threeWayMarket // Home/Draw/Away
        let line1 = MockMarketOutcomesLineViewModel.twoWayMarket   // Over/Under
        let line2 = MockMarketOutcomesLineViewModel.threeWayMarket // Another 3-way

        lineViewModels = [line0, line1, line2]

        // Create multi-line ViewModel
        multiLineViewModel = MockMarketOutcomesMultiLineViewModel(
            lineViewModels: lineViewModels,
            groupTitle: "Total Goals",
            isEmpty: false
        )
    }

    private func setupView() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Interactive Test Suite"

        buildViewHierarchy()
        setupConstraints()
    }

    private func buildViewHierarchy() {
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        // Title label
        let titleLabel = Self.createSectionTitle("MarketOutcomesMultiLineView Test Suite")
        contentStackView.addArrangedSubview(titleLabel)

        // Component display area
        contentStackView.addArrangedSubview(componentContainer)
        componentContainer.addSubview(multiLineView)
        componentContainer.addSubview(stateLabel)

        // Add all control sections
        addDisplayStateControls()
        addStructureControls()
        addLineControls()
        addOutcomeControls()
        addCellReuseControls()
        addBetslipControls()
        addAnimationControls()

        // State inspector
        let inspectorLabel = Self.createSectionTitle("State Inspector")
        contentStackView.addArrangedSubview(inspectorLabel)
        contentStackView.addArrangedSubview(stateInspectorTextView)

        // Event log
        let logLabel = Self.createSectionTitle("Event Log")
        contentStackView.addArrangedSubview(logLabel)
        contentStackView.addArrangedSubview(eventLogTextView)
        contentStackView.addArrangedSubview(clearLogButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            // Component container
            componentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),

            // Multi-line view in container
            multiLineView.topAnchor.constraint(equalTo: componentContainer.topAnchor, constant: 40),
            multiLineView.leadingAnchor.constraint(equalTo: componentContainer.leadingAnchor, constant: 12),
            multiLineView.trailingAnchor.constraint(equalTo: componentContainer.trailingAnchor, constant: -12),
            multiLineView.bottomAnchor.constraint(equalTo: componentContainer.bottomAnchor, constant: -12),

            // State label
            stateLabel.topAnchor.constraint(equalTo: componentContainer.topAnchor, constant: 12),
            stateLabel.leadingAnchor.constraint(equalTo: componentContainer.leadingAnchor, constant: 12),
            stateLabel.trailingAnchor.constraint(equalTo: componentContainer.trailingAnchor, constant: -12),

            // State inspector height
            stateInspectorTextView.heightAnchor.constraint(equalToConstant: 200),

            // Event log height
            eventLogTextView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupBindings() {
        // Subscribe to multi-line display state
        multiLineViewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateStateLabel()
                self?.updateStateInspector()
            }
            .store(in: &cancellables)

        // Subscribe to line view models changes
        multiLineViewModel.lineViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStateLabel()
                self?.updateStateInspector()
                self?.logEvent("📋 Line ViewModels changed")
            }
            .store(in: &cancellables)

        // Subscribe to each line's market state for logging
        for (index, lineVM) in lineViewModels.enumerated() {
            lineVM.marketStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.updateStateInspector()
                }
                .store(in: &cancellables)
        }

        // Animation slider
        animationSpeedSlider.addTarget(self, action: #selector(animationSpeedChanged), for: .valueChanged)
    }

    private func setupCallbacks() {
        multiLineView.onOutcomeSelected = { [weak self] outcomeId, outcomeType in
            self?.logEvent("✅ Outcome SELECTED: \(outcomeId) (\(outcomeType))")
            self?.updateStateInspector()
            self?.callbacksRestored = true
        }

        multiLineView.onOutcomeDeselected = { [weak self] outcomeId, outcomeType in
            self?.logEvent("❌ Outcome DESELECTED: \(outcomeId) (\(outcomeType))")
            self?.updateStateInspector()
            self?.callbacksRestored = true
        }

        multiLineView.onOutcomeLongPress = { [weak self] outcomeId, outcomeType in
            self?.logEvent("👆 Outcome LONG PRESS: \(outcomeId) (\(outcomeType))")
        }

        multiLineView.onLineSuspended = { [weak self] lineId in
            self?.logEvent("⏸️ Line SUSPENDED: \(lineId)")
        }

        multiLineView.onLineResumed = { [weak self] lineId in
            self?.logEvent("▶️ Line RESUMED: \(lineId)")
        }

        multiLineView.onOddsChanged = { [weak self] lineId, outcomeType, oldValue, newValue in
            self?.logEvent("📊 Odds CHANGED: Line \(lineId), \(outcomeType): \(oldValue) → \(newValue)")
        }

        callbacksRestored = true
    }

    // MARK: - Control Sections

    private func addDisplayStateControls() {
        let buttons = UIStackView()
        buttons.axis = .horizontal
        buttons.spacing = 8
        buttons.distribution = .fillEqually

        buttons.addArrangedSubview(Self.createButton(title: "Content", action: #selector(showContentState)))
        buttons.addArrangedSubview(Self.createButton(title: "Loading", action: #selector(showLoadingState)))
        buttons.addArrangedSubview(Self.createButton(title: "Error", action: #selector(showErrorState)))
        buttons.addArrangedSubview(Self.createButton(title: "Empty", action: #selector(showEmptyState)))

        displayStateSection.addArrangedSubview(buttons)
        contentStackView.addArrangedSubview(displayStateSection)
    }

    private func addStructureControls() {
        let lineCountButtons = UIStackView()
        lineCountButtons.axis = .horizontal
        lineCountButtons.spacing = 8
        lineCountButtons.distribution = .fillEqually

        lineCountButtons.addArrangedSubview(Self.createButton(title: "1 Line", action: #selector(setOneLine)))
        lineCountButtons.addArrangedSubview(Self.createButton(title: "2 Lines", action: #selector(setTwoLines)))
        lineCountButtons.addArrangedSubview(Self.createButton(title: "3 Lines", action: #selector(setThreeLines)))
        lineCountButtons.addArrangedSubview(Self.createButton(title: "5 Lines", action: #selector(setFiveLines)))

        let otherButtons = UIStackView()
        otherButtons.axis = .horizontal
        otherButtons.spacing = 8
        otherButtons.distribution = .fillEqually

        otherButtons.addArrangedSubview(Self.createButton(title: "Mixed Layout", action: #selector(setMixedLayout)))
        otherButtons.addArrangedSubview(Self.createButton(title: "Toggle Title", action: #selector(toggleGroupTitle)))

        structureSection.addArrangedSubview(lineCountButtons)
        structureSection.addArrangedSubview(otherButtons)
        contentStackView.addArrangedSubview(structureSection)
    }

    private func addLineControls() {
        lineControlSection.addArrangedSubview(lineSegmentedControl)

        let displayModeButtons = UIStackView()
        displayModeButtons.axis = .horizontal
        displayModeButtons.spacing = 8
        displayModeButtons.distribution = .fillEqually

        displayModeButtons.addArrangedSubview(Self.createButton(title: "Single", action: #selector(setSingleMode)))
        displayModeButtons.addArrangedSubview(Self.createButton(title: "Double", action: #selector(setDoubleMode)))
        displayModeButtons.addArrangedSubview(Self.createButton(title: "Triple", action: #selector(setTripleMode)))

        let suspendButtons = UIStackView()
        suspendButtons.axis = .horizontal
        suspendButtons.spacing = 8
        suspendButtons.distribution = .fillEqually

        suspendButtons.addArrangedSubview(Self.createButton(title: "Suspend Line", action: #selector(suspendSelectedLine), backgroundColor: .systemOrange))
        suspendButtons.addArrangedSubview(Self.createButton(title: "Resume Line", action: #selector(resumeSelectedLine), backgroundColor: .systemGreen))

        lineControlSection.addArrangedSubview(displayModeButtons)
        lineControlSection.addArrangedSubview(suspendButtons)
        contentStackView.addArrangedSubview(lineControlSection)
    }

    private func addOutcomeControls() {
        outcomeControlSection.addArrangedSubview(outcomeSegmentedControl)

        let selectionButtons = UIStackView()
        selectionButtons.axis = .horizontal
        selectionButtons.spacing = 8
        selectionButtons.distribution = .fillEqually

        selectionButtons.addArrangedSubview(Self.createButton(title: "Toggle Selection", action: #selector(toggleOutcomeSelection)))
        selectionButtons.addArrangedSubview(Self.createButton(title: "Toggle Disabled", action: #selector(toggleOutcomeDisabled)))

        let oddsButtons = UIStackView()
        oddsButtons.axis = .horizontal
        oddsButtons.spacing = 8
        oddsButtons.distribution = .fillEqually

        oddsButtons.addArrangedSubview(Self.createButton(title: "Odds Up", action: #selector(oddsUp), backgroundColor: .systemGreen))
        oddsButtons.addArrangedSubview(Self.createButton(title: "Odds Down", action: #selector(oddsDown), backgroundColor: .systemRed))
        oddsButtons.addArrangedSubview(Self.createButton(title: "Clear Indicator", action: #selector(clearOddsIndicator)))

        outcomeControlSection.addArrangedSubview(selectionButtons)
        outcomeControlSection.addArrangedSubview(oddsButtons)
        contentStackView.addArrangedSubview(outcomeControlSection)
    }

    private func addCellReuseControls() {
        let reuseButtons = UIStackView()
        reuseButtons.axis = .vertical
        reuseButtons.spacing = 8

        reuseButtons.addArrangedSubview(Self.createButton(
            title: "✅ Simulate Cell Reuse (same VM)",
            action: #selector(simulateCellReuse),
            backgroundColor: .systemBlue
        ))
        reuseButtons.addArrangedSubview(Self.createButton(
            title: "🔄 Simulate Sport Change (new VM)",
            action: #selector(simulateSportChange),
            backgroundColor: .systemPurple
        ))
        reuseButtons.addArrangedSubview(Self.createButton(
            title: "🧪 Test Selection Persistence",
            action: #selector(testSelectionPersistence),
            backgroundColor: .systemTeal
        ))
        reuseButtons.addArrangedSubview(Self.createButton(
            title: "🎯 Test Callback Restoration",
            action: #selector(testCallbackRestoration),
            backgroundColor: .systemIndigo
        ))

        cellReuseSection.addArrangedSubview(reuseButtons)
        contentStackView.addArrangedSubview(cellReuseSection)
    }

    private func addBetslipControls() {
        let betslipButtons = UIStackView()
        betslipButtons.axis = .horizontal
        betslipButtons.spacing = 8
        betslipButtons.distribution = .fillEqually

        betslipButtons.addArrangedSubview(Self.createButton(title: "Select All", action: #selector(selectAllOutcomes)))
        betslipButtons.addArrangedSubview(Self.createButton(title: "Deselect All", action: #selector(deselectAllOutcomes)))
        betslipButtons.addArrangedSubview(Self.createButton(title: "Select Random 3", action: #selector(selectRandomThree)))

        betslipSection.addArrangedSubview(betslipButtons)
        contentStackView.addArrangedSubview(betslipSection)
    }

    private func addAnimationControls() {
        let sliderStack = UIStackView()
        sliderStack.axis = .horizontal
        sliderStack.spacing = 8
        sliderStack.alignment = .center

        let sliderLabel = UILabel()
        sliderLabel.text = "Delay:"
        sliderLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        sliderLabel.textColor = StyleProvider.Color.textSecondary
        sliderLabel.setContentHuggingPriority(.required, for: .horizontal)

        sliderStack.addArrangedSubview(sliderLabel)
        sliderStack.addArrangedSubview(animationSpeedSlider)
        sliderStack.addArrangedSubview(animationSpeedLabel)

        let animButtons = UIStackView()
        animButtons.axis = .horizontal
        animButtons.spacing = 8
        animButtons.distribution = .fillEqually

        animButtons.addArrangedSubview(Self.createButton(title: "Rapid Odds (5x)", action: #selector(rapidOddsChanges)))
        animButtons.addArrangedSubview(Self.createButton(title: "Selection Wave", action: #selector(selectionWave)))
        animButtons.addArrangedSubview(Self.createButton(title: "Suspend All", action: #selector(suspendAllLines)))

        animationSection.addArrangedSubview(sliderStack)
        animationSection.addArrangedSubview(animButtons)
        contentStackView.addArrangedSubview(animationSection)
    }

    // MARK: - Actions - Display State

    @objc private func showContentState() {
        logEvent("🎬 Showing content state")
        // Reset to content with current lines
        updateMultiLineViewModel()
    }

    @objc private func showLoadingState() {
        logEvent("⏳ Showing loading state")
        multiLineView.showLoadingState()
    }

    @objc private func showErrorState() {
        logEvent("❌ Showing error state")
        multiLineView.showErrorState("Failed to load markets")
    }

    @objc private func showEmptyState() {
        logEvent("📭 Showing empty state")
        lineViewModels.removeAll()
        updateMultiLineViewModel()
    }

    // MARK: - Actions - Structure

    @objc private func setOneLine() {
        logEvent("📊 Setting 1 line (structure change)")
        lineViewModels = [MockMarketOutcomesLineViewModel.threeWayMarket]
        updateMultiLineViewModel()
        updateLineSegmentedControl()
    }

    @objc private func setTwoLines() {
        logEvent("📊 Setting 2 lines (structure change)")
        lineViewModels = [
            MockMarketOutcomesLineViewModel.threeWayMarket,
            MockMarketOutcomesLineViewModel.twoWayMarket
        ]
        updateMultiLineViewModel()
        updateLineSegmentedControl()
    }

    @objc private func setThreeLines() {
        logEvent("📊 Setting 3 lines (structure change)")
        lineViewModels = [
            MockMarketOutcomesLineViewModel.threeWayMarket,
            MockMarketOutcomesLineViewModel.twoWayMarket,
            MockMarketOutcomesLineViewModel.threeWayMarket
        ]
        updateMultiLineViewModel()
        updateLineSegmentedControl()
    }

    @objc private func setFiveLines() {
        logEvent("📊 Setting 5 lines (structure change)")
        lineViewModels = [
            MockMarketOutcomesLineViewModel.threeWayMarket,
            MockMarketOutcomesLineViewModel.twoWayMarket,
            MockMarketOutcomesLineViewModel.threeWayMarket,
            MockMarketOutcomesLineViewModel.twoWayMarket,
            MockMarketOutcomesLineViewModel.twoWayMarket
        ]
        updateMultiLineViewModel()
        updateLineSegmentedControl()
    }

    @objc private func setMixedLayout() {
        logEvent("📊 Setting mixed layout")
        lineViewModels = [
            MockMarketOutcomesLineViewModel.threeWayMarket,  // Triple
            MockMarketOutcomesLineViewModel.twoWayMarket,    // Double
            MockMarketOutcomesLineViewModel.singleMarket,    // Single
            MockMarketOutcomesLineViewModel.threeWayMarket   // Triple
        ]
        updateMultiLineViewModel()
        updateLineSegmentedControl()
    }

    @objc private func toggleGroupTitle() {
        let currentTitle = multiLineViewModel.displayStateSubject.value.groupTitle
        let newTitle = (currentTitle == nil || currentTitle?.isEmpty == true) ? "Total Goals" : nil
        logEvent("🏷️ Group title: \(newTitle ?? "nil")")

        multiLineViewModel = MockMarketOutcomesMultiLineViewModel(
            lineViewModels: lineViewModels,
            groupTitle: newTitle,
            isEmpty: lineViewModels.isEmpty
        )
        multiLineView.configure(with: multiLineViewModel)
        setupCallbacks()
    }

    // MARK: - Actions - Line Level

    @objc private func lineSelectionChanged() {
        selectedLineIndex = lineSegmentedControl.selectedSegmentIndex
        logEvent("🎯 Selected line: \(selectedLineIndex)")
        updateStateInspector()
    }

    @objc private func setSingleMode() {
        guard selectedLineIndex < lineViewModels.count else { return }
        logEvent("🔢 Line \(selectedLineIndex): Set single mode")
        lineViewModels[selectedLineIndex].setDisplayMode(.single)
    }

    @objc private func setDoubleMode() {
        guard selectedLineIndex < lineViewModels.count else { return }
        logEvent("🔢 Line \(selectedLineIndex): Set double mode")
        lineViewModels[selectedLineIndex].setDisplayMode(.double)
    }

    @objc private func setTripleMode() {
        guard selectedLineIndex < lineViewModels.count else { return }
        logEvent("🔢 Line \(selectedLineIndex): Set triple mode")
        lineViewModels[selectedLineIndex].setDisplayMode(.triple)
    }

    @objc private func suspendSelectedLine() {
        guard selectedLineIndex < lineViewModels.count else { return }
        logEvent("⏸️ Line \(selectedLineIndex): SUSPENDED")
        lineViewModels[selectedLineIndex].setDisplayMode(.suspended("Market Suspended"))
    }

    @objc private func resumeSelectedLine() {
        guard selectedLineIndex < lineViewModels.count else { return }
        logEvent("▶️ Line \(selectedLineIndex): RESUMED")
        lineViewModels[selectedLineIndex].setDisplayMode(.triple)
    }

    // MARK: - Actions - Outcome Level

    @objc private func toggleOutcomeSelection() {
        guard selectedLineIndex < lineViewModels.count else { return }
        let outcomeType = selectedOutcomeType()
        let isSelected = lineViewModels[selectedLineIndex].toggleOutcome(type: outcomeType)
        logEvent("🎯 Line \(selectedLineIndex), \(outcomeType): Selection = \(isSelected)")
    }

    @objc private func toggleOutcomeDisabled() {
        guard selectedLineIndex < lineViewModels.count else { return }
        let outcomeType = selectedOutcomeType()
        // Note: Mock doesn't have setDisabled, but we log the intent
        logEvent("🔒 Line \(selectedLineIndex), \(outcomeType): Toggle disabled (mock limitation)")
    }

    @objc private func oddsUp() {
        guard selectedLineIndex < lineViewModels.count else { return }
        let outcomeType = selectedOutcomeType()
        let currentState = lineViewModels[selectedLineIndex].marketStateSubject.value

        let currentValue: String
        switch outcomeType {
        case .left: currentValue = currentState.leftOutcome?.value ?? "0.00"
        case .middle: currentValue = currentState.middleOutcome?.value ?? "0.00"
        case .right: currentValue = currentState.rightOutcome?.value ?? "0.00"
        }

        let newValue = String(format: "%.2f", (Double(currentValue) ?? 0.0) + 0.10)
        lineViewModels[selectedLineIndex].updateOddsValue(type: outcomeType, newValue: newValue)
        logEvent("📈 Line \(selectedLineIndex), \(outcomeType): \(currentValue) → \(newValue) (UP)")
    }

    @objc private func oddsDown() {
        guard selectedLineIndex < lineViewModels.count else { return }
        let outcomeType = selectedOutcomeType()
        let currentState = lineViewModels[selectedLineIndex].marketStateSubject.value

        let currentValue: String
        switch outcomeType {
        case .left: currentValue = currentState.leftOutcome?.value ?? "0.00"
        case .middle: currentValue = currentState.middleOutcome?.value ?? "0.00"
        case .right: currentValue = currentState.rightOutcome?.value ?? "0.00"
        }

        let newValue = String(format: "%.2f", max(1.01, (Double(currentValue) ?? 0.0) - 0.10))
        lineViewModels[selectedLineIndex].updateOddsValue(type: outcomeType, newValue: newValue)
        logEvent("📉 Line \(selectedLineIndex), \(outcomeType): \(currentValue) → \(newValue) (DOWN)")
    }

    @objc private func clearOddsIndicator() {
        guard selectedLineIndex < lineViewModels.count else { return }
        let outcomeType = selectedOutcomeType()
        lineViewModels[selectedLineIndex].clearOddsChangeIndicator(type: outcomeType)
        logEvent("🧹 Line \(selectedLineIndex), \(outcomeType): Cleared odds indicator")
    }

    // MARK: - Actions - Cell Reuse (Critical for testing November fix)

    @objc private func simulateCellReuse() {
        logEvent("🔄 ═══ SIMULATING CELL REUSE (same VM) ═══")
        logEvent("   Step 1: Calling cleanupForReuse()...")
        multiLineView.cleanupForReuse()
        callbacksRestored = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.logEvent("   Step 2: Calling configure(with: same VM)...")
            self.multiLineView.configure(with: self.multiLineViewModel)

            self.logEvent("   Step 3: Re-establishing callbacks...")
            self.setupCallbacks()

            self.logEvent("   Step 4: Verifying state...")
            self.updateStateInspector()

            if self.callbacksRestored {
                self.logEvent("✅ Cell reuse SUCCESSFUL - Callbacks working!")
            } else {
                self.logEvent("⚠️ Callbacks not restored - Tap an outcome to test")
            }
        }
    }

    @objc private func simulateSportChange() {
        logEvent("🔄 ═══ SIMULATING SPORT CHANGE (new VM) ═══")
        logEvent("   Creating new ViewModels (Basketball)...")

        // Create completely new ViewModels
        let newLine0 = MockMarketOutcomesLineViewModel.twoWayMarket
        let newLine1 = MockMarketOutcomesLineViewModel.twoWayMarket

        lineViewModels = [newLine0, newLine1]

        let newMultiLineVM = MockMarketOutcomesMultiLineViewModel(
            lineViewModels: lineViewModels,
            groupTitle: "Basketball - Total Points",
            isEmpty: false
        )

        logEvent("   Calling configure(with: new VM)...")
        multiLineViewModel = newMultiLineVM
        multiLineView.configure(with: multiLineViewModel)

        logEvent("   Re-establishing callbacks...")
        setupCallbacks()

        logEvent("✅ Sport change complete")
        updateLineSegmentedControl()
    }

    @objc private func testSelectionPersistence() {
        logEvent("🧪 ═══ TESTING SELECTION PERSISTENCE ═══")

        // Step 1: Select some outcomes
        logEvent("   Step 1: Selecting outcomes...")
        if lineViewModels.count > 0 {
            lineViewModels[0].toggleOutcome(type: .left)
        }
        if lineViewModels.count > 1 {
            lineViewModels[1].toggleOutcome(type: .right)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            // Step 2: Simulate cell reuse
            self.logEvent("   Step 2: Simulating cell reuse...")
            self.multiLineView.cleanupForReuse()
            self.multiLineView.configure(with: self.multiLineViewModel)
            self.setupCallbacks()

            // Step 3: Check if selections are still visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.logEvent("   Step 3: Verifying selections...")
                self?.updateStateInspector()
                self?.logEvent("✅ Selection persistence test complete - Check visual state above")
            }
        }
    }

    @objc private func testCallbackRestoration() {
        logEvent("🎯 ═══ TESTING CALLBACK RESTORATION ═══")
        logEvent("   Step 1: Clearing callbacks with cleanupForReuse()...")

        callbacksRestored = false
        multiLineView.cleanupForReuse()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }

            self.logEvent("   Step 2: Reconfiguring...")
            self.multiLineView.configure(with: self.multiLineViewModel)

            self.logEvent("   Step 3: Restoring callbacks...")
            self.setupCallbacks()

            self.logEvent("   Step 4: Waiting for user interaction...")
            self.logEvent("👆 TAP ANY OUTCOME to verify callbacks work!")
            self.logEvent("   (Watch for 'Outcome SELECTED' message above)")
        }
    }

    // MARK: - Actions - Betslip Sync

    @objc private func selectAllOutcomes() {
        logEvent("✅ Selecting all visible outcomes...")
        for lineVM in lineViewModels {
            let state = lineVM.marketStateSubject.value
            if state.leftOutcome != nil {
                lineVM.setOutcomeSelected(type: .left)
            }
            if state.middleOutcome != nil {
                lineVM.setOutcomeSelected(type: .middle)
            }
            if state.rightOutcome != nil {
                lineVM.setOutcomeSelected(type: .right)
            }
        }
    }

    @objc private func deselectAllOutcomes() {
        logEvent("❌ Deselecting all outcomes...")
        for lineVM in lineViewModels {
            lineVM.setOutcomeDeselected(type: .left)
            lineVM.setOutcomeDeselected(type: .middle)
            lineVM.setOutcomeDeselected(type: .right)
        }
    }

    @objc private func selectRandomThree() {
        logEvent("🎲 Selecting 3 random outcomes...")
        deselectAllOutcomes()

        var count = 0
        let maxAttempts = 20
        var attempts = 0

        while count < 3 && attempts < maxAttempts {
            attempts += 1
            let randomLine = Int.random(in: 0..<lineViewModels.count)
            let randomOutcome = [OutcomeType.left, .middle, .right].randomElement()!

            let state = lineViewModels[randomLine].marketStateSubject.value
            let outcomeExists: Bool
            switch randomOutcome {
            case .left: outcomeExists = state.leftOutcome != nil
            case .middle: outcomeExists = state.middleOutcome != nil
            case .right: outcomeExists = state.rightOutcome != nil
            }

            if outcomeExists {
                lineViewModels[randomLine].setOutcomeSelected(type: randomOutcome)
                count += 1
            }
        }
    }

    // MARK: - Actions - Batch Animations

    @objc private func rapidOddsChanges() {
        logEvent("⚡ Starting rapid odds changes (5 sequential)...")
        let delay = TimeInterval(animationSpeedSlider.value)

        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(i)) { [weak self] in
                guard let self = self else { return }

                for (lineIndex, lineVM) in self.lineViewModels.enumerated() {
                    let state = lineVM.marketStateSubject.value

                    if let leftOutcome = state.leftOutcome {
                        let currentValue = Double(leftOutcome.value) ?? 1.50
                        let change = i % 2 == 0 ? 0.05 : -0.05
                        let newValue = String(format: "%.2f", currentValue + change)
                        lineVM.updateOddsValue(type: .left, newValue: newValue)
                    }
                }

                self.logEvent("⚡ Rapid change \(i + 1)/5")
            }
        }
    }

    @objc private func selectionWave() {
        logEvent("🌊 Starting selection wave...")
        let delay = TimeInterval(animationSpeedSlider.value)

        var index = 0
        for lineVM in lineViewModels {
            let state = lineVM.marketStateSubject.value

            if state.leftOutcome != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) { [weak lineVM] in
                    lineVM?.toggleOutcome(type: .left)
                }
                index += 1
            }

            if state.middleOutcome != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) { [weak lineVM] in
                    lineVM?.toggleOutcome(type: .middle)
                }
                index += 1
            }

            if state.rightOutcome != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) { [weak lineVM] in
                    lineVM?.toggleOutcome(type: .right)
                }
                index += 1
            }
        }
    }

    @objc private func suspendAllLines() {
        logEvent("⏸️ Suspending all lines sequentially...")
        let delay = TimeInterval(animationSpeedSlider.value)

        for (index, lineVM) in lineViewModels.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) { [weak lineVM] in
                lineVM?.setDisplayMode(.suspended("Suspended"))
            }
        }
    }

    @objc private func animationSpeedChanged() {
        let speed = animationSpeedSlider.value
        animationSpeedLabel.text = String(format: "Delay: %.1fs", speed)
    }

    // MARK: - Event Log

    private func logEvent(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        eventLogTextView.text = logMessage + eventLogTextView.text
    }

    @objc private func clearLog() {
        eventLogTextView.text = ""
        logEvent("🧹 Log cleared")
    }

    // MARK: - State Updates

    private func updateStateLabel() {
        let state = multiLineViewModel.displayStateSubject.value
        let lineCount = lineViewModels.count
        let title = state.groupTitle ?? "nil"
        stateLabel.text = "📊 Lines: \(lineCount) | Title: \(title) | Empty: \(state.isEmpty)"
    }

    private func updateStateInspector() {
        var text = ""

        // Component state
        let displayState = multiLineViewModel.displayStateSubject.value
        text += "┌─ Component State ─────────────┐\n"
        text += "│ Lines: \(lineViewModels.count)                        │\n"
        text += "│ Group Title: \"\(displayState.groupTitle ?? "nil")\"     │\n"
        text += "│ Empty: \(displayState.isEmpty)                   │\n"
        text += "└────────────────────────────────┘\n\n"

        // Selected line state
        if selectedLineIndex < lineViewModels.count {
            let lineVM = lineViewModels[selectedLineIndex]
            let state = lineVM.marketStateSubject.value

            text += "┌─ Line \(selectedLineIndex) State ────────────────┐\n"
            text += "│ Mode: \(state.displayMode)                   │\n"

            let outcomeCount = [state.leftOutcome, state.middleOutcome, state.rightOutcome].compactMap { $0 }.count
            text += "│ Outcomes: \(outcomeCount)                    │\n"

            var selectedOutcomes: [String] = []
            if state.leftOutcome?.isSelected == true { selectedOutcomes.append("Left") }
            if state.middleOutcome?.isSelected == true { selectedOutcomes.append("Middle") }
            if state.rightOutcome?.isSelected == true { selectedOutcomes.append("Right") }
            text += "│ Selected: [\(selectedOutcomes.joined(separator: ", "))]               │\n"

            if let left = state.leftOutcome {
                let indicator = left.oddsChangeDirection == .up ? " (UP)" : left.oddsChangeDirection == .down ? " (DOWN)" : ""
                text += "│ Left: \"\(left.title)\" = \(left.value)\(indicator)   │\n"
            }
            if let middle = state.middleOutcome {
                let indicator = middle.oddsChangeDirection == .up ? " (UP)" : middle.oddsChangeDirection == .down ? " (DOWN)" : ""
                text += "│ Middle: \"\(middle.title)\" = \(middle.value)\(indicator)   │\n"
            }
            if let right = state.rightOutcome {
                let indicator = right.oddsChangeDirection == .up ? " (UP)" : right.oddsChangeDirection == .down ? " (DOWN)" : ""
                text += "│ Right: \"\(right.title)\" = \(right.value)\(indicator)   │\n"
            }

            text += "└────────────────────────────────┘\n\n"
        }

        // Callbacks status
        text += "┌─ Callbacks Status ────────────┐\n"
        text += "│ \(callbacksRestored ? "✅" : "❌") onOutcomeSelected           │\n"
        text += "│ \(callbacksRestored ? "✅" : "❌") onOutcomeDeselected         │\n"
        text += "│ \(callbacksRestored ? "✅" : "❌") onOutcomeLongPress          │\n"
        text += "│ \(callbacksRestored ? "✅" : "❌") onLineSuspended             │\n"
        text += "│ \(callbacksRestored ? "✅" : "❌") onLineResumed               │\n"
        text += "└────────────────────────────────┘\n"

        stateInspectorTextView.text = text
    }

    private func updateMultiLineViewModel() {
        let currentTitle = multiLineViewModel.displayStateSubject.value.groupTitle
        multiLineViewModel = MockMarketOutcomesMultiLineViewModel(
            lineViewModels: lineViewModels,
            groupTitle: currentTitle,
            isEmpty: lineViewModels.isEmpty
        )
        multiLineView.configure(with: multiLineViewModel)
        setupCallbacks()
        updateStateLabel()
    }

    private func updateLineSegmentedControl() {
        lineSegmentedControl.removeAllSegments()
        for i in 0..<min(lineViewModels.count, 5) {
            lineSegmentedControl.insertSegment(withTitle: "Line \(i)", at: i, animated: false)
        }
        lineSegmentedControl.selectedSegmentIndex = min(selectedLineIndex, lineViewModels.count - 1)
    }

    // MARK: - Helpers

    private func selectedOutcomeType() -> OutcomeType {
        switch outcomeSegmentedControl.selectedSegmentIndex {
        case 0: return .left
        case 1: return .middle
        case 2: return .right
        default: return .left
        }
    }
}

// MARK: - Factory Methods

extension MarketOutcomesMultiLineInteractiveTestViewController {

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }

    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        return stackView
    }

    private static func createComponentContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        return view
    }

    private static func createStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 11)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        return label
    }

    private static func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }

    private static func createControlSection(title: String) -> UIStackView {
        let section = UIStackView()
        section.translatesAutoresizingMaskIntoConstraints = false
        section.axis = .vertical
        section.spacing = 8
        section.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        titleLabel.textColor = StyleProvider.Color.highlightPrimary

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = StyleProvider.Color.highlightPrimary.withAlphaComponent(0.3)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        section.addArrangedSubview(titleLabel)
        section.addArrangedSubview(separator)

        return section
    }

    private static func createButton(
        title: String,
        action: Selector,
        backgroundColor: UIColor = StyleProvider.Color.highlightPrimary
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 13)
        button.layer.cornerRadius = 6
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(nil, action: action, for: .touchUpInside)
        return button
    }

    private static func createEventLogTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = StyleProvider.fontWith(type: .regular, size: 11)
        textView.textColor = StyleProvider.Color.textPrimary
        textView.backgroundColor = StyleProvider.Color.backgroundSecondary
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = StyleProvider.Color.highlightSecondary.cgColor
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }

    private static func createStateInspectorTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: "Menlo-Regular", size: 11) ?? StyleProvider.fontWith(type: .regular, size: 11)
        textView.textColor = StyleProvider.Color.textPrimary
        textView.backgroundColor = StyleProvider.Color.backgroundSecondary
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = StyleProvider.Color.highlightTertiary.cgColor
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }
}

// MARK: - SwiftUI Preview

@available(iOS 17.0, *)
#Preview("Interactive Test Suite") {
    PreviewUIViewController {
        let navController = UINavigationController(
            rootViewController: MarketOutcomesMultiLineInteractiveTestViewController()
        )
        return navController
    }
}

#endif
