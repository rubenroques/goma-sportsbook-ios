import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ButtonIconSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case layoutVariants = "Layout Variants"
    case styleVariants = "Style Variants"
}

final class ButtonIconViewSnapshotViewController: UIViewController {

    private let category: ButtonIconSnapshotCategory

    init(category: ButtonIconSnapshotCategory) {
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
        titleLabel.text = "ButtonIconView - \(category.rawValue)"
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
        case .layoutVariants:
            addLayoutVariants(to: stackView)
        case .styleVariants:
            addStyleVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled (Booking Code)",
            view: createButtonIconView(viewModel: MockButtonIconViewModel.bookingCodeMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled (Clear Betslip)",
            view: createButtonIconView(viewModel: MockButtonIconViewModel.clearBetslipMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createButtonIconView(viewModel: MockButtonIconViewModel.disabledMock())
        ))
    }

    private func addLayoutVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon Left",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Share",
                icon: "square.and.arrow.up",
                layoutType: .iconLeft
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon Right",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Delete",
                icon: "trash",
                layoutType: .iconRight
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Text Only (No Icon)",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Continue",
                icon: nil,
                layoutType: .iconLeft
            ))
        ))
    }

    private func addStyleVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Background Color",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Action",
                icon: "star.fill",
                layoutType: .iconLeft,
                backgroundColor: StyleProvider.Color.buttonBackgroundSecondary,
                cornerRadius: 8
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Custom Icon Color",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Favorite",
                icon: "heart.fill",
                layoutType: .iconLeft,
                iconColor: StyleProvider.Color.buttonBackgroundPrimary
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Styled Disabled",
            view: createButtonIconView(viewModel: MockButtonIconViewModel(
                title: "Unavailable",
                icon: "xmark.circle",
                layoutType: .iconLeft,
                isEnabled: false,
                backgroundColor: StyleProvider.Color.backgroundSecondary,
                cornerRadius: 8
            ))
        ))
    }

    // MARK: - Helper Methods

    private func createButtonIconView(viewModel: MockButtonIconViewModel) -> ButtonIconView {
        let view = ButtonIconView(viewModel: viewModel)
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
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Basic States") {
    ButtonIconViewSnapshotViewController(category: .basicStates)
}

#Preview("Layout Variants") {
    ButtonIconViewSnapshotViewController(category: .layoutVariants)
}

#Preview("Style Variants") {
    ButtonIconViewSnapshotViewController(category: .styleVariants)
}
#endif
