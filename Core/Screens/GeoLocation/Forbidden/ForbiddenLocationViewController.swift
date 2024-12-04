//
//  ForbiddenLocationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/08/2021.
//

import UIKit

class ForbiddenLocationViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var logoMainImageView: UIImageView!
    @IBOutlet private var forbiddenView: UIView!
    @IBOutlet private var forbiddenImageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    init() {
        super.init(nibName: "ForbiddenLocationViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        containerView.backgroundColor = UIColor.App.backgroundPrimary
        forbiddenView.backgroundColor = UIColor.App.backgroundPrimary
        textLabel.textColor = UIColor.App.textPrimary
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "brand_icon_variation_1")
        logoMainImageView.sizeToFit()
        forbiddenImageView.image = UIImage(named: "location_error_icon")
        forbiddenImageView.contentMode = .scaleAspectFill
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 20)
        textLabel.numberOfLines = 0
        textLabel.text = localized("access_forbidden")
        textLabel.sizeToFit()
    }

}
