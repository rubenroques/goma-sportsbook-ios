//
//  BonusAvailableCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/03/2022.
//

import Foundation
import Combine

class BonusAvailableCellViewModel: NSObject {

    // MARK: Public Properties
    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var subtitlePublisher: CurrentValueSubject<String, Never> = .init("")
    var bonusBannerUrlPublisher: CurrentValueSubject<URL?, Never> = .init(nil)

    // MARK: Lifetime and Cycle
    init(bonus: ApplicableBonus, bonusBannerUrl: URL? = nil) {
        super.init()

        self.setupPublishers(bonus: bonus, bonusBannerUrl: bonusBannerUrl)

    }

    private func setupPublishers(bonus: ApplicableBonus, bonusBannerUrl: URL?) {

        self.titlePublisher.value = bonus.name

        self.subtitlePublisher.value = bonus.description

        if let bonusBannerUrl = bonusBannerUrl {
            self.bonusBannerUrlPublisher.value = bonusBannerUrl
        }

    }
}
