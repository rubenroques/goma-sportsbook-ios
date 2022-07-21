//
//  ShareTicketChoiceViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2022.
//

import UIKit
import Combine
import LinkPresentation
import Social

class ShareTicketChoiceViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var bottomShareView: UIView = Self.createBottomShareView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var chatTitleLabel: UILabel = Self.createChatTitleLabel()
    private lazy var chatCollectionView: UICollectionView = Self.createChatCollectionView()
    private lazy var separatorView: UIView = Self.createSeparatorView()
    private lazy var leftSeparatorLineView: UIView = Self.createLeftSeparatorLineView()
    private lazy var rightSeparatorLineView: UIView = Self.createRightSeparatorLineView()
    private lazy var titleSeparatorLabel: UILabel = Self.createTitleSeparatorLabel()
    private lazy var sendViaButton: UIButton = Self.createSendViaButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private lazy var emptyChatroomsView: UIView = Self.createEmptyChatroomsView()
    private lazy var emptyChatroomsLabel: UILabel = Self.createEmptyChatroomsLabel()
    private var cancellables = Set<AnyCancellable>()

    var viewModel: ShareTicketChoiceViewModel
    let pasteboard = UIPasteboard.general

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            self.emptyChatroomsView.isHidden = !isEmptyState
            self.chatCollectionView.isHidden = isEmptyState
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: ShareTicketChoiceViewModel) {
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

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)

        self.chatCollectionView.delegate = self
        self.chatCollectionView.dataSource = self

        self.chatCollectionView.register(SocialItemCollectionViewCell.self,
                                        forCellWithReuseIdentifier: SocialItemCollectionViewCell.identifier)

        self.sendViaButton.addTarget(self, action: #selector(didTapSendViaButton), for: .primaryActionTriggered)

        self.bind(toViewModel: self.viewModel)

        self.isLoading = false

        self.isEmptyState = false
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.bottomShareView.layer.cornerRadius = CornerRadius.view
        self.bottomShareView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bottomShareView.clipsToBounds = true

        self.sendViaButton.layer.cornerRadius = CornerRadius.button
        self.sendViaButton.clipsToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.5)

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.bottomShareView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.chatCollectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.chatCollectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.separatorView.backgroundColor = .clear

        self.leftSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.rightSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.sendViaButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextDisablePrimary.withAlphaComponent(0.7), for: .disabled)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyChatroomsView.backgroundColor = .clear

        self.emptyChatroomsLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ShareTicketChoiceViewModel) {

        viewModel.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.chatCollectionView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.messageSentAction = { [weak self] in
            guard let self = self else {return}

            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }

        viewModel.chatrooms
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] chatrooms in
                self?.isEmptyState = chatrooms.isEmpty
            })
            .store(in: &cancellables)

    }

    // MARK: Functions
    private func openMoreOptions() {
        if let sharedTicketInfo = self.viewModel.clickedShareTicketInfo {
            let shareTicketFriendGroupViewModel = ShareTicketFriendGroupViewModel(sharedTicketInfo: sharedTicketInfo)

            let shareTicketFriendGroupViewController = ShareTicketFriendGroupViewController(viewModel: shareTicketFriendGroupViewModel)

            shareTicketFriendGroupViewController.shouldCloseParentViewController = { [weak self] in
                self?.closeViewController()
            }

            let navigationViewController = Router.navigationController(with: shareTicketFriendGroupViewController)
            self.present(navigationViewController, animated: true, completion: nil)
            //self.present(shareTicketFriendGroupViewController, animated: true)
        }
    }

    private func shareTicketToChatroom(chatroomData: ChatroomData) {
        self.viewModel.sendTicketMessage(chatroomData: chatroomData)
    }

    private func closeViewController() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func showSocialShareScreen(socialApp: SocialApp) {

        if socialApp.urlShare != "" {
            if let betStatus = self.viewModel.clickedShareTicketInfo?.betStatus {
                let urlMobile = Env.urlMobileShares
                if betStatus == "OPEN",
                   let betToken = self.viewModel.clickedShareTicketInfo?.betToken {
                    let matchUrlString = "\(urlMobile)/bet/\(betToken)"

                    let socialAppUrlShareString = socialApp.urlShare.replacingOccurrences(of: "%url", with: matchUrlString)

                    if let urlString = socialAppUrlShareString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        if let socialShareUrl = URL(string: urlString) {
                            if UIApplication.shared.canOpenURL(socialShareUrl) {
                                UIApplication.shared.open(socialShareUrl, options: [:], completionHandler: nil)
                            } else {
                                print("Cannot share on \(socialApp.name)")
                            }
                         }
                    }
                }
            }
        }
        else {
            print("URL share on \(socialApp.name) not available")
        }

    }

    // MARK: Actions
    @objc func didTapCancelButton() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapCopyLinkButton() {
        print("COPY LINK")

        if let betStatus = self.viewModel.clickedShareTicketInfo?.betStatus {

            let urlMobile = Env.urlMobileShares

            if betStatus == "OPEN",
               let betToken = self.viewModel.clickedShareTicketInfo?.betToken {
                let matchUrlString = "\(urlMobile)/bet/\(betToken)"

                self.pasteboard.string = matchUrlString

                let customUrlString = localized("ticket_url_pasteboard")

                let customToast = ToastCustom.text(title: customUrlString)

                customToast.show()
            }

        }

    }

    @objc func didTapSendViaButton() {

        let metadata = LPLinkMetadata()
        let urlMobile = Env.urlMobileShares

        if let gameSnapshot = self.viewModel.clickedShareTicketInfo?.snapshot, let betStatus = self.viewModel.clickedShareTicketInfo?.betStatus {

            if betStatus == "OPEN",
               let betToken = self.viewModel.clickedShareTicketInfo?.betToken{

                let matchUrl = URL(string: "\(urlMobile)/bet/\(betToken)")
                metadata.url = matchUrl
                metadata.originalURL = metadata.url
            }

            let imageProvider = NSItemProvider(object: gameSnapshot)
            metadata.imageProvider = imageProvider
            metadata.title = localized("look_bet_made")
        }

        let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

        if let betStatus = self.viewModel.clickedShareTicketInfo?.betStatus, betStatus == "OPEN" {
            let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, self.viewModel.clickedShareTicketInfo?.snapshot],
                                                                       applicationActivities: nil)
            if let popoverController = shareActivityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(shareActivityViewController, animated: true, completion: nil)
        }
        else {
            let shareActivityViewController = UIActivityViewController(activityItems: [self.viewModel.clickedShareTicketInfo?.snapshot],
                                                                       applicationActivities: nil)
            if let popoverController = shareActivityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(shareActivityViewController, animated: true, completion: nil)
        }
    }

}

extension ShareTicketChoiceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueCellType(SocialItemCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        if indexPath.row < 4 {
            if let chatroomData = self.viewModel.chatrooms.value[safe: indexPath.row] {

                let cellViewModel = SocialItemCellViewModel(chatroomData: chatroomData)

                cell.configure(withViewModel: cellViewModel)

                cell.shouldShareTicket = {
                    self.shareTicketToChatroom(chatroomData: chatroomData)

                }

            }
        }
        else {
            cell.simpleConfigure()

            cell.shouldOpenMoreOptions = {
                self.openMoreOptions()
            }
        }

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if self.viewModel.chatrooms.value.count <= 4 {
            return self.viewModel.chatrooms.value.count
        }
        return 5

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == self.chatCollectionView {
//            if let chatroom = self.viewModel.chatrooms.value[safe: indexPath.row] {
//                self.shareTicketToChatroom(chatroomData: chatroom)
//            }
//
//        }
//        else {
//            let socialApp = self.viewModel.socialApps.value[safe: indexPath.row]
//
//        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat =  30
        let collectionViewWidth = collectionView.frame.size.width - padding
        let collectionViewHeight = collectionView.frame.size.height - 8
        return CGSize(width: collectionViewWidth/5, height: collectionViewHeight)
    }
}

extension ShareTicketChoiceViewController {
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

    private static func createBottomShareView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("share_ticket")
        return label
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 13)
        return button
    }

    private static func createChatCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true

        collectionView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        return collectionView
    }

    private static func createChatTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = localized("send_to_chat")
        return label
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLeftSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createRightSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createTitleSeparatorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.buttonBackgroundSecondary
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = localized("or")
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createSendViaButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("share_outside_via"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.setImage(UIImage(named: "send_via_icon"), for: .normal)
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -2, left: -10, bottom: 0, right: 0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.layer.cornerRadius = CornerRadius.button
        return button
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private static func createEmptyChatroomsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyChatroomsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.buttonBackgroundSecondary
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = localized("empty_chatrooms")
        return label
    }
    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomShareView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.bottomShareView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.cancelButton)

        self.bottomShareView.addSubview(self.chatTitleLabel)

        self.bottomShareView.addSubview(self.emptyChatroomsView)

        self.emptyChatroomsView.addSubview(self.emptyChatroomsLabel)

        self.bottomShareView.addSubview(self.chatCollectionView)

        self.bottomShareView.addSubview(self.separatorView)

        self.bottomShareView.addSubview(self.leftSeparatorLineView)
        self.bottomShareView.addSubview(self.titleSeparatorLabel)
        self.bottomShareView.addSubview(self.rightSeparatorLineView)

        self.bottomShareView.addSubview(self.sendViaButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

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

        // Bottom share view
        NSLayoutConstraint.activate([
            self.bottomShareView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomShareView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomShareView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.bottomShareView.topAnchor, constant: 10),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.cancelButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 40)

        ])

        // Chat collection view
        NSLayoutConstraint.activate([

            self.chatTitleLabel.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 20),
            self.chatTitleLabel.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 10),

            self.chatCollectionView.heightAnchor.constraint(equalToConstant: 105),

            self.chatCollectionView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 15),
            self.chatCollectionView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -15),
            self.chatCollectionView.topAnchor.constraint(equalTo: self.chatTitleLabel.bottomAnchor, constant: 2)
        ])

        // Separator stack view
        NSLayoutConstraint.activate([
            self.separatorView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 18),
            self.separatorView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -18),
            self.separatorView.topAnchor.constraint(equalTo: self.chatCollectionView.bottomAnchor, constant: 5),
            self.separatorView.heightAnchor.constraint(equalToConstant: 20),

            self.leftSeparatorLineView.leadingAnchor.constraint(equalTo: self.separatorView.leadingAnchor),
            self.leftSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.leftSeparatorLineView.centerYAnchor.constraint(equalTo: self.separatorView.centerYAnchor),

            self.titleSeparatorLabel.centerXAnchor.constraint(equalTo: self.separatorView.centerXAnchor),
            self.titleSeparatorLabel.leadingAnchor.constraint(equalTo: self.leftSeparatorLineView.trailingAnchor, constant: 10),
            self.titleSeparatorLabel.centerYAnchor.constraint(equalTo: self.separatorView.centerYAnchor),

            self.rightSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.rightSeparatorLineView.leadingAnchor.constraint(equalTo: self.titleSeparatorLabel.trailingAnchor, constant: 10),
            self.rightSeparatorLineView.trailingAnchor.constraint(equalTo: self.separatorView.trailingAnchor),
            self.rightSeparatorLineView.centerYAnchor.constraint(equalTo: self.separatorView.centerYAnchor),

        ])

        // Send via button
        NSLayoutConstraint.activate([
            self.sendViaButton.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 90),
            self.sendViaButton.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -90),
            self.sendViaButton.heightAnchor.constraint(equalToConstant: 31),
            self.sendViaButton.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 15),
            self.sendViaButton.bottomAnchor.constraint(equalTo: self.bottomShareView.bottomAnchor, constant: -15)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

        // Empty chatrooms view
        NSLayoutConstraint.activate([
            self.emptyChatroomsView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor),
            self.emptyChatroomsView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor),
            self.emptyChatroomsView.topAnchor.constraint(equalTo: self.chatTitleLabel.bottomAnchor, constant: 2),
            self.emptyChatroomsView.bottomAnchor.constraint(equalTo: self.separatorView.topAnchor, constant: -5),

            self.emptyChatroomsLabel.leadingAnchor.constraint(equalTo: self.emptyChatroomsView.leadingAnchor, constant: 15),
            self.emptyChatroomsLabel.trailingAnchor.constraint(equalTo: self.emptyChatroomsView.trailingAnchor, constant: -15),
            self.emptyChatroomsLabel.centerYAnchor.constraint(equalTo: self.emptyChatroomsView.centerYAnchor)
        ])
    }
}

struct ClickedShareTicketInfo {
    var snapshot: UIImage?
    var betId: String?
    var betStatus: String?
    var betToken: String
    var ticket: BetHistoryEntry?
}

struct SocialApp {
    var id: String
    var name: String
    var iconName: String
    var appScheme: String
    var urlShare: String
}
