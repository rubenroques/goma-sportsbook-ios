//
//  TransactionsTableViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 15/02/2022.
//

import UIKit

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
    
    var transactionHistoryEntry : EveryMatrix.TransactionHistory?
    
    
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
        self.baseView.layer.cornerRadius = 10
        
        self.interiorView.backgroundColor = .clear
        
        self.baseView.backgroundColor = UIColor.App.backgroundCards
        self.transactionTypeLabel.textColor = UIColor.App.textPrimary
        
        self.transactionIdLabel.textColor = UIColor.App.textSecondary
        self.transactionDateLabel.textColor = UIColor.App.textSecondary
        self.transactionValueLabel.textColor = UIColor.App.textPrimary
        
    }
    
    func setTransactionIcon(transactionType : Int){
        
        if transactionType == 0 {
            self.transactionIcon.image = UIImage(named: "icon_excluded")
        }else{
            self.transactionIcon.image = UIImage(named: "icon_active")
        }
        
    }

    func setTransactionTypeLabel(transactionType : Int){
        
        if transactionType == 0 {
            self.transactionTypeLabel.text = "Deposit"
        }else{
            self.transactionTypeLabel.text = "Withdraw"
        }
        self.transactionTypeLabel.font = AppFont.with(type: .bold, size: 14)
        
    }

    func setTransactionValueLabel(transactionType : Int, transactionValue : String){
        
        if transactionType == 0 {
            self.transactionValueLabel.text = "+"+transactionValue
        }else{
            self.transactionValueLabel.text = "-"+transactionValue
        }
        self.transactionValueLabel.font = AppFont.with(type: .semibold, size: 16)
        
    }
    
    func setTransactionDateLabel(transactionDate : String){
        
        self.transactionDateLabel.text = transactionDate
        self.transactionDateLabel.font = AppFont.with(type: .medium, size: 12)
    }
    
    func setTransactionIdLabel(transactionId : String){
        
        self.transactionIdLabel.text = transactionId
        self.transactionIdLabel.font = AppFont.with(type: .medium, size: 12)
      
    }
    
    
    
    func configure(withTransactionHistoryEntry transactionHistoryEntry: EveryMatrix.TransactionHistory, transactionType : Int) {

        
        setTransactionDateLabel(transactionDate: transactionHistoryEntry.time)
        setTransactionIcon(transactionType: transactionType)
        setTransactionTypeLabel(transactionType: transactionType)
        if transactionType == 0{
          if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.debit.amount)){
                setTransactionValueLabel(transactionType: transactionType, transactionValue: amount)
            }
        
        }else{
            if let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: transactionHistoryEntry.credit.amount)) {
             
                setTransactionValueLabel(transactionType: transactionType, transactionValue: amount)
            }
        }
            setTransactionIdLabel(transactionId: transactionHistoryEntry.transactionID)
            
            
 
    }

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
        label.font = AppFont.with(type: .bold, size: 17)
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
        self.addSubview(self.interiorView)
        

        //self.view.addSubview(self.loadingBaseView)
       // self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

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

    
