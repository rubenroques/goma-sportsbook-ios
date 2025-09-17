//
//  SportsSearchViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import Foundation
import Combine
import GomaUI

protocol SportsSearchViewModelProtocol: AnyObject {
    
    // MARK: - Publishers
    var searchTextPublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var searchResultsPublisher: AnyPublisher<[SearchResult], Never> { get }
    
    // MARK: - Component View Models
    var searchViewModel: SearchViewModelProtocol { get }
    
    // MARK: - Actions
    var onSearchSubmitted: AnyPublisher<String, Never> { get }
    
    // MARK: - Input Methods
    func updateSearchText(_ text: String)
    func submitSearch()
    func clearSearch()
}

// MARK: - Search Result Model
struct SearchResult: Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let type: SearchResultType
    let imageUrl: String?
    
    enum SearchResultType: String, CaseIterable {
        case sport = "sport"
        case league = "league"
        case team = "team"
        case match = "match"
    }
}
