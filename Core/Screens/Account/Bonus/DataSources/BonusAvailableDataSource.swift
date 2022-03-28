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
    var bonusAvailable: [BonusTypeData] = []
    var requestBonusDetail: ((Int) -> Void)?
    var requestApplyBonus: ((Int) -> Void)?

    var bonusBanners: [String: UIImage] = [:]

    override init() {
        super.init()

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bonusAvailable.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueCellType(BonusAvailableTableViewCell.self) {
                if let availableBonus = self.bonusAvailable[safe: indexPath.row] {

                    if let bonusBanner = self.bonusBanners[availableBonus.bonus.code] {
                        cell.setupBonus(bonus: availableBonus.bonus, bonusBanner: bonusBanner)
                    }
                    else {
                        cell.setupBonus(bonus: availableBonus.bonus)
                    }

                    if availableBonus.bonusType == .claimable {
                        cell.isClaimableBonus = true
                    }
                    else {
                        cell.isClaimableBonus = false
                    }
                }

                cell.didTapMoreInfoAction = { [weak self] in
                    self?.requestBonusDetail?(indexPath.row)
                }

                cell.didTapGetBonusAction = { [weak self] in
                    self?.requestApplyBonus?(indexPath.row)
                }

                cell.selectionStyle = .none

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

struct BonusTypeData {
    var bonus: EveryMatrix.ApplicableBonus
    var bonusType: BonusType

    enum BonusType {
        case applicable
        case claimable
    }
}
