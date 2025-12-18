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

        self.isModalInPresentation = true

        self.setupWithTheme()
        self.commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        refusedView.backgroundColor = UIColor.App.backgroundPrimary
        refusedTitleLabel.textColor = UIColor.App.textPrimary
        refusedSubtitleLabel.textColor = UIColor.App.textSecondary

        locationButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        locationButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "brand_icon_variation_new")
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
        locationButton.setTitle(localized("enable_location"), for: .normal)
    }

    @IBAction private func enableLocationAction() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
           UIApplication.shared.open(settingsUrl)
         }
    }

}
