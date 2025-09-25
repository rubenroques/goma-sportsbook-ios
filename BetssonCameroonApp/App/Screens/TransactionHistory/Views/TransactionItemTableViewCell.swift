//
//  TransactionItemTableViewCell.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import UIKit

final class TransactionItemTableViewCell: UITableViewCell {

    // MARK: - Constants

    struct Constants {
        static let horizontalInset: CGFloat = 0
        static let verticalInset: CGFloat = 0
    }

    // MARK: - Properties

    private let transactionItemView: TransactionItemView

    // MARK: - Cell Identifier

    static let identifier = "TransactionItemTableViewCell"

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.transactionItemView = TransactionItemView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        self.transactionItemView = TransactionItemView()
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Cell Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the transaction view to empty state
        transactionItemView.reset()
    }

    // MARK: - Setup

    private func setupCell() {
        // Clear background and selection
        contentView.backgroundColor = UIColor.App.backgroundPrimary
        backgroundColor = UIColor.App.backgroundPrimary
        selectionStyle = .none

        // Setup transaction item view
        transactionItemView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionItemView)

        // Setup constraints
        NSLayoutConstraint.activate([
            transactionItemView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            transactionItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            transactionItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            transactionItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset)
        ])
    }

    // MARK: - Configuration

    func configure(
        with viewModel: TransactionItemViewModel?,
        cornerRadiusStyle: TransactionCornerRadiusStyle,
        isFirstCell: Bool = false,
        isLastCell: Bool = false
    ) {
        // Configure the transaction item view with the viewModel and corner radius
        transactionItemView.configure(with: viewModel, cornerRadiusStyle: cornerRadiusStyle)
    }

}
