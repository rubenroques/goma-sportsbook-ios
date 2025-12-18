import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ButtonSnapshotCategory: String, CaseIterable {
    case basicStyles = "Basic Styles"
    case disabledStates = "Disabled States"
    case commonActions = "Common Actions"
    case customColors = "Custom Colors"
    case themeVariants = "Theme Variants"
    case fontCustomization = "Font Customization"
}

final class ButtonViewSnapshotViewController: UIViewController {

    private let category: ButtonSnapshotCategory

    init(category: ButtonSnapshotCategory) {
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
        titleLabel.text = "ButtonView - \(category.rawValue)"
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
        case .basicStyles:
            addBasicStylesVariants(to: stackView)
        case .disabledStates:
            addDisabledStatesVariants(to: stackView)
        case .commonActions:
            addCommonActionsVariants(to: stackView)
        case .customColors:
            addCustomColorsVariants(to: stackView)
        case .themeVariants:
            addThemeVariantsVariants(to: stackView)
        case .fontCustomization:
            addFontCustomizationVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStylesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Solid Background (Enabled)",
            view: ButtonView(viewModel: MockButtonViewModel.solidBackgroundMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bordered (Enabled)",
            view: ButtonView(viewModel: MockButtonViewModel.borderedMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Transparent (Enabled)",
            view: ButtonView(viewModel: MockButtonViewModel.transparentMock)
        ))
    }

    private func addDisabledStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Solid Background (Disabled)",
            view: ButtonView(viewModel: MockButtonViewModel.solidBackgroundDisabledMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bordered (Disabled)",
            view: ButtonView(viewModel: MockButtonViewModel.borderedDisabledMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Transparent (Disabled)",
            view: ButtonView(viewModel: MockButtonViewModel.transparentDisabledMock)
        ))
    }

    private func addCommonActionsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Submit Button",
            view: ButtonView(viewModel: MockButtonViewModel.submitMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Cancel Button",
            view: ButtonView(viewModel: MockButtonViewModel.cancelMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Claim Bonus",
            view: ButtonView(viewModel: MockButtonViewModel.claimBonusMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Learn More",
            view: ButtonView(viewModel: MockButtonViewModel.learnMoreMock)
        ))
    }

    private func addCustomColorsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Solid (Red)",
            view: ButtonView(viewModel: MockButtonViewModel.solidBackgroundCustomColorMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Bordered (Blue)",
            view: ButtonView(viewModel: MockButtonViewModel.borderedCustomColorMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Transparent (Purple)",
            view: ButtonView(viewModel: MockButtonViewModel.transparentCustomColorMock)
        ))
    }

    private func addThemeVariantsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Red Theme",
            view: ButtonView(viewModel: MockButtonViewModel.redThemeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Blue Theme",
            view: ButtonView(viewModel: MockButtonViewModel.blueThemeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Green Theme",
            view: ButtonView(viewModel: MockButtonViewModel.greenThemeMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Orange Theme",
            view: ButtonView(viewModel: MockButtonViewModel.orangeThemeMock)
        ))
    }

    private func addFontCustomizationVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Large Font (24pt, Bold)",
            view: ButtonView(viewModel: MockButtonViewModel.largeFontMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Small Font (12pt, Medium)",
            view: ButtonView(viewModel: MockButtonViewModel.smallFontMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Light Font (18pt)",
            view: ButtonView(viewModel: MockButtonViewModel.lightFontMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Heavy Font (20pt)",
            view: ButtonView(viewModel: MockButtonViewModel.heavyFontMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Font Style (16pt, Semibold)",
            view: ButtonView(viewModel: MockButtonViewModel.customFontStyleMock)
        ))
    }

    private func createSectionHeader(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
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
#Preview("Basic Styles") {
    ButtonViewSnapshotViewController(category: .basicStyles)
}

@available(iOS 17.0, *)
#Preview("Disabled States") {
    ButtonViewSnapshotViewController(category: .disabledStates)
}

@available(iOS 17.0, *)
#Preview("Common Actions") {
    ButtonViewSnapshotViewController(category: .commonActions)
}

@available(iOS 17.0, *)
#Preview("Custom Colors") {
    ButtonViewSnapshotViewController(category: .customColors)
}

@available(iOS 17.0, *)
#Preview("Theme Variants") {
    ButtonViewSnapshotViewController(category: .themeVariants)
}

@available(iOS 17.0, *)
#Preview("Font Customization") {
    ButtonViewSnapshotViewController(category: .fontCustomization)
}
#endif
