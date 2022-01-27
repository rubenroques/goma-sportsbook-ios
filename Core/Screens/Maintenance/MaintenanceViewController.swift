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
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

    // Variables
    var imageGradient: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true

        imageGradient = UIImage().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        containerView.backgroundColor = UIColor(patternImage: imageGradient)
        maintenanceView.backgroundColor = UIColor(patternImage: imageGradient)
        titleLabel.textColor = UIColor.App.headingMain
        textLabel.textColor = UIColor.App.headingMain
    }

    func commonInit() {
        logoImageView.backgroundColor = UIColor(patternImage: imageGradient)
        logoImageView.image = UIImage(named: "maintenance_icon")
        logoImageView.contentMode = .scaleAspectFill

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 22)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.text = localized("maintenance_mode")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = Env.businessSettingsSocket.clientSettings?.maintenanceReason ?? ""
        textLabel.sizeToFit()
    }

}
