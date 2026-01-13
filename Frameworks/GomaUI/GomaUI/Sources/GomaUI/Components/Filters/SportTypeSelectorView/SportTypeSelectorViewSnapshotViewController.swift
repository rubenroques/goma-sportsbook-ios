import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SportTypeSelectorSnapshotCategory: String, CaseIterable {
    case defaultConfiguration = "Default Configuration"
    case itemCountVariants = "Item Count Variants"
}

final class SportTypeSelectorViewSnapshotViewController: UIViewController {

    private let category: SportTypeSelectorSnapshotCategory

    init(category: SportTypeSelectorSnapshotCategory) {
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
        titleLabel.text = "SportTypeSelectorView - \(category.rawValue)"
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
        case .defaultConfiguration:
            addDefaultConfigurationVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultConfigurationVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (4 Sports)",
            view: createSelectorView(viewModel: MockSportTypeSelectorViewModel.defaultMock)
        ))
    }

    private func addItemCountVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Sports (2)",
            view: createSelectorView(viewModel: MockSportTypeSelectorViewModel.fewSportsMock, height: 100)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Sports (12)",
            view: createSelectorView(viewModel: MockSportTypeSelectorViewModel.manySportsMock, height: 400)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty (0 Sports)",
            view: createSelectorView(viewModel: MockSportTypeSelectorViewModel.emptySportsMock, height: 60)
        ))
    }

    // MARK: - Helper Methods

    private func createSelectorView(
        viewModel: MockSportTypeSelectorViewModel,
        height: CGFloat = 200
    ) -> SportTypeSelectorView {
        let view = SportTypeSelectorView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: height)
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
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Default Configuration") {
    SportTypeSelectorViewSnapshotViewController(category: .defaultConfiguration)
}

#Preview("Item Count Variants") {
    SportTypeSelectorViewSnapshotViewController(category: .itemCountVariants)
}
#endif
