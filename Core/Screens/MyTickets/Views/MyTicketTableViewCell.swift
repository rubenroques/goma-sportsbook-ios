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
    @IBOutlet private weak var betIdLabel: UILabel!
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

    @IBOutlet private weak var cashbackInfoBaseView: UIView!
    @IBOutlet private weak var cashbackInfoView: CashbackInfoView!
    @IBOutlet private weak var cashbackValueLabel: UILabel!

    @IBOutlet private weak var cashoutBaseView: UIView!
    @IBOutlet private weak var cashoutButton: UIButton!
    @IBOutlet private weak var partialCashoutFilterButton: UIButton!

    @IBOutlet private weak var partialCashoutSliderView: UIView!
    @IBOutlet private weak var multiSliderInnerView: UIView!
    @IBOutlet private weak var partialCashoutButton: UIButton!

    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var freebetBaseView: UIView!
    @IBOutlet private weak var freebetLabel: UILabel!

    @IBOutlet private weak var partialAmountsView: UIView!
    @IBOutlet private weak var originalAmountValueLabel: UILabel!
    @IBOutlet private weak var returnedAmountValueLabel: UILabel!

    @IBOutlet private weak var cashbackIconImageView: UIImageView!
    @IBOutlet private weak var cashbackUsedBaseView: UIView!
    @IBOutlet private weak var cashbackUsedTitleLabel: UILabel!

    // Custom views
    lazy var learnMoreBaseView: CashbackLearnMoreView = {
        let view = CashbackLearnMoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // Constraints
//    @IBOutlet private weak var stackBottomToPartialConstraint: NSLayoutConstraint!
//    @IBOutlet private weak var stackBottomToContainerConstraint: NSLayoutConstraint!
//    @IBOutlet private weak var partialBottomToContainerConstraint: NSLayoutConstraint!

    private var betHistoryEntry: BetHistoryEntry?

    private var viewModel: MyTicketCellViewModel?

    private var isLoadingCellDataSubscription: AnyCancellable?

    private var cashoutSubscription: AnyCancellable?
    
    private var selectedMatch: String = ""

    private var cashoutValue: Double?

    private var cancellables = Set<AnyCancellable>()

    private var showCashoutButton: Bool = false {
        didSet {
            self.cashoutBaseView.isHidden = !showCashoutButton
            if showCashoutButton {
                self.needsHeightRedraw?(false)
            }
        }
    }

    private var showPartialCashoutSliderView: Bool = false {
        didSet {
//            if showPartialCashoutSliderView {
//                self.partialCashoutFilterButton.setImage(UIImage(named: "close_dark_icon"), for: .normal)
//                self.cashoutButton.isEnabled = false
//
//            }
//            else {
//                self.partialCashoutFilterButton.setImage(UIImage(named: "partial_cashout_slider_icon"), for: .normal)
//                self.cashoutButton.isEnabled = true
//            }

            self.partialCashoutSliderView.isHidden = !showPartialCashoutSliderView

            if showPartialCashoutSliderView {
                self.viewModel?.hasRedraw = true
                self.needsHeightRedraw?(false)

            }

        }
    }

    var hasPartialCashoutReturned: Bool = false {
        didSet {
            self.partialAmountsView.isHidden = !hasPartialCashoutReturned
        }
    }

    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback

        }
    }

    var usedCashback: Bool = false {
        didSet {
            self.cashbackUsedBaseView.isHidden = !usedCashback
            self.cashbackInfoBaseView.isHidden = !usedCashback
            self.cashbackValueLabel.isHidden = !usedCashback
        }
    }

    var snapshot: UIImage?

    var needsHeightRedraw: ((Bool) -> Void)?
    var tappedShareAction: (() -> Void)?
    var tappedMatchDetail: ((String) -> Void)?
    var shouldShowCashbackInfo: (() -> Void)?
    
    var selectedIdPublisher: CurrentValueSubject<String, Never> = .init("")

    var partialCashoutMultiSlider: MultiSlider?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
//        if Env.appSession.businessModulesManager.isSocialFeaturesEnabled {
//            self.shareButton.isHidden = false
//        }
//        else {
//            self.shareButton.isHidden = true
//        }
        self.shareButton.isHidden = false

        self.loadingView.isHidden = true

        self.cashoutBaseView.isHidden = true
        self.partialCashoutSliderView.isHidden = true

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 10
        
        self.baseView.layer.masksToBounds = true

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        self.betIdLabel.text = ""

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"

        self.freebetLabel.text = localized("Freebet")
        self.freebetLabel.font = AppFont.with(type: .bold, size: 9.0)

        self.freebetBaseView.clipsToBounds = true
        self.freebetBaseView.layer.masksToBounds = true

        self.freebetBaseView.isHidden = true

        self.partialCashoutFilterButton.setTitle("", for: .normal)
        self.partialCashoutFilterButton.setImage(UIImage(named: "partial_cashout_slider_icon"), for: .normal)
        self.partialCashoutFilterButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.partialCashoutFilterButton.contentMode = .scaleAspectFit

        self.originalAmountValueLabel.text = "\(localized("original"))\n€1.00"

        self.returnedAmountValueLabel.text = "\(localized("returned"))\n€0.10"

        self.cashbackUsedTitleLabel.text = localized("used_cashback").uppercased()
        self.cashbackUsedTitleLabel.font = AppFont.with(type: .bold, size: 9)

        self.hasPartialCashoutReturned = false

        self.hasCashback = false

        self.usedCashback = false

        self.cashbackInfoView.didTapInfoAction = { [weak self] in
            print("TAPPED INFO CASHBACK")

            UIView.animate(withDuration: 0.5, animations: {
                self?.learnMoreBaseView.alpha = 1
            }) { (completed) in
                if completed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        UIView.animate(withDuration: 0.5) {
                            self?.learnMoreBaseView.alpha = 0
                        }
                    }
                }
            }
        }

        self.baseView.addSubview(self.learnMoreBaseView)

        NSLayoutConstraint.activate([

            self.learnMoreBaseView.bottomAnchor.constraint(equalTo: self.cashbackInfoView.topAnchor, constant: -10),
            self.learnMoreBaseView.trailingAnchor.constraint(equalTo: self.cashbackInfoView.trailingAnchor, constant: 10)

        ])

        self.learnMoreBaseView.didTapLearnMoreAction = { [weak self] in

            self?.shouldShowCashbackInfo?()
        }

        self.learnMoreBaseView.alpha = 0

        self.setupWithTheme()

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.loadingView.isHidden = true
        self.freebetBaseView.isHidden = true

        self.betHistoryEntry = nil
        self.viewModel = nil

        self.cashoutValue = nil
        // self.showCashoutButton = false
        // self.showPartialCashoutSliderView = false

        self.cashoutSubscription?.cancel()
        self.cashoutSubscription = nil

        self.isLoadingCellDataSubscription?.cancel()
        self.isLoadingCellDataSubscription = nil

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        self.betIdLabel.text = ""

        self.totalOddTitleLabel.text = localized("total_odd")
        self.betAmountTitleLabel.text = localized("bet_amount")
        self.winningsTitleLabel.text = localized("return_text")

        self.totalOddSubtitleLabel.text = "-"
        self.betAmountSubtitleLabel.text = "-"
        self.winningsSubtitleLabel.text = "-"

        self.hasPartialCashoutReturned = false

        self.hasCashback = false

        self.usedCashback = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.freebetBaseView.layer.cornerRadius = self.freebetBaseView.frame.height / 2

        self.cashbackUsedBaseView.layer.cornerRadius = CornerRadius.status
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

        self.subtitleLabel.textColor = UIColor.App.textSecondary

        self.betIdLabel.textColor = UIColor.App.textSecondary
        
        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomStackView.backgroundColor = .clear
        self.cashoutBaseView.backgroundColor = .clear
        
        self.cashoutButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.cashoutButton.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.cashoutButton.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.39), for: .disabled)

        self.cashoutButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.cashoutButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary.withAlphaComponent(0.7), for: .highlighted)

        self.cashoutButton.layer.cornerRadius = CornerRadius.button
        self.cashoutButton.layer.masksToBounds = true
        self.cashoutButton.backgroundColor = .clear

        self.partialCashoutFilterButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.partialCashoutFilterButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary.withAlphaComponent(0.7), for: .highlighted)

        self.partialCashoutFilterButton.layer.cornerRadius = CornerRadius.button
        self.partialCashoutFilterButton.layer.masksToBounds = true
        self.partialCashoutFilterButton.backgroundColor = .clear

        self.freebetBaseView.backgroundColor = UIColor.App.myTicketsOther

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

        self.partialCashoutSliderView.backgroundColor = UIColor.App.backgroundPrimary
        self.partialCashoutSliderView.layer.cornerRadius = CornerRadius.view
        self.partialCashoutSliderView.layer.masksToBounds = true

        self.multiSliderInnerView.backgroundColor = .clear

        self.partialAmountsView.backgroundColor = .clear

        self.originalAmountValueLabel.textColor = UIColor.App.textSecondary

        self.returnedAmountValueLabel.textColor = UIColor.App.textSecondary

        self.partialCashoutButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.partialCashoutButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.partialCashoutButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.39), for: .disabled)

        self.partialCashoutButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.partialCashoutButton.setBackgroundColor(UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.partialCashoutButton.layer.cornerRadius = CornerRadius.button
        self.partialCashoutButton.layer.masksToBounds = true
        self.partialCashoutButton.backgroundColor = .clear

        self.cashbackIconImageView.backgroundColor = .clear

        self.cashbackValueLabel.textColor = UIColor.App.textPrimary

        self.cashbackUsedBaseView.backgroundColor = UIColor.App.highlightSecondary

        self.cashbackUsedTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func configureCashoutButton(withState state: MyTicketCellViewModel.CashoutButtonState) {
        if case .visible(let cashoutValue) = state {
//            self.cashoutButton.setTitle(localized("cashout"), for: .normal)
//            if let cashoutValueString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashoutValue)) {
//                self.cashoutButton.setTitle(localized("cashout")+"  \(cashoutValueString)", for: .normal)
//            }
            self.cashoutValue = cashoutValue

//            self.showCashoutButton = true
            self.showPartialCashoutSliderView = true
        }
        else {
//            self.showCashoutButton = false
            self.showPartialCashoutSliderView = false

        }
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry
        self.viewModel = viewModel

        if betHistoryEntry.freeBet ?? false {
            self.freebetBaseView.isHidden = false
        }
        else {
            self.freebetBaseView.isHidden = true
        }

        self.viewModel?.hasCashoutEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] cashoutButtonState in

                if !viewModel.hasRedraw {
                    self?.setupPartialCashoutSlider()
                    self?.configureCashoutButton(withState: cashoutButtonState)
                }
            })
            .store(in: &cancellables)

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
            self.titleLabel.text = localized("single")+" - \(betHistoryEntry.localizedBetStatus)"
        }
        else if betHistoryEntry.type?.lowercased() == "multiple" {
            self.titleLabel.text = localized("multiple")+" - \(betHistoryEntry.localizedBetStatus)"
        }
        else if betHistoryEntry.type?.lowercased() == "system" {
            self.titleLabel.text = localized("system")+" - \(betHistoryEntry.systemBetType?.capitalized ?? "") - \(betHistoryEntry.localizedBetStatus)"
        }
        else {
            self.titleLabel.text = String([betHistoryEntry.type, betHistoryEntry.localizedBetStatus]
                .compactMap({ $0 })
                .map({ $0.capitalized })
                .joined(separator: " - "))
        }

        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketTableViewCell.dateFormatter.string(from: date)
        }

        // Strange ID with .10 instead of .1
        if let betIdDouble = Double(betHistoryEntry.betId) {
            let betId = String(format: "%.1f", betIdDouble)
            self.betIdLabel.text = "\(localized("bet_id")): \(betId)"
        }
        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            // let newOddValue = Double(floor(oddValue * 100)/100)
//            self.totalOddSubtitleLabel.text = oddValue == 0.0 ? "-" : OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.buttonTextPrimary

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
                self.cashbackValueLabel.textColor = UIColor.App.textPrimary

            default:
                self.resetHighlightedCard()
            }
        }

        if betHistoryEntry.status?.uppercased() == "OPENED",
           let partialCashoutStake = betHistoryEntry.partialCashoutStake,
           let partialCashoutReturn = betHistoryEntry.partialCashoutReturn,
        partialCashoutStake > 0 && partialCashoutReturn > 0 {

            // Original amount
            let originalBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betHistoryEntry.totalBetAmount ?? 0.0))
            self.originalAmountValueLabel.text = "\(localized("original"))\n\(originalBetAmountString ?? "")"

            // New bet amount
            let newBetAmount = (betHistoryEntry.totalBetAmount ?? 0.0) - partialCashoutStake
            let totalNewBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: newBetAmount))
            self.betAmountSubtitleLabel.text = totalNewBetAmountString

            // New Possible Winnings
            let newMaxWinnings = newBetAmount*(betHistoryEntry.maxWinning ?? 0.0)
            let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: newMaxWinnings))
            self.winningsSubtitleLabel.text = maxWinningsString

            // Returned Amount
            let returnedBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: partialCashoutReturn))
            self.returnedAmountValueLabel.text = "\(localized("returned"))\n\(returnedBetAmountString ?? "")"

            self.hasPartialCashoutReturned = true

        }
        else {
            self.hasPartialCashoutReturned = false
        }

        // Cashback
        if betHistoryEntry.status?.uppercased() == "OPENED" {
            self.hasCashback = false
            self.usedCashback = false
        }
        else if let cashbackReturn = betHistoryEntry.cashbackReturn {
            self.hasCashback = false
            self.usedCashback = true

            let cashbackReturnString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackReturn))

            self.cashbackValueLabel.text = cashbackReturnString
        }

        self.viewModel?.partialCashout
            .sink(receiveValue: { [weak self] partialCashout in

                if let partialCashout,
                   let partialCashoutValue = partialCashout.value {

                    let partialCashoutLabel = localized("cashout_value").replacingFirstOccurrence(of: "{cashoutAmount}", with: "\(partialCashoutValue)")
                    self?.partialCashoutButton.setTitle("\(partialCashoutLabel)€", for: .normal)
                    self?.partialCashoutButton.isEnabled = true
                }
                else {
                    self?.partialCashoutButton.isEnabled = false
                }
            })
            .store(in: &cancellables)

        //self.viewModel?.requestCashoutAvailability()

    }

    func setupPartialCashoutSlider() {
        guard let cashout = self.viewModel?.cashout,
        let ticket = self.viewModel?.ticket
        else {
            return

        }

        let cashoutValue = cashout.value ?? 0.0
        let cashoutStake = cashout.stake ?? 0.0

        var maxSliderStake = cashoutStake

        if let partialCashoutStake = ticket.partialCashoutStake,
           let totalStake = ticket.totalBetAmount,
           partialCashoutStake > 0 {
            maxSliderStake = totalStake - partialCashoutStake
        }

        let minCashout = maxSliderStake/10
        let minValue: CGFloat = minCashout
        let maxValue: CGFloat = maxSliderStake
        let values: [CGFloat] = [minValue, maxValue]
        
        self.partialCashoutMultiSlider = MultiSlider()
        partialCashoutMultiSlider?.backgroundColor = .clear
        partialCashoutMultiSlider?.orientation = .horizontal
        partialCashoutMultiSlider?.minimumValue = minValue
        partialCashoutMultiSlider?.maximumValue = maxValue
        partialCashoutMultiSlider?.value = values
        partialCashoutMultiSlider?.outerTrackColor = UIColor.App.separatorLine
        partialCashoutMultiSlider?.snapStepSize = minCashout
        partialCashoutMultiSlider?.thumbImage = UIImage(named: "slider_thumb_orange_icon")
        partialCashoutMultiSlider?.tintColor = UIColor.App.highlightPrimary
        partialCashoutMultiSlider?.trackWidth = 6
        partialCashoutMultiSlider?.showsThumbImageShadow = false
        partialCashoutMultiSlider?.keepsDistanceBetweenThumbs = false
        partialCashoutMultiSlider?.addTarget(self, action: #selector(partialSliderChanged), for: .touchUpInside)
        partialCashoutMultiSlider?.valueLabelPosition = .bottom
        partialCashoutMultiSlider?.valueLabelColor = UIColor.App.textPrimary
        partialCashoutMultiSlider?.valueLabelFont = AppFont.with(type: .bold, size: 14)
        partialCashoutMultiSlider?.extraLabelInfoSingular = localized("€")
        partialCashoutMultiSlider?.extraLabelInfoPlural = localized("€")
        partialCashoutMultiSlider?.thumbCount = 1
        partialCashoutMultiSlider?.value[0] = maxValue/2

        if let partialCashoutMultiSlider = partialCashoutMultiSlider {

            for view in self.multiSliderInnerView.subviews {
                view.removeFromSuperview()
            }

            self.multiSliderInnerView.addConstrainedSubview(partialCashoutMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
            self.multiSliderInnerView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }

        self.partialCashoutButton.isEnabled = false
        self.viewModel?.requestPartialCashoutAvailability(ticket: ticket, stakeValue: "\(maxSliderStake/2)")

        self.viewModel?.partialCashoutSliderValue = Double(maxSliderStake/2)

//        let partialCashoutLabel = localized("partial_cashout_value").replacingFirstOccurrence(of: "{cashoutAmount}", with: "\(maxValue)")
//        self.partialCashoutButton.setTitle("\(partialCashoutLabel)€", for: .normal)
    }

    @objc func partialSliderChanged(_ slider: MultiSlider) {
        let partialCashoutValue = slider.value[0]
        print("PARTIAL CASHOUT VALUE: \(partialCashoutValue)")

        self.viewModel?.partialCashoutSliderValue = Double(partialCashoutValue)

        if let betTicket = self.viewModel?.ticket {
            self.partialCashoutButton.isEnabled = false
            self.viewModel?.requestPartialCashoutAvailability(ticket: betTicket, stakeValue: "\(partialCashoutValue)")
        }
//        let partialCashoutLabel = localized("partial_cashout_value").replacingFirstOccurrence(of: "{cashoutAmount}", with: "\(partialCashoutValue)")
//        self.partialCashoutButton.setTitle("\(partialCashoutLabel)€", for: .normal)
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

        let titleMessage = localized("cashout_confirmation").replacingOccurrences(of: "{amount}", with: cashoutValueString)

        let submitCashoutAlert = UIAlertController(title: titleMessage,
                                                   message: cashoutAlertMessage,
                                                   preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: localized("cashout"), style: .default, handler: { _ in
            self.viewModel?.requestCashout()
        })

        okAction.setValue(UIColor.App.highlightPrimary, forKey: "titleTextColor")

        submitCashoutAlert.addAction(okAction)

        submitCashoutAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.viewController?.present(submitCashoutAlert, animated: true, completion: nil)
    }

    @IBAction private func didTapPartialCashoutFilterButton() {

        self.showPartialCashoutSliderView = !self.showPartialCashoutSliderView

    }

    @IBAction private func didTapPartialCashoutButton() {

        guard
            let partialCashoutValue = self.viewModel?.partialCashout.value?.value,
            let cashoutValueString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: partialCashoutValue))
        else {
            return
        }

        let cashoutAlertMessage = "\(localized("return_money")) \(cashoutValueString)"

        let titleMessage = localized("cashout_confirmation").replacingOccurrences(of: "{amount}", with: cashoutValueString)

        let submitCashoutAlert = UIAlertController(title: titleMessage,
                                                   message: cashoutAlertMessage,
                                                   preferredStyle: UIAlertController.Style.alert)
        submitCashoutAlert.addAction(UIAlertAction(title: localized("cashout"), style: .default, handler: { _ in
            self.viewModel?.requestPartialCashout()
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

}

extension MyTicketTableViewCell {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
}
