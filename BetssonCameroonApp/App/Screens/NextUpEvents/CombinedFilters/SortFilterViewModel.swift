import Foundation
import UIKit
import Combine
import SharedModels
import GomaUI

public class SortFilterViewModel: SortFilterViewModelProtocol {
    public let title: String
    public var sortOptions: [SortOption]
    public var sortFilterType: SortFilterType

    public var selectedFilter: CurrentValueSubject<LeagueFilterIdentifier, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    public var shouldRefreshData: PassthroughSubject<Void, Never> = .init()

    public init(title: String, sortOptions: [SortOption], selectedFilter: LeagueFilterIdentifier = .all, sortFilterType: SortFilterType = .regular) {
        self.title = title
        self.sortOptions = sortOptions
        self.sortFilterType = sortFilterType
        self.selectedFilter = .init(selectedFilter)
    }

    public func selectFilter(_ filter: LeagueFilterIdentifier) {
        selectedFilter.send(filter)
    }

    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }

    public func updateSortOptions(_ newSortOptions: [SortOption]) {
        self.sortOptions = newSortOptions
        self.shouldRefreshData.send()
    }
}
