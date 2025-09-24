//
//  MockTopBannerSliderViewModel+Casino.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import GomaUI
import UIKit

extension MockTopBannerSliderViewModel {

    /// Casino-themed mock banners for testing and preview
    public static var casinoGameMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .singleButton(createCasinoGameBanner()),
            .singleButton(createPromotionBanner()),
            .singleButton(createWelcomeBonusBanner())
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Single casino banner for minimal testing
    public static var singleCasinoBannerMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .singleButton(createCasinoGameBanner())
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: false,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    // MARK: - Private Factory Methods

    private static func createCasinoGameBanner() -> MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "casino_game",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=5",
            messageText: "Try your luck with Mega Fortune!",
            buttonConfig: ButtonConfig(
                title: "Play Now",
                backgroundColor: StyleProvider.Color.primaryColor,
                textColor: StyleProvider.Color.textPrimary,
                cornerRadius: 8.0
            )
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData, isButtonEnabled: true)
    }

    private static func createPromotionBanner() -> MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "casino_promotion",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=6",
            messageText: "Weekend Casino Bonus - Double your deposit!",
            buttonConfig: ButtonConfig(
                title: "Claim Bonus",
                backgroundColor: StyleProvider.Color.primaryColor,
                textColor: StyleProvider.Color.textPrimary,
                cornerRadius: 8.0
            )
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData, isButtonEnabled: true)
    }

    private static func createWelcomeBonusBanner() -> MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "casino_welcome",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=7",
            messageText: "Welcome to Casino! Get 100 free spins",
            buttonConfig: ButtonConfig(
                title: "Start Playing",
                backgroundColor: StyleProvider.Color.primaryColor,
                textColor: StyleProvider.Color.textPrimary,
                cornerRadius: 8.0
            )
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData, isButtonEnabled: true)
    }
}