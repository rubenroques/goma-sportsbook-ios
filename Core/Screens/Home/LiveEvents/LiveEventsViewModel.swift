//
//  LiveEventsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/10/2021.
//

import UIKit
import Combine
import OrderedCollections

class LiveEventsViewModel: NSObject {

    private var banners: [EveryMatrix.BannerInfo] = []
    private var bannersViewModel: BannerLineCellViewModel?
    private var userMessages: [String] = []

    private var allMatches: [Match] = []

    var matchListTypePublisher: CurrentValueSubject<MatchListType, Never> = .init(.allMatches)
    enum MatchListType {
        case allMatches
    }

    enum screenState {
            case emptyAndFilter
            case emptyNoFilter
            case noEmptyNoFilter
            case noEmptyAndFilter
        }
    
    var screenStatePublisher: CurrentValueSubject<screenState, Never> = .init(.noEmptyNoFilter)
    
    private var allMatchesViewModelDataSource = AllMatchesViewModelDataSource(banners: [], allMatches: [])

    private var isLoadingAllEventsList: CurrentValueSubject<Bool, Never> = .init(true)

    var isLoading: AnyPublisher<Bool, Never>

    var sportsRepository: SportsAggregatorRepository = SportsAggregatorRepository()
    var selectedSportNumberofLiveEvents: Int = 0
    var liveSportsPublisher: AnyCancellable?
    var liveSportsRegister: EndpointPublisherIdentifiable?
    var updateNumberOfLiveEventsAction: (() -> Void)?
    var currentLiveSportsPublisher: AnyCancellable?

    var didChangeSportType = false
    var selectedSport: Sport {
        willSet {
            if newValue.id != self.selectedSport.id {
                didChangeSportType = true
            }
        }
        didSet {
            self.fetchData()
        }
    }

    var homeFilterOptions: HomeFilterOptions? {
        didSet {
            self.updateContentList()
        }
    }
    var dataDidChangedAction: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    private var sportsCancellables = Set<AnyCancellable>()
    private var allMatchesPublisher: AnyCancellable?
    private var bannersInfoPublisher: AnyCancellable?

    private var allMatchesRegister: EndpointPublisherIdentifiable?
    private var bannersInfoRegister: EndpointPublisherIdentifiable?

    private var allMatchesCount = 10
    private var allMatchesPage = 1
    private var allMatchesHasMorePages = true

    init(selectedSport: Sport) {

        self.selectedSport = selectedSport

        isLoading = isLoadingAllEventsList.eraseToAnyPublisher()

        super.init()

        self.allMatchesViewModelDataSource.requestNextPage = { [weak self] in
            self?.fetchAllMatchesNextPage()
        }

        self.allMatchesViewModelDataSource.didSelectMatchAction = { [weak self] match in
            self?.didSelectMatchAction?(match)
        }

        self.getSportsLive()

    }

    func fetchData() {
        self.isLoadingAllEventsList.send(true)

        self.allMatchesPage = 1
        self.allMatchesHasMorePages = true

        //self.fetchBanners()
        self.fetchAllMatches()

        if let sportPublisher = sportsRepository.sportsLivePublisher[self.selectedSport.id] {

            self.currentLiveSportsPublisher = sportPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {[weak self] sport in
                    self?.selectedSportNumberofLiveEvents = sport.numberOfLiveEvents ?? 0
                    self?.updateNumberOfLiveEventsAction?()
                })
        }
    }

    func getSportsLive() {

        if let liveSportsRegister = liveSportsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: liveSportsRegister)
        }

        let endpoint = TSRouter.sportsListPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en")

        self.liveSportsPublisher?.cancel()
        self.liveSportsPublisher = nil

        self.liveSportsPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.SportsAggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving liveSportsPublisher data!")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("SportsSelectorViewController liveSportsPublisher connect")
                    self?.liveSportsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("SportsSelectorViewController liveSportsPublisher initialContent")
                    self?.setupSportsAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("SportsSelectorViewController liveSportsPublisher updatedContent")
                    self?.updateSportsAggregatorProcessor(aggregator: aggregatorUpdates)
                case .disconnect:
                    print("SportsSelectorViewController liveSportsPublisher disconnect")
                }

            })
    }

    func setupSportsAggregatorProcessor(aggregator: EveryMatrix.SportsAggregator) {
        sportsRepository.processSportsAggregator(aggregator)

        if let sportPublisher = sportsRepository.sportsLivePublisher[self.selectedSport.id] {

            self.currentLiveSportsPublisher = sportPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {[weak self] sport in
                    self?.selectedSportNumberofLiveEvents = sport.numberOfLiveEvents ?? 0
                    self?.updateNumberOfLiveEventsAction?()
                })
        }
    }

    func updateSportsAggregatorProcessor(aggregator: EveryMatrix.SportsAggregator) {
        sportsRepository.processContentUpdateSportsAggregator(aggregator)

        
    }

    func filterAllMatches(with filtersOptions: HomeFilterOptions?, matches: [Match]) -> [Match] {
        guard let filterOptionsValue = filtersOptions else {
            return matches
        }

        var filteredMatches: [Match] = []
        for match in matches {
            if match.markets.isEmpty {
                continue
            }
            // Check default market order
            var marketSort: [Market] = []
            let favoriteMarketIndex = match.markets.firstIndex(where: { $0.typeId == filterOptionsValue.defaultMarket.marketId })
            marketSort.append(match.markets[favoriteMarketIndex ?? 0])
            for market in match.markets {
                if market.typeId != marketSort[0].typeId {
                    marketSort.append(market)
                }
            }

            // Check odds filter
            let matchOdds = marketSort[0].outcomes
            let oddsRange = filterOptionsValue.lowerBoundOddsRange...filterOptionsValue.highBoundOddsRange
            for odd in matchOdds {
                let oddValue = CGFloat(odd.bettingOffer.value)
                if oddsRange.contains(oddValue) {
                    var newMatch = match
                    newMatch.markets = marketSort

                    filteredMatches.append(newMatch)
                    break
                }
            }

        }
        return filteredMatches
    }

    func setMatchListType(_ matchListType: MatchListType) {
        self.matchListTypePublisher.send(matchListType)
        self.updateContentList()
    }

    private func updateContentList() {

        self.allMatchesViewModelDataSource.allMatches = filterAllMatches(with: self.homeFilterOptions, matches: self.allMatches)

        if self.allMatches.isNotEmpty, self.allMatches.count < (self.allMatchesCount * self.allMatchesPage) {
            self.allMatchesHasMorePages = false
            self.allMatchesViewModelDataSource.shouldShowLoadingCell = false
        }
        else {
            self.allMatchesViewModelDataSource.shouldShowLoadingCell = true
        }

        if let numberOfFilters = self.homeFilterOptions?.countFilters {
            if numberOfFilters > 0 {
                if !self.allMatchesViewModelDataSource.allMatches.isNotEmpty{
                    self.screenStatePublisher.send(.emptyAndFilter)
                }else{
                    self.screenStatePublisher.send(.noEmptyAndFilter)
                }
            }else{
                if !self.allMatchesViewModelDataSource.allMatches.isNotEmpty{
                    self.screenStatePublisher.send(.emptyNoFilter)
                }else{
                    self.screenStatePublisher.send(.noEmptyNoFilter)
                }
            }
        }else{
            if !self.allMatchesViewModelDataSource.allMatches.isNotEmpty{
                self.screenStatePublisher.send(.emptyNoFilter)
            }else{
                self.screenStatePublisher.send(.noEmptyNoFilter)
            }
        }
        
        //Todo - Code Review
        DispatchQueue.main.async {
            self.dataDidChangedAction?()
        }
        
        DispatchQueue.main.async {
            self.dataDidChangedAction?()
        }
    }

    private func setupAllMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .allLiveEvents,
                                                 shouldClear: true)
        self.allMatches = Env.everyMatrixStorage.matchesForListType(.allLiveEvents)
        self.isLoadingAllEventsList.send(false)

        self.updateContentList()
    }

    private func updateAllMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)
    }

    //
    // MARK: - Fetches
    //
    //
    private func fetchAllMatchesNextPage() {
        self.allMatchesPage += 1
        self.fetchAllMatches()
    }

    private func fetchAllMatches() {

        if let allMatchesRegister = allMatchesRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: allMatchesRegister)
        }

        let matchesCount = self.allMatchesCount * self.allMatchesPage

        let endpoint = TSRouter.liveMatchesPublisher(operatorId: Env.appSession.operatorId,
                                                     language: "en",
                                                     sportId: self.selectedSport.id,
                                                     matchesCount: matchesCount)

        self.allMatchesPublisher?.cancel()
        self.allMatchesPublisher = nil

        self.allMatchesPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingAllEventsList.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("LiveEventsViewModel popularMatchesPublisher connect")
                    self?.allMatchesRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("LiveEventsViewModel popularMatchesPublisher initialContent")
                    self?.setupAllMatchesAggregatorProcessor(aggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateAllMatchesAggregatorProcessor(aggregator: aggregatorUpdates)
                    print("LiveEventsViewModel popularMatchesPublisher updatedContent")
                case .disconnect:
                    print("LiveEventsViewModel popularMatchesPublisher disconnect")
                }
            })
    }

    func fetchBanners() {

        if let bannersInfoRegister = bannersInfoRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: bannersInfoRegister)
        }

        let endpoint = TSRouter.bannersInfoPublisher(operatorId: Env.appSession.operatorId, language: "en")

        self.bannersInfoPublisher?.cancel()
        self.bannersInfoPublisher = nil

        self.bannersInfoPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrixSocketResponse<EveryMatrix.BannerInfo>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.bannersInfoRegister = publisherIdentifiable
                case .initialContent(let responde):
                    print("LiveEventsViewModel bannersInfoPublisher initialContent")
                    self?.banners = responde.records ?? []
                case .updatedContent:
                    print("LiveEventsViewModel bannersInfoPublisher updatedContent")
                case .disconnect:
                    print("LiveEventsViewModel bannersInfoPublisher disconnect")
                }
                self?.updateContentList()
            })

    }

}

extension LiveEventsViewModel: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.numberOfSections(in: tableView)
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.matchListTypePublisher.value {
        case .allMatches:
            cell = self.allMatchesViewModelDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, estimatedHeightForRowAt: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch self.matchListTypePublisher.value {
        case .allMatches:
            return self.allMatchesViewModelDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

class AllMatchesViewModelDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var allMatches: [Match] = []
    var requestNextPage: (() -> Void)?
    var didSelectMatchAction: ((Match) -> Void)?

    var shouldShowLoadingCell = true

    var banners: [EveryMatrix.BannerInfo] = [] {
        didSet {
            self.bannersViewModel = self.createBannersViewModel()
        }
    }

    private var bannersViewModel: BannerLineCellViewModel?

    init(banners: [EveryMatrix.BannerInfo], allMatches: [Match]) {
        self.banners = banners
        self.allMatches = allMatches
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0 // banners.isEmpty ? 0 : 1
        case 1:
            return 0
        case 2:
            return self.allMatches.count
        case 3:
            return self.shouldShowLoadingCell ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueCellType(BannerScrollTableViewCell.self) {
                if let viewModel = self.bannersViewModel {
                    cell.setupWithViewModel(viewModel)
                }
                return cell
            }
        case 1:
            return UITableViewCell()
        case 2:
            if let cell = tableView.dequeueCellType(MatchLineTableViewCell.self),
               let match = self.allMatches[safe: indexPath.row] {
                cell.setupWithMatch(match, liveMatch: true)
                cell.tappedMatchLineAction = {
                    self.didSelectMatchAction?(match)
                }

                return cell
            }
        case 3:
            if let cell = tableView.dequeueCellType(LoadingMoreTableViewCell.self) {
                return cell
            }
        default:
            fatalError()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleTableViewHeader.identifier) as? TitleTableViewHeader
        else {
            fatalError()
        }
        headerView.configureWithTitle(localized("all_live_events")) 
        return headerView
    }

    private func createBannersViewModel() -> BannerLineCellViewModel? {
        if self.banners.isEmpty {
            return nil
        }
        var cells = [BannerCellViewModel]()
        for banner in self.banners {
            cells.append(BannerCellViewModel(matchId: banner.matchID, imageURL: banner.imageURL ?? ""))
        }
        return BannerLineCellViewModel(banners: cells)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 54
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 3:
            // Loading cell
            return 70
        default:
            return MatchWidgetCollectionViewCell.cellHeight + 20
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 3:
            // Loading cell
            return 70
        default:
            return MatchWidgetCollectionViewCell.cellHeight + 20
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3, self.allMatches.isNotEmpty {
            if let typedCell = cell as? LoadingMoreTableViewCell {
                typedCell.startAnimating()
            }
            self.requestNextPage?()
        }
    }

}
