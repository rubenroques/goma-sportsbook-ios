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
    var bonusValuePublisher: CurrentValueSubject<String, Never> = .init("")

    var bonusType: BonusTypeMapper?

    // MARK: Lifetime and Cycle
    init(bonus: GrantedBonus) {
        super.init()

        self.setupPublishers(bonus: bonus)

    }

    private func setupPublishers(bonus: GrantedBonus) {

        self.titlePublisher.value = bonus.name

        let grantedDate: Date = bonus.grantedDate ?? Date()
        self.startDateStringPublisher.value = self.getDateFormatted(date: grantedDate)

        let expiryDate: Date = bonus.expiryDate ?? Date()
        self.endDateStringPublisher.value = self.getDateFormatted(date: expiryDate)

        self.bonusValuePublisher.value = "\(bonus.amount ?? 0.0)"

        self.bonusType = BonusTypeMapper.init(bonusType: bonus.status)

        self.bonusStatusPublisher.value = self.bonusType?.bonusName ?? bonus.status.capitalized

    }

    private func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"


        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }
    
    private func getDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatterPrint.string(from: date)
    }

}
