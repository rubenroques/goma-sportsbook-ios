//
//  SearchHeaderInfoViewModelProtocol.swift
//  GomaUI
//
//  Created on 2024-12-19.
//

import Foundation
import Combine

public protocol SearchHeaderInfoViewModelProtocol: AnyObject {
    var searchTerm: String { get }
    var categoryString: String { get }
    var showResultsString: String { get }
    var noResultsString: String { get }
    var searchingString: String { get }
    var state: SearchState { get }
    var count: Int? { get }
    var statePublisher: AnyPublisher<SearchState, Never> { get }
    
    var refreshData: (() -> Void)? { get set }
    
    func updateSearch(term: String, category: String, state: SearchState, count: Int?)
}

public enum SearchState {
    case loading
    case results
    case noResults
}
