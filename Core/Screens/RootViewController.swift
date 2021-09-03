//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine
import SwiftUI

class RootViewController: UIViewController {

    var showingDebug: Bool = false

    var networkClient: NetworkManager
    var gomaGamingAPIClient: GomaGamingServiceClient

    var isMaintenance: Bool = Env.isMaintenance
    let locationManager = GeoLocationManager()

    var cancellables = Set<AnyCancellable>()
    var everyMatrixAPIClient: EveryMatrixAPIClient

    init() {
        networkClient = Env.networkManager
        gomaGamingAPIClient = GomaGamingServiceClient(networkClient: networkClient)
        everyMatrixAPIClient = EveryMatrixAPIClient()
        super.init(nibName: "RootViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
        self.getLocationDateFormat()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        
        let realtimeClient = RealtimeSocketClient()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            let isMaintenance = realtimeClient.verifyMaintenanceMode()
            let appUpdateType = realtimeClient.verifyAppUpdateType()

            if isMaintenance {
                let maintenanceViewController = MaintenanceViewController()
                let navigationController = UINavigationController(rootViewController: maintenanceViewController)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)
            }
            else if appUpdateType != "" {
                let versionUpdateViewController = VersionUpdateViewController()
                let navigationController = UINavigationController(rootViewController: versionUpdateViewController)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.Core.tint

//        Example
//        let label1 = UILabel()
//        label1.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)
//        label1.textColor = UIColor.Core.headingMain

    }

    func getLocationDateFormat() {

        if locationManager.isLocationServicesEnabled() {
            print("GEO ACTIVATED")
        }
        else {
            print("GEO NOT ACTIVATED")
            locationManager.requestGeoLocationUpdates()
        }
        locationManager.startGeoLocationUpdates()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // FIXME:  .now() + 2 ? Não percebi este async after com 2 segundos

            let location = self.locationManager.lastLocation
            Env.userLatitude = location.coordinate.latitude
            Env.userLongitude = location.coordinate.longitude

            location.fetchCityAndCountry { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                print("\(city) \(country)")
            }

        }
    }

    @IBAction private func didTapAPITest() {

        gomaGamingAPIClient.requestTest(deviceId: Env.deviceId)
            .sink(receiveCompletion: {
                print("Received completion: \($0).")
            },
            receiveValue: { user in
                print("Received Content - user: \(String(describing: user)).")
            })
            .store(in: &cancellables)

    }

    @IBAction private func didTapGeolocationAPI() {

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
                        self.showForbiddenAccess()
                    }
                case .finished:
                    print("User allowed!")
                }

                print("Received completion: \(completion).")

            },
            receiveValue: { data in
                print("Received Content - data: \(String(describing: data)).")
            })
            .store(in: &cancellables)
    }

    @IBAction private func didTapUserSettings() {

        gomaGamingAPIClient.requestSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving user settings!")

                case .finished:
                    print("User settings retrieved!")
                }

                print("Received completion: \(completion).")

            },
            receiveValue: { data in
                print("Received Content - data: \(data!).")
                var settingsArray = [ClientSettings]()
                for value in data! {
                    let setting = ClientSettings(id: value.id, category: value.category, name: value.name, type: value.type)
                    settingsArray.append(setting)
                }
                let settingsData = try? JSONEncoder().encode(settingsArray)

                UserDefaults.standard.set(settingsData, forKey: "user_settings")

                let settingsStored = Env.getUserSettings()
                print("User settings: \(String(describing: settingsStored))")

            })
            .store(in: &cancellables)
    }

    @IBAction private func testEveryMatrixAPI() {
            everyMatrixAPIClient.getDisciplines()
    }


    @objc func checkMaintenance() {
        if Env.isMaintenance {
            let maintenanceVC = MaintenanceViewController()
            self.present(maintenanceVC, animated: true, completion: nil)
        }
        print("Checked maintenance mode")
    }

    func showForbiddenAccess() {
        let forbiddenAccessViewController = ForbiddenAccessViewController()
        let navigationController = UINavigationController(rootViewController: forbiddenAccessViewController)
        navigationController.modalPresentationStyle = .fullScreen

        self.present(navigationController, animated: true, completion: nil)
    }

}


extension RootViewController {

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        // Do any additional setup after loading the view.
        AnalyticsClient.logEvent(event: .login)

        let limit = TargetVariables.featureFlags.limitCheckoutItems
        // print("Target config flags \(limit)")

        Logger.log("Target config flags \(limit)")

        if showingDebug {
            return
        }

        Logger.log("Debug screen called")

        showingDebug = true

        if TargetVariables.environmentType == .dev {
            if motion == .motionShake {

                let debugViewController = DebugViewController()
                debugViewController.isBeingDismissedAction = { [weak self] _ in
                    self?.showingDebug = false
                }
                let navigationController = UINavigationController(rootViewController: debugViewController)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)
            }
        }

    }
}
