import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum RecentlyPlayedGamesSnapshotCategory: String, CaseIterable {
    case contentVariants = "Content Variants"
    case displayStates = "Display States"
}

final class RecentlyPlayedGamesViewSnapshotViewController: UIViewController {

    private let category: RecentlyPlayedGamesSnapshotCategory

    init(category: RecentlyPlayedGamesSnapshotCategory) {
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
        titleLabel.text = "RecentlyPlayedGamesView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .contentVariants:
            addContentVariants(to: stackView)
        case .displayStates:
            addDisplayStates(to: stackView)
        }
    }

    // MARK: - Content Variants

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (5 games)",
            view: createRecentlyPlayedView(viewModel: MockRecentlyPlayedGamesViewModel.defaultRecentlyPlayed)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Games (2 games)",
            view: createRecentlyPlayedView(viewModel: MockRecentlyPlayedGamesViewModel.fewGames)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Game Names",
            view: createRecentlyPlayedView(viewModel: MockRecentlyPlayedGamesViewModel.longGameNames)
        ))
    }

    // MARK: - Display States

    private func addDisplayStates(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Placeholder (no viewModel)",
            view: createRecentlyPlayedView(viewModel: nil)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty Games List",
            view: createRecentlyPlayedView(viewModel: MockRecentlyPlayedGamesViewModel.emptyRecentlyPlayed)
        ))
    }

    // MARK: - Helper Methods

    private func createRecentlyPlayedView(viewModel: RecentlyPlayedGamesViewModelProtocol?) -> RecentlyPlayedGamesView {
        let view = RecentlyPlayedGamesView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Content Variants") {
    RecentlyPlayedGamesViewSnapshotViewController(category: .contentVariants)
}

#Preview("Display States") {
    RecentlyPlayedGamesViewSnapshotViewController(category: .displayStates)
}
#endif
