import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ActionRowSnapshotCategory: String, CaseIterable {
    case rowTypes = "Row Types"
    case iconVariants = "Icon Variants"
    case customStyling = "Custom Styling"
}

final class ActionRowViewSnapshotViewController: UIViewController {

    private let category: ActionRowSnapshotCategory

    init(category: ActionRowSnapshotCategory) {
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
        titleLabel.text = "ActionRowView - \(category.rawValue)"
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
        case .rowTypes:
            addRowTypesVariants(to: stackView)
        case .iconVariants:
            addIconVariants(to: stackView)
        case .customStyling:
            addCustomStylingVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addRowTypesVariants(to stackView: UIStackView) {
        // Navigation type (with chevron)
        let navigationItem = ActionRowItem(
            icon: "bell",
            title: "Notifications",
            type: .navigation,
            action: .notifications
        )
        let navigationRow = ActionRowView()
        navigationRow.configure(with: navigationItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Navigation Type",
            view: navigationRow
        ))

        // Action type (no chevron)
        let actionItem = ActionRowItem(
            icon: "arrow.right.square",
            title: "Logout",
            type: .action,
            action: .logout
        )
        let actionRow = ActionRowView()
        actionRow.configure(with: actionItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Action Type",
            view: actionRow
        ))

        // With subtitle
        let subtitleItem = ActionRowItem(
            icon: "person.circle",
            title: "My Account",
            subtitle: "user@example.com",
            type: .navigation,
            action: .custom
        )
        let subtitleRow = ActionRowView()
        subtitleRow.configure(with: subtitleItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Subtitle",
            view: subtitleRow
        ))

        // Non-tappable
        let nonTappableItem = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: "Verified",
            type: .action,
            action: .custom,
            isTappable: false
        )
        let nonTappableRow = ActionRowView()
        nonTappableRow.configure(with: nonTappableItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Non-Tappable",
            view: nonTappableRow
        ))
    }

    private func addIconVariants(to stackView: UIStackView) {
        // With icon
        let withIconItem = ActionRowItem(
            icon: "bell",
            title: "With Icon",
            type: .navigation,
            action: .notifications
        )
        let withIconRow = ActionRowView()
        withIconRow.configure(with: withIconItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Leading Icon",
            view: withIconRow
        ))

        // Without icon (empty string)
        let noIconItem = ActionRowItem(
            icon: "",
            title: "No Leading Icon",
            type: .navigation,
            action: .custom
        )
        let noIconRow = ActionRowView()
        noIconRow.configure(with: noIconItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Leading Icon",
            view: noIconRow
        ))

        // Custom trailing icon
        let customTrailingItem = ActionRowItem(
            icon: "",
            title: "Share your Betslip",
            type: .action,
            action: .custom,
            trailingIcon: "square.and.arrow.up"
        )
        let customTrailingRow = ActionRowView()
        customTrailingRow.configure(with: customTrailingItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Trailing Icon",
            view: customTrailingRow
        ))
    }

    private func addCustomStylingVariants(to stackView: UIStackView) {
        // Success background
        let successItem = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: "Bet Placed Successfully",
            type: .action,
            action: .custom,
            isTappable: false
        )
        let successRow = ActionRowView()
        successRow.customBackgroundColor = StyleProvider.Color.alertSuccess
        successRow.configure(with: successItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Success Background",
            view: successRow
        ))

        // Error background
        let errorItem = ActionRowItem(
            icon: "exclamationmark.triangle.fill",
            title: "Error Occurred",
            type: .action,
            action: .custom,
            isTappable: false
        )
        let errorRow = ActionRowView()
        errorRow.customBackgroundColor = StyleProvider.Color.alertError
        errorRow.configure(with: errorItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error Background",
            view: errorRow
        ))

        // Default styling
        let defaultItem = ActionRowItem(
            icon: "gearshape",
            title: "Settings",
            type: .navigation,
            action: .custom
        )
        let defaultRow = ActionRowView()
        defaultRow.configure(with: defaultItem) { _ in }
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Background",
            view: defaultRow
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
@available(iOS 17.0, *)
#Preview("Row Types") {
    ActionRowViewSnapshotViewController(category: .rowTypes)
}

@available(iOS 17.0, *)
#Preview("Icon Variants") {
    ActionRowViewSnapshotViewController(category: .iconVariants)
}

@available(iOS 17.0, *)
#Preview("Custom Styling") {
    ActionRowViewSnapshotViewController(category: .customStyling)
}
#endif
