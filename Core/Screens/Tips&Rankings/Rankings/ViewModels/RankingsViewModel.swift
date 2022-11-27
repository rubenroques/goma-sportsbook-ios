//
//  RankingsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2022.
//

import Foundation
import Combine

class RankingsViewModel {

    var selectedIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int = 0) {
        self.startTabIndex = startTabIndex
        self.selectedIndexPublisher.send(startTabIndex)
    }

    func selectTicketType(atIndex index: Int) {
        self.selectedIndexPublisher.send(index)
    }

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        return 3
    }

    func shortcutTitle(forIndex index: Int) -> String {
        switch index {
        case 0:
            return localized("top_tipsters")
        case 1:
            return localized("friends")
        case 2:
            return localized("following")
        default:
            return localized("empty_value")
        }
    }

}
