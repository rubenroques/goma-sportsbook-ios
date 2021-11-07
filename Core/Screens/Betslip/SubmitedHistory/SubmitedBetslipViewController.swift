//
//  SubmitedBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class SubmitedBetslipViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var cancellables = Set<AnyCancellable>()
    private var betHistoryEntries: [BetHistoryEntry] = []

    init() {
        super.init(nibName: "SubmitedBetslipViewController", bundle: nil)
        self.title = "My Bets"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SubmitedBetTableViewCell.nib, forCellReuseIdentifier: SubmitedBetTableViewCell.identifier)
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        
        self.requestHistory()
        self.setupWithTheme()
    }



    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground
        self.tableView.backgroundColor = UIColor.App.mainBackground
        self.tableView.backgroundView?.backgroundColor = UIColor.App.mainBackground

    }

    private func requestHistory() {

        let route = TSRouter.getOpenBets(language: "en", records: 100, page: 0)

        TSManager.shared.getModel(router: route, decodingType: BetHistoryResponse.self)
            .map(\.betList)
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { betHistoryEntry in
                self.betHistoryEntries = betHistoryEntry
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

}

extension SubmitedBetslipViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.betHistoryEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueCellType(SubmitedBetTableViewCell.self),
            let entry = self.betHistoryEntries[safe: indexPath.row]
        else {
            return UITableViewCell()
        }

        cell.configureWithBetHistoryEntry(entry)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }

}
