//
//  ForbiddenAccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/08/2021.
//

import UIKit

class ForbiddenAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var logoMainImageView: UIImageView!
    @IBOutlet private var forbiddenView: UIView!
    @IBOutlet private var forbiddenImageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    // Variables
    var imageGradient: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)
        setupWithTheme()
        commonInit()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)
        containerView.backgroundColor = UIColor(patternImage: imageGradient)
        forbiddenView.backgroundColor = UIColor(patternImage: imageGradient)
        textLabel.textColor = UIColor.App.headingMain
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "SPORTSBOOK")
        logoMainImageView.sizeToFit()
        forbiddenImageView.image = UIImage(named: "Location_Error")
        forbiddenImageView.contentMode = .scaleAspectFill
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 20)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = localized("string_access_forbidden")
        textLabel.sizeToFit()

    }

}
