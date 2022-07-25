//
//  MessagesViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 25/07/2022.
//

import UIKit

class MessagesViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var markAllReadButton: UIButton = Self.createMarkAllReadButton()
    private lazy var deleteAllButton: UIButton = Self.createDeleteAllButton()
    private lazy var tableView: UITableView = Self.createTableView()

    // MARK: Lifetime and Cycle
    init() {
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.markAllReadButton.addTarget(self, action: #selector(didTapMarkAllReadButton), for: .primaryActionTriggered)

        self.deleteAllButton.addTarget(self, action: #selector(didTapDeleteAllButton), for: .primaryActionTriggered)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(InAppMessageTableViewCell.self,
                                forCellReuseIdentifier: InAppMessageTableViewCell.identifier)
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.markAllReadButton.backgroundColor = .clear
        self.markAllReadButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.deleteAllButton.backgroundColor = .clear
        self.deleteAllButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.tableView.backgroundColor = .red

    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMarkAllReadButton() {
        print("MARK ALL READ")
    }

    @objc private func didTapDeleteAllButton() {
        print("DELETE ALL")
    }
}

extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(InAppMessageTableViewCell.self)
        else {
            fatalError()
        }

        cell.configure(cardType: .promo)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 88

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.01

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

//
// MARK: Subviews initialization and setup
//
extension MessagesViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("messages")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createMarkAllReadButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("mark_all_read"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createDeleteAllButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("delete_all"), for: .normal)
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

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.bringSubviewToFront(self.topTitleLabel)

        self.view.addSubview(self.markAllReadButton)

        self.view.addSubview(self.deleteAllButton)

        self.view.addSubview(self.tableView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 20),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -20),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)
        ])

        // Action Buttons
        NSLayoutConstraint.activate([
            self.markAllReadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.markAllReadButton.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 10),
            self.markAllReadButton.heightAnchor.constraint(equalToConstant: 40),

            self.deleteAllButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.deleteAllButton.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 10),
            self.deleteAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Tableview
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            self.tableView.topAnchor.constraint(equalTo: self.markAllReadButton.bottomAnchor, constant: 10),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

    }

}
