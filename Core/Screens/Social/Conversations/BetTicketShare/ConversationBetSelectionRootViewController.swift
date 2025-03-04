//
//  ConversationBetSelectionRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/06/2022.
//

import UIKit
import Combine

class ConversationBetSelectionRootViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var navigationLineSeparatorView: UIView = Self.createNavigationLineSeparatorView()

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var ticketTypesCollectionView: UICollectionView = Self.createTicketTypesCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()

    private lazy var messageInputBaseView: UIView = Self.createMessageInputBaseView()
    private lazy var messageInputLineSeparatorView: UIView = Self.createMessageInputLineSeparatorView()
    private lazy var messageInputView: ChatMessageView = Self.createMessageInputView()
    private lazy var sendButton: UIButton = Self.createSendButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    // Constraints
    private lazy var viewHeightConstraint: NSLayoutConstraint = Self.createViewHeightConstraint()

    // Constraints
    private lazy var messageInputBottomConstraint: NSLayoutConstraint = Self.createMessageInputBottomConstraint()
    private lazy var messageInputKeyboardConstraint: NSLayoutConstraint = Self.createMessageInputKeyboardConstraint()

    private var ticketTypePagedViewController: UIPageViewController
    private var ticketTypesViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: ConversationBetSelectionRootViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: ConversationBetSelectionRootViewModel) {
        self.viewModel = viewModel

        self.ticketTypePagedViewController  = UIPageViewController(transitionStyle: .scroll,
                                                                   navigationOrientation: .horizontal,
                                                                   options: nil)

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

//        self.ticketTypesViewControllers = [
//            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .opened)),
//            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .resolved)),
//            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .won))
//        ]

        let openConversationBetViewController = ConversationBetSelectionViewController(viewModel: ConversationBetSelectionViewModel(ticketType: .opened))
        openConversationBetViewController.selectedBetTicketPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedTicket in
                self?.viewModel.openSelectedTicket = selectedTicket
            })
            .store(in: &cancellables)

        let resolvedConversationBetViewController = ConversationBetSelectionViewController(viewModel: ConversationBetSelectionViewModel(ticketType: .resolved))
        resolvedConversationBetViewController.selectedBetTicketPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedTicket in
                self?.viewModel.resolvedSelectedTicket = selectedTicket
            })
            .store(in: &cancellables)

        let wonConversationBetViewController = ConversationBetSelectionViewController(viewModel: ConversationBetSelectionViewModel(ticketType: .won))
        wonConversationBetViewController.selectedBetTicketPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedTicket in
                self?.viewModel.wonSelectedTicket = selectedTicket
            })
            .store(in: &cancellables)

        self.ticketTypesViewControllers = [
            openConversationBetViewController,
            resolvedConversationBetViewController,
            wonConversationBetViewController
        ]

        self.ticketTypePagedViewController.delegate = self
        self.ticketTypePagedViewController.dataSource = self

        self.ticketTypesCollectionView.register(ListTypeCollectionViewCell.self,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.ticketTypesCollectionView.delegate = self
        self.ticketTypesCollectionView.dataSource = self

        self.reloadCollectionView()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.pagesBaseView.addGestureRecognizer(backgroundTapGesture)

        self.bind(toViewModel: self.viewModel)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.sendButton.layer.cornerRadius = CornerRadius.button
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

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.closeButton.backgroundColor = .clear

        self.navigationLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.topBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.ticketTypesCollectionView.backgroundColor = UIColor.App.pillNavigation

        self.messageInputBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.messageInputLineSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.sendButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.8)
   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: ConversationBetSelectionRootViewModel) {

        viewModel.selectedTicketTypeIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

        viewModel.chatTitlePublisher
            .sink(receiveValue: { [weak self] title in
                self?.subtitleLabel.text = title
            })
            .store(in: &cancellables)

        viewModel.hasTicketSelectedPublisher
           .receive(on: DispatchQueue.main)
           .sink(receiveValue: { [weak self] hasTicketSelected in
               self?.sendButton.isEnabled = hasTicketSelected
           })
           .store(in: &cancellables)

        viewModel.messageSentAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        viewModel.isLoadingSharedBetPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                }            })
            .store(in: &cancellables)
    }

    // MARK: Functions

    func reloadCollectionView() {
        self.ticketTypesCollectionView.reloadData()
    }

    func scrollToViewController(atIndex index: Int) {
        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.ticketTypesViewControllers[safe: index] {
                self.ticketTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .forward,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }
        else {
            if let selectedViewController = self.ticketTypesViewControllers[safe: index] {
                self.ticketTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .reverse,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
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

    @objc func didTapSendButton() {
        let message = self.messageInputView.getTextViewValue()

        if message != "" {
            self.viewModel.sendMessage(message: message)
        }
        else {
            let defaultMessage = localized("check_this_bet_made")
            self.viewModel.sendMessage(message: defaultMessage)
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.messageInputView.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.messageInputKeyboardConstraint.isActive = false
        self.messageInputBottomConstraint.isActive = true

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height - self.bottomSafeAreaView.frame.height

            self.messageInputKeyboardConstraint =
            NSLayoutConstraint(item: self.messageInputBaseView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.bottomSafeAreaView,
                               attribute: .top,
                               multiplier: 1,
                               constant: -keyboardHeight)
            self.messageInputBottomConstraint.isActive = false
            self.messageInputKeyboardConstraint.isActive = true
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.messageInputKeyboardConstraint.isActive = false
        self.messageInputBottomConstraint.isActive = true
    }
}

extension ConversationBetSelectionRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectTicketType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectTicketType(atIndex: index)

        self.ticketTypesCollectionView.reloadData()
        self.ticketTypesCollectionView.layoutIfNeeded()
        self.ticketTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = ticketTypesViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return ticketTypesViewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = ticketTypesViewControllers.firstIndex(of: viewController) {
            if index < ticketTypesViewControllers.count - 1 {
                return ticketTypesViewControllers[index + 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if !completed {
            return
        }

        if let currentViewController = pageViewController.viewControllers?.first,
           let index = ticketTypesViewControllers.firstIndex(of: currentViewController) {
            self.selectTicketType(atIndex: index)
        }
        else {
            self.selectTicketType(atIndex: 0)
        }
    }

}

extension ConversationBetSelectionRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle(localized("open"))
        case 1:
            cell.setupWithTitle(localized("resolved"))
        case 2:
            cell.setupWithTitle(localized("won"))
        default:
            ()
        }

        if let index = self.viewModel.selectedTicketTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.viewModel.selectedTicketTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.viewModel.selectedTicketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension ConversationBetSelectionRootViewController {
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

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconIdentifierLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "C"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createIconUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createIconStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("share_my_tickets")
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.font = AppFont.with(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "@chattitle"
        return label
    }

    private static func createCloseButton() -> UIButton {
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle(localized("cancel"), for: .normal)
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return backButton
    }

    private static func createNavigationLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketTypesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return collectionView
    }

    private static func createPagesBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageInputBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageInputLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMessageInputView() -> ChatMessageView {
        let view = ChatMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hasTicketButton = false
        return view
    }

    private static func createSendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "send_message_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }

    private static func createMessageInputBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createMessageInputKeyboardConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createViewHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
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

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.subtitleLabel)
        self.navigationView.addSubview(self.closeButton)
        self.navigationView.addSubview(self.navigationLineSeparatorView)

        self.view.addSubview(self.topBaseView)
        self.topBaseView.addSubview(self.ticketTypesCollectionView)

        self.view.addSubview(self.pagesBaseView)

        self.view.addSubview(self.messageInputBaseView)

        self.messageInputBaseView.addSubview(self.messageInputLineSeparatorView)
        self.messageInputBaseView.addSubview(self.messageInputView)
        self.messageInputBaseView.addSubview(self.sendButton)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.addChildViewController(self.ticketTypePagedViewController, toView: self.pagesBaseView)

        self.initConstraints()

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.messageInputView.shouldResizeView = { [weak self] newHeight in
            self?.viewHeightConstraint.constant = newHeight
            self?.view.layoutIfNeeded()
        }

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

            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 60),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -60),
            self.titleLabel.topAnchor.constraint(equalTo: self.navigationView.topAnchor, constant: 6),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 60),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -60),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),

            self.closeButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -10),

            self.navigationLineSeparatorView.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.navigationLineSeparatorView.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor),
            self.navigationLineSeparatorView.bottomAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.navigationLineSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Page Control
        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.ticketTypesCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.ticketTypesCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.ticketTypesCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.ticketTypesCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),

            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.messageInputBaseView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.messageInputBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.messageInputBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.messageInputBaseView.topAnchor.constraint(equalTo: self.pagesBaseView.bottomAnchor),
//            self.messageInputBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            // self.messageInputBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.messageInputLineSeparatorView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor),
            self.messageInputLineSeparatorView.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor),
            self.messageInputLineSeparatorView.topAnchor.constraint(equalTo: self.messageInputBaseView.topAnchor),
            self.messageInputLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            self.messageInputView.leadingAnchor.constraint(equalTo: self.messageInputBaseView.leadingAnchor, constant: 15),
            self.messageInputView.bottomAnchor.constraint(equalTo: self.messageInputBaseView.bottomAnchor, constant: -10),

            self.sendButton.leadingAnchor.constraint(equalTo: self.messageInputView.trailingAnchor, constant: 16),
            self.sendButton.trailingAnchor.constraint(equalTo: self.messageInputBaseView.trailingAnchor, constant: -15),
            self.sendButton.bottomAnchor.constraint(equalTo: self.messageInputBaseView.bottomAnchor, constant: -12),
            self.sendButton.widthAnchor.constraint(equalToConstant: 46),
            self.sendButton.heightAnchor.constraint(equalTo: self.sendButton.widthAnchor)
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

        self.messageInputBottomConstraint =
        NSLayoutConstraint(item: self.messageInputBaseView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.bottomSafeAreaView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0)
        self.messageInputBottomConstraint.isActive = true

        self.messageInputKeyboardConstraint.isActive = false

        self.viewHeightConstraint = self.messageInputBaseView.heightAnchor.constraint(equalToConstant: 70)
        self.viewHeightConstraint.isActive = true
    }
}
