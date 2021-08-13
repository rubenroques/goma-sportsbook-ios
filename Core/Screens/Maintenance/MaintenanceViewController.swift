//
//  MaintenanceViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 13/08/2021.
//

import UIKit

class MaintenanceViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    // Variables
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkMaintenance), userInfo: nil, repeats: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.Core.tint
        self.containerView.backgroundColor = UIColor.Core.tint
        self.titleLabel.textColor = UIColor.Core.headingMain
        self.textLabel.textColor = UIColor.Core.headingMain
    }

    func commonInit() {
        self.titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 30)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "Maintenance in Course"
        self.textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 24)
        self.textLabel.textColor = UIColor.white
        self.textLabel.numberOfLines = 0
        self.textLabel.text = String(describing: UserDefaults.standard.object(forKey: "maintenance_reason")!)
        self.textLabel.sizeToFit()
    }

    @objc func checkMaintenance() {
        if !Env.isMaintenance {
            self.dismiss(animated: false, completion: nil)
            timer.invalidate()
        }
        print("Checked maintenance mode")
    }

}
