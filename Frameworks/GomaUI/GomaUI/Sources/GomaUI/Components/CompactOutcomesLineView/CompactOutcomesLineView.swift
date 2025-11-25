import UIKit
import Combine
import SwiftUI

/// Compact single-line outcomes display for inline match cards
/// Displays 2-3 OutcomeItemView instances horizontally
final public class CompactOutcomesLineView: UIView {

    // MARK: - UI Components
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // Outcome views
    private var leftOutcomeView: OutcomeItemView?
    private var middleOutcomeView: OutcomeItemView?
    private var rightOutcomeView: OutcomeItemView?

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CompactOutcomesLineViewModelProtocol?
    private var currentDisplayMode: CompactOutcomesDisplayMode = .triple

    // MARK: - Public Callbacks
    public var onOutcomeSelected: ((String, OutcomeType) -> Void) = { _, _ in }
    public var onOutcomeDeselected: ((String, OutcomeType) -> Void) = { _, _ in }

    // MARK: - Constants
    private enum Constants {
        static let stackSpacing: CGFloat = 4.0
        static let outcomeHeight: CGFloat = 52.0
        static let outcomeMinWidth: CGFloat = 60.0
    }

    // MARK: - Initialization
    public init(viewModel: CompactOutcomesLineViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()

        if let viewModel = viewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: CompactOutcomesLineViewModelProtocol?) {
        cancellables.removeAll()
        self.viewModel = newViewModel

        if let viewModel = newViewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        } else {
            clearOutcomeViews()
        }
    }

    /// Prepare for reuse in table/collection view cells
    public func cleanupForReuse() {
        cancellables.removeAll()
        onOutcomeSelected = { _, _ in }
        onOutcomeDeselected = { _, _ in }
    }

    // MARK: - Private Configuration
    private func configureImmediately(with viewModel: CompactOutcomesLineViewModelProtocol) {
        updateDisplayMode(viewModel.currentDisplayState.displayMode)
        updateOutcomeViews(
            left: viewModel.currentLeftOutcomeViewModel,
            middle: viewModel.currentMiddleOutcomeViewModel,
            right: viewModel.currentRightOutcomeViewModel
        )
    }

    private func clearOutcomeViews() {
        leftOutcomeView?.removeFromSuperview()
        middleOutcomeView?.removeFromSuperview()
        rightOutcomeView?.removeFromSuperview()
        leftOutcomeView = nil
        middleOutcomeView = nil
        rightOutcomeView = nil
    }
}

// MARK: - ViewCode
extension CompactOutcomesLineView {
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        addSubview(containerStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.heightAnchor.constraint(equalToConstant: Constants.outcomeHeight)
        ])
    }

    private func setupAdditionalConfiguration() {
        backgroundColor = .clear
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Bind to display state changes
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateDisplayMode(state.displayMode)
            }
            .store(in: &cancellables)

        // Bind to individual outcome view model changes
        Publishers.CombineLatest3(
            viewModel.leftOutcomeViewModelPublisher,
            viewModel.middleOutcomeViewModelPublisher,
            viewModel.rightOutcomeViewModelPublisher
        )
        .dropFirst()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] left, middle, right in
            self?.updateOutcomeViews(left: left, middle: middle, right: right)
        }
        .store(in: &cancellables)
    }

    private func updateDisplayMode(_ mode: CompactOutcomesDisplayMode) {
        guard currentDisplayMode != mode else { return }
        currentDisplayMode = mode

        // Update visibility of middle outcome
        middleOutcomeView?.isHidden = (mode == .double)

        // Update corner positions based on mode
        updateOutcomePositions()
    }

    private func updateOutcomeViews(
        left: OutcomeItemViewModelProtocol?,
        middle: OutcomeItemViewModelProtocol?,
        right: OutcomeItemViewModelProtocol?
    ) {
        // Update or create left outcome
        if let leftVM = left {
            if let existingView = leftOutcomeView {
                existingView.configure(with: leftVM)
            } else {
                leftOutcomeView = createOutcomeView(viewModel: leftVM, type: .left)
                containerStackView.insertArrangedSubview(leftOutcomeView!, at: 0)
            }
            setupOutcomeCallbacks(view: leftOutcomeView!, type: .left)
        } else {
            leftOutcomeView?.removeFromSuperview()
            leftOutcomeView = nil
        }

        // Update or create middle outcome (only for triple mode)
        if let middleVM = middle, currentDisplayMode == .triple {
            if let existingView = middleOutcomeView {
                existingView.configure(with: middleVM)
            } else {
                middleOutcomeView = createOutcomeView(viewModel: middleVM, type: .middle)
                let insertIndex = leftOutcomeView != nil ? 1 : 0
                containerStackView.insertArrangedSubview(middleOutcomeView!, at: insertIndex)
            }
            middleOutcomeView?.isHidden = false
            setupOutcomeCallbacks(view: middleOutcomeView!, type: .middle)
        } else {
            middleOutcomeView?.removeFromSuperview()
            middleOutcomeView = nil
        }

        // Update or create right outcome
        if let rightVM = right {
            if let existingView = rightOutcomeView {
                existingView.configure(with: rightVM)
            } else {
                rightOutcomeView = createOutcomeView(viewModel: rightVM, type: .right)
                containerStackView.addArrangedSubview(rightOutcomeView!)
            }
            setupOutcomeCallbacks(view: rightOutcomeView!, type: .right)
        } else {
            rightOutcomeView?.removeFromSuperview()
            rightOutcomeView = nil
        }

        // Update corner positions
        updateOutcomePositions()
    }

    private func createOutcomeView(viewModel: OutcomeItemViewModelProtocol, type: OutcomeType) -> OutcomeItemView {
        let view = OutcomeItemView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.outcomeMinWidth)
        ])

        return view
    }

    private func setupOutcomeCallbacks(view: OutcomeItemView, type: OutcomeType) {
        view.onTap = { [weak self] outcomeId in
            guard let self = self else { return }

            // Check if already selected to determine select/deselect
            let isCurrentlySelected = self.isOutcomeSelected(type: type)

            if isCurrentlySelected {
                self.onOutcomeDeselected(outcomeId, type)
                self.viewModel?.onOutcomeDeselected(outcomeId: outcomeId, outcomeType: type)
            } else {
                self.onOutcomeSelected(outcomeId, type)
                self.viewModel?.onOutcomeSelected(outcomeId: outcomeId, outcomeType: type)
            }
        }
    }

    private func isOutcomeSelected(type: OutcomeType) -> Bool {
        switch type {
        case .left:
            return viewModel?.currentDisplayState.leftOutcome?.isSelected ?? false
        case .middle:
            return viewModel?.currentDisplayState.middleOutcome?.isSelected ?? false
        case .right:
            return viewModel?.currentDisplayState.rightOutcome?.isSelected ?? false
        }
    }

    private func updateOutcomePositions() {
        switch currentDisplayMode {
        case .double:
            leftOutcomeView?.setPosition(.singleFirst)
            rightOutcomeView?.setPosition(.singleLast)
        case .triple:
            leftOutcomeView?.setPosition(.singleFirst)
            middleOutcomeView?.setPosition(.middle)
            rightOutcomeView?.setPosition(.singleLast)
        }
    }
}

// MARK: - UI Elements Factory
extension CompactOutcomesLineView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.stackSpacing
        return stackView
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("CompactOutcomesLineView States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "CompactOutcomesLineView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 20)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        // 3-way (triple)
        let tripleLabel = UILabel()
        tripleLabel.text = "3-way (1X2):"
        tripleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        tripleLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(tripleLabel)

        let tripleView = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.threeWayMarket)
        stackView.addArrangedSubview(tripleView)

        // 2-way (double)
        let doubleLabel = UILabel()
        doubleLabel.text = "2-way (Tennis):"
        doubleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        doubleLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(doubleLabel)

        let doubleView = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.twoWayMarket)
        stackView.addArrangedSubview(doubleView)

        // Selected state
        let selectedLabel = UILabel()
        selectedLabel.text = "With selection:"
        selectedLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        selectedLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(selectedLabel)

        let selectedView = CompactOutcomesLineView(viewModel: MockCompactOutcomesLineViewModel.withSelectedOutcome)
        stackView.addArrangedSubview(selectedView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
