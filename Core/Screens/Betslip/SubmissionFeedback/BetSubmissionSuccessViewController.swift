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
    
    
    @IBOutlet weak var possibleEarningsLabel: UILabel!
    @IBOutlet weak var totalOddsLabel: UILabel!
    @IBOutlet weak var betsMadeLabel: UILabel!
    
    

    var betPlacedDetailsArray: [BetPlacedDetails]
    var totalOddsValue : String
    var possibleEarningsValue : String
    var numberOfbets : Int

    var willDismissAction: (() -> ())?

    init(betPlacedDetailsArray: [BetPlacedDetails], totalOddsValue : String ,  possibleEarningsValue  : String, numberOfBets : Int ) {

        self.betPlacedDetailsArray = betPlacedDetailsArray
        self.possibleEarningsValue = possibleEarningsValue
        self.totalOddsValue = totalOddsValue
        self.numberOfbets = numberOfBets
        
        super.init(nibName: "BetSubmissionSuccessViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

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

        self.view.backgroundColor = UIColor.App.mainBackground
        self.topView.backgroundColor = UIColor.App.mainBackground
        self.bottomView.backgroundColor = UIColor.App.mainBackground
        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.safeAreaBottomView.backgroundColor = UIColor.App.mainBackground

        self.possibleEarningsLabel.text = possibleEarningsValue
        //self.possibleEarningsLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
        self.totalOddsLabel.text = totalOddsValue
        //self.totalOddsLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
        self.betsMadeLabel.text = String(numberOfbets)
       // self.betsMadeLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
        self.messageTitleLabel.textColor = UIColor.App.headingMain
        self.messageSubtitleLabel.textColor = UIColor.App.headingMain

        StyleHelper.styleButton(button: self.continueButton)
    }


    @IBAction private func didTapContinueButton(){
        if self.isModal {
            self.willDismissAction?()
            self.dismiss(animated: true, completion: nil)
        }
    }


    @IBAction private func didTapBackButton(){
        self.navigationController?.popViewController(animated: true)
    }

}

extension BetSubmissionSuccessViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.betPlacedDetailsArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0 // self.betPlacedDetailsArray[safe: section].tickets.count ?? 0
        case 1:
            return 0 //1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }


}
