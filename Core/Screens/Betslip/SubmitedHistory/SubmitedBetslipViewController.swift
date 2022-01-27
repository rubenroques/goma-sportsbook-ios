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
    @IBOutlet private weak var emptyBetsBaseView: UIView!
    @IBOutlet private weak var dontHaveAnyTicketsLabel: UILabel!
    @IBOutlet private weak var makeSomeBetsLabel: UILabel!
    @IBOutlet private weak var popularGamesButton: UIButton!
    
    @IBOutlet private weak var firstTextNoBetsLabel: UILabel!
    @IBOutlet private weak var secondTextNoBetsLabel: UILabel!
    @IBOutlet private weak var noBetsImage: UIImageView!
    
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
        self.title = localized("my_bets")
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
        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.emptyBetsBaseView.isHidden = true
        
        
        if let userSession = UserSessionStore.loggedUserSession() {
            self.emptyBetsBaseView.isHidden = true
        }else{
            self.emptyBetsBaseView.isHidden = false
            self.firstTextNoBetsLabel.text = localized("you_not_logged_in")
            self.secondTextNoBetsLabel.text = localized("need_login_tickets")
           
            self.popularGamesButton.setTitle(localized("login"), for: .normal)
            self.noBetsImage.image = UIImage(named: "no_internet_icon")
        }

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

    

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App2.backgroundPrimary
        self.tableView.backgroundColor = UIColor.App2.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App2.backgroundPrimary
        self.emptyBetsBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        
        self.dontHaveAnyTicketsLabel.textColor = UIColor.App2.textPrimary
        self.makeSomeBetsLabel.textColor = UIColor.App2.textPrimary
        self.popularGamesButton.titleLabel?.textColor = UIColor.App2.textPrimary
        self.popularGamesButton.backgroundColor = UIColor.App2.buttonBackgroundPrimary
    }

    private func requestHistory() {

        let route = TSRouter.getOpenBets(language: "en", records: 100, page: 0)

        Env.everyMatrixClient.manager.getModel(router: route, decodingType: BetHistoryResponse.self)
            .map(\.betList)
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { betHistoryEntry in
                if betHistoryEntry.isEmpty {
                    self.emptyBetsBaseView.isHidden = false
                    self.popularGamesButton.isHidden = true
                }
                else {
                    self.emptyBetsBaseView.isHidden = true
                }
                self.betHistoryEntries = betHistoryEntry
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func requestCashout(betHistoryEntry: BetHistoryEntry) {

        Logger.log("MyBets requestCashout \(betHistoryEntry.betId)", .debug)

        if let cashoutRegister = cashoutRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
        }

        let endpoint = TSRouter.cashoutPublisher(operatorId: Env.appSession.operatorId,
                                                 language: "en",
                                                 betId: betHistoryEntry.betId)

        Env.everyMatrixClient.manager
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

        let cashoutRawMessageString = localized("cashout_prompt_message")
        let cashoutMessageString = cashoutRawMessageString.replacingOccurrences(of: "%s", with: "\(betCashoutValue)")

        let submitCashoutAlert = UIAlertController(title: localized("cashout_verification"),
                                                   message: cashoutMessageString,
                                                   preferredStyle: UIAlertController.Style.alert)

        submitCashoutAlert.addAction(UIAlertAction(title: localized("cashout"), style: .default, handler: { _ in
            self.activityIndicatorBaseView.isHidden = false

            let route = TSRouter.cashoutBet(language: "en", betId: betCashout.id)

            Env.everyMatrixClient.manager
                .getModel(router: route, decodingType: CashoutSubmission.self)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { value in
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
        let infoCashoutAlert = UIAlertController(title: localized("cashout"), message: localized("cashout_info"), preferredStyle: UIAlertController.Style.alert)

        infoCashoutAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

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
