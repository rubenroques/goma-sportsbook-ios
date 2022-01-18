//
//  TodayMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class TodayMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var todayMatches: [Match] = []

    var requestNextPageAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    init(todayMatches: [Match]) {
        self.todayMatches = todayMatches
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.todayMatches.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.todayMatches[safe: indexPath.row] {
                cell.setupWithMatch(match)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                cell.startAnimating()
                return cell
            }
        default:
            ()
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {
            headerView.configureWithTitle(localized("string_upcoming_highlights"))
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return 155
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, self.todayMatches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.requestNextPageAction?()
        }
    }
}

