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
    var timer = Timer()
    var imageGradient: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)
        commonInit()
        setupWithTheme()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkMaintenance), userInfo: nil, repeats: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor(patternImage: imageGradient)
        containerView.backgroundColor = UIColor(patternImage: imageGradient)
        maintenanceView.backgroundColor = UIColor(patternImage: imageGradient)
        titleLabel.textColor = UIColor.Core.headingMain
        textLabel.textColor = UIColor.Core.headingMain
    }

    func commonInit() {
        logoImageView.backgroundColor = UIColor(patternImage: imageGradient)
        logoImageView.image = UIImage(named: "Maintenance")
        logoImageView.contentMode = .scaleAspectFill
        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 22)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.text = localized("string_maintenance_mode")
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = String(describing: UserDefaults.standard.object(forKey: "maintenance_reason")!)
        textLabel.sizeToFit()
    }

    @objc func checkMaintenance() {
        if !Env.isMaintenance {
            self.dismiss(animated: false, completion: nil)
            timer.invalidate()
        }
        print("Checked maintenance mode")
    }

}
