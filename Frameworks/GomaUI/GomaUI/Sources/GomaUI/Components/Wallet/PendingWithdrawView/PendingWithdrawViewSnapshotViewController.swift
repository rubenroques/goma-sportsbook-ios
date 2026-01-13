import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PendingWithdrawSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case statusStyles = "Status Styles"
    case contentVariants = "Content Variants"
}

final class PendingWithdrawViewSnapshotViewController: UIViewController {

    private let category: PendingWithdrawSnapshotCategory

    init(category: PendingWithdrawSnapshotCategory) {
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
        titleLabel.text = "PendingWithdrawView - \(category.rawValue)"
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
        case .statusStyles:
            addStatusStylesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Default pending state
        let defaultState = PendingWithdrawViewDisplayState.samplePending
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (In Progress)",
            view: createPendingWithdrawView(displayState: defaultState)
        ))
    }

    private func addStatusStylesVariants(to stackView: UIStackView) {
        // In Progress (default green style)
        let inProgressStyle = PendingWithdrawStatusStyle(
            textColor: StyleProvider.Color.buttonActiveHoverPrimary,
            backgroundColor: StyleProvider.Color.myTicketsWonFaded,
            borderColor: StyleProvider.Color.buttonActiveHoverPrimary
        )
        let inProgressState = PendingWithdrawViewDisplayState(
            dateText: "05/08/2025, 11:17",
            statusText: "In Progress",
            statusStyle: inProgressStyle,
            amountValueText: "XAF 200,000",
            transactionIdValueText: "HFD90230NRF"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "In Progress (Green)",
            view: createPendingWithdrawView(displayState: inProgressState)
        ))

        // Pending (orange/warning style)
        let pendingStyle = PendingWithdrawStatusStyle(
            textColor: StyleProvider.Color.alertWarning,
            backgroundColor: StyleProvider.Color.alertWarning.withAlphaComponent(0.15),
            borderColor: StyleProvider.Color.alertWarning
        )
        let pendingState = PendingWithdrawViewDisplayState(
            dateText: "04/08/2025, 09:30",
            statusText: "Pending",
            statusStyle: pendingStyle,
            amountValueText: "XAF 150,000",
            transactionIdValueText: "ABC12345XYZ"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pending (Orange)",
            view: createPendingWithdrawView(displayState: pendingState)
        ))

        // Processing (blue style)
        let processingStyle = PendingWithdrawStatusStyle(
            textColor: StyleProvider.Color.highlightPrimary,
            backgroundColor: StyleProvider.Color.highlightPrimary.withAlphaComponent(0.15),
            borderColor: StyleProvider.Color.highlightPrimary
        )
        let processingState = PendingWithdrawViewDisplayState(
            dateText: "03/08/2025, 14:45",
            statusText: "Processing",
            statusStyle: processingStyle,
            amountValueText: "XAF 500,000",
            transactionIdValueText: "PRO98765DEF"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Processing (Blue)",
            view: createPendingWithdrawView(displayState: processingState)
        ))

        // No border style
        let noBorderStyle = PendingWithdrawStatusStyle(
            textColor: StyleProvider.Color.textPrimary,
            backgroundColor: StyleProvider.Color.backgroundTertiary,
            borderColor: nil
        )
        let noBorderState = PendingWithdrawViewDisplayState(
            dateText: "02/08/2025, 16:20",
            statusText: "Queued",
            statusStyle: noBorderStyle,
            amountValueText: "XAF 100,000",
            transactionIdValueText: "QUE55555QQQ"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Queued (No Border)",
            view: createPendingWithdrawView(displayState: noBorderState)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short transaction ID
        let shortIdState = PendingWithdrawViewDisplayState(
            dateText: "01/01/2025",
            statusText: "OK",
            amountValueText: "XAF 1,000",
            transactionIdValueText: "A1B2"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Content",
            view: createPendingWithdrawView(displayState: shortIdState)
        ))

        // Long transaction ID
        let longIdState = PendingWithdrawViewDisplayState(
            dateText: "31/12/2025, 23:59:59",
            statusText: "Awaiting Approval",
            amountValueText: "XAF 10,000,000",
            transactionIdValueText: "VERYLONGTRANSACTIONID12345"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Content",
            view: createPendingWithdrawView(displayState: longIdState)
        ))

        // Without copy icon
        let noCopyState = PendingWithdrawViewDisplayState(
            dateText: "15/06/2025, 12:00",
            statusText: "In Progress",
            amountValueText: "XAF 50,000",
            transactionIdValueText: "NOCOPY123",
            copyIconName: nil
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Copy Icon",
            view: createPendingWithdrawView(displayState: noCopyState)
        ))

        // Custom labels
        let customLabelsState = PendingWithdrawViewDisplayState(
            dateText: "10/03/2025, 08:15",
            statusText: "Completed",
            amountTitleText: "Withdrawal Amount",
            amountValueText: "EUR 250.00",
            transactionIdTitleText: "Reference",
            transactionIdValueText: "REF-2025-001"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Labels",
            view: createPendingWithdrawView(displayState: customLabelsState)
        ))
    }

    // MARK: - Helper Methods

    private func createPendingWithdrawView(displayState: PendingWithdrawViewDisplayState) -> PendingWithdrawView {
        let viewModel = MockPendingWithdrawViewModel(displayState: displayState)
        let view = PendingWithdrawView(viewModel: viewModel)
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
    PendingWithdrawViewSnapshotViewController(category: .basicStates)
}

#Preview("Status Styles") {
    PendingWithdrawViewSnapshotViewController(category: .statusStyles)
}

#Preview("Content Variants") {
    PendingWithdrawViewSnapshotViewController(category: .contentVariants)
}
#endif
