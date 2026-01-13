import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum StackViewBlockSnapshotCategory: String, CaseIterable {
    case defaultConfiguration = "Default Configuration"
    case contentVariants = "Content Variants"
    case itemCountVariants = "Item Count Variants"
}

final class StackViewBlockViewSnapshotViewController: UIViewController {

    private let category: StackViewBlockSnapshotCategory

    init(category: StackViewBlockSnapshotCategory) {
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
        titleLabel.text = "StackViewBlockView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .defaultConfiguration:
            addDefaultConfigurationVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultConfigurationVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Title + Description)",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.defaultMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Title + Description",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.defaultMock)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Bullet Items",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.multipleViewsMock)
        ))

        // Custom variant with only descriptions
        let descOnly = MockStackViewBlockViewModel(views: [
            DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.defaultMock),
            DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.shortMock)
        ])
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Descriptions Only",
            view: createStackViewBlockView(viewModel: descOnly)
        ))
    }

    private func addItemCountVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Item",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.singleViewMock)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Items",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.defaultMock)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Items",
            view: createStackViewBlockView(viewModel: MockStackViewBlockViewModel.multipleViewsMock)
        ))

        // Many items variant
        let manyItems = MockStackViewBlockViewModel(views: [
            TitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock),
            DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.defaultMock),
            BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock),
            BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock),
            BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock),
            DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.shortMock)
        ])
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Six Items",
            view: createStackViewBlockView(viewModel: manyItems)
        ))
    }

    // MARK: - Helper Methods

    private func createStackViewBlockView(viewModel: StackViewBlockViewModelProtocol) -> StackViewBlockView {
        let blockView = StackViewBlockView(viewModel: viewModel)
        blockView.translatesAutoresizingMaskIntoConstraints = false
        return blockView
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
    StackViewBlockViewSnapshotViewController(category: .defaultConfiguration)
}

#Preview("Content Variants") {
    StackViewBlockViewSnapshotViewController(category: .contentVariants)
}

#Preview("Item Count Variants") {
    StackViewBlockViewSnapshotViewController(category: .itemCountVariants)
}
#endif
