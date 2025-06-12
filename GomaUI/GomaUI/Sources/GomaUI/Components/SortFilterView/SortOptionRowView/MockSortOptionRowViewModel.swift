//
//  MockSortOptionRowViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation

public class MockSortOptionRowViewModel: SortOptionRowViewModelProtocol {
    
    public var sortOption: SortOption
    
    init(sortOption: SortOption) {
        
        self.sortOption = sortOption
    }
    
}
