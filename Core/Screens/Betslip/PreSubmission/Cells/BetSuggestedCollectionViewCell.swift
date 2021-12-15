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
    var betslipTickets: [BettingTicket] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupWithTheme()
        betNowButton.layer.cornerRadius = 4.0
        layer.cornerRadius = 4.0
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

        var validMarkets = 0
        
//        for value in betValues {
//
//            let gameTitle = "\(value.homeParticipant.name) x \(value.awayParticipant.name)"
//            var gameMarket = ""
//
//            if let marketName = value.markets.first?.name {
//                gameMarket = marketName
//            }
//            print("GAME: \(value)")
//            if let betOutcomes = value.markets.first?.outcomes {
//                var foundOutcome = false
//
//                for betOutcome in betOutcomes {
//                    for gomaBet in gomaValues {
//
//                        if value.id == "\(gomaBet.matchId)" {
//
//                            if betOutcome.codeName == gomaBet.bettingOption {
//
//                                if firstOdd {
//                                    totalOdd = betOutcome.bettingOffer.value
//                                    firstOdd = false
//                                }
//                                else {
//                                    totalOdd *= betOutcome.bettingOffer.value
//                                }
//                                foundOutcome = true
//
//                            }
//
//                        }
//                    }
//
//                }
//                if !foundOutcome {
//                    if firstOdd {
//                        totalOdd = betOutcomes[0].bettingOffer.value
//                        firstOdd = false
//                    }
//                    else {
//                        totalOdd *= betOutcomes[0].bettingOffer.value
//                    }
//                }
//            }
//
//            let gameInfo = "\(gameMarket)"
//
//            let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)
//
//            if let countryIsoCode = value.venue?.isoCode {
//                gameSuggestedView.setMatchFlag(isoCode: countryIsoCode)
//            }
//
//            betsStackView.addArrangedSubview(gameSuggestedView)
//        }

        for gomaBet in gomaArray {

            for match in betsArray {

                if match.id == "\(gomaBet.matchId)" {

                    // Regular market
                    if gomaBet.paramFloat == nil {
                        let gameTitle = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"

                        for market in match.markets {

                            for betOutcome in market.outcomes {

                                if betOutcome.codeName == gomaBet.bettingOption && market.typeId == "\(gomaBet.bettingType)" {

                                    if firstOdd {
                                        totalOdd = betOutcome.bettingOffer.value
                                        firstOdd = false
                                    }
                                    else {
                                        totalOdd *= betOutcome.bettingOffer.value
                                    }

                                    let gameInfo = "\(market.name)"

                                    let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)

                                    if let countryIsoCode = match.venue?.isoCode {
                                        gameSuggestedView.setMatchFlag(isoCode: countryIsoCode)
                                    }

                                    validMarkets += 1

                                    betsStackView.addArrangedSubview(gameSuggestedView)
                                }
                            }

                        }

                    }
                    // Over/Under Market
                    else {
                        let gameTitle = "\(match.homeParticipant.name) x \(match.awayParticipant.name)"

                        for market in match.markets {

                            for betOutcome in market.outcomes {

                                var nameOddString = ""

                                if let nameOdd = betOutcome.nameDigit1 {
                                    nameOddString = "\(nameOdd)"
                                }

                                let nameOddGoma = gomaBet.paramFloat

                                if betOutcome.codeName == gomaBet.bettingOption && nameOddString == nameOddGoma {

                                    if firstOdd {
                                        totalOdd = betOutcome.bettingOffer.value
                                        firstOdd = false
                                    }
                                    else {
                                        totalOdd *= betOutcome.bettingOffer.value
                                    }

                                    let gameInfo = "\(market.name)"

                                    let gameSuggestedView = GameSuggestedView(gameTitle: gameTitle, gameInfo: gameInfo)

                                    if let countryIsoCode = match.venue?.isoCode {
                                        gameSuggestedView.setMatchFlag(isoCode: countryIsoCode)
                                    }

                                    validMarkets += 1

                                    betsStackView.addArrangedSubview(gameSuggestedView)
                                }
                            }

                        }
                    }
                }

            }
        }

        self.setupInfoBetValues(totalOdd: totalOdd, numberOfSelection: validMarkets)
        
     }
    
    func setupInfoBetValues(totalOdd: Double, numberOfSelection: Int) {
        let formatedOdd = OddFormatter.formatOdd(withValue: totalOdd)
        totalOddValueLabel.text = "\(formatedOdd)"
        numberOfSelectionsValueLabel.text = "\(numberOfSelection)"

     }

    func 

    @IBAction private func betNowAction() {

//        var foundOutcome = false
//
//        for bet in betsArray {
//            guard
//                let firstMarket = bet.markets.first,
//                let outcomes = bet.markets.first?.outcomes
//            else {
//                return
//            }
//
//            for outcome in outcomes {
//
//                for gomaBet in self.gomaArray {
//
//                    if bet.id == "\(gomaBet.matchId)" {
//
//                        if outcome.codeName == gomaBet.bettingOption {
//                            let matchDescription = "\(bet.homeParticipant.name) x \(bet.awayParticipant.name)"
//                            let marketDescription = firstMarket.name
//                            let outcomeDescription = outcome.translatedName
//
//                            let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
//                                                              outcomeId: outcome.id,
//                                                              matchId: bet.id,
//                                                              value: outcome.bettingOffer.value,
//                                                              matchDescription: matchDescription,
//                                                              marketDescription: marketDescription,
//                                                              outcomeDescription: outcomeDescription)
//
//                            Env.betslipManager.addBettingTicket(bettingTicket)
//                            foundOutcome = true
//                        }
//                    }
//                }
//
//            }
//            if !foundOutcome {
//                let matchDescription = "\(bet.homeParticipant.name) x \(bet.awayParticipant.name)"
//                let marketDescription = firstMarket.name
//                let outcomeDescription = outcomes[0].translatedName
//
//                let bettingTicket = BettingTicket(id: outcomes[0].bettingOffer.id,
//                                                  outcomeId: outcomes[0].id,
//                                                  matchId: bet.id,
//                                                  value: outcomes[0].bettingOffer.value,
//                                                  matchDescription: matchDescription,
//                                                  marketDescription: marketDescription,
//                                                  outcomeDescription: outcomeDescription)
//
//                Env.betslipManager.addBettingTicket(bettingTicket)
//                foundOutcome = true
//            }
//
//        }

    }

}
