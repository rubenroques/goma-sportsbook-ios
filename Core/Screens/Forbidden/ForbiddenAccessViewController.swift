//
//  ForbiddenAccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/08/2021.
//

import UIKit

class ForbiddenAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

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
        self.view.backgroundColor = UIColor.Core.tint
        containerView.backgroundColor = UIColor.Core.tint
        titleLabel.textColor = UIColor.Core.headingMain
        textLabel.textColor = UIColor.Core.headingMain
    }

    func commonInit() {
        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 30)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Access Forbidden"
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 24)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = "You don't have permission to access the app. Please contact our user support."
        textLabel.sizeToFit()

    }

}
