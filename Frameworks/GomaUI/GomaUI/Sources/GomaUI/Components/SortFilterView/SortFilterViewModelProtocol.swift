import Foundation
import Combine
import SharedModels

public enum SortFilterType{
    case regular
    case league
}

public protocol SortFilterViewModelProtocol {
    var title: String { get }
    var sortOptions: [SortOption] { get }
    var sortFilterType: SortFilterType { get }
    var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func selectFilter(_ filter: LeagueFilterIdentifier)
    func toggleCollapse()
    func updateSortOptions(_ newSortOptions: [SortOption])
}
