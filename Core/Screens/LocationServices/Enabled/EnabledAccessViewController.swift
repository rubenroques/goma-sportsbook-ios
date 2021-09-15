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
    // Variables
    var networkClient: NetworkManager
    var gomaGamingAPIClient: GomaGamingServiceClient
    var cancellables = Set<AnyCancellable>()

    init() {
        networkClient = Env.networkManager
        gomaGamingAPIClient = GomaGamingServiceClient(networkClient: networkClient)
        super.init(nibName: "EnabledAccessViewController", bundle: nil)
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
        self.view.backgroundColor = UIColor.Core.backgroundDarkFade
        containerView.backgroundColor = UIColor.Core.backgroundDarkFade
        enabledView.backgroundColor = UIColor.Core.backgroundDarkModal
        enabledLabel.textColor = UIColor.Core.headingMain
        dismissButton.setTitleColor(UIColor.white, for: .normal)
        dismissButton.layer.borderColor = UIColor.Core.buttonMain.cgColor
        dismissButton.layer.backgroundColor = UIColor.Core.buttonMain.cgColor

        
    }

    func commonInit() {
        enabledImageView.translatesAutoresizingMaskIntoConstraints = false
        enabledImageView.layer.cornerRadius = BorderRadius.modal
        enabledImageView.image = UIImage(named: "Location_Success")
        enabledImageView.contentMode = .scaleAspectFill
        enabledLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        enabledLabel.numberOfLines = 0
        enabledLabel.text = localized("string_success_location")
        enabledLabel.sizeToFit()
        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 16)
        dismissButton.layer.cornerRadius = 5
        dismissButton.layer.borderWidth = 1
        dismissButton.setTitle(localized("string_done"), for: .normal)
    }

    @IBAction private func dismissAction() {
        guard
            let latitude = Env.userLatitude,
            let longitude = Env.userLongitude
        else {
            return
        }

        gomaGamingAPIClient.requestGeoLocation(deviceId: Env.deviceId, latitude: latitude, longitude: longitude)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("User not allowed!")
                    DispatchQueue.main.async {
                        self.present(ForbiddenAccessViewController(), animated: true, completion: nil)
                    }
                case .finished:
                    print("User allowed!")
                    DispatchQueue.main.async {
                        self.present(RootViewController(), animated: true, completion: nil)
                    }
                }

                print("Received completion: \(completion).")

            },
            receiveValue: { data in
                print("Received Content - data: \(String(describing: data)).")
            })
            .store(in: &cancellables)
    }

}
