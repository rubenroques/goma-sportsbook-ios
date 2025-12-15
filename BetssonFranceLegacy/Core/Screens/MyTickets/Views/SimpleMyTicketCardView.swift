//
//  MyTicketCardView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/12/2021.
//

import UIKit
import Combine
import ServicesProvider

class SimpleMyTicketCardView: NibView {
    
    @IBOutlet private weak var baseView: UIView!
    
    @IBOutlet private weak var topStatusView: UIView!
    
    @IBOutlet private weak var headerBaseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    @IBOutlet private weak var betCardsBaseView: UIView!
    @IBOutlet private weak var betCardsStackView: UIStackView!
    
    @IBOutlet private weak var bottomBaseView: UIView!
    @IBOutlet private weak var bottomSeparatorLineView: UIView!
    @IBOutlet private weak var bottomStackView: UIStackView!
    
    @IBOutlet private weak var amountsBaseView: UIView!
    @IBOutlet private weak var totalOddTitleLabel: UILabel!
    @IBOutlet private weak var totalOddSubtitleLabel: UILabel!
    
    @IBOutlet private weak var betAmountTitleLabel: UILabel!
    @IBOutlet private weak var betAmountSubtitleLabel: UILabel!
    
    @IBOutlet private weak var winningsTitleLabel: UILabel!
    @IBOutlet private weak var winningsSubtitleLabel: UILabel!
  
    @IBOutlet private weak var cashbackTitleLabel: UILabel!
    @IBOutlet private weak var cashbackValueLabel: UILabel!
    
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    private var betHistoryEntry: BetHistoryEntry?
    
    private var viewModel: MyTicketCellViewModel?
    
    private var isLoadingCellDataSubscription: AnyCancellable?
    
    private var cashoutSubscription: AnyCancellable?
    
    private var selectedMatch: String = ""
    
    private var cashoutValue: Double?
    
    private var cancellables = Set<AnyCancellable>()
    
    var tappedMatchDetail: ((String) -> Void)?
    var shouldShowCashbackInfo: (() -> Void)?
    var needsDataUpdate: (() -> Void)?
    
    var partialCashoutMultiSlider: MultiSlider?
    
    deinit {
        print("MyTicketCardView.deinit")
    }
    
    override func commonInit() {
        super.commonInit()
        
        // Setup fonts
        self.titleLabel.font = AppFont.with(type: .heavy, size: 17)
        self.subtitleLabel.font = AppFont.with(type: .bold, size: 12)
                
        self.totalOddTitleLabel.font = AppFont.with(type: .bold, size: 12)
        self.betAmountTitleLabel.font = AppFont.with(type: .bold, size: 12)
        self.winningsTitleLabel.font = AppFont.with(type: .bold, size: 12)
        
        self.totalOddSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
        self.betAmountSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
        
        self.winningsSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
                
        //
        self.loadingView.isHidden = true
        
        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 10
        
        self.baseView.layer.masksToBounds = true
        
        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        
        self.cashbackTitleLabel.isHidden = true
        self.cashbackValueLabel.isHidden = true
        
        self.totalOddTitleLabel.text = localized("total_odd")
        self.totalOddTitleLabel.font = AppFont.with(type: .semibold, size: 12)
        
        self.betAmountTitleLabel.text = localized("bet_amount")
        self.betAmountTitleLabel.font = AppFont.with(type: .semibold, size: 12)
        
        self.winningsTitleLabel.text = localized("return_text")
        self.winningsTitleLabel.font = AppFont.with(type: .semibold, size: 12)
        
        self.totalOddSubtitleLabel.text = "-"
        self.totalOddSubtitleLabel.font = AppFont.with(type: .semibold, size: 16)
        
        self.betAmountSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.font = AppFont.with(type: .semibold, size: 16)
        
        self.winningsSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.font = AppFont.with(type: .semibold, size: 16)
        
        self.setupWithTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        
        self.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.topStatusView.backgroundColor = .clear
        self.headerBaseView.backgroundColor = .clear
        
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear
        
        self.subtitleLabel.textColor = UIColor.App.textSecondary
                
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomStackView.backgroundColor = .clear
       
        self.loadingActivityIndicator.tintColor = UIColor.App.textPrimary
        
        if let status = self.betHistoryEntry?.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.highlightCard(withColor: UIColor.App.myTicketsWon)
            case "LOST", "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
            case "CASHED_OUT", "CANCELLED":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
            default:
                self.resetHighlightedCard()
            }
        }
    }
    
    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry,
                   countryCodes: [String],
                   viewModel: MyTicketCellViewModel,
                   grantedWinBoost: GrantedWinBoostInfo? = nil)
    {
        self.betHistoryEntry = betHistoryEntry
        self.viewModel = viewModel
        
        self.isLoadingCellDataSubscription = self.viewModel?.isLoadingCellData
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingCellData in
                if isLoadingCellData {
                    self?.loadingActivityIndicator.startAnimating()
                }
                else {
                    self?.loadingActivityIndicator.stopAnimating()
                }
                self?.loadingView.isHidden = !isLoadingCellData
            })
        
        self.betCardsStackView.removeAllArrangedSubviews()
        
        for (index, betHistoryEntrySelection) in (betHistoryEntry.selections ?? []).enumerated() {
            
            let myTicketBetLineView = MyTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection,
                                                          countryCode: countryCodes[safe: index] ?? "",
                                                          viewModel: viewModel.selections[index])
            myTicketBetLineView.tappedMatchDetail = { [weak self] matchId in
                self?.tappedMatchDetail?(matchId)
            }
            
            self.betCardsStackView.addArrangedSubview(myTicketBetLineView)
        }
        
        //
        if betHistoryEntry.type?.lowercased() == "single" {
            self.titleLabel.text = localized("single")+" - \(betHistoryEntry.localizedBetStatus.capitalized)"
        }
        else if betHistoryEntry.type?.lowercased() == "multiple" {
            self.titleLabel.text = localized("multiple")+" - \(betHistoryEntry.localizedBetStatus.capitalized)"
        }
        else if betHistoryEntry.type?.lowercased() == "system" {
            self.titleLabel.text = localized("system")+" - \(betHistoryEntry.systemBetType?.capitalized ?? "") - \(betHistoryEntry.localizedBetStatus.capitalized)"
        }
        else if betHistoryEntry.type?.lowercased() == "mix_match" {
            self.titleLabel.text = localized("mix-match")+" - \(betHistoryEntry.localizedBetStatus.capitalized)"
        }
        else {
            self.titleLabel.text = String([betHistoryEntry.type, betHistoryEntry.localizedBetStatus]
                .compactMap({ $0 })
                .map({ $0.capitalized })
                .joined(separator: " - "))
        }
        
        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketCardView.dateFormatter.string(from: date)
        }
        
        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            self.totalOddSubtitleLabel.text = oddValue == 0.0 ? "-" : OddFormatter.formatOdd(withValue: oddValue)
        }
        
        if let betAmount = betHistoryEntry.totalBetAmount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountSubtitleLabel.text = betAmountString
        }
        
        //
        self.winningsTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsSubtitleLabel.text = maxWinningsString
        }
        
        if let status = betHistoryEntry.status?.uppercased() {
            switch status {
            case "WON", "HALF_WON":
                self.highlightCard(withColor: UIColor.App.myTicketsWon)
                self.winningsTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
                self.winningsTitleLabel.text = localized("return_text") // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "CASHED_OUT", "CASHEDOUT":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("return_text") // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "DRAW":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "CANCELLED":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsTitleLabel.textColor = UIColor.App.buttonTextPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.buttonTextPrimary
                
            case "OPEN":
                self.resetHighlightedCard()
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = UIColor.App.textPrimary
                self.totalOddSubtitleLabel.textColor = UIColor.App.textPrimary
                self.betAmountTitleLabel.textColor = UIColor.App.textPrimary
                self.betAmountSubtitleLabel.textColor = UIColor.App.textPrimary
                self.winningsTitleLabel.textColor = UIColor.App.textPrimary
                self.winningsSubtitleLabel.textColor = UIColor.App.textPrimary
                
            default:
                self.resetHighlightedCard()
            }
        }
    }
    
    private func resetHighlightedCard() {
        self.bottomStackView.backgroundColor = .clear
        self.topStatusView.backgroundColor = .clear
        
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
    }
    
    private func highlightCard(withColor color: UIColor) {
        self.bottomStackView.backgroundColor = color
        self.topStatusView.backgroundColor = color
        
        self.bottomSeparatorLineView.backgroundColor = .white
    }
    
}

extension SimpleMyTicketCardView {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
}
