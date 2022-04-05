//
//  BonusActiveDataSource.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import Foundation
import UIKit
import Combine

class BonusActiveDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: Public Properties
    var bonusActive: [EveryMatrix.GrantedBonus] = []

    var bonusActiveCellViewModels: [BonusActiveCellViewModel] = []

    override init() {
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bonusActive.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueCellType(BonusActiveTableViewCell.self) {
                if let activeBonus = self.bonusActive[safe: indexPath.row] {
                    if let cellViewModel = self.bonusActiveCellViewModels[safe: indexPath.row] {
                        cell.configure(withViewModel: cellViewModel)
                    }
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

        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70

    }
}
