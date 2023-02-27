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
    private lazy var interiorView: UIView = Self.createBaseView()
    private lazy var transactionIcon: UIImageView = Self.createImageView()
    private lazy var transactionTypeLabel: UILabel = Self.createLabel()
    private lazy var transactionValueLabel: UILabel = Self.createLabel()
    private lazy var transactionDateLabel: UILabel = Self.createLabel()
    private lazy var transactionIdLabel: UILabel = Self.createLabel()
    
    var transactionHistoryEntry: EveryMatrix.TransactionHistory?
    
    // MARK: - Lifetime and Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupSubviews()
        self.setupWithTheme()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout and Theme

    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.layer.cornerRadius = 10

        self.interiorView.backgroundColor = .clear
        
        self.baseView.backgroundColor = UIColor.App.backgroundCards
        self.transactionTypeLabel.textColor = UIColor.App.textPrimary
        
        self.transactionIdLabel.textColor = UIColor.App.textSecondary
        self.transactionDateLabel.textColor = UIColor.App.textSecondary
        self.transactionValueLabel.textColor = UIColor.App.textPrimary
        
        self.transactionTypeLabel.font = AppFont.with(type: .bold, size: 14)
        self.transactionValueLabel.font = AppFont.with(type: .semibold, size: 16)
        self.transactionDateLabel.font = AppFont.with(type: .medium, size: 12)
        self.transactionIdLabel.font = AppFont.with(type: .medium, size: 12)
    }

    func configure(withTransactionHistoryEntry transactionHistoryEntry: TransactionHistory,
                   transactionType: TransactionsHistoryViewModel.TransactionsType) {

        if let date = DateFormatter.init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: transactionHistoryEntry.time) {
            self.transactionDateLabel.text = TransactionsTableViewCell.dateFormatter.string(from: date)
        }
        self.transactionIdLabel.text = transactionHistoryEntry.transactionID

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
    
    private static func createLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.baseView.addSubview(self.transactionIcon)
        self.baseView.addSubview(self.transactionIdLabel)
        self.baseView.addSubview(self.transactionDateLabel)
        self.baseView.addSubview(self.transactionTypeLabel)
        self.baseView.addSubview(self.transactionValueLabel)
        
        self.interiorView.addSubview(self.baseView)
        self.contentView.addSubview(self.interiorView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.interiorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.interiorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.interiorView.topAnchor.constraint(equalTo: self.topAnchor),
            self.interiorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.interiorView.widthAnchor.constraint(equalToConstant: 90),
            
            self.baseView.leadingAnchor.constraint(equalTo: self.interiorView.leadingAnchor, constant: 16),
            self.baseView.trailingAnchor.constraint(equalTo: self.interiorView.trailingAnchor, constant: -16),
            self.baseView.topAnchor.constraint(equalTo: self.interiorView.topAnchor, constant: 16),
            self.baseView.bottomAnchor.constraint(equalTo: self.interiorView.bottomAnchor),
            
            self.transactionIcon.heightAnchor.constraint(equalToConstant: 16),
            self.transactionIcon.widthAnchor.constraint(equalToConstant: 16),
            self.transactionIcon.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.transactionIcon.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 16),
            
            self.transactionTypeLabel.leadingAnchor.constraint(equalTo: self.transactionIcon.trailingAnchor, constant: 8 ),
            self.transactionTypeLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 16),
           
            self.transactionIdLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -16),
            self.transactionIdLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
       
            self.transactionValueLabel.centerYAnchor.constraint(equalTo: self.transactionIcon.centerYAnchor),
            self.transactionValueLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.transactionValueLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 16),
            
            self.transactionDateLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -16),
            self.transactionDateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),

        ])

    }

}
