//
//  SportsSearchViewModel.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import Foundation
import Combine
import GomaUI

final class SportsSearchViewModel: SportsSearchViewModelProtocol {
    
    // MARK: - Properties
    
    // Publishers
    var searchTextPublisher: AnyPublisher<String, Never> {
        searchTextSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var searchResultsPublisher: AnyPublisher<[SearchResult], Never> {
        searchResultsSubject.eraseToAnyPublisher()
    }
    
    var onSearchSubmitted: AnyPublisher<String, Never> {
        searchSubmittedSubject.eraseToAnyPublisher()
    }
    
    // Component View Models
    var searchViewModel: SearchViewModelProtocol {
        return searchComponentViewModel
    }
    
    // Subjects
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let searchResultsSubject = CurrentValueSubject<[SearchResult], Never>([])
    private let searchSubmittedSubject = PassthroughSubject<String, Never>()
    
    // Component View Models
    private let searchComponentViewModel: SearchViewModelProtocol
    
    // Dependencies
    private let userSessionStore: UserSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    // Search state
    private var currentSearchText: String = ""
    
    // MARK: - Initialization
    
    init(userSessionStore: UserSessionStore) {
        self.userSessionStore = userSessionStore
        
        // Create the SearchView's view model
        self.searchComponentViewModel = MockSearchViewModel.default
        
        setupSearchComponentBindings()
    }
    
    // MARK: - SportsSearchViewModelProtocol
    
    func updateSearchText(_ text: String) {
        currentSearchText = text
        searchTextSubject.send(text)
        performSearch(text)
    }
    
    func submitSearch() {
        guard !currentSearchText.isEmpty else { return }
        
        searchSubmittedSubject.send(currentSearchText)
        performSearch(currentSearchText)
    }
    
    func clearSearch() {
        currentSearchText = ""
        searchTextSubject.send("")
        searchResultsSubject.send([])
    }
    
    // MARK: - Private Methods
    
    private func setupSearchComponentBindings() {
        // Connect SearchView's text changes to our search logic with debouncing
        searchComponentViewModel.textPublisher
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                print("SEARCH NOW!")
                self?.updateSearchText(text)
            }
            .store(in: &cancellables)
        
        // Connect SearchView's clear action to our clear logic
        searchComponentViewModel.textPublisher
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                self?.clearSearch()
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        guard !searchText.isEmpty else {
            searchResultsSubject.send([])
            return
        }
        
        isLoadingSubject.send(true)
        
        // Simulate search delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            self?.isLoadingSubject.send(false)
//            
//            // Mock search results for now
//            let mockResults = self?.generateMockSearchResults(for: searchText) ?? []
//            self?.searchResultsSubject.send(mockResults)
//        }
        Env.servicesProvider.getSearchEvents(query: searchText, resultLimit: "20", page: "0")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SEARCH ERROR: \(error)")
                    self?.searchResultsSubject.send([])
                }

                self?.isLoadingSubject.send(false)
            }, receiveValue: { [weak self] eventsGroup in

                print("SPORTS SEARCH: \(eventsGroup)")
            })
            .store(in: &cancellables)
    }
    
    private func generateMockSearchResults(for searchText: String) -> [SearchResult] {
        // Mock data for demonstration
        let mockResults = [
            SearchResult(
                id: "1",
                title: "Football",
                subtitle: "Sport",
                type: .sport,
                imageUrl: nil
            ),
            SearchResult(
                id: "2",
                title: "Premier League",
                subtitle: "Football League",
                type: .league,
                imageUrl: nil
            ),
            SearchResult(
                id: "3",
                title: "Manchester United",
                subtitle: "Football Team",
                type: .team,
                imageUrl: nil
            ),
            SearchResult(
                id: "4",
                title: "Manchester United vs Liverpool",
                subtitle: "Premier League Match",
                type: .match,
                imageUrl: nil
            )
        ]
        
        // Filter results based on search text
        return mockResults.filter { result in
            result.title.localizedCaseInsensitiveContains(searchText) ||
            result.subtitle?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
}
