import Foundation
import Combine
import SharedModels

public protocol LeaguesFilterViewModelProtocol {
    var leagueOptions: [LeagueOption] { get }
    var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }

    func selectFilter(_ filter: LeagueFilterIdentifier)
    func toggleCollapse()
}
