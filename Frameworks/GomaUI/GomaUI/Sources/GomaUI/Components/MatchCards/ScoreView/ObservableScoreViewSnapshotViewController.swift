import UIKit

// MARK: - Snapshot Category

public enum ObservableScoreViewSnapshotCategory: String, CaseIterable {
    case sportVariants = "Sport Variants"
    case visualStates = "Visual States"
    case styleVariants = "Style Variants"
}

/// Snapshot test ViewController for ObservableScoreView.
///
/// Tests Apple's @Observable + layoutSubviews() pattern.
/// Mirrors ScoreViewSnapshotViewController to allow direct comparison.
public final class ObservableScoreViewSnapshotViewController: UIViewController {

    private let category: ObservableScoreViewSnapshotCategory

    public init(category: ObservableScoreViewSnapshotCategory = .sportVariants) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "ObservableScoreView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "@Observable + layoutSubviews() (No Combine)"
        subtitleLabel.font = StyleProvider.fontWith(type: .regular, size: 11)
        subtitleLabel.textColor = StyleProvider.Color.textSecondary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .sportVariants:
            addSportVariants(to: stackView)
        case .visualStates:
            addVisualStates(to: stackView)
        case .styleVariants:
            addStyleVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSportVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tennis Match",
            viewModel: .tennisMatch
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tennis Advantage",
            viewModel: .tennisAdvantage
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Basketball Match",
            viewModel: .basketballMatch
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Football Match",
            viewModel: .footballMatch
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Hockey Match",
            viewModel: .hockeyMatch
        ))
    }

    private func addVisualStates(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Display State",
            viewModel: .simpleExample
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State",
            viewModel: .empty
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle State",
            viewModel: .idle
        ))
    }

    private func addStyleVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Simple Style",
            viewModel: .simpleStyle()
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Border Style",
            viewModel: .borderStyle()
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Background Style",
            viewModel: .backgroundStyle()
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed Styles",
            viewModel: .mixedStyles
        ))
    }

    // MARK: - Helper Methods

    private func createLabeledVariant(label: String, viewModel: ObservableScoreViewModel) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let scoreView = ObservableScoreView()
        scoreView.configure(with: viewModel)

        containerView.addSubview(scoreView)

        NSLayoutConstraint.activate([
            scoreView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            scoreView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            scoreView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            scoreView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 12),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

#Preview("Sport Variants") {
    ObservableScoreViewSnapshotViewController(category: .sportVariants)
}

#Preview("Visual States") {
    ObservableScoreViewSnapshotViewController(category: .visualStates)
}

#Preview("Style Variants") {
    ObservableScoreViewSnapshotViewController(category: .styleVariants)
}
#endif
