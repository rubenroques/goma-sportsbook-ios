//
//  BonusAvailableDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import Foundation
import UIKit
import Combine

class BonusAvailableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var bonusAvailable: [EveryMatrix.ApplicableBonus] = []
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var isEmptyStatePublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isBonusLoading: CurrentValueSubject<Bool, Never> = .init(false)

    override init() {
        super.init()

        self.getBonusAvailable()
    }

    private func getBonusAvailable() {
        self.isBonusLoading.send(true)

        var gamingAccountId = ""

        if let walletGamingAccountId = Env.userSessionStore.userBalanceWallet.value?.id {
            gamingAccountId = "\(walletGamingAccountId)"
        }

        // Get Applicable Bonus
        Env.everyMatrixClient.getApplicableBonus(type: "deposit", gamingAccountId: gamingAccountId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("APPLICABLE BONUS ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] bonusResponse in
                print("APPLICABLE BONUS: \(bonusResponse)")
                if let bonusList = bonusResponse.bonuses {
                    for bonus in bonusList {
                        self?.bonusAvailable.append(bonus)
                    }
                }

            })
            .store(in: &cancellables)

        // Get Claimable Bonus
        Env.everyMatrixClient.getClaimableBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("CLAIMABLE BONUS ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] bonusResponse in
                print("CLAIMABLE BONUS: \(bonusResponse)")
//                if let bonusList = bonusResponse.bonuses {
//                    for bonus in bonusList {
//                        //self?.bonusAvailable.append(bonus)
//                    }
//                }
            })
            .store(in: &cancellables)

        if self.bonusAvailable.isEmpty {
            self.isEmptyStatePublisher.send(true)
        }

        self.shouldReloadData.send()
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bonusAvailable.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueCellType(BonusAvailableTableViewCell.self) {

                cell.hasBannerImage = true

                return cell
            }

        fatalError()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

       return UIView()

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 240

    }
}
