//
//  CasinoTopBannerSliderViewModel.swift
//  BetssonCameroonApp
//
//  Created on 22/09/2025.
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
        let currentBanners = displayStateSubject.value.sliderData.banners
        guard index < currentBanners.count else { return }

        let bannerType = currentBanners[index]

        // Handle tap based on banner type
        switch bannerType {
        case .info, .casino:
            // Info and casino banners handle taps through their button callbacks
            break
        case .match:
            // Match banners not expected in casino context
            break
        }
    }

    // MARK: - Private Methods
    private func loadCasinoBanners() {
        let language = LanguageManager.shared.currentLanguageCode
        servicesProvider.getCasinoRichBanners(language: language)
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

        // Setup callbacks for all banner types
        for bannerType in bannerTypes {
            switch bannerType {
            case .info(let viewModel):
                if let infoVM = viewModel as? InfoBannerViewModel {
                    infoVM.onButtonAction = { [weak self] action in
                        // Convert InfoBannerAction to CasinoBannerAction
                        switch action {
                        case .openURL(let url, _):
                            self?.onBannerAction(.openURL(url: url))
                        case .none:
                            self?.onBannerAction(.none)
                        }
                    }
                }

            case .casino(let viewModel):
                if let casinoVM = viewModel as? CasinoBannerViewModel {
                    casinoVM.onButtonAction = { [weak self] action in
                        self?.onBannerAction(action)
                    }
                }

            case .match:
                // Match banners not expected in casino context
                break
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
