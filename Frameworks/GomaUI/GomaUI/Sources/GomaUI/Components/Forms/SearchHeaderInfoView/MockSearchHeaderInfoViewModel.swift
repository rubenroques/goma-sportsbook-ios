//
//  MockSearchHeaderInfoViewModel.swift
//  GomaUI
//
//  Created on 2024-12-19.
//

import Foundation
import Combine

public class MockSearchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol {
    public var searchTerm: String
    public var categoryString: String
    public var showResultsString: String
    public var noResultsString: String
    public var searchingString: String
    public var state: SearchState
    public var count: Int?
    
    public var statePublisher: AnyPublisher<SearchState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    public var refreshData: (() -> Void)?
    
    private let stateSubject = CurrentValueSubject<SearchState, Never>(.loading)
    
    public init(
        searchTerm: String = "",
        categoryString: String = "",
        showResultsString: String = "",
        noResultsString: String = "",
        searchingString: String = "",
        state: SearchState = .loading,
        count: Int? = nil
    ) {
        self.searchTerm = searchTerm
        self.categoryString = categoryString
        self.showResultsString = showResultsString
        self.noResultsString = noResultsString
        self.searchingString = searchingString
        self.state = state
        self.count = count
        self.stateSubject.send(state)
    }
    
    public func updateSearch(term: String, category: String, state: SearchState, count: Int?) {
        self.searchTerm = term
        self.categoryString = category
        self.state = state
        self.count = count
        self.stateSubject.send(state)
        
        self.refreshData?()
    }
}
