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
    private lazy var baseIconView: UIView = Self.createBaseIconView()
    private lazy var transactionIcon: UIImageView = Self.createImageView()
    private lazy var transactionTypeLabel: UILabel = Self.createTypeLabel()
    private lazy var transactionValueLabel: UILabel = Self.createValueLabel()
    private lazy var transactionDateLabel: UILabel = Self.createDateLabel()
    private lazy var transactionIdLabel: UILabel = Self.createIdLabel()
    private lazy var transactionIdValueLabel: UILabel = Self.createIdValueLabel()
    private lazy var gameTransactionIdLabel: UILabel = Self.createGameTransactionIdLabel()
    private lazy var gameTransactionIdValueLabel: UILabel = Self.createGameTransactionIdValueLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var separatorView: UIView = Self.createSeparatorView()

//    private lazy var dateLabelBottomConstraint: NSLayoutConstraint = Self.createDateLabelBottomConstraint()
//    private lazy var gameTranIdBottomConstraint: NSLayoutConstraint = Self.createGameTranIdBottomConstraint()
    
    var transactionHistoryEntry: TransactionHistory?

    var hasPendingTransaction: Bool = false {
        didSet {
            self.cancelButton.isHidden = !hasPendingTransaction
        }
    }

    var hasGameTranId: Bool = false {
        didSet {
            self.gameTransactionIdLabel.isHidden = !hasGameTranId
            self.gameTransactionIdValueLabel.isHidden = !hasGameTranId

//            self.dateLabelBottomConstraint.isActive = !hasGameTranId
//
//            self.gameTranIdBottomConstraint.isActive = hasGameTranId
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
        self.hasGameTranId = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseIconView.layer.cornerRadius = self.baseIconView.frame.size.width/2

        self.baseIconView.layer.shadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.18).cgColor
        self.baseIconView.layer.shadowOpacity = 1
        self.baseIconView.layer.shadowOffset = .zero
        self.baseIconView.layer.shadowRadius = 10
        self.baseIconView.layer.shouldRasterize = true
        self.baseIconView.layer.rasterizationScale = UIScreen.main.scale

    }

    // MARK: - Layout and Theme

    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.layer.cornerRadius = 10

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary

        self.baseIconView.backgroundColor = UIColor.App.backgroundCards

        self.transactionTypeLabel.textColor = UIColor.App.textPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine
        
        self.transactionIdLabel.textColor = UIColor.App.textPrimary

        self.transactionIdValueLabel.textColor = UIColor.App.textSecondary

        self.transactionDateLabel.textColor = UIColor.App.textSecondary

        self.transactionValueLabel.textColor = UIColor.App.textPrimary

        self.gameTransactionIdLabel.textColor = UIColor.App.textPrimary

        self.gameTransactionIdValueLabel.textColor = UIColor.App.textSecondary

//        self.cancelButton.backgroundColor = .clear
//
//        self.cancelButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        StyleHelper.styleButton(button: cancelButton)
    }

    func configure(withTransactionHistoryEntry transactionHistoryEntry: TransactionHistory,
                   transactionType: TransactionsHistoryViewModel.TransactionsType) {
        self.transactionHistoryEntry = transactionHistoryEntry

        if let date = DateFormatter.init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: transactionHistoryEntry.time) {
            self.transactionDateLabel.text = TransactionsTableViewCell.dateFormatter.string(from: date)
        }
        else if let date = DateFormatter.init(format: "dd-MM-yyyy HH:mm:ss").date(from: transactionHistoryEntry.time) {

            let dateFormatter = Self.dateFormatter
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"

            self.transactionDateLabel.text = dateFormatter.string(from: date)
        }

        self.transactionIdValueLabel.text = transactionHistoryEntry.transactionID

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

        self.transactionTypeLabel.text = transactionHistoryEntry.type

        switch transactionHistoryEntry.valueType {
        case .won:
            self.transactionIcon.image = UIImage(named: "deposit_icon")
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
                self.transactionValueLabel.text = "+" + amount
            }
        case .loss:
            self.transactionIcon.image = UIImage(named: "withdraw_icon")
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
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)) {
                self.transactionValueLabel.text = amount
            }

        }

        // Automated withdraw icons

        if transactionHistoryEntry.type == localized("automated_withdrawal") {
            self.transactionIcon.image = UIImage(named: "automated_withdraw_icon")
        }
        else if transactionHistoryEntry.type == localized("automated_withdrawal_threshold") {
            self.transactionIcon.image = UIImage(named: "automated_withdraw_threshold_icon")
        }

        self.hasPendingTransaction = false

        if let gameTranId = transactionHistoryEntry.id,
           let gameId = gameTranId.components(separatedBy: "_")[safe: 1] {

//            self.gameTransactionIdLabel.text = "\(localized("bet_id")): \(gameId)"
            self.gameTransactionIdValueLabel.text = gameId
            self.hasGameTranId = true

        }
        else {
            self.hasGameTranId = false
        }

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

    private static func createBaseIconView() -> UIView {
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
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = "0.0€"
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 11)
        label.text = "01-01-2000"
        label.textAlignment = .right
        return label
    }

    private static func createIdLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 11)
        label.text = "ID:"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createIdValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 11)
        label.text = "123456"
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
//        let labelAttributes: [NSAttributedString.Key: Any] = [
//            .font: AppFont.with(type: .bold, size: 12),
//            .foregroundColor: UIColor.App.highlightSecondary,
//            .underlineStyle: NSUnderlineStyle.single.rawValue
//        ]
//        let attributeString = NSMutableAttributedString(
//            string: localized("cancel"),
//            attributes: labelAttributes
//        )
//        button.setAttributedTitle(attributeString, for: .normal)
        button.setTitle(localized("cancel"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 12)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private static func createGameTransactionIdLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 11)
        label.text = "\(localized("bet_id")):"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createGameTransactionIdValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 11)
        label.text = "123456"
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

//    private static func createDateLabelBottomConstraint() -> NSLayoutConstraint {
//        let constraint = NSLayoutConstraint()
//        return constraint
//    }
//
//    private static func createGameTranIdBottomConstraint() -> NSLayoutConstraint {
//        let constraint = NSLayoutConstraint()
//        return constraint
//    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.baseIconView)

        self.baseIconView.addSubview(self.transactionIcon)

        self.baseView.addSubview(self.transactionTypeLabel)

        self.baseView.addSubview(self.transactionValueLabel)

        self.baseView.addSubview(self.separatorView)

        self.baseView.addSubview(self.transactionIdLabel)
        self.baseView.addSubview(self.transactionIdValueLabel)
        self.baseView.addSubview(self.transactionDateLabel)
        self.baseView.addSubview(self.gameTransactionIdLabel)
        self.baseView.addSubview(self.gameTransactionIdValueLabel)
        self.baseView.addSubview(self.cancelButton)

        self.initConstraints()

        self.baseView.setNeedsLayout()
        self.baseView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),

            self.baseIconView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12),
            self.baseIconView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 16),
            self.baseIconView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -16),
            self.baseIconView.widthAnchor.constraint(equalToConstant: 52),
            self.baseIconView.heightAnchor.constraint(equalTo: self.baseIconView.widthAnchor),
            
            self.transactionIcon.widthAnchor.constraint(equalToConstant: 28),
            self.transactionIcon.heightAnchor.constraint(equalTo: self.transactionIcon.widthAnchor),
            self.transactionIcon.centerXAnchor.constraint(equalTo: self.baseIconView.centerXAnchor),
            self.transactionIcon.centerYAnchor.constraint(equalTo: self.baseIconView.centerYAnchor),
            
            self.transactionTypeLabel.leadingAnchor.constraint(equalTo: self.baseIconView.trailingAnchor, constant: 20),
            self.transactionTypeLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 13),

            self.transactionValueLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -14),
            self.transactionValueLabel.leadingAnchor.constraint(equalTo: self.transactionTypeLabel.trailingAnchor, constant: 6),
            self.transactionValueLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 9),

            self.separatorView.leadingAnchor.constraint(equalTo: self.transactionTypeLabel.leadingAnchor),
            self.separatorView.trailingAnchor.constraint(equalTo: self.transactionValueLabel.trailingAnchor),
            self.separatorView.topAnchor.constraint(equalTo: self.transactionTypeLabel.bottomAnchor, constant: 6),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),

            self.transactionIdLabel.leadingAnchor.constraint(equalTo: self.separatorView.leadingAnchor),
            self.transactionIdLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 6),

            self.transactionIdValueLabel.leadingAnchor.constraint(equalTo: self.transactionIdLabel.trailingAnchor, constant: 2),
            self.transactionIdValueLabel.centerYAnchor.constraint(equalTo: self.transactionIdLabel.centerYAnchor),

            self.transactionDateLabel.trailingAnchor.constraint(equalTo: self.separatorView.trailingAnchor),
            self.transactionDateLabel.leadingAnchor.constraint(equalTo: self.transactionIdValueLabel.trailingAnchor, constant: 8),
            self.transactionDateLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 6),

            self.gameTransactionIdLabel.leadingAnchor.constraint(equalTo: self.separatorView.leadingAnchor),
            self.gameTransactionIdLabel.topAnchor.constraint(equalTo: self.transactionIdLabel.bottomAnchor, constant: 4),

            self.gameTransactionIdValueLabel.leadingAnchor.constraint(equalTo: self.gameTransactionIdLabel.trailingAnchor, constant: 2),
            self.gameTransactionIdValueLabel.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor, constant: -8),
            self.gameTransactionIdValueLabel.centerYAnchor.constraint(equalTo: self.gameTransactionIdLabel.centerYAnchor),

            self.cancelButton.heightAnchor.constraint(equalToConstant: 22),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.separatorView.trailingAnchor),
            self.cancelButton.topAnchor.constraint(greaterThanOrEqualTo: self.transactionDateLabel.bottomAnchor, constant: 5),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -5)

        ])

//        self.dateLabelBottomConstraint = self.transactionDateLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -15)
//        self.dateLabelBottomConstraint.isActive = true
//
//        self.gameTranIdBottomConstraint = self.gameTransactionIdLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -15)
//        self.gameTranIdBottomConstraint.isActive = false

    }

}
