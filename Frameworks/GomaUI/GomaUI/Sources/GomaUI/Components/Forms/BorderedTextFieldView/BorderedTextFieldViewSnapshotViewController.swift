import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BorderedTextFieldSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case inputTypes = "Input Types"
    case errorStates = "Error States"
}

final class BorderedTextFieldViewSnapshotViewController: UIViewController {

    private let category: BorderedTextFieldSnapshotCategory

    init(category: BorderedTextFieldSnapshotCategory) {
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
        titleLabel.text = "BorderedTextFieldView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
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
        case .inputTypes:
            addInputTypesVariants(to: stackView)
        case .errorStates:
            addErrorStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Idle (empty)",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.emailField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Focused",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.focusedField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Text",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.phoneNumberField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.disabledField)
        ))
    }

    private func addInputTypesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Phone Number",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.phoneNumberField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Email",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.emailField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Password (secure)",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.passwordField)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Name",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.nameField)
        ))
    }

    private func addErrorStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error State",
            view: createTextField(viewModel: MockBorderedTextFieldViewModel.errorField)
        ))

        // Create a custom error field with longer message
        let longErrorViewModel = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "longError",
                text: "abc",
                placeholder: "Password",
                visualState: .error("Password must be at least 8 characters long and contain uppercase, lowercase, and a number"),
                textContentType: .password
            )
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error with Long Message",
            view: createTextField(viewModel: longErrorViewModel)
        ))

        // Create a field with short error
        let shortErrorViewModel = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "shortError",
                text: "",
                placeholder: "Required Field",
                isRequired: true,
                visualState: .error("Required")
            )
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Required Field Error",
            view: createTextField(viewModel: shortErrorViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createTextField(viewModel: MockBorderedTextFieldViewModel) -> BorderedTextFieldView {
        let view = BorderedTextFieldView(viewModel: viewModel)
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
    BorderedTextFieldViewSnapshotViewController(category: .basicStates)
}

#Preview("Input Types") {
    BorderedTextFieldViewSnapshotViewController(category: .inputTypes)
}

#Preview("Error States") {
    BorderedTextFieldViewSnapshotViewController(category: .errorStates)
}
#endif
