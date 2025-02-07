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
    private lazy var cashbackInfoView: CashbackInfoView = {
        let view = CashbackInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBOutlet private weak var cashbackValueLabel: UILabel!

    @IBOutlet private weak var cashoutBaseView: UIView!
    @IBOutlet private weak var cashoutButton: UIButton!

    @IBOutlet private weak var partialCashoutSliderView: UIView!
    @IBOutlet private weak var multiSliderInnerView: UIView!
    @IBOutlet private weak var partialCashoutButton: UIButton!
    @IBOutlet private weak var partialCashoutDisableView: UIView!

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

    @IBOutlet private weak var minimumCashoutValueLabel: UILabel!
    @IBOutlet private weak var maximumCashoutValueLabel: UILabel!
    
    @IBOutlet private weak var multisliderZeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var multisliderNormalHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var partialCashoutButtonTopSliderConstraint: NSLayoutConstraint!
    @IBOutlet private weak var partialCashoutButtonTopViewConstraint: NSLayoutConstraint!
    
    // Custom views
    lazy var learnMoreBaseView: CashbackLearnMoreView = {
        let view = CashbackLearnMoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        }
    }

    var showPartialCashoutSliderView: Bool = true {
        didSet {
            self.partialCashoutSliderView.isHidden = !showPartialCashoutSliderView
            
            let partialCashoutEnabled = Env.businessSettingsSocket.clientSettings.partialCashoutEnabled
            
            self.partialCashoutMultiSlider?.isHidden = !partialCashoutEnabled
            self.maximumCashoutValueLabel.isHidden = !partialCashoutEnabled
            self.minimumCashoutValueLabel.isHidden = !partialCashoutEnabled
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
            self.cashbackInfoBaseView.isHidden = !hasCashback
            self.cashbackValueLabel.isHidden = !hasCashback
        }
    }

    var usedCashback: Bool = false {
        didSet {
            self.cashbackUsedBaseView.isHidden = !usedCashback
        }
    }

    var isPartialCashoutDisabled: Bool = false {
        didSet {
            self.partialCashoutDisableView.isHidden = !isPartialCashoutDisabled
            self.partialCashoutSliderView.isUserInteractionEnabled = !isPartialCashoutDisabled
        }
    }

    var needsHeightRedraw: ((Bool) -> Void)?
    var tappedShareAction: ((UIImage, BetHistoryEntry) -> Void) = { _, _ in }
    var tappedMatchDetail: ((String) -> Void)?
    var shouldShowCashbackInfo: (() -> Void)?
    var needsDataUpdate: (() -> Void)?
    
    var partialCashoutMultiSlider: MultiSlider?

    deinit {
        print("MyTicketTableViewCell.deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
//        if Env.appSession.businessModulesManager.isSocialFeaturesEnabled {
//            self.shareButton.isHidden = false
//        }
//        else {
//            self.shareButton.isHidden = true
//        }

            
        // Setup fonts
        self.titleLabel.font = AppFont.with(type: .heavy, size: 16)
        self.subtitleLabel.font = AppFont.with(type: .bold, size: 10)
        self.freebetLabel.font = AppFont.with(type: .bold, size: 10)
        self.betIdLabel.font = AppFont.with(type: .bold, size: 10)
        
        self.totalOddTitleLabel.font = AppFont.with(type: .bold, size: 12)
        self.betAmountTitleLabel.font = AppFont.with(type: .bold, size: 12)
        self.winningsTitleLabel.font = AppFont.with(type: .bold, size: 12)
        
        self.totalOddSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
        self.betAmountSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
        self.cashbackValueLabel.font = AppFont.with(type: .bold, size: 16)
        self.winningsSubtitleLabel.font = AppFont.with(type: .bold, size: 16)
        
        self.originalAmountValueLabel.font = AppFont.with(type: .bold, size: 9)
        self.returnedAmountValueLabel.font = AppFont.with(type: .bold, size: 9)
        
        self.minimumCashoutValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.maximumCashoutValueLabel.font = AppFont.with(type: .bold, size: 12)
        
        self.cashbackInfoBaseView.addSubview(self.cashbackInfoView)
        NSLayoutConstraint.activate([
            self.cashbackInfoView.centerXAnchor.constraint(equalTo: self.cashbackInfoBaseView.centerXAnchor),
            self.cashbackInfoView.centerYAnchor.constraint(equalTo: self.cashbackInfoBaseView.centerYAnchor),
        ])
        
        //
        self.shareButton.isHidden = false

        self.loadingView.isHidden = true

        self.cashoutBaseView.isHidden = true
        self.partialCashoutSliderView.isHidden = false
        self.partialCashoutDisableView.isHidden = true

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = 10
        
        self.baseView.layer.masksToBounds = true

        self.titleLabel.text = ""
        self.subtitleLabel.text = ""
        self.betIdLabel.text = ""
        
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
        
        self.cashbackValueLabel.font = AppFont.with(type: .semibold, size: 16)

        self.freebetLabel.text = localized("Freebet")
        self.freebetLabel.font = AppFont.with(type: .bold, size: 9.0)

        self.freebetBaseView.clipsToBounds = true
        self.freebetBaseView.layer.masksToBounds = true

        self.freebetBaseView.isHidden = true

        self.originalAmountValueLabel.text = "\(localized("original")) "

        self.returnedAmountValueLabel.text = "\(localized("returned")) "

        self.cashbackUsedTitleLabel.text = localized("used_cashback").uppercased()
        self.cashbackUsedTitleLabel.font = AppFont.with(type: .bold, size: 9)

        self.hasPartialCashoutReturned = false

        self.hasCashback = false

        self.usedCashback = false

        self.cashbackInfoView.didTapInfoAction = { [weak self] in
//            UIView.animate(withDuration: 0.5, animations: { [weak self] in
//                self?.learnMoreBaseView.alpha = 1
//            }, completion: { [weak self] completed in
//                if completed {
//                    UIView.animate(withDuration: 0.5, delay: 5.0, animations: {
//                        self?.learnMoreBaseView.alpha = 0
//                    })
//                }
//            })
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self?.learnMoreBaseView.alpha = 1
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                    self?.learnMoreBaseView.alpha = 0
                })
            }
        }

        self.baseView.addSubview(self.learnMoreBaseView)

        NSLayoutConstraint.activate([
            self.learnMoreBaseView.bottomAnchor.constraint(equalTo: self.cashbackInfoBaseView.topAnchor, constant: -10),
            self.learnMoreBaseView.trailingAnchor.constraint(equalTo: self.cashbackInfoBaseView.trailingAnchor, constant: 10),
            self.learnMoreBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 10)
        ])

        self.learnMoreBaseView.didTapLearnMoreAction = { [weak self] in
            self?.shouldShowCashbackInfo?()
        }

        self.learnMoreBaseView.alpha = 0
        
        let partialCashoutEnabled = Env.businessSettingsSocket.clientSettings.partialCashoutEnabled
        
        self.multisliderZeroHeightConstraint.isActive = !partialCashoutEnabled
        self.multisliderNormalHeightConstraint.isActive = partialCashoutEnabled
        
        self.partialCashoutButtonTopViewConstraint.isActive = !partialCashoutEnabled
        self.partialCashoutButtonTopSliderConstraint.isActive = partialCashoutEnabled

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.loadingView.isHidden = true
        self.freebetBaseView.isHidden = true

        self.betHistoryEntry = nil
        self.viewModel = nil

        self.cashoutValue = nil
        self.showCashoutButton = false
        self.showPartialCashoutSliderView = true

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

        self.minimumCashoutValueLabel.text = ""
        self.maximumCashoutValueLabel.text = ""
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

        self.cashoutButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.cashoutButton.setBackgroundColor(UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.cashoutButton.layer.cornerRadius = CornerRadius.button
        self.cashoutButton.layer.masksToBounds = true
        self.cashoutButton.backgroundColor = .clear

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

        self.partialCashoutDisableView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
        self.partialCashoutDisableView.layer.cornerRadius = CornerRadius.view
        self.partialCashoutDisableView.layer.masksToBounds = true

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
            self.cashoutValue = cashoutValue

            self.showPartialCashoutSliderView = true
            self.isPartialCashoutDisabled = false
        }
        else {
            if self.viewModel?.ticket.status?.uppercased() == "OPENED" {
                self.showPartialCashoutSliderView = true
                let partialCashoutLabel = localized("cashout_value").replacingFirstOccurrence(of: "{cashoutAmount}", with: localized("unavailable"))
                self.partialCashoutButton.setTitle("\(partialCashoutLabel)", for: .normal)
                self.isPartialCashoutDisabled = true
            }
            else {
                self.showPartialCashoutSliderView = false
            }
        }
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry
        self.viewModel = viewModel

        if TargetVariables.hasFeatureEnabled(feature: .freebets) {
            if betHistoryEntry.freeBet ?? false {
                self.freebetBaseView.isHidden = false
            }
            else {
                self.freebetBaseView.isHidden = true

            }
        }
        else if TargetVariables.hasFeatureEnabled(feature: .cashback) {
            if betHistoryEntry.freeBet ?? false {
                self.usedCashback = true
            }
            else {
                self.usedCashback = false
            }
        }
        else {
            if betHistoryEntry.freeBet ?? false {
                self.freebetBaseView.isHidden = false
            }
            else {
                self.freebetBaseView.isHidden = true

            }
        }

        self.viewModel?.hasCashoutEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] cashoutButtonState in
                self?.setupPartialCashoutSlider()
                self?.configureCashoutButton(withState: cashoutButtonState)
            })
            .store(in: &self.cancellables)

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
            self.subtitleLabel.text = MyTicketTableViewCell.dateFormatter.string(from: date)
        }

        // Strange ID with .10 instead of .1
        if let betIdDouble = Double(betHistoryEntry.betId) {
            let betId = String(format: "%.1f", betIdDouble)
            self.betIdLabel.text = "\(localized("bet_id")): \(betId)"
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
            self.originalAmountValueLabel.text = "\(localized("original")):\n \(originalBetAmountString ?? "")"

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
            self.returnedAmountValueLabel.text = "\(localized("returned")):\n \(returnedBetAmountString ?? "")"

            self.hasPartialCashoutReturned = true

        }
        else {
            self.hasPartialCashoutReturned = false
        }

        // Cashback
        if betHistoryEntry.status?.uppercased() == "OPENED" {
            self.hasCashback = false

            if TargetVariables.hasFeatureEnabled(feature: .cashback) {
                if betHistoryEntry.freeBet ?? false {
                    self.usedCashback = true
                }
                else {
                    self.usedCashback = false
                }
            }
            else {
                self.usedCashback = false
            }
            
            var cashbackReturn = 0.0
            
            if let potentialCashbackReturn = betHistoryEntry.potentialCashbackReturn, potentialCashbackReturn > 0 {
                cashbackReturn = potentialCashbackReturn
            }
            else if let potentialFreebetReturn = betHistoryEntry.potentialFreebetReturn, potentialFreebetReturn != 0 {
                cashbackReturn = potentialFreebetReturn
            }
            
            if cashbackReturn > 0 {
                self.hasCashback = true
                let potentialCashbackReturnString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackReturn))
                self.cashbackValueLabel.text = potentialCashbackReturnString
            }
        }
        else if let cashbackReturn = betHistoryEntry.cashbackReturn != nil ? betHistoryEntry.cashbackReturn : betHistoryEntry.freebetReturn,
                cashbackReturn > 0 {
            self.hasCashback = true
            self.usedCashback = false

            let cashbackReturnString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackReturn))

            self.cashbackValueLabel.text = cashbackReturnString
        }
        else if let freebetReturn = betHistoryEntry.freebetReturn,
                freebetReturn > 0 {

            self.hasCashback = true
            self.usedCashback = false

            let cashbackReturnString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freebetReturn))
            self.cashbackValueLabel.text = cashbackReturnString
        }

        self.viewModel?.partialCashout
            .receive(on: DispatchQueue.main)
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
            .store(in: &self.cancellables)

    }

    func setupPartialCashoutSlider() {
        guard let ticket = self.viewModel?.ticket
        else {
            return
        }

        let cashout = self.viewModel?.cashout

        let cashoutValue = cashout?.value ?? 0.0
        let cashoutStake = cashout?.stake ?? (ticket.totalBetAmount ?? 0.0)

        var maxSliderStake = cashoutStake

        if let partialCashoutStake = ticket.partialCashoutStake,
           let totalStake = ticket.totalBetAmount,
           partialCashoutStake > 0 {
            maxSliderStake = totalStake - partialCashoutStake
        }

        var minCashoutStep = 0.01
        
        var minValue: CGFloat = minCashoutStep
        var maxValue: CGFloat = maxSliderStake
        var middleValue: CGFloat = maxValue/2 // Default slider place
        
        var values: [CGFloat] = [minValue, maxValue]

        //Minimum and maximum labels
        self.minimumCashoutValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: minCashoutStep)) ?? ""

        self.maximumCashoutValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxSliderStake)) ?? ""

        self.partialCashoutMultiSlider = MultiSlider()
        partialCashoutMultiSlider?.backgroundColor = .clear
        partialCashoutMultiSlider?.orientation = .horizontal
        partialCashoutMultiSlider?.minimumValue = minValue
        partialCashoutMultiSlider?.maximumValue = maxValue
        partialCashoutMultiSlider?.value = values
        partialCashoutMultiSlider?.outerTrackColor = UIColor.App.separatorLine
        partialCashoutMultiSlider?.snapStepSize = minCashoutStep
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
        partialCashoutMultiSlider?.value[0] = middleValue

        if let partialCashoutMultiSlider = partialCashoutMultiSlider {

            for view in self.multiSliderInnerView.subviews {
                view.removeFromSuperview()
            }

            self.multiSliderInnerView.addConstrainedSubview(partialCashoutMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin, .topMargin)
            self.multiSliderInnerView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }

        self.partialCashoutButton.isEnabled = false
        
        if Env.businessSettingsSocket.clientSettings.partialCashoutEnabled {
            self.viewModel?.requestPartialCashoutAvailability(ticket: ticket, stakeValue: "\(maxSliderStake/2)")
            
            self.viewModel?.partialCashoutSliderValue = Double(maxSliderStake/2)
        }
        else {
            self.viewModel?.requestPartialCashoutAvailability(ticket: ticket, stakeValue: "\(maxSliderStake)")
            
            self.viewModel?.partialCashoutSliderValue = Double(maxSliderStake)
        }
    }

    @objc func partialSliderChanged(_ slider: MultiSlider) {
        let partialCashoutValue = slider.value[0]
        print("PARTIAL CASHOUT VALUE: \(partialCashoutValue)")

        self.viewModel?.partialCashoutSliderValue = Double(partialCashoutValue)

        if let betTicket = self.viewModel?.ticket {
            self.partialCashoutButton.isEnabled = false
            self.viewModel?.requestPartialCashoutAvailability(ticket: betTicket, stakeValue: "\(partialCashoutValue)")
        }
    }

    @IBAction func didTapShareButton() {
        let renderer = UIGraphicsImageRenderer(size: self.baseView.bounds.size)
        let image = renderer.image { _ in
            self.baseView.drawHierarchy(in: self.baseView.bounds, afterScreenUpdates: true)
        }

        if let betHistoryEntry = self.betHistoryEntry {
            self.tappedShareAction(image, betHistoryEntry)
        }
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
        let okAction = UIAlertAction(title: localized("cashout"), style: .default, handler: { [weak self] _ in
            self?.viewModel?.requestCashout()
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
        submitCashoutAlert.addAction(UIAlertAction(title: localized("cashout"), style: .default, handler: { [weak self] _ in
            self?.viewModel?.requestPartialCashout()
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
