
import Foundation
import Combine
import SharedModels

/// Implementation of ManagedContentProvider for the Sportradar API
class SportRadarManagedContentProvider: HomeContentProvider {

    // MARK: - Properties
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)

    private unowned let sessionCoordinator: SportRadarSessionCoordinator
    private let eventsProvider: SportRadarEventsProvider

    private let homeContentProvider: GomaHomeContentProvider

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(sessionCoordinator: SportRadarSessionCoordinator,
         eventsProvider: SportRadarEventsProvider,
         homeContentProvider: GomaHomeContentProvider) {

        self.sessionCoordinator = sessionCoordinator
        self.eventsProvider = eventsProvider

        self.homeContentProvider = homeContentProvider

        // Set up token handling
        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if launchToken != nil {
                    self?.connectionStateSubject.send(.connected)
                } else {
                    self?.connectionStateSubject.send(.disconnected)
                }
            }
            .store(in: &self.cancellables)
    }

    // MARK: - ManagedContentProvider Implementation
    func preFetchHomeContent() -> AnyPublisher<CMSInitialDump, ServiceProviderError> {
        return self.homeContentProvider.preFetchHomeContent()
    }

    func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError> {
        return self.homeContentProvider.getHomeTemplate()
    }

    func getAlertBanner() -> AnyPublisher<AlertBanner?, ServiceProviderError> {
        return self.homeContentProvider.getAlertBanner()
    }

    func getBanners() -> AnyPublisher<[Banner], ServiceProviderError> {
        return self.homeContentProvider.getBanners()
    }

    func getCarouselEventPointers() -> AnyPublisher<CarouselEventPointers, ServiceProviderError> {
        return self.homeContentProvider.getCarouselEventPointers()
    }

    func getCarouselEvents(language: String?) -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> {
        let requestPublisher = self.getCarouselEventPointers()
        return requestPublisher
            .flatMap({ topImageCardPointers -> AnyPublisher<ImageHighlightedContents<Event>, ServiceProviderError> in

                var headlineItemsImages: [String: String] = [:]

                topImageCardPointers.forEach({ pointer in
                    if let imageURL = pointer.imageUrl {
                        headlineItemsImages[pointer.eventMarketId] = imageURL
                    }
                })
                let marketIds: [String] = topImageCardPointers.map({ item in return item.eventMarketId }).compactMap({ $0 })

                let publishers: [AnyPublisher<Event?, Never>] = marketIds.map(self.eventsProvider.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> [Event] in
                        return events.compactMap({ $0 })
                    })
                    .map({ events -> ImageHighlightedContents<Event> in
                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:]
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })

                        // create ImageHighlightedContent array in the order of pointers
                        let highlightedEvents: ImageHighlightedContents<Event> = topImageCardPointers.compactMap { pointer in
                            guard let event = eventDict[pointer.eventMarketId] else { return nil }

                            return ImageHighlightedContent(
                                content: event,
                                promotedChildCount: 1,
                                imageURL: headlineItemsImages[pointer.eventMarketId]
                            )
                        }
                        return highlightedEvents
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getBoostedOddsPointers() -> AnyPublisher<[BoostedOddsPointer], ServiceProviderError> {
        return self.homeContentProvider.getBoostedOddsPointers()
    }
    
    func getBoostedOddsEvents() -> AnyPublisher<Events, ServiceProviderError> {
        let requestPublisher = self.getBoostedOddsPointers()
        return requestPublisher
            .flatMap({ boostedOddsPointers -> AnyPublisher<Events, ServiceProviderError> in

                var headlineItemsOldMarkets: [String: String] = [:]
                boostedOddsPointers.forEach({ pointer in
                    headlineItemsOldMarkets[pointer.boostedEventMarketId] = pointer.eventMarketId
                })

                let marketIds = boostedOddsPointers.map({ item in return item.boostedEventMarketId }).compactMap({ $0 })

                let publishers = marketIds.map(self.eventsProvider.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> Events in
                        return events.compactMap({ $0 })
                    })
                    .map({ (events: Events) -> Events in

                        for event in events {
                            let firstMarketId = event.markets.first?.id ?? ""
                            event.oldMainMarketId =  headlineItemsOldMarkets[firstMarketId]
                        }

                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:]
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })

                        // re-order the cleanedEvents based on the order of marketIds in headlineItems
                        let orderedEvents = boostedOddsPointers.compactMap { item in eventDict[item.boostedEventMarketId] }
                        return orderedEvents
                    })

                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getHeroCardPointers() -> AnyPublisher<HeroCardPointers, ServiceProviderError> {
        return self.homeContentProvider.getHeroCardPointers()
    }

    func getHeroCardEvents() -> AnyPublisher<Events, ServiceProviderError> {
        let requestPublisher = self.homeContentProvider.getHeroCardPointers()

        var uniqueMarketGroupIds: [String] = []

        return requestPublisher
            .flatMap({ heroCardPointers -> AnyPublisher<Events, ServiceProviderError> in
                var eventImageURLs = [String: String]()
                heroCardPointers.forEach({ pointer in
                    if let id = pointer.eventId, let imageURL = pointer.imageUrl {
                        eventImageURLs[id] = imageURL
                    }
                })

                let marketGroupIds = heroCardPointers.map({ $0.eventMarketIds ?? [] }).flatMap { $0 }

                var seen = Set<String>()
                uniqueMarketGroupIds = marketGroupIds.filter { marketGroupId in
                    guard !seen.contains(marketGroupId) else { return false }
                    seen.insert(marketGroupId)
                    return true
                }

                // First collect all events with their markets
                let eventPublishers = uniqueMarketGroupIds.map { marketId -> AnyPublisher<(String, Event?), ServiceProviderError> in
                    self.eventsProvider.getEventForMarket(withId: marketId)
                        .setFailureType(to: ServiceProviderError.self)
                        .map { event -> (String, Event?) in
                            return (marketId, event)
                        }
                        .eraseToAnyPublisher()
                }

                // Combine all event publishers
                return Publishers.MergeMany(eventPublishers)
                    .collect()
                    .map { marketEventsArray -> Events in
                        // Group by event ID to merge markets from the same event
                        var eventMap: [String: Event] = [:]
                        var marketGroupIdToEventId: [String: String] = [:]

                        // First pass: collect all events and establish relationships
                        for (marketGroupId, optionalEvent) in marketEventsArray {
                            guard let event = optionalEvent else { continue }

                            if let existingEvent = eventMap[event.id] {
                                // Event already exists, merge markets
                                let updatedEvent = existingEvent
                                let newMarkets = updatedEvent.markets + event.markets
                                updatedEvent.markets = newMarkets
                                eventMap[event.id] = updatedEvent
                            } else {
                                // First time seeing this event
                                eventMap[event.id] = event
                            }

                            // Track which market group belongs to which event
                            marketGroupIdToEventId[marketGroupId] = event.id
                        }

                        // Second pass: post-process events with additional information
                        let processedEvents = eventMap.values.map { event -> Event in
                            let modifiedEvent = event

                            modifiedEvent.promoImageURL = eventImageURLs[event.id] ?? ""

                            let firstMarket = modifiedEvent.markets.first
                            modifiedEvent.homeTeamName = firstMarket?.homeParticipant ?? ""
                            modifiedEvent.awayTeamName = firstMarket?.awayParticipant ?? ""
                            modifiedEvent.name = firstMarket?.eventName ?? ""

                            return modifiedEvent
                        }

                        // Sort events according to original order
                        return processedEvents.sorted { leftEvent, rightEvent in
                            let leftPosition = uniqueMarketGroupIds.firstIndex(of: leftEvent.id) ?? 100
                            let rightPosition = uniqueMarketGroupIds.firstIndex(of: rightEvent.id) ?? 101

                            return leftPosition < rightPosition
                        }
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getTopImageCardPointers() -> AnyPublisher<TopImageCardPointers, ServiceProviderError> {
        return self.homeContentProvider.getTopImageCardPointers()
    }
    
    func getTopImageEvents() -> AnyPublisher<Events, ServiceProviderError> {
        let requestPublisher = self.getTopImageCardPointers()
        return requestPublisher
            .flatMap({ topImageCardPointers -> AnyPublisher<Events, ServiceProviderError> in

                var headlineItemsImages: [String: String] = [:]

                topImageCardPointers.forEach({ pointer in
                    if let imageURL = pointer.imageUrl {
                        headlineItemsImages[pointer.eventMarketId] = imageURL
                    }
                })
                let marketIds: [String] = topImageCardPointers.map({ item in return item.eventMarketId }).compactMap({ $0 })

                let publishers: [AnyPublisher<Event?, Never>] = marketIds.map(self.eventsProvider.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> Events in
                        return events.compactMap({ $0 })
                    })
                    .map({ events -> Events in // Configure the image of each market
                        for event in events {
                            let firstMarketId = event.markets.first?.id ?? ""
                            event.promoImageURL =  headlineItemsImages[firstMarketId]
                        }

                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:]
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })

                        // re-order the cleanedEvents based on the order of marketIds in headlineItems
                        let orderedEvents = topImageCardPointers.compactMap { eventDict[$0.eventMarketId] }
                        return orderedEvents
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    
    func getStories() -> AnyPublisher<[Story], ServiceProviderError> {
        return self.homeContentProvider.getStories()
    }

    func getNews(pageIndex: Int, pageSize: Int) -> AnyPublisher<[NewsItem], ServiceProviderError> {
        return self.homeContentProvider.getNews(pageIndex: pageIndex, pageSize: pageSize)
    }

    func getProChoiceCardPointers() -> AnyPublisher<ProChoiceCardPointers, ServiceProviderError> {
        return self.homeContentProvider.getProChoiceCardPointers()
    }
    
    func getProChoiceMarketCards() -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> {
        let requestPublisher = self.getProChoiceCardPointers()

        return requestPublisher
            .flatMap { proChoiceCardPointers -> AnyPublisher<ImageHighlightedContents<Market>, ServiceProviderError> in
                
                var headlineItemsImages: [String: String] = [:]
                var headlineItemsPresentedSelection: [String: String] = [:]

                proChoiceCardPointers.forEach { item in
                    if let imageURL = item.imageUrl {
                        headlineItemsImages[item.eventMarketId] = imageURL
                        headlineItemsPresentedSelection[item.eventMarketId] = "3" // item.numofselections TODO: SP Merge
                    }
                }

                // Mapeia `marketIds` com índices para preservar a ordem original
                let marketIds = proChoiceCardPointers.compactMap { $0.eventMarketId }

                var uniqueMarketIds = [String]()
                for id in marketIds {
                    if !uniqueMarketIds.contains(id) {
                        uniqueMarketIds.append(id)
                    }
                }

                let marketIdIndexMap = Dictionary(uniqueKeysWithValues: uniqueMarketIds.enumerated().map { ($1, $0) })

                let publishers = marketIds.map { id in
                    return self.eventsProvider.getMarketInfo(marketId: id)
                        .map { market in
                            return Optional(market)
                        }
                        .replaceError(with: nil)
                }

                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map { (markets: [Market?]) -> ImageHighlightedContents<Market> in
                        let marketValue = markets.compactMap { $0 }
                        var highlightMarkets = ImageHighlightedContents<Market>()

                        for market in marketValue {
                            let enableSelections = headlineItemsPresentedSelection[market.id] ?? "0"
                            let enabledSelectionsCount = Int(enableSelections) ?? 0
                            let imageURL = headlineItemsImages[market.id]
                            
                            let highlightMarket = ImageHighlightedContent<Market>.init(
                                content: market,
                                promotedChildCount: enabledSelectionsCount,
                                imageURL: imageURL)

                            highlightMarkets.append(highlightMarket)
                        }

                        // Ordena `highlightMarkets` com base na posição original em `marketIdIndexMap`
                        return highlightMarkets.sorted {
                            guard let index1 = marketIdIndexMap[$0.id],
                                  let index2 = marketIdIndexMap[$1.id]
                            else { return false }
                            return index1 < index2
                        }
                    }
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError> {
        return self.homeContentProvider.getTopCompetitionsPointers()
    }

    func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError> {
        
        let publisher = self.getTopCompetitionsPointers()
            .flatMap({ (topCompetitionPointers: [TopCompetitionPointer]) -> AnyPublisher<[TopCompetition], ServiceProviderError> in

                let getCompetitonNodesRequests: [AnyPublisher<SportRadarModels.SportCompetitionInfo?, ServiceProviderError>] = topCompetitionPointers
                    .map { topCompetitionPointer in
                        let competitionIdComponents = topCompetitionPointer.competitionId.components(separatedBy: "/")
                        let competitionId: String = (competitionIdComponents.last ?? "").lowercased()

                        if !competitionId.hasSuffix(".1") {
                            return Just(Optional<SportRadarModels.SportCompetitionInfo>.none)
                                .setFailureType(to: ServiceProviderError.self)
                                .eraseToAnyPublisher()
                        }

                        let endpoint = SportRadarRestAPIClient.competitionMarketGroups(competitionId: competitionId)
                        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportCompetitionInfo>, ServiceProviderError> = self.eventsProvider.customRequest(endpoint: endpoint)
                        
                        return requestPublisher.map({ response in
                            return response.data
                        })
                        .catch({ (error: ServiceProviderError) -> AnyPublisher<SportRadarModels.SportCompetitionInfo?, ServiceProviderError> in
                            return Just(Optional<SportRadarModels.SportCompetitionInfo>.none)
                                .setFailureType(to: ServiceProviderError.self)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                    }

                let mergedPublishers = Publishers.MergeMany(getCompetitonNodesRequests)
                    .compactMap({ $0 })
                    .collect()
                    .flatMap { competitionsInfoArray -> AnyPublisher<[TopCompetition], ServiceProviderError> in
                        let getCompetitionCountryRequests = competitionsInfoArray
                            .compactMap { $0.parentId }
                            .map { self.eventsProvider.getTopCompetitionCountry(competitionParentId: $0).eraseToAnyPublisher() }
                        return Publishers.MergeMany(getCompetitionCountryRequests)
                            .collect()
                            .map { competitionParentNodes in
                                // Create a dictionary mapping competition parent IDs to their country names
                                let competitionCountriesDictionary = competitionParentNodes.reduce(into: [String: String]()) {
                                    $0[$1.id] = $1.name
                                }

                                // Create a dictionary mapping competition IDs to their names
                                let competitionNameDictionary = competitionsInfoArray.reduce(into: [String: String]()) {
                                    $0[$1.id] = $1.name
                                }

                                // Create a dictionary mapping competition IDs to their parent IDs (if available)
                                let competitionAndParentIdDictionary = competitionsInfoArray.reduce(into: [String: String]()) {
                                    if let parentId = $1.parentId {
                                        $0[$1.id] = parentId
                                    }
                                }

                                // Iterate over the list of top competition pointers and map them to `TopCompetition` objects
                                return topCompetitionPointers.compactMap { pointer in
                                    // Extract the competition ID from the last component of the competition ID string
                                    guard let competitionId = pointer.competitionId.components(separatedBy: "/").last?.lowercased() else {
                                        return nil // Skip if we cannot extract a valid competition ID
                                    }

                                    // Retrieve the parent competition ID, country name, and competition name
                                    guard let competitionParentId = competitionAndParentIdDictionary[competitionId],
                                          let competitionCountryName = competitionCountriesDictionary[competitionParentId],
                                          let competitionName = competitionNameDictionary[competitionId] else {
                                        return nil // Skip if any required data is missing
                                    }

                                    // Get the `Country` object based on the competition country name
                                    let country = Country.country(withName: competitionCountryName)

                                    // Extract the sport name (assumed to be the third-to-last component in the competition ID string)
                                    let sportName = pointer.competitionId.components(separatedBy: "/").dropLast(2).last?.lowercased() ?? ""

                                    // Create a `SportType` object
                                    let namedSport = SportRadarModels.SportType(
                                        name: sportName,
                                        numberEvents: 0,
                                        numberOutrightEvents: 0,
                                        numberOutrightMarkets: 0,
                                        numberLiveEvents: 0
                                    )

                                    // Map the sport type using `SportRadarModelMapper`
                                    let mappedSport = SportRadarModelMapper.sportType(fromSportRadarSportType: namedSport)

                                    // Create and return a `TopCompetition` object
                                    return TopCompetition(id: competitionId, name: competitionName, country: country, sportType: mappedSport)
                                }
                            }
                            .eraseToAnyPublisher()
                    }
                return mergedPublishers.eraseToAnyPublisher()
            })
        return publisher.eraseToAnyPublisher()
    }

    func getCasinoCarouselPointers(language: String?) -> AnyPublisher<CasinoCarouselPointers, ServiceProviderError> {
        fatalError("Casino Carousel not supported for this provider")
    }

    func getCasinoCarouselGames() -> AnyPublisher<CasinoGameBanners, ServiceProviderError> {
        fatalError("Casino Carousel not supported for this provider")
    }

    func getCasinoRichBanners(language: String?) -> AnyPublisher<RichBanners, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSportRichBanners(language: String?) -> AnyPublisher<RichBanners, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getCasinoRichBannerPointers(language: String?) -> AnyPublisher<RichBannerPointers, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getSportRichBannerPointers(language: String?) -> AnyPublisher<RichBannerPointers, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFooterLinks(language: String?) -> AnyPublisher<FooterLinks, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFooterSponsors(language: String?) -> AnyPublisher<FooterSponsors, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFooterSocialLinks(language: String?) -> AnyPublisher<FooterSocialLinks, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
}


