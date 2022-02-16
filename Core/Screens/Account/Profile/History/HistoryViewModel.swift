//
//  HistoryViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 14/02/2022.
//

import Foundation
import Combine
import OrderedCollections

class HistoryViewModel {

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
    enum ListType {
        case transactions
        case bettings
        
        var identifier: Int {
            switch self {
            case .transactions: return 0
            case .bettings: return 1
            
            }
        }
    }
    
    enum BettingType {
        case resolved
        case open
        case won
        case cashout
        case none
        
        var identifier: String {
            switch self {
            case .resolved: return "Resolved"
            case .open: return "Open"
            case .won: return "Won"
            case .cashout: return "Cashout"
            case .none: return "None"
            }
        }
    }
    
    

    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    var scrollToContentPublisher = PassthroughSubject<Int?, Never>.init()
    
    
    var listTypeSelected : CurrentValueSubject<ListType, Never> = .init(.transactions)
    
    var bettingTypeSelected : CurrentValueSubject<BettingType, Never> = .init(.none)

    private let itemsPreSports = 4
    private var userMessages: [String] = []
    private var suggestedBets: [String] = []

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

    private var sportsToFetch: [Sport] = []
    private var sportsLineViewModelsCache: [String: SportMatchLineViewModel] = [:]

    private var bannersLineViewModelCache: [String: BannerCellViewModel] = [:]
    private var bannersLineViewModel: BannerLineCellViewModel? {
        didSet {
            self.refreshPublisher.send()
        }
    }

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
        self.requestSports()
        self.fetchBanners()
        self.fetchFavoriteMatches()
    }

    func refresh() {

        self.requestSports()
        self.fetchBanners()
        self.fetchFavoriteMatches()
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
                    print("HistoryViewModel bannersInfo initialContent")
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
        self.favoriteMatchesIds = matchesIds
    }

    private func updateFavoriteMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        self.store.updateContent(fromAggregator: aggregator)
    }
}

extension HistoryViewModel {

    func didSelectShortcut(atSection section: Int) {
        self.scrollToContentPublisher.send(section)
    }

}

extension HistoryViewModel {

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        if listTypeSelected.value == .transactions {
            return 2
        }
        else{
            return 4
        }
       
    }

    func shortcutTitle(forIndex index: Int) -> String? {
        
        if listTypeSelected.value == .transactions {
            switch index {
            case 0:
                return "Deposits"
            case 1:
                return "Withdraws"
            default:
                return ""
            }
        }else{
            switch index {
            case 0:
                return "Resolved"
            case 1:
                return "Open"
            case 2:
                return "Won"
            case 3:
                return "Cashout"
            default:
                return ""
            }
        }
        
        
        
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        return 2
    }


}

