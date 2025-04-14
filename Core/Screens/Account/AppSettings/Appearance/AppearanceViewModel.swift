//
//  AppearanceViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 21/02/2022.
//

import Foundation
import Combine

class AppearanceViewModel: NSObject {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var themeRadioButtonViews: [SettingsRadioRowView] = []
    var selectedThemePublisher: CurrentValueSubject<AppearanceMode, Never>

    // MARK: Lifetime and Cycle
    override init() {
        self.selectedThemePublisher = { () -> CurrentValueSubject<AppearanceMode, Never> in
            let themeChosenId = UserDefaults.standard.appearanceMode.themeId

            if themeChosenId == 1 {
                return .init(AppearanceMode.dark)
            }
            else if themeChosenId == 2 {
                return .init(AppearanceMode.light)
            }
            return .init(AppearanceMode.device)
        }()
        super.init()

    }

    // MARK: Setup and functions

    func setSelectedView() {
        // Set selected view
        let themeChosenId = UserDefaults.standard.appearanceMode.themeId

        for view in self.themeRadioButtonViews {
            view.didTapView = { _ in
                self.checkThemeRadioOptionsSelected(viewTapped: view)
            }
            if view.viewId == themeChosenId {
                view.isChecked = true
            }
        }

    }

    private func checkThemeRadioOptionsSelected(viewTapped: SettingsRadioRowView) {
        for view in self.themeRadioButtonViews {
            view.isChecked = false
        }
        viewTapped.isChecked = true

        if viewTapped.viewId == 1 {
            UserDefaults.standard.appearanceMode = AppearanceMode.dark
            self.selectedThemePublisher.send(AppearanceMode.dark)
        }
        else if viewTapped.viewId == 2 {
            UserDefaults.standard.appearanceMode = AppearanceMode.light
            self.selectedThemePublisher.send(AppearanceMode.light)
        }
        else if viewTapped.viewId == 3 {
            UserDefaults.standard.appearanceMode = AppearanceMode.device
            self.selectedThemePublisher.send(AppearanceMode.device)
        }

    }
}
