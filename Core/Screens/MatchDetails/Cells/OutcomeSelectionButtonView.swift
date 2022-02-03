//
//  OutcomeSelectionButtonView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import UIKit
import Combine

class OutcomeSelectionButtonView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var marketTypeLabel: UILabel!
    @IBOutlet private var marketOddLabel: UILabel!

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var upChangeOddValueImage: UIImageView!
    @IBOutlet private weak var downChangeOddValueImage: UIImageView!

    var match: Match?
    var marketId: String?
    var outcome: Outcome?
    var bettingOffer: BettingOffer?

    var oddValue: Double?
    var isAvailableForBet: Bool?

    var debouncerSubscription: Debouncer?

    private var isOutcomeButtonSelected: Bool = false {
        didSet {
            self.isOutcomeButtonSelected ? self.selectButton() : self.deselectButton()
        }
    }

    private var oddUpdatesPublisher: AnyCancellable?
    private var oddUpdatesRegister: EndpointPublisherIdentifiable?
    
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

        self.debouncerSubscription = Debouncer(timeInterval: 1, clearHandler: true)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = .clear

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.marketTypeLabel.text = ""
        self.marketOddLabel.text = ""

        let tapOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapOddButton))
        self.containerView.addGestureRecognizer(tapOddButton)

        self.setupWithTheme()
    }

    deinit {

        self.debouncerSubscription?.cancel()
        self.debouncerSubscription = nil

        if let oddUpdatesRegister = oddUpdatesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: oddUpdatesRegister)
        }
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

        self.updateBettingOffer(value: outcome.bettingOffer.value, isAvailableForBetting: true)

        self.isOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        let endpoint = TSRouter.bettingOfferPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      bettingOfferId: outcome.bettingOffer.id)

        self.debouncerSubscription?.handler = { [weak self] in
            print(" debouncerSubscription called ")
            self?.oddUpdatesPublisher = Env.everyMatrixClient.manager.registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        print("Error retrieving data!")
                    case .finished:
                        print("Data retrieved!")
                    }
                }, receiveValue: { [weak self] state in
                    switch state {
                    case .connect(let oddUpdatesRegister):
                        self?.oddUpdatesRegister = oddUpdatesRegister
                    case .initialContent(let aggregator):

                        if let content = aggregator.content {
                            for contentType in content {
                                if case let .bettingOffer(bettingOffer) = contentType, let oddsValue = bettingOffer.oddsValue {
                                    self?.oddValue =  nil
                                    self?.updateBettingOffer(value: oddsValue, isAvailableForBetting: true)
                                    break
                                }
                            }
                        }

                    case .updatedContent(let aggregatorUpdates):
                        if let content = aggregatorUpdates.contentUpdates {
                            for contentType in content {
                                if case let .bettingOfferUpdate(_, odd, _, isAvailable) = contentType {
                                    self?.updateBettingOffer(value: odd, isAvailableForBetting: isAvailable)
                                }
                            }
                        }

                    case .disconnect:
                        print("MarketDetailCell odd update - disconnect")
                    }
                })
        }

        self.debouncerSubscription?.call()

    }

    private func updateBettingOffer(value: Double?, isAvailableForBetting available: Bool?) {

        if let currentOddValue = self.oddValue, let newOddValue = value {
            if newOddValue > currentOddValue {
                self.highlightOddChangeUp(animated: true,
                                          upChangeOddValueImage: self.upChangeOddValueImage,
                                          baseView: self.containerView)
            }
            else if newOddValue < currentOddValue {
                self.highlightOddChangeDown(animated: true,
                                            downChangeOddValueImage: self.downChangeOddValueImage,
                                            baseView: self.containerView)
            }
        }

        let oddValue = (value ?? self.oddValue) ?? 0.0
        let isAvailable = (available ?? self.isAvailableForBet) ?? true

        self.oddValue = oddValue
        self.isAvailableForBet = isAvailable

        self.marketOddLabel.text = OddFormatter.formatOdd(withValue: oddValue)
        if isAvailable && OddFormatter.isValidOdd(withValue: oddValue) {
            self.isUserInteractionEnabled = true
            self.containerView.alpha = 1.0
        }
        else {
            self.isUserInteractionEnabled = false
            self.containerView.alpha = 0.4
            self.marketOddLabel.text = "-"
        }

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
            let match = self.match,
            let marketId = self.outcome?.marketId,
            let outcome = self.outcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = outcome.marketName ?? ""
        let outcomeDescription = outcome.translatedName

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: marketId,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          isAvailable: outcome.bettingOffer.isAvailable,
                                          matchDescription: matchDescription,
                                          marketDescription: marketDescription,
                                          outcomeDescription: outcomeDescription)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)
            self.isOutcomeButtonSelected = true
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
