//
//  TodayMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class TodayMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var todayMatches: [Match] = []

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var canRequestNextPageAction: (() -> Bool)?
    var requestNextPageAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    
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
            if self.canRequestNextPageAction?() ?? true {
                return 1
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.todayMatches[safe: indexPath.row] {
                if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                    cell.matchStatsViewModel = matchStatsViewModel
                }
                let store = Env.everyMatrixStorage as AggregatorStore

                cell.setupWithMatch(match, store: store)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }
//                cell.didTapFavoriteMatchAction = { [weak self] match in
//                    self?.didTapFavoriteMatchAction?(match)
//                }

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
            headerView.configureWithTitle(localized("upcoming_highlights"))
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
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            // Loading cell
            return 70
        default:
            return MatchWidgetCollectionViewCell.cellHeight + 20
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

