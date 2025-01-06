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

    var betNowCallbackAction: (() -> Void)?

    var viewModel: SuggestedBetViewModel?
    var cancellables = Set<AnyCancellable>()
    var needsReload: PassthroughSubject<Void, Never> = .init()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.totalOddValueLabel.text = ""
        self.numberOfSelectionsValueLabel.text = ""
    
        self.numberOfSelectionsLabel.font = AppFont.with(type: .heavy, size: 12)
        self.numberOfSelectionsValueLabel.font = AppFont.with(type: .heavy, size: 14)
        self.totalOddLabel.font = AppFont.with(type: .heavy, size: 12)
        self.totalOddValueLabel.font = AppFont.with(type: .heavy, size: 14)

        self.setupWithTheme()

        self.betNowButton.setTitle(localized("bet_now"), for: .normal)
        
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

        StyleHelper.styleButton(button: self.betNowButton)

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
        self.betsStackView.removeAllArrangedSubviews()

        if let viewModel = self.viewModel {

            for gameSuggestedView in viewModel.gameSuggestedViewsArray {
                betsStackView.addArrangedSubview(gameSuggestedView)
            }

            self.setupInfoBetValues(totalOdd: viewModel.totalOdd, numberOfSelection: viewModel.numberOfSelection)
        }
    }
    
    func setupInfoBetValues(totalOdd: Double, numberOfSelection: Int) {
        let formatedOdd = OddFormatter.formatOdd(withValue: totalOdd)
        self.totalOddValueLabel.text = "\(formatedOdd)"
        self.numberOfSelectionsValueLabel.text = "\(numberOfSelection)"
     }

    @IBAction private func betNowAction() {
        guard let viewModel = self.viewModel else {
            return
        }

        for ticket in viewModel.betslipTickets {
            Env.betslipManager.addBettingTicket(ticket)
        }

        self.betNowCallbackAction?()
    }

}
