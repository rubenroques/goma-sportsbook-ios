//
//  BettingsTableViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 16/02/2022.
//

import UIKit

class BettingsTableViewCell : UITableViewCell {

    // MARK: - Private Properties
    // Sub Views
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var interiorView: UIView = Self.createBaseView()
    private lazy var lateralView: UIView = Self.createBaseView()
    private lazy var betTypeLabel: UILabel = Self.createLabel()
    private lazy var betDateLabel: UILabel = Self.createLabel()
    private lazy var betStatusLabel: UILabel = Self.createLabel()
    private lazy var betIdLabel: UILabel = Self.createLabel()
    private lazy var totalOddLabel: UILabel = Self.createLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createLabel()
    private lazy var betAmountLabel: UILabel = Self.createLabel()
    private lazy var betAmountValueLabel: UILabel = Self.createLabel()
    private lazy var possibleWinningsLabel: UILabel = Self.createLabel()
    private lazy var possibleWinningsValueLabel: UILabel = Self.createLabel()
    private lazy var separatorView: UIView = Self.createSimpleView()
    private lazy var labelsStackView: UIStackView = Self.createHorizontalStackView()
    private lazy var valuesStackView: UIStackView = Self.createHorizontalStackView()
    private lazy var oddsStackView: UIStackView = Self.createVerticalStackView()
    private lazy var betAmountStackView: UIStackView = Self.createVerticalStackView()
    private lazy var possibleEarningsStackView: UIStackView = Self.createVerticalStackView()
    
    
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

        self.betTypeLabel.textColor = UIColor.App.textPrimary
        self.betStatusLabel.textColor = UIColor.App.textPrimary
        
        self.betDateLabel.textColor = UIColor.App.textSecondary
        self.betIdLabel.textColor = UIColor.App.textSecondary
        
        self.totalOddLabel.textColor = UIColor.App.textPrimary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        
        self.betAmountLabel.textColor = UIColor.App.textPrimary
        self.betAmountValueLabel.textColor = UIColor.App.textPrimary
        
        self.possibleWinningsLabel.textColor = UIColor.App.textPrimary
        self.possibleWinningsValueLabel.textColor = UIColor.App.textPrimary
        
        self.separatorView.backgroundColor = UIColor.App.separatorLine
 
    }
    
    func setupDetailsLabel(betType : String, betStatus : String ){
        
        if betStatus == "Lost"{
            self.lateralView.backgroundColor = UIColor.App.myTicketsLost
        }else if betStatus == "Won"{
            self.lateralView.backgroundColor = UIColor.App.myTicketsWon
        }else if betStatus == "Cashout"{
            self.lateralView.backgroundColor = UIColor.App.alertWarning
            
        }else{

            self.lateralView.backgroundColor = .clear
        }
        
        self.betTypeLabel.text = betType + " - " + betStatus
        self.betTypeLabel.font = AppFont.with(type: .bold, size: 14)
    }
    
    func setupDateLabel(date : String ){
      
        self.betDateLabel.text = date
        self.betDateLabel.font = AppFont.with(type: .medium, size: 10)
    }

    func setupIdLabel(id : String ){
      
        self.betIdLabel.text = id
        self.betIdLabel.font = AppFont.with(type: .medium, size: 10)
    }
    
    func setupOddValuesLabel(oddValue : String){
       
        self.totalOddLabel.font = AppFont.with(type: .semibold, size: 12)
        self.totalOddLabel.text = localized("total_odd")
        self.totalOddValueLabel.font = AppFont.with(type: .semibold, size: 16)
        self.totalOddValueLabel.text = oddValue
    }
    
    func setupBetAmountValuesLabel(betAmount : String){
        
        self.betAmountLabel.font = AppFont.with(type: .semibold, size: 12)
        self.betAmountLabel.text = localized("bet_amount")
        self.betAmountValueLabel.font = AppFont.with(type: .semibold, size: 16)
        self.betAmountValueLabel.text = betAmount
        
    }
    
    func setupPossibleWinningsValuesLabel(possibleWinnings : String, betStatus : String){
        
        if betStatus == "Cashout"{
            self.possibleWinningsLabel.text = localized("return")
        }else{
            self.possibleWinningsLabel.text = localized("possible_winnings")
        }
        self.possibleWinningsLabel.font = AppFont.with(type: .semibold, size: 12)
        
        self.possibleWinningsValueLabel.font = AppFont.with(type: .semibold, size: 16)
        self.possibleWinningsValueLabel.text = possibleWinnings
        
    }
}



//
// MARK: - Subviews Initialization and Setup
//
extension BettingsTableViewCell {

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
        label.text = "---"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHorizontalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        
        return stack
    }
    
    private static func createVerticalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 12
        
        return stack
    }
    
    
    
 
    private func setupSubviews() {

        // Add subviews to self.view or each other
      /*
        self.labelsStackView.addSubview(self.totalOddLabel)
        self.labelsStackView.addSubview(self.betAmountLabel)
        self.labelsStackView.addSubview(self.possibleWinningsLabel)
        
        self.valuesStackView.addSubview(self.totalOddValueLabel)
        self.valuesStackView.addSubview(self.betAmountValueLabel)
        self.valuesStackView.addSubview(self.possibleWinningsValueLabel)
       */
       
        
  
        
       
        self.oddsStackView.addArrangedSubview(self.totalOddLabel)
        self.oddsStackView.addArrangedSubview(self.totalOddValueLabel)
        
        self.betAmountStackView.addArrangedSubview(self.betAmountLabel)
        self.betAmountStackView.addArrangedSubview(self.betAmountValueLabel)
        
        self.possibleEarningsStackView.addArrangedSubview(self.possibleWinningsLabel)
        self.possibleEarningsStackView.addArrangedSubview(self.possibleWinningsValueLabel)
        
        self.valuesStackView.addArrangedSubview(self.oddsStackView)
        self.valuesStackView.addArrangedSubview(self.betAmountStackView)
        self.valuesStackView.addArrangedSubview(self.possibleEarningsStackView)
        
        
        self.baseView.addSubview(self.valuesStackView)
        //self.baseView.addSubview(self.separatorView)
        self.baseView.addSubview(self.betIdLabel)
        self.baseView.addSubview(self.betTypeLabel)
        self.baseView.addSubview(self.betDateLabel)
        self.baseView.addSubview(self.lateralView)
        
        self.baseView.addSubview(self.separatorView)
       
        
        self.interiorView.addSubview(self.baseView)
        self.addSubview(self.interiorView)
 
        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        
       /* NSLayoutConstraint.activate([
            
            self.labelsStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.labelsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.labelsStackView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.labelsStackView.bottomAnchor.constraint(equalTo: self.separatorView.topAnchor, constant: -16),
            //self.labelsStackView.widthAnchor.constraint(equalToConstant: 20),
            
           /* self.totalOddLabel.leadingAnchor.constraint(equalTo: self.labelsStackView.leadingAnchor, constant: 16),
            //self.totalOddValueLabel.trailingAnchor.constraint(equalTo: self.valuesStackView.trailingAnchor, constant: -16),
            self.totalOddLabel.centerYAnchor.constraint(equalTo: self.labelsStackView.centerYAnchor),
            
            self.betAmountLabel.centerXAnchor.constraint(equalTo: self.labelsStackView.centerXAnchor),
            self.betAmountLabel.centerYAnchor.constraint(equalTo: self.labelsStackView.centerYAnchor),
            
            //self.possibleWinningsValueLabel.leadingAnchor.constraint(equalTo: self.valuesStackView.leadingAnchor, constant: 16),
            self.possibleWinningsLabel.trailingAnchor.constraint(equalTo: self.labelsStackView.trailingAnchor, constant: -16),
            self.possibleWinningsLabel.centerYAnchor.constraint(equalTo: self.labelsStackView.centerYAnchor),*/
            
        ])*/
        

        
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
           
            self.lateralView.widthAnchor.constraint(equalToConstant: 8),
            self.lateralView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.lateralView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.lateralView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            
            self.separatorView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.separatorView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorView.centerYAnchor.constraint(equalTo: self.valuesStackView.centerYAnchor),
             
            self.betTypeLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.betTypeLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 12),
            
            self.betDateLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.betDateLabel.centerXAnchor.constraint(equalTo: self.betTypeLabel.centerXAnchor),
            self.betDateLabel.topAnchor.constraint(equalTo: self.betTypeLabel.bottomAnchor, constant: 6),
       
            self.betIdLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.betIdLabel.centerYAnchor.constraint(equalTo: self.betTypeLabel.centerYAnchor),
            
            self.valuesStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.valuesStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.valuesStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -16),
            self.valuesStackView.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            
       
            
        ])

    
    }

}

    
