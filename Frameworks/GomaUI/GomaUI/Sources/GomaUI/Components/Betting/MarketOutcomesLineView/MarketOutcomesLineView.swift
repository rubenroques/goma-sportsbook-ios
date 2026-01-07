import UIKit
import Combine
import SwiftUI

final public class MarketOutcomesLineView: UIView {

    // MARK: - Private Properties
    // Container stack view for outcomes
    private lazy var oddsStackView: UIStackView = Self.createOddsStackView()

    // Outcome item views - much cleaner!
    private var leftOutcomeView: OutcomeItemView?
    private var middleOutcomeView: OutcomeItemView?
    private var rightOutcomeView: OutcomeItemView?

    // Suspended and see all views
    private lazy var suspendedBaseView: UIView = Self.createSuspendedBaseView()
    private lazy var suspendedLabel: UILabel = Self.createSuspendedLabel()
    private lazy var seeAllBaseView: UIView = Self.createSeeAllBaseView()
    private lazy var seeAllLabel: UILabel = Self.createSeeAllLabel()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: MarketOutcomesLineViewModelProtocol
    
    // Store current display mode for corner radius calculations
    private var currentDisplayMode: MarketDisplayMode = .triple
    
    // Position overrides for multi-line scenarios
    private var positionOverrides: [OutcomeType: OutcomePosition] = [:]

    // MARK: - Public Properties
    public var onOutcomeSelected: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onOutcomeDeselected: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onOutcomeLongPress: ((OutcomeType) -> Void) = { _ in }
    public var onSeeAllTapped: (() -> Void) = { }

    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 0.0
        static let stackSpacing: CGFloat = 1.0
        static let viewHeight: CGFloat = 52.0
    }

    // MARK: - Initialization
    public init(viewModel: MarketOutcomesLineViewModelProtocol) {
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
    /// Following GomaUI pattern from OutcomeItemView, MarketInfoLineView, etc.
    public func configure(with newViewModel: MarketOutcomesLineViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()

        // Update view model reference
        self.viewModel = newViewModel

        // Re-establish bindings with new ViewModel
        setupBindings()

        // Immediately apply current state from ViewModel
        // After cell reuse, the ViewModel may already have selection state
        // from betslip synchronization. We must render this state immediately.
        updateMarketState(newViewModel.marketStateSubject.value)
    }

    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        // Add main stack view
        addSubview(oddsStackView)

        // Setup suspended view
        addSubview(suspendedBaseView)
        suspendedBaseView.addSubview(suspendedLabel)

        // Setup see all view
        addSubview(seeAllBaseView)
        seeAllBaseView.addSubview(seeAllLabel)

        setupConstraints()
        setupWithTheme()
        setupSeeAllGesture()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Odds stack view
            oddsStackView.topAnchor.constraint(equalTo: topAnchor),
            oddsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            oddsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            oddsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            oddsStackView.heightAnchor.constraint(equalToConstant: Constants.viewHeight),

            // Suspended view
            suspendedBaseView.topAnchor.constraint(equalTo: topAnchor),
            suspendedBaseView.leadingAnchor.constraint(equalTo: leadingAnchor),
            suspendedBaseView.trailingAnchor.constraint(equalTo: trailingAnchor),
            suspendedBaseView.bottomAnchor.constraint(equalTo: bottomAnchor),

            suspendedLabel.centerXAnchor.constraint(equalTo: suspendedBaseView.centerXAnchor),
            suspendedLabel.centerYAnchor.constraint(equalTo: suspendedBaseView.centerYAnchor),

            // See all view
            seeAllBaseView.topAnchor.constraint(equalTo: topAnchor),
            seeAllBaseView.leadingAnchor.constraint(equalTo: leadingAnchor),
            seeAllBaseView.trailingAnchor.constraint(equalTo: trailingAnchor),
            seeAllBaseView.bottomAnchor.constraint(equalTo: bottomAnchor),

            seeAllLabel.centerXAnchor.constraint(equalTo: seeAllBaseView.centerXAnchor),
            seeAllLabel.centerYAnchor.constraint(equalTo: seeAllBaseView.centerYAnchor)
        ])
    }

    private func setupWithTheme() {
        // Suspended view
        suspendedBaseView.backgroundColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.1)
        suspendedBaseView.layer.borderColor = StyleProvider.Color.highlightSecondary.cgColor
        suspendedLabel.textColor = StyleProvider.Color.highlightSecondary

        // See all view
        seeAllBaseView.backgroundColor = StyleProvider.Color.highlightSecondary.withAlphaComponent(0.1)
        seeAllLabel.textColor = StyleProvider.Color.textPrimary
    }

    private func setupSeeAllGesture() {
        let tapSeeAll = UITapGestureRecognizer(target: self, action: #selector(didTapSeeAll))
        seeAllBaseView.addGestureRecognizer(tapSeeAll)
    }

    private func setupBindings() {
        // Single market state binding for all data updates
        viewModel.marketStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateMarketState(state)
            }
            .store(in: &cancellables)

        // Observe selection changes from parent ViewModel (proper MVVM pattern)
        // Parent VM observes child VMs' selectionDidChangePublisher and re-publishes here
        viewModel.outcomeSelectionDidChangePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                if event.isSelected {
                    self?.onOutcomeSelected(event.outcomeId, event.outcomeType)
                } else {
                    self?.onOutcomeDeselected(event.outcomeId, event.outcomeType)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Update Methods
    private func updateMarketState(_ state: MarketOutcomesLineDisplayState) {
        // Store current display mode for corner radius calculations
        currentDisplayMode = state.displayMode
        
        // Update display mode and visibility
        updateDisplayMode(state.displayMode)

        // Update outcomes using the new OutcomeItemView components
        leftOutcomeView = updateOutcomeView(
            outcomeData: state.leftOutcome,
            existingOutcomeView: leftOutcomeView,
            outcomeType: .left
        )

        middleOutcomeView = updateOutcomeView(
            outcomeData: state.middleOutcome,
            existingOutcomeView: middleOutcomeView,
            outcomeType: .middle
        )

        rightOutcomeView = updateOutcomeView(
            outcomeData: state.rightOutcome,
            existingOutcomeView: rightOutcomeView,
            outcomeType: .right
        )

        // Update suspended/see all text if applicable
        if let displayText = state.displayMode.displayText {
            switch state.displayMode {
            case .suspended:
                suspendedLabel.text = displayText
            case .seeAll:
                seeAllLabel.text = displayText
            default:
                break
            }
        }
    }

    private func updateDisplayMode(_ mode: MarketDisplayMode) {
        switch mode {
        case .single:
            oddsStackView.isHidden = false
            middleOutcomeView?.isHidden = true
            rightOutcomeView?.isHidden = true
            suspendedBaseView.isHidden = true
            seeAllBaseView.isHidden = true
        case .double:
            oddsStackView.isHidden = false
            middleOutcomeView?.isHidden = true
            suspendedBaseView.isHidden = true
            seeAllBaseView.isHidden = true
        case .triple:
            oddsStackView.isHidden = false
            middleOutcomeView?.isHidden = false
            suspendedBaseView.isHidden = true
            seeAllBaseView.isHidden = true
        case .suspended:
            oddsStackView.isHidden = true
            suspendedBaseView.isHidden = false
            seeAllBaseView.isHidden = true
        case .seeAll:
            oddsStackView.isHidden = true
            suspendedBaseView.isHidden = true
            seeAllBaseView.isHidden = false
        }
    }

    private func updateOutcomeView(
        outcomeData: MarketOutcomeData?,
        existingOutcomeView: OutcomeItemView?,
        outcomeType: OutcomeType
    ) -> OutcomeItemView? {
        guard let outcomeData = outcomeData else {
            // Remove the outcome view if no data
            existingOutcomeView?.removeFromSuperview()
            return nil
        }

        // If we already have a view, reconfigure it with the new view model
        if let existingOutcomeView = existingOutcomeView {
            guard let childViewModel = viewModel.createOutcomeViewModel(for: outcomeType) else {
                // No view model available - remove the existing view
                existingOutcomeView.removeFromSuperview()
                return nil
            }

            // Reconfigure existing view with new view model
            existingOutcomeView.configure(with: childViewModel)

            // Reapply position (may have changed if market structure changed)
            let position = determineOutcomePosition(outcomeType: outcomeType)
            existingOutcomeView.setPosition(position)

            return existingOutcomeView
        }

        // Create new view since we don't have one
        guard let childViewModel = viewModel.createOutcomeViewModel(for: outcomeType) else {
            return nil
        }

        // Create new view with the child view model
        let newOutcomeView = OutcomeItemView(viewModel: childViewModel)
        
        // Apply position-based corner radius
        let position = determineOutcomePosition(outcomeType: outcomeType)
        newOutcomeView.setPosition(position)

        // Setup callbacks
        setupOutcomeViewCallbacks(newOutcomeView, outcomeType: outcomeType)

        // Add to stack view
        switch outcomeType {
        case .left:
            oddsStackView.insertArrangedSubview(newOutcomeView, at: 0)
        case .middle:
            if oddsStackView.arrangedSubviews.count >= 2 {
                oddsStackView.insertArrangedSubview(newOutcomeView, at: 1)
            } else {
                oddsStackView.addArrangedSubview(newOutcomeView)
            }
        case .right:
            oddsStackView.addArrangedSubview(newOutcomeView)
        }

        return newOutcomeView
    }

    private func setupOutcomeViewCallbacks(_ outcomeView: OutcomeItemView, outcomeType: OutcomeType) {
        // Long press callback only - tap is handled via ViewModel publishers
        outcomeView.onLongPress = { [weak self] in
            self?.onOutcomeLongPress(outcomeType)
        }
    }

    // MARK: - Actions
    @objc private func didTapSeeAll() {
        onSeeAllTapped()
    }

    // MARK: - Corner Radius Logic
    private func determineOutcomePosition(outcomeType: OutcomeType) -> OutcomePosition {
        // Check for position override first (used in multi-line scenarios)
        if let overridePosition = positionOverrides[outcomeType] {
            return overridePosition
        }
        
        // Use default single-line logic
        switch currentDisplayMode {
        case .single:
            return .single // Full rounded corners for single placeholder
        case .double:
            switch outcomeType {
            case .left: return .singleFirst
            case .right: return .singleLast
            case .middle: return .middle // Hidden in double mode anyway
            }
        case .triple:
            switch outcomeType {
            case .left: return .singleFirst
            case .middle: return .middle
            case .right: return .singleLast
            }
        case .suspended, .seeAll:
            return .single // Full rounded corners for suspended/seeAll states
        }
    }

    // MARK: - Public Methods
    
    /// Sets position overrides for multi-line scenarios where outcomes need specific corner positions
    public func setPositionOverrides(_ overrides: [OutcomeType: OutcomePosition]) {
        positionOverrides = overrides
        
        // Apply position changes to existing views
        if let leftView = leftOutcomeView, let position = overrides[.left] {
            leftView.setPosition(position)
        }
        if let middleView = middleOutcomeView, let position = overrides[.middle] {
            middleView.setPosition(position)
        }
        if let rightView = rightOutcomeView, let position = overrides[.right] {
            rightView.setPosition(position)
        }
    }
    
    public func cleanupForReuse() {
        cancellables.removeAll()

        // Remove all outcome views
        leftOutcomeView?.removeFromSuperview()
        middleOutcomeView?.removeFromSuperview()
        rightOutcomeView?.removeFromSuperview()

        leftOutcomeView = nil
        middleOutcomeView = nil
        rightOutcomeView = nil

        // Reset visibility
        suspendedBaseView.isHidden = true
        seeAllBaseView.isHidden = true
        oddsStackView.isHidden = false

        // Reset state that survives across reuse
        positionOverrides = [:]
        currentDisplayMode = .triple
    }
}

// MARK: - Factory Methods
extension MarketOutcomesLineView {
    private static func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.stackSpacing
        stackView.backgroundColor = .clear
        return stackView
    }

    private static func createSuspendedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = true
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }

    private static func createSuspendedLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        return label
    }

    private static func createSeeAllBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = true
        view.isHidden = true
        view.isUserInteractionEnabled = true
        return view
    }

    private static func createSeeAllLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        return label
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("MarketOutcomesLineView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .gray

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "MarketOutcomesLineView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Two Way Market
        let twoWayView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.twoWayMarket)
        twoWayView.translatesAutoresizingMaskIntoConstraints = false

        // Three Way Market
        let threeWayView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.threeWayMarket)
        threeWayView.translatesAutoresizingMaskIntoConstraints = false

        // Suspended Market
        let suspendedView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.suspendedMarket)
        suspendedView.translatesAutoresizingMaskIntoConstraints = false

        // See All Market
        let seeAllView = MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.seeAllMarket)
        seeAllView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(twoWayView)
        stackView.addArrangedSubview(threeWayView)
        stackView.addArrangedSubview(suspendedView)
        stackView.addArrangedSubview(seeAllView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif
