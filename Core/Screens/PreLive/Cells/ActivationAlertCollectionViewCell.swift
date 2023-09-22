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

    enum AlertType {
        case email
        case profile
    }
    // Variables

    var linkLabelAction: (() -> Void)?

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
        } else {
            self.actionButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.actionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
            self.actionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            self.actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }

        setupWithTheme()
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

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
        self.actionButton.setTitle("", for: .normal)
    }

    func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.backgroundTertiary

        self.gradientView.colors = [(UIColor.App.backgroundHeaderGradient2, NSNumber(0.0)),
                                    (UIColor.App.backgroundHeaderGradient1, NSNumber(1.0))]

        self.backgroundImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
        self.titleLabel.font = AppFont.with(type: .bold, size: 16)

        self.descriptionLabel.textColor = UIColor.App.textPrimary
        self.descriptionLabel.font = AppFont.with(type: .semibold, size: 13)

        self.actionButton.backgroundColor = UIColor.App.highlightTertiary
        self.actionButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
    }

    func setText(title: String, info: String, linkText: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = info
        self.descriptionLabel.addLineHeight(to: self.descriptionLabel, lineHeight: 24)
        self.actionButton.setTitle(linkText, for: .normal)
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        self.linkLabelAction?()
    }

}
