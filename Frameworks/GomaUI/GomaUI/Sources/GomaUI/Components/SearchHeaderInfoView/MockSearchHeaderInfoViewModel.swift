//
//  MockSearchHeaderInfoViewModel.swift
//  GomaUI
//
//  Created by Assistant on 2024-12-19.
//

import Foundation
import Combine

public class MockSearchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol {
    public var searchTerm: String
    public var category: String
    public var state: SearchState
    public var count: Int?
    
    public init(
        searchTerm: String = "",
        category: String = "",
        state: SearchState = .loading,
        count: Int? = nil
    ) {
        self.searchTerm = searchTerm
        self.category = category
        self.state = state
        self.count = count
    }
    
    public func updateSearch(term: String, category: String, state: SearchState, count: Int?) {
        self.searchTerm = term
        self.category = category
        self.state = state
        self.count = count
    }
}
