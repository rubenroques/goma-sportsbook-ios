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
    var shouldShowSearch: (() -> Void)?

    override init() {
        super.init()
    }

    func shouldShowOutrightMarkets() -> Bool {
        return self.todayMatches.isEmpty
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
        case 3:
            return 1
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
                
                let viewModel = MatchLineTableCellViewModel(match: match)
                cell.viewModel = viewModel
                
                cell.tappedMatchLineAction = { [weak self] match in
                    self?.didSelectMatchAction?(match)
                }

                cell.didLongPressOdd = { [weak self] bettingTicket in
                    self?.didLongPressOdd?(bettingTicket)
                }

                return cell
            }
        case 2:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        case 3:
            if let cell = tableView.dequeueCellType(FooterResponsibleGamingViewCell.self) {
                return cell
            }
        default:
            ()
        }

        return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.outrightCompetitions != nil && self.todayMatches.isNotEmpty {
            return nil
        }
        else if section == 0 && self.outrightCompetitions != nil && self.todayMatches.isEmpty {
            ()
        }
        else if self.todayMatches.isEmpty {
            return nil
        }

        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
            as? TitleTableViewHeader {

            headerView.configureWithTitle(localized("upcoming"))

            headerView.setSearchIcon(hasSearch: true)

            headerView.shouldShowSearch = { [weak self] in
                self?.shouldShowSearch?()
            }
            
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.outrightCompetitions != nil && self.todayMatches.isEmpty {
            return 54
        }

        if self.todayMatches.isEmpty {
            return .leastNonzeroMagnitude
        }

        if section == 1 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.outrightCompetitions != nil && self.todayMatches.isEmpty {
            return 54
        }

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
            return 70 // Loading cell
        case 3:
            return UITableView.automaticDimension // Footer
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 145 // Outrights
        case 2:
            return 70 // Loading cell
        case 3:
            return 120 // Footer
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
