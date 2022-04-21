//
//  NewGroupManagementViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/04/2022.
//

import UIKit
import Combine

class NewGroupManagementViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var tableView: UITableView = Self.createTableView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: NewGroupViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: NewGroupViewModel) {
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

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(AddFriendTableViewCell.self,
                                forCellReuseIdentifier: AddFriendTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        //self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)


        //self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        //self.nextBaseView.backgroundColor = UIColor.App.backgroundPrimary

        //StyleHelper.styleButton(button: self.nextButton)

        //self.nextSeparatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    // MARK: Binding

    private func bind(toViewModel viewModel: NewGroupViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.canAddFriendPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                //self?.nextButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapCloseButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapNextButton() {
        print("NEXT")
        //self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapBackground() {

    }

}

extension NewGroupManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(AddFriendTableViewCell.self)
        else {
            fatalError()
        }

        if let userContact = self.viewModel.users[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedFriendCellViewModels[userContact.id] {
                // TEST
                if indexPath.row % 2 == 0 {
                    cellViewModel.isOnline = true
                }
                cell.configure(viewModel: cellViewModel)

                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                }
            }
            else {
                let cellViewModel = AddFriendCellViewModel(userContact: userContact)
                self.viewModel.cachedFriendCellViewModels[userContact.id] = cellViewModel
                // TEST
                if indexPath.row % 2 == 0 {
                    cellViewModel.isOnline = true
                }
                cell.configure(viewModel: cellViewModel)

                cell.didTapCheckboxAction = { [weak self] in
                    self?.viewModel.checkSelectedUserContact(cellViewModel: cellViewModel)
                }
            }

        }

        if indexPath.row == self.viewModel.users.count - 1 {
            cell.hasSeparatorLine = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
        else {
            fatalError()
        }

        let resultsLabel = localized("select_friends_add")

        headerView.configureHeader(title: resultsLabel)

        return headerView

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return 70

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 30

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

       return 30
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
extension NewGroupManagementViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("new_group")
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createNextBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNextButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("next"), for: .normal)
        return button
    }

    private static func createNextSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.closeButton)

        self.view.addSubview(self.tableView)

//        self.view.addSubview(self.nextBaseView)
//
//        self.nextBaseView.addSubview(self.nextButton)
//        self.nextBaseView.addSubview(self.nextSeparatorLineView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)

        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 16),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])

        // Add Friend Button View
//        NSLayoutConstraint.activate([
//            self.nextBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.nextBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.nextBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 8),
//            self.nextBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
//            self.nextBaseView.heightAnchor.constraint(equalToConstant: 105),
//
//            self.nextButton.leadingAnchor.constraint(equalTo: self.nextBaseView.leadingAnchor, constant: 33),
//            self.nextButton.trailingAnchor.constraint(equalTo: self.nextBaseView.trailingAnchor, constant: -33),
//            self.nextButton.heightAnchor.constraint(equalToConstant: 55),
//            self.nextButton.centerYAnchor.constraint(equalTo: self.nextBaseView.centerYAnchor),
//
//            self.nextSeparatorLineView.leadingAnchor.constraint(equalTo: self.nextBaseView.leadingAnchor),
//            self.nextSeparatorLineView.trailingAnchor.constraint(equalTo: self.nextBaseView.trailingAnchor),
//            self.nextSeparatorLineView.topAnchor.constraint(equalTo: self.nextBaseView.topAnchor),
//            self.nextSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
//        ])

    }
}
