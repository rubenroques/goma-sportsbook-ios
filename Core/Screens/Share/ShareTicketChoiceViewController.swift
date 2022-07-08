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

class ShareTicketChoiceViewModel {

    var chatrooms: CurrentValueSubject<[ChatroomData], Never> = .init([])
    var socialApps: CurrentValueSubject<[SocialApp], Never> = .init([])
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()
    var clickedShareTicketInfo: ClickedShareTicketInfo?
    var messageSentAction: (() -> Void)?
    var canCopyLinkPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var canShareLinkSocialApps: CurrentValueSubject<Bool, Never> = .init(false)
    private var cancellables = Set<AnyCancellable>()

    init(clickedShareTicketInfo: ClickedShareTicketInfo) {

        self.clickedShareTicketInfo = clickedShareTicketInfo

        self.checkCopyLink()
        self.checkSocialAppSharesAvailability()

        self.getChatrooms()
        self.getSocialApps()

    }

    private func getChatrooms() {

        Env.gomaNetworkClient.requestChatrooms(deviceId: Env.deviceId, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.log("Share ticket chatrooms failure \(error)")
                case .finished:
                    Logger.log("Share ticket chatrooms finished")
                }

                self?.shouldReloadData.send()
            }, receiveValue: { [weak self] response in
                if let chatrooms = response.data {
                    self?.chatrooms.value = chatrooms
                }
            })
            .store(in: &cancellables)
    }

    private func getSocialApps() {
        let socialAppsInfo = Env.gomaSocialClient.socialAppsInfo

        // Verify if app is installed
        for (index, socialAppInfo) in socialAppsInfo.enumerated() {

            let appUrl = URL(string: socialAppInfo.urlScheme)

            if UIApplication.shared.canOpenURL(appUrl! as URL) {

                let socialApp = SocialApp(id: "\(index)",
                                          name: socialAppInfo.name,
                                          iconName: "\(socialAppInfo.name.lowercased())_icon",
                                          appScheme: socialAppInfo.urlScheme,
                                          urlShare: socialAppInfo.urlShare)

                self.socialApps.value.append(socialApp)

                print("\(socialAppInfo.urlScheme) detected")

            }
            else {
                print("\(socialAppInfo.urlScheme) not detected")
            }

        }

        self.shouldReloadData.send()
    }

    private func checkCopyLink() {
        if let betStatus = self.clickedShareTicketInfo?.betStatus {
            if betStatus == "OPEN" {
                self.canCopyLinkPublisher.send(true)
            }
            else {
                self.canCopyLinkPublisher.send(false)
            }
        }
    }

    private func checkSocialAppSharesAvailability() {
        if let betStatus = self.clickedShareTicketInfo?.betStatus {
            if betStatus == "OPEN" {
                self.canShareLinkSocialApps.send(true)
            }
            else {
                self.canShareLinkSocialApps.send(false)
            }
        }
    }

    func sendTicketMessage(chatroomData: ChatroomData) {

        guard
            let ticket = self.clickedShareTicketInfo?.ticket
        else {
            return
        }

        let betTokenRoute = TSRouter.getSharedBetTokens(betId: ticket.betId)

        Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    ()
                    //self?.isLoadingSharedBetPublisher.send(false)
                case .finished:
                    ()
                }
            },
            receiveValue: { [weak self] betToken in
                guard let self = self else { return }

                let defaultMessage = localized("check_this_bet_made")

                let attachment = self.generateAttachmentString(ticket: ticket,
                                                               withToken: betToken.sharedBetTokens.betTokenWithAllInfo)

                Env.gomaSocialClient.sendMessage(chatroomId: chatroomData.chatroom.id,
                                                 message: defaultMessage,
                                                 attachment: attachment)

                //self.isLoadingSharedBetPublisher.send(false)
                self.messageSentAction?()
            })
            .store(in: &cancellables)

    }

    func generateAttachmentString(ticket: BetHistoryEntry, withToken betShareToken: String) -> [String: AnyObject]? {

        guard let token = Env.gomaNetworkClient.getCurrentToken() else {
            return nil
        }

        let attachment = SharedBetTicketAttachment(id: ticket.betId,
                                                   type: "bet",
                                                   fromUser: "\(token.userId)",
                                                   content: SharedBetTicket(betHistoryEntry: ticket,
                                                                            betShareToken: betShareToken))

        if let jsonData = try? JSONEncoder().encode(attachment) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
            return dictionary
        }
        else {
            return nil
        }
    }
}

class ShareTicketChoiceViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var bottomShareView: UIView = Self.createBottomShareView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var chatCollectionView: UICollectionView = Self.createChatCollectionView()
    private lazy var generalOptionsView: UIView = Self.createGeneralOptionsView()
    private lazy var topSeparatorLineView: UIView = Self.createTopSeparatorLineView()
    private lazy var bottomSeparatorLineView: UIView = Self.createBottomSeparatorLineView()
    private lazy var copyLinkButton: UIButton = Self.createCopyLinkButton()
    private lazy var sendViaButton: UIButton = Self.createSendViaButton()
    private lazy var socialAppsCollectionView: UICollectionView = Self.createSocialAppsCollectionView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    var viewModel: ShareTicketChoiceViewModel
    let pasteboard = UIPasteboard.general

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
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

        self.socialAppsCollectionView.delegate = self
        self.socialAppsCollectionView.dataSource = self

        self.socialAppsCollectionView.register(SocialAppItemCollectionViewCell.self,
                                        forCellWithReuseIdentifier: SocialAppItemCollectionViewCell.identifier)

        self.copyLinkButton.addTarget(self, action: #selector(didTapCopyLinkButton), for: .primaryActionTriggered)

        self.sendViaButton.addTarget(self, action: #selector(didTapSendViaButton), for: .primaryActionTriggered)

        self.bind(toViewModel: self.viewModel)

        self.isLoading = false

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.bottomShareView.layer.cornerRadius = CornerRadius.view
        self.bottomShareView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bottomShareView.clipsToBounds = true

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

        self.generalOptionsView.backgroundColor = .clear

        self.topSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine

        self.copyLinkButton.setBackgroundColor(.clear, for: .normal)
        self.copyLinkButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.copyLinkButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.copyLinkButton.setTitleColor(UIColor.App.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        self.sendViaButton.setBackgroundColor(.clear, for: .normal)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.sendViaButton.setTitleColor(UIColor.App.buttonTextDisablePrimary.withAlphaComponent(0.7), for: .disabled)

        self.socialAppsCollectionView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.socialAppsCollectionView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: ShareTicketChoiceViewModel) {

        viewModel.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.chatCollectionView.reloadData()
                self?.socialAppsCollectionView.reloadData()
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

        viewModel.canCopyLinkPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.copyLinkButton.isEnabled = isEnabled
            })
            .store(in: &cancellables)

        viewModel.canShareLinkSocialApps
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEnabled in
                self?.socialAppsCollectionView.isUserInteractionEnabled = isEnabled
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

            self.present(shareTicketFriendGroupViewController, animated: true)
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

            if betStatus == "OPEN" {
                let betToken = self.viewModel.clickedShareTicketInfo?.betToken
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

        if collectionView == self.chatCollectionView {
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
        else {
            guard
                let cell = collectionView.dequeueCellType(SocialAppItemCollectionViewCell.self, indexPath: indexPath)
            else {
                fatalError()
            }

            if let socialApp = self.viewModel.socialApps.value[safe: indexPath.row] {

                let cellViewModel = SocialAppItemCellViewModel(socialApp: socialApp)

                cell.configure(withViewModel: cellViewModel)

                if let betStatus = self.viewModel.clickedShareTicketInfo?.betStatus {
                    if betStatus != "OPEN" {
                        cell.isItemDisabled = true
                    }
                    else {
                        cell.isItemDisabled = false
                    }
                }

                cell.shouldShowSocialShare = { [weak self] in
                    self?.showSocialShareScreen(socialApp: socialApp)
                }

            }

            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.socialAppsCollectionView {
            return self.viewModel.socialApps.value.count
        }
        else {
            if self.viewModel.chatrooms.value.count <= 4 {
                return self.viewModel.chatrooms.value.count
            }
            return 5

        }

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

        if collectionView == self.socialAppsCollectionView {
            let padding: CGFloat =  30
            let collectionViewWidth = collectionView.frame.size.width - padding
            let collectionViewHeight = collectionView.frame.size.height - 8
            return CGSize(width: collectionViewWidth/4, height: collectionViewHeight)
        }

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

    private static func createGeneralOptionsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCopyLinkButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("copy_link"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.setImage(UIImage(named: "link_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -2, left: -10, bottom: 0, right: 0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private static func createSendViaButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("send_via"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.setImage(UIImage(named: "send_via_icon"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -8, left: -10, bottom: 0, right: 0)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private static func createSocialAppsCollectionView() -> UICollectionView {
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

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomShareView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.bottomShareView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.cancelButton)

        self.bottomShareView.addSubview(self.chatCollectionView)

        self.bottomShareView.addSubview(self.generalOptionsView)

        self.generalOptionsView.addSubview(self.topSeparatorLineView)
        self.generalOptionsView.addSubview(self.copyLinkButton)
        self.generalOptionsView.addSubview(self.sendViaButton)
        self.generalOptionsView.addSubview(self.bottomSeparatorLineView)

        self.bottomShareView.addSubview(self.socialAppsCollectionView)

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

            self.chatCollectionView.heightAnchor.constraint(equalToConstant: 105),

            self.chatCollectionView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 15),
            self.chatCollectionView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -15),
            self.chatCollectionView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 2)
        ])

        // General options view
        NSLayoutConstraint.activate([
            self.generalOptionsView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 18),
            self.generalOptionsView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -18),
            self.generalOptionsView.topAnchor.constraint(equalTo: self.chatCollectionView.bottomAnchor),
            self.generalOptionsView.heightAnchor.constraint(equalToConstant: 64),

            self.topSeparatorLineView.leadingAnchor.constraint(equalTo: self.generalOptionsView.leadingAnchor),
            self.topSeparatorLineView.trailingAnchor.constraint(equalTo: self.generalOptionsView.trailingAnchor),
            self.topSeparatorLineView.topAnchor.constraint(equalTo: self.generalOptionsView.topAnchor),
            self.topSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.bottomSeparatorLineView.leadingAnchor.constraint(equalTo: self.generalOptionsView.leadingAnchor),
            self.bottomSeparatorLineView.trailingAnchor.constraint(equalTo: self.generalOptionsView.trailingAnchor),
            self.bottomSeparatorLineView.bottomAnchor.constraint(equalTo: self.generalOptionsView.bottomAnchor),
            self.bottomSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.copyLinkButton.leadingAnchor.constraint(equalTo: self.generalOptionsView.leadingAnchor, constant: 20),
            self.copyLinkButton.heightAnchor.constraint(equalToConstant: 40),
            self.copyLinkButton.centerYAnchor.constraint(equalTo: self.generalOptionsView.centerYAnchor),

            self.sendViaButton.trailingAnchor.constraint(equalTo: self.generalOptionsView.trailingAnchor, constant: -20),
            self.sendViaButton.heightAnchor.constraint(equalToConstant: 40),
            self.sendViaButton.centerYAnchor.constraint(equalTo: self.generalOptionsView.centerYAnchor),

        ])

        // Social Apps collection view
        NSLayoutConstraint.activate([

            self.socialAppsCollectionView.heightAnchor.constraint(equalToConstant: 105),

            self.socialAppsCollectionView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 15),
            self.socialAppsCollectionView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: -15),
            self.socialAppsCollectionView.topAnchor.constraint(equalTo: self.generalOptionsView.bottomAnchor, constant: 2),
            self.socialAppsCollectionView.bottomAnchor.constraint(equalTo: self.bottomShareView.bottomAnchor)
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
