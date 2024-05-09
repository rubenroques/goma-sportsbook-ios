//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit
import ServicesProvider
import Combine

class OddDoubleCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    lazy var gradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        
        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]

        return gradientBorderView
    }()

    lazy var liveGradientBorderView: GradientBorderView = {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        
        gradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                             UIColor.App.liveBorderGradient2,
                                             UIColor.App.liveBorderGradient1]
        
        return gradientBorderView
    }()
    
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
    @IBOutlet private weak var cashbackIconImageView: UIImageView!
    
    //
    // Design Constraints
    @IBOutlet private weak var topMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingMarginSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingMarginSpaceConstraint: NSLayoutConstraint!

    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsHeightConstraint: NSLayoutConstraint!

    var openStatsButton: OpenStatsButton?
    
    private var cachedCardsStyle: CardsStyle?
    //

    var matchStatsViewModel: MatchStatsViewModel?

    var match: Match?
    var market: Market?

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
    
    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }

    var tappedMatchWidgetAction: (() -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

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

        self.suspendedLabel.text = localized("suspended")
        
        self.suspendedBaseView.isHidden = true

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0
        
        self.cashbackIconImageView.image = UIImage(named: "cashback_small_blue_icon")
        self.cashbackIconImageView.contentMode = .scaleAspectFit
        
        self.hasCashback = false

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.leftBaseView.addGestureRecognizer(tapLeftOddButton)

        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.leftBaseView.addGestureRecognizer(longPressLeftOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.rightBaseView.addGestureRecognizer(tapRightOddButton)

        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.rightBaseView.addGestureRecognizer(longPressRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

        // Add gradient border
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveGradientBorderView)
        
        self.baseView.sendSubviewToBack(self.liveGradientBorderView)
        self.baseView.sendSubviewToBack(self.gradientBorderView)

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),
            
            self.baseView.leadingAnchor.constraint(equalTo: self.liveGradientBorderView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.liveGradientBorderView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.liveGradientBorderView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.liveGradientBorderView.bottomAnchor),
        ])
        
        self.gradientBorderView.isHidden = true
        self.liveGradientBorderView.isHidden = true
        
        //
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
        
        self.hasCashback = false

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
        
        self.iconStatsImageView.setTintColor(color: UIColor.App.iconSecondary)
        
        self.openStatsButton?.setupWithTheme()
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

    func setupWithMarket(_ market: Market, match: Match, teamsText: String, countryIso: String, isLive: Bool) {

        if isLive {
            self.baseView.backgroundColor = UIColor.App.backgroundDrop
            self.liveGradientBorderView.isHidden = false
            self.gradientBorderView.isHidden = true
        }
        else {
            self.baseView.backgroundColor = UIColor.App.backgroundCards
            self.liveGradientBorderView.isHidden = true
            self.gradientBorderView.isHidden = false
        }
        
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

        if market.statsTypeId != nil {
            self.showStatsButton()
        }
        else {
            // No market statys type id found, show error label
        }
        
        self.match = match
        self.market = market

        self.marketNameLabel.text = market.name

        self.participantsNameLabel.text = teamsText

        self.participantsCountryImageView.image = UIImage(named: "market_stats_icon")

        self.marketSubscriber = Env.servicesProvider.subscribeToEventMarketUpdates(withId: market.id)
            .compactMap({ $0 })
            .map({ (serviceProviderMarket: ServicesProvider.Market) -> Market in
                return ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("marketSubscriber subscribeToEventMarketUpdates completion: \(completion)")
            }, receiveValue: { [weak self] (marketUpdated: Market) in

                if marketUpdated.isAvailable {
                    self?.showMarketButtons()
                    print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will show \n")
                }
                else {
                    self?.showSuspendedView()
                    print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will hide \n")
                }
            })
        
        //
        //
        if let outcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = outcome.typeName
            self.leftOutcome = outcome

            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
//            self.leftOddValueLabel.text = OddConverter.stringForValue(outcome.bettingOffer.decimalOdd, format: UserDefaults.standard.userOddsFormat)
                self.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
            }
            else {
                self.leftBaseView.isUserInteractionEnabled = false
                self.leftBaseView.alpha = 0.5
                self.leftOddValueLabel.text = "-"
            }

            self.leftOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isAvailable {
                        weakSelf.leftBaseView.isUserInteractionEnabled = false
                        weakSelf.leftBaseView.alpha = 0.5
                        weakSelf.leftOddValueLabel.text = "-"
                    }
                    else {
                        weakSelf.leftBaseView.isUserInteractionEnabled = true
                        weakSelf.leftBaseView.alpha = 1.0

                        let newOddValue = bettingOffer.decimalOdd

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
                        weakSelf.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    }
                })
        }

        if let outcome = market.outcomes[safe: 1] {
            self.rightOddTitleLabel.text = outcome.typeName
            self.rightOutcome = outcome

            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
//            self.rightOddValueLabel.text = OddConverter.stringForValue(outcome.bettingOffer.decimalOdd, format: UserDefaults.standard.userOddsFormat)
                self.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
            }
            else {
                self.rightBaseView.isUserInteractionEnabled = false
                self.rightBaseView.alpha = 0.5
                self.rightOddValueLabel.text = "-"
            }

            self.rightOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }
                    
                    if !bettingOffer.isAvailable {
                        weakSelf.rightBaseView.isUserInteractionEnabled = false
                        weakSelf.rightBaseView.alpha = 0.5
                        weakSelf.rightOddValueLabel.text = "-"
                    }
                    else {
                        weakSelf.rightBaseView.isUserInteractionEnabled = true
                        weakSelf.rightBaseView.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd

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
                        weakSelf.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    }
                })
        }
        
        self.hasCashback = RePlayFeatureHelper.shouldShowRePlay(forMatch: match) 

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
        self.suspendedLabel.text = localized("suspended")
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

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isLeftOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressLeftOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.match,
                let market = self.market,
                let outcome = self.leftOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
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

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            self.isRightOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressRightOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.match,
                let market = self.market,
                let outcome = self.rightOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
    }

}

extension OddDoubleCollectionViewCell {
    
    @objc private func openStatsWidgetFullscreen() {
        if let rootViewController = self.window?.rootViewController, let matchId = self.match?.id, let marketTypeId = self.market?.statsTypeId {
            let statsWebViewController = StatsWebViewController(matchId: matchId, marketTypeId: marketTypeId)
            statsWebViewController.modalPresentationStyle = .overCurrentContext
            rootViewController.present(statsWebViewController, animated: true)
        }
    }
    
    private func showStatsButton() {
        
        self.marketStatsStackView.distribution = .fillEqually
        self.marketStatsStackView.spacing = 2
        
        let stackSubviews = self.marketStatsStackView.arrangedSubviews
        stackSubviews.forEach({
            if $0 != self.marketNameLabel {
                self.marketStatsStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        })
        
        let openStatsButton = OpenStatsButton()
        openStatsButton.openStatsWidgetFullscreenAction = { [weak self] in
            self?.openStatsWidgetFullscreen()
        }
        self.openStatsButton = openStatsButton
        self.marketStatsStackView.addArrangedSubview(openStatsButton)
        
    }
    
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



import WebKit

class StatsWebViewController: UIViewController, WKNavigationDelegate {
    
    private var loadingView: UIActivityIndicatorView!
    private var webView: WKWebView!
    private var webViewHeightConstraint: NSLayoutConstraint!
    private var closeButton: UIButton!

    private var matchId: String
    private var marketTypeId: String
    
    private var marketStatsSubscriber: AnyCancellable?
    
    init(matchId: String, marketTypeId: String) {
        self.matchId = matchId
        self.marketTypeId = marketTypeId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        self.setupCloseButton()

        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.isOpaque = false

        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
        self.webView.scrollView.isScrollEnabled = false
        
        self.view.addSubview(webView)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.loadingView = UIActivityIndicatorView()
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.loadingView)
        
        self.webViewHeightConstraint = self.webView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            self.webView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.webView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.webView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.webViewHeightConstraint,
            
            self.loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])

        self.loadingView.startAnimating()
        
        let theme = self.traitCollection.userInterfaceStyle
        self.marketStatsSubscriber = Env.servicesProvider.getStatsWidget(eventId: self.matchId,
                                                                         marketTypeName: self.marketTypeId,
                                                                         isDarkTheme: theme == .dark ? true : false)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("getStatsWidget completion \(completion)")
            } receiveValue: { [weak self] statsWidgetRenderDataType in
                switch statsWidgetRenderDataType {
                case .url:
                    break
                case .htmlString(let url, let htmlString):
                    self?.webView.loadHTMLString(htmlString, baseURL: url)
                }
            }
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(closeButtonTapped))
        self.view.addGestureRecognizer(tapGesture)
    }

    private func setupCloseButton() {
        self.closeButton = UIButton(type: .custom)
        
        let closeImage = UIImage(named: "arrow_close_icon")?.withRenderingMode(.alwaysTemplate)

        
        self.closeButton.setImage(closeImage, for: .normal)
        self.closeButton.imageView?.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.view.addSubview(self.closeButton)

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loadingView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] complete, error in
            if complete != nil {
                self?.recalculateWebview()
            }
            else if let error = error {
                Logger.log("Match details WKWebView didFinish error \(error)")
            }
        })
    }
    
    private func recalculateWebview() {
        executeDelayed(0.2) {
             self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] height, error in
                 if let heightFloat = height as? CGFloat {
                     self?.redrawWebView(withHeight: heightFloat)
                 }
                 if let error = error {
                     Logger.log("Match details WKWebView didFinish error \(error)")
                 }
             })
         }
     }
     
     private func redrawWebView(withHeight heigth: CGFloat) {
         if heigth < 10 {
            self.recalculateWebview()
         }
         else {
             self.webViewHeightConstraint.constant = heigth
             self.view.layoutIfNeeded()
             self.loadingView.stopAnimating()
         }
     }
     
    
}

class OpenStatsButton: UIView {
    
    var openStatsWidgetFullscreenAction: () -> () = { }
    
    private let shadowBackgroundView = UIView()
    private let button = UIButton()
    private let statsImage = UIImage(named: "open_stats_icon")?.withRenderingMode(.alwaysTemplate)
    
    init() {
        super.init(frame: .zero)
        self.setupSubviews()
        
        self.setupWithTheme()
    }
    
    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.button.addTarget(self, action: #selector(self.openStatsWidgetFullscreen), for: .primaryActionTriggered)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.setTitle(localized("view_stats"), for: .normal)
        
        self.button.setImage(self.statsImage, for: .normal)
        
        self.button.titleLabel?.font = AppFont.with(type: .semibold, size: 11)
        
        self.button.layer.cornerRadius = CornerRadius.button
        self.button.layer.masksToBounds = true
        
        self.button.setInsets(forContentPadding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8), imageTitlePadding: 4)

        self.shadowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.shadowBackgroundView.layer.cornerRadius = CornerRadius.button
        self.shadowBackgroundView.layer.masksToBounds = true
        
        self.addSubview(self.shadowBackgroundView)
        self.addSubview(self.button)
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: self.button.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.button.centerYAnchor, constant: 3),
            
            self.button.heightAnchor.constraint(equalToConstant: 24),
            
            self.shadowBackgroundView.leadingAnchor.constraint(equalTo: self.button.leadingAnchor),
            self.shadowBackgroundView.trailingAnchor.constraint(equalTo: self.button.trailingAnchor),
            self.shadowBackgroundView.topAnchor.constraint(equalTo: self.button.topAnchor),
            self.shadowBackgroundView.bottomAnchor.constraint(equalTo: self.button.bottomAnchor, constant: 2),
        ])
        
        
        
    }
    
    @objc func openStatsWidgetFullscreen() {
        self.openStatsWidgetFullscreenAction()
    }
    
    func setupWithTheme() {
        self.shadowBackgroundView.backgroundColor = UIColor.App.highlightPrimary
        
        self.button.imageView?.setTintColor(color: UIColor.App.textPrimary)
        self.button.tintColor = UIColor.App.textPrimary
        
        self.button.setTitleColor(UIColor.App.textPrimary, for: .normal)
        
        self.button.setBackgroundColor(UIColor.App.backgroundBorder, for: .normal)
        self.button.backgroundColor = .clear
    }
    
}
