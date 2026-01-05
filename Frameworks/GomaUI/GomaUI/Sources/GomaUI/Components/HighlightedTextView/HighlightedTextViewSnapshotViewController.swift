import UIKit

// MARK: - Snapshot Category
enum HighlightedTextSnapshotCategory: String, CaseIterable {
    case alignmentStates = "Alignment States"
    case highlightVariants = "Highlight Variants"
}

final class HighlightedTextViewSnapshotViewController: UIViewController {

    private let category: HighlightedTextSnapshotCategory

    init(category: HighlightedTextSnapshotCategory) {
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
        titleLabel.text = "HighlightedTextView - \(category.rawValue)"
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
        case .alignmentStates:
            addAlignmentVariants(to: stackView)
        case .highlightVariants:
            addHighlightVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAlignmentVariants(to stackView: UIStackView) {
        // Left aligned (default)
        let leftAligned = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.defaultMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Left Aligned",
            view: leftAligned
        ))

        // Center aligned
        let centerAligned = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.centeredMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Center Aligned",
            view: centerAligned
        ))

        // Right aligned
        let rightAligned = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.rightAlignedMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Right Aligned",
            view: rightAligned
        ))
    }

    private func addHighlightVariants(to stackView: UIStackView) {
        // Single highlight
        let singleHighlight = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.defaultMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Highlight",
            view: singleHighlight
        ))

        // Multiple highlights
        let multipleHighlights = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.multipleHighlightsMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Highlights",
            view: multipleHighlights
        ))

        // Link style (underlined)
        let linkStyle = createHighlightedTextView(viewModel: MockHighlightedTextViewModel.linkMock())
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Link Style (Underlined)",
            view: linkStyle
        ))
    }

    // MARK: - Helper Methods

    private func createHighlightedTextView(viewModel: MockHighlightedTextViewModel) -> HighlightedTextView {
        let textView = HighlightedTextView(viewModel: viewModel)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
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
#Preview("Alignment States") {
    HighlightedTextViewSnapshotViewController(category: .alignmentStates)
}

@available(iOS 17.0, *)
#Preview("Highlight Variants") {
    HighlightedTextViewSnapshotViewController(category: .highlightVariants)
}
#endif
