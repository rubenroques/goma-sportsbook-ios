//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit
import Combine

class OddDoubleCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var participantsNameLabel: UILabel!
    @IBOutlet private weak var participantsCountryImageView: UIImageView!

    @IBOutlet private weak var marketStatsStackView: UIStackView!
    @IBOutlet private weak var marketNameLabel: UILabel!

    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var leftBaseView: UIView!
    @IBOutlet private weak var leftOddTitleLabel: UILabel!
    @IBOutlet private weak var leftOddValueLabel: UILabel!

    @IBOutlet private weak var rightBaseView: UIView!
    @IBOutlet private weak var rightOddTitleLabel: UILabel!
    @IBOutlet private weak var rightOddValueLabel: UILabel!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    @IBOutlet private weak var leftUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var leftDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var rightUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var rightDownChangeOddValueImage: UIImageView!

    @IBOutlet private weak var statsBaseView: UIView!
    @IBOutlet private weak var iconStatsImageView: UIImageView!
    @IBOutlet private weak var homeCircleCaptionView: UIView!
    @IBOutlet private weak var homeNameCaptionLabel: UILabel!
    @IBOutlet private weak var awayCircleCaptionView: UIView!
    @IBOutlet private weak var awayNameCaptionLabel: UILabel!

    //
    // Design Constraints
    @IBOutlet private weak var topMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingMarginSpaceConstraint: NSLayoutConstraint!

    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsHeightConstraint: NSLayoutConstraint!

    private var cachedCardsStyle: CardsStyle?
    //

    var matchStatsViewModel: MatchStatsViewModel?

    var match: Match?
    var market: Market?
    var store: AggregatorStore?

    private var leftOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var matchStatsSubscriber: AnyCancellable?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var marketSubscriber: AnyCancellable?

    private var currentLeftOddValue: Double?
    private var currentRightOddValue: Double?

    private var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }
    private var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }

    var tappedMatchWidgetAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.bringSubviewToFront(self.suspendedBaseView)

        self.statsBaseView.isHidden = true

        self.homeCircleCaptionView.layer.masksToBounds = true
        self.awayCircleCaptionView.layer.masksToBounds = true

        self.baseView.layer.cornerRadius = 9

        self.oddsStackView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.leftBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5

        self.participantsNameLabel.text = ""
        self.marketNameLabel.text = ""

        self.leftOddValueLabel.text = "-"
        self.rightOddValueLabel.text = "-"

        self.suspendedBaseView.isHidden = true

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.leftBaseView.addGestureRecognizer(tapLeftOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.rightBaseView.addGestureRecognizer(tapRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = 9

        self.homeCircleCaptionView.layer.cornerRadius = self.homeCircleCaptionView.frame.size.width / 2
        self.awayCircleCaptionView.layer.cornerRadius = self.awayCircleCaptionView.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        let stackSubviews = self.marketStatsStackView.arrangedSubviews
        stackSubviews.forEach({
            if $0 != self.marketNameLabel {
                self.marketStatsStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        })

        self.matchStatsViewModel = nil
        self.match = nil
        self.market = nil
        self.store = nil

        self.leftOutcome = nil
        self.rightOutcome = nil

        self.isLeftOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.statsBaseView.isHidden = true
        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""

        self.marketNameLabel.text = ""
        self.participantsNameLabel.text = ""
        self.leftOddTitleLabel.text = ""
        self.leftOddValueLabel.text = ""
        self.rightOddTitleLabel.text = ""
        self.rightOddValueLabel.text = ""

        self.leftBaseView.isUserInteractionEnabled = true
        self.rightBaseView.isUserInteractionEnabled = true

        self.leftBaseView.alpha = 1.0
        self.rightBaseView.alpha = 1.0

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil
        self.matchStatsSubscriber?.cancel()
        self.matchStatsSubscriber = nil

        self.currentLeftOddValue = nil
        self.currentRightOddValue = nil

        self.suspendedBaseView.isHidden = true

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.marketNameLabel.font = AppFont.with(type: .bold, size: 13)
        case .normal:
            self.marketNameLabel.font = AppFont.with(type: .bold, size: 14)
        }

        self.adjustDesignToCardStyle()
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.participantsNameLabel.textColor = UIColor.App.textPrimary
        self.marketNameLabel.textColor = UIColor.App.textPrimary

        self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.suspendedBaseView.backgroundColor = UIColor.App.backgroundDisabledOdds
        self.suspendedLabel.textColor = UIColor.App.textDisablePrimary

        self.statsBaseView.backgroundColor = UIColor.App.backgroundCards

        self.homeNameCaptionLabel.textColor = UIColor.App.textPrimary
        self.awayNameCaptionLabel.textColor = UIColor.App.textPrimary

        self.homeCircleCaptionView.backgroundColor = UIColor.App.statsHome
        self.awayCircleCaptionView.backgroundColor = UIColor.App.statsAway

        if isLeftOutcomeButtonSelected {
            self.leftBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.leftOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.leftOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.leftOddTitleLabel.textColor = UIColor.App.textPrimary
            self.leftOddValueLabel.textColor = UIColor.App.textPrimary
        }

        if isRightOutcomeButtonSelected {
            self.rightBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.rightOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.rightOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.rightOddTitleLabel.textColor = UIColor.App.textPrimary
            self.rightOddValueLabel.textColor = UIColor.App.textPrimary
        }
    }

    private func adjustDesignToCardStyle() {

        if self.cachedCardsStyle == StyleHelper.cardsStyleActive() {
            return
        }

        self.cachedCardsStyle = StyleHelper.cardsStyleActive()

        switch StyleHelper.cardsStyleActive() {
        case .small:
            self.adjustDesignToSmallCardStyle()
        case .normal:
            self.adjustDesignToNormalCardStyle()
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func adjustDesignToSmallCardStyle() {
        self.topMarginSpaceConstraint.constant = 8
        self.leadingMarginSpaceConstraint.constant = 8
        self.trailingMarginSpaceConstraint.constant = 8
        self.bottomMarginSpaceConstraint.constant = 8

        self.headerHeightConstraint.constant = 12
        self.buttonsHeightConstraint.constant = 27

        self.marketNameLabel.font = AppFont.with(type: .bold, size: 13)
        self.leftOddValueLabel.font = AppFont.with(type: .bold, size: 12)
        self.rightOddValueLabel.font = AppFont.with(type: .bold, size: 12)
    }

    private func adjustDesignToNormalCardStyle() {
        self.topMarginSpaceConstraint.constant = 11
        self.bottomMarginSpaceConstraint.constant = 12
        self.leadingMarginSpaceConstraint.constant = 12
        self.trailingMarginSpaceConstraint.constant = 12

        self.headerHeightConstraint.constant = 17
        self.buttonsHeightConstraint.constant = 40

        self.marketNameLabel.font = AppFont.with(type: .bold, size: 14)
        self.leftOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.rightOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func setupWithMarket(_ market: Market, match: Match, teamsText: String, countryIso: String, store: AggregatorStore) {

        if let matchStatsViewModel = matchStatsViewModel,
           market.eventPartId != nil,
           market.bettingTypeId != nil {

            self.homeNameCaptionLabel.text = match.homeParticipant.name
            self.awayNameCaptionLabel.text = match.awayParticipant.name

            self.matchStatsSubscriber = matchStatsViewModel.statsTypePublisher
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { json in
                    self.setupStatsLine(withjson: json)
                })
        }

        self.match = match
        self.market = market
        self.store = store
        
        self.marketNameLabel.text = market.name

        self.participantsNameLabel.text = teamsText

        self.participantsCountryImageView.image = UIImage(named: "market_stats_icon")

        if let marketPublisher = store.marketPublisher(withId: market.id) {
            self.marketSubscriber = marketPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] marketUpdate in
                    if marketUpdate.isAvailable ?? true {
                        self?.showMarketButtons()
                    }
                    else {
                        if marketUpdate.isClosed ?? false {
                            self?.showClosedView()
                        }
                        else {
                            self?.showSuspendedView()
                        }
                    }
                }
        }

        if let outcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = outcome.typeName
            self.leftOutcome = outcome

            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            self.leftOddButtonSubscriber = store.bettingOfferPublisher(withId: outcome.bettingOffer.id)?
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isOpen {
                        weakSelf.leftBaseView.isUserInteractionEnabled = false
                        weakSelf.leftBaseView.alpha = 0.5
                        weakSelf.leftOddValueLabel.text = "-"
                    }
                    else {
                        weakSelf.leftBaseView.isUserInteractionEnabled = true
                        weakSelf.leftBaseView.alpha = 1.0

                        guard let newOddValue = bettingOffer.oddsValue else { return }

                        if let currentOddValue = weakSelf.currentLeftOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.leftUpChangeOddValueImage,
                                                              baseView: weakSelf.leftBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.leftDownChangeOddValueImage,
                                                                baseView: weakSelf.leftBaseView)
                            }
                        }
                        weakSelf.currentLeftOddValue = newOddValue
                        //weakSelf.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                        weakSelf.leftOddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                    }
                })
        }

        if let outcome = market.outcomes[safe: 1] {
            self.rightOddTitleLabel.text = outcome.typeName
            self.rightOutcome = outcome

            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            self.rightOddButtonSubscriber = store.bettingOfferPublisher(withId: outcome.bettingOffer.id)?
                .compactMap({ $0 })
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }
                    
                    if !bettingOffer.isOpen {
                        weakSelf.rightBaseView.isUserInteractionEnabled = false
                        weakSelf.rightBaseView.alpha = 0.5
                        weakSelf.rightOddValueLabel.text = "-"
                    }
                    else {
                        weakSelf.rightBaseView.isUserInteractionEnabled = true
                        weakSelf.rightBaseView.alpha = 1.0
                        
                        guard let newOddValue = bettingOffer.oddsValue else { return }

                        if let currentOddValue = weakSelf.currentRightOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.rightUpChangeOddValueImage,
                                                              baseView: weakSelf.rightBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.rightDownChangeOddValueImage,
                                                                baseView: weakSelf.rightBaseView)
                            }
                        }
                        
                        weakSelf.currentRightOddValue = newOddValue
                        //weakSelf.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                        weakSelf.rightOddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                    }
                })
        }

    }

    @IBAction private func didTapMatchView(_ sender: Any) {
        self.tappedMatchWidgetAction?()
    }

    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true, downChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

    }

    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }

    //
    //
    private func showMarketButtons() {
        self.suspendedBaseView.isHidden = true
    }

    private func showSuspendedView() {
        self.suspendedLabel.text = localized("suspended_market")
        self.suspendedBaseView.isHidden = false
    }

    private func showClosedView() {
        self.suspendedLabel.text = localized("closed_market")
        self.suspendedBaseView.isHidden = false
    }

    //
    //
    func selectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.leftOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.leftOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectLeftOddButton() {
        self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.leftOddTitleLabel.textColor = UIColor.App.textPrimary
        self.leftOddValueLabel.textColor = UIColor.App.textPrimary
    }
    @objc func didTapLeftOddButton() {

        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.leftOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = true
        }
    }

    func selectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.rightOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.rightOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.rightOddTitleLabel.textColor = UIColor.App.textPrimary
        self.rightOddValueLabel.textColor = UIColor.App.textPrimary
    }
    @objc func didTapRightOddButton() {

        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.rightOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        
        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = true
        }
    }

}

extension OddDoubleCollectionViewCell {
    private func setupStatsLine(withjson json: JSON) {

        if StyleHelper.cardsStyleActive() == .small {
            return
        }

        guard
            let eventPartId = self.market?.eventPartId,
            let bettingTypeId = self.market?.bettingTypeId
        else {
            return
        }

        var bettingType: JSON? = nil

        if let eventPartsArray = json["event_parts"].array {
            for partDict in eventPartsArray {
                if let id = partDict["id"].int, String(id) == eventPartId {

                    if let bettintTypesArray = partDict["betting_types"].array {
                        for dict in bettintTypesArray {
                            if let id = dict["id"].int, String(id) == bettingTypeId {
                                bettingType = dict
                                break
                            }
                        }
                    }

                }
            }
        }

        if let bettingTypeValue = bettingType,
           let bettingTypeStats = bettingTypeValue["stats"]["data"].dictionary {

            self.marketNameLabel.font = AppFont.with(type: .bold, size: 12)

            var homeWin: Int?
            var homeWinTotal: Int = 10
            var awayWin: Int?
            var awayWinTotal: Int = 10

            if let homeWinValue = bettingTypeStats["home_participant"]?.int,
               let awayWinValue = bettingTypeStats["away_participant"]?.int {
                homeWin = homeWinValue
                awayWin = awayWinValue
            }
            else if
                let homeUnder = bettingTypeStats["home_participant"]?["Under"].dictionary,
                let homeOver = bettingTypeStats["home_participant"]?["Over"].dictionary,
                let awayUnder = bettingTypeStats["away_participant"]?["Under"].dictionary,
                let awayOver = bettingTypeStats["away_participant"]?["Over"].dictionary,
                let marketParamFloat = self.market?.nameDigit1 {

                let marketParamFloatCast = Int(marketParamFloat)
                switch marketParamFloatCast {
                case 0:
                    homeWin = homeOver["+0.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+0.5"]?.int ?? 0) + (homeUnder["-0.5"]?.int ?? 0)
                    awayWin = awayOver["+0.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+0.5"]?.int ?? 0) + (awayUnder["-0.5"]?.int ?? 0)
                case 1:
                    homeWin = homeOver["+1.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+1.5"]?.int ?? 0) + (homeUnder["-1.5"]?.int ?? 0)
                    awayWin = awayOver["+1.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+1.5"]?.int ?? 0) + (awayUnder["-1.5"]?.int ?? 0)
                case 2:
                    homeWin = homeOver["+2.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+2.5"]?.int ?? 0) + (homeUnder["-2.5"]?.int ?? 0)
                    awayWin = awayOver["+2.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+2.5"]?.int ?? 0) + (awayUnder["-2.5"]?.int ?? 0)
                case 3:
                    homeWin = homeOver["+3.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+3.5"]?.int ?? 0) + (homeUnder["-3.5"]?.int ?? 0)
                    awayWin = awayOver["+3.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+3.5"]?.int ?? 0) + (awayUnder["-3.5"]?.int ?? 0)
                default: ()
                }
            }

            if let homeWinValue = homeWin, let awayWinValue = awayWin {

                let stackSubviews = self.marketStatsStackView.arrangedSubviews
                stackSubviews.forEach({
                    if $0 != self.marketNameLabel {
                        self.marketStatsStackView.removeArrangedSubview($0)
                        $0.removeFromSuperview()
                    }
                })
                
                let homeAwayCardStatsView = HomeAwayCardStatsView()

                homeAwayCardStatsView.setupHomeValues(win: homeWinValue, total: homeWinTotal)
                homeAwayCardStatsView.setupAwayValues(win: awayWinValue, total: awayWinTotal)

                self.marketStatsStackView.addArrangedSubview(homeAwayCardStatsView)

                self.statsBaseView.isHidden = false
            }
        }
    }
}
