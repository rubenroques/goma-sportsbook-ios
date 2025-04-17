//
//  ActivationAlertCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 17/11/2021.
//

import UIKit

class ActivationAlertCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var gradientView: GradientView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var kycExpireView: UIView!
    @IBOutlet private var kycExpireLabel: UILabel!
    
    enum AlertType {
        case email
        case profile
    }
    // Variables

    var linkLabelAction: (() -> Void)?
    
    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.layer.cornerRadius = CornerRadius.button
        self.containerView.layer.masksToBounds = true

        self.backgroundImageView.image = UIImage(named: "arrow_pattern_background")
        self.backgroundImageView.contentMode = .scaleAspectFill

        self.titleLabel.text = ""
        self.titleLabel.font = AppFont.with(type: .bold, size: 15)

        self.descriptionLabel.text = ""
        self.descriptionLabel.font = AppFont.with(type: .regular, size: 15)
        self.descriptionLabel.numberOfLines = 0

        self.actionButton.setTitle("", for: .normal)
        self.actionButton.titleLabel?.font = AppFont.with(type: .bold, size: 15)
        self.actionButton.setImage(UIImage(named: "arrow_right_icon"), for: .normal)

        if #available(iOS 15.0, *) {
            var buttonConfig = UIButton.Configuration.filled()
            buttonConfig.title = ""
            buttonConfig.buttonSize = .medium
            buttonConfig.image = UIImage(systemName: "arrow_right_icon")
            buttonConfig.imagePlacement = .trailing
            buttonConfig.imagePadding = 10
            buttonConfig.baseBackgroundColor = UIColor.App.highlightTertiary
            self.actionButton.configuration = buttonConfig
        }
        else {
            self.actionButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
            self.actionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            self.actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        
        self.kycExpireLabel.font = AppFont.with(type: .bold, size: 12)
        
        self.setupWithTheme()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.0)

        self.actionButton.layer.cornerRadius = CornerRadius.squareView

        self.actionButton.layer.shadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor
        self.actionButton.layer.shadowOpacity = 1
        self.actionButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.actionButton.layer.shadowRadius = 3
        
        self.kycExpireView.layer.mask = nil
        self.kycExpireView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
        self.actionButton.setTitle("", for: .normal)
        
        self.kycExpireView.isHidden = true
    }

    func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.backgroundTertiary

        self.gradientView.colors = [(UIColor.App.topBarGradient3, NSNumber(0.0)),
                                    (UIColor.App.topBarGradient2, NSNumber(0.5)),
                                    (UIColor.App.topBarGradient1, NSNumber(1.0))]

        self.backgroundImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.buttonTextPrimary
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)

        self.descriptionLabel.textColor = UIColor.App.buttonTextPrimary
        self.descriptionLabel.font = AppFont.with(type: .semibold, size: 13)

        self.actionButton.backgroundColor = UIColor.App.highlightTertiary
        self.actionButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        
        self.kycExpireView.backgroundColor = UIColor.App.highlightPrimary
        
        self.kycExpireLabel.textColor = UIColor.App.buttonTextPrimary
    }
    
    func configure(alertType: ActivationAlertType) {
        
        if alertType == .documents {
            
            if let kycExpireString = Env.userSessionStore.kycExpire {
                
                if let expireDateString = self.getExpireDateString(dateString: kycExpireString) {
                    self.kycExpireLabel.text = expireDateString
                    
                    self.kycExpireView.isHidden = false
                }
                else {
                    self.kycExpireView.isHidden = true
                }
            }
            else {
                self.kycExpireView.isHidden = true
            }
            
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
        }
        else if alertType == .server {
            // For server alerts, we use the standard styling without the KYC expiration view
            self.kycExpireView.isHidden = true
            
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
        }
    }

    func setText(title: String, info: String, linkText: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = info
        self.descriptionLabel.addLineHeight(to: self.descriptionLabel, lineHeight: 24)
        self.actionButton.setTitle(linkText, for: .normal)
    }
    
    func getExpireDateString(dateString: String) -> String? {
        
        let dateFormat = "dd-MM-yyyy HH:mm:ss"
        self.dateFormatter.dateFormat = dateFormat
        
        if let expirationDate = dateFormatter.date(from: dateString) {
            
            let currentDate = Date()
            
            let hoursDifference = expirationDate.hours(from: currentDate)
            let daysDifference = expirationDate.days(from: currentDate)
            
            var timeLeft: String?
            
            if hoursDifference < 0 {
                timeLeft = nil
            }
            if hoursDifference < 24 {
                // Today
                timeLeft = "\(localized("expires")) \(localized("today")) \(localized("at_")) \(expirationDate.format("HH:mm"))"
            }
            else if hoursDifference < 48 {
                // Tomorrow
                timeLeft = "\(localized("expires")) \(localized("tomorrow")) \(localized("at_")) \(expirationDate.format("HH:mm"))"
            }
            else {
                // After tomorrow
                timeLeft = "\(localized("expire_in_days").replacingFirstOccurrence(of: "{numberOfDays}", with: "\(daysDifference)"))"
            }
            
            return timeLeft
        }
        
        return nil
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        self.linkLabelAction?()
    }

}
