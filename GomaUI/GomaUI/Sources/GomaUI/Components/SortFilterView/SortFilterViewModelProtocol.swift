//
//  SortFilterViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import Combine

public protocol SortFilterViewModelProtocol {
    var title: String { get }
    var sortOptions: [SortOption] { get }
    var selectedOptionId: CurrentValueSubject<Int, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    var shouldRefreshData: PassthroughSubject<Void, Never> { get }

    func selectOption(withId id: Int)
    func toggleCollapse()
    func updateSortOptions(_ newSortOptions: [SortOption])
}
