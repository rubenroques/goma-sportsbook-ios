//
//  HomeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class HomeViewModel {

    enum Content {
        case userMessage
        case userFavorites
        case bannerLine
        case suggestedBets
        case sport(Sport)

        var identifier: String {
            switch self {
            case .userMessage: return "userMessage"
            case .userFavorites: return "userFavorites"
            case .bannerLine: return "bannerLine"
            case .suggestedBets: return "suggestedBets"
            case .sport(let sport): return "sport[\(sport)]"
            }
        }
    }

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var scrollToContentPublisher = PassthroughSubject<Int?, Never>.init()

    private let itemsPreSports = 4
    private var userMessages: [String] = []
    
    //
    private var favoriteMatchesIds: [String] = [] {
        didSet {
            var matches: [Match] = []
            for matchId in self.favoriteMatchesIds {
                if let match = self.store.matchWithId(id: matchId) {
                    matches.append(match)
                }
            }
            self.favoriteMatches = matches
        }
    }
    private var favoriteMatches: [Match] = [] {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var banners: [BannerInfo] = [] {
        didSet {
            var bannerCellViewModels: [BannerCellViewModel] = []

            for banner in self.banners {
                if let bannerViewModel = self.bannersLineViewModelCache[banner.id] {
                    bannerCellViewModels.append(bannerViewModel)
                }
                else {
                    let bannerViewModel = BannerCellViewModel(id: banner.id,
                                                              matchId: banner.matchId,
                                                              imageURL: banner.imageURL ?? "")
                    bannerCellViewModels.append(bannerViewModel)
                    self.bannersLineViewModelCache[banner.id] = bannerViewModel
                }
            }

            self.bannersLineViewModel = BannerLineCellViewModel(banners: bannerCellViewModels)
        }
    }
    private var bannersLineViewModelCache: [String: BannerCellViewModel] = [:]
    private var bannersLineViewModel: BannerLineCellViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }
    
    //
    private var suggestedBets: [SuggestedBetCardSummary] = []
    private var suggestedBetLineViewModel: SuggestedBetLineViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

    //
    private var sportsToFetch: [Sport] = []
    private var sportsLineViewModelsCache: [String: SportMatchLineViewModel] = [:]
    
    //
    // EM Registers
    private var bannersInfoRegister: EndpointPublisherIdentifiable?
    private var favoriteMatchesRegister: EndpointPublisherIdentifiable?

    // Combine Publishers
    private var bannersInfoPublisher: AnyCancellable?
    private var favoriteMatchesPublisher: AnyCancellable?

    // Updatable Storage
    private var store: HomeStore = HomeStore()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    init() {
        self.refresh()
    }

    func refresh() {
        self.requestSports()
        self.fetchBanners()
        self.fetchFavoriteMatches()
        self.fetchSuggestedBets()
    }

    func requestSports() {

        let language = "en"
        Env.everyMatrixClient.getDisciplines(language: language)
            .map(\.records)
            .compactMap({ $0 })
            .sink(receiveCompletion: { _ in

            }, receiveValue: { response in
                self.sportsToFetch = Array(response.map(Sport.init(discipline:)).prefix(10))
                self.refreshPublisher.send()
            })
            .store(in: &cancellables)
    }

    // Banners
    func stopBannerUpdates() {
        if let bannersInfoRegister = bannersInfoRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: bannersInfoRegister)
        }

        self.bannersInfoPublisher?.cancel()
        self.bannersInfoPublisher = nil
    }

    func fetchBanners() {

        self.stopBannerUpdates()

        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")

        self.bannersInfoPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.bannersInfoRegister = publisherIdentifiable
                case .initialContent(let responde):
                    print("HomeViewModel bannersInfo initialContent")
                    let sortedBanners = (responde.records ?? []).sorted {
                        $0.priorityOrder ?? 0 < $1.priorityOrder ?? 1
                    }
                    self?.banners = sortedBanners.map({
                        BannerInfo(type: $0.type,
                                   id: $0.id,
                                   matchId: $0.matchID,
                                   imageURL: $0.imageURL,
                                   priorityOrder: $0.priorityOrder)
                    })
                    self?.stopBannerUpdates()
                case .updatedContent:
                    ()
                case .disconnect:
                    ()
                }
            })
    }

    // Favorites
    private func fetchFavoriteMatches() {

        if let favoriteMatchesRegister = favoriteMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: favoriteMatchesRegister)
        }

        guard let userId = Env.userSessionStore.userSessionPublisher.value?.userId else { return }

        let endpoint = TSRouter.favoriteMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      userId: userId)

        self.favoriteMatchesPublisher?.cancel()
        self.favoriteMatchesPublisher = nil

        self.favoriteMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving Favorite data!")

                case .finished:
                    print("Favorite Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher connect")
                    self?.favoriteMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher initialContent")
                    self?.setupFavoriteMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("PreLiveEventsViewModel favoriteMatchesPublisher updatedContent")
                    self?.updateFavoriteMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("PreLiveEventsViewModel favoriteMatchesPublisher disconnect")
                }

            })
    }

    private func setupFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.storeContent(fromAggregator: aggregator)

        var matchesIds: [String] = []
        for content in aggregator.content ?? [] {
            switch content {
            case .match(let matchContent):
                matchesIds.append(matchContent.id)
            default:
                ()
            }
        }
        self.favoriteMatchesIds = Array(matchesIds.prefix(2))
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }
    
    // Suggested Bets
    func fetchSuggestedBets() {
        
        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .compactMap({$0})
            .map({ betGroupsArray in
                var cardsSummaryArray: [SuggestedBetCardSummary] = []
                for betGroup in betGroupsArray {
                    cardsSummaryArray.append(SuggestedBetCardSummary.init(bets: betGroup))
                }
                return cardsSummaryArray
            })
            .sink(receiveCompletion: { _ in
            },
            receiveValue: { [weak self] suggestedBets in
                self?.suggestedBets = suggestedBets
            })
            .store(in: &cancellables)
    }
}

extension HomeViewModel {

    func didSelectShortcut(atSection section: Int) {
        self.scrollToContentPublisher.send(section)
    }

}

extension HomeViewModel {

    func numberOfShortcutsSections() -> Int {
        return itemsPreSports + sportsToFetch.count
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return self.favoriteMatches.isEmpty ? 0 : 1
        case 3:
            return self.suggestedBets.isEmpty ? 0 : 1
        default:
            return 1
        }
    }

    func shortcutTitle(forSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return nil
        case 2:
            return "My Games"
        case 3:
            return "Suggested Bets"
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-itemsPreSports] {
                return sportForIndex.name
            }
            else {
                return nil
            }
        }
    }

    func numberOfSections() -> Int {
        return itemsPreSports + sportsToFetch.count
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            if let bannersLineViewModel = self.bannersLineViewModel,
               bannersLineViewModel.banners.isNotEmpty {
                return 1
            }
            else {
                return 0
            }
        case 2: return self.favoriteMatches.count
        case 3: return self.suggestedBets.isEmpty ? 0 : 1
        default:
            if self.sportsToFetch[safe: section-itemsPreSports] != nil {
                return 3
            }
            else {
                return 0
            }
        }
    }

    func title(forSection section: Int) -> (String?, String?) {
        switch section {
        case 0, 1: return (nil, nil)
        case 2: return ("My Games", nil)
        case 3: return ("Suggested Bets", nil)
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-itemsPreSports] {
                return (sportForIndex.name, sportForIndex.id)
            }
            else {
                return (nil, nil)
            }
        }
    }

    func contentType(forSection section: Int) -> HomeViewModel.Content? {
        switch section {
        case 0: return HomeViewModel.Content.userMessage
        case 1: return HomeViewModel.Content.bannerLine
        case 2: return HomeViewModel.Content.userFavorites
        case 3: return HomeViewModel.Content.suggestedBets
        default:
            if let sportForIndex = self.sportsToFetch[safe: section-itemsPreSports] {
                return HomeViewModel.Content.sport(sportForIndex)
            }
            else {
                return nil
            }
        }
    }

    func bannerLineViewModel() -> BannerLineCellViewModel? {
        return self.bannersLineViewModel
    }

    func sportMatchLineViewModel(forIndexPath indexPath: IndexPath) -> SportMatchLineViewModel? {

        guard
            let contentId = self.contentType(forSection: indexPath.section)
        else {
            return nil
        }

        let matchTypeIdentifier = SportMatchLineViewModel.matchesType(forIndex: indexPath.row)?.rawValue ?? ""
        let cacheKey = "\(contentId.identifier)-\(matchTypeIdentifier)"

        if let viewModel = sportsLineViewModelsCache[cacheKey] {
            return viewModel
        }
        else if
            let sportForIndex = self.sportsToFetch[safe: indexPath.section-itemsPreSports],
            let matchType = SportMatchLineViewModel.matchesType(forIndex: indexPath.row)
        {
            let sportMatchLineViewModel = SportMatchLineViewModel(sport: sportForIndex,
                                                                  matchesType: matchType,
                                                                  store: self.store)

            self.sportsLineViewModelsCache[cacheKey] = sportMatchLineViewModel
            return sportMatchLineViewModel
        }
        return nil
    }
    
    func favoriteMatch(forIndex index: Int) -> Match? {
        return self.favoriteMatches[safe: index]
    }

    func getSuggestedBetLineViewModel() -> SuggestedBetLineViewModel? {
        
        if self.suggestedBets.isEmpty {
            return nil
        }
        
        if let suggestedBetLineViewModel = self.suggestedBetLineViewModel {
            return suggestedBetLineViewModel
        }
        else {
            self.suggestedBetLineViewModel = SuggestedBetLineViewModel(suggestedBetCardSummaries: self.suggestedBets)
            return self.suggestedBetLineViewModel
        }
    }
    
}
