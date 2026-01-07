import UIKit

// MARK: - Snapshot Category
enum StepInstructionViewSnapshotCategory: String, CaseIterable {
    case instructionVariants = "Instruction Variants"
}

final class StepInstructionViewSnapshotViewController: UIViewController {

    private let category: StepInstructionViewSnapshotCategory

    init(category: StepInstructionViewSnapshotCategory) {
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
        titleLabel.text = "StepInstructionView - \(category.rawValue)"
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
        case .instructionVariants:
            addInstructionVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addInstructionVariants(to stackView: UIStackView) {
        // Default
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Step 1)",
            view: createStepInstructionView(viewModel: MockStepInstructionViewModel.defaultMock)
        ))

        // Custom color
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Color (Step 2)",
            view: createStepInstructionView(viewModel: MockStepInstructionViewModel.customColorMock)
        ))

        // Multiple highlights
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Highlights (Step 3)",
            view: createStepInstructionView(viewModel: MockStepInstructionViewModel.multipleHighlightsMock)
        ))
    }

    // MARK: - Helper Methods

    private func createStepInstructionView(viewModel: MockStepInstructionViewModel) -> StepInstructionView {
        let instructionView = StepInstructionView(viewModel: viewModel)
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        return instructionView
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
#Preview("Instruction Variants") {
    StepInstructionViewSnapshotViewController(category: .instructionVariants)
}
#endif
