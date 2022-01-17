//
//  BetSuggestedCollectionViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 09/12/2021.
//

import UIKit
import Combine

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

    var betNowCallbackAction: (() -> Void)?
    var viewModel: BetSuggestedCollectionViewCellViewModel?
    var cancellables = Set<AnyCancellable>()
    var needsReload: PassthroughSubject<Void, Never> = .init()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupWithTheme()
        betNowButton.layer.cornerRadius = 5.0
        layer.cornerRadius = 5.0
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
        
    }

    func setupWithViewModel(viewModel: BetSuggestedCollectionViewCellViewModel) {
        self.viewModel = viewModel

        self.viewModel?.isViewModelFinishedLoading
            .sink(receiveValue: { [weak self] value in
                if value {
                    self?.setupStackBetView()
                }
            })
            .store(in: &cancellables)
    }
    
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.betsStackView.removeAllArrangedSubviews()
       
    }

    func setupStackBetView() {
        betsStackView.removeAllArrangedSubviews()

        if let viewModel = self.viewModel {

            for gameSuggestedView in viewModel.gameSuggestedViewsArray {
                betsStackView.addArrangedSubview(gameSuggestedView)
            }

            self.setupInfoBetValues(totalOdd: viewModel.totalOdd, numberOfSelection: viewModel.numberOfSelection)

            self.betslipTickets = viewModel.betslipTickets

            self.needsReload.send()
        }

    }
    
    func setupStackBetView2(betValues: [Match], gomaValues: [GomaSuggestedBets]) {
     
        betsStackView.removeAllArrangedSubviews()

        var totalOdd = 0.0
        var firstOdd = true

        self.betsArray = betValues
        self.gomaArray = gomaValues

        var validMarkets = 0

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

                                    self.addOutcomeToTicketArray(match: match, market: market, outcome: betOutcome)
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
                                    gameSuggestedView.frame.size.height = 60
                                    
                                    betsStackView.addArrangedSubview(gameSuggestedView)

                                    self.addOutcomeToTicketArray(match: match, market: market, outcome: betOutcome)
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

    func addOutcomeToTicketArray(match: Match, market: Market, outcome: Outcome) {
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
        self.betslipTickets.append(bettingTicket)
    }

    @IBAction private func betNowAction() {

        for ticket in self.betslipTickets {
            Env.betslipManager.addBettingTicket(ticket)
        }

        self.betNowCallbackAction?()

    }

}
