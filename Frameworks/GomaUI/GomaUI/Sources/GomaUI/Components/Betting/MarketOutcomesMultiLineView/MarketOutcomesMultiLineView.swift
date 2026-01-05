import UIKit
import Combine
import SwiftUI

final public class MarketOutcomesMultiLineView: UIView {

    // MARK: - Private Properties
    // Main container
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    
    // Optional group title
    private lazy var groupTitleLabel: UILabel = Self.createGroupTitleLabel()
    
    // Container for all market lines
    private lazy var linesStackView: UIStackView = Self.createLinesStackView()
    
    // Loading, error and empty states
    private lazy var loadingContainer: UIView = Self.createLoadingContainer()
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var errorContainer: UIView = Self.createErrorContainer()
    private lazy var errorLabel: UILabel = Self.createErrorLabel()
    private lazy var emptyStateContainer: UIView = Self.createEmptyStateContainer()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    
    // Array to manage line views (simplified - view models come from the parent VM)
    private var lineViews: [MarketOutcomesLineView] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: MarketOutcomesMultiLineViewModelProtocol

    // MARK: - Public Properties
    public var onOutcomeSelected: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onOutcomeDeselected: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onOutcomeLongPress: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onLineSuspended: ((String) -> Void) = { _ in }
    public var onLineResumed: ((String) -> Void) = { _ in }
    public var onOddsChanged: ((String, OutcomeType, String, String) -> Void) = { _, _, _, _ in }
    public var onGroupExpansionToggled: ((Bool) -> Void) = { _ in }

    // MARK: - Constants
    private enum Constants {
        static let lineSpacing: CGFloat = 1.0
        static let groupTitleBottomSpacing: CGFloat = 12.0
        static let containerPadding: CGFloat = 0.0
        static let disabledAlpha: CGFloat = 0.5
        static let emptyStateHeight: CGFloat = 50.0
        static let cornerRadius: CGFloat = 4.5
    }

    // MARK: - Initialization
    public init(viewModel: MarketOutcomesMultiLineViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()

        // ✅ CRITICAL: Configure immediately with current data (synchronous for UITableView sizing)
        configureImmediately(with: viewModel)

        // Subscribe to updates for real-time changes (asynchronous)
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    /// Cleans up the view for reuse in table/collection views
    /// Call this in prepareForReuse() before configuring with a new view model
    public func cleanupForReuse() {
        // Clear bindings
        cancellables.removeAll()

        // Clear child view callbacks (prevent stale references)
        lineViews.forEach { lineView in
            lineView.onOutcomeSelected = { _, _ in }
            lineView.onOutcomeDeselected = { _, _ in }
            lineView.onOutcomeLongPress = { _ in }
            lineView.onSeeAllTapped = { }
        }

        // Clear all local callbacks (prevent stale closures after cell reuse)
        onOutcomeSelected = { _, _ in }
        onOutcomeDeselected = { _, _ in }
        onOutcomeLongPress = { _, _ in }
        onLineSuspended = { _ in }
        onLineResumed = { _ in }
        onOddsChanged = { _, _, _, _ in }
        onGroupExpansionToggled = { _ in }
    }

    /// Configures the view with a new view model for efficient reuse
    /// Following GomaUI guidelines: reuses existing line views when possible
    public func configure(with newViewModel: MarketOutcomesMultiLineViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()

        // Update view model reference
        self.viewModel = newViewModel

        // ✅ SMART REUSE: Only recreate views if structure changed
        reconfigureOrRecreateLineViews(with: newViewModel)

        // Subscribe to updates for real-time changes (asynchronous)
        setupBindings()
    }

    /// Immediately configure the view with current data from view model
    /// This is synchronous and required for proper UITableView automatic dimension calculation
    private func configureImmediately(with viewModel: MarketOutcomesMultiLineViewModelProtocol) {
        // Update display state immediately
        updateDisplayState(viewModel.currentDisplayState)

        // Update line views immediately with current data
        recreateAllLineViews(with: viewModel.lineViewModels)
    }

    /// Smart reuse logic: reconfigures existing views or recreates if structure changed
    /// This is the core of the cell reuse fix
    private func reconfigureOrRecreateLineViews(with viewModel: MarketOutcomesMultiLineViewModelProtocol) {
        let newLineViewModels = viewModel.lineViewModels

        // Update display state
        updateDisplayState(viewModel.currentDisplayState)

        // ✅ OPTIMIZATION: If count matches, reconfigure existing views (REUSE)
        if lineViews.count == newLineViewModels.count {
            for (index, lineViewModel) in newLineViewModels.enumerated() {
                // Reuse existing view, just reconfigure with new ViewModel
                lineViews[index].configure(with: lineViewModel)

                // Re-establish callbacks (they were cleared in cleanupForReuse)
                setupLineCallbacks(lineView: lineViews[index])
            }

            // Update corner radius (structure unchanged, just refresh)
            applyMultiLineCornerRadiusToAllLines()

        } else {
            // ❗Structure changed (different number of lines) - must recreate
            recreateAllLineViews(with: newLineViewModels)
        }
    }

    // MARK: - Setup
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear

        // Add main container
        addSubview(containerStackView)
        
        // Add group title (initially hidden)
        containerStackView.addArrangedSubview(groupTitleLabel)
        
        // Add lines container
        containerStackView.addArrangedSubview(linesStackView)
        
        // Add all state containers to stack (mutually exclusive, initially hidden)
        containerStackView.addArrangedSubview(loadingContainer)
        containerStackView.addArrangedSubview(errorContainer)
        containerStackView.addArrangedSubview(emptyStateContainer)
        
        // Add content to containers
        loadingContainer.addSubview(loadingIndicator)
        errorContainer.addSubview(errorLabel)
        emptyStateContainer.addSubview(emptyStateLabel)

        setupConstraints()
        setupWithTheme()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.containerPadding),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.containerPadding),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.containerPadding),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.containerPadding),

            // Loading container height (stackview handles position)
            loadingContainer.heightAnchor.constraint(equalToConstant: Constants.emptyStateHeight),
            
            // Loading indicator (centered in container)
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor),

            // Error container height (stackview handles position)
            errorContainer.heightAnchor.constraint(equalToConstant: Constants.emptyStateHeight),
            
            // Error label (centered in container)
            errorLabel.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorContainer.centerYAnchor),
            
            // Empty state container height (stackview handles position)
            emptyStateContainer.heightAnchor.constraint(equalToConstant: Constants.emptyStateHeight),
            
            // Empty state label (centered in container)
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateContainer.centerYAnchor)
        ])
    }

    private func setupWithTheme() {
        // Group title styling
        groupTitleLabel.textColor = StyleProvider.Color.textPrimary
        groupTitleLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        
        // Loading container styling
        loadingContainer.backgroundColor = StyleProvider.Color.backgroundPrimary
        loadingContainer.layer.cornerRadius = Constants.cornerRadius
        loadingContainer.clipsToBounds = true
        
        // Error container styling
        errorContainer.backgroundColor = StyleProvider.Color.backgroundPrimary
        errorContainer.layer.cornerRadius = Constants.cornerRadius
        errorContainer.clipsToBounds = true
        
        // Error label styling
        errorLabel.textColor = StyleProvider.Color.textDisabledOdds
        
        // Empty state container styling
        emptyStateContainer.backgroundColor = StyleProvider.Color.backgroundPrimary
        emptyStateContainer.layer.cornerRadius = Constants.cornerRadius
        emptyStateContainer.clipsToBounds = true
        
        // Empty state label styling
        emptyStateLabel.textColor = StyleProvider.Color.textDisabledOdds
        emptyStateLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        
        // Loading indicator styling
        loadingIndicator.color = StyleProvider.Color.highlightPrimary
    }

    private func setupBindings() {
        // Line view models binding (main aggregation)
        // Use dropFirst() since we already configured with current value
        viewModel.lineViewModelsPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lineViewModels in
                self?.recreateAllLineViews(with: lineViewModels)
            }
            .store(in: &cancellables)

        // Display state binding (title, loading, etc.)
        // Use dropFirst() since we already configured with current value
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.updateDisplayState(displayState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Update Methods
    private func updateDisplayState(_ displayState: MarketOutcomesMultiLineDisplayState) {
        // Update group title
        if let title = displayState.groupTitle, !title.isEmpty {
            groupTitleLabel.text = title
            groupTitleLabel.isHidden = false
        } else {
            groupTitleLabel.isHidden = true
        }
        
        // Check if we should show empty state
        if displayState.isEmpty {
            showEmptyState(displayState.emptyStateMessage ?? "No markets available")
        } else {
            // Show content state (no loading/error in simplified version)
            showContentState()
        }
    }
    
    /// Recreates all line views from scratch
    /// Only called when structure changes (different number of lines) or during initial setup
    private func recreateAllLineViews(with lineViewModels: [MarketOutcomesLineViewModelProtocol]) {
        // Clear existing line views
        lineViews.forEach { $0.removeFromSuperview() }
        lineViews.removeAll()

        // Hide empty state when we have content to show
        emptyStateContainer.isHidden = true
        linesStackView.isHidden = false

        // If empty, create placeholder line to maintain visual consistency
        if lineViewModels.isEmpty {
            let placeholderViewModel = createPlaceholderLineViewModel()
            let lineView = MarketOutcomesLineView(viewModel: placeholderViewModel)
            lineView.translatesAutoresizingMaskIntoConstraints = false

            // No callbacks needed for placeholder (non-interactive)

            lineViews.append(lineView)
            linesStackView.addArrangedSubview(lineView)
        } else {
            // Create new line views from the aggregated view models
            for lineViewModel in lineViewModels {
                let lineView = MarketOutcomesLineView(viewModel: lineViewModel)
                lineView.translatesAutoresizingMaskIntoConstraints = false

                // Set up callbacks (simplified - no line ID needed)
                setupLineCallbacks(lineView: lineView)

                // Store and add to stack
                lineViews.append(lineView)
                linesStackView.addArrangedSubview(lineView)
            }
        }

        // Apply multi-line corner radius to all lines
        applyMultiLineCornerRadiusToAllLines()
    }

    /// Creates a placeholder line view model when no markets are available
    /// Displays a single disabled button with "-" to maintain visual consistency
    private func createPlaceholderLineViewModel() -> MarketOutcomesLineViewModelProtocol {
        let placeholderOutcome = MarketOutcomeData(
            id: "placeholder",
            bettingOfferId: nil,
            title: "",
            value: "-",
            isDisabled: true  // Non-interactive
        )

        let displayState = MarketOutcomesLineDisplayState(
            displayMode: .single,
            leftOutcome: placeholderOutcome,
            middleOutcome: nil,
            rightOutcome: nil
        )

        return MockMarketOutcomesLineViewModel(
            displayMode: .single,
            leftOutcome: placeholderOutcome,
            middleOutcome: nil,
            rightOutcome: nil
        )
    }

    private func setupLineCallbacks(lineView: MarketOutcomesLineView) {
        // Simplified callbacks - no line ID needed since individual line VMs handle their own state
        lineView.onOutcomeSelected = { [weak self] outcomeId, outcomeType in
            // Individual line view models handle their own selection state
            // Just notify about the interaction
            self?.onOutcomeSelected(outcomeId, outcomeType) // Empty string since line ID not needed in simple version
        }
        
        lineView.onOutcomeDeselected = { [weak self] outcomeId, outcomeType in
            self?.onOutcomeDeselected(outcomeId, outcomeType)
        }
        
        lineView.onOutcomeLongPress = { [weak self] outcomeType in
            self?.onOutcomeLongPress("", outcomeType) // Empty string since line ID not needed in simple version
        }
    }

    // MARK: - State Management
    func showLoadingState() {
        // Keep containerStackView visible, hide content and other states, show loading
        containerStackView.isHidden = false
        linesStackView.isHidden = true
        errorContainer.isHidden = true
        emptyStateContainer.isHidden = true
        loadingContainer.isHidden = false
        loadingIndicator.startAnimating()
    }

    func showErrorState(_ message: String) {
        // Keep containerStackView visible, hide content and other states, show error
        containerStackView.isHidden = false
        linesStackView.isHidden = true
        loadingContainer.isHidden = true
        loadingIndicator.stopAnimating()
        emptyStateContainer.isHidden = true
        errorLabel.text = message
        errorContainer.isHidden = false
    }

    private func showEmptyState(_ message: String) {
        // Keep containerStackView visible, hide content and other states, show empty state
        containerStackView.isHidden = false
        linesStackView.isHidden = true
        loadingContainer.isHidden = true
        loadingIndicator.stopAnimating()
        errorContainer.isHidden = true
        emptyStateLabel.text = message
        emptyStateContainer.isHidden = false
    }

    private func showContentState() {
        // Keep containerStackView visible, hide all state containers, show content
        containerStackView.isHidden = false
        loadingContainer.isHidden = true
        loadingIndicator.stopAnimating()
        errorContainer.isHidden = true
        emptyStateContainer.isHidden = true
        linesStackView.isHidden = false
    }

    // MARK: - Multi-Line Corner Radius Logic
    private func applyMultiLineCornerRadius(to lineView: MarketOutcomesLineView, at lineIndex: Int) {
        let totalLines = linesStackView.arrangedSubviews.count
        
        // Determine if this is the first or last line
        let isFirstLine = lineIndex == 0
        let isLastLine = lineIndex == totalLines - 1
        
        // Calculate position overrides for outcomes in this line
        var positionOverrides: [OutcomeType: OutcomePosition] = [:]
        
        // For single line, use default behavior (no override needed)
        if totalLines == 1 {
            return // MarketOutcomesLineView will handle single-line logic internally
        }
        
        // For multi-line, determine grid position for each outcome
        // Assuming most common layout: 3 outcomes per line arranged in a grid
        if isFirstLine && isLastLine {
            // Only one line - use default single-line logic
            return
        } else if isFirstLine {
            // Top line - outcomes get top corners
            positionOverrides[.left] = .multiTopLeft
            positionOverrides[.middle] = .middle // No corners for middle outcomes
            positionOverrides[.right] = .multiTopRight
        } else if isLastLine {
            // Bottom line - outcomes get bottom corners
            positionOverrides[.left] = .multiBottomLeft
            positionOverrides[.middle] = .middle // No corners for middle outcomes
            positionOverrides[.right] = .multiBottomRight
        } else {
            // Middle lines - no corners for any outcomes
            positionOverrides[.left] = .middle
            positionOverrides[.middle] = .middle
            positionOverrides[.right] = .middle
        }
        
        // Apply the position overrides
        lineView.setPositionOverrides(positionOverrides)
    }
    
    private func applyMultiLineCornerRadiusToAllLines() {
        for (index, arrangedSubview) in linesStackView.arrangedSubviews.enumerated() {
            if let lineView = arrangedSubview as? MarketOutcomesLineView {
                applyMultiLineCornerRadius(to: lineView, at: index)
            }
        }
    }

    // MARK: - Public Methods
    // Note: Individual line view models now handle their own state management
    // No complex methods needed in the simplified aggregator pattern

}

// MARK: - Factory Methods
private extension MarketOutcomesMultiLineView {
    static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.groupTitleBottomSpacing
        return stackView
    }

    static func createGroupTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }

    static func createLinesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.lineSpacing
        return stackView
    }

    static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }

    static func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.isHidden = true
        return label
    }
    
    static func createLoadingContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = Constants.cornerRadius
        container.clipsToBounds = true
        container.isHidden = true
        return container
    }
    
    static func createErrorContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = Constants.cornerRadius
        container.clipsToBounds = true
        container.isHidden = true
        return container
    }
    
    static func createEmptyStateContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = StyleProvider.Color.backgroundPrimary
        container.layer.cornerRadius = Constants.cornerRadius
        container.clipsToBounds = true
        container.isHidden = true
        return container
    }
    
    static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textDisabledOdds
        return label
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("All States Comparison") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        // Create container stack view for all states comparison
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 20
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Market with outcomes
        let marketWithOutcomes = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup)
        marketWithOutcomes.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Loading state - use empty view model but manually trigger loading
        let loadingStateMarket = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
        loadingStateMarket.translatesAutoresizingMaskIntoConstraints = false
        // Manually trigger loading state
        DispatchQueue.main.async {
            loadingStateMarket.showLoadingState()
        }
        
        // 3. Error state - use empty view model but manually trigger error
        let errorStateMarket = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
        errorStateMarket.translatesAutoresizingMaskIntoConstraints = false
        // Manually trigger error state
        DispatchQueue.main.async {
            errorStateMarket.showErrorState("Failed to load markets")
        }
        
        // 4. Empty state market
        let emptyStateMarket = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
        emptyStateMarket.translatesAutoresizingMaskIntoConstraints = false
        
        // Create labels for each state
        let createLabel: (String) -> UILabel = { text in
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .medium, size: 16)
            label.textColor = StyleProvider.Color.textPrimary
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }
        
        // Add all components to stack
        containerStack.addArrangedSubview(createLabel("Content State"))
        containerStack.addArrangedSubview(marketWithOutcomes)
        containerStack.addArrangedSubview(createLabel("Loading State"))
        containerStack.addArrangedSubview(loadingStateMarket)
        containerStack.addArrangedSubview(createLabel("Error State"))
        containerStack.addArrangedSubview(errorStateMarket)
        containerStack.addArrangedSubview(createLabel("Empty State"))
        containerStack.addArrangedSubview(emptyStateMarket)
        
        vc.view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            containerStack.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 50),
            containerStack.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Over/Under Market Group") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Group Empty") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.emptyMarketGroup)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray2
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Home/Draw/Away Market Group") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Group with Suspended Line") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Mixed Layout Market Group") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Market Group with Odds Changes") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let marketOutcomesMultiLineView = MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.marketGroupWithOddsChanges)
        
        marketOutcomesMultiLineView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(marketOutcomesMultiLineView)
        
        NSLayoutConstraint.activate([
            marketOutcomesMultiLineView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            marketOutcomesMultiLineView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 40),
            marketOutcomesMultiLineView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 12),
        ])
        
        vc.view.backgroundColor = UIColor.systemGray6
        return vc
    }
}

#endif
