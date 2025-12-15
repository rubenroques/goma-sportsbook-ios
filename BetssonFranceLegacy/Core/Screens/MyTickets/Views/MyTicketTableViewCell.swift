//
//  MyTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/12/2021.
//

import UIKit
import Combine
import ServicesProvider

class MyTicketTableViewCell: UITableViewCell {
    
    private lazy var cardView: MyTicketCardView = {
        let view = MyTicketCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Forward public properties and callbacks to the card view
    var needsHeightRedraw: ((Bool) -> Void)? {
        get { cardView.needsHeightRedraw }
        set { cardView.needsHeightRedraw = newValue }
    }
    
    var tappedShareAction: ((UIImage, BetHistoryEntry) -> Void) {
        get { cardView.tappedShareAction }
        set { cardView.tappedShareAction = newValue }
    }
    
    var tappedMatchDetail: ((String) -> Void)? {
        get { cardView.tappedMatchDetail }
        set { cardView.tappedMatchDetail = newValue }
    }
    
    var shouldShowCashbackInfo: (() -> Void)? {
        get { cardView.shouldShowCashbackInfo }
        set { cardView.shouldShowCashbackInfo = newValue }
    }
    
    var needsDataUpdate: (() -> Void)? {
        get { cardView.needsDataUpdate }
        set { cardView.needsDataUpdate = newValue }
    }
    
    var showPartialCashoutSliderView: Bool {
        get { cardView.showPartialCashoutSliderView }
        set { cardView.showPartialCashoutSliderView = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.commonInit()
        self.setupSubviews()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
        self.setupSubviews()
        self.setupWithTheme()
    }
    
    private func commonInit() {
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset card view for reuse
        self.cardView.needsHeightRedraw = nil
        self.cardView.tappedShareAction = { _, _ in }
        self.cardView.tappedMatchDetail = nil
        self.cardView.shouldShowCashbackInfo = nil
        self.cardView.needsDataUpdate = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Configuration Methods
    
    func configureCashoutButton(withState state: MyTicketCellViewModel.CashoutButtonState) {
        cardView.configureCashoutButton(withState: state)
    }
    
    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry,
                   countryCodes: [String],
                   viewModel: MyTicketCellViewModel,
                   grantedWinBoost: GrantedWinBoostInfo? = nil) {
        cardView.configure(withBetHistoryEntry: betHistoryEntry,
                          countryCodes: countryCodes,
                          viewModel: viewModel,
                          grantedWinBoost: grantedWinBoost)
    }
    
    private func setupSubviews() {
        // Add card view to content view
        self.contentView.addSubview(self.cardView)
        
        // Initialize constraints
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}

extension MyTicketTableViewCell {
    
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
}
