//
//  RefusedAccessViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 31/08/2021.
//

import UIKit

class RefusedAccessViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var logoMainImageView: UIImageView!
    @IBOutlet private var refusedView: UIView!
    @IBOutlet private var refusedImageView: UIImageView!
    @IBOutlet private var refusedTitleLabel: UILabel!
    @IBOutlet private var refusedSubtitleLabel: UILabel!
    @IBOutlet private var locationButton: UIButton!
    // Variables
    var imageGradient: UIImage = UIImage()
    let locationManager = GeoLocationManager()

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
        refusedView.backgroundColor = UIColor(patternImage: imageGradient)
        refusedTitleLabel.textColor = UIColor.Core.headingMain
        refusedSubtitleLabel.textColor = UIColor.Core.subtitleGray
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.borderColor = UIColor.Core.buttonMain.cgColor
        locationButton.layer.backgroundColor = UIColor.Core.buttonMain.cgColor
    }

    func commonInit() {
        logoMainImageView.image = UIImage(named: "SPORTSBOOK")
        logoMainImageView.sizeToFit()
        refusedImageView.image = UIImage(named: "Location")
        refusedImageView.contentMode = .scaleAspectFill
        refusedTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        refusedTitleLabel.numberOfLines = 0
        refusedTitleLabel.text = localized("string_refused_location")
        refusedTitleLabel.sizeToFit()
        refusedSubtitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
        refusedSubtitleLabel.numberOfLines = 0
        refusedSubtitleLabel.text = localized("string_refused_location_subtitle")
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
        self.present(EnabledAccessViewController(), animated: true, completion: nil)
    }

}
