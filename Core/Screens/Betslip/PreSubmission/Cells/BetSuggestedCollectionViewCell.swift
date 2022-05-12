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

    var viewModel: SuggestedBetViewModel?
    var cancellables = Set<AnyCancellable>()
    var needsReload: PassthroughSubject<Void, Never> = .init()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.totalOddValueLabel.text = ""
        self.numberOfSelectionsValueLabel.text = ""

        self.setupWithTheme()

        self.betNowButton.layer.cornerRadius = 5
        self.layer.cornerRadius = 9
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.betsStackView.removeAllArrangedSubviews()
        self.totalOddValueLabel.text = ""
        self.numberOfSelectionsValueLabel.text = ""

        self.viewModel = nil

    }

    func setReloadedState(reloaded: Bool) {
        if let viewModel = self.viewModel {
            viewModel.reloadedState = reloaded
        }
    }

    func setupWithViewModel(viewModel: SuggestedBetViewModel) {
        self.viewModel = viewModel

        self.viewModel?.isViewModelFinishedLoading
            .receive(on: DispatchQueue.main)
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
        self.betNowButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.totalOddValueLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.totalOddLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        self.totalOddLabel.textColor = UIColor.App.textSecondary
        
        self.numberOfSelectionsLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.numberOfSelectionsValueLabel.backgroundColor = UIColor.App.backgroundSecondary
        self.numberOfSelectionsValueLabel.textColor = UIColor.App.textPrimary
        self.numberOfSelectionsLabel.textColor = UIColor.App.textSecondary
        
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
        let formatedOdd = OddConverter.stringForValue(totalOdd, format: UserDefaults.standard.userOddsFormat)
        totalOddValueLabel.text = "\(formatedOdd)"
        numberOfSelectionsValueLabel.text = "\(numberOfSelection)"
     }

    func addOutcomeToTicketArray(match: Match, market: Market, outcome: Outcome) {
        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)
        self.betslipTickets.append(bettingTicket)
    }

    @IBAction private func betNowAction() {

        for ticket in self.betslipTickets {
            Env.betslipManager.addBettingTicket(ticket)
        }

        self.betNowCallbackAction?()

    }

}
