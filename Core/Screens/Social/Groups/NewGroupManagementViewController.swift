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
    private lazy var newGroupInfoBaseView: UIView = Self.createNewGroupInfoBaseView()
    private lazy var newGroupIconBaseView: UIView = Self.createNewGroupIconBaseView()
    private lazy var newGroupIconInnerView: UIView = Self.createNewGroupIconInnerBaseView()
    private lazy var newGroupIconLabel: UILabel = Self.createNewGroupIconLabel()
    private lazy var textFieldBaseView: UIView = Self.createTextFieldBaseView()
    private lazy var newGroupTextField: UITextField = Self.createNewGroupTextField()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var startNewGroupBaseView: UIView = Self.createStartNewGroupBaseView()
    private lazy var startNewGroupButton: UIButton = Self.createStartNewGroupButton()
    private lazy var startNewGroupSeparatorLineView: UIView = Self.createStartNewGroupSeparatorLineView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: NewGroupManagementViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: NewGroupManagementViewModel) {
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

        self.newGroupTextField.delegate = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(ResultsHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ResultsHeaderFooterView.identifier)
        self.tableView.register(GroupUserManagementTableViewCell.self,
                                forCellReuseIdentifier: GroupUserManagementTableViewCell.identifier)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.startNewGroupButton.addTarget(self, action: #selector(didTapStartNewGroupButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.newGroupIconBaseView.layer.cornerRadius = self.newGroupIconBaseView.frame.height / 2

        self.newGroupIconInnerView.layer.cornerRadius = self.newGroupIconInnerView.frame.height / 2

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

        self.startNewGroupBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.newGroupIconBaseView.backgroundColor = UIColor.App.backgroundOdds

        self.newGroupIconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.newGroupIconLabel.textColor = UIColor.App.backgroundOdds

        self.textFieldBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.newGroupTextField.backgroundColor = UIColor.App.backgroundSecondary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.startNewGroupBaseView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.startNewGroupButton)

        self.startNewGroupSeparatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    // MARK: Binding

    private func bind(toViewModel viewModel: NewGroupManagementViewModel) {

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
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

    @objc func didTapStartNewGroupButton() {
        print("NEW GROUP")
        //self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapBackground() {
        self.newGroupTextField.resignFirstResponder()
    }

}

//
// MARK: Delegates
//
extension NewGroupManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(GroupUserManagementTableViewCell.self)
        else {
            fatalError()
        }

        if let userContact = self.viewModel.users[safe: indexPath.row] {

            if let cellViewModel = self.viewModel.cachedUserCellViewModels[userContact.id] {
                // TEST
                if indexPath.row % 2 == 0 {
                    cellViewModel.isOnline = true
                }
                if indexPath.row == 0 {
                    cellViewModel.isAdmin = true
                }

                cell.configure(viewModel: cellViewModel)

            }
            else {
                let cellViewModel = GroupUserManagementCellViewModel(userContact: userContact)
                self.viewModel.cachedUserCellViewModels[userContact.id] = cellViewModel
                // TEST
                if indexPath.row % 2 == 0 {
                    cellViewModel.isOnline = true
                }
                if indexPath.row == 0 {
                    cellViewModel.isAdmin = true
                }
                
                cell.configure(viewModel: cellViewModel)

            }

            cell.didTapDeleteAction = { [weak self] in
                self?.viewModel.users.remove(at: indexPath.row)
                self?.viewModel.cachedUserCellViewModels[userContact.id] = nil
                self?.tableView.reloadData()
            }
        }

        if indexPath.row == self.viewModel.users.count - 1 {
            cell.hasSeparatorLine = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

//        guard
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
//        else {
//            fatalError()
//        }
//
//        let resultsLabel = localized("select_friends_add")
//
//        headerView.configureHeader(title: resultsLabel)
//
//        return headerView

        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return 70

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

       return 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}

extension NewGroupManagementViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("TEXT: \(textField.text)")

        if let text = textField.text, text != "" {
            self.newGroupIconLabel.text = self.viewModel.getGroupInitials(text: text)
        }
        else {
            self.newGroupIconLabel.text = "G"
        }
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

    private static func createNewGroupInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconInnerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupIconLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "G"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        return label
    }

    private static func createTextFieldBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNewGroupTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = localized("group_name")
        textField.layer.cornerRadius = CornerRadius.view
        return textField
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createStartNewGroupBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStartNewGroupButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("start_group_chat"), for: .normal)
        return button
    }

    private static func createStartNewGroupSeparatorLineView() -> UIView {
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

        self.view.addSubview(self.newGroupInfoBaseView)

        self.newGroupInfoBaseView.addSubview(self.newGroupIconBaseView)

        self.newGroupIconBaseView.addSubview(self.newGroupIconInnerView)

        self.newGroupIconInnerView.addSubview(self.newGroupIconLabel)

        self.newGroupInfoBaseView.addSubview(self.textFieldBaseView)

        self.textFieldBaseView.addSubview(self.newGroupTextField)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.startNewGroupBaseView)

        self.startNewGroupBaseView.addSubview(self.startNewGroupButton)
        self.startNewGroupBaseView.addSubview(self.startNewGroupSeparatorLineView)

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

        // New Group Top View
        NSLayoutConstraint.activate([
            self.newGroupInfoBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.newGroupInfoBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.newGroupInfoBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.newGroupInfoBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.newGroupIconBaseView.leadingAnchor.constraint(equalTo: self.newGroupInfoBaseView.leadingAnchor, constant: 25),
            self.newGroupIconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.newGroupIconBaseView.heightAnchor.constraint(equalTo: self.newGroupIconBaseView.widthAnchor),
            self.newGroupIconBaseView.centerYAnchor.constraint(equalTo: self.newGroupInfoBaseView.centerYAnchor),

            self.newGroupIconInnerView.widthAnchor.constraint(equalToConstant: 37),
            self.newGroupIconInnerView.heightAnchor.constraint(equalTo: self.newGroupIconInnerView.widthAnchor),
            self.newGroupIconInnerView.centerXAnchor.constraint(equalTo: self.newGroupIconBaseView.centerXAnchor),
            self.newGroupIconInnerView.centerYAnchor.constraint(equalTo: self.newGroupIconBaseView.centerYAnchor),

            self.newGroupIconLabel.leadingAnchor.constraint(equalTo: self.newGroupIconInnerView.leadingAnchor, constant: 4),
            self.newGroupIconLabel.trailingAnchor.constraint(equalTo: self.newGroupIconInnerView.trailingAnchor, constant: -4),
            self.newGroupIconLabel.centerYAnchor.constraint(equalTo: self.newGroupIconInnerView.centerYAnchor),

            self.textFieldBaseView.leadingAnchor.constraint(equalTo: self.newGroupIconBaseView.trailingAnchor, constant: 8),
            self.textFieldBaseView.trailingAnchor.constraint(equalTo: self.newGroupInfoBaseView.trailingAnchor, constant: -25),
            self.textFieldBaseView.centerYAnchor.constraint(equalTo: self.newGroupInfoBaseView.centerYAnchor),
            self.textFieldBaseView.heightAnchor.constraint(equalToConstant: 50),

            self.newGroupTextField.leadingAnchor.constraint(equalTo: self.textFieldBaseView.leadingAnchor, constant: 10),
            self.newGroupTextField.trailingAnchor.constraint(equalTo: self.textFieldBaseView.trailingAnchor, constant: -10),
            self.newGroupTextField.topAnchor.constraint(equalTo: self.textFieldBaseView.topAnchor, constant: 5),
            self.newGroupTextField.bottomAnchor.constraint(equalTo: self.textFieldBaseView.bottomAnchor, constant: -5)

        ])

        // Tableview
        NSLayoutConstraint.activate([

            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.newGroupInfoBaseView.bottomAnchor, constant: 16),
            self.tableView.bottomAnchor.constraint(equalTo: self.startNewGroupBaseView.topAnchor)
        ])

        // New Group Button View
        NSLayoutConstraint.activate([
            self.startNewGroupBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.startNewGroupBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.startNewGroupBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 8),
            self.startNewGroupBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.startNewGroupBaseView.heightAnchor.constraint(equalToConstant: 105),

            self.startNewGroupButton.leadingAnchor.constraint(equalTo: self.startNewGroupBaseView.leadingAnchor, constant: 33),
            self.startNewGroupButton.trailingAnchor.constraint(equalTo: self.startNewGroupBaseView.trailingAnchor, constant: -33),
            self.startNewGroupButton.heightAnchor.constraint(equalToConstant: 55),
            self.startNewGroupButton.centerYAnchor.constraint(equalTo: self.startNewGroupBaseView.centerYAnchor),

            self.startNewGroupSeparatorLineView.leadingAnchor.constraint(equalTo: self.startNewGroupBaseView.leadingAnchor),
            self.startNewGroupSeparatorLineView.trailingAnchor.constraint(equalTo: self.startNewGroupBaseView.trailingAnchor),
            self.startNewGroupSeparatorLineView.topAnchor.constraint(equalTo: self.startNewGroupBaseView.topAnchor),
            self.startNewGroupSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])

    }
}
