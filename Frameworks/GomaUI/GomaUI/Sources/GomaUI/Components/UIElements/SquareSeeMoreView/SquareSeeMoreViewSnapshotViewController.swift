import UIKit
import SwiftUI

// MARK: - Snapshot Category

enum SquareSeeMoreSnapshotCategory: String, CaseIterable {
    case defaultState = "Default State"
}

final class SquareSeeMoreViewSnapshotViewController: UIViewController {

    private let category: SquareSeeMoreSnapshotCategory

    init(category: SquareSeeMoreSnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "SquareSeeMoreView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .defaultState:
            addDefaultStateVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultStateVariants(to stackView: UIStackView) {
        // Default state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (100x100pt)",
            view: createSeeMoreView(viewModel: MockSquareSeeMoreViewModel.default)
        ))

        // Show in context with a game card placeholder for size reference
        let contextStack = UIStackView()
        contextStack.axis = .horizontal
        contextStack.spacing = 8
        contextStack.alignment = .top

        let placeholderView = createPlaceholderGameCard()
        let seeMoreView = createSeeMoreView(viewModel: MockSquareSeeMoreViewModel.default)

        contextStack.addArrangedSubview(placeholderView)
        contextStack.addArrangedSubview(seeMoreView)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "In Grid Context (with placeholder)",
            view: contextStack
        ))
    }

    // MARK: - Helper Methods

    private func createSeeMoreView(viewModel: MockSquareSeeMoreViewModel) -> SquareSeeMoreView {
        let view = SquareSeeMoreView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createPlaceholderGameCard() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundCards
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let label = UILabel()
        label.text = "Game"
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 100),
            view.heightAnchor.constraint(equalToConstant: 100),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Default State") {
    SquareSeeMoreViewSnapshotViewController(category: .defaultState)
}
#endif
