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
    var onInfoBannerAction: ((InfoBannerAction) -> Void) = { _ in }
    var onCasinoBannerAction: ((CasinoBannerAction) -> Void) = { _ in }

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
        // Get sport rich banners (supports info, casino, and sport event types)
        let language = LanguageManager.shared.currentLanguageCode
        servicesProvider.getSportRichBanners(language: language)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleAPIError(error)
                    }
                },
                receiveValue: { [weak self] richBanners in
                    self?.processRichBanners(richBanners)
                }
            )
            .store(in: &cancellables)
    }

    private func processRichBanners(_ richBanners: RichBanners) {
        // Use mapper to convert RichBanners to BannerType array
        let bannerTypes = ServiceProviderModelMapper.bannerTypes(fromRichBanners: richBanners)

        // Set up callbacks for all banner types
        // Since all ViewModels are classes, we can modify properties directly through the protocol
        for bannerType in bannerTypes {
            switch bannerType {
            case .match(let viewModel):
                if let matchViewModel = viewModel as? MatchBannerViewModel {
                    matchViewModel.onMatchTap = { [weak self] eventId in
                        self?.onMatchTap(eventId)
                    }
                    
                    matchViewModel.onOutcomeSelected = { [weak self] outcomeId in
                        self?.onOutcomeSelected(outcomeId)
                    }
                    
                    matchViewModel.onOutcomeDeselected = { [weak self] outcomeId in
                        self?.onOutcomeDeselected(outcomeId)
                    }
                }
            case .info(let viewModel):
                // Type check to determine action handler
                if let infoVM = viewModel as? InfoBannerViewModel {
                    infoVM.onButtonAction = { [weak self] action in
                        self?.onInfoBannerAction(action)
                    }
                }

            case .casino(let viewModel):
                if let casinoVM = viewModel as? CasinoBannerViewModel {
                    casinoVM.onButtonAction = { [weak self] action in
                        self?.onCasinoBannerAction(action)
                    }
                }
            }
        }

        // Update slider data
        updateSliderDataWithBanners(bannerTypes)
    }

    private func updateSliderDataWithBanners(_ bannerTypes: [BannerType]) {
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

}
