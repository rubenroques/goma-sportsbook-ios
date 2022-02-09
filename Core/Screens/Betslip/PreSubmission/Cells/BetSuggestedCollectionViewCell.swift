//
//  BetSuggestedCollectionViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 09/12/2021.
//

import UIKit
import Combine

class BetSuggestedCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var betsStackView: UIStackView!
    @IBOutlet private weak var competitionTitleLabel: UILabel!

    @IBOutlet private weak var infoBetLabelsView: UIView!
    @IBOutlet private weak var informationBetView: UIView!
    
    @IBOutlet private weak var numberOfSelectionsLabel: UILabel!
    @IBOutlet private weak var numberOfSelectionsValueLabel: UILabel!
    @IBOutlet private weak var totalOddLabel: UILabel!
    @IBOutlet private weak var totalOddValueLabel: UILabel!
    @IBOutlet private weak var betNowButton: UIButton!

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
        self.infoBetLabelsView.backgroundColor = UIColor.App.backgroundSecondary
        self.informationBetView.backgroundColor = UIColor.App.backgroundSecondary
        self.betNowButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
        
        self.totalOddValueLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.totalOddLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        self.totalOddLabel.textColor = UIColor.App.textSecond
        
        self.numberOfSelectionsLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.numberOfSelectionsValueLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.numberOfSelectionsValueLabel.textColor = UIColor.App.textPrimary
        self.numberOfSelectionsLabel.textColor = UIColor.App.textSecond
        
        self.betsStackView.removeAllArrangedSubviews()
        self.betsStackView.backgroundColor = UIColor.App.backgroundSecondary
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
                                          marketId: market.id,
                                          matchId: match.id,
                                          value: outcome.bettingOffer.value,
                                          isAvailable: outcome.bettingOffer.isAvailable,
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
