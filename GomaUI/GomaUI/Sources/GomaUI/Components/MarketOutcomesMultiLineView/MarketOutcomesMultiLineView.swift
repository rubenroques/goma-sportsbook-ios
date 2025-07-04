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
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var errorLabel: UILabel = Self.createErrorLabel()
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
    }

    // MARK: - Initialization
    public init(viewModel: MarketOutcomesMultiLineViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: MarketOutcomesMultiLineViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()
        
        // Clear all line views
        lineViews.forEach { $0.removeFromSuperview() }
        lineViews.removeAll()
        
        // Update view model reference
        self.viewModel = newViewModel
        
        // Re-establish bindings with new view model
        setupBindings()
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
        
        // Add loading, error and empty state views
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        addSubview(emptyStateLabel)

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

            // Loading indicator (centered)
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Error label (centered)
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            // Empty state label (centered)
            emptyStateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }

    private func setupWithTheme() {
        // Group title styling
        groupTitleLabel.textColor = StyleProvider.Color.textColor
        groupTitleLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        
        // Error label styling
        errorLabel.textColor = StyleProvider.Color.secondaryColor
        
        // Empty state label styling
        emptyStateLabel.textColor = StyleProvider.Color.secondaryColor
        emptyStateLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        
        // Loading indicator styling
        loadingIndicator.color = StyleProvider.Color.primaryColor
    }

    private func setupBindings() {
        // Line view models binding (main aggregation)
        viewModel.lineViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lineViewModels in
                self?.updateLineViews(with: lineViewModels)
            }
            .store(in: &cancellables)

        // Display state binding (title, loading, etc.)
        viewModel.displayStatePublisher
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
    
    private func updateLineViews(with lineViewModels: [MarketOutcomesLineViewModelProtocol]) {
        // Clear existing line views
        lineViews.forEach { $0.removeFromSuperview() }
        lineViews.removeAll()
        
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
        
        // Apply multi-line corner radius to all lines
        applyMultiLineCornerRadiusToAllLines()
    }

    private func setupLineCallbacks(lineView: MarketOutcomesLineView) {
        // Simplified callbacks - no line ID needed since individual line VMs handle their own state
        lineView.onOutcomeSelected = { [weak self] outcomeType in
            // Individual line view models handle their own selection state
            // Just notify about the interaction
            self?.onOutcomeSelected("", outcomeType) // Empty string since line ID not needed in simple version
        }
        
        lineView.onOutcomeLongPress = { [weak self] outcomeType in
            self?.onOutcomeLongPress("", outcomeType) // Empty string since line ID not needed in simple version
        }
    }

    // MARK: - State Management
    private func showLoadingState() {
        containerStackView.isHidden = true
        errorLabel.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func showErrorState(_ message: String) {
        containerStackView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func showEmptyState(_ message: String) {
        containerStackView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = true
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
    }

    private func showContentState() {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = true
        emptyStateLabel.isHidden = true
        containerStackView.isHidden = false
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
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.isHidden = true
        return label
    }
    
    static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.isHidden = true
        return label
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Over/Under Market Group") {
    PreviewUIView {
        MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup)
    }
    .frame(height: 200)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Home/Draw/Away Market Group") {
    PreviewUIView {
        MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.homeDrawAwayMarketGroup)
    }
    .frame(height: 200)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Market Group with Suspended Line") {
    PreviewUIView {
        MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.overUnderWithSuspendedLine)
    }
    .frame(height: 250)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Mixed Layout Market Group") {
    PreviewUIView {
        MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.mixedLayoutMarketGroup)
    }
    .frame(height: 200)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Market Group with Odds Changes") {
    PreviewUIView {
        MarketOutcomesMultiLineView(viewModel: MockMarketOutcomesMultiLineViewModel.marketGroupWithOddsChanges)
    }
    .frame(height: 150)
    .padding()
    .background(Color(UIColor.systemGray6))
}

#endif 
