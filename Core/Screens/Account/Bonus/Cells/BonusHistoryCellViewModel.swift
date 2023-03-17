//
//  BonusHistoryCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/03/2022.
//

import Foundation
import Combine

class BonusHistoryCellViewModel: NSObject {

    // MARK: Public Properties
    var titlePublisher: CurrentValueSubject<String, Never> = .init("")
    var startDateStringPublisher: CurrentValueSubject<String, Never> = .init("")
    var endDateStringPublisher: CurrentValueSubject<String, Never> = .init("")
    var bonusStatusPublisher: CurrentValueSubject<String, Never> = .init("")

    // MARK: Lifetime and Cycle
    init(bonus: GrantedBonus) {
        super.init()

        self.setupPublishers(bonus: bonus)

    }

    private func setupPublishers(bonus: GrantedBonus) {

        self.titlePublisher.value = bonus.name ?? ""

        self.startDateStringPublisher.value = getDateFormatted(dateString: bonus.grantedDate ?? "")

        self.endDateStringPublisher.value = getDateFormatted(dateString: bonus.expiryDate ?? "")

        self.bonusStatusPublisher.value = bonus.status.capitalized

    }

    private func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }

//    private func getDateFormatted(dateString: String) -> String {
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//
//        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"
//
//        let date = dateString
//
//        if let formattedDate = dateFormatterGet.date(from: date) {
//
//            return dateFormatterPrint.string(from: formattedDate)
//        }
//
//        return ""
//    }
}
