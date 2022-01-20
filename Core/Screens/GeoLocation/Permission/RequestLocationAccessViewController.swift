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

    var loadingView: UIView?

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
        self.view.backgroundColor = UIColor.App.contentBackground
        containerView.backgroundColor = UIColor.App.contentBackground
        permissionView.backgroundColor = UIColor.App.secondaryBackground
        permissionTitleLabel.textColor = UIColor.App.headingMain
        permissionTextLabel.textColor = UIColor.App.headingMain
        permissionSubtitleLabel.textColor = UIColor.App.fadeOutHeading
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.borderColor = UIColor.App.mainTint.cgColor
        locationButton.layer.backgroundColor = UIColor.App.mainTint.cgColor
    }

    func commonInit() {
        permissionView.translatesAutoresizingMaskIntoConstraints = false
        permissionView.layer.cornerRadius = CornerRadius.modal
        permissionImageView.image = UIImage(named: "location_prompt_icon")
        permissionImageView.contentMode = .scaleAspectFill
        permissionTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 20)
        permissionTitleLabel.numberOfLines = 0
        permissionTitleLabel.text = localized("permission_location")
        permissionTitleLabel.sizeToFit()
        permissionTextLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        permissionTextLabel.numberOfLines = 0
        permissionTextLabel.text = localized("permission_location_text")
        permissionTextLabel.sizeToFit()
        permissionSubtitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
        permissionSubtitleLabel.numberOfLines = 0
        permissionSubtitleLabel.text = localized("permission_location_subtitle")
        permissionSubtitleLabel.sizeToFit()

        locationButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderWidth = 1
        locationButton.setTitle(localized("enable_location"), for: .normal)
    }

    @IBAction private func enableLocationAction() {
        showLoadingView()
        executeDelayed(1) {
            Env.locationManager.requestGeoLocationUpdates()
        }
    }

    func showLoadingView() {

        self.loadingView = self.createLoadingView()

        self.view.addSubview(self.loadingView!)

        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: self.loadingView!.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingView!.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.loadingView!.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingView!.trailingAnchor),
        ])
    }

}

extension RequestLocationAccessViewController {

    func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.5)

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
        ])
        return view
    }

}
