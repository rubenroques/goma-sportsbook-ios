//
//  CasinoTopBannerSliderViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

/// Production ViewModel for TopBannerSliderView that displays casino carousel banners
final class CasinoTopBannerSliderViewModel: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>
    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()

    // Internal state
    private var casinoBanners: [CasinoBannerData] = []
    private var currentPageIndex: Int = 0

    // MARK: - Callbacks
    var onBannerAction: ((CasinoBannerAction) -> Void) = { _ in }

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
        loadCasinoBanners()
    }

    // MARK: - TopBannerSliderViewModelProtocol Methods
    func didScrollToPage(_ pageIndex: Int) {
        currentPageIndex = pageIndex
        updateSliderData()
    }

    func bannerTapped(at index: Int) {
        guard index < casinoBanners.count else { return }
        let bannerData = casinoBanners[index]
        let action = bannerData.primaryAction
        onBannerAction(action)
    }

    // MARK: - Private Methods
    private func loadCasinoBanners() {
        servicesProvider.getCasinoCarouselPointers()
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
                receiveValue: { [weak self] casinoCarouselPointers in
                    self?.processCasinoCarouselData(casinoCarouselPointers)
                }
            )
            .store(in: &cancellables)
    }

    private func processCasinoCarouselData(_ pointers: [CasinoCarouselPointer]) {
        // Convert API models to app models
        casinoBanners = pointers.map { pointer in
            ServiceProviderModelMapper.casinoBannerData(fromCasinoCarouselPointer: pointer)
        }

        // Filter visible banners
        let visibleBanners = casinoBanners.filter { $0.isVisible }

        // Convert to BannerType array and setup callbacks
        let bannerTypes = ServiceProviderModelMapper.bannerTypes(fromCasinoBannerData: visibleBanners)
        setupBannerCallbacks(bannerTypes)

        // Update slider data
        updateSliderDataWithBanners(bannerTypes)
    }

    private func setupBannerCallbacks(_ bannerTypes: [BannerType]) {
        for bannerType in bannerTypes {
            if case .singleButton(let viewModel) = bannerType,
               let casinoBannerViewModel = viewModel as? CasinoBannerViewModel {
                casinoBannerViewModel.onBannerAction = { [weak self] action in
                    self?.onBannerAction(action)
                }
            }
        }
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
        print("CasinoTopBannerSliderViewModel: Failed to load casino banners: \(error)")

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
    /// Reload casino banners from API
    func reloadBanners() {
        loadCasinoBanners()
    }
}