//
//  BetSuggestedCollectionViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 09/12/2021.
//

import UIKit

class BetSuggestedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var betsStackView: UIStackView!
    @IBOutlet weak var competitionTitleLabel: UILabel!
   
   
    @IBOutlet weak var informationBetView: UIView!
    
    @IBOutlet weak var numberOfSelectionsLabel: UILabel!
    @IBOutlet weak var numberOfSelectionsValueLabel: UILabel!
    @IBOutlet weak var totalOddLabel: UILabel!
    @IBOutlet weak var totalOddValueLabel: UILabel!
    @IBOutlet weak var betNowButton: UIButton!

    var betsArray: [Match] = []
    var gomaArray: [GomaSuggestedBets] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupWithTheme()
        
        betNowButton.layer.cornerRadius = 4.0
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.betsStackView.removeAllArrangedSubviews()

    }
    
    func setupStackBetView(betValues: [Match], gomaValues: [GomaSuggestedBets]) {
     
        betsStackView.removeAllArrangedSubviews()

        var totalOdd = 0.0
        var firstOdd = true

        self.betsArray = betValues
        self.gomaArray = gomaValues
        
        for value in betValues {

            let gameTitle = "\(value.homeParticipant.name) x \(value.awayParticipant.name)"
            var gameMarket = ""

            if let marketName = value.markets.first?.name {
                gameMarket = marketName
            }
            print("GAME: \(value)")
            if let betOutcomes = value.markets.first?.outcomes {

                for betOutcome in betOutcomes {
                    for gomaBet in gomaValues {

                        if value.id == "\(gomaBet.matchId)" {
                            if betOutcome.codeName == gomaBet.bettingOption {

                                if firstOdd {
                                    totalOdd = betOutcome.bettingOffer.value
                                    firstOdd = false
                                }
                                else {
                                    totalOdd *= betOutcome.bettingOffer.value
                                }

                            }
                        }
                    }
                }
            }

            let gameInfo = "\(gameMarket)"

            let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)

            if let countryIsoCode = value.venue?.isoCode {
                gameSuggestedView.setMatchFlag(isoCode: countryIsoCode)
            }


            betsStackView.addArrangedSubview(gameSuggestedView)
        }
        
        self.setupInfoBetValues(totalOdd: totalOdd, numberOfSelection: betValues.count)
        
     }
    
    func setupInfoBetValues(totalOdd: Double, numberOfSelection: Int) {
        let formatedOdd = OddFormatter.formatOdd(withValue: totalOdd)
        totalOddValueLabel.text = "\(formatedOdd)"
        numberOfSelectionsValueLabel.text = "\(numberOfSelection)"

     }

    @IBAction func betNowAction() {

        for bet in betsArray {
            guard
                let firstMarket = bet.markets.first,
                let outcomes = bet.markets.first?.outcomes
            else {
                return
            }

                for outcome in outcomes {

                    for gomaBet in self.gomaArray {

                        if bet.id == "\(gomaBet.matchId)" {

                            if outcome.codeName == gomaBet.bettingOption {
                                let matchDescription = "\(bet.homeParticipant.name) x \(bet.awayParticipant.name)"
                                let marketDescription = firstMarket.name
                                let outcomeDescription = outcome.translatedName

                                let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                                                  outcomeId: outcome.id,
                                                                  matchId: bet.id,
                                                                  value: outcome.bettingOffer.value,
                                                                  matchDescription: matchDescription,
                                                                  marketDescription: marketDescription,
                                                                  outcomeDescription: outcomeDescription)


                                Env.betslipManager.addBettingTicket(bettingTicket)
                            }

                        }
                    }

                }
//            if let outcome = bet.markets.first?.outcomes[0] {
//                let matchDescription = "\(bet.homeParticipant.name) x \(bet.awayParticipant.name)"
//                let marketDescription = firstMarket.name
//                let outcomeDescription = outcome.translatedName
//
//                let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
//                                                  outcomeId: outcome.id,
//                                                  matchId: bet.id,
//                                                  value: outcome.bettingOffer.value,
//                                                  matchDescription: matchDescription,
//                                                  marketDescription: marketDescription,
//                                                  outcomeDescription: outcomeDescription)
//
//
//                Env.betslipManager.addBettingTicket(bettingTicket)
//            }

        }

    }

}
