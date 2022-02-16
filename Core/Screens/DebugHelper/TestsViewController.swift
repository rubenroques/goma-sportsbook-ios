//
//  TestsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine
import SwiftUI

class TestsViewController: UIViewController {

    @IBOutlet private weak var openProfileButton: UIButton!

    var cancellables = Set<AnyCancellable>()

    var savedRegistration: Registration?

    init() {
        super.init(nibName: "TestsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.buttonBackgroundPrimary
    }

    @IBAction private func didTapAPITest() {

        Env.gomaNetworkClient.requestTest(deviceId: Env.deviceId)
            .sink(receiveCompletion: {
                print("Received completion: \($0).")
            },
            receiveValue: { user in
                print("Received Content - user: \(String(describing: user)).")
            })
            .store(in: &cancellables)
    }

    @IBAction private func didTapUserSettings() {

        Env.gomaNetworkClient.requestSettings(deviceId: Env.deviceId)
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
                var settingsArray = [GomaClientSettings]()
                for value in data! {
                    let setting = GomaClientSettings(id: value.id, category: value.category, name: value.name, type: value.type)
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

    }

    @IBAction private func testSubscription() {

    }

    @IBAction private func testSubscriptionInitialDump() {

        if let savedRegistration = savedRegistration {
            Env.everyMatrixClient.manager.swampSession?.unregister(savedRegistration.registration, onSuccess: {
                self.savedRegistration = nil
            }, onError: { _, _ in
                self.savedRegistration = nil
            })
        }

    }

    @IBAction private func didTapOpenProfileButton() {

    }

    @IBAction private func didTapLoginProfileButton() {

    }

}
