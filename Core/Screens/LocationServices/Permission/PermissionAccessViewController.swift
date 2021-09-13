//
//  PermissionAccessViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 31/08/2021.
//

import UIKit

class PermissionAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var permissionView: UIView!
    @IBOutlet private var permissionImageView: UIImageView!
    @IBOutlet private var permissionTitleLabel: UILabel!
    @IBOutlet private var permissionTextLabel: UILabel!
    @IBOutlet private var permissionSubtitleLabel: UILabel!
    @IBOutlet private var locationButton: UIButton!
    // Variables
    let locationManager = GeoLocationManager()
    
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
        self.view.backgroundColor = UIColor.Core.backgroundDarkFade
        containerView.backgroundColor = UIColor.Core.backgroundDarkFade
        permissionView.backgroundColor = UIColor.Core.backgroundDarkModal
        permissionTitleLabel.textColor = UIColor.Core.headingMain
        permissionTextLabel.textColor = UIColor.Core.headingMain
        permissionSubtitleLabel.textColor = UIColor.Core.subtitleGray
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.borderColor = UIColor.Core.buttonMain.cgColor
        locationButton.layer.backgroundColor = UIColor.Core.buttonMain.cgColor
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
        locationManager.requestGeoLocationUpdates()
        locationManager.startGeoLocationUpdates()

        while !locationManager.isLocationServicesEnabled() {
            // Wait for location confirmation
        }
        let location = self.locationManager.lastLocation
        Env.userLatitude = location.coordinate.latitude
        Env.userLongitude = location.coordinate.longitude
        
        self.present(EnabledAccessViewController(), animated: true, completion: nil)
    }

}
