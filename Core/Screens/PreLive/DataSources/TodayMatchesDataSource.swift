//
//  TodayMatchesDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/01/2022.
//

import UIKit

class TodayMatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var todayMatches: [Match] = []
    var outrightCompetitions: [Competition]? = []

    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?

    var canRequestNextPageAction: (() -> Bool)?
    var requestNextPageAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    var didSelectCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    override init() {
        super.init()
    }

    func shouldShowOutrightMarkets() -> Bool {
        return self.todayMatches.isEmpty
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
                if self.shouldShowOutrightMarkets(), let count = self.outrightCompetitions?.count {
                    return count
                }
                return 0
        case 1:
            return self.todayMatches.count
        case 2:
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
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.outrightCompetitions?[safe: indexPath.row]
            else {
                fatalError()
            }
            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.didSelectCompetitionAction?(competition)
            }
            return cell
        case 1:
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

                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.didLongPressOdd?(bettingTicket)
                }

                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            ()
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if self.todayMatches.isEmpty {
            return nil
        }

        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {
            headerView.configureWithTitle(localized("upcoming_highlights"))
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if self.todayMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        if self.todayMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 2:
            // Loading cell
            return 70
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 2:
            // Loading cell
            return 70
        default:
            return StyleHelper.cardsStyleHeight() + 20
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2, self.todayMatches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.requestNextPageAction?()
        }
    }
}
