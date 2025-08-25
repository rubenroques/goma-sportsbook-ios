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
    private let viewModel: MarketOutcomesLineViewModelProtocol
    
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
        suspendedBaseView.backgroundColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.1)
        suspendedBaseView.layer.borderColor = StyleProvider.Color.secondaryColor.cgColor
        suspendedLabel.textColor = StyleProvider.Color.secondaryColor

        // See all view
        seeAllBaseView.backgroundColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.1)
        seeAllLabel.textColor = StyleProvider.Color.textColor
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

        // Note: Odds change events are now handled by the parent view model
        // which forwards them to the appropriate child view models
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
        outcomeView.onTap = { [weak self] outcomeId in
            self?.handleOutcomeTap(outcomeType, outcomeId: outcomeId)
        }

        outcomeView.onLongPress = { [weak self] in
            self?.onOutcomeLongPress(outcomeType)
        }
    }

    // MARK: - Actions
    @objc private func didTapSeeAll() {
        onSeeAllTapped()
    }

    private func handleOutcomeTap(_ type: OutcomeType, outcomeId: String) {
        // Toggle the selection state and get the new state
        let isNowSelected = viewModel.toggleOutcome(type: type)
        
        // Call the appropriate callback based on the new state
        if isNowSelected {
            onOutcomeSelected(outcomeId, type)
        } else {
            onOutcomeDeselected(outcomeId, type)
        }

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Corner Radius Logic
    private func determineOutcomePosition(outcomeType: OutcomeType) -> OutcomePosition {
        // Check for position override first (used in multi-line scenarios)
        if let overridePosition = positionOverrides[outcomeType] {
            return overridePosition
        }
        
        // Use default single-line logic
        switch currentDisplayMode {
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

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Two Way Market") {
    PreviewUIView {
        MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.twoWayMarket)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Three Way Market") {
    PreviewUIView {
        MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.threeWayMarket)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("Suspended Market") {
    PreviewUIView {
        MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.suspendedMarket)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

@available(iOS 17.0, *)
#Preview("See All Market") {
    PreviewUIView {
        MarketOutcomesLineView(viewModel: MockMarketOutcomesLineViewModel.seeAllMarket)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemGray6))
}

#endif
