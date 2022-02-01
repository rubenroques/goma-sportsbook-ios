//
//  EmptyCardTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 23/12/2021.
//

import UIKit

class EmptyCardTableViewCell: UITableViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var firstTextFieldLabel: UILabel!
    @IBOutlet private var secondTextFieldLabel: UILabel!
    @IBOutlet private var loginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.layer.cornerRadius = CornerRadius.modal
        self.containerView.layer.masksToBounds = true

        self.iconImageView.backgroundColor = .clear
        self.iconImageView.tintColor = UIColor.App.textPrimary

        self.firstTextFieldLabel.textColor = UIColor.App.textPrimary
        self.firstTextFieldLabel.font = AppFont.with(type: .semibold, size: 20)
        
        self.secondTextFieldLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldLabel.font = AppFont.with(type: .semibold, size: 14)
        self.firstTextFieldLabel.numberOfLines = 2
        
        self.iconImageView.image = UIImage(named: "no_content_icon")
        
        self.loginButton.isHidden = true
    }
    
    func setDescription(primaryText: String, secondaryText: String, userIsLoggedIn: Bool) {
        self.firstTextFieldLabel.text = primaryText
        self.secondTextFieldLabel.text = secondaryText
        if userIsLoggedIn {
            self.loginButton.isHidden = true
        }
        else {
            self.loginButton.setTitle(localized("login"), for: .normal)
            self.loginButton.isHidden = false
        }
    }

}
