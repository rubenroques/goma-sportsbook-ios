import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ListBlockSnapshotCategory: String, CaseIterable {
    case iconVariants = "Icon Variants"
    case contentVariants = "Content Variants"
}

final class ListBlockViewSnapshotViewController: UIViewController {

    private let category: ListBlockSnapshotCategory

    init(category: ListBlockSnapshotCategory) {
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
        titleLabel.text = "ListBlockView - \(category.rawValue)"
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
        case .iconVariants:
            addIconVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addIconVariants(to stackView: UIStackView) {
        // No icon - shows numbered counter (empty iconUrl)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Icon (Shows Counter)",
            view: createListBlockView(viewModel: MockListBlockViewModel.noIconMock)
        ))

        // With counter number
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter #1",
            view: createListBlockView(viewModel: createCounterMock(counter: "1"))
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter #2",
            view: createListBlockView(viewModel: createCounterMock(counter: "2"))
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Counter #10",
            view: createListBlockView(viewModel: createCounterMock(counter: "10"))
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Single bullet item
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Bullet",
            view: createListBlockView(viewModel: createSingleBulletMock())
        ))

        // Multiple bullet items
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Bullets",
            view: createListBlockView(viewModel: createMultiBulletMock())
        ))

        // Long text content
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text Content",
            view: createListBlockView(viewModel: createLongContentMock())
        ))
    }

    // MARK: - Helper Methods

    private func createListBlockView(viewModel: ListBlockViewModelProtocol) -> ListBlockView {
        let view = ListBlockView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createCounterMock(counter: String) -> MockListBlockViewModel {
        let bulletView = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        return MockListBlockViewModel(
            iconUrl: "",
            counter: counter,
            views: [bulletView]
        )
    }

    private func createSingleBulletMock() -> MockListBlockViewModel {
        let bulletView = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock)
        return MockListBlockViewModel(
            iconUrl: "",
            counter: "1",
            views: [bulletView]
        )
    }

    private func createMultiBulletMock() -> MockListBlockViewModel {
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock)
        let bulletView3 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel(title: "Weekly cashback rewards"))
        return MockListBlockViewModel(
            iconUrl: "",
            counter: "1",
            views: [bulletView1, bulletView2, bulletView3]
        )
    }

    private func createLongContentMock() -> MockListBlockViewModel {
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.longMock)
        let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel(title: "Additional terms and conditions may apply to bonus offers"))
        return MockListBlockViewModel(
            iconUrl: "",
            counter: "1",
            views: [bulletView1, bulletView2]
        )
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
#Preview("Icon Variants") {
    ListBlockViewSnapshotViewController(category: .iconVariants)
}

#Preview("Content Variants") {
    ListBlockViewSnapshotViewController(category: .contentVariants)
}
#endif
