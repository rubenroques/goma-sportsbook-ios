import Foundation
import Combine
import GomaUI
import ServicesProvider

protocol CasinoSearchViewModelProtocol: AnyObject {
    // Loading state
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var searchTextPublisher: AnyPublisher<String, Never> { get }
    
    // Component View Models
    var searchViewModel: SearchViewModelProtocol { get }
    var searchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol { get }
    var searchedGameViewModelsPublisher: AnyPublisher<[CasinoGameSearchedViewModelProtocol], Never> { get }
    var mostPlayedGameViewModelsPublisher: AnyPublisher<[CasinoGameSearchedViewModelProtocol], Never> { get }
    
    // Inputs
    func updateSearchText(_ text: String)
    func submitSearch()
    func clearSearch()
    
    // Action
    func searchGames(query: String)
    
    // Navigation callbacks
    var onGameSelected: AnyPublisher<String, Never> { get }
}


