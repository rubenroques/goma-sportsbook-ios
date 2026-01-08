//
//  ConversationBetSelectionViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import UIKit
import Combine

class ConversationBetSelectionViewController: UIViewController {

    // MARK: Private Properties
    
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyBaseView: UIView = Self.createEmptyBaseView()
    private lazy var emptyBetsImageView: UIImageView = Self.createEmptyBetsImageView()
    private lazy var emptyBetsLabel: UILabel = Self.createEmptyBetsLabel()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var viewModel: ConversationBetSelectionViewModel

    private var cancellables = Set<AnyCancellable>()

    private var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = true
        }
    }

    private var isEmpty: Bool = false {
        didSet {
            self.emptyBaseView.isHidden = !isEmpty
            self.tableView.isHidden = isEmpty
        }
    }

    var selectedBetTicketPublisher: CurrentValueSubject<BetSelectionCellViewModel?, Never> = .init(nil)

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationBetSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(BetSelectionTableViewCell.self,
                                forCellReuseIdentifier: BetSelectionTableViewCell.identifier)
        self.tableView.register(BetSelectionStateTableViewCell.self,
                                forCellReuseIdentifier: BetSelectionStateTableViewCell.identifier)

        tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)

        self.bind(toViewModel: self.viewModel)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.emptyBetsImageView.layer.cornerRadius = self.emptyBetsImageView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = .clear

        self.emptyBaseView.backgroundColor = .clear

        self.emptyBetsImageView.backgroundColor = .clear

        self.emptyBetsLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ConversationBetSelectionViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

         viewModel.hasTicketSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasTicketSelected in

                self?.selectedBetTicketPublisher.send(self?.viewModel.selectedTicket)
            })
            .store(in: &cancellables)

        viewModel.isLoadingSharedBetPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }
            }.store(in: &cancellables)

        viewModel.isTicketsEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isTicketsEmpty in
                self?.isEmpty = isTicketsEmpty
            })
            .store(in: &cancellables)

    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

}

//
// MARK: - TableView Protocols
//
extension ConversationBetSelectionViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(forSectionIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if self.viewModel.myTicketsTypePublisher.value == .opened {

            guard
                let cell = tableView.dequeueCellType(BetSelectionTableViewCell.self),
                let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
            else {
                fatalError()
            }

            cell.configure(withViewModel: cellViewModel)
            cell.didTapCheckboxAction = { [weak self] viewModel in
                self?.viewModel.checkSelectedTicket(withId: viewModel.id)
            }
            cell.didTapUncheckboxAction = { [weak self] viewModel in
                self?.viewModel.uncheckSelectedTicket(withId: viewModel.id)
            }

            return cell
        }
        else {
            guard
                let cell = tableView.dequeueCellType(BetSelectionStateTableViewCell.self),
                let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
            else {
                fatalError()
            }

            cell.configure(withViewModel: cellViewModel)
            cell.didTapCheckboxAction = { [weak self] viewModel in
                self?.viewModel.checkSelectedTicket(withId: viewModel.id)
            }
            cell.didTapUncheckboxAction = { [weak self] viewModel in
                self?.viewModel.uncheckSelectedTicket(withId: viewModel.id)
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
//        else {
//            fatalError()
//        }
//
//        let headerDate = self.viewModel.sectionTitle(forSectionIndex: section)
//        headerView.configureHeader(title: headerDate)
//
//        return headerView
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension ConversationBetSelectionViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyBetsImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createEmptyBetsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("not_bets_tickets_section")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyBaseView)

        self.emptyBaseView.addSubview(self.emptyBetsImageView)
        self.emptyBaseView.addSubview(self.emptyBetsLabel)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emptyBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyBetsImageView.bottomAnchor.constraint(equalTo: self.emptyBaseView.centerYAnchor, constant: -30),
            self.emptyBetsImageView.widthAnchor.constraint(equalToConstant: 160),
            self.emptyBetsImageView.heightAnchor.constraint(equalTo: self.emptyBetsImageView.widthAnchor),
            self.emptyBetsImageView.centerXAnchor.constraint(equalTo: self.emptyBaseView.centerXAnchor),

            self.emptyBetsLabel.topAnchor.constraint(equalTo: self.emptyBetsImageView.bottomAnchor, constant: 20),
            self.emptyBetsLabel.leadingAnchor.constraint(equalTo: self.emptyBaseView.leadingAnchor, constant: 30),
            self.emptyBetsLabel.trailingAnchor.constraint(equalTo: self.emptyBaseView.trailingAnchor, constant: -30),
            self.emptyBetsLabel.centerXAnchor.constraint(equalTo: self.emptyBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }
}
