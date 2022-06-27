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
//    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
//    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
//    private lazy var navigationView: UIView = Self.createNavigationView()
//    private lazy var titleLabel: UILabel = Self.createTitleLabel()
//    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
//    private lazy var closeButton: UIButton = Self.createCloseButton()
//    private lazy var navigationLineSeparatorView: UIView = Self.createNavigationLineSeparatorView()
    
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyBaseView: UIView = Self.createEmptyBaseView()
    private lazy var emptyBetsImageView: UIImageView = Self.createEmptyBetsImageView()
    private lazy var emptyBetsLabel: UILabel = Self.createEmptyBetsLabel()
//    private lazy var messageInputBaseView: UIView = Self.createMessageInputBaseView()
//    private lazy var messageInputLineSeparatorView: UIView = Self.createMessageInputLineSeparatorView()
//    private lazy var messageInputView: ChatMessageView = Self.createMessageInputView()
//    private lazy var sendButton: UIButton = Self.createSendButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Constraints
//    private lazy var messageInputBottomConstraint: NSLayoutConstraint = Self.createMessageInputBottomConstraint()
//    private lazy var messageInputKeyboardConstraint: NSLayoutConstraint = Self.createMessageInputKeyboardConstraint()

    private var viewModel: ConversationBetSelectionViewModel

    private var cancellables = Set<AnyCancellable>()

//    private var isChatGroup: Bool = false {
//        didSet {
//            self.iconIdentifierLabel.isHidden = !isChatGroup
//            self.iconUserImageView.isHidden = isChatGroup
//        }
//    }

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

//        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
//
//        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)
//
//        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
//        self.view.addGestureRecognizer(backgroundTapGesture)

        // self.isChatGroup = self.viewModel.isChatGroup

        self.bind(toViewModel: self.viewModel)

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        // self.sendButton.layer.cornerRadius = CornerRadius.button
        self.emptyBetsImageView.layer.cornerRadius = self.emptyBetsImageView.frame.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

//        self.topSafeAreaView.backgroundColor = .clear
//
//        self.bottomSafeAreaView.backgroundColor = .clear
//
//        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
//
//        self.titleLabel.textColor = UIColor.App.textPrimary
//
//        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
//        self.closeButton.backgroundColor = .clear
//
//        self.navigationLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.tableView.backgroundColor = .clear

        self.emptyBaseView.backgroundColor = .clear

        self.emptyBetsImageView.backgroundColor = .clear

        self.emptyBetsLabel.textColor = UIColor.App.textPrimary

//        self.messageInputBaseView.backgroundColor = UIColor.App.backgroundPrimary
//
//        self.messageInputLineSeparatorView.backgroundColor = UIColor.App.separatorLine
//
//        self.sendButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ConversationBetSelectionViewModel) {

//        viewModel.chatTitlePublisher
//            .sink(receiveValue: { [weak self] title in
//                self?.subtitleLabel.text = title
//            })
//            .store(in: &cancellables)

        viewModel.dataNeedsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

         viewModel.hasTicketSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasTicketSelected in
                // self?.sendButton.isEnabled = hasTicketSelected
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

//        viewModel.isLoadingOpened
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] isLoading in
//                self?.isLoading = isLoading
//            })
//            .store(in: &cancellables)

//        viewModel.openedTicketsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] tickets in
//                self?.isEmpty = tickets.isEmpty
//            })
//            .store(in: &cancellables)

//        viewModel.messageSentAction = { [weak self] in
//            self?.dismiss(animated: true, completion: nil)
//        }

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

//    @objc func didTapSendButton() {
//        let message = self.messageInputView.getTextViewValue()
//        self.viewModel.sendMessage(message: message)
//    }
//
//    @objc func didTapBackground() {
//        self.resignFirstResponder()
//
//        self.messageInputView.resignFirstResponder()
//    }

//    @objc func keyboardWillShow(notification: NSNotification) {
//        self.messageInputKeyboardConstraint.isActive = false
//        self.messageInputBottomConstraint.isActive = true
//
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardSize.height - self.bottomSafeAreaView.frame.height
//
//            self.messageInputKeyboardConstraint =
//            NSLayoutConstraint(item: self.messageInputBaseView,
//                               attribute: .bottom,
//                               relatedBy: .equal,
//                               toItem: self.bottomSafeAreaView,
//                               attribute: .top,
//                               multiplier: 1,
//                               constant: -keyboardHeight)
//            self.messageInputBottomConstraint.isActive = false
//            self.messageInputKeyboardConstraint.isActive = true
//            }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        self.messageInputKeyboardConstraint.isActive = false
//        self.messageInputBottomConstraint.isActive = true
//    }
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
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ResultsHeaderFooterView.identifier) as? ResultsHeaderFooterView
        else {
            fatalError()
        }

        let headerDate = self.viewModel.sectionTitle(forSectionIndex: section)
        headerView.configureHeader(title: headerDate)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 20
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
//    private static func createTopSafeAreaView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createBottomSafeAreaView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createNavigationView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createIconBaseView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createIconView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createIconIdentifierLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "C"
//        label.font = AppFont.with(type: .bold, size: 16)
//        return label
//    }
//
//    private static func createIconUserImageView() -> UIImageView {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "my_account_profile_icon")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }
//
//    private static func createIconStateView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createTitleLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = UIColor.App.textPrimary
//        label.font = AppFont.with(type: .bold, size: 16)
//        label.textAlignment = .center
//        label.numberOfLines = 1
//        label.text = localized("share_my_tickets")
//        return label
//    }
//
//    private static func createSubtitleLabel() -> UILabel {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = UIColor.App.textSecondary
//        label.font = AppFont.with(type: .regular, size: 14)
//        label.textAlignment = .center
//        label.numberOfLines = 1
//        label.text = "@chattitle"
//        return label
//    }
//
//    private static func createCloseButton() -> UIButton {
//        let backButton = UIButton()
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.setTitle(localized("cancel"), for: .normal)
//        backButton.setContentHuggingPriority(.required, for: .horizontal)
//        backButton.titleLabel?.font = AppFont.with(type: .bold, size: 14)
//        return backButton
//    }
//
//    private static func createNavigationLineSeparatorView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }

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

//    private static func createMessageInputBaseView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createMessageInputLineSeparatorView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createMessageInputView() -> ChatMessageView {
//        let view = ChatMessageView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.hasTicketButton = false
//        return view
//    }
//
//    private static func createSendButton() -> UIButton {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "send_message_icon"), for: .normal)
//        button.contentMode = .scaleAspectFit
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
//        return button
//    }
//
//    private static func createMessageInputBottomConstraint() -> NSLayoutConstraint {
//        let constraint = NSLayoutConstraint()
//        return constraint
//    }
//
//    private static func createMessageInputKeyboardConstraint() -> NSLayoutConstraint {
//        let constraint = NSLayoutConstraint()
//        return constraint
//    }

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

//        self.view.addSubview(self.topSafeAreaView)
//
//        self.view.addSubview(self.navigationView)
//
//        self.navigationView.addSubview(self.titleLabel)
//        self.navigationView.addSubview(self.subtitleLabel)
//        self.navigationView.addSubview(self.closeButton)
//        self.navigationView.addSubview(self.navigationLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyBaseView)

        self.emptyBaseView.addSubview(self.emptyBetsImageView)
        self.emptyBaseView.addSubview(self.emptyBetsLabel)

//        self.view.addSubview(self.messageInputBaseView)
//
//        self.messageInputBaseView.addSubview(self.messageInputLineSeparatorView)
//        self.messageInputBaseView.addSubview(self.messageInputView)
//        self.messageInputBaseView.addSubview(self.sendButton)
//
//        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
//        NSLayoutConstraint.activate([
//            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
//
//            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
//            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        ])

        // Navigation View
//        NSLayoutConstraint.activate([
//            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
//            self.navigationView.heightAnchor.constraint(equalToConstant: 44),
//
//            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 60),
//            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -60),
//            self.titleLabel.topAnchor.constraint(equalTo: self.navigationView.topAnchor, constant: 6),
//
//            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 60),
//            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -60),
//            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
//
//            self.closeButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
//            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
//            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -10),
//
//            self.navigationLineSeparatorView.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
//            self.navigationLineSeparatorView.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor),
//            self.navigationLineSeparatorView.bottomAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
//            self.navigationLineSeparatorView.heightAnchor.constraint(equalToConstant: 1)
//        ])

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
            self.emptyBaseView.bottomAnchor.constraint(equalTo:     self.view.bottomAnchor),

            self.emptyBetsImageView.bottomAnchor.constraint(equalTo: self.emptyBaseView.centerYAnchor, constant: -30),
            self.emptyBetsImageView.widthAnchor.constraint(equalToConstant: 160),
            self.emptyBetsImageView.heightAnchor.constraint(equalTo: self.emptyBetsImageView.widthAnchor),
            self.emptyBetsImageView.centerXAnchor.constraint(equalTo: self.emptyBaseView.centerXAnchor),

            self.emptyBetsLabel.topAnchor.constraint(equalTo: self.emptyBetsImageView.bottomAnchor, constant: 20),
            self.emptyBetsLabel.leadingAnchor.constraint(equalTo: self.emptyBaseView.leadingAnchor, constant: 30),
            self.emptyBetsLabel.trailingAnchor.constraint(equalTo: self.emptyBaseView.trailingAnchor, constant: -30),
            self.emptyBetsLabel.centerXAnchor.constraint(equalTo: self.emptyBaseView.centerXAnchor),
        ])

//        NSLayoutConstraint.activate([
//            self.messageInputBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.messageInputBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.messageInputBaseView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor),
////            self.messageInputBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
//            self.messageInputBaseView.heightAnchor.constraint(equalToConstant: 70),
//
//            self.messageInputLineSeparatorView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor),
//            self.messageInputLineSeparatorView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor),
//            self.messageInputLineSeparatorView.topAnchor.constraint(equalTo: self.messageInputBaseView.topAnchor),
//            self.messageInputLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),
//
//            self.messageInputView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor, constant: 15),
////            self.messageInputView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -70),
//            self.messageInputView.centerYAnchor.constraint(equalTo: self.messageInputBaseView.centerYAnchor),
//
//            self.sendButton.leadingAnchor.constraint(equalTo: self.messageInputView.trailingAnchor, constant: 16),
//            self.sendButton.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -15),
//            self.sendButton.centerYAnchor.constraint(equalTo: self.messageInputBaseView.centerYAnchor),
//            self.sendButton.widthAnchor.constraint(equalToConstant: 46),
//            self.sendButton.heightAnchor.constraint(equalTo: self.sendButton.widthAnchor)
//        ])

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

//        self.messageInputBottomConstraint =
//        NSLayoutConstraint(item: self.messageInputBaseView,
//                           attribute: .bottom,
//                           relatedBy: .equal,
//                           toItem: self.bottomSafeAreaView,
//                           attribute: .top,
//                           multiplier: 1,
//                           constant: 0)
//        self.messageInputBottomConstraint.isActive = true
//
//        self.messageInputKeyboardConstraint.isActive = false

    }
}
