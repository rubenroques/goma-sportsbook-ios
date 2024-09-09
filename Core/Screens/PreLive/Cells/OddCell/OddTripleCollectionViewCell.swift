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

    @IBOutlet private weak var middleBaseView: UIView!
    @IBOutlet private weak var middleOddTitleLabel: UILabel!
    @IBOutlet private weak var middleOddValueLabel: UILabel!

    @IBOutlet private weak var rightBaseView: UIView!
    @IBOutlet private weak var rightOddTitleLabel: UILabel!
    @IBOutlet private weak var rightOddValueLabel: UILabel!

    @IBOutlet private weak var suspendedBaseView: UIView!
    @IBOutlet private weak var suspendedLabel: UILabel!

    @IBOutlet private weak var leftUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var leftDownChangeOddValueImage: UIImageView!
    @IBOutlet private weak var middleUpChangeOddValueImage: UIImageView!
    @IBOutlet private weak var middleDownChangeOddValueImage: UIImageView!
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

    private var openStatsButton: OpenStatsButton?
    
    private var cachedCardsStyle: CardsStyle?
    //

    var matchStatsViewModel: MatchStatsViewModel?

    var match: Match?
    var market: Market?

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

        self.marketNameLabel.font = AppFont.with(type: .bold, size: 14)

        self.statsBaseView.isHidden = true

        self.homeCircleCaptionView.layer.masksToBounds = true
        self.awayCircleCaptionView.layer.masksToBounds = true
        
        self.oddsStackView.backgroundColor = .clear

        self.suspendedBaseView.layer.cornerRadius = 4.5

        self.leftBaseView.layer.cornerRadius = 4.5
        self.middleBaseView.layer.cornerRadius = 4.5
        self.rightBaseView.layer.cornerRadius = 4.5

        self.participantsNameLabel.text = ""
        self.marketNameLabel.text = ""

        self.leftOddValueLabel.text = "-"
        self.middleOddValueLabel.text = "-"
        self.rightOddValueLabel.text = "-"

        self.suspendedLabel.text = localized("suspended")
        self.suspendedBaseView.isHidden = true

        self.leftUpChangeOddValueImage.alpha = 0.0
        self.leftDownChangeOddValueImage.alpha = 0.0
        self.middleUpChangeOddValueImage.alpha = 0.0
        self.middleDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""
        
        self.cashbackIconImageView.image = UIImage(named: "cashback_small_blue_icon")
        self.cashbackIconImageView.contentMode = .scaleAspectFit
        
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
        self.middleOddTitleLabel.text = ""
        self.middleOddValueLabel.text = ""
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
        self.middleUpChangeOddValueImage.alpha = 0.0
        self.middleDownChangeOddValueImage.alpha = 0.0
        self.rightUpChangeOddValueImage.alpha = 0.0
        self.rightDownChangeOddValueImage.alpha = 0.0

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.marketSubscriber?.cancel()
        self.marketSubscriber = nil
        self.matchStatsSubscriber?.cancel()
        self.matchStatsSubscriber = nil

        self.currentLeftOddValue = nil
        self.currentMiddleOddValue = nil
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

        self.middleOddTitleLabel.textColor = UIColor.App.textPrimary
        self.middleOddValueLabel.textColor = UIColor.App.textPrimary

        self.rightOddTitleLabel.textColor = UIColor.App.textPrimary
        self.rightOddValueLabel.textColor = UIColor.App.textPrimary

        self.leftBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.middleBaseView.backgroundColor = UIColor.App.backgroundOdds
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
        
        if let matchStatsViewModel = self.matchStatsViewModel,
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
        if let outcome = market.outcomes[safe: 0] {
            self.leftOddTitleLabel.text = outcome.typeName
            self.leftOutcome = outcome

            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

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
                .sink(receiveCompletion: { completion in
                    
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
                .sink(receiveCompletion: { completion in
                    
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

//            self.rightOddButtonSubscriber = Env.servicesProvider
//                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
//                .compactMap({ $0 })
//                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: ))
//                .map(\.bettingOffer)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { completion in
//                }, receiveValue: { [weak self] bettingOffer in
//
//                    guard let weakSelf = self else { return }
//
//                    if !bettingOffer.isAvailable {
//                        weakSelf.rightBaseView.isUserInteractionEnabled = false
//                        weakSelf.rightBaseView.alpha = 0.5
//                        weakSelf.rightOddValueLabel.text = "-"
//                    }
//                    else {
//                        weakSelf.rightBaseView.isUserInteractionEnabled = true
//                        weakSelf.rightBaseView.alpha = 1.0
//
//                        let newOddValue = bettingOffer.decimalOdd
//
//
//                        if let currentOddValue = weakSelf.currentRightOddValue {
//                            if newOddValue > currentOddValue {
//                                weakSelf.highlightOddChangeUp(animated: true,
//                                                              upChangeOddValueImage: weakSelf.rightUpChangeOddValueImage,
//                                                              baseView: weakSelf.rightBaseView)
//                            }
//                            else if newOddValue < currentOddValue {
//                                weakSelf.highlightOddChangeDown(animated: true,
//                                                                downChangeOddValueImage: weakSelf.rightDownChangeOddValueImage,
//                                                                baseView: weakSelf.rightBaseView)
//                            }
//                        }
//
//                        weakSelf.currentRightOddValue = newOddValue
//                        weakSelf.rightOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
//                    }
//                })
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

    func selectRightOddButton() {
        self.rightBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.rightOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.rightOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
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

extension OddTripleCollectionViewCell {
    
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

            var homeWin: Int = 0
            var homeDraw: Int = 0
            var homeLoss: Int = 0
            var homeTotal: Int = 10

            var awayWin: Int = 0
            var awayDraw: Int = 0
            var awayLoss: Int = 0
            var awayTotal: Int = 10

            if let homeWinsValue = bettingTypeStats["home_participant"]?["Wins"].int,
               let homeDrawValue = bettingTypeStats["home_participant"]?["Draws"].int,
               let homeLossesValue = bettingTypeStats["home_participant"]?["Losses"].int,
               let awayWinsValue = bettingTypeStats["away_participant"]?["Wins"].int,
               let awayDrawValue = bettingTypeStats["away_participant"]?["Draws"].int,
               let awayLossesValue = bettingTypeStats["away_participant"]?["Losses"].int {

                homeWin = homeWinsValue
                homeDraw = homeDrawValue
                homeLoss = homeLossesValue
                homeTotal = homeWin + homeDraw + homeLoss

                awayWin = awayWinsValue
                awayDraw = awayDrawValue
                awayLoss = awayLossesValue
                awayTotal = awayWin + awayDraw + awayLoss

                self.marketNameLabel.font = AppFont.with(type: .bold, size: 12)

                let stackSubviews = self.marketStatsStackView.arrangedSubviews
                stackSubviews.forEach({
                    if $0 != self.marketNameLabel {
                        self.marketStatsStackView.removeArrangedSubview($0)
                        $0.removeFromSuperview()
                    }
                })
                
                let headToHeadCardStatsView = HeadToHeadCardStatsView()
                self.marketStatsStackView.addArrangedSubview(headToHeadCardStatsView)

                headToHeadCardStatsView.setupHomeValues(win: homeWin, draw: homeDraw, loss: homeLoss, total: homeTotal)
                headToHeadCardStatsView.setupAwayValues(win: awayWin, draw: awayDraw, loss: awayLoss, total: awayTotal)

                self.statsBaseView.isHidden = false
            }
        }
    }
}
