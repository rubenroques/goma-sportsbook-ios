//
//  MaintenanceViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/08/2021.
//

import UIKit

class MaintenanceViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var maintenanceView: UIView!
    @IBOutlet private var brandImageView: UIImageView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true

        self.commonInit()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        
        containerView.backgroundColor = UIColor.App.backgroundPrimary
        maintenanceView.backgroundColor = UIColor.App.backgroundPrimary
        titleLabel.textColor = UIColor.App.textPrimary
        textLabel.textColor = UIColor.App.textPrimary
    }

    func commonInit() {
        brandImageView.image = UIImage(named: "brand_icon_variation_new")
        brandImageView.contentMode = .scaleAspectFit
        
        logoImageView.backgroundColor = UIColor.App.backgroundPrimary
        logoImageView.image = UIImage(named: "maintenance_icon")
        logoImageView.contentMode = .scaleAspectFill

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 22)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.text = localized("maintenance_mode")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = Env.businessSettingsSocket.clientSettings.maintenanceReason
        textLabel.sizeToFit()
    }

}
