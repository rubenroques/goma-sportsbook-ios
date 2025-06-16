//
//  FilterStorage.swift
//  Sportsbook
//
//  Created by André Lascas on 16/06/2025.
//

import Foundation
import Combine
import GomaUI

public class FilterStorage: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentFilterSelection: GeneralFilterSelection
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let filterSelectionKey = "user_filter_selection"
    
    // MARK: - Default Values
    public static let defaultFilterSelection = GeneralFilterSelection(
        sportId: 1,
        timeValue: 1.0,
        sortTypeId: 1,
        leagueId: 0
    )
    
    public var selectedFilterOptions: [FilterOptionItem] = []
    
    // MARK: - Initialization
    public init() {
        // Load saved filter selection or use default
        self.currentFilterSelection = Self.defaultFilterSelection
        self.currentFilterSelection = self.loadFilterSelection()
        
        self.selectedFilterOptions = self.buildFilterOptions(from: self.currentFilterSelection)
    }
    
    // MARK: - Public Methods
    
    /// Updates the current filter selection and saves it
    public func updateFilterSelection(_ newSelection: GeneralFilterSelection) {
        selectedFilterOptions = buildFilterOptions(from: newSelection)
        currentFilterSelection = newSelection
        saveFilterSelection(newSelection)
    }
    
    /// Resets filter selection to default values
    public func resetToDefault() {
        updateFilterSelection(Self.defaultFilterSelection)
    }
    
    /// Gets the current filter selection
    public func getCurrentFilterSelection() -> GeneralFilterSelection {
        return currentFilterSelection
    }
    
    /// Checks if current selection differs from default
    public func hasCustomSelection() -> Bool {
        return currentFilterSelection.sportId != Self.defaultFilterSelection.sportId ||
               currentFilterSelection.timeValue != Self.defaultFilterSelection.timeValue ||
               currentFilterSelection.sortTypeId != Self.defaultFilterSelection.sortTypeId ||
               currentFilterSelection.leagueId != Self.defaultFilterSelection.leagueId
    }
    
    /// Counts how many filters differ from default
    public func countDifferencesFromDefault() -> Int {
        var differenceCount = 0
        
        if currentFilterSelection.sportId != Self.defaultFilterSelection.sportId {
            differenceCount += 1
        }
        
        if currentFilterSelection.timeValue != Self.defaultFilterSelection.timeValue {
            differenceCount += 1
        }
        
        if currentFilterSelection.sortTypeId != Self.defaultFilterSelection.sortTypeId {
            differenceCount += 1
        }
        
        if currentFilterSelection.leagueId != Self.defaultFilterSelection.leagueId {
            differenceCount += 1
        }
        
        return differenceCount
    }
    
    // MARK: - Private Methods
    private func saveFilterSelection(_ selection: GeneralFilterSelection) {
        userDefaults.set(selection.sportId, forKey: "\(filterSelectionKey)_sportId")
        userDefaults.set(selection.timeValue, forKey: "\(filterSelectionKey)_timeValue")
        userDefaults.set(selection.sortTypeId, forKey: "\(filterSelectionKey)_sortTypeId")
        userDefaults.set(selection.leagueId, forKey: "\(filterSelectionKey)_leagueId")
    }

    private func loadFilterSelection() -> GeneralFilterSelection {
        let sportId = userDefaults.integer(forKey: "\(filterSelectionKey)_sportId")
        let timeValue = userDefaults.float(forKey: "\(filterSelectionKey)_timeValue")
        let sortTypeId = userDefaults.integer(forKey: "\(filterSelectionKey)_sortTypeId")
        let leagueId = userDefaults.integer(forKey: "\(filterSelectionKey)_leagueId")

        // If no values are saved (all return 0), use defaults
        if sportId == 0 && timeValue == 0.0 && sortTypeId == 0 && leagueId == 0 {
            return Self.defaultFilterSelection
        }

        return GeneralFilterSelection(
            sportId: sportId,
            timeValue: timeValue,
            sortTypeId: sortTypeId,
            leagueId: leagueId
        )
    }
    
    // Filters functions
    func buildFilterOptions(from selection: GeneralFilterSelection) -> [FilterOptionItem] {
        var options: [FilterOptionItem] = []
        
        if let sportOption = getSportOption(for: selection.sportId) {
            options.append(FilterOptionItem(
                type: .sport,
                title: sportOption.title,
                icon: sportOption.icon
            ))
        }
        
        if let sortOption = getSortOption(for: selection.sortTypeId) {
            options.append(FilterOptionItem(
                type: .sortBy,
                title: sortOption.title,
                icon: sortOption.icon ?? ""
            ))
        }
        
        if let leagueOption = getLeagueOption(for: selection.leagueId) {
            options.append(FilterOptionItem(
                type: .league,
                title: leagueOption.title,
                icon: leagueOption.icon ?? ""
            ))
        }
        
        return options
    }
    
    // MARK: - Helper Methods for Filter Data
    private func getSportOption(for sportId: Int) -> (title: String, icon: String)? {
        let sportOptions = [
            (id: 1, title: "Football", icon: "sport_type_icon_1"),
            (id: 2, title: "Basketball", icon: "sport_type_icon_8"),
            (id: 3, title: "Tennis", icon: "sport_type_icon_3"),
            (id: 4, title: "Cricket", icon: "sport_type_icon_9")
        ]
        
        return sportOptions.first { $0.id == sportId }.map { (title: $0.title, icon: $0.icon) }
    }
    
    private func getSortOption(for sortId: Int) -> SortOption? {
        // Replicate the same data structure from createSortFilterViewModel
        let sortOptions = [
            SortOption(id: 1, icon: "popular_icon", title: "Popular", count: 25),
            SortOption(id: 2, icon: "timelapse_icon", title: "Upcoming", count: 15),
            SortOption(id: 3, icon: "favourites_icon", title: "Favourites", count: 0)
        ]
        
        return sortOptions.first { $0.id == sortId }
    }

    private func getLeagueOption(for leagueId: Int) -> SortOption? {
        // Replicate the same data structure from CombinedFiltersViewModel.getPopularLeagues()
        var allLeaguesOption = SortOption(id: 0, icon: "league_icon", title: "All Popular Leagues", count: 0)
        
        let leagueOptions = [
            allLeaguesOption,
            SortOption(id: 1, icon: "league_icon", title: "Premier League", count: 32),
            SortOption(id: 16, icon: "league_icon", title: "La Liga", count: 28),
            SortOption(id: 10, icon: "league_icon", title: "Bundesliga", count: 25),
            SortOption(id: 13, icon: "league_icon", title: "Serie A", count: 27),
            SortOption(id: 7, icon: "league_icon", title: "Ligue 1", count: 0),
            SortOption(id: 19, icon: "league_icon", title: "Champions League", count: 16),
            SortOption(id: 20, icon: "league_icon", title: "Europa League", count: 12),
            SortOption(id: 8, icon: "league_icon", title: "MLS", count: 28),
            SortOption(id: 28, icon: "league_icon", title: "Eredivisie", count: 18),
            SortOption(id: 24, icon: "league_icon", title: "Primeira Liga", count: 16)
        ]
        
        return leagueOptions.first { $0.id == leagueId }
    }
}

public struct GeneralFilterSelection: Codable {
    var sportId: Int
    var timeValue: Float
    var sortTypeId: Int
    var leagueId: Int
}
