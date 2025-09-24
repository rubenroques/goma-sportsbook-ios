import Foundation
import Combine
import GomaUI
import ServicesProvider

final class CasinoSearchViewModel: CasinoSearchViewModelProtocol {
    
    // MARK: - Outputs
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    var searchTextPublisher: AnyPublisher<String, Never> { searchTextSubject.eraseToAnyPublisher() }
    private let gameSelectedSubject = PassthroughSubject<String, Never>()
    var onGameSelected: AnyPublisher<String, Never> { gameSelectedSubject.eraseToAnyPublisher() }
    
    // MARK: - Component View Models
    private let searchComponentViewModel: SearchViewModelProtocol
    let searchHeaderInfoViewModel: SearchHeaderInfoViewModelProtocol
    var searchViewModel: SearchViewModelProtocol { searchComponentViewModel }
    
    // MARK: - Dependencies
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State
    private var currentSearchText: String = ""
    private let searchedGameViewModelsSubject = CurrentValueSubject<[CasinoGameSearchedViewModelProtocol], Never>([])
    var searchedGameViewModelsPublisher: AnyPublisher<[CasinoGameSearchedViewModelProtocol], Never> { searchedGameViewModelsSubject.eraseToAnyPublisher() }
    private let mostPlayedGameViewModelsSubject = CurrentValueSubject<[CasinoGameSearchedViewModelProtocol], Never>([])
    var mostPlayedGameViewModelsPublisher: AnyPublisher<[CasinoGameSearchedViewModelProtocol], Never> { mostPlayedGameViewModelsSubject.eraseToAnyPublisher() }
    
    // MARK: - Init
    init(servicesProvider: ServicesProvider.Client = Env.servicesProvider) {
        self.servicesProvider = servicesProvider
        self.searchComponentViewModel = MockSearchViewModel(placeholder: "Search in Casino")
        self.searchHeaderInfoViewModel = MockSearchHeaderInfoViewModel()
        setupBindings()
        
        getMostPlayedGames()
    }
    
    private func getMostPlayedGames() {
        let playerId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
        guard !playerId.isEmpty else { return }
        
        servicesProvider.getMostPlayedGames(playerId: playerId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("MOST PLAYED FAILED: \(error)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Map to CasinoGameSearchedViewModelProtocol
                let gameCardsData = response.games.map {
                    ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: $0)
                }
                let viewModels: [CasinoGameSearchedViewModelProtocol] = gameCardsData.map { game in
                    let data = CasinoGameSearchedData(
                        id: game.id,
                        title: game.name,
                        provider: game.provider != nil ? game.provider : game.subProvider,
                        imageURL: game.imageURL
                    )
                    let viewModel = MockCasinoGameSearchedViewModel(data: data, state: .normal)
                    viewModel.onSelected
                        .sink { [weak self] gameId in
                            self?.gameSelectedSubject.send(gameId)
                        }
                        .store(in: &self.cancellables)
                    return viewModel
                }
                self.mostPlayedGameViewModelsSubject.send(viewModels)
            }
            .store(in: &cancellables)
    }
    
    private func setupBindings() {
        // Connect SearchView's text changes to our search logic with debouncing
        searchComponentViewModel.textPublisher
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
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
    
    // MARK: - Inputs
    func updateSearchText(_ text: String) {
        currentSearchText = text
        searchTextSubject.send(text)
        searchGames(query: currentSearchText)
    }
    
    func submitSearch() {
        guard !currentSearchText.isEmpty else { return }
        searchGames(query: currentSearchText)
    }
    
    func clearSearch() {
        currentSearchText = ""
        searchTextSubject.send("")
        // When cleared, keep most played in memory but UI should hide sections via controller logic
    }
    
    // MARK: - Action
    func searchGames(query: String) {
        
        guard !query.isEmpty else {
            self.searchedGameViewModelsSubject.send([])
            return
        }
                
        isLoadingSubject.send(true)
        updateSearchResultsState(isLoading: true, results: 0)

        servicesProvider.searchGames(language: nil, name: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingSubject.send(false)
                if case .failure(_) = completion {
                    self?.searchedGameViewModelsSubject.send([])
                    self?.searchHeaderInfoViewModel.updateSearch(term: query, category: "Casino", state: .noResults, count: 0)
                }
            } receiveValue: { [weak self] response in
                self?.isLoadingSubject.send(false)
                // Map games to CasinoGameSearchedViewModelProtocol and store
                let gameCardsData = response.games.map {
                    ServiceProviderModelMapper.casinoGameCardData(fromCasinoGame: $0)
                }
                
                let viewModels = gameCardsData.map { game in
                    let data = CasinoGameSearchedData(
                        id: game.id,
                        title: game.name,
                        provider: game.provider != nil ? game.provider : game.subProvider,
                        imageURL: game.imageURL
                    )
                    
                    let viewModel = MockCasinoGameSearchedViewModel(data: data, state: .normal)
                    
                    viewModel.onSelected
                        .sink { [weak self] gameId in
                            self?.gameSelectedSubject.send(gameId)
                        }
                        .store(in: &self!.cancellables)
                    
                    return viewModel
                }
                self?.searchedGameViewModelsSubject.send(viewModels)
                let count = viewModels.count
                let state: SearchState = count > 0 ? .results : .noResults
                self?.searchHeaderInfoViewModel.updateSearch(term: query, category: "Casino", state: state, count: count)
            }
            .store(in: &cancellables)
    }
    
    private func updateSearchResultsState(isLoading: Bool, results: Int) {
        
        // Get current search text from the view model
        let searchText = currentSearchText
        
        // Determine state based on loading status and results
        let state: SearchState
        if isLoading {
            state = .loading
        } else if results == 0 {
            state = .noResults
        } else {
            state = .results
        }
        
        let count = results > 0 ? results : nil
        
        // Update the view model with new data
        searchHeaderInfoViewModel.updateSearch(
            term: searchText,
            category: "Casino",
            state: state,
            count: count
        )
        
    }
}


