//
//  BonusActiveCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/03/2022.
//

import Foundation
import Combine

class BonusActiveCellViewModel: NSObject {

    // MARK: Public Properties
    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var dateStringPublisher: CurrentValueSubject<String, Never> = .init("")

    // MARK: Lifetime and Cycle
    init(bonus: EveryMatrix.GrantedBonus) {
        super.init()

        self.setupPublishers(bonus: bonus)

    }

    private func setupPublishers(bonus: EveryMatrix.GrantedBonus) {

        self.titlePublisher.value = bonus.name ?? ""

        let formattedDate = getDateFormatted(dateString: bonus.expiryDate ?? "")

        if formattedDate != "" {
            self.dateStringPublisher.value = formattedDate
        }
        else {
            self.dateStringPublisher.value = localized("permanent")
        }

    }

    private func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }
}
