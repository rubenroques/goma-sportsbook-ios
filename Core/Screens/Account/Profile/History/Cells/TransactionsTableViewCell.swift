//
//  TransactionsTableViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 15/02/2022.
//

import UIKit
import ServicesProvider

class TransactionsTableViewCell: UITableViewCell {

    // MARK: - Private Properties
    // Sub Views
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var transactionIcon: UIImageView = Self.createImageView()
    private lazy var transactionTypeLabel: UILabel = Self.createTypeLabel()
    private lazy var transactionValueLabel: UILabel = Self.createValueLabel()
    private lazy var transactionDateLabel: UILabel = Self.createDateLabel()
    private lazy var transactionIdLabel: UILabel = Self.createIdLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    
    var transactionHistoryEntry: TransactionHistory?

    var hasPendingTransaction: Bool = false {
        didSet {
            self.cancelButton.isHidden = !hasPendingTransaction
        }
    }
    var shouldCancelPendingTransaction: ((Int) -> Void)?
    
    // MARK: - Lifetime and Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupSubviews()
        self.setupWithTheme()

        self.cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCancelButton)))

        self.hasPendingTransaction = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.hasPendingTransaction = false
    }

    // MARK: - Layout and Theme

    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.layer.cornerRadius = 10

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.transactionTypeLabel.textColor = UIColor.App.textPrimary
        
        self.transactionIdLabel.textColor = UIColor.App.textSecondary
        self.transactionDateLabel.textColor = UIColor.App.textSecondary
        self.transactionValueLabel.textColor = UIColor.App.textPrimary

        self.cancelButton.backgroundColor = .clear

        self.cancelButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

    }

    func configure(withTransactionHistoryEntry transactionHistoryEntry: TransactionHistory,
                   transactionType: TransactionsHistoryViewModel.TransactionsType) {
        self.transactionHistoryEntry = transactionHistoryEntry

        if let date = DateFormatter.init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: transactionHistoryEntry.time) {
            self.transactionDateLabel.text = TransactionsTableViewCell.dateFormatter.string(from: date)
        }
        else if let date = DateFormatter.init(format: "dd-MM-yyyy HH:mm:ss").date(from: transactionHistoryEntry.time) {

            let dateFormatter = Self.dateFormatter
            dateFormatter.dateFormat = "dd-MM-yyyy"

            self.transactionDateLabel.text =
            dateFormatter.string(from: date)
        }
        self.transactionIdLabel.text = "ID: \(transactionHistoryEntry.transactionID)"

//        switch transactionType {
//        case .deposit:
//            self.transactionIcon.image = UIImage(named: "deposit_icon")
//            self.transactionTypeLabel.text = localized("deposit")
//            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
//                self.transactionValueLabel.text = "+ " + amount
//            }
//        case .withdraw:
//            self.transactionIcon.image = UIImage(named: "withdraw_icon")
//            self.transactionTypeLabel.text = localized("withdraw")
//            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.credit.amount)) {
//                self.transactionValueLabel.text = "- " + amount
//            }
//        }

        switch transactionHistoryEntry.valueType {
        case .won:
            self.transactionIcon.image = UIImage(named: "deposit_icon")
            self.transactionTypeLabel.text = transactionHistoryEntry.type
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
                self.transactionValueLabel.text = "+" + amount
            }
        case .loss:
            self.transactionIcon.image = UIImage(named: "withdraw_icon")
            self.transactionTypeLabel.text = transactionHistoryEntry.type
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
                if transactionHistoryEntry.debit.amount > 0 {
                    self.transactionValueLabel.text = "-" + amount
                }
                else {
                    self.transactionValueLabel.text = amount
                }
            }
        case .neutral:
            self.transactionIcon.image = UIImage(named: "neutral_icon")
            self.transactionTypeLabel.text = transactionHistoryEntry.type
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
                self.transactionValueLabel.text = amount
            }

        }

        self.hasPendingTransaction = false

    }

    @objc private func didTapCancelButton() {
        print("CANCEL")
        if let paymentId = self.transactionHistoryEntry?.paymentId {
            self.shouldCancelPendingTransaction?(paymentId)
        }
    }

}

extension TransactionsTableViewCell {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}

//
// MARK: - Subviews Initialization and Setup
//
extension TransactionsTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private static func createTypeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = "Transaction Type"
        return label
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = "0.0€"
        return label
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "01-01-2000"
        return label
    }

    private static func createIdLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 10)
        label.text = "ID: 0000"
        return label
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.with(type: .bold, size: 12),
            .foregroundColor: UIColor.App.highlightSecondary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributeString = NSMutableAttributedString(
            string: localized("cancel"),
            attributes: labelAttributes
        )
        button.setAttributedTitle(attributeString, for: .normal)
        return button
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.transactionIcon)
        self.baseView.addSubview(self.transactionIdLabel)
        self.baseView.addSubview(self.transactionDateLabel)
        self.baseView.addSubview(self.transactionTypeLabel)
        self.baseView.addSubview(self.transactionValueLabel)
        self.baseView.addSubview(self.cancelButton)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            
            self.transactionIcon.heightAnchor.constraint(equalToConstant: 18),
            self.transactionIcon.widthAnchor.constraint(equalToConstant: 18),
            self.transactionIcon.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.transactionIcon.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 15),
            
            self.transactionTypeLabel.leadingAnchor.constraint(equalTo: self.transactionIcon.trailingAnchor, constant: 9),
            self.transactionTypeLabel.centerYAnchor.constraint(equalTo: self.transactionIcon.centerYAnchor),
            self.transactionTypeLabel.trailingAnchor.constraint(equalTo: self.transactionValueLabel.leadingAnchor, constant: -6),

            self.transactionIdLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.transactionIdLabel.topAnchor.constraint(equalTo: self.transactionTypeLabel.bottomAnchor, constant: 6),
       
            self.transactionValueLabel.centerYAnchor.constraint(equalTo: self.transactionIcon.centerYAnchor),
            self.transactionValueLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),

            self.transactionDateLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.transactionDateLabel.topAnchor.constraint(equalTo: self.transactionIdLabel.bottomAnchor, constant: 8),
            self.transactionDateLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -15),

            self.cancelButton.heightAnchor.constraint(equalToConstant: 40),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),
            self.cancelButton.topAnchor.constraint(equalTo: self.transactionValueLabel.bottomAnchor, constant: 0)

        ])

    }

}
