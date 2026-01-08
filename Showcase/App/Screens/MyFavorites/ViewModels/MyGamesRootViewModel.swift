//
//  MyGamesRootViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 04/08/2023.
//

import Foundation
import Combine

class MyGamesRootViewModel {

    var selectedIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int = 0) {
        self.startTabIndex = startTabIndex
        self.selectedIndexPublisher.send(startTabIndex)
    }

    func selectGamesType(atIndex index: Int) {
        self.selectedIndexPublisher.send(index)
    }

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        return 6
    }

    func shortcutTitle(forIndex index: Int) -> String {
        switch index {
        case 0:
            return localized("all")
        case 1:
            return localized("live")
        case 2:
            return localized("today")
        case 3:
            return localized("tomorrow")
        case 4:
            return localized("this_week")
        case 5:
            return localized("next_week")
        default:
            return ""
        }
    }

}
