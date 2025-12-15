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
    var selectedThemePublisher: CurrentValueSubject<Theme, Never>

    // MARK: Lifetime and Cycle
    override init() {
        self.selectedThemePublisher = { () -> CurrentValueSubject<Theme, Never> in
            let themeChosenId = UserDefaults.standard.theme.themeId

            if themeChosenId == 1 {
                return .init(Theme.dark)
            }
            else if themeChosenId == 2 {
                return .init(Theme.light)
            }
            return .init(Theme.device)
        }()
        super.init()

    }

    // MARK: Setup and functions

    func setSelectedView() {
        // Set selected view
        let themeChosenId = UserDefaults.standard.theme.themeId

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
            UserDefaults.standard.theme = Theme.dark
            self.selectedThemePublisher.send(Theme.dark)
        }
        else if viewTapped.viewId == 2 {
            UserDefaults.standard.theme = Theme.light
            self.selectedThemePublisher.send(Theme.light)
        }
        else if viewTapped.viewId == 3 {
            UserDefaults.standard.theme = Theme.device
            self.selectedThemePublisher.send(Theme.device)
        }

    }
}
