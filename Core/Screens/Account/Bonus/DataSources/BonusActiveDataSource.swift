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
    var bonusActive: [String] = []
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var isEmptyStatePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    override init() {
        super.init()

        self.getBonusActive()
    }

    private func getBonusActive() {
        self.bonusActive.append("1")

        if self.bonusActive.isEmpty {
            self.isEmptyStatePublisher.send(true)
        }

        self.shouldReloadData.send()
    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bonusActive.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueCellType(BonusActiveTableViewCell.self) {

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
