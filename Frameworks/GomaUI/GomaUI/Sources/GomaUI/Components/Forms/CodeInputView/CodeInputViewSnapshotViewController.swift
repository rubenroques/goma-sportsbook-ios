import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CodeInputSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case inputStates = "Input States"
}

final class CodeInputViewSnapshotViewController: UIViewController {

    private let category: CodeInputSnapshotCategory

    init(category: CodeInputSnapshotCategory) {
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
        titleLabel.text = "CodeInputView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .inputStates:
            addInputStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Default state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: CodeInputView(viewModel: MockCodeInputViewModel.defaultMock())
        ))

        // Loading state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loading",
            view: CodeInputView(viewModel: MockCodeInputViewModel.loadingMock())
        ))
    }

    private func addInputStatesVariants(to stackView: UIStackView) {
        // With code
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Code",
            view: CodeInputView(viewModel: MockCodeInputViewModel.withCodeMock())
        ))

        // Error state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error",
            view: CodeInputView(viewModel: MockCodeInputViewModel.errorMock())
        ))
    }

    // MARK: - Helper Methods

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
    CodeInputViewSnapshotViewController(category: .basicStates)
}

#Preview("Input States") {
    CodeInputViewSnapshotViewController(category: .inputStates)
}
#endif
