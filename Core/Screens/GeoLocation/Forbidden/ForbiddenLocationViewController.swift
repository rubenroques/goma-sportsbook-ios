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

        setupWithTheme()
        commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor
        containerView.backgroundColor = UIColor.App.mainBackgroundColor
        forbiddenView.backgroundColor = UIColor.App.mainBackgroundColor
        textLabel.textColor = UIColor.App.headingMain
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "logo_horizontal_large")
        logoMainImageView.sizeToFit()
        forbiddenImageView.image = UIImage(named: "location_error_icon")
        forbiddenImageView.contentMode = .scaleAspectFill
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 20)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = localized("string_access_forbidden")
        textLabel.sizeToFit()
    }

}
