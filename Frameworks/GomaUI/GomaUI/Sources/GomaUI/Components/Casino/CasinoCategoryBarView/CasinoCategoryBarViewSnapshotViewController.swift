import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CasinoCategoryBarSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case categoryVariants = "Category Variants"
}

final class CasinoCategoryBarViewSnapshotViewController: UIViewController {

    private let category: CasinoCategoryBarSnapshotCategory

    init(category: CasinoCategoryBarSnapshotCategory) {
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
        titleLabel.text = "CasinoCategoryBarView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .categoryVariants:
            addCategoryVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "New Games",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.newGames)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Popular Games",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.popularGames)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Slot Games",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.slotGames)
        ))
    }

    private func addCategoryVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Games",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.liveGames)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Jackpot Games",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.jackpotGames)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Category (Short Title)",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.customCategory(
                id: "custom-1",
                title: "VIP",
                buttonText: "All 5"
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Category (Long Title)",
            view: createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel.customCategory(
                id: "custom-2",
                title: "Featured Casino Games This Week",
                buttonText: "All 234"
            ))
        ))
    }

    // MARK: - Helper Methods

    private func createCasinoCategoryBarView(viewModel: MockCasinoCategoryBarViewModel) -> CasinoCategoryBarView {
        let view = CasinoCategoryBarView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Basic States") {
    CasinoCategoryBarViewSnapshotViewController(category: .basicStates)
}

#Preview("Category Variants") {
    CasinoCategoryBarViewSnapshotViewController(category: .categoryVariants)
}
#endif
