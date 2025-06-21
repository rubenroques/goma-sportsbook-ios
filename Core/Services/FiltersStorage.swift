//
//  FilterStorage.swift
//  Sportsbook
//
//  Created by André Lascas on 16/06/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

public class FilterStorage: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentFilterSelection: GeneralFilterSelection
    @Published var currentCompetitions: [Competition] = []

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let filterSelectionKey = "user_filter_selection"
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Default Values
    public static let defaultFilterSelection = GeneralFilterSelection(
        sportId: "1",
        timeValue: 1.0,
        sortTypeId: "1",
        leagueId: "all"
    )
    
    // MARK: - Initialization
    public init() {
        // Load saved filter selection or use default
        self.currentFilterSelection = Self.defaultFilterSelection
        self.currentFilterSelection = self.loadFilterSelection()
        
    }
    
    public func getCurrentCompetitions() {
        
        let sportType = SportType(name: "",
                                  numericId: self.currentFilterSelection.sportId,
                                  alphaId: self.currentFilterSelection.sportId,
                                  iconId: nil, showEventCategory: false,
                                  numberEvents: 0,
                                  numberOutrightEvents: 0,
                                  numberOutrightMarkets: 0,
                                  numberLiveEvents: 0)
        
        Env.servicesProvider.subscribeSportTournaments(
            forSportType: sportType
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("✅ Sport Tournaments subscription completed")
                case .failure(let error):
                    print("❌ Sport Tournaments subscription failed: \(error)")
                }
            },
            receiveValue: { subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    print("🔗 Connected to Sport Tournaments stream with subscription: \(subscription.id)")
                    
                case .contentUpdate(let tournaments):
                    
                    print("Sport tournaments received: \(tournaments)")
                    
                    let popularCompetitions = ServiceProviderModelMapper.competitions(fromTournaments: tournaments)
                    
                    self.currentCompetitions = popularCompetitions
                    
                case .disconnected:
                    print("🔌 Disconnected from Popular Tournaments stream")
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Updates the current filter selection and saves it
    public func updateFilterSelection(_ newSelection: GeneralFilterSelection) {
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
        let sportId = userDefaults.string(forKey: "\(filterSelectionKey)_sportId")
        let timeValue = userDefaults.float(forKey: "\(filterSelectionKey)_timeValue")
        let sortTypeId = userDefaults.string(forKey: "\(filterSelectionKey)_sortTypeId")
        let leagueId = userDefaults.string(forKey: "\(filterSelectionKey)_leagueId")

        // If no values are saved (all return 0), use defaults
        if sportId == "0" && timeValue == 0.0 && sortTypeId == "0" && leagueId == "all" {
            return Self.defaultFilterSelection
        }

        return GeneralFilterSelection(
            sportId: sportId ?? "1",
            timeValue: timeValue,
            sortTypeId: sortTypeId ?? "0",
            leagueId: leagueId ?? "all"
        )
    }
    
}

public struct GeneralFilterSelection: Codable {
    var sportId: String
    var timeValue: Float
    var sortTypeId: String
    var leagueId: String
}
