//
//  RequestLocationAccessViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 31/08/2021.
//

import UIKit

class RequestLocationAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var permissionView: UIView!
    @IBOutlet private var permissionImageView: UIImageView!
    @IBOutlet private var permissionTitleLabel: UILabel!
    @IBOutlet private var permissionTextLabel: UILabel!
    @IBOutlet private var permissionSubtitleLabel: UILabel!
    @IBOutlet private var locationButton: UIButton!

    init() {
        super.init(nibName: "RequestLocationAccessViewController", bundle: nil)
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
        self.view.backgroundColor = UIColor.App.backgroundDarkFade
        containerView.backgroundColor = UIColor.App.backgroundDarkFade
        permissionView.backgroundColor = UIColor.App.backgroundDarkModal
        permissionTitleLabel.textColor = UIColor.App.headingMain
        permissionTextLabel.textColor = UIColor.App.headingMain
        permissionSubtitleLabel.textColor = UIColor.App.subtitleGray
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.borderColor = UIColor.App.buttonMain.cgColor
        locationButton.layer.backgroundColor = UIColor.App.buttonMain.cgColor
    }

    func commonInit() {
        permissionView.translatesAutoresizingMaskIntoConstraints = false
        permissionView.layer.cornerRadius = BorderRadius.modal
        permissionImageView.image = UIImage(named: "Location")
        permissionImageView.contentMode = .scaleAspectFill
        permissionTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 20)
        permissionTitleLabel.numberOfLines = 0
        permissionTitleLabel.text = localized("string_permission_location")
        permissionTitleLabel.sizeToFit()
        permissionTextLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        permissionTextLabel.numberOfLines = 0
        permissionTextLabel.text = localized("string_permission_location_text")
        permissionTextLabel.sizeToFit()
        permissionSubtitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
        permissionSubtitleLabel.numberOfLines = 0
        permissionSubtitleLabel.text = localized("string_permission_location_subtitle")
        permissionSubtitleLabel.sizeToFit()

        locationButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderWidth = 1
        locationButton.setTitle(localized("string_enable_location"), for: .normal)
    }

    @IBAction private func enableLocationAction() {
        Env.locationManager.requestGeoLocationUpdates()
    }

}
