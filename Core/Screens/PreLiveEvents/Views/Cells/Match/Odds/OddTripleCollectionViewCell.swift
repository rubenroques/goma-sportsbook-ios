//
//  OddDoubleCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit
import ServicesProvider
import Combine

class OddTripleCollectionViewCell: UICollectionViewCell {
    
    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var gradientBorderView: GradientBorderView = Self.createGradientBorderView()
    private lazy var liveGradientBorderView: GradientBorderView = Self.createLiveGradientBorderView()
    
    private lazy var participantsCountryImageView: UIImageView = Self.createParticipantsCountryImageView()
    private lazy var participantsNameLabel: UILabel = Self.createParticipantsNameLabel()
    
    private lazy var statsBaseView: UIView = Self.createStatsBaseView()
    private lazy var iconStatsImageView: UIImageView = Self.createIconStatsImageView()
    private lazy var homeCircleCaptionView: UIView = Self.createHomeCircleCaptionView()
    private lazy var homeNameCaptionLabel: UILabel = Self.createHomeNameCaptionLabel()
    private lazy var awayCircleCaptionView: UIView = Self.createAwayCircleCaptionView()
    private lazy var awayNameCaptionLabel: UILabel = Self.createAwayNameCaptionLabel()
    private lazy var cashbackIconImageView: UIImageView = Self.createCashbackIconImageView()
    
    private lazy var marketStatsStackView: UIStackView = Self.createMarketStatsStackView()
    private lazy var marketNameLabel: UILabel = Self.createMarketNameLabel()
    private lazy var marketInfoView: UIView = Self.createMarketInfoView()
    
    private lazy var oddsStackView: UIStackView = Self.createOddsStackView()
    private lazy var leftBaseView: UIView = Self.createLeftBaseView()
    private lazy var leftOddTitleLabel: UILabel = Self.createLeftOddTitleLabel()
    private lazy var leftOddValueLabel: UILabel = Self.createLeftOddValueLabel()
    private lazy var leftUpChangeOddValueImage: UIImageView = Self.createLeftUpChangeOddValueImage()
    private lazy var leftDownChangeOddValueImage: UIImageView = Self.createLeftDownChangeOddValueImage()
    
    private lazy var middleBaseView: UIView = Self.createMiddleBaseView()
    private lazy var middleOddTitleLabel: UILabel = Self.createMiddleOddTitleLabel()
    private lazy var middleOddValueLabel: UILabel = Self.createMiddleOddValueLabel()
    private lazy var middleUpChangeOddValueImage: UIImageView = Self.createMiddleUpChangeOddValueImage()
    private lazy var middleDownChangeOddValueImage: UIImageView = Self.createMiddleDownChangeOddValueImage()
    
    private lazy var rightBaseView: UIView = Self.createRightBaseView()
    private lazy var rightOddTitleLabel: UILabel = Self.createRightOddTitleLabel()
    private lazy var rightOddValueLabel: UILabel = Self.createRightOddValueLabel()
    private lazy var rightUpChangeOddValueImage: UIImageView = Self.createRightUpChangeOddValueImage()
    private lazy var rightDownChangeOddValueImage: UIImageView = Self.createRightDownChangeOddValueImage()
    
    private lazy var suspendedBaseView: UIView = Self.createSuspendedBaseView()
    private lazy var suspendedLabel: UILabel = Self.createSuspendedLabel()
    
    // MARK: Constraints
    private var topMarginSpaceConstraint: NSLayoutConstraint!
    private var bottomMarginSpaceConstraint: NSLayoutConstraint!
    private var leadingMarginSpaceConstraint: NSLayoutConstraint!
    private var trailingMarginSpaceConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    private var buttonsHeightConstraint: NSLayoutConstraint!
    
    private var cachedCardsStyle: CardsStyle?
    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var matchStatsSubscriber: AnyCancellable?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var marketSubscriber: AnyCancellable?

    private var currentLeftOddValue: Double?
    private var currentMiddleOddValue: Double?
    private var currentRightOddValue: Double?

    private var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }
    
    private var isMiddleOutcomeButtonSelected: Bool = false {
        didSet {
            self.isMiddleOutcomeButtonSelected ? self.selectMiddleOddButton() : self.deselectMiddleOddButton()
        }
    }
    
    private var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }
    
    // MARK: Public properties
    var openStatsButton: OpenStatsButton?
    
    var matchStatsViewModel: MatchStatsViewModel?

    var match: Match?
    var market: Market?
    
    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }

    // MARK: Callbacks
    var tappedMatchWidgetAction: (() -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()

        self.statsBaseView.isHidden = true
        
        self.suspendedBaseView.isHidden = true
        
        self.hasCashback = false

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.leftBaseView.addGestureRecognizer(tapLeftOddButton)

        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.leftBaseView.addGestureRecognizer(longPressLeftOddButton)
        
        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.middleBaseView.addGestureRecognizer(tapMiddleOddButton)

        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.middleBaseView.addGestureRecognizer(longPressMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.rightBaseView.addGestureRecognizer(tapRightOddButton)

        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.rightBaseView.addGestureRecognizer(longPressRightOddButton)

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)
        
        self.adjustDesignToCardStyle()
        self.setupWithTheme()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
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
        self.middleBaseView.isUserInteractionEnabled = true
        self.rightBaseView.isUserInteractionEnabled = true

        self.leftBaseView.alpha = 1.0
        self.middleBaseView.alpha = 1.0
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
    
    // MARK: Layout and theme
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
        
        self.baseView.layer.cornerRadius = 9

        self.suspendedBaseView.layer.cornerRadius = 4.5
        self.leftBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5
    }
    
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.participantsNameLabel.textColor = UIColor.App.textPrimary
        
        self.marketInfoView.backgroundColor = .clear
        self.marketNameLabel.textColor = UIColor.App.textPrimary

        self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.leftOddTitleLabel.textColor = UIColor.App.textPrimary
        self.leftOddValueLabel.textColor = UIColor.App.textPrimary
        
        self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.middleOddTitleLabel.textColor = UIColor.App.textPrimary
        self.middleOddValueLabel.textColor = UIColor.App.textPrimary
        
        self.rightBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.rightOddTitleLabel.textColor = UIColor.App.textPrimary
        self.rightOddValueLabel.textColor = UIColor.App.textPrimary

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
        
        if isMiddleOutcomeButtonSelected {
            self.middleBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.middleOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.middleOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.middleOddTitleLabel.textColor = UIColor.App.textPrimary
            self.middleOddValueLabel.textColor = UIColor.App.textPrimary
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
        self.middleOddValueLabel.font = AppFont.with(type: .bold, size: 12)
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
        self.middleOddValueLabel.font = AppFont.with(type: .bold, size: 13)
        self.rightOddValueLabel.font = AppFont.with(type: .bold, size: 13)
    }
    
    // MARK: Functions
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

        self.marketSubscriber = Env.servicesProvider.subscribeToEventOnListsMarketUpdates(withId: market.id)
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
                }
                else {
                    self?.showSuspendedView()
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
                self.leftOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
            }
            else {
                self.leftBaseView.isUserInteractionEnabled = false
                self.leftBaseView.alpha = 0.5
                self.leftOddValueLabel.text = "-"
            }

            self.leftOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

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
            self.middleOddTitleLabel.text = outcome.typeName
            self.middleOutcome = outcome

            self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.middleOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
            }
            else {
                self.middleBaseView.isUserInteractionEnabled = false
                self.middleBaseView.alpha = 0.5
                self.middleOddValueLabel.text = "-"
            }

            self.middleOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { [weak self] bettingOffer in

                    guard let weakSelf = self else { return }

                    if !bettingOffer.isAvailable {
                        weakSelf.middleBaseView.isUserInteractionEnabled = false
                        weakSelf.middleBaseView.alpha = 0.5
                        weakSelf.middleOddValueLabel.text = "-"
                    }
                    else {
                        weakSelf.middleBaseView.isUserInteractionEnabled = true
                        weakSelf.middleBaseView.alpha = 1.0

                        let newOddValue = bettingOffer.decimalOdd

                        if let currentOddValue = weakSelf.currentMiddleOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.middleUpChangeOddValueImage,
                                                              baseView: weakSelf.middleBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.middleDownChangeOddValueImage,
                                                                baseView: weakSelf.middleBaseView)
                            }
                        }
                        weakSelf.currentMiddleOddValue = newOddValue
                        weakSelf.middleOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    }
                })
        }

        if let outcome = market.outcomes[safe: 2] {
            self.rightOddTitleLabel.text = outcome.typeName
            self.rightOutcome = outcome

            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
            }
            else {
                self.rightBaseView.isUserInteractionEnabled = false
                self.rightBaseView.alpha = 0.5
                self.rightOddValueLabel.text = "-"
            }

            self.rightOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

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
    
    func selectMiddleOddButton() {
        self.middleBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.middleOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.middleOddValueLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectMiddleOddButton() {
        self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.middleOddTitleLabel.textColor = UIColor.App.textPrimary
        self.middleOddValueLabel.textColor = UIColor.App.textPrimary
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
    
    // MARK: Actions
    @objc private func didTapMatchView(_ sender: Any) {
        self.tappedMatchWidgetAction?()
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
    
    @objc func didTapMiddleOddButton() {
        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.middleOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isMiddleOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressMiddleOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.match,
                let market = self.market,
                let outcome = self.middleOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
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

extension OddTripleCollectionViewCell {
    
    @objc private func openStatsWidgetFullscreen() {
        if let rootViewController = self.window?.rootViewController, let matchId = self.match?.id, let marketTypeId = self.market?.statsTypeId {
            let statsWebViewController = StatsWebViewController(matchId: matchId, marketTypeId: marketTypeId)
            statsWebViewController.modalPresentationStyle = .overCurrentContext
            rootViewController.present(statsWebViewController, animated: true)
        }
    }
    
    private func showStatsButton() {
        
        switch StyleHelper.cardsStyleActive() {
        case .normal:
            self.marketStatsStackView.distribution = .fillEqually
            self.marketStatsStackView.spacing = 2
            self.marketStatsStackView.axis = .vertical
        case .small:
            self.marketStatsStackView.distribution = .fillEqually
            self.marketStatsStackView.spacing = 6
            self.marketStatsStackView.axis = .horizontal
        }
        
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

        var bettingType: JSON?

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

extension OddTripleCollectionViewCell {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }
    
    private static func createGradientBorderView() -> GradientBorderView {
        let gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]
        gradientBorderView.isHidden = true
        return gradientBorderView
    }

    private static func createLiveGradientBorderView() -> GradientBorderView {
        let gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 9
        gradientBorderView.gradientColors = [UIColor.App.liveBorder3,
                                             UIColor.App.liveBorder2,
                                             UIColor.App.liveBorder1]
        gradientBorderView.isHidden = true
        return gradientBorderView
    }

    private static func createParticipantsNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textColor = UIColor.App.textPrimary
        label.text = ""
        return label
    }

    private static func createParticipantsCountryImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createMarketStatsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createMarketNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.text = ""
        return label
    }

    private static func createMarketInfoView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createLeftBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        return view
    }

    private static func createLeftOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        return label
    }

    private static func createLeftOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.text = "-"
        return label
    }

    private static func createLeftUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.alpha = 0.0
        return imageView
    }

    private static func createLeftDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.alpha = 0.0
        return imageView
    }
    
    private static func createMiddleBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundOdds
        view.layer.cornerRadius = 4.5
        return view
    }

    private static func createMiddleOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        return label
    }

    private static func createMiddleOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .heavy, size: 13)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        label.text = "-"
        return label
    }

    private static func createMiddleUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    private static func createMiddleDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    private static func createRightBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        return view
    }

    private static func createRightOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        return label
    }

    private static func createRightOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.text = "-"
        return label
    }

    private static func createRightUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.alpha = 0.0
        return imageView
    }

    private static func createRightDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.alpha = 0.0
        return imageView
    }

    private static func createSuspendedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.isHidden = true
        return view
    }

    private static func createSuspendedLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.text = localized("suspended")
        label.textAlignment = .center
        return label
    }

    private static func createStatsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }

    private static func createIconStatsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "market_stats_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createHomeCircleCaptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }

    private static func createHomeNameCaptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 9)
        return label
    }

    private static func createAwayCircleCaptionView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }

    private static func createAwayNameCaptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 9)
        return label
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_small_blue_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        self.contentView.addSubview(self.baseView)
        
        self.baseView.addSubview(self.gradientBorderView)
        self.baseView.addSubview(self.liveGradientBorderView)
        
        self.baseView.addSubview(self.participantsCountryImageView)
        self.baseView.addSubview(self.participantsNameLabel)
        
        self.baseView.addSubview(self.marketInfoView)
        self.marketInfoView.addSubview(self.marketStatsStackView)
        self.marketStatsStackView.addArrangedSubview(self.marketNameLabel)
        
        self.baseView.addSubview(self.oddsStackView)
        self.oddsStackView.addArrangedSubview(self.leftBaseView)
        self.oddsStackView.addArrangedSubview(self.middleBaseView)
        self.oddsStackView.addArrangedSubview(self.rightBaseView)
        
        self.leftBaseView.addSubview(self.leftOddTitleLabel)
        self.leftBaseView.addSubview(self.leftOddValueLabel)
        self.leftBaseView.addSubview(self.leftUpChangeOddValueImage)
        self.leftBaseView.addSubview(self.leftDownChangeOddValueImage)
        
        self.middleBaseView.addSubview(self.middleOddTitleLabel)
        self.middleBaseView.addSubview(self.middleOddValueLabel)
        self.middleBaseView.addSubview(self.middleUpChangeOddValueImage)
        self.middleBaseView.addSubview(self.middleDownChangeOddValueImage)
        
        self.rightBaseView.addSubview(self.rightOddTitleLabel)
        self.rightBaseView.addSubview(self.rightOddValueLabel)
        self.rightBaseView.addSubview(self.rightUpChangeOddValueImage)
        self.rightBaseView.addSubview(self.rightDownChangeOddValueImage)
        
        self.baseView.addSubview(self.suspendedBaseView)
        self.suspendedBaseView.addSubview(self.suspendedLabel)
        
        self.baseView.addSubview(self.statsBaseView)
        self.statsBaseView.addSubview(self.iconStatsImageView)
        self.statsBaseView.addSubview(self.homeCircleCaptionView)
        self.statsBaseView.addSubview(self.homeNameCaptionLabel)
        self.statsBaseView.addSubview(self.awayCircleCaptionView)
        self.statsBaseView.addSubview(self.awayNameCaptionLabel)
        
        self.baseView.addSubview(self.cashbackIconImageView)
        
        self.baseView.bringSubviewToFront(self.suspendedBaseView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        // Base view constraints
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        // Gradient border constraints
        NSLayoutConstraint.activate([
            self.gradientBorderView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.gradientBorderView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.gradientBorderView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.gradientBorderView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            
            self.liveGradientBorderView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.liveGradientBorderView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.liveGradientBorderView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.liveGradientBorderView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor)
        ])
        
        // Header components constraints
        self.leadingMarginSpaceConstraint = self.participantsCountryImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 12)
        self.topMarginSpaceConstraint = self.participantsCountryImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 6)
        self.headerHeightConstraint = self.participantsCountryImageView.heightAnchor.constraint(equalToConstant: 16)
        
        NSLayoutConstraint.activate([
            self.leadingMarginSpaceConstraint,
            self.topMarginSpaceConstraint,
            self.headerHeightConstraint,
            self.participantsCountryImageView.widthAnchor.constraint(equalTo: self.participantsCountryImageView.heightAnchor),
            
            self.participantsNameLabel.leadingAnchor.constraint(equalTo: self.participantsCountryImageView.trailingAnchor, constant: 6),
            self.participantsNameLabel.centerYAnchor.constraint(equalTo: self.participantsCountryImageView.centerYAnchor, constant: 1),
            self.participantsNameLabel.trailingAnchor.constraint(equalTo: self.cashbackIconImageView.leadingAnchor, constant: -6),
            
            self.cashbackIconImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -8),
            self.cashbackIconImageView.centerYAnchor.constraint(equalTo: self.participantsCountryImageView.centerYAnchor),
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.cashbackIconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Stats base view constraints
        NSLayoutConstraint.activate([
            self.statsBaseView.leadingAnchor.constraint(equalTo: self.participantsCountryImageView.leadingAnchor),
            self.statsBaseView.trailingAnchor.constraint(equalTo: self.participantsNameLabel.trailingAnchor),
            self.statsBaseView.topAnchor.constraint(equalTo: self.participantsCountryImageView.topAnchor),
            self.statsBaseView.bottomAnchor.constraint(equalTo: self.participantsCountryImageView.bottomAnchor),
            
            self.iconStatsImageView.leadingAnchor.constraint(equalTo: self.statsBaseView.leadingAnchor),
            self.iconStatsImageView.centerYAnchor.constraint(equalTo: self.statsBaseView.centerYAnchor),
            self.iconStatsImageView.topAnchor.constraint(equalTo: self.statsBaseView.topAnchor),
            
            self.homeCircleCaptionView.leadingAnchor.constraint(equalTo: self.iconStatsImageView.trailingAnchor, constant: 4),
            self.homeCircleCaptionView.centerYAnchor.constraint(equalTo: self.statsBaseView.centerYAnchor),
            self.homeCircleCaptionView.widthAnchor.constraint(equalToConstant: 6),
            self.homeCircleCaptionView.heightAnchor.constraint(equalToConstant: 6),
            
            self.homeNameCaptionLabel.leadingAnchor.constraint(equalTo: self.homeCircleCaptionView.trailingAnchor, constant: 3),
            self.homeNameCaptionLabel.centerYAnchor.constraint(equalTo: self.statsBaseView.centerYAnchor),
            
            self.awayCircleCaptionView.leadingAnchor.constraint(equalTo: self.homeNameCaptionLabel.trailingAnchor, constant: 6),
            self.awayCircleCaptionView.centerYAnchor.constraint(equalTo: self.statsBaseView.centerYAnchor),
            self.awayCircleCaptionView.widthAnchor.constraint(equalToConstant: 6),
            self.awayCircleCaptionView.heightAnchor.constraint(equalToConstant: 6),
            
            self.awayNameCaptionLabel.leadingAnchor.constraint(equalTo: self.awayCircleCaptionView.trailingAnchor, constant: 3),
            self.awayNameCaptionLabel.centerYAnchor.constraint(equalTo: self.statsBaseView.centerYAnchor)
        ])
        
        // Market info view constraints
        NSLayoutConstraint.activate([
            self.marketInfoView.leadingAnchor.constraint(equalTo: self.participantsCountryImageView.leadingAnchor),
            self.marketInfoView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12),
            self.marketInfoView.topAnchor.constraint(equalTo: self.participantsCountryImageView.bottomAnchor, constant: 6),
            
            self.marketStatsStackView.leadingAnchor.constraint(equalTo: self.marketInfoView.leadingAnchor),
            self.marketStatsStackView.trailingAnchor.constraint(equalTo: self.marketInfoView.trailingAnchor),
            self.marketStatsStackView.topAnchor.constraint(equalTo: self.marketInfoView.topAnchor),
            self.marketStatsStackView.bottomAnchor.constraint(equalTo: self.marketInfoView.bottomAnchor)
        ])
        
        // Odds stack view constraints
        self.buttonsHeightConstraint = self.oddsStackView.heightAnchor.constraint(equalToConstant: 40)
        self.trailingMarginSpaceConstraint = self.baseView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor, constant: 12)
        self.bottomMarginSpaceConstraint = self.baseView.bottomAnchor.constraint(equalTo: self.oddsStackView.bottomAnchor, constant: 12)
        
        NSLayoutConstraint.activate([
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.participantsCountryImageView.leadingAnchor),
            self.trailingMarginSpaceConstraint,
            self.oddsStackView.topAnchor.constraint(equalTo: self.marketInfoView.bottomAnchor, constant: 4),
            self.bottomMarginSpaceConstraint,
            self.buttonsHeightConstraint
        ])
        
        // Left odd labels constraints
        NSLayoutConstraint.activate([
            self.leftOddTitleLabel.leadingAnchor.constraint(equalTo: self.leftBaseView.leadingAnchor, constant: 2),
            self.leftOddTitleLabel.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -2),
            self.leftOddTitleLabel.topAnchor.constraint(equalTo: self.leftBaseView.topAnchor, constant: 6),
            self.leftOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),
            
            self.leftOddValueLabel.leadingAnchor.constraint(equalTo: self.leftBaseView.leadingAnchor, constant: 2),
            self.leftOddValueLabel.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -2),
            self.leftOddValueLabel.topAnchor.constraint(equalTo: self.leftOddTitleLabel.bottomAnchor),
            
            self.leftUpChangeOddValueImage.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -6),
            self.leftUpChangeOddValueImage.topAnchor.constraint(equalTo: self.leftBaseView.topAnchor, constant: 14),
            self.leftUpChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.leftUpChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9),
            
            self.leftDownChangeOddValueImage.trailingAnchor.constraint(equalTo: self.leftBaseView.trailingAnchor, constant: -6),
            self.leftDownChangeOddValueImage.bottomAnchor.constraint(equalTo: self.leftBaseView.bottomAnchor, constant: -14),
            self.leftDownChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.leftDownChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9)
        ])
        
        // Middle odd labels constraints
        NSLayoutConstraint.activate([
            self.middleOddTitleLabel.leadingAnchor.constraint(equalTo: self.middleBaseView.leadingAnchor, constant: 2),
            self.middleOddTitleLabel.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -2),
            self.middleOddTitleLabel.topAnchor.constraint(equalTo: self.middleBaseView.topAnchor, constant: 6),
            self.middleOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),
            
            self.middleOddValueLabel.leadingAnchor.constraint(equalTo: self.middleBaseView.leadingAnchor, constant: 2),
            self.middleOddValueLabel.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -2),
            self.middleOddValueLabel.topAnchor.constraint(equalTo: self.middleOddTitleLabel.bottomAnchor),
            
            self.middleUpChangeOddValueImage.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -6),
            self.middleUpChangeOddValueImage.topAnchor.constraint(equalTo: self.middleBaseView.topAnchor, constant: 14),
            self.middleUpChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.middleUpChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9),
            
            self.middleDownChangeOddValueImage.trailingAnchor.constraint(equalTo: self.middleBaseView.trailingAnchor, constant: -6),
            self.middleDownChangeOddValueImage.bottomAnchor.constraint(equalTo: self.middleBaseView.bottomAnchor, constant: -14),
            self.middleDownChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.middleDownChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9)
        ])
        
        // Right odd labels constraints
        NSLayoutConstraint.activate([
            self.rightOddTitleLabel.leadingAnchor.constraint(equalTo: self.rightBaseView.leadingAnchor, constant: 2),
            self.rightOddTitleLabel.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -2),
            self.rightOddTitleLabel.topAnchor.constraint(equalTo: self.rightBaseView.topAnchor, constant: 6),
            self.rightOddTitleLabel.heightAnchor.constraint(equalToConstant: 14),
            
            self.rightOddValueLabel.leadingAnchor.constraint(equalTo: self.rightBaseView.leadingAnchor, constant: 2),
            self.rightOddValueLabel.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -2),
            self.rightOddValueLabel.topAnchor.constraint(equalTo: self.rightOddTitleLabel.bottomAnchor),
            
            self.rightUpChangeOddValueImage.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -6),
            self.rightUpChangeOddValueImage.topAnchor.constraint(equalTo: self.rightBaseView.topAnchor, constant: 14),
            self.rightUpChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.rightUpChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9),
            
            self.rightDownChangeOddValueImage.trailingAnchor.constraint(equalTo: self.rightBaseView.trailingAnchor, constant: -6),
            self.rightDownChangeOddValueImage.bottomAnchor.constraint(equalTo: self.rightBaseView.bottomAnchor, constant: -14),
            self.rightDownChangeOddValueImage.widthAnchor.constraint(equalToConstant: 11),
            self.rightDownChangeOddValueImage.heightAnchor.constraint(equalToConstant: 9)
        ])
        
        // Suspended view constraints
        NSLayoutConstraint.activate([
            self.suspendedBaseView.leadingAnchor.constraint(equalTo: self.oddsStackView.leadingAnchor),
            self.suspendedBaseView.trailingAnchor.constraint(equalTo: self.oddsStackView.trailingAnchor),
            self.suspendedBaseView.topAnchor.constraint(equalTo: self.oddsStackView.topAnchor),
            self.suspendedBaseView.bottomAnchor.constraint(equalTo: self.oddsStackView.bottomAnchor),
            
            self.suspendedLabel.centerXAnchor.constraint(equalTo: self.suspendedBaseView.centerXAnchor),
            self.suspendedLabel.centerYAnchor.constraint(equalTo: self.suspendedBaseView.centerYAnchor)
        ])
    }
}
