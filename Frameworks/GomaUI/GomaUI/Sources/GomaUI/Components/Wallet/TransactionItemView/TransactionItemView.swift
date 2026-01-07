import UIKit
import SwiftUI

public class TransactionItemView: UIView {

    // MARK: - Properties

    private var viewModel: TransactionItemViewModelProtocol?
    private var cornerRadiusStyle: TransactionCornerRadiusStyle

    // MARK: - UI Components

    private let wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()

    // Row 1: Header
    private lazy var headerView: UIView = Self.createRowView()
    private lazy var categoryLabel: UILabel = Self.createCategoryLabel()
    private lazy var statusBadgeView: UIView = Self.createStatusBadgeView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    private lazy var amountLabel: UILabel = Self.createAmountLabel()

    // Row 2: Transaction ID
    private lazy var transactionIdView: UIView = Self.createRowView()
    private lazy var transactionIdLabel: UILabel = Self.createTransactionIdLabel()
    private lazy var copyButton: UIButton = Self.createCopyButton()

    // Row 3: Footer
    private lazy var footerView: UIView = Self.createRowView()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var balanceLabel: UILabel = Self.createBalanceLabel()

    // Separators
    private lazy var separator1: UIView = Self.createSeparator()
    private lazy var separator2: UIView = Self.createSeparator()

    // MARK: - Initialization

    public init(viewModel: TransactionItemViewModelProtocol? = MockTransactionItemViewModel.defaultMock, cornerRadiusStyle: TransactionCornerRadiusStyle = .none) {
        self.viewModel = viewModel
        self.cornerRadiusStyle = cornerRadiusStyle
        super.init(frame: .zero)
        setupUI()
        configureContent()
    }

    required init?(coder: NSCoder) {
        self.viewModel = nil
        self.cornerRadiusStyle = .none
        super.init(coder: coder)
        setupUI()
        configureContent()
    }

    // MARK: - Setup

    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        setupViewHierarchy()
        setupConstraints()
        setupActions()
        applyCornerRadius()
    }

    private func setupViewHierarchy() {
        addSubview(wrapperView)

        wrapperView.addSubview(containerView)

        containerView.addSubview(mainStackView)

        // Setup header row
        headerView.addSubview(categoryLabel)
        headerView.addSubview(statusBadgeView)
        statusBadgeView.addSubview(statusLabel)
        headerView.addSubview(amountLabel)

        // Setup transaction ID row
        transactionIdView.addSubview(transactionIdLabel)
        transactionIdView.addSubview(copyButton)

        // Setup footer row
        footerView.addSubview(dateLabel)
        footerView.addSubview(balanceLabel)

        // Add to stack view
        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(separator1)
        mainStackView.addArrangedSubview(transactionIdView)
        mainStackView.addArrangedSubview(separator2)
        mainStackView.addArrangedSubview(footerView)
    }

    private func setupConstraints() {
        // Set content priorities to ensure statusBadgeView and amountLabel are always visible
        // Category label should be compressed first when space is limited
        categoryLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        statusBadgeView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Set hugging priorities
        categoryLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        statusBadgeView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        amountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            // Wrapper View
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Container View (with padding)
            containerView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -12),

            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Header Row Height
            headerView.heightAnchor.constraint(equalToConstant: 44),

            // Header Row Content
            categoryLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            statusBadgeView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            statusBadgeView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            statusBadgeView.heightAnchor.constraint(equalToConstant: 24),
            statusBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -6),

            statusLabel.topAnchor.constraint(equalTo: statusBadgeView.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadgeView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadgeView.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadgeView.bottomAnchor, constant: -4),

            amountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Transaction ID Row Height
            transactionIdView.heightAnchor.constraint(equalToConstant: 44),

            // Transaction ID Row Content
            transactionIdLabel.leadingAnchor.constraint(equalTo: transactionIdView.leadingAnchor, constant: 16),
            transactionIdLabel.centerYAnchor.constraint(equalTo: transactionIdView.centerYAnchor),

            copyButton.trailingAnchor.constraint(equalTo: transactionIdView.trailingAnchor, constant: -16),
            copyButton.centerYAnchor.constraint(equalTo: transactionIdView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),

            // Footer Row Height
            footerView.heightAnchor.constraint(equalToConstant: 44),

            // Footer Row Content
            dateLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),

            balanceLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            balanceLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),

            // Separators
            separator1.heightAnchor.constraint(equalToConstant: 1),
            separator2.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupActions() {
        copyButton.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
    }

    private func applyCornerRadius() {
        let cornerRadius: CGFloat = 8

        switch cornerRadiusStyle {
        case .all:
            wrapperView.layer.cornerRadius = cornerRadius
            wrapperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .topOnly:
            wrapperView.layer.cornerRadius = cornerRadius
            wrapperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottomOnly:
            wrapperView.layer.cornerRadius = cornerRadius
            wrapperView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .none:
            wrapperView.layer.cornerRadius = 0
        }

        wrapperView.layer.masksToBounds = true
        wrapperView.clipsToBounds = true
    }

    private func configureContent() {
        guard let viewModel = viewModel, let data = viewModel.data else {
            clearContent()
            return
        }

        // Category
        categoryLabel.text = data.category

        // Status badge
        if let status = data.status {
            statusBadgeView.isHidden = false
            statusLabel.text = status.displayName
            statusBadgeView.backgroundColor = status.backgroundColor
            statusLabel.textColor = status.textColor
        } else {
            statusBadgeView.isHidden = true
        }

        // Amount
        amountLabel.text = data.formattedAmount
        amountLabel.textColor = data.isPositive ? StyleProvider.Color.alertSuccess : StyleProvider.Color.highlightTertiary

        // Transaction ID
        transactionIdLabel.text = data.transactionId

        // Date
        dateLabel.text = data.formattedDate

        // Balance - create attributed string with normal and bold parts or hide if no balance
        if data.balance != nil && !viewModel.balanceAmount.isEmpty {
            balanceLabel.isHidden = false
            let balanceAttributedString = NSMutableAttributedString()

            let balancePrefix = NSAttributedString(
                string: viewModel.balancePrefix,
                attributes: [
                    .font: StyleProvider.fontWith(type: .medium, size: 14),
                    .foregroundColor: StyleProvider.Color.iconSecondary
                ]
            )

            let balanceAmount = NSAttributedString(
                string: viewModel.balanceAmount,
                attributes: [
                    .font: StyleProvider.fontWith(type: .bold, size: 14),
                    .foregroundColor: StyleProvider.Color.iconSecondary
                ]
            )

            balanceAttributedString.append(balancePrefix)
            balanceAttributedString.append(balanceAmount)
            balanceLabel.attributedText = balanceAttributedString
        } else {
            balanceLabel.isHidden = true
        }
    }

    private func clearContent() {
        // Clear all text content
        categoryLabel.text = ""
        statusLabel.text = ""
        amountLabel.text = ""
        transactionIdLabel.text = ""
        dateLabel.text = ""
        balanceLabel.text = ""
        balanceLabel.attributedText = nil

        // Hide status badge
        statusBadgeView.isHidden = true

        // Show balance label by default (it will be hidden if needed in configureContent)
        balanceLabel.isHidden = false

        // Reset colors to default
        amountLabel.textColor = StyleProvider.Color.textPrimary
    }

    // MARK: - Actions

    @objc private func didTapCopy() {
        viewModel?.copyTransactionId()
    }

    // MARK: - Public Methods

    public func configure(with viewModel: TransactionItemViewModelProtocol?) {
        self.viewModel = viewModel
        configureContent()
    }

    public func configure(with viewModel: TransactionItemViewModelProtocol?, cornerRadiusStyle: TransactionCornerRadiusStyle) {
        self.viewModel = viewModel
        self.cornerRadiusStyle = cornerRadiusStyle
        configureContent()
        applyCornerRadius()
    }

    public func configure(with cornerRadiusStyle: TransactionCornerRadiusStyle) {
        self.cornerRadiusStyle = cornerRadiusStyle
        applyCornerRadius()
    }

    public func reset() {
        clearContent()
    }
}

// MARK: - Factory Methods

extension TransactionItemView {

    private static func createRowView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createCategoryLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.highlightTertiary
        return label
    }

    private static func createStatusBadgeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }

    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createAmountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textAlignment = .right
        return label
    }

    private static func createTransactionIdLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }

    private static func createCopyButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.tintColor = StyleProvider.Color.textSecondary
        return button
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.iconSecondary
        return label
    }

    private static func createBalanceLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.iconSecondary
        label.textAlignment = .right
        return label
    }

    private static func createSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.separatorLine
        return view
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("Transaction Item - Deposit") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray5

        let transactionView = TransactionItemView(viewModel: MockTransactionItemViewModel.depositMock)
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(transactionView)

        NSLayoutConstraint.activate([
            transactionView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            transactionView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            transactionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            transactionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#Preview("Transaction Item - Bet Won") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray5

        let transactionView = TransactionItemView(viewModel: MockTransactionItemViewModel.betWonMock)
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(transactionView)

        NSLayoutConstraint.activate([
            transactionView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            transactionView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            transactionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            transactionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#Preview("Transaction Item - Bet Placed") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray5

        let transactionView = TransactionItemView(viewModel: MockTransactionItemViewModel.betPlacedMock)
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(transactionView)

        NSLayoutConstraint.activate([
            transactionView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            transactionView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            transactionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            transactionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#Preview("Corner Radius Test - Three Cards") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red

        // Container view for the three cards
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .blue
        containerView.layer.cornerRadius = 12
        vc.view.addSubview(containerView)

        // Create stack view for the three transaction cards
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        containerView.addSubview(stackView)

        // First card (top only corners)
        let firstCard = TransactionItemView(
            viewModel: MockTransactionItemViewModel.depositMock,
            cornerRadiusStyle: .topOnly
        )

        // Middle card (no corners)
        let middleCard = TransactionItemView(
            viewModel: MockTransactionItemViewModel.betPlacedMock,
            cornerRadiusStyle: .none
        )

        // Last card (bottom only corners)
        let lastCard = TransactionItemView(
            viewModel: MockTransactionItemViewModel.betWonMock,
            cornerRadiusStyle: .bottomOnly
        )

        stackView.addArrangedSubview(firstCard)
        stackView.addArrangedSubview(middleCard)
        stackView.addArrangedSubview(lastCard)

        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return vc
    }
}

#endif
