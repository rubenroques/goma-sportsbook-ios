//
//  OutcomeSelectionButtonView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import UIKit
import Combine
import ServicesProvider

class OutcomeSelectionButtonView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var marketTypeLabel: UILabel!
    @IBOutlet private var marketOddLabel: UILabel!

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var upChangeOddValueImage: UIImageView!
    @IBOutlet private weak var downChangeOddValueImage: UIImageView!

    var match: Match?
    var marketId: String?

    var competitionName: String?

    var outcome: Outcome?
    var bettingOffer: BettingOffer?

    var oddValue: Double?
    var isAvailableForBet: Bool?

    var didLongPressOdd: ((BettingTicket) -> Void)?

    private var isOutcomeButtonSelected: Bool = false {
        didSet {
            self.isOutcomeButtonSelected ? self.selectButton() : self.deselectButton()
        }
    }

    private var oddUpdatesPublisher: AnyCancellable?
    private var marketStateCancellable: AnyCancellable?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func commonInit() {

        self.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = .clear

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.marketTypeLabel.text = ""
        self.marketOddLabel.text = ""

        let tapOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapOddButton))
        self.containerView.addGestureRecognizer(tapOddButton)

        let longPressOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOddButton))
        self.containerView.addGestureRecognizer(longPressOddButton)

        self.setupWithTheme()
    }

    deinit {

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundOdds
        self.containerView.layer.cornerRadius = CornerRadius.button

        self.marketTypeLabel.textColor = UIColor.App.textPrimary
        self.marketTypeLabel.font = AppFont.with(type: .medium, size: 11)

        self.marketOddLabel.textColor = UIColor.App.textPrimary
        self.marketOddLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func configureWith(outcome: Outcome) {

        self.outcome = outcome
        self.bettingOffer = outcome.bettingOffer
        self.marketTypeLabel.text = outcome.translatedName

        self.isOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        // Check for SportRadar invalid odd
        if !outcome.bettingOffer.decimalOdd.isNaN {
            self.containerView.isUserInteractionEnabled = true
            self.containerView.alpha = 1.0
            self.marketOddLabel.text = OddConverter.stringForValue(outcome.bettingOffer.decimalOdd, format: UserDefaults.standard.userOddsFormat)
        }
        else {
            self.containerView.isUserInteractionEnabled = false
            self.containerView.alpha = 0.5
            self.marketOddLabel.text = "-"
        }

        if let marketId = outcome.marketId {
            self.marketStateCancellable?.cancel()
            self.marketStateCancellable = Env.servicesProvider.subscribeToEventMarketUpdates(withId: marketId)
                .compactMap({ $0 })
                .map({ (serviceProviderMarket: ServicesProvider.Market) -> Market in
                    return ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)
                })
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    print("marketSubscriber subscribeToEventMarketUpdates completion: \(completion)")
                }, receiveValue: { [weak self] (marketUpdated: Market) in

                    if marketUpdated.isAvailable {
                        self?.containerView.isUserInteractionEnabled = true
                        self?.containerView.alpha = 1.0
                        print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will show \n")
                    }
                    else {
                        self?.containerView.isUserInteractionEnabled = false
                        self?.containerView.alpha = 0.5
                        print("subscribeToEventMarketUpdates market \(marketUpdated.id)-\(marketUpdated.isAvailable) will hide \n")
                    }
                })
        }

        self.oddUpdatesPublisher = Env.servicesProvider
            .subscribeToEventOutcomeUpdates(withId: outcome.bettingOffer.id)
            .compactMap({ $0 })
            .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
            .map(\.bettingOffer)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("oddUpdatesPublisher subscribeToOutcomeUpdates completion: \(completion)")
            }, receiveValue: { [weak self] (updatedBettingOffer: BettingOffer) in
                guard let weakSelf = self else { return }

                print("oddUpdatesPublisher subscribeToOutcomeUpdates completion: \(updatedBettingOffer)")

                if !updatedBettingOffer.isAvailable || updatedBettingOffer.decimalOdd.isNaN {
                    weakSelf.containerView.isUserInteractionEnabled = false
                    weakSelf.containerView.alpha = 0.5
                    weakSelf.marketOddLabel.text = "-"
                }
                else {
                    weakSelf.containerView.isUserInteractionEnabled = true
                    weakSelf.containerView.alpha = 1.0

                    let newOddValue = updatedBettingOffer.decimalOdd

                    if let currentOddValue = weakSelf.oddValue {
                        if newOddValue > currentOddValue {
                            weakSelf.highlightOddChangeUp(animated: true,
                                                          upChangeOddValueImage: weakSelf.upChangeOddValueImage,
                                                          baseView: weakSelf.containerView)
                        }
                        else if newOddValue < currentOddValue {
                            weakSelf.highlightOddChangeDown(animated: true,
                                                            downChangeOddValueImage: weakSelf.downChangeOddValueImage,
                                                            baseView: weakSelf.containerView)
                        }
                    }
                    weakSelf.oddValue = newOddValue
                    weakSelf.marketOddLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                }
            })

    }

    func selectButton() {
        self.containerView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.marketOddLabel.textColor = UIColor.App.buttonTextPrimary
        self.marketTypeLabel.textColor = UIColor.App.buttonTextPrimary
    }
    
    func deselectButton() {
        self.containerView.backgroundColor = UIColor.App.backgroundOdds
        self.marketOddLabel.textColor = UIColor.App.textPrimary
        self.marketTypeLabel.textColor = UIColor.App.textPrimary
    }
    
    @objc func didTapOddButton() {

        guard
            let outcome = self.outcome,
            let marketId = self.marketId
        else {
            return
        }

        var bettingTicket: BettingTicket

        if let match = self.match {
            let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
            let marketDescription = outcome.marketName ?? ""
            let outcomeDescription = outcome.translatedName

            bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: marketId,
                                          matchId: match.id,
                                          isAvailable: outcome.bettingOffer.isAvailable,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription,
                                          odd: outcome.bettingOffer.odd)
        }
        else {
            let marketName = outcome.marketName ?? ""
            var matchDescription: String
            if let competitionName = self.competitionName {
                matchDescription = competitionName
            }
            else {
                matchDescription =  marketName.isNotEmpty ? "\(outcome.translatedName), \(marketName)" : "\(outcome.translatedName)"
            }
            let marketDescription = outcome.marketName ?? ""
            let outcomeDescription = outcome.translatedName

            bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: marketId,
                                          matchId: "",
                                          isAvailable: outcome.bettingOffer.isAvailable,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription,
                                          odd: outcome.bettingOffer.odd)
        }

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isOutcomeButtonSelected = true
        }
    }

    func blockOutcomeInteraction() {
        if self.isOutcomeButtonSelected {
            self.alpha = 1.0
            self.isUserInteractionEnabled = true
        }
        else {
            self.alpha = 0.25
            self.isUserInteractionEnabled = false
        }
    }
    
    @objc func didLongPressOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let outcome = self.outcome,
                let marketId = outcome.marketId
            else {
                return
            }

            var bettingTicket: BettingTicket

            if let match = self.match {
                let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
                let marketDescription = outcome.marketName ?? ""
                let outcomeDescription = outcome.translatedName

                bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                              outcomeId: outcome.id,
                                              marketId: marketId,
                                              matchId: match.id,
                                              isAvailable: outcome.bettingOffer.isAvailable,
                                              matchDescription: matchDescription,
                                              marketDescription: marketDescription,
                                              outcomeDescription: outcomeDescription,
                                              odd: outcome.bettingOffer.odd)
            }
            else {
                let marketName = outcome.marketName ?? ""
                var matchDescription: String
                if let competitionName = self.competitionName {
                    matchDescription = competitionName
                }
                else {
                    matchDescription =  marketName.isNotEmpty ? "\(outcome.translatedName), \(marketName)" : "\(outcome.translatedName)"
                }
                let marketDescription = outcome.marketName ?? ""
                let outcomeDescription = outcome.translatedName

                bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                              outcomeId: outcome.id,
                                              marketId: marketId,
                                              matchId: "",
                                              isAvailable: outcome.bettingOffer.isAvailable,
                                              matchDescription: matchDescription,
                                              marketDescription: marketDescription,
                                              outcomeDescription: outcomeDescription,
                                              odd: outcome.bettingOffer.odd)
            }

            self.didLongPressOdd?(bettingTicket)
        }
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
