//
//  EnabledAccessViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 31/08/2021.
//

import UIKit
import Combine

class EnabledAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var enabledView: UIView!
    @IBOutlet private var enabledImageView: UIImageView!
    @IBOutlet private var enabledLabel: UILabel!
    @IBOutlet private var dismissButton: UIButton!

    init() {
        super.init(nibName: "EnabledAccessViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundCards

        containerView.backgroundColor = UIColor.App.backgroundCards
        enabledView.backgroundColor = UIColor.App.backgroundSecondary
        enabledLabel.textColor = UIColor.App.textPrimary

        dismissButton.setTitleColor(UIColor.white, for: .normal)
        dismissButton.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        dismissButton.layer.backgroundColor = UIColor.App.highlightPrimary.cgColor
    }

    func commonInit() {
        enabledImageView.translatesAutoresizingMaskIntoConstraints = false
        enabledImageView.layer.cornerRadius = CornerRadius.modal
        enabledImageView.image = UIImage(named: "location_success_icon")
        enabledImageView.contentMode = .scaleAspectFill

        enabledLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        enabledLabel.numberOfLines = 0
        enabledLabel.text = localized("success_location")
        enabledLabel.sizeToFit()

        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        dismissButton.layer.cornerRadius = 5
        dismissButton.layer.borderWidth = 1
        dismissButton.setTitle(localized("done"), for: .normal)
    }

    @IBAction private func dismissAction() {

    }

}
