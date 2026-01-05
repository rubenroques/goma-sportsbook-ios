import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ExpandableSectionSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class ExpandableSectionViewSnapshotViewController: UIViewController {

    private let category: ExpandableSectionSnapshotCategory

    init(category: ExpandableSectionSnapshotCategory) {
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
        titleLabel.text = "ExpandableSectionView - \(category.rawValue)"
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
        // Collapsed state
        let collapsedView = createExpandableSection(
            viewModel: MockExpandableSectionViewModel.defaultMock,
            content: createSampleContent()
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Collapsed",
            view: collapsedView
        ))

        // Expanded state
        let expandedView = createExpandableSection(
            viewModel: MockExpandableSectionViewModel.expandedMock,
            content: createSampleContent()
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Expanded",
            view: expandedView
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short title
        let shortTitleView = createExpandableSection(
            viewModel: MockExpandableSectionViewModel.customMock(title: "Info", isExpanded: true),
            content: createSampleContent()
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: shortTitleView
        ))

        // Long title
        let longTitleView = createExpandableSection(
            viewModel: MockExpandableSectionViewModel.customMock(title: "Additional Information and Details", isExpanded: false),
            content: createSampleContent()
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: longTitleView
        ))

        // Multi-line content (expanded)
        let multiLineVM = MockExpandableSectionViewModel.customMock(title: "Terms", isExpanded: true)
        let multiLineView = createExpandableSection(
            viewModel: multiLineVM,
            content: createMultiLineContent()
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multi-line Content",
            view: multiLineView
        ))
    }

    // MARK: - Helper Methods

    private func createExpandableSection(viewModel: ExpandableSectionViewModelProtocol, content: UIView) -> ExpandableSectionView {
        let section = ExpandableSectionView(viewModel: viewModel)
        section.contentContainer.addArrangedSubview(content)
        section.translatesAutoresizingMaskIntoConstraints = false
        return section
    }

    private func createSampleContent() -> UIView {
        let label = UILabel()
        label.text = "This is sample content that appears when the section is expanded."
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createMultiLineContent() -> UIView {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
@available(iOS 17.0, *)
#Preview("Basic States") {
    ExpandableSectionViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    ExpandableSectionViewSnapshotViewController(category: .contentVariants)
}
#endif
