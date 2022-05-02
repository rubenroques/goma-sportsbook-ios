//
//  MyTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/12/2021.
//

import UIKit
import Combine

class MyTicketTableViewCell: UITableViewCell {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var topStatusView: UIView!

    @IBOutlet private weak var headerBaseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!

    @IBOutlet private weak var betCardsBaseView: UIView!
    @IBOutlet private weak var betCardsStackView: UIStackView!

    @IBOutlet private weak var bottomBaseView: UIView!
    @IBOutlet private weak var bottomSeparatorLineView: UIView!
    @IBOutlet private weak var bottomStackView: UIStackView!

    @IBOutlet private weak var totalOddTitleLabel: UILabel!
    @IBOutlet private weak var totalOddSubtitleLabel: UILabel!

    @IBOutlet private weak var betAmountTitleLabel: UILabel!
    @IBOutlet private weak var betAmountSubtitleLabel: UILabel!

    @IBOutlet private weak var winningsTitleLabel: UILabel!
    @IBOutlet private weak var winningsSubtitleLabel: UILabel!

    @IBOutlet private weak var cashoutBaseView: UIView!
    @IBOutlet private weak var cashoutButton: UIButton!

    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!

    private var betHistoryEntry: BetHistoryEntry?

    private var viewModel: MyTicketCellViewModel?

    private var isLoadingCellDataSubscription: AnyCancellable?

    private var cashoutSubscription: AnyCancellable?
    
    private var selectedMatch: String = ""

    private var cashoutValue: Double?
    private var showCashoutButton: Bool = false {
        didSet {
            self.cashoutBaseView.isHidden = !showCashoutButton
            if showCashoutButton {
                self.needsHeightRedraw?()
            }
        }
    }

    var snapshot: UIImage?

    var needsHeightRedraw: (() -> Void)?
    var tappedShareAction: (() -> Void)?
    var tappedMatchDetail: ((String) -> Void)?
    
    var selectedIdPublisher: CurrentValueSubject<String, Never> = .init("")

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none

        self.loadingView.isHidden = true

        self.cashoutBaseView.isHidden = true

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 10
        
        self.baseView.layer.masksToBounds = true

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.loadingView.isHidden = true

        self.betHistoryEntry = nil
        self.viewModel = nil

        self.cashoutValue = nil
        self.showCashoutButton = false

        self.cashoutSubscription?.cancel()
        self.cashoutSubscription = nil

        self.isLoadingCellDataSubscription?.cancel()
        self.isLoadingCellDataSubscription = nil

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""

        self.totalOddTitleLabel.text = localized("total_odd")
        self.betAmountTitleLabel.text = localized("bet_amount")
        self.winningsTitleLabel.text = localized("return")

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.App.backgroundPrimary

        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.topStatusView.backgroundColor = .clear
        self.headerBaseView.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear
        
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomStackView.backgroundColor = .clear
        self.cashoutBaseView.backgroundColor = .clear

        self.cashoutButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)

       /* self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textSecondary
        self.totalOddTitleLabel.textColor = UIColor.App.textPrimary
        self.totalOddSubtitleLabel.textColor = UIColor.App.textPrimary
        self.betAmountTitleLabel.textColor = UIColor.App.textPrimary
        self.betAmountSubtitleLabel.textColor = UIColor.App.textPrimary
        self.winningsTitleLabel.textColor = UIColor.App.textPrimary
        self.winningsSubtitleLabel.textColor = UIColor.App.textPrimary*/
        
        self.cashoutButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.cashoutButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.cashoutButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.39), for: .disabled)

        self.cashoutButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.cashoutButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary.withAlphaComponent(0.7), for: .highlighted)

        self.cashoutButton.layer.cornerRadius = CornerRadius.button
        self.cashoutButton.layer.masksToBounds = true
        self.cashoutButton.backgroundColor = .clear

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

    func configureCashoutButton(withState state: MyTicketCellViewModel.CashoutButtonState) {
        if case .visible(let cashoutValue) = state {
            self.cashoutButton.setTitle(localized("cashout"), for: .normal)
            if let cashoutValueString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashoutValue)) {
                self.cashoutButton.setTitle(localized("cashout")+"  \(cashoutValueString)", for: .normal)
            }
            self.cashoutValue = cashoutValue
            self.showCashoutButton = true
        }
        else {
            self.showCashoutButton = false
        }
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry
        self.viewModel = viewModel

        if let state = self.viewModel?.hasCashoutEnabled.value {
            self.configureCashoutButton(withState: state)
        }

        self.cashoutSubscription = self.viewModel?.hasCashoutEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] cashoutButtonState in
                self?.configureCashoutButton(withState: cashoutButtonState)
            })

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
        if betHistoryEntry.type == "SINGLE" {
            self.titleLabel.text = localized("single")+" - \(betStatusText(forCode: betHistoryEntry.status?.uppercased() ?? "-"))"
        }
        else if betHistoryEntry.type == "MULTIPLE" {
            self.titleLabel.text = localized("multiple")+" - \(betStatusText(forCode: betHistoryEntry.status?.uppercased() ?? "-"))"
        }
        else if betHistoryEntry.type == "SYSTEM" {
            self.titleLabel.text = localized("system")+" - \(betHistoryEntry.systemBetType?.capitalized ?? "") - \(betStatusText(forCode: betHistoryEntry.status?.uppercased() ?? "-"))"
        }

        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketTableViewCell.dateFormatter.string(from: date)
        }

        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            let newOddValue = Double(floor(oddValue * 100)/100)
            self.totalOddSubtitleLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
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
                self.winningsTitleLabel.text = localized("return")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = .white
                self.totalOddSubtitleLabel.textColor = .white
                self.betAmountTitleLabel.textColor = .white
                self.betAmountSubtitleLabel.textColor = .white
                self.winningsTitleLabel.textColor = .white
                self.winningsSubtitleLabel.textColor = .white

            case "LOST", "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = .white
                self.totalOddSubtitleLabel.textColor = .white
                self.betAmountTitleLabel.textColor = .white
                self.betAmountSubtitleLabel.textColor = .white
                self.winningsTitleLabel.textColor = .white
                self.winningsSubtitleLabel.textColor = .white

            case "CASHED_OUT":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("return") // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }

            case "DRAW":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("return")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = .white
                self.totalOddSubtitleLabel.textColor = .white
                self.betAmountTitleLabel.textColor = .white
                self.betAmountSubtitleLabel.textColor = .white
                self.winningsTitleLabel.textColor = .white
                self.winningsSubtitleLabel.textColor = .white

            case "CANCELLED":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsSubtitleLabel.text = maxWinningsString
                }
                self.totalOddTitleLabel.textColor = .white
                self.totalOddSubtitleLabel.textColor = .white
                self.betAmountTitleLabel.textColor = .white
                self.betAmountSubtitleLabel.textColor = .white
                self.winningsTitleLabel.textColor = .white
                self.winningsSubtitleLabel.textColor = .white

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

    @IBAction func didTapShareButton() {
        let renderer = UIGraphicsImageRenderer(size: self.baseView.bounds.size)
        let image = renderer.image { _ in
            self.baseView.drawHierarchy(in: self.baseView.bounds, afterScreenUpdates: true)
        }
        self.snapshot = image

        self.tappedShareAction?()
    }

    @IBAction private func didTapCashoutButton() {

        guard
            let cashoutValue = self.cashoutValue,
            let cashoutValueString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashoutValue))
        else {
            return
        }

        let cashoutAlertMessage = "\(localized("return_money")) \(cashoutValueString)"

        let submitCashoutAlert = UIAlertController(title: localized("cashout_verification"),
                                                   message: cashoutAlertMessage,
                                                   preferredStyle: UIAlertController.Style.alert)
        submitCashoutAlert.addAction(UIAlertAction(title: localized("cashout"), style: .default, handler: { _ in
            self.viewModel?.requestCashout()
        }))

        submitCashoutAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.viewController?.present(submitCashoutAlert, animated: true, completion: nil)

    }

    private func resetHighlightedCard() {
        self.bottomBaseView.backgroundColor = .clear
        self.topStatusView.backgroundColor = .clear

        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
    }

    private func highlightCard(withColor color: UIColor) {
        self.bottomBaseView.backgroundColor = color
        self.topStatusView.backgroundColor = color

        self.bottomSeparatorLineView.backgroundColor = .white
    }

    private func betStatusText(forCode code: String) -> String {
        switch code {
        case "OPEN": return localized("open")
        case "DRAW": return localized("draw")
        case "WON": return localized("won")
        case "HALF_WON": return localized("half_won")
        case "LOST": return localized("lost")
        case "HALF_LOST": return localized("half_lost")
        case "CANCELLED": return localized("cancelled")
        case "CASHED_OUT": return localized("cashed_out")
        default: return ""
        }
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
