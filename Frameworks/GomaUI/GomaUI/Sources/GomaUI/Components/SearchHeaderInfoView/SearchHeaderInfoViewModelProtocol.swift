//
//  SearchHeaderInfoViewModelProtocol.swift
//  GomaUI
//
//  Created by Assistant on 2024-12-19.
//

import Foundation
import Combine

public protocol SearchHeaderInfoViewModelProtocol: AnyObject {
    var searchTerm: String { get }
    var category: String { get }
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
