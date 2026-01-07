import Foundation
import UIKit
import Combine
import SharedModels

public class MockLeaguesFilterViewModel: LeaguesFilterViewModelProtocol {
    public let leagueOptions: [LeagueOption]

    public var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)

    public init(leagueOptions: [LeagueOption], selectedFilter: LeagueFilterIdentifier = .all) {
        self.leagueOptions = leagueOptions
        self.selectedFilter = .init(selectedFilter)
    }

    public func selectFilter(_ filter: LeagueFilterIdentifier) {
        selectedFilter.send(filter)
    }

    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
}
