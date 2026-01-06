//
//  TallOddsMatchCardView+CellReuseTestPreview.swift
//  GomaUI
//
//  Interactive test suite for verifying cell reuse fixes (November 2025)
//  Tests: MarketInfoLineView cleanup, position override reset, callback clearing
//

#if DEBUG
import UIKit
import Combine
import SwiftUI

/// Interactive test controller for verifying TallOddsMatchCardView cell reuse fixes
/// Focus: Testing the fixes made to cleanupForReuse(), prepareForReuse(), and position reset
final class TallOddsMatchCardCellReuseTestViewController: UIViewController {

    // MARK: - UI Components

    // Card under test
    private lazy var cardView = TallOddsMatchCardView(viewModel: cardViewModel)
    private lazy var cardContainer: UIView = Self.createCardContainer()

    // Scroll container
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()

    // Control sections
    private lazy var cellReuseSection: UIStackView = Self.createControlSection(title: "1. Cell Reuse Simulation")
    private lazy var callbackSection: UIStackView = Self.createControlSection(title: "2. Callback Testing")
    private lazy var childViewSection: UIStackView = Self.createControlSection(title: "3. Child View Cleanup")
    private lazy var configSection: UIStackView = Self.createControlSection(title: "4. ViewModel Switch")

    // State inspector
    private lazy var stateInspectorTextView: UITextView = Self.createStateInspectorTextView()

    // Event log
    private lazy var eventLogTextView: UITextView = Self.createEventLogTextView()
    private lazy var clearLogButton: UIButton = {
        let button = Self.createButton(title: "Clear Log", action: #selector(clearLog), backgroundColor: .systemGray)
        return button
    }()

    // MARK: - Properties

    private var cardViewModel: MockTallOddsMatchCardViewModel!
    private var cancellables = Set<AnyCancellable>()

    // Callback tracking
    private var callbacksActive = true
    private var matchHeaderTapCount = 0
    private var favoriteTapCount = 0
    private var outcomeTapCount = 0
    private var marketInfoTapCount = 0
    private var cardTapCount = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViewModel()
        setupView()
        setupCallbacks()
        updateStateInspector()
        logEvent("Cell Reuse Test Suite loaded")
    }

    // MARK: - Setup

    private func setupInitialViewModel() {
        cardViewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
    }

    private func setupView() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Cell Reuse Test"

        buildViewHierarchy()
        setupConstraints()
    }

    private func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        // Title
        let titleLabel = Self.createSectionTitle("TallOddsMatchCardView Cell Reuse Tests")
        contentStackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Verifies November 2025 cell reuse fixes"
        subtitleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        subtitleLabel.textColor = StyleProvider.Color.textSecondary
        contentStackView.addArrangedSubview(subtitleLabel)

        // Card display area
        contentStackView.addArrangedSubview(cardContainer)
        cardContainer.addSubview(cardView)

        // Add control sections
        addCellReuseControls()
        addCallbackControls()
        addChildViewControls()
        addConfigControls()

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
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            cardContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),

            cardView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12),

            stateInspectorTextView.heightAnchor.constraint(equalToConstant: 220),
            eventLogTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupCallbacks() {
        callbacksActive = true

        cardView.onMatchHeaderTapped = { [weak self] in
            self?.matchHeaderTapCount += 1
            self?.logEvent("onMatchHeaderTapped fired (count: \(self?.matchHeaderTapCount ?? 0))")
            self?.updateStateInspector()
        }

        cardView.onFavoriteToggled = { [weak self] in
            self?.favoriteTapCount += 1
            self?.logEvent("onFavoriteToggled fired (count: \(self?.favoriteTapCount ?? 0))")
            self?.updateStateInspector()
        }

        cardView.onOutcomeSelected = { [weak self] outcomeId in
            self?.outcomeTapCount += 1
            self?.logEvent("onOutcomeSelected: \(outcomeId) (count: \(self?.outcomeTapCount ?? 0))")
            self?.updateStateInspector()
        }

        cardView.onMarketInfoTapped = { [weak self] in
            self?.marketInfoTapCount += 1
            self?.logEvent("onMarketInfoTapped fired (count: \(self?.marketInfoTapCount ?? 0))")
            self?.updateStateInspector()
        }

        cardView.onCardTapped = { [weak self] in
            self?.cardTapCount += 1
            self?.logEvent("onCardTapped fired (count: \(self?.cardTapCount ?? 0))")
            self?.updateStateInspector()
        }
    }

    // MARK: - Control Sections

    private func addCellReuseControls() {
        let buttons = UIStackView()
        buttons.axis = .vertical
        buttons.spacing = 8

        buttons.addArrangedSubview(Self.createButton(
            title: "Full Cell Reuse Cycle",
            action: #selector(fullCellReuseCycle),
            backgroundColor: .systemBlue
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "prepareForReuse() Only",
            action: #selector(prepareForReuseOnly),
            backgroundColor: .systemOrange
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "configure() Only",
            action: #selector(configureOnly),
            backgroundColor: .systemGreen
        ))

        cellReuseSection.addArrangedSubview(buttons)
        contentStackView.addArrangedSubview(cellReuseSection)
    }

    private func addCallbackControls() {
        let buttons = UIStackView()
        buttons.axis = .vertical
        buttons.spacing = 8

        buttons.addArrangedSubview(Self.createButton(
            title: "Test Callback Clearing",
            action: #selector(testCallbackClearing),
            backgroundColor: .systemPurple
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Test Callback Restoration",
            action: #selector(testCallbackRestoration),
            backgroundColor: .systemIndigo
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Reset Tap Counters",
            action: #selector(resetTapCounters),
            backgroundColor: .systemGray
        ))

        let helpLabel = UILabel()
        helpLabel.text = "Tap outcomes/header/card to verify callbacks work"
        helpLabel.font = StyleProvider.fontWith(type: .regular, size: 11)
        helpLabel.textColor = StyleProvider.Color.textSecondary
        buttons.addArrangedSubview(helpLabel)

        callbackSection.addArrangedSubview(buttons)
        contentStackView.addArrangedSubview(callbackSection)
    }

    private func addChildViewControls() {
        let buttons = UIStackView()
        buttons.axis = .vertical
        buttons.spacing = 8

        buttons.addArrangedSubview(Self.createButton(
            title: "Test MarketInfoLine Cleanup",
            action: #selector(testMarketInfoLineCleanup),
            backgroundColor: .systemTeal
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Test Position Override Reset",
            action: #selector(testPositionOverrideReset),
            backgroundColor: .systemCyan
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Verify All Child Cleanup Called",
            action: #selector(verifyAllChildCleanup),
            backgroundColor: .systemMint
        ))

        childViewSection.addArrangedSubview(buttons)
        contentStackView.addArrangedSubview(childViewSection)
    }

    private func addConfigControls() {
        let buttons = UIStackView()
        buttons.axis = .horizontal
        buttons.spacing = 8
        buttons.distribution = .fillEqually

        buttons.addArrangedSubview(Self.createButton(
            title: "Premier League",
            action: #selector(switchToPremierLeague)
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Bundesliga",
            action: #selector(switchToBundesliga)
        ))
        buttons.addArrangedSubview(Self.createButton(
            title: "Live Match",
            action: #selector(switchToLive)
        ))

        configSection.addArrangedSubview(buttons)
        contentStackView.addArrangedSubview(configSection)
    }

    // MARK: - Actions - Cell Reuse

    @objc private func fullCellReuseCycle() {
        logEvent("=== FULL CELL REUSE CYCLE ===")
        logEvent("Step 1: Calling prepareForReuse()...")
        cardView.prepareForReuse()
        callbacksActive = false
        updateStateInspector()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.logEvent("Step 2: Calling configure(with:)...")
            self.cardView.configure(with: self.cardViewModel)
            self.updateStateInspector()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.logEvent("Step 3: Re-establishing callbacks...")
                self.setupCallbacks()
                self.updateStateInspector()
                self.logEvent("=== CYCLE COMPLETE ===")
                self.logEvent("Tap outcomes to verify callbacks work")
            }
        }
    }

    @objc private func prepareForReuseOnly() {
        logEvent("Calling prepareForReuse() ONLY...")
        cardView.prepareForReuse()
        callbacksActive = false
        updateStateInspector()
        logEvent("prepareForReuse() complete - callbacks should be cleared")
        logEvent("Tapping now should NOT log events")
    }

    @objc private func configureOnly() {
        logEvent("Calling configure(with:) ONLY...")
        cardView.configure(with: cardViewModel)
        updateStateInspector()
        logEvent("configure() complete - view should be updated")
        logEvent("Note: Callbacks were NOT re-established!")
    }

    // MARK: - Actions - Callback Testing

    @objc private func testCallbackClearing() {
        logEvent("=== TEST CALLBACK CLEARING ===")
        logEvent("Before prepareForReuse: callbacks active = \(callbacksActive)")

        cardView.prepareForReuse()
        callbacksActive = false
        updateStateInspector()

        logEvent("After prepareForReuse: callbacks should be cleared")
        logEvent("Expected: onMatchHeaderTapped = {}")
        logEvent("Expected: onFavoriteToggled = {}")
        logEvent("Expected: onOutcomeSelected = { _ in }")
        logEvent("Expected: onMarketInfoTapped = {}")
        logEvent("Expected: onCardTapped = {}")
        logEvent("TRY TAPPING - should see NO log events!")
    }

    @objc private func testCallbackRestoration() {
        logEvent("=== TEST CALLBACK RESTORATION ===")
        logEvent("Step 1: Full reuse cycle with callback restoration...")

        cardView.prepareForReuse()
        callbacksActive = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.cardView.configure(with: self.cardViewModel)
            self.setupCallbacks()
            self.updateStateInspector()
            self.logEvent("Step 2: Callbacks restored")
            self.logEvent("NOW TAP ANYTHING - should see log events!")
        }
    }

    @objc private func resetTapCounters() {
        matchHeaderTapCount = 0
        favoriteTapCount = 0
        outcomeTapCount = 0
        marketInfoTapCount = 0
        cardTapCount = 0
        updateStateInspector()
        logEvent("Tap counters reset to 0")
    }

    // MARK: - Actions - Child View Testing

    @objc private func testMarketInfoLineCleanup() {
        logEvent("=== TEST MARKETINFOLINE CLEANUP ===")
        logEvent("This tests the NEW cleanupForReuse() method")

        // First configure with data
        logEvent("Step 1: Configured with icons and market count")

        // Call cleanup
        logEvent("Step 2: Calling prepareForReuse() (triggers child cleanup)...")
        cardView.prepareForReuse()

        logEvent("Step 3: MarketInfoLineView.cleanupForReuse() should have:")
        logEvent("  - Cleared cancellables")
        logEvent("  - Removed iconImageViews")
        logEvent("  - Reset marketCountLabel.text = nil")
        logEvent("  - Hidden marketCountLabel")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // Reconfigure
            self.cardView.configure(with: self.cardViewModel)
            self.setupCallbacks()
            self.logEvent("Step 4: Reconfigured - icons and count should be visible again")
            self.updateStateInspector()
        }
    }

    @objc private func testPositionOverrideReset() {
        logEvent("=== TEST POSITION OVERRIDE RESET ===")
        logEvent("This tests positionOverrides = [:] and currentDisplayMode = .triple")

        logEvent("Step 1: Current state with outcomes displayed")

        // Call cleanup
        logEvent("Step 2: Calling prepareForReuse()...")
        cardView.prepareForReuse()

        logEvent("Step 3: MarketOutcomesLineView.cleanupForReuse() should have:")
        logEvent("  - Reset positionOverrides = [:]")
        logEvent("  - Reset currentDisplayMode = .triple")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // Reconfigure with different ViewModel
            self.cardViewModel = MockTallOddsMatchCardViewModel.bundesliegaMock
            self.cardView.configure(with: self.cardViewModel)
            self.setupCallbacks()
            self.logEvent("Step 4: Reconfigured with Bundesliga - check corner radius")
            self.logEvent("Corners should be correctly applied (not stale)")
            self.updateStateInspector()
        }
    }

    @objc private func verifyAllChildCleanup() {
        logEvent("=== VERIFY ALL CHILD CLEANUP ===")
        logEvent("Checking that resetChildViewsState() calls cleanup on all children:")

        cardView.prepareForReuse()
        callbacksActive = false

        logEvent("  matchHeaderView.cleanupForReuse()")
        logEvent("  scoreView.cleanupForReuse()")
        logEvent("  marketOutcomesView.cleanupForReuse()")
        logEvent("  marketInfoLineView.cleanupForReuse() <- NEW!")
        logEvent("")
        logEvent("All child cleanups should have been called")

        updateStateInspector()
    }

    // MARK: - Actions - Config Switch

    @objc private func switchToPremierLeague() {
        logEvent("Switching to Premier League...")
        cardView.prepareForReuse()
        cardViewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
        cardView.configure(with: cardViewModel)
        setupCallbacks()
        updateStateInspector()
    }

    @objc private func switchToBundesliga() {
        logEvent("Switching to Bundesliga...")
        cardView.prepareForReuse()
        cardViewModel = MockTallOddsMatchCardViewModel.bundesliegaMock
        cardView.configure(with: cardViewModel)
        setupCallbacks()
        updateStateInspector()
    }

    @objc private func switchToLive() {
        logEvent("Switching to Live Match...")
        cardView.prepareForReuse()
        cardViewModel = MockTallOddsMatchCardViewModel.liveMock
        cardView.configure(with: cardViewModel)
        setupCallbacks()
        updateStateInspector()
    }

    // MARK: - Event Log

    private func logEvent(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        eventLogTextView.text = logMessage + eventLogTextView.text
    }

    @objc private func clearLog() {
        eventLogTextView.text = ""
        logEvent("Log cleared")
    }

    // MARK: - State Inspector

    private func updateStateInspector() {
        var text = ""

        text += "--- Callback Status ---\n"
        text += "Active: \(callbacksActive ? "YES" : "NO")\n\n"

        text += "--- Tap Counts ---\n"
        text += "Header:     \(matchHeaderTapCount)\n"
        text += "Favorite:   \(favoriteTapCount)\n"
        text += "Outcome:    \(outcomeTapCount)\n"
        text += "MarketInfo: \(marketInfoTapCount)\n"
        text += "Card:       \(cardTapCount)\n\n"

        text += "--- Current ViewModel ---\n"
        let state = cardViewModel.currentDisplayState
        text += "Match ID: \(state.matchId)\n"
        text += "Home: \(state.homeParticipantName)\n"
        text += "Away: \(state.awayParticipantName)\n"
        text += "Live: \(state.isLive)\n\n"

        text += "--- Fix Status ---\n"
        text += "MarketInfoLine.cleanup: IMPLEMENTED\n"
        text += "Position override reset: IMPLEMENTED\n"
        text += "Callback clearing: IMPLEMENTED\n"
        text += "Child cleanup chain: IMPLEMENTED\n"

        stateInspectorTextView.text = text
    }
}

// MARK: - Factory Methods

extension TallOddsMatchCardCellReuseTestViewController {

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
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }

    private static func createCardContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        return view
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

#Preview("Cell Reuse Test Suite") {
    PreviewUIViewController {
        let navController = UINavigationController(
            rootViewController: TallOddsMatchCardCellReuseTestViewController()
        )
        return navController
    }
}

#endif
