//
//  BonusHistoryDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import Foundation
import UIKit
import Combine

class BonusHistoryDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: Public Properties
    var bonusHistory: [EveryMatrix.GrantedBonus] = []

    override init() {
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bonusHistory.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueCellType(BonusHistoryTableViewCell.self) {
                if let historyBonus = self.bonusHistory[safe: indexPath.row] {
                    cell.setupBonus(bonus: historyBonus)
                }
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

        return 70

    }
}
