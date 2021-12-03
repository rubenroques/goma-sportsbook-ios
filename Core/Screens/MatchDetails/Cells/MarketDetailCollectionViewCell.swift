//
//  MarketDetailCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/11/2021.
//

import UIKit
import Combine

class MarketDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var marketTypeLabel: UILabel!
    @IBOutlet private var marketOddLabel: UILabel!

    @IBOutlet weak var upChangeOddValueImage: UIImageView!
    @IBOutlet weak var downChangeOddValueImage: UIImageView!

    var match: Match?
    var market: Market?
    var outcome: Outcome?
    var bettingOffer: BettingOffer?

    var oddValue: Double?
    var isAvailableForBet: Bool?

    private var isOutcomeButtonSelected: Bool = false {
        didSet {
            self.isOutcomeButtonSelected ? self.selectButton() : self.deselectButton()
        }
    }

    private var oddUpdatesPublisher: AnyCancellable?
    private var oddUpdatesRegister: EndpointPublisherIdentifiable?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.marketTypeLabel.text = ""
        self.marketOddLabel.text = ""

        let tapOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapOddButton))
        self.containerView.addGestureRecognizer(tapOddButton)


        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.marketTypeLabel.text = ""
        self.marketOddLabel.text = ""

        self.match = nil
        self.market = nil
        self.outcome = nil
        self.bettingOffer = nil

        self.oddValue = nil
        self.isAvailableForBet = nil

        self.oddUpdatesPublisher?.cancel()
        self.oddUpdatesPublisher = nil

        if let oddUpdatesRegister = oddUpdatesRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: oddUpdatesRegister)
        }

        self.isOutcomeButtonSelected = false

        self.isUserInteractionEnabled = true
        self.containerView.alpha = 1.0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.tertiaryBackground
        self.containerView.layer.cornerRadius = CornerRadius.button

        self.marketTypeLabel.textColor = UIColor.App.headingMain
        self.marketTypeLabel.font = AppFont.with(type: .medium, size: 11)

        self.marketOddLabel.textColor = UIColor.App.headingMain
        self.marketOddLabel.font = AppFont.with(type: .bold, size: 13)
    }

    func configureWith(outcome: Outcome) {

        self.outcome = outcome
        self.bettingOffer = outcome.bettingOffer

        self.marketTypeLabel.text = outcome.typeName

        self.updateBettingOffer(value: outcome.bettingOffer.value, isAvailableForBetting: true)

        self.isOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

        let endpoint = TSRouter.bettingOfferPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      bettingOfferId: outcome.bettingOffer.id)

        self.oddUpdatesPublisher = TSManager.shared.registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
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
                    ()
                }
            })
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
        self.containerView.backgroundColor = UIColor.App.mainTint
    }
    func deselectButton() {
        self.containerView.backgroundColor = UIColor.App.tertiaryBackground
    }
    @objc func didTapOddButton() {

        guard
            let match = self.match,
            let market = self.market,
            let outcome = self.outcome
        else {
            return
        }

        let matchDescription = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"
        let marketDescription = market.name
        let outcomeDescription = outcome.translatedName

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
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
