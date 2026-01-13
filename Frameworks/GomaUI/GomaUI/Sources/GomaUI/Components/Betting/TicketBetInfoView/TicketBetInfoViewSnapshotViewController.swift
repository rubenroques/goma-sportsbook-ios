import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum TicketBetInfoSnapshotCategory: String, CaseIterable {
    case pendingStates = "Pending States"
    case settledStates = "Settled States"
    case cashoutComponents = "Cashout Components"
    case cornerRadiusStyles = "Corner Radius Styles"
}

final class TicketBetInfoViewSnapshotViewController: UIViewController {

    private let category: TicketBetInfoSnapshotCategory

    init(category: TicketBetInfoSnapshotCategory) {
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
        titleLabel.text = "TicketBetInfoView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .pendingStates:
            addPendingStatesVariants(to: stackView)
        case .settledStates:
            addSettledStatesVariants(to: stackView)
        case .cashoutComponents:
            addCashoutComponentsVariants(to: stackView)
        case .cornerRadiusStyles:
            addCornerRadiusStylesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addPendingStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Single Ticket - Pending",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMock())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multiple Tickets - Pending",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.multipleTicketsMock())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Names - Pending",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.longCompetitionNamesMock())
        ))
    }

    private func addSettledStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Won Bet",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.wonBetMock())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Lost Bet",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.lostBetMock())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Draw Bet",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.drawBetMock())
        ))
    }

    private func addCashoutComponentsVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Cashout Amount",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMockWithCashout())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Cashout Slider",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMockWithSlider())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Full Cashout Button",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMockWithFullCashoutButton())
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Amount + Slider",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMockWithBoth())
        ))
    }

    private func addCornerRadiusStylesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "All Corners",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMock(), cornerRadiusStyle: .all)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Top Corners Only",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMock(), cornerRadiusStyle: .topOnly)
        ))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bottom Corners Only",
            view: createTicketBetInfoView(viewModel: MockTicketBetInfoViewModel.pendingMock(), cornerRadiusStyle: .bottomOnly)
        ))
    }

    // MARK: - Helper Methods

    private func createTicketBetInfoView(
        viewModel: TicketBetInfoViewModelProtocol,
        cornerRadiusStyle: CornerRadiusStyle = .all
    ) -> TicketBetInfoView {
        let view = TicketBetInfoView(viewModel: viewModel, cornerRadiusStyle: cornerRadiusStyle)
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
#Preview("Pending States") {
    TicketBetInfoViewSnapshotViewController(category: .pendingStates)
}

#Preview("Settled States") {
    TicketBetInfoViewSnapshotViewController(category: .settledStates)
}

#Preview("Cashout Components") {
    TicketBetInfoViewSnapshotViewController(category: .cashoutComponents)
}

#Preview("Corner Radius Styles") {
    TicketBetInfoViewSnapshotViewController(category: .cornerRadiusStyles)
}
#endif
