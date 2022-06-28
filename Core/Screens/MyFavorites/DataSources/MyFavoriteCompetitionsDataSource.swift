//
//  MyFavoriteCompetitionsDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 11/02/2022.
//

import Foundation
import UIKit

class MyFavoriteCompetitionsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var competitions: [Competition] = []
    var outrightCompetitions: [Competition] = []
    
    var collapsedCompetitionsSections: Set<Int> = []
    
    var cachedMatchWidgetCellViewModels: [String: MatchWidgetCellViewModel] = [:]
    
    var didSelectMatchAction: ((Match) -> Void)?
    var didTapFavoriteCompetitionAction: ((Competition) -> Void)?
    var didTapFavoriteMatchAction: ((Match) -> Void)?
    
    var didSelectCompetitionAction: ((Competition) -> Void)?
    
    var matchWentLiveAction: (() -> Void)?
    
    var matchStatsViewModelForMatch: ((Match) -> MatchStatsViewModel?)?
    
    var store: AggregatorStore
    
    init(favoriteCompetitions: [Competition], favoriteOutrightCompetitions: [Competition], store: AggregatorStore) {
        self.store = store
        self.competitions = favoriteCompetitions
        self.outrightCompetitions = favoriteOutrightCompetitions
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let outrightsSections = 1
        let competitionsCount = competitions.count
        return  outrightsSections + competitionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.outrightCompetitions.count
        }
        if let competition = competitions[safe: section-1] {
            return competition.matches.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: OutrightCompetitionLargeLineTableViewCell.identifier)
                    as? OutrightCompetitionLargeLineTableViewCell,
                let competition = self.outrightCompetitions[safe: indexPath.row]
            else {
                fatalError()
            }
            
            cell.configure(withViewModel: OutrightCompetitionLargeLineViewModel(competition: competition))
            cell.didSelectCompetitionAction = { [weak self] competition in
                self?.didSelectCompetitionAction?(competition)
            }
            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
                let competition = self.competitions[safe: indexPath.section-1],
                let match = competition.matches[safe: indexPath.row]
            else {
                fatalError()
            }
            
            if let matchStatsViewModel = self.matchStatsViewModelForMatch?(match) {
                cell.matchStatsViewModel = matchStatsViewModel
            }
            
            if !collapsedCompetitionsSections.contains(indexPath.section) {
                if self.store.hasMatchesInfoForMatch(withId: match.id) {
                    cell.setupWithMatch(match, liveMatch: true, store: self.store)
                }
                else {
                    cell.setupWithMatch(match, store: self.store)
                }
                cell.shouldShowCountryFlag(false)
                cell.tappedMatchLineAction = { [weak self] in
                    self?.didSelectMatchAction?(match)
                }
                cell.matchWentLive = { [weak self] in
                    self?.matchWentLiveAction?()
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        else {
            
            guard
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TournamentTableViewHeader.identifier)
                    as? TournamentTableViewHeader,
                let competition = self.competitions[safe: section-1]
            else {
                if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier)
                    as? TitleTableViewHeader {
                    headerView.configureWithTitle(localized("my_competitions"))
                    return headerView
                }
                return UIView()
            }
            
            headerView.nameTitleLabel.text = competition.name
            headerView.countryFlagImageView.image = UIImage(named: Assets.flagName(withCountryCode: competition.venue?.isoCode ?? ""))
            headerView.sectionIndex = section
            headerView.competition = competition
            headerView.didToggleHeaderViewAction = { [weak self, weak tableView] section in
                guard
                    let weakSelf = self,
                    let weakTableView = tableView
                else { return }
                
                if weakSelf.collapsedCompetitionsSections.contains(section) {
                    weakSelf.collapsedCompetitionsSections.remove(section)
                }
                else {
                    weakSelf.collapsedCompetitionsSections.insert(section)
                }
                
                weakSelf.needReloadSection(section, tableView: weakTableView)
                
                if weakSelf.collapsedCompetitionsSections.contains(section) {
                    headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
                }
                else {
                    headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
                }
            }
            if self.collapsedCompetitionsSections.contains(section) {
                headerView.collapseImageView.image = UIImage(named: "arrow_down_icon")
            }
            else {
                headerView.collapseImageView.image = UIImage(named: "arrow_up_icon")
            }
            
            headerView.didTapFavoriteCompetitionAction = {[weak self] competition in
                self?.didTapFavoriteCompetitionAction?(competition)
            }
            
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .leastNormalMagnitude
        }
        else {
            return 54
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .leastNormalMagnitude
        }
        else {
            return 54
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if competitions.isEmpty {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch StyleHelper.cardsStyleActive() {
            case .small: return  125
            case .normal: return 154
            }
        }
        else if self.collapsedCompetitionsSections.contains(indexPath.section) {
            return .leastNormalMagnitude
        }
        else if competitions.isEmpty {
            return 600
        }
        else {
            return StyleHelper.cardsStyleHeight() + 20
        }
    }
    
    func needReloadSection(_ section: Int, tableView: UITableView) {
        
        guard let competition = self.competitions[safe: section-1] else { return }
        
        let rows = (0 ..< competition.matches.count).map({ IndexPath(row: $0, section: section) }) // all section rows
        
        tableView.beginUpdates()
        tableView.reloadRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }
    
}
