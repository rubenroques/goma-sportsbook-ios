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
    var hasBonusAmountPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var bonus: GrantedBonus

    var shouldReloadData: (() -> Void)?
    var shouldShowAlert: ((AlertType) -> Void)?

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and Cycle
    init(bonus: GrantedBonus) {
        self.bonus = bonus
        
        super.init()

        self.setupPublishers(bonus: bonus)

    }

    private func setupPublishers(bonus: GrantedBonus) {

        self.titlePublisher.value = bonus.name

        let expiryDate: Date = bonus.expiryDate ?? Date()
        let formattedDate = self.getDateFormatted(date: expiryDate)

        if formattedDate != "" {
            self.dateStringPublisher.value = formattedDate
        }
        else {
            self.dateStringPublisher.value = localized("permanent")
        }

        if let bonusAmount = bonus.amount, let wagerAmount = bonus.initialWagerRequirementAmount {
            if bonusAmount > 0 || wagerAmount > 0 {
                self.hasBonusAmountPublisher.send(true)
            }
        }

    }

    private func getDateFormatted(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyy HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"

        let date = dateString

        if let formattedDate = dateFormatterGet.date(from: date) {

            return dateFormatterPrint.string(from: formattedDate)
        }

        return ""
    }
    
    private func getDateFormatted(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatterPrint.string(from: date)
    }

    func cancelBonus() {

        Env.servicesProvider.cancelBonus(bonusId: self.bonus.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("CANCEL BONUS ERROR: \(error)")
                    self?.shouldShowAlert?(.error)
                }
            }, receiveValue: { [weak self] cancelBonusResponse in

                print("CANCEL BONUS SUCCESS: \(cancelBonusResponse)")

                self?.shouldShowAlert?(.success)
            })
            .store(in: &cancellables)
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
