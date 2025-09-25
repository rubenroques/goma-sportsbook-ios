//
//  TransactionItemView.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import UIKit
import GomaUI

enum TransactionCornerRadiusStyle {
    case all
    case topOnly
    case bottomOnly
    case none
}

class TransactionItemView: UIView {

    // MARK: - Properties

    private var viewModel: TransactionItemViewModel?
    private var cornerRadiusStyle: TransactionCornerRadiusStyle

    // MARK: - UI Components

    private let wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
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

    init(cornerRadiusStyle: TransactionCornerRadiusStyle = .none) {
        self.viewModel = nil
        self.cornerRadiusStyle = cornerRadiusStyle
        super.init(frame: .zero)
        setupUI()
        configureContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor.App.backgroundPrimary

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
        NSLayoutConstraint.activate([
            // Wrapper View
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Container View (with padding)
            containerView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -8),

            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Header Row Height
            headerView.heightAnchor.constraint(equalToConstant: 56),

            // Header Row Content
            categoryLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            statusBadgeView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 12),
            statusBadgeView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            statusBadgeView.heightAnchor.constraint(equalToConstant: 24),

            statusLabel.topAnchor.constraint(equalTo: statusBadgeView.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadgeView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadgeView.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadgeView.bottomAnchor, constant: -4),

            amountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Transaction ID Row Height
            transactionIdView.heightAnchor.constraint(equalToConstant: 56),

            // Transaction ID Row Content
            transactionIdLabel.leadingAnchor.constraint(equalTo: transactionIdView.leadingAnchor, constant: 16),
            transactionIdLabel.centerYAnchor.constraint(equalTo: transactionIdView.centerYAnchor),

            copyButton.trailingAnchor.constraint(equalTo: transactionIdView.trailingAnchor, constant: -16),
            copyButton.centerYAnchor.constraint(equalTo: transactionIdView.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),

            // Footer Row Height
            footerView.heightAnchor.constraint(equalToConstant: 56),

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

        wrapperView.clipsToBounds = true
    }

    private func configureContent() {
        guard let viewModel = viewModel else {
            // Empty state
            clearContent()
            return
        }

        // Category
        categoryLabel.text = viewModel.category

        // Status badge
        if let status = viewModel.status {
            statusBadgeView.isHidden = false
            statusLabel.text = status.displayName
            statusBadgeView.backgroundColor = status.backgroundColor
            statusLabel.textColor = status.textColor
        } else {
            statusBadgeView.isHidden = true
        }

        // Amount
        amountLabel.text = viewModel.formattedAmount
        amountLabel.textColor = viewModel.isPositive ? StyleProvider.Color.alertSuccess : StyleProvider.Color.alertError

        // Transaction ID
        transactionIdLabel.text = viewModel.transactionId

        // Date
        dateLabel.text = viewModel.formattedDate

        // Balance
        balanceLabel.text = viewModel.formattedBalance
    }

    private func clearContent() {
        // Clear all text content
        categoryLabel.text = ""
        statusLabel.text = ""
        amountLabel.text = ""
        transactionIdLabel.text = ""
        dateLabel.text = ""
        balanceLabel.text = ""

        // Hide status badge
        statusBadgeView.isHidden = true

        // Reset colors to default
        amountLabel.textColor = StyleProvider.Color.textPrimary
    }

    // MARK: - Actions

    @objc private func didTapCopy() {
        viewModel?.copyTransactionId()
    }

    // MARK: - Public Methods

    func configure(with viewModel: TransactionItemViewModel?) {
        self.viewModel = viewModel
        configureContent()
    }

    func configure(with viewModel: TransactionItemViewModel?, cornerRadiusStyle: TransactionCornerRadiusStyle) {
        self.viewModel = viewModel
        self.cornerRadiusStyle = cornerRadiusStyle
        configureContent()
        applyCornerRadius()
    }

    func reset() {
        self.viewModel = nil
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
        label.font = StyleProvider.fontWith(type: .semibold, size: 16)
        label.textColor = StyleProvider.Color.highlightPrimary
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
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
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
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }

    private static func createBalanceLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
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
