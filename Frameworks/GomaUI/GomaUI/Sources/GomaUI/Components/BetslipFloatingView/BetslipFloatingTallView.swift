import Foundation
import UIKit
import Combine
import SwiftUI

/// A tall floating view that displays odds boost promotion with progress tracking - matches Figma design exactly
public final class BetslipFloatingTallView: UIView {

    // MARK: - UI Components

    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
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
        label.text = "You're almost there!" // TODO: localization
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
    private let viewModel: BetslipFloatingViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init(viewModel: BetslipFloatingViewModelProtocol) {
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
    private func render(data: BetslipFloatingData) {
        switch data.state {
        case .noTickets:
            // Hide entire view when no tickets
            isHidden = true

        case .withTickets(let selectionCount, _, _, let totalEligibleCount, let nextTierPercentage):
            // Only show when we have odds boost data
            let hasOddsBoost = totalEligibleCount > 0
            isHidden = !hasOddsBoost

            if hasOddsBoost {
                // Update heading
                if let nextPercentage = nextTierPercentage {
                    headingLabel.text = "Get a \(nextPercentage) Win Boost"
                } else {
                    headingLabel.text = "Max Win Boost Activated!"
                }

                // Update description
                let remainingSelections = max(0, totalEligibleCount - selectionCount)
                if remainingSelections > 0 {
                    let legWord = remainingSelections == 1 ? "leg" : "legs"
                    descriptionLabel.text = "by adding \(remainingSelections) more \(legWord) to your betslip (1.2 min odds)."
                } else {
                    descriptionLabel.text = "All qualifying events added!"
                }

                // Update progress segments
                updateProgressSegments(filledCount: selectionCount, totalCount: totalEligibleCount, animated: true)
            }
        }

        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }

    // MARK: - Actions
    @objc private func handleTap() {
        viewModel.onBetslipTapped?()
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Tall - With Boost Progress") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let betslipView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 1, odds: "5.71", winBoostPercentage: nil, totalEligibleCount: 3, nextTierPercentage: "3%")))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tall - Almost Complete") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.gray

        let betslipView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 2, odds: "8.50", winBoostPercentage: nil, totalEligibleCount: 3, nextTierPercentage: "5%")))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tall - Max Boost Reached") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.gray

        let betslipView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 3, odds: "12.50", winBoostPercentage: "10%", totalEligibleCount: 3, nextTierPercentage: nil)))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tall - No Boost (Hidden)") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.gray

        let betslipView = BetslipFloatingTallView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 2, odds: "3.40", winBoostPercentage: nil, totalEligibleCount: 0, nextTierPercentage: nil)))
        betslipView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(betslipView)

        NSLayoutConstraint.activate([
            betslipView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            betslipView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            betslipView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        return vc
    }
}

#endif
