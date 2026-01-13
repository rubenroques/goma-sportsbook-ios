import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum ShareChannelsGridSnapshotCategory: String, CaseIterable {
    case channelCounts = "Channel Counts"
    case channelTypes = "Channel Types"
    case availabilityStates = "Availability States"
}

final class ShareChannelsGridViewSnapshotViewController: UIViewController {

    private let category: ShareChannelsGridSnapshotCategory

    init(category: ShareChannelsGridSnapshotCategory) {
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
        titleLabel.text = "ShareChannelsGridView - \(category.rawValue)"
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
        case .channelCounts:
            addChannelCountsVariants(to: stackView)
        case .channelTypes:
            addChannelTypesVariants(to: stackView)
        case .availabilityStates:
            addAvailabilityStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addChannelCountsVariants(to stackView: UIStackView) {
        // All channels (8 - fills both rows)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "All Channels (8 items - 2 rows)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.allChannelsMock)
        ))

        // Limited (4 items - single row partial)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Limited (4 items)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.limitedMock)
        ))

        // Empty
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty (0 items)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.emptyMock)
        ))
    }

    private func addChannelTypesVariants(to stackView: UIStackView) {
        // Social only (5 items - full top row)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Social Only (Twitter, WhatsApp, Facebook, Telegram, Messenger)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.socialOnlyMock)
        ))

        // Messaging only (3 items)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Messaging Only (Viber, SMS, Email)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.messagingOnlyMock)
        ))
    }

    private func addAvailabilityStatesVariants(to stackView: UIStackView) {
        // All available
        stackView.addArrangedSubview(createLabeledVariant(
            label: "All Available",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.socialOnlyMock)
        ))

        // Mixed with disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mixed (Facebook & Messenger disabled)",
            view: createGridView(viewModel: MockShareChannelsGridViewModel.withDisabledMock)
        ))
    }

    // MARK: - Helper Methods

    private func createGridView(viewModel: MockShareChannelsGridViewModel) -> ShareChannelsGridView {
        let view = ShareChannelsGridView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Channel Counts") {
    ShareChannelsGridViewSnapshotViewController(category: .channelCounts)
}

#Preview("Channel Types") {
    ShareChannelsGridViewSnapshotViewController(category: .channelTypes)
}

#Preview("Availability States") {
    ShareChannelsGridViewSnapshotViewController(category: .availabilityStates)
}
#endif
