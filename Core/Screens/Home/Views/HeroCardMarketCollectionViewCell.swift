//
//  HeroCardMarketCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 02/08/2024.
//

import UIKit
import Combine
import ServicesProvider

class HeroCardMarketCollectionViewCell: UICollectionViewCell {
    
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var homeTeamLabel: UILabel = Self.createHomeTeamLabel()
    private lazy var awayTeamLabel: UILabel = Self.createAwayTeamLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var timeLabel: UILabel = Self.createTimeLabel()
    private lazy var marketNamePillLabelView: PillLabelView = Self.createMarketPillLabelView()
    private lazy var oddsStackView: UIStackView = Self.createOddsStackView()
    private lazy var homeBaseView: UIView = Self.createHomeBaseView()
    private lazy var homeOddBaseView: UIView = Self.createHomeOddBaseView()
    private lazy var homeOddTitleLabel: UILabel = Self.createHomeOddTitleLabel()
    private lazy var homeOddValueLabel: UILabel = Self.createHomeOddValueLabel()
    private lazy var drawBaseView: UIView = Self.createDrawBaseView()
    private lazy var drawOddBaseView: UIView = Self.createDrawOddBaseView()
    private lazy var drawOddTitleLabel: UILabel = Self.createDrawOddTitleLabel()
    private lazy var drawOddValueLabel: UILabel = Self.createDrawOddValueLabel()
    private lazy var awayBaseView: UIView = Self.createAwayBaseView()
    private lazy var awayOddBaseView: UIView = Self.createAwayOddBaseView()
    private lazy var awayOddTitleLabel: UILabel = Self.createAwayOddTitleLabel()
    private lazy var awayOddValueLabel: UILabel = Self.createAwayOddValueLabel()
    
    private lazy var homeUpChangeOddValueImageView: UIImageView = Self.createHomeUpChangeOddValueImageView()
    private lazy var homeDownChangeOddValueImageView: UIImageView = Self.createHomeDownChangeOddValueImageView()
    private lazy var drawUpChangeOddValueImageView: UIImageView = Self.createDrawUpChangeOddValueImageView()
    private lazy var drawDownChangeOddValueImageView: UIImageView = Self.createDrawDownChangeOddValueImageView()
    private lazy var awayUpChangeOddValueImageView: UIImageView = Self.createAwayUpChangeOddValueImageView()
    private lazy var awayDownChangeOddValueImageView: UIImageView = Self.createAwayDownChangeOddValueImageView()
    
    private var match: Match? = nil
    private var market: Market? = nil
    
    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?
    
    private var currentHomeOddValue: Double?
    private var currentDrawOddValue: Double?
    private var currentAwayOddValue: Double?
    
    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?
    
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
    
    var selectedOutcome: ((Match, Market, Outcome) -> Void)?
    var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Actions
    var didLongPressOdd: ((BettingTicket) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.cancellables.removeAll()

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil
        
        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil
    }

    private func commonInit() {

        self.setupSubviews()
        self.setupWithTheme()
        
        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)
        
        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeBaseView.addGestureRecognizer(longPressLeftOddButton)
        
        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)
        
        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(longPressMiddleOddButton)
        
        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)
        
        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayBaseView.addGestureRecognizer(longPressRightOddButton)
        
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] bettingTicket in

                self?.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: self?.leftOutcome?.id ?? "")

                self?.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: self?.middleOutcome?.id ?? "")

                self?.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: self?.rightOutcome?.id ?? "")

            }
            .store(in: &cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.homeBaseView.layer.cornerRadius = 4.5
        self.drawBaseView.layer.cornerRadius = 4.5
        self.awayBaseView.layer.cornerRadius = 4.5
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.contentView.backgroundColor = .clear
        
        self.baseView.backgroundColor = .clear

        self.homeTeamLabel.textColor = UIColor.App.textHeroCard
        
        self.awayTeamLabel.textColor = UIColor.App.textHeroCard
        
        self.dateLabel.textColor = UIColor.App.textSecondaryHeroCard
        
        self.timeLabel.textColor = UIColor.App.textSecondaryHeroCard
        
        self.marketNamePillLabelView.setupWithTheme(withBorderColor: UIColor.App.highlightPrimary, withTextColor: UIColor.App.textHeroCard)

        self.oddsStackView.backgroundColor = .clear
        
        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
        
        self.homeOddBaseView.backgroundColor = .clear
        self.drawOddBaseView.backgroundColor = .clear
        self.awayOddBaseView.backgroundColor = .clear

        if isLeftOutcomeButtonSelected {
            self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
            self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        }
        
        if isMiddleOutcomeButtonSelected {
            self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
            self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        }
        
        if isRightOutcomeButtonSelected {
            self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
            self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        }
    }
    
    func configure(market: Market, match: Match) {
        self.match = match
        self.market = market
        
        self.homeTeamLabel.text = market.homeParticipant ?? ""
        
        self.awayTeamLabel.text = market.awayParticipant ?? ""
        
        if let date = match.date {
            self.dateLabel.text = MatchWidgetCellViewModel.startDateString(fromDate: date)
            self.timeLabel.text = MatchWidgetCellViewModel.hourDateFormatter.string(from: date)
        }
        
        self.marketNamePillLabelView.title = market.name
        
        self.configureOutcomes(withMarket: market)
    }
    
    private func configureOutcomes(withMarket market: Market) {
        
        if let outcome = market.outcomes[safe: 0] {
            
            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.homeOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.homeOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.homeOddTitleLabel.text = outcome.typeName
            }
            
            self.leftOutcome = outcome
            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.homeBaseView.isUserInteractionEnabled = false
                self.homeBaseView.alpha = 0.5
                self.setHomeOddValueLabel(toText: "-")
            }
            
            self.leftOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
//                .compactMap({ $0 })
//                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
//                .handleEvents(receiveOutput: { [weak self] outcome in
//                    self?.leftOutcome = outcome
//                })
//                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("leftOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")

                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.homeBaseView.isUserInteractionEnabled = false
                        weakSelf.homeBaseView.alpha = 0.5
                        weakSelf.setHomeOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.homeBaseView.isUserInteractionEnabled = true
                        weakSelf.homeBaseView.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        
                        if let currentOddValue = weakSelf.currentHomeOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.homeUpChangeOddValueImageView,
                                                              baseView: weakSelf.homeBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.homeDownChangeOddValueImageView,
                                                                baseView: weakSelf.homeBaseView)
                            }
                        }
                        weakSelf.currentHomeOddValue = newOddValue
                        weakSelf.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
            
        }
        
        if let outcome = market.outcomes[safe: 1] {
            
            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.drawOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.drawOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.drawOddTitleLabel.text = outcome.typeName
            }
            
            self.middleOutcome = outcome
            self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.drawBaseView.isUserInteractionEnabled = false
                self.drawBaseView.alpha = 0.5
                self.setDrawOddValueLabel(toText: "-")
            }
            
            self.middleOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
//                .compactMap({ $0 })
//                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
//                .handleEvents(receiveOutput: { [weak self] outcome in
//                    self?.middleOutcome = outcome
//                })
//                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("middleOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.drawBaseView.isUserInteractionEnabled = false
                        weakSelf.drawBaseView.alpha = 0.5
                        weakSelf.setDrawOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.drawBaseView.isUserInteractionEnabled = true
                        weakSelf.drawBaseView.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentDrawOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.drawUpChangeOddValueImageView,
                                                              baseView: weakSelf.drawBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.drawDownChangeOddValueImageView,
                                                                baseView: weakSelf.drawBaseView)
                            }
                        }
                        weakSelf.currentDrawOddValue = newOddValue
                        weakSelf.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }
        
        if let outcome = market.outcomes[safe: 2] {
            
            if let nameDigit1 = market.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.awayOddTitleLabel.text = outcome.typeName
                }
                else {
                    self.awayOddTitleLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.awayOddTitleLabel.text = outcome.typeName
            }
            
            self.rightOutcome = outcome
            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN {
                self.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.awayBaseView.isUserInteractionEnabled = false
                self.awayBaseView.alpha = 0.5
                self.setAwayOddValueLabel(toText: "-")
            }
            
            self.rightOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
//                .compactMap({ $0 })
//                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
//                .handleEvents(receiveOutput: { [weak self] outcome in
//                    self?.rightOutcome = outcome
//                })
//                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("rightOddButtonSubscriber subscribeToOutcomeUpdates completion: \(completion)")
                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.awayBaseView.isUserInteractionEnabled = false
                        weakSelf.awayBaseView.alpha = 0.5
                        weakSelf.setAwayOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.awayBaseView.isUserInteractionEnabled = true
                        weakSelf.awayBaseView.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentAwayOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.awayUpChangeOddValueImageView,
                                                              baseView: weakSelf.awayBaseView)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.awayDownChangeOddValueImageView,
                                                                baseView: weakSelf.awayBaseView)
                            }
                        }
                        
                        weakSelf.currentAwayOddValue = newOddValue
                        weakSelf.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
            
        }
        
        if market.outcomes.count == 3 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = false
        }
        else if market.outcomes.count == 2 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = false
            self.awayBaseView.isHidden = true
        }
        else if market.outcomes.count == 1 {
            self.homeBaseView.isHidden = false
            self.drawBaseView.isHidden = true
            self.awayBaseView.isHidden = true
        }
    }
    
    //
    // Odd buttons interaction
    //
    func selectLeftOddButton() {
        self.setupWithTheme()
    }

    func deselectLeftOddButton() {
        self.setupWithTheme()
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
            
            self.unselectedOutcome?(match, market, outcome)
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            self.isLeftOutcomeButtonSelected = true
            
            self.selectedOutcome?(match, market, outcome)
        }

    }

    @objc func didLongPressLeftOddButton(_ sender: UILongPressGestureRecognizer) {

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

    //
    func selectMiddleOddButton() {
        
        self.setupWithTheme()
    }

    func deselectMiddleOddButton() {
        
        self.setupWithTheme()
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

    //
    func selectRightOddButton() {
        self.setupWithTheme()
    }

    func deselectRightOddButton() {
        self.setupWithTheme()
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
    
    // Odd values
    private func setHomeOddValueLabel(toText text: String) {
        self.homeOddValueLabel.text = text
    }

    private func setDrawOddValueLabel(toText text: String) {
        self.drawOddValueLabel.text = text
    }

    private func setAwayOddValueLabel(toText text: String) {
        self.awayOddValueLabel.text = text
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
}

extension HeroCardMarketCollectionViewCell {
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHomeTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }
    
    private static func createAwayTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .right
        return label
    }
    
    private static func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .right
        return label
    }
    
    private static func createMarketPillLabelView() -> PillLabelView {
        var marketNamePillLabelView = PillLabelView()
        marketNamePillLabelView.translatesAutoresizingMaskIntoConstraints = false
        return marketNamePillLabelView
    }
    
    private static func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private static func createHomeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.isUserInteractionEnabled = true
        return view
    }
    
    private static func createHomeOddBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createHomeOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .center
        return label
    }
    
    private static func createHomeOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }
    
    private static func createDrawBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.isUserInteractionEnabled = true
        return view
    }
    
    private static func createDrawOddBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDrawOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .center
        return label
    }
    
    private static func createDrawOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }
    
    private static func createAwayBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.isUserInteractionEnabled = true
        return view
    }
    
    private static func createAwayOddBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAwayOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .center
        return label
    }
    
    private static func createAwayOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }
    
    private static func createHomeUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private static func createHomeDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private static func createDrawUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private static func createDrawDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private static func createAwayUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private static func createAwayDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)
        
        self.baseView.addSubview(self.homeTeamLabel)
        self.baseView.addSubview(self.awayTeamLabel)
        
        self.baseView.addSubview(self.dateLabel)
        self.baseView.addSubview(self.timeLabel)
        
        self.baseView.addSubview(self.marketNamePillLabelView)
        
        self.baseView.addSubview(self.oddsStackView)

        self.oddsStackView.addArrangedSubview(self.homeBaseView)
        self.oddsStackView.addArrangedSubview(self.drawBaseView)
        self.oddsStackView.addArrangedSubview(self.awayBaseView)
        
        self.homeBaseView.addSubview(self.homeOddBaseView)
        
        self.homeOddBaseView.addSubview(self.homeOddTitleLabel)
        self.homeOddBaseView.addSubview(self.homeOddValueLabel)
        
        self.homeBaseView.addSubview(self.homeUpChangeOddValueImageView)
        self.homeBaseView.addSubview(self.homeDownChangeOddValueImageView)
        
        self.drawBaseView.addSubview(self.drawOddBaseView)

        self.drawOddBaseView.addSubview(self.drawOddTitleLabel)
        self.drawOddBaseView.addSubview(self.drawOddValueLabel)
        
        self.drawBaseView.addSubview(self.drawUpChangeOddValueImageView)
        self.drawBaseView.addSubview(self.drawDownChangeOddValueImageView)
        
        self.awayBaseView.addSubview(self.awayOddBaseView)

        self.awayOddBaseView.addSubview(self.awayOddTitleLabel)
        self.awayOddBaseView.addSubview(self.awayOddValueLabel)
        
        self.awayBaseView.addSubview(self.awayUpChangeOddValueImageView)
        self.awayBaseView.addSubview(self.awayDownChangeOddValueImageView)
        
        self.initConstraints()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.baseView.heightAnchor.constraint(equalToConstant: 110),
            
            self.homeTeamLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 2),
            self.homeTeamLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 10),
            self.homeTeamLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -50),
            
            self.awayTeamLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 2),
            self.awayTeamLabel.topAnchor.constraint(equalTo: self.homeTeamLabel.bottomAnchor, constant: 5),
            self.awayTeamLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -50),
            
            self.dateLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -2),
            self.dateLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 10),
            
            self.timeLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -2),
            self.timeLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 5),
            
            self.marketNamePillLabelView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 2),
            self.marketNamePillLabelView.topAnchor.constraint(equalTo: self.awayTeamLabel.bottomAnchor, constant: 5),
            
            self.oddsStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 2),
            self.oddsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -2),
            self.oddsStackView.topAnchor.constraint(greaterThanOrEqualTo: self.marketNamePillLabelView.bottomAnchor, constant: 10),
            self.oddsStackView.heightAnchor.constraint(equalToConstant: 40),
            self.oddsStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -5),
            
            self.homeOddBaseView.leadingAnchor.constraint(equalTo: self.homeBaseView.leadingAnchor, constant: 5),
            self.homeOddBaseView.trailingAnchor.constraint(equalTo: self.homeBaseView.trailingAnchor, constant: -5),
            self.homeOddBaseView.centerYAnchor.constraint(equalTo: self.homeBaseView.centerYAnchor),
            
            self.homeOddTitleLabel.leadingAnchor.constraint(equalTo: self.homeOddBaseView.leadingAnchor, constant: 5),
            self.homeOddTitleLabel.trailingAnchor.constraint(equalTo: self.homeOddBaseView.trailingAnchor, constant: -5),
            self.homeOddTitleLabel.topAnchor.constraint(equalTo: self.homeOddBaseView.topAnchor, constant: 0),
            
            self.homeOddValueLabel.leadingAnchor.constraint(equalTo: self.homeOddBaseView.leadingAnchor, constant: 5),
            self.homeOddValueLabel.trailingAnchor.constraint(equalTo: self.homeOddBaseView.trailingAnchor, constant: -5),
            self.homeOddValueLabel.topAnchor.constraint(equalTo: self.homeOddTitleLabel.bottomAnchor, constant: 5),
            self.homeOddValueLabel.bottomAnchor.constraint(equalTo: self.homeOddBaseView.bottomAnchor, constant: 0),
            
            self.homeUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.homeUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.homeUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.homeBaseView.centerYAnchor),
            self.homeUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.homeBaseView.trailingAnchor, constant: -5),
            
            self.homeDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.homeDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.homeDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.homeBaseView.centerYAnchor),
            self.homeDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.homeBaseView.trailingAnchor, constant: -5),
            
            self.drawOddBaseView.leadingAnchor.constraint(equalTo: self.drawBaseView.leadingAnchor, constant: 5),
            self.drawOddBaseView.trailingAnchor.constraint(equalTo: self.drawBaseView.trailingAnchor, constant: -5),
            self.drawOddBaseView.centerYAnchor.constraint(equalTo: self.drawBaseView.centerYAnchor),
            
            self.drawOddTitleLabel.leadingAnchor.constraint(equalTo: self.drawOddBaseView.leadingAnchor, constant: 5),
            self.drawOddTitleLabel.trailingAnchor.constraint(equalTo: self.drawOddBaseView.trailingAnchor, constant: -5),
            self.drawOddTitleLabel.topAnchor.constraint(equalTo: self.drawOddBaseView.topAnchor, constant: 0),
            
            self.drawOddValueLabel.leadingAnchor.constraint(equalTo: self.drawOddBaseView.leadingAnchor, constant: 5),
            self.drawOddValueLabel.trailingAnchor.constraint(equalTo: self.drawOddBaseView.trailingAnchor, constant: -5),
            self.drawOddValueLabel.topAnchor.constraint(equalTo: self.drawOddTitleLabel.bottomAnchor, constant: 5),
            self.drawOddValueLabel.bottomAnchor.constraint(equalTo: self.homeOddBaseView.bottomAnchor, constant: 0),
            
            self.drawUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.drawUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.drawUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.drawBaseView.centerYAnchor),
            self.drawUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.drawBaseView.trailingAnchor, constant: -5),
            
            self.drawDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.drawDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.drawDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.drawBaseView.centerYAnchor),
            self.drawDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.drawBaseView.trailingAnchor, constant: -5),
            
            self.awayOddBaseView.leadingAnchor.constraint(equalTo: self.awayBaseView.leadingAnchor, constant: 5),
            self.awayOddBaseView.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor, constant: -5),
            self.awayOddBaseView.centerYAnchor.constraint(equalTo: self.awayBaseView.centerYAnchor),
            
            self.awayOddTitleLabel.leadingAnchor.constraint(equalTo: self.awayOddBaseView.leadingAnchor, constant: 5),
            self.awayOddTitleLabel.trailingAnchor.constraint(equalTo: self.awayOddBaseView.trailingAnchor, constant: -5),
            self.awayOddTitleLabel.topAnchor.constraint(equalTo: self.awayOddBaseView.topAnchor, constant: 0),
            
            self.awayOddValueLabel.leadingAnchor.constraint(equalTo: self.awayOddBaseView.leadingAnchor, constant: 5),
            self.awayOddValueLabel.trailingAnchor.constraint(equalTo: self.awayOddBaseView.trailingAnchor, constant: -5),
            self.awayOddValueLabel.topAnchor.constraint(equalTo: self.awayOddTitleLabel.bottomAnchor, constant: 5),
            self.awayOddValueLabel.bottomAnchor.constraint(equalTo: self.awayOddBaseView.bottomAnchor, constant: 0),
            
            self.awayUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.awayUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.awayUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayBaseView.centerYAnchor),
            self.awayUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor, constant: -5),
            
            self.awayDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.awayDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.awayDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayBaseView.centerYAnchor),
            self.awayDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayBaseView.trailingAnchor, constant: -5)
        ])
    }
    
    static var hourDateFormatter: DateFormatter = {
           var dateFormatter = DateFormatter()
           dateFormatter.timeStyle = .short
           dateFormatter.dateStyle = .none
           return dateFormatter
       }()
    
    static var dayDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
}

