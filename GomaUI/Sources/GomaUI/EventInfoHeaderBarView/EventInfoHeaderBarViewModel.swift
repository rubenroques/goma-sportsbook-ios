//
//  EventInfoHeaderBarViewModel.swift
//  GomaUI
//
//  Created by Ruben Roques on 16/10/2024.
//

import Combine
import GomaAssets

public class EventInfoHeaderBarViewModel: ObservableObject {

    @Published public var isStarSelected: Bool = false
    @Published public var sportIconName: String?
    @Published public var countryIconName: String?
    @Published public var competitionName: String = ""

    public init(isStarSelected: Bool, sportIconName: String?, countryIconName: String?, competitionName: String) {
        self.isStarSelected = isStarSelected
        self.sportIconName = sportIconName
        self.countryIconName = countryIconName
        self.competitionName = competitionName
    }

    public func toggleStar() {
        self.isStarSelected.toggle()
    }
    
    public func updateIcons(sportName: String?, countryName: String?) {
        self.sportIconName = sportName
        self.countryIconName = countryName
    }
    
    public func updateCompetitionName(_ name: String) {
        self.competitionName = name
    }
    
}

public extension EventInfoHeaderBarViewModel {
    static let debug: EventInfoHeaderBarViewModel = EventInfoHeaderBarViewModel(
        isStarSelected: false,
        sportIconName: "football",
        countryIconName: "spain",
        competitionName: "Competition Name"
    )
    static let empty: EventInfoHeaderBarViewModel = EventInfoHeaderBarViewModel(
        isStarSelected: false,
        sportIconName: "",
        countryIconName: "",
        competitionName: ""
    )
}
