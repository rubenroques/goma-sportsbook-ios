//
//  BetSubmissionSuccessViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit

class BetSubmissionSuccessViewController: UIViewController {

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
    
    @IBOutlet weak var totalOddsLabel: UILabel!
    @IBOutlet weak var possibleEarningsLabel: UILabel!
    @IBOutlet weak var betsMadeLabel: UILabel!
    
    var totalOddsValue: String
    var possibleEarningsValue: String
    var numberOfBets: Int

    var willDismissAction: (() -> Void)?

    init(betPlacedDetailsArray: [BetPlacedDetails]) {

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

        self.totalOddsValue = OddFormatter.formatOdd(withValue: totalOddDouble)

        //
        // Number Of Bets
        self.numberOfBets = betPlacedDetailsArray.count

        //
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

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App2.backgroundPrimary
        self.topView.backgroundColor = UIColor.App2.backgroundPrimary
        self.bottomView.backgroundColor = UIColor.App2.backgroundPrimary
        self.bottomSeparatorView.backgroundColor = UIColor.App2.separatorLine
        self.safeAreaBottomView.backgroundColor = UIColor.App2.backgroundPrimary
        self.messageTitleLabel.textColor = UIColor.App2.textPrimary
        self.messageSubtitleLabel.textColor = UIColor.App2.textPrimary
        self.betsMadeLabel.textColor = UIColor.App2.textPrimary
        self.totalOddsLabel.textColor = UIColor.App2.textPrimary
        self.possibleEarningsLabel.textColor = UIColor.App2.textPrimary
        self.betsMadeValueLabel.textColor = UIColor.App2.textPrimary
        self.totalOddsValueLabel.textColor = UIColor.App2.textPrimary
        self.possibleEarningsValueLabel.textColor = UIColor.App2.textPrimary
        StyleHelper.styleButton(button: self.continueButton)
    }

    @IBAction private func didTapContinueButton() {
        if self.isModal {
            self.willDismissAction?()
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

}
