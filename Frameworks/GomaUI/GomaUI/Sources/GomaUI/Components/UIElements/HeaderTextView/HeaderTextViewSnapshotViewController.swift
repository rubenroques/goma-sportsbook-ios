import UIKit

// MARK: - Snapshot Category
enum HeaderTextViewSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class HeaderTextViewSnapshotViewController: UIViewController {

    private let category: HeaderTextViewSnapshotCategory

    init(category: HeaderTextViewSnapshotCategory) {
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
        titleLabel.text = "HeaderTextView - \(category.rawValue)"
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
        // Default state
        let defaultViewModel = MockHeaderTextViewModel(title: "Suggested Events")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: createHeaderTextView(viewModel: defaultViewModel)
        ))

        // Section header
        let sectionViewModel = MockHeaderTextViewModel(title: "Popular Matches")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Section Header",
            view: createHeaderTextView(viewModel: sectionViewModel)
        ))

        // Category header
        let categoryViewModel = MockHeaderTextViewModel(title: "Live Now")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Category Header",
            view: createHeaderTextView(viewModel: categoryViewModel)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short text
        let shortViewModel = MockHeaderTextViewModel(title: "Live")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: createHeaderTextView(viewModel: shortViewModel)
        ))

        // Medium text
        let mediumViewModel = MockHeaderTextViewModel(title: "Today's Top Picks")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Medium Text",
            view: createHeaderTextView(viewModel: mediumViewModel)
        ))

        // Long text
        let longViewModel = MockHeaderTextViewModel(title: "Premier League Highlights & Featured Matches")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: createHeaderTextView(viewModel: longViewModel)
        ))

        // All caps
        let capsViewModel = MockHeaderTextViewModel(title: "TRENDING NOW")
        stackView.addArrangedSubview(createLabeledVariant(
            label: "All Caps",
            view: createHeaderTextView(viewModel: capsViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createHeaderTextView(viewModel: MockHeaderTextViewModel) -> HeaderTextView {
        let headerView = HeaderTextView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
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
@available(iOS 17.0, *)
#Preview("Basic States") {
    HeaderTextViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    HeaderTextViewSnapshotViewController(category: .contentVariants)
}
#endif
