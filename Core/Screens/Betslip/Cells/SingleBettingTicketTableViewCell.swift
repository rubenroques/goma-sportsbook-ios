//
//  SingleBettingTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class SingleBettingTicketTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var topBaseView: UIView!
    @IBOutlet weak var outcomeNameLabel: UILabel!
    @IBOutlet weak var oddBaseView: UIView!
    @IBOutlet weak var oddValueLabel: UILabel!

    @IBOutlet weak var upChangeOddValueImage: UIImageView!
    @IBOutlet weak var downChangeOddValueImage: UIImageView!

    @IBOutlet weak var deleteBetButton: UIButton!

    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var bottomBaseView: UIView!
    @IBOutlet weak var marketNameLabel: UILabel!
    @IBOutlet weak var matchDetailLabel: UILabel!
    @IBOutlet weak var returnsValueLabel: UILabel!

    @IBOutlet weak var amountBaseView: UIView!
    @IBOutlet weak var amountTextfield: UITextField!

    @IBOutlet weak var buttonsBaseView: UIView!
    @IBOutlet weak var plusOneButtonView: UIButton!
    @IBOutlet weak var plusFiveButtonView: UIButton!
    @IBOutlet weak var maxValueButtonView: UIButton!

    var currentOddValue: Double?
    var bettingTicket: BettingTicket?

    var oddSubscriber: AnyCancellable?

    var currentValue: Int = 0
    var realBetValue: Double {
        if currentValue == 0 {
            return 0
        }
        else {
            return Double(currentValue)/Double(100)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.amountTextfield.delegate = self
        self.addDoneAccessoryView()

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.plusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.plusOneButtonView.clipsToBounds = true
        self.plusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.plusFiveButtonView.clipsToBounds = true
        self.maxValueButtonView.layer.cornerRadius = CornerRadius.view
        self.maxValueButtonView.clipsToBounds = true

        self.baseView.layer.cornerRadius = CornerRadius.view
        self.oddBaseView.layer.cornerRadius = 3
        self.amountBaseView.layer.cornerRadius = CornerRadius.view
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.currentOddValue = nil

        self.bettingTicket = nil
        self.oddSubscriber?.cancel()
        self.oddSubscriber = nil

        self.currentValue = 0

        self.outcomeNameLabel.text = ""
        self.oddValueLabel.text = ""
        self.marketNameLabel.text = ""
        self.matchDetailLabel.text = ""

        self.amountTextfield.text = nil
        self.endEditing(true)
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.topBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.separatorView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.buttonsBaseView.backgroundColor = UIColor.App.secondaryBackground
        
        self.outcomeNameLabel.textColor = UIColor.App.headingMain
        self.oddValueLabel.textColor = UIColor.App.headingMain
        self.marketNameLabel.textColor = UIColor.App.headingMain
        self.matchDetailLabel.textColor = UIColor.App.headingDisabled
        self.returnsValueLabel.textColor = UIColor.App.headingDisabled

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.headingMain
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingDisabled
        ])

        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground
        
        self.plusOneButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

    }

    func addDoneAccessoryView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.amountTextfield.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    func highlightOddChangeUp(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func configureWithBettingTicket(_ bettingTicket: BettingTicket) {
        self.bettingTicket = bettingTicket
        self.outcomeNameLabel.text = bettingTicket.outcomeDescription
        self.oddValueLabel.text = "\(Double(floor(bettingTicket.value * 100)/100))"
        self.marketNameLabel.text = bettingTicket.marketDescription
        self.matchDetailLabel.text = bettingTicket.matchDescription

        self.currentOddValue = bettingTicket.value

        self.oddSubscriber = Env.everyMatrixStorage
            .oddPublisherForBettingOfferId(bettingTicket.id)?
            .map(\.oddsValue)
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newOddValue in

                if let currentOddValue = self?.currentOddValue {
                    if newOddValue > currentOddValue {
                        self?.highlightOddChangeUp()
                    }
                    else if newOddValue < currentOddValue {
                        self?.highlightOddChangeDown()
                    }
                }
                
                self?.currentOddValue = newOddValue
                self?.oddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
            })

    }

    @IBAction func didTapDeleteButton() {
        if let bettingTicket = self.bettingTicket {
            Env.betslipManager.removeBettingTicket(bettingTicket)
        }
    }

    @IBAction func didTapPlusOneButton() {
        self.addAmountValue(1)
    }

    @IBAction func didTapPlusFiveButton() {
        self.addAmountValue(5)
    }

    @IBAction func didTapPlusMaxButton() {
        self.addAmountValue(100)
    }

}

extension SingleBettingTicketTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
        return false
    }

    func addAmountValue(_ value: Int) {
        currentValue = currentValue + (value * 100)

        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

    func updateAmountValue(_ newValue: String) {
        if let insertedDigit = Int(newValue) {
            currentValue = currentValue * 10 + insertedDigit
        }
        if newValue == "" {
            currentValue = currentValue/10
        }
        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

}

extension SingleBettingTicketTableViewCell {
    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }
}
