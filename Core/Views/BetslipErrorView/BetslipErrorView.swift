//
//  BetslipErrorView.swift
//  Sportsbook
//
//  Created by André Lascas on 26/11/2021.
//

import UIKit

class BetslipErrorView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var descriptionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    override func commonInit() {
        self.descriptionLabel.text = localized("error")
        self.descriptionLabel.numberOfLines = 0

        self.logoImageView.image = UIImage(named: "warning_alert_icon")
        self.logoImageView.contentMode = .scaleAspectFit
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .black
        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.borderColor = UIColor.App.alertError.cgColor

        self.logoImageView.backgroundColor = .clear
        self.logoImageView.tintColor = UIColor.App.headingMain

        self.descriptionLabel.textColor = UIColor.App.headingMain
    }

    func setDescription(description: String) {
        self.descriptionLabel.text = description
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: descriptionLabel.frame.height)
    }
}
