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

    func setReloadedState(reloaded: Bool) {

        if let viewModel = self.viewModel {
            viewModel.reloadedState = reloaded
        }
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

            if !viewModel.reloadedState {
                self.needsReload.send()
            }

        }



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
