//
//  SportTopBannerSliderViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

/// Production ViewModel for TopBannerSliderView that displays sport carousel banners
final class SportTopBannerSliderViewModel: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()

    // Internal state
    private var matchBannerViewModels: [MatchBannerViewModel] = []
    private var currentPageIndex: Int = 0

    // MARK: - Callbacks
    var onMatchTap: ((String) -> Void) = { _ in }

    // MARK: - TopBannerSliderViewModelProtocol
    var currentDisplayState: TopBannerSliderDisplayState {
        return displayStateSubject.value
    }

    var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider

        // Start with empty state
        let initialSliderData = TopBannerSliderData(
            banners: [],
            showPageIndicators: true,
            currentPageIndex: 0
        )

        let initialState = TopBannerSliderDisplayState(
            sliderData: initialSliderData,
            isVisible: false, // Hidden until data loads
            isUserInteractionEnabled: true
        )

        self.displayStateSubject = CurrentValueSubject(initialState)

        // Load banner data
        loadSportBanners()
    }

    // MARK: - TopBannerSliderViewModelProtocol Methods
    func didScrollToPage(_ pageIndex: Int) {
        currentPageIndex = pageIndex
        updateSliderData()
    }

    func bannerTapped(at index: Int) {
        guard index < matchBannerViewModels.count else { return }
        let matchBannerViewModel = matchBannerViewModels[index]
        matchBannerViewModel.userDidTapBanner()
    }

    // MARK: - Private Methods
    private func loadSportBanners() {
        // Get carousel events and create banners directly
        servicesProvider.getCarouselEvents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleAPIError(error)
                    }
                },
                receiveValue: { [weak self] imageHighlightedEvents in
                    self?.processCarouselEvents(imageHighlightedEvents)
                }
            )
            .store(in: &cancellables)
    }

    private func processCarouselEvents(_ imageHighlightedEvents: ImageHighlightedContents<Event>) {
        // Convert ImageHighlightedContent<Event> directly to MatchBannerViewModel
        matchBannerViewModels = imageHighlightedEvents.compactMap { highlightedEvent in
            return self.createMatchBannerViewModel(from: highlightedEvent)
        }

        // Set up match tap callbacks for each view model
        matchBannerViewModels.forEach { [weak self] viewModel in
            viewModel.onMatchTap = { [weak self] eventId in
                self?.onMatchTap(eventId)
            }
        }

        // Convert to BannerType array
        let bannerTypes = matchBannerViewModels.map { BannerType.matchBanner($0) }

        // Update slider data
        updateSliderDataWithBanners(bannerTypes)
    }

    private func updateSliderDataWithBanners(_ bannerTypes: [BannerType]) {
        let showPageIndicators = bannerTypes.count > 1

        let sliderData = TopBannerSliderData(
            banners: bannerTypes,
            showPageIndicators: showPageIndicators,
            currentPageIndex: currentPageIndex
        )

        let newState = TopBannerSliderDisplayState(
            sliderData: sliderData,
            isVisible: true,
            isUserInteractionEnabled: true
        )

        displayStateSubject.send(newState)
    }

    private func updateSliderData() {
        let currentState = displayStateSubject.value
        let updatedSliderData = TopBannerSliderData(
            banners: currentState.sliderData.banners,
            showPageIndicators: currentState.sliderData.showPageIndicators,
            currentPageIndex: currentPageIndex
        )

        let newState = TopBannerSliderDisplayState(
            sliderData: updatedSliderData,
            isVisible: currentState.isVisible,
            isUserInteractionEnabled: currentState.isUserInteractionEnabled
        )

        displayStateSubject.send(newState)
    }

    private func handleAPIError(_ error: ServiceProviderError) {

        // Show empty state on error
        let emptySliderData = TopBannerSliderData(
            banners: [],
            showPageIndicators: false,
            currentPageIndex: 0
        )

        let errorState = TopBannerSliderDisplayState(
            sliderData: emptySliderData,
            isVisible: false, // Hide on error
            isUserInteractionEnabled: false
        )

        displayStateSubject.send(errorState)
    }

    // MARK: - Public Methods
    /// Reload sport banners from API
    func reloadBanners() {
        loadSportBanners()
    }

    // MARK: - Private Helper Methods

    /// Convert ImageHighlightedContent<Event> directly to MatchBannerViewModel
    private func createMatchBannerViewModel(from highlighted: ImageHighlightedContent<Event>) -> MatchBannerViewModel? {
        let event = highlighted.content

        // Map ServicesProvider.Event to app's Match model first
        guard let match = ServiceProviderModelMapper.match(fromEvent: event) else {
            return nil // Skip if event can't be mapped to match
        }

        // Create MatchBannerViewModel with the match and CMS image URL
        return MatchBannerViewModel(match: match, imageURL: highlighted.imageURL)
    }
}
