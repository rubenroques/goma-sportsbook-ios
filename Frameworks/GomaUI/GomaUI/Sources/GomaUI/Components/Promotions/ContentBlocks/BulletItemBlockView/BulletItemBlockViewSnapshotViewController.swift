import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BulletItemBlockSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class BulletItemBlockViewSnapshotViewController: UIViewController {

    private let category: BulletItemBlockSnapshotCategory

    init(category: BulletItemBlockSnapshotCategory) {
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
        titleLabel.text = "BulletItemBlockView - \(category.rawValue)"
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
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createBulletItemView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: createBulletItemView(viewModel: MockBulletItemBlockViewModel.shortMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: createBulletItemView(viewModel: MockBulletItemBlockViewModel.longMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Multiple bullet items in a list
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 8
        listStack.alignment = .fill

        listStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "100% welcome bonus up to €200")))
        listStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "50 free spins on first deposit")))
        listStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "VIP rewards program")))
        listStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "24/7 customer support")))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Items (List)",
            view: listStack
        ))

        // Very short items
        let shortListStack = UIStackView()
        shortListStack.axis = .vertical
        shortListStack.spacing = 8
        shortListStack.alignment = .fill

        shortListStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "Fast")))
        shortListStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "Secure")))
        shortListStack.addArrangedSubview(createBulletItemView(viewModel: MockBulletItemBlockViewModel(title: "Easy")))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Items",
            view: shortListStack
        ))
    }

    // MARK: - Helper Methods

    private func createBulletItemView(viewModel: MockBulletItemBlockViewModel) -> BulletItemBlockView {
        let view = BulletItemBlockView(viewModel: viewModel)
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
    BulletItemBlockViewSnapshotViewController(category: .basicStates)
}

#Preview("Content Variants") {
    BulletItemBlockViewSnapshotViewController(category: .contentVariants)
}
#endif
