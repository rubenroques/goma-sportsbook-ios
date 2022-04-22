//
//  BonusDetailViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/03/2022.
//

import Foundation
import Combine

class BonusDetailViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var bonus: EveryMatrix.ApplicableBonus
    private var bonusBannerUrl: URL?

    // MARK: Public Properties
    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var descriptionPublisher: CurrentValueSubject<String, Never> = .init("")
    var termsTitlePublisher: CurrentValueSubject<String, Never> = .init("")
    var termsLinkStringPublisher: CurrentValueSubject<String, Never> = .init("")
    var bonusBannerPublisher: CurrentValueSubject<URL?, Never> = .init(nil)

    // MARK: Lifetime and Cycle
    init(bonus: EveryMatrix.ApplicableBonus, bonusBannerUrl: URL? = nil) {
        self.bonus = bonus
        self.bonusBannerUrl = bonusBannerUrl

        super.init()

        self.setupPublishers()
    }

    // MARK: Functions
    private func setupPublishers() {
        self.titlePublisher.value = self.bonus.name

        self.descriptionPublisher.value = self.bonus.description

        self.termsTitlePublisher.value = localized("terms_conditions")

        self.termsLinkStringPublisher.value = self.bonus.url

        self.bonusBannerPublisher.value = self.bonusBannerUrl
    }

}
