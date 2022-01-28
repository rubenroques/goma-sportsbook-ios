//
//  RefusedAccessViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 31/08/2021.
//

import UIKit

class RefusedAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var logoMainImageView: UIImageView!
    @IBOutlet private var refusedView: UIView!
    @IBOutlet private var refusedImageView: UIImageView!
    @IBOutlet private var refusedTitleLabel: UILabel!
    @IBOutlet private var refusedSubtitleLabel: UILabel!
    @IBOutlet private var locationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App2.backgroundPrimary

        containerView.backgroundColor = UIColor.App2.backgroundPrimary
        refusedView.backgroundColor = UIColor.App2.backgroundPrimary
        refusedTitleLabel.textColor = UIColor.App2.textPrimary
        refusedSubtitleLabel.textColor = UIColor.App.fadeOutHeading

        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor
        locationButton.layer.backgroundColor = UIColor.App2.buttonBackgroundPrimary.cgColor
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "logo_horizontal_large")
        logoMainImageView.sizeToFit()
        refusedImageView.image = UIImage(named: "location_error_icon")
        refusedImageView.contentMode = .scaleAspectFill
        refusedTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        refusedTitleLabel.numberOfLines = 0
        refusedTitleLabel.text = localized("refused_location")
        refusedTitleLabel.sizeToFit()
        refusedSubtitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
        refusedSubtitleLabel.numberOfLines = 0
        refusedSubtitleLabel.text = localized("refused_location_subtitle")
        locationButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderWidth = 1
        locationButton.setTitle(localized("enable_location"), for: .normal)
    }

    @IBAction private func enableLocationAction() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
           UIApplication.shared.open(settingsUrl)
         }
    }

}
