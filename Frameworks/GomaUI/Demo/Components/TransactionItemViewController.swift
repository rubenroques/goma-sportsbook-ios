import UIKit
import GomaUI

class TransactionItemViewController: UIViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = StyleProvider.Color.backgroundPrimary
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addTransactionExamples()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Transaction Item View"

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func addTransactionExamples() {
        // Create section headers and transaction examples

        // Deposit Section
        let depositHeader = createSectionHeader(title: "Deposits")
        stackView.addArrangedSubview(depositHeader)

        let depositView = TransactionItemView(viewModel: MockTransactionItemViewModel.depositMock)
        stackView.addArrangedSubview(depositView)

        // Withdrawal Section
        let withdrawalHeader = createSectionHeader(title: "Withdrawals")
        stackView.addArrangedSubview(withdrawalHeader)

        let withdrawalView = TransactionItemView(viewModel: MockTransactionItemViewModel.withdrawalMock)
        stackView.addArrangedSubview(withdrawalView)

        // Betting Section
        let bettingHeader = createSectionHeader(title: "Betting Transactions")
        stackView.addArrangedSubview(bettingHeader)

        let betPlacedView = TransactionItemView(viewModel: MockTransactionItemViewModel.betPlacedMock)
        stackView.addArrangedSubview(betPlacedView)

        let betWonView = TransactionItemView(viewModel: MockTransactionItemViewModel.betWonMock)
        stackView.addArrangedSubview(betWonView)

        let taxView = TransactionItemView(viewModel: MockTransactionItemViewModel.taxMock)
        stackView.addArrangedSubview(taxView)

        // Corner Radius Examples
        let cornerHeader = createSectionHeader(title: "Corner Radius Styles")
        stackView.addArrangedSubview(cornerHeader)

        let allCornersView = TransactionItemView(
            viewModel: MockTransactionItemViewModel.depositMock,
            cornerRadiusStyle: .all
        )
        stackView.addArrangedSubview(allCornersView)

        let topOnlyView = TransactionItemView(
            viewModel: MockTransactionItemViewModel.withdrawalMock,
            cornerRadiusStyle: .topOnly
        )
        stackView.addArrangedSubview(topOnlyView)

        let bottomOnlyView = TransactionItemView(
            viewModel: MockTransactionItemViewModel.betWonMock,
            cornerRadiusStyle: .bottomOnly
        )
        stackView.addArrangedSubview(bottomOnlyView)
    }

    private func createSectionHeader(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}