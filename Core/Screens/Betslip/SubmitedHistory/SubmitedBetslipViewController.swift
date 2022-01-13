//
//  SubmitedBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections

class SubmitedBetslipViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorBaseView: UIView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    private var cancellables = Set<AnyCancellable>()
    private var betHistoryEntries: [BetHistoryEntry] = []
    // private var cashouts: [EveryMatrix.Cashout] = []
    var cashouts: OrderedDictionary<String, EveryMatrix.Cashout> = [:]

    private var cashoutRegister: EndpointPublisherIdentifiable?
    private var cashoutPublisher: AnyCancellable?

    //Cached view models
    var cachedViewModels: [String: SubmitedBetTableViewCellViewModel] = [:]

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

        self.activityIndicatorBaseView.isHidden = true
        self.view.bringSubviewToFront(self.activityIndicatorBaseView)

        Env.userSessionStore
            .userSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.requestHistory()
            }
            .store(in: &cancellables)

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
//                for bet in self.betHistoryEntries {
//                    self.requestCashout(betHistoryEntry: bet)
//                }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func requestCashout(betHistoryEntry: BetHistoryEntry) {

        Logger.log("MyBets requestCashout \(betHistoryEntry.betId)", .debug)

        if let cashoutRegister = cashoutRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
        }

        let endpoint = TSRouter.cashoutPublisher(operatorId: Env.appSession.operatorId,
                                                 language: "en",
                                                 betId: betHistoryEntry.betId)

        TSManager.shared
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("MyBets cashoutPublisher connect")
                    self?.cashoutRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyBets cashoutPublisher initialContent")
                    self?.setupCashoutAggregatorProcessor(aggregator: aggregator)

                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                    self?.updateCashoutAggregatorProcessor(aggregator: aggregatorUpdates)

                    print("UPDATE CASHOUT: \(Env.everyMatrixStorage.cashoutsPublisher.values)")
                case .disconnect:
                    print("MyBets cashoutPublisher disconnect")
                }
            })
            .store(in: &cancellables)

    }

    private func setupCashoutAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .cashouts,
                                                 shouldClear: false)

        self.tableView.reloadData()

    }

    private func updateCashoutAggregatorProcessor(aggregator: EveryMatrix.Aggregator) {
        Env.everyMatrixStorage.processContentUpdateAggregator(aggregator)

        self.tableView.reloadData()

    }

    func submitCashout(betCashout: EveryMatrix.Cashout) {

        guard let betCashoutValue = betCashout.value else {
            return
        }
        let submitCashoutAlert = UIAlertController(title: localized("string_cashout_verification"), message: localized("string_return_money") + "€\(betCashoutValue)", preferredStyle: UIAlertController.Style.alert)

        submitCashoutAlert.addAction(UIAlertAction(title: localized("string_cashout"), style: .default, handler: { _ in
            self.activityIndicatorBaseView.isHidden = false

            let route = TSRouter.cashoutBet(language: "en", betId: betCashout.id)

            TSManager.shared
                .getModel(router: route, decodingType: CashoutSubmission.self)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { value in
                    print(value)
                    if value.cashoutSucceed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.requestHistory()
                            self.activityIndicatorBaseView.isHidden = true
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.activityIndicatorBaseView.isHidden = true
                        }
                    }
                })
                .store(in: &self.cancellables)
        }))

        submitCashoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(submitCashoutAlert, animated: true, completion: nil)

    }

    func showCashoutInfo() {
        let infoCashoutAlert = UIAlertController(title: localized("string_cashout"), message: localized("string_cashout_info"), preferredStyle: UIAlertController.Style.alert)

        infoCashoutAlert.addAction(UIAlertAction(title: "OK", style: .default))

        present(infoCashoutAlert, animated: true, completion: nil)

    }

    func viewModel(forIndex index: Int) -> SubmitedBetTableViewCellViewModel? {
        let ticket: BetHistoryEntry?

        ticket = self.betHistoryEntries[safe: index]

        guard let ticket = ticket else {
            return nil
        }

        if let viewModel = cachedViewModels[ticket.betId] {
            return viewModel
        }
        else {
            let viewModel =  SubmitedBetTableViewCellViewModel(ticket: ticket)
            cachedViewModels[ticket.betId] = viewModel
            return viewModel
        }
    }

    func redrawTableViewAction() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func reloadTableViewAction() {
        self.tableView.reloadData()
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
            let entry = self.betHistoryEntries[safe: indexPath.row],
            let viewModel = self.viewModel(forIndex: indexPath.row)
        else {
            return UITableViewCell()
        }

        cell.configureWithViewModel(viewModel: viewModel)

        cell.needsRedraw = { [weak self] in
            if let betCashout = cell.viewModel?.cashout {
                cell.cashoutAction = { value in
                    self?.submitCashout(betCashout: value)
                }
                cell.infoAction = {
                    self?.showCashoutInfo()
                }

                self?.redrawTableViewAction()
            }
        }

        cell.viewModel?.createdCashout
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadTableViewAction()
                self?.redrawTableViewAction()
            })
            .store(in: &cancellables)

        cell.viewModel?.deletedCashout
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.reloadTableViewAction()
                self?.redrawTableViewAction()
            })
            .store(in: &cancellables)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }

}
