//
//  ShareTicketChoiceViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2022.
//

import UIKit
import Combine

class ShareTicketChoiceViewModel {

    var chatrooms: CurrentValueSubject<[ChatroomData], Never> = .init([])
    var shouldReloadData: PassthroughSubject<Void, Never> = .init()

    private var cancellables = Set<AnyCancellable>()

    init() {

        self.getChatrooms()
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

    private var cancellables = Set<AnyCancellable>()

    var viewModel: ShareTicketChoiceViewModel

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

    }

    override func viewDidAppear(_ animated: Bool) {

        self.chatCollectionView.reloadData()
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
    }

    // MARK: Binding

    private func bind(toViewModel viewModel: ShareTicketChoiceViewModel) {

        viewModel.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.chatCollectionView.reloadData()
            })
            .store(in: &cancellables)

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

        if let chatroomData = self.viewModel.chatrooms.value[safe: indexPath.row] {

            let cellViewModel = SocialItemCellViewModel(chatroom: chatroomData.chatroom)

            cell.configure(withViewModel: cellViewModel)

        }

//        cell.configureCell(viewModel: viewModel)
//
//        if cell.viewModel?.sport.id == self.defaultSport.id {
//            cell.isSelected = true
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
//        }
//        if isLiveSport {
//            cell.viewModel?.setSportPublisher(sportsRepository: self.sportsRepository)
//        }
//        return cell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.chatrooms.value.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let chatroom = self.viewModel.chatrooms.value[safe: indexPath.row]

        print("CHATROOM: \(chatroom)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  8
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

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.bottomShareView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.bottomShareView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.titleLabel)
        self.navigationView.addSubview(self.cancelButton)

        self.bottomShareView.addSubview(self.chatCollectionView)

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
            self.bottomShareView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.bottomShareView.heightAnchor.constraint(equalToConstant: 381)
        ])

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.bottomShareView.topAnchor),
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

            self.chatCollectionView.leadingAnchor.constraint(equalTo: self.bottomShareView.leadingAnchor, constant: 0),
            self.chatCollectionView.trailingAnchor.constraint(equalTo: self.bottomShareView.trailingAnchor, constant: 0),
            self.chatCollectionView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 2)
        ])
    }
}
