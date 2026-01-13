import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum NotificationListSnapshotCategory: String, CaseIterable {
    case listStates = "List States"
    case notificationStates = "Notification States"
    case actionStyles = "Action Styles"
    case contentVariants = "Content Variants"
}

final class NotificationListViewSnapshotViewController: UIViewController {

    private let category: NotificationListSnapshotCategory

    init(category: NotificationListSnapshotCategory) {
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
        titleLabel.text = "NotificationListView - \(category.rawValue)"
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
        case .listStates:
            addListStatesVariants(to: stackView)
        case .notificationStates:
            addNotificationStatesVariants(to: stackView)
        case .actionStyles:
            addActionStylesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addListStatesVariants(to stackView: UIStackView) {
        // Empty state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty State",
            view: createNotificationListView(viewModel: MockNotificationListViewModel.emptyMock),
            height: 150
        ))

        // Loaded with notifications
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loaded (Multiple Notifications)",
            view: createNotificationListView(viewModel: MockNotificationListViewModel.defaultMock),
            height: 400
        ))
    }

    private func addNotificationStatesVariants(to stackView: UIStackView) {
        // Unread only
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Unread Only",
            view: createNotificationListView(viewModel: MockNotificationListViewModel.unreadOnlyMock),
            height: 250
        ))

        // Read only
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Read Only",
            view: createNotificationListView(viewModel: MockNotificationListViewModel.readOnlyMock),
            height: 200
        ))
    }

    private func addActionStylesVariants(to stackView: UIStackView) {
        // Mixed notifications with different action styles
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed Action Styles",
            view: createNotificationListView(viewModel: MockNotificationListViewModel.mixedNotificationsMock),
            height: 450
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Single notification (tests .single card position)
        let singleNotification = NotificationData(
            id: "single_1",
            timestamp: Date(),
            title: "Single Notification",
            description: "This is a single notification that should have all corners rounded.",
            state: .unread,
            action: NotificationAction(id: "action_1", title: "View Details", style: .primary)
        )
        let singleMock = MockNotificationListViewModel(initialNotifications: [singleNotification])
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Notification (All Corners Rounded)",
            view: createNotificationListView(viewModel: singleMock),
            height: 140
        ))

        // Long content notification
        let longContentNotification = NotificationData(
            id: "long_1",
            timestamp: Date(),
            title: "Special Promotion: Double Your Winnings This Weekend with Our Exclusive Offer",
            description: "Don't miss out on our exclusive weekend promotion! Double your winnings on all football matches this Saturday and Sunday. This offer is valid for both single bets and accumulators. Terms and conditions apply. Minimum bet amount is 10. Maximum bonus is 500 per customer.",
            state: .unread,
            action: NotificationAction(id: "action_long", title: "Learn More", style: .secondary)
        )
        let longMock = MockNotificationListViewModel(initialNotifications: [longContentNotification])
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Content",
            view: createNotificationListView(viewModel: longMock),
            height: 200
        ))
    }

    // MARK: - Helper Methods

    private func createNotificationListView(viewModel: MockNotificationListViewModel) -> NotificationListView {
        let listView = NotificationListView(viewModel: viewModel)
        listView.translatesAutoresizingMaskIntoConstraints = false
        return listView
    }

    private func createLabeledVariant(label: String, view: UIView, height: CGFloat) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        view.heightAnchor.constraint(equalToConstant: height).isActive = true

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("List States") {
    NotificationListViewSnapshotViewController(category: .listStates)
}

#Preview("Notification States") {
    NotificationListViewSnapshotViewController(category: .notificationStates)
}

#Preview("Action Styles") {
    NotificationListViewSnapshotViewController(category: .actionStyles)
}

#Preview("Content Variants") {
    NotificationListViewSnapshotViewController(category: .contentVariants)
}
#endif
