import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum WalletDetailSnapshotCategory: String, CaseIterable {
    case balanceVariants = "Balance Variants"
    case edgeCases = "Edge Cases"
    case withPendingWithdraw = "With Pending Withdraw"
}

final class WalletDetailViewSnapshotViewController: UIViewController {

    private let category: WalletDetailSnapshotCategory

    init(category: WalletDetailSnapshotCategory) {
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
        titleLabel.text = "WalletDetailView - \(category.rawValue)"
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

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .balanceVariants:
            addBalanceVariants(to: stackView)
        case .edgeCases:
            addEdgeCaseVariants(to: stackView)
        case .withPendingWithdraw:
            addPendingWithdrawVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBalanceVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Balance",
            view: createWalletDetailView(viewModel: MockWalletDetailViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "High Balance",
            view: createWalletDetailView(viewModel: MockWalletDetailViewModel.highBalanceMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Cashback Focus",
            view: createWalletDetailView(viewModel: MockWalletDetailViewModel.cashbackFocusMock)
        ))
    }

    private func addEdgeCaseVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty Wallet",
            view: createWalletDetailView(viewModel: MockWalletDetailViewModel.emptyBalanceMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Bonus Only (No Withdrawable)",
            view: createWalletDetailView(viewModel: MockWalletDetailViewModel.bonusOnlyMock)
        ))
    }

    private func addPendingWithdrawVariants(to stackView: UIStackView) {
        // Create view model with pending withdraw section
        let viewModel = MockWalletDetailViewModel.defaultMock
        let pendingWithdrawSectionViewModel = MockCustomExpandableSectionViewModel(
            title: LocalizationProvider.string("pending_withdrawals"),
            isExpanded: true,
            leadingIconName: "arrow.down.circle",
            collapsedIconName: "chevron.down",
            expandedIconName: "chevron.up"
        )
        viewModel.pendingWithdrawSectionViewModel = pendingWithdrawSectionViewModel
        viewModel.pendingWithdrawViewModels = [MockPendingWithdrawViewModel()]

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Pending Withdraw (Expanded)",
            view: createWalletDetailView(viewModel: viewModel)
        ))

        // Collapsed pending withdraw
        let viewModelCollapsed = MockWalletDetailViewModel.highBalanceMock
        let collapsedSectionViewModel = MockCustomExpandableSectionViewModel(
            title: LocalizationProvider.string("pending_withdrawals"),
            isExpanded: false,
            leadingIconName: "arrow.down.circle",
            collapsedIconName: "chevron.down",
            expandedIconName: "chevron.up"
        )
        viewModelCollapsed.pendingWithdrawSectionViewModel = collapsedSectionViewModel
        viewModelCollapsed.pendingWithdrawViewModels = [MockPendingWithdrawViewModel()]

        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Pending Withdraw (Collapsed)",
            view: createWalletDetailView(viewModel: viewModelCollapsed)
        ))
    }

    // MARK: - Helper Methods

    private func createWalletDetailView(viewModel: MockWalletDetailViewModel) -> WalletDetailView {
        let walletView = WalletDetailView(viewModel: viewModel)
        walletView.translatesAutoresizingMaskIntoConstraints = false
        return walletView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Balance Variants") {
    WalletDetailViewSnapshotViewController(category: .balanceVariants)
}

#Preview("Edge Cases") {
    WalletDetailViewSnapshotViewController(category: .edgeCases)
}

#Preview("With Pending Withdraw") {
    WalletDetailViewSnapshotViewController(category: .withPendingWithdraw)
}
#endif
