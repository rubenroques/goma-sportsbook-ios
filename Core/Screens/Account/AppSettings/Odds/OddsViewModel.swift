//
//  OddsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/02/2022.
//

import Foundation

import Combine

class OddsViewModel: NSObject {

    // MARK: Private Properties
    private var userSettings: UserSettingsGoma?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var oddsFormatRadioButtonViews: [SettingsRadioRowView] = []
    var oddsVariationRadioButtonViews: [SettingsRadioRowView] = []

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.getUserSettings()
    }

    // MARK: Setup and functions
    func checkOddsVariationOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.oddsVariationRadioButtonViews {
            view.isChecked = false
        }
        viewTapped.isChecked = true

        if viewTapped.viewId == 1 {
            UserDefaults.standard.userBetslipSettings = "ACCEPT_HIGHER"
        }
        else if viewTapped.viewId == 2 {
            UserDefaults.standard.userBetslipSettings = "ACCEPT_ANY"
        }

        self.userSettings?.oddValidationType = UserDefaults.standard.userBetslipSettings

        self.postOddsSettingsToGoma()
    }

    func setOddsVariationSelectedValues() {
        // Set selected view
        let oddsVariationTypeString = UserDefaults.standard.userBetslipSettings
        let oddVariationId = getOddsVariationType(userBetslipSetting: oddsVariationTypeString)

        for view in self.oddsVariationRadioButtonViews {
            view.didTapView = { _ in
                self.checkOddsVariationOptionsSelected( viewTapped: view)
            }
            // Default market selected
            if view.viewId == oddVariationId {
                view.isChecked = true
            }
        }
    }

    func setOddsFormatSelectedValues() {
        // Set selected view
        let oddsFormat = UserDefaults.standard.userOddsFormat
        let oddsFormatId = oddsFormat.oddsFormatId

        for view in self.oddsFormatRadioButtonViews {
            view.didTapView = { _ in
                self.checkOddsFormatOptionsSelected( viewTapped: view)
            }
            // Default market selected
            if view.viewId == oddsFormatId {
                view.isChecked = true
            }
        }
    }

    private func checkOddsFormatOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.oddsFormatRadioButtonViews {
            view.isChecked = false
        }
        viewTapped.isChecked = true

        if viewTapped.viewId == 1 {
            UserDefaults.standard.userOddsFormat = .europe
        }
        else if viewTapped.viewId == 2 {
            UserDefaults.standard.userOddsFormat = .unitedKingdom
        }
        else if viewTapped.viewId == 3 {
            UserDefaults.standard.userOddsFormat = .unitedStates
        }
    }


    private func getOddsVariationType(userBetslipSetting: String) -> Int {
        if userBetslipSetting == "ACCEPT_HIGHER" {
            return 1
        }
        else if userBetslipSetting == "ACCEPT_ANY" {
            return 2
        }

        return 0
    }

    private func getUserSettings() {
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: "gomaUserSettings") {
            do {
                let decoder = JSONDecoder()

                let userSettings = try decoder.decode(UserSettingsGoma.self, from: data)

                self.userSettings = userSettings

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }

    private func setUserSettings(userSettings: UserSettingsGoma) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(userSettings)

            UserDefaults.standard.set(data, forKey: "gomaUserSettings")

        } catch {
            print("Unable to Encode User Settings Goma (\(error))")
        }

        self.postOddsSettingsToGoma()
    }

    private func postOddsSettingsToGoma() {
        if let data = UserDefaults.standard.data(forKey: "gomaUserSettings") {
            do {
                let decoder = JSONDecoder()

                let userSettings = try decoder.decode(UserSettingsGoma.self, from: data)

                Env.gomaNetworkClient.sendUserSettings(deviceId: Env.deviceId, userSettings: userSettings)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("GOMA SETTINGS ERROR: \(error)")
                        case .finished:
                            print("Finished")
                        }
                    }, receiveValue: { value in
                        print("GOMA SETTINGS: \(value)")
                    })
                    .store(in: &cancellables)

            }
            catch {
                print("Unable to Decode UserSettings Goma (\(error))")
            }
        }
    }
}
