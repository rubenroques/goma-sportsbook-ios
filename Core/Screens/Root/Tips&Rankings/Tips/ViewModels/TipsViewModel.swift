//
//  TipsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2022.
//

import Foundation
import Combine

class TipsViewModel {

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
        return 4
    }

    func shortcutTitle(forIndex index: Int) -> String {
        switch index {
        case 0:
            return "All"
        case 1:
            return "Top Tips"
        case 2:
            return "Friends"
        case 3:
            return "Following"
        default:
            return ""
        }
    }

}
