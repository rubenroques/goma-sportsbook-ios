//
//  BetSubmissionSuccessViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit

class BetSubmissionSuccessViewController: UIViewController {

    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    @IBOutlet private weak var messageTitleLabel: UILabel!
    @IBOutlet private weak var messageSubtitleLabel: UILabel!

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var continueButton: UIButton!

    @IBOutlet private weak var safeAreaBottomView: UIView!
    
    @IBOutlet private weak var possibleEarningsValueLabel: UILabel!
    @IBOutlet private weak var totalOddsValueLabel: UILabel!
    @IBOutlet private weak var betsMadeValueLabel: UILabel!
    
    @IBOutlet private weak var totalOddsLabel: UILabel!
    @IBOutlet private weak var possibleEarningsLabel: UILabel!
    @IBOutlet private weak var betsMadeLabel: UILabel!
    
    @IBOutlet private weak var checkboxImage: UIImageView!
    
    @IBOutlet private weak var checkboxLabel: UILabel!

    private var totalOddsValue: String
    private var possibleEarningsValue: String
    private var numberOfBets: Int
    private var isChecked: Bool = true
    private var betPlacedDetailsArray: [BetPlacedDetails]

    var willDismissAction: (() -> Void)?

    init(betPlacedDetailsArray: [BetPlacedDetails]) {

        self.betPlacedDetailsArray = betPlacedDetailsArray
        
        //
        // Possible Earnings
        var possibleEarningsDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                betPlacedDetails.response.maxWinning ?? 0.0
            })
            .reduce(0.0, +)

        possibleEarningsDouble = Double(floor(possibleEarningsDouble * 100)/100)
        self.possibleEarningsValue = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleEarningsDouble)) ?? "-.--€"

        //
        // Total Odd
        let totalOddDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                betPlacedDetails.response.totalPriceValue ?? 1.0
            })
            .reduce(1.0, *)
        self.totalOddsValue = OddConverter.stringForValue(totalOddDouble, format: UserDefaults.standard.userOddsFormat)

        //
        // Number Of Bets
        self.numberOfBets = betPlacedDetailsArray.count

         super.init(nibName: "BetSubmissionSuccessViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.possibleEarningsValueLabel.text = possibleEarningsValue
        self.totalOddsValueLabel.text = totalOddsValue
        self.betsMadeValueLabel.text = String(numberOfBets)
        
        if let betType = betPlacedDetailsArray.first?.response.type {
            if betType == "SYSTEM" {
                self.totalOddsLabel.isHidden = true
                self.totalOddsValueLabel.isHidden = true
            }
        }

        self.setupWithTheme()
    
        let checkboxTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkboxImage.addGestureRecognizer(checkboxTap)
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.safeAreaBottomView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.messageTitleLabel.textColor = UIColor.App.textPrimary
        self.messageSubtitleLabel.textColor = UIColor.App.textPrimary
        self.messageTitleLabel.font = AppFont.with(type: .bold, size: 32)
        self.messageSubtitleLabel.font = AppFont.with(type: .semibold, size: 24)
        
        self.betsMadeLabel.textColor = UIColor.App.textPrimary
        self.betsMadeValueLabel.textColor = UIColor.App.textPrimary
        self.betsMadeLabel.font = AppFont.with(type: .semibold, size: 16)
        self.betsMadeValueLabel.font = AppFont.with(type: .bold, size: 23)
        
        self.totalOddsValueLabel.textColor = UIColor.App.textPrimary
        self.totalOddsLabel.textColor = UIColor.App.textPrimary
        self.totalOddsValueLabel.font = AppFont.with(type: .bold, size: 23)
        self.totalOddsLabel.font = AppFont.with(type: .semibold, size: 16)
        
        self.possibleEarningsValueLabel.textColor = UIColor.App.textPrimary

        self.possibleEarningsLabel.textColor = UIColor.App.textPrimary
        self.possibleEarningsLabel.font = AppFont.with(type: .semibold, size: 21)
        self.possibleEarningsValueLabel.font = AppFont.with(type: .bold, size: 33)
       
        self.checkboxImage.image = UIImage(named: "checkbox_selected_icon")
        StyleHelper.styleButton(button: self.continueButton)
        self.checkboxLabel.backgroundColor = .clear
        self.checkboxLabel.textColor = UIColor.App.textSecondary
        self.checkboxLabel.text = localized("keep_bet_checkbox")
        self.checkboxLabel.font = AppFont.with(type: .semibold, size: 14)

    }

    @IBAction private func didTapContinueButton() {

        if !isChecked {
            Env.betslipManager.clearAllBettingTickets()
        }
        
        if self.isModal {
            self.willDismissAction?()
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapCheckbox() {
        if self.isChecked {
            self.checkboxImage.image = UIImage(named: "checkbox_unselected_icon")
        }
        else {
            self.checkboxImage.image = UIImage(named: "checkbox_selected_icon")
        }
        self.isChecked = !isChecked
    }

}
