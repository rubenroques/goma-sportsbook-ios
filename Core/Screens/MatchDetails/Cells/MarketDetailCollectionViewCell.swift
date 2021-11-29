//
//  MarketDetailCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/11/2021.
//

import UIKit

class MarketDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var marketTypeLabel: UILabel!
    @IBOutlet private var marketOddLabel: UILabel!

    var match: Match?
    var market: Market?
    var outcome: Outcome?
    var bettingOffer: BettingOffer?

    private var isOutcomeButtonSelected: Bool = false {
        didSet {
            self.isOutcomeButtonSelected ? self.selectButton() : self.deselectButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

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

        self.isOutcomeButtonSelected = false
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

        self.marketTypeLabel.text = outcome.translatedName
        self.marketOddLabel.text = "\(Double(floor(outcome.bettingOffer.value * 100)/100))"

        self.isOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

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

}
