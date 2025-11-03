//
//  TopBannerSliderViewModel.swift
//  BetssonCameroonApp
//
//  Created on 22/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

/// Production ViewModel for TopBannerSliderView that displays sport carousel banners
final class TopBannerSliderViewModel: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()

    // Internal state
    private var currentPageIndex: Int = 0

    // MARK: - Callbacks
    var onMatchTap: ((String) -> Void) = { _ in }
    var onOutcomeSelected: ((String) -> Void) = { _ in }
    var onOutcomeDeselected: ((String) -> Void) = { _ in }

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
        let currentBanners = displayStateSubject.value.sliderData.banners
        guard index < currentBanners.count else { return }

        let bannerType = currentBanners[index]

        // Handle tap based on banner type
        switch bannerType {
        case .match(let matchViewModel):
            matchViewModel.userDidTapBanner()
        case .info, .casino:
            // Info and casino banners handle taps through their button callbacks
            break
        }
    }

    // MARK: - Private Methods
    private func loadSportBanners() {
        print("[BANNER-DEBUG] 📡 Calling getSportRichBanners() API...")

        // Get sport rich banners (supports info, casino, and sport event types)
        servicesProvider.getSportRichBanners()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("[BANNER-DEBUG] ✅ getSportRichBanners() completed successfully")
                    case .failure(let error):
                        print("[BANNER-DEBUG] ❌ getSportRichBanners() failed with error: \(error)")
                        self?.handleAPIError(error)
                    }
                },
                receiveValue: { [weak self] richBanners in
                    print("[BANNER-DEBUG] 📥 Received \(richBanners.count) rich banners from API")
                    for (index, banner) in richBanners.enumerated() {
                        switch banner {
                        case .info(let infoBanner):
                            print("[BANNER-DEBUG]   [\(index)] Info banner: \(infoBanner.id)")
                        case .casinoGame(let casinoBanner):
                            print("[BANNER-DEBUG]   [\(index)] Casino banner: \(casinoBanner.bannerMetadata.bannerId)")
                        case .sportEvent(let sportBanner):
                            print("[BANNER-DEBUG]   [\(index)] Sport event banner: \(sportBanner.eventContent.content.name ?? "")")
                        }
                    }
                    self?.processRichBanners(richBanners)
                }
            )
            .store(in: &cancellables)
    }

    private func processRichBanners(_ richBanners: RichBanners) {
        print("[BANNER-DEBUG] 🔄 Processing \(richBanners.count) rich banners through mapper...")

        // Use mapper to convert RichBanners to BannerType array
        let bannerTypes = ServiceProviderModelMapper.bannerTypes(fromRichBanners: richBanners)

        print("[BANNER-DEBUG] 📦 Mapper produced \(bannerTypes.count) BannerType items")
        for (index, bannerType) in bannerTypes.enumerated() {
            switch bannerType {
            case .info:
                print("[BANNER-DEBUG]   [\(index)] BannerType.info")
            case .casino:
                print("[BANNER-DEBUG]   [\(index)] BannerType.casino")
            case .match:
                print("[BANNER-DEBUG]   [\(index)] BannerType.match")
            }
        }

        // Set up callbacks for match banners
        // Since MatchBannerViewModel is a class, we can modify properties directly through the protocol
        for (index, bannerType) in bannerTypes.enumerated() {
            if case .match(var matchViewModel) = bannerType {
                print("[BANNER-DEBUG] 🔗 Setting up callbacks for match banner at index \(index)")

                // Directly modify the class instance through the protocol reference
                matchViewModel.onMatchTap = { [weak self] eventId in
                    print("[BANNER-DEBUG] 👆 Match banner tapped: \(eventId)")
                    self?.onMatchTap(eventId)
                }

                matchViewModel.onOutcomeSelected = { [weak self] outcomeId in
                    print("[BANNER-DEBUG] ✅ Outcome selected: \(outcomeId)")
                    self?.onOutcomeSelected(outcomeId)
                }

                matchViewModel.onOutcomeDeselected = { [weak self] outcomeId in
                    print("[BANNER-DEBUG] ❌ Outcome deselected: \(outcomeId)")
                    self?.onOutcomeDeselected(outcomeId)
                }
            }
        }

        // Update slider data
        updateSliderDataWithBanners(bannerTypes)
    }

    private func updateSliderDataWithBanners(_ bannerTypes: [BannerType]) {
        print("[BANNER-DEBUG] 🎨 Updating slider with \(bannerTypes.count) banners")

        let showPageIndicators = bannerTypes.count > 1
        let isVisible = !bannerTypes.isEmpty

        let sliderData = TopBannerSliderData(
            banners: bannerTypes,
            showPageIndicators: showPageIndicators,
            currentPageIndex: currentPageIndex
        )

        let newState = TopBannerSliderDisplayState(
            sliderData: sliderData,
            isVisible: isVisible,
            isUserInteractionEnabled: true
        )

        print("[BANNER-DEBUG] 📊 Final state: isVisible=\(isVisible), bannerCount=\(bannerTypes.count), showPageIndicators=\(showPageIndicators)")
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
        print("[BANNER-DEBUG] ⚠️ Handling API error, hiding banner slider")

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

}
