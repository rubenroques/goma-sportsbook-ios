import Foundation
import UIKit
import Combine
import SwiftUI


/// A header view that displays odds boost promotion with progress tracking - designed for betslip header positioning
public final class BetslipOddsBoostHeaderView: UIView {

    // MARK: - UI Components

    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        return view
    }()

    // Main vertical stack (16px spacing)
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    // MARK: - Section 1: Title Label (standalone)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("you_almost_there")
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Section 2: Icon + Text Stack

    private lazy var contentHorizontalContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var boostIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "buy_bonus_games", in: Bundle.module, with: nil)
        imageView.image = image ?? UIImage(systemName: "flame.fill")
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0  // No spacing between heading and description
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Section 3: Progress Segments

    private lazy var progressSegmentsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let segmentCoordinator = ProgressSegmentCoordinator()

    // MARK: - Properties
    private let viewModel: BetslipOddsBoostHeaderViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init(viewModel: BetslipOddsBoostHeaderViewModelProtocol) {
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
        addSubview(containerView)
        containerView.addSubview(mainStackView)

        // Add sections to main stack
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(contentHorizontalContainer)
        mainStackView.addArrangedSubview(progressSegmentsContainer)

        // Setup content horizontal container (icon + text stack)
        contentHorizontalContainer.addSubview(boostIconImageView)
        contentHorizontalContainer.addSubview(textStackView)

        // Setup text stack
        textStackView.addArrangedSubview(headingLabel)
        textStackView.addArrangedSubview(descriptionLabel)

        setupConstraints()
        setupGestures()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container (with 16px padding)
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Main stack (16px padding on all sides)
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            // Icon (32x32, left side)
            boostIconImageView.leadingAnchor.constraint(equalTo: contentHorizontalContainer.leadingAnchor),
            boostIconImageView.topAnchor.constraint(equalTo: contentHorizontalContainer.topAnchor),
            boostIconImageView.widthAnchor.constraint(equalToConstant: 32),
            boostIconImageView.heightAnchor.constraint(equalToConstant: 32),

            // Text stack (right side, 12px gap from icon)
            textStackView.leadingAnchor.constraint(equalTo: boostIconImageView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: contentHorizontalContainer.trailingAnchor),
            textStackView.topAnchor.constraint(equalTo: contentHorizontalContainer.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: contentHorizontalContainer.bottomAnchor),

            // Progress segments container (8px height)
            progressSegmentsContainer.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    /// Updates progress segments with diff-based approach and coordinated width animations
    /// - Parameters:
    ///   - filledCount: Number of segments that should be filled
    ///   - totalCount: Total number of segments to display
    ///   - animated: Whether to animate changes (default: true)
    private func updateProgressSegments(filledCount: Int, totalCount: Int, animated: Bool = true) {
        segmentCoordinator.updateSegments(
            filledCount: filledCount,
            totalCount: totalCount,
            in: progressSegmentsContainer,
            animated: animated
        )
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        // Recalculate segment widths when container resizes (e.g., rotation, dynamic layout)
        segmentCoordinator.handleLayoutUpdate(
            containerWidth: progressSegmentsContainer.bounds.width
        )
    }

    // MARK: - Rendering
    private func render(data: BetslipOddsBoostHeaderData) {
        let state = data.state

        // Update heading
        if let currentBoost = state.currentBoostPercentage {
            headingLabel.text = LocalizationProvider.string("max_win_boost_activated") + " (\(currentBoost))"
        } else if let nextPercentage = state.nextTierPercentage {
            headingLabel.text = LocalizationProvider.string("get_win_boost")
                .replacingOccurrences(of: "{percentage}", with: nextPercentage)
        } else {
            headingLabel.text = LocalizationProvider.string("win_boost_available")
        }

        // Update description
        let remainingSelections = max(0, state.totalEligibleCount - state.selectionCount)
        if remainingSelections > 0 {
            let legWord = remainingSelections == 1 ? LocalizationProvider.string("leg") : LocalizationProvider.string("legs")
            descriptionLabel.text = "by adding \(remainingSelections) more \(legWord) to your betslip."
        } else {
            descriptionLabel.text = LocalizationProvider.string("all_qualifying_events_added")
        }

        // Update progress segments
        updateProgressSegments(filledCount: state.selectionCount, totalCount: state.totalEligibleCount, animated: true)

        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }

    // MARK: - Actions
    @objc private func handleTap() {
        viewModel.onHeaderTapped?()
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Header - Progress 1/3") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let headerView = BetslipOddsBoostHeaderView(
            viewModel: MockBetslipOddsBoostHeaderViewModel.activeMock(
                selectionCount: 1,
                totalEligibleCount: 3,
                nextTierPercentage: "3%"
            )
        )
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Header - Progress 2/3") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let headerView = BetslipOddsBoostHeaderView(
            viewModel: MockBetslipOddsBoostHeaderViewModel.activeMock(
                selectionCount: 2,
                totalEligibleCount: 3,
                nextTierPercentage: "5%"
            )
        )
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Header - Max Boost Reached") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let headerView = BetslipOddsBoostHeaderView(
            viewModel: MockBetslipOddsBoostHeaderViewModel.maxBoostMock()
        )
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        return vc
    }
}

// MARK: - Interactive Preview

@available(iOS 17.0, *)
#Preview("Interactive Animation") {
    PreviewUIViewController {
        BetslipOddsBoostHeaderInteractivePreviewController()
    }
}

/// Interactive preview controller for testing segment animations
@available(iOS 17.0, *)
private final class BetslipOddsBoostHeaderInteractivePreviewController: UIViewController {

    private var currentSelections = 1
    private var totalEligible = 3

    private let mockViewModel = MockBetslipOddsBoostHeaderViewModel.activeMock(
        selectionCount: 1,
        totalEligibleCount: 3,
        nextTierPercentage: "3%"
    )

    private lazy var headerView = BetslipOddsBoostHeaderView(viewModel: mockViewModel)

    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var selectionControlsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var totalControlsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var addSelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Selection", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.highlightPrimary
        button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addSelection), for: .touchUpInside)
        return button
    }()

    private lazy var removeSelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("- Remove Selection", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.backgroundTertiary
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeSelection), for: .touchUpInside)
        return button
    }()

    private lazy var addTotalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Total", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.highlightSecondary
        button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTotal), for: .touchUpInside)
        return button
    }()

    private lazy var removeTotalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("- Remove Total", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.backgroundTertiary
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeTotal), for: .touchUpInside)
        return button
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizationProvider.string("reset"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.backgroundColor = StyleProvider.Color.backgroundBorder
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateState()
    }

    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        view.addSubview(controlsStackView)

        selectionControlsStack.addArrangedSubview(removeSelectionButton)
        selectionControlsStack.addArrangedSubview(addSelectionButton)

        totalControlsStack.addArrangedSubview(removeTotalButton)
        totalControlsStack.addArrangedSubview(addTotalButton)

        controlsStackView.addArrangedSubview(infoLabel)
        controlsStackView.addArrangedSubview(selectionControlsStack)
        controlsStackView.addArrangedSubview(totalControlsStack)
        controlsStackView.addArrangedSubview(resetButton)

        NSLayoutConstraint.activate([
            // Controls at top
            controlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            controlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Button heights
            addSelectionButton.heightAnchor.constraint(equalToConstant: 44),
            removeSelectionButton.heightAnchor.constraint(equalToConstant: 44),
            addTotalButton.heightAnchor.constraint(equalToConstant: 44),
            removeTotalButton.heightAnchor.constraint(equalToConstant: 44),
            resetButton.heightAnchor.constraint(equalToConstant: 44),

            // Header at bottom
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func addSelection() {
        guard currentSelections < totalEligible else { return }
        currentSelections += 1
        updateState()
    }

    @objc private func removeSelection() {
        guard currentSelections > 0 else { return }
        currentSelections -= 1
        updateState()
    }

    @objc private func addTotal() {
        guard totalEligible < 10 else { return }
        totalEligible += 1
        updateState()
    }

    @objc private func removeTotal() {
        guard totalEligible > 1 else { return }
        totalEligible -= 1
        // Adjust current selections if needed
        if currentSelections > totalEligible {
            currentSelections = totalEligible
        }
        updateState()
    }

    @objc private func reset() {
        currentSelections = 1
        totalEligible = 3
        updateState()
    }

    private func updateState() {
        // Calculate boost percentage based on progress
        let nextBoost: String?
        let currentBoost: String?

        if currentSelections >= totalEligible {
            nextBoost = nil
            currentBoost = "\((totalEligible * 3))%"
        } else {
            let remainingToNext = totalEligible - currentSelections
            nextBoost = "\((remainingToNext * 3))%"
            currentBoost = nil
        }

        let newState = BetslipOddsBoostHeaderState(
            selectionCount: currentSelections,
            totalEligibleCount: totalEligible,
            nextTierPercentage: nextBoost,
            currentBoostPercentage: currentBoost
        )

        mockViewModel.updateState(newState)
        updateInfoLabel()
        updateButtonStates()
    }

    private func updateInfoLabel() {
        let progress = "\(currentSelections)/\(totalEligible)"
        let status = currentSelections >= totalEligible ? "✓ Max Boost!" : "In Progress"
        infoLabel.text = "Selections: \(progress)\nStatus: \(status)"
    }

    private func updateButtonStates() {
        addSelectionButton.isEnabled = currentSelections < totalEligible
        addSelectionButton.alpha = addSelectionButton.isEnabled ? 1.0 : 0.5

        removeSelectionButton.isEnabled = currentSelections > 0
        removeSelectionButton.alpha = removeSelectionButton.isEnabled ? 1.0 : 0.5

        addTotalButton.isEnabled = totalEligible < 10
        addTotalButton.alpha = addTotalButton.isEnabled ? 1.0 : 0.5

        removeTotalButton.isEnabled = totalEligible > 1
        removeTotalButton.alpha = removeTotalButton.isEnabled ? 1.0 : 0.5
    }
}

#endif
