//
//  MockSortFilterViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import UIKit
import Combine

public class MockSortFilterViewModel: SortFilterViewModelProtocol {
    public let title: String
    public var sortOptions: [SortOption]
    
    public var selectedOptionId: CurrentValueSubject<Int, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    public var shouldRefreshData: PassthroughSubject<Void, Never> = .init()
    
    public init(title: String, sortOptions: [SortOption], selectedId: Int = 1) {
        self.title = title
        self.sortOptions = sortOptions
        self.selectedOptionId = .init(selectedId)
    }
    
    public func selectOption(withId id: Int) {
        selectedOptionId.send(id)
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    public func updateSortOptions(_ newSortOptions: [SortOption]) {
        // Update the internal sortOptions array
        self.sortOptions = newSortOptions
                
        self.shouldRefreshData.send()
    }
}
