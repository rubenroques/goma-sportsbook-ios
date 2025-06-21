//
//  SortFilterViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import Combine

public enum SortFilterType{
    case regular
    case league
}

public protocol SortFilterViewModelProtocol {
    var title: String { get }
    var sortOptions: [SortOption] { get }
    var sortFilterType: SortFilterType { get }
    var selectedOptionId: CurrentValueSubject<String, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func selectOption(withId id: String)
    func toggleCollapse()
    func updateSortOptions(_ newSortOptions: [SortOption])
}
