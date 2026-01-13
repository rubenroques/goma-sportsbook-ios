import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum LanguageSelectorSnapshotCategory: String, CaseIterable {
    case itemCountVariants = "Item Count Variants"
    case selectionStates = "Selection States"
}

final class LanguageSelectorViewSnapshotViewController: UIViewController {

    private let category: LanguageSelectorSnapshotCategory

    init(category: LanguageSelectorSnapshotCategory) {
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
        titleLabel.text = "LanguageSelectorView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .itemCountVariants:
            addItemCountVariants(to: stackView)
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addItemCountVariants(to stackView: UIStackView) {
        // Single language
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Language",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.singleLanguageMock)
        ))

        // Two languages
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Two Languages",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.twoLanguagesMock)
        ))

        // Four languages (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Four Languages",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.defaultMock)
        ))

        // Many languages
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Many Languages",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.manyLanguagesMock)
        ))
    }

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // English selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "English Selected",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.defaultMock)
        ))

        // French selected
        stackView.addArrangedSubview(createLabeledVariant(
            label: "French Selected",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.frenchSelectedMock)
        ))

        // Interactive (English default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Interactive Mock (5 Languages)",
            view: createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel.interactiveMock)
        ))
    }

    // MARK: - Helper Methods

    private func createLanguageSelectorView(viewModel: MockLanguageSelectorViewModel) -> LanguageSelectorView {
        let view = LanguageSelectorView(viewModel: viewModel)
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
#Preview("Item Count Variants") {
    LanguageSelectorViewSnapshotViewController(category: .itemCountVariants)
}

#Preview("Selection States") {
    LanguageSelectorViewSnapshotViewController(category: .selectionStates)
}
#endif
