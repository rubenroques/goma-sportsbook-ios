//
//  CasinoBannerViewModel.swift
//  BetssonCameroonApp
//
//  Created on 22/09/2025.
//

import Foundation
import Combine
import GomaUI

/// Production ViewModel for casino banner that implements SingleButtonBannerViewModelProtocol
final class CasinoBannerViewModel: SingleButtonBannerViewModelProtocol {

    // MARK: - Associated Type
    typealias ActionType = CasinoBannerAction

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<SingleButtonBannerDisplayState, Never>
    private let bannerData: CasinoBannerData

    // MARK: - SingleButtonBannerViewModelProtocol
    var currentDisplayState: SingleButtonBannerDisplayState {
        return displayStateSubject.value
    }

    var displayStatePublisher: AnyPublisher<SingleButtonBannerDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    var onButtonAction: ((CasinoBannerAction) -> Void)?

    // MARK: - Initialization
    init(bannerData: CasinoBannerData, displayData: SingleButtonBannerData) {
        self.bannerData = bannerData

        let initialState = SingleButtonBannerDisplayState(
            bannerData: displayData,
            isButtonEnabled: true
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - Protocol Methods
    func buttonTapped() {
        let action = bannerData.primaryAction
        onButtonAction?(action)
    }

    // MARK: - Helper Methods
    func updateButtonEnabled(_ enabled: Bool) {
        let currentState = displayStateSubject.value
        let newState = SingleButtonBannerDisplayState(
            bannerData: currentState.bannerData,
            isButtonEnabled: enabled
        )
        displayStateSubject.send(newState)
    }
}
