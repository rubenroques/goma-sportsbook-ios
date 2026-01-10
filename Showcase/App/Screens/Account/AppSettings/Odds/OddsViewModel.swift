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
    private var bettingUserSettings: BettingUserSettings?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var oddsFormatRadioButtonViews: [SettingsRadioRowView] = []
    var oddsVariationRadioButtonViews: [SettingsRadioRowView] = []

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.getBettingUserSettings()
    }

    // MARK: Setup and functions
    func checkOddsVariationOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.oddsVariationRadioButtonViews {
            view.isChecked = false
        }
        viewTapped.isChecked = true

        if viewTapped.viewId == 1 {
            self.bettingUserSettings?.oddValidationType =  BetslipOddValidationType.acceptHigher.key
        }
        else if viewTapped.viewId == 2 {
            self.bettingUserSettings?.oddValidationType = BetslipOddValidationType.acceptAny.key
        }

        self.storeBettingUserSettings()
    }

    func setOddsVariationSelectedValues() {
        // Set selected view
        let oddsVariationTypeString = UserDefaults.standard.bettingUserSettings.oddValidationType
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

    private func getBettingUserSettings() {
        self.bettingUserSettings = UserDefaults.standard.bettingUserSettings
    }

    func storeBettingUserSettings() {
        if let bettingUserSettings = self.bettingUserSettings {
            UserDefaults.standard.bettingUserSettings = bettingUserSettings
            self.postBettingUserSettings()
        }
    }

    private func postBettingUserSettings() {let bettingUserSettings = UserDefaults.standard.bettingUserSettings
        Env.gomaNetworkClient.postBettingUserSettings(deviceId: Env.deviceId, bettingUserSettings: bettingUserSettings)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
