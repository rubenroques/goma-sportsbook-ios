//
//  PromotionsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 11/03/2025.
//

import UIKit
import Combine

class PromotionsViewModel {
    
    var promotions: [PromotionInfo] = []
    var promotionsCacheCellViewModel: [Int: PromotionCellViewModel] = [:]
    
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    
    init() {
        self.getPromotions()
    }
    
    private func getPromotions() {
        
        self.isLoadingPublisher.send(true)
        
        // Mock promotions
//        let promotions: [PromotionInfo] = [
//            PromotionInfo(
//                id: "1",
//                title: "Super Bonus Offer",
//                background: "bonus_background",
//                date: "2025-03-11",
//                description: "Get a 50% bonus on your first deposit up to $200!",
//                headerTitle: "Exclusive Bonus!",
//                headerImage: nil // Since headerTitle is set, headerImage must be nil
//            ),
//            PromotionInfo(
//                id: "2",
//                title: "Weekend Special",
//                background: "weekend_special_bg",
//                date: "2025-03-15",
//                description: "Exclusive weekend offer! Bet $20 and get a free $10 bet.",
//                headerTitle: nil, // Since headerImage is set, headerTitle must be nil
//                headerImage: "header_weekend"
//            ),
//            PromotionInfo(
//                id: "3",
//                title: "VIP Exclusive Deal",
//                background: "vip_deal_bg",
//                date: "2025-03-20",
//                description: "VIP members get double rewards points for all bets placed today!",
//                headerTitle: "VIP Rewards",
//                headerImage: nil
//            ),
//            PromotionInfo(
//                id: "4",
//                title: "Limited Time Free Bet",
//                background: "free_bet_bg",
//                date: "2025-03-25",
//                description: "Sign up now and receive a free $5 bet – no deposit required!",
//                headerTitle: nil,
//                headerImage: "header_free_bet"
//            )
//        ]
        let promotions: [PromotionInfo] = [
                PromotionInfo(
                    id: 3,
                    title: "promo 2",
                    slug: "promo-2",
                    sortOrder: 1,
                    platform: "all",
                    status: "published",
                    userType: "all",
                    listDisplayNote: "Note 123",
                    listDisplayDescription: "Description 123",
                    listDisplayImageUrl: "https://cms.gomademo.com/storage/198/01JPA2GABR9BWFGBB9XNSASZRN.png",
                    startDate: "2025-03-14T10:16:00.000000Z",
                    endDate: "2026-03-14T10:16:00.000000Z",
                    staticPage: StaticPage(
                        title: "Static Page 2",
                        slug: "static-page-2",
                        headerTitle: "Promo 1",
                        headerImageUrl: "https://cms.gomademo.com/storage/200/01JPAG0DJ9VM8HJ0NV8568B08X.png",
                        isActive: true,
                        usedForPromotions: true,
                        platform: "all",
                        status: "published",
                        userType: "all",
                        startDate: "2025-03-10T20:12:00.000000Z",
                        endDate: "2026-03-10T20:12:00.000000Z",
                        sections: [
                            SectionBlock(
                                type: "banner",
                                sortOrder: 1,
                                isActive: true,
                                banner: BannerBlock(
                                    bannerLinkUrl: nil,
                                    bannerType: "image",
                                    bannerLinkTarget: "_blank",
                                    imageUrl: "https://cms.gomademo.com/storage/192/01JPA2DH3NTDVR6DPN5S0MHYY3.png"),
                                text: nil,
                                list: nil),
                            SectionBlock(
                                type: "text",
                                sortOrder: 2,
                                isActive: true,
                                banner: nil,
                                text: TextBlock(
                                    sectionHighlighted: true,
                                    contentBlocks: [
                                        TextContentBlock(
                                            title: "Text Section Title Text 1",
                                            blockType: "title",
                                            description: nil,
                                            image: nil,
                                            video: nil,
                                            buttonURL: nil,
                                            buttonText: nil,
                                            buttonTarget: nil,
                                            bulletedListItems: nil
                                        ),
                                        TextContentBlock(
                                            title: nil,
                                            blockType: "description",
                                            description: "Text Section Title Description 1",
                                            image: nil,
                                            video: nil,
                                            buttonURL: nil,
                                            buttonText: nil,
                                            buttonTarget: nil,
                                            bulletedListItems: nil
                                        ),
                                        TextContentBlock(
                                            title: nil,
                                            blockType: "image",
                                            description: nil,
                                            image: "https://cms.gomademo.com/storage/193/01JPA2DHFVRMXKRMY4MNA69PHN.png",
                                            video: nil,
                                            buttonURL: nil,
                                            buttonText: nil,
                                            buttonTarget: nil,
                                            bulletedListItems: nil
                                        ),
                                        TextContentBlock(
                                            title: nil,
                                            blockType: "video",
                                            description: nil,
                                            image: nil,
                                            video: "https://cms.gomademo.com/storage/194/01JPA2DHGXC8GRN78XEYDVAJ07.mp4",
                                            buttonURL: nil,
                                            buttonText: nil,
                                            buttonTarget: nil,
                                            bulletedListItems: nil
                                        ),
                                        TextContentBlock(
                                            title: nil,
                                            blockType: "button",
                                            description: nil,
                                            image: nil,
                                            video: nil,
                                            buttonURL: "https://www.google.com",
                                            buttonText: "Button 1",
                                            buttonTarget: "_blank",
                                            bulletedListItems: nil
                                        ),
                                        TextContentBlock(
                                            title: nil,
                                            blockType: "bulleted_list",
                                            description: nil,
                                            image: nil,
                                            video: nil,
                                            buttonURL: nil,
                                            buttonText: nil,
                                            buttonTarget: nil,
                                            bulletedListItems: [
                                                BulletedListItem(text: "Text Section - Bullet List item 1"),
                                                BulletedListItem(text: "Text Section - Bullet List item 2"),
                                                BulletedListItem(text: "Text Section - Bullet List item 3")
                                            ]
                                        )
                                    ],
                                    itemIcon: nil
                                ),
                                list: nil
                            ),
                            SectionBlock(
                                type: "list",
                                sortOrder: 3,
                                isActive: true,
                                banner: nil,
                                text: nil,
                                list: ListBlock(
                                    title: "List Section Title 1",
                                    genericListItemsIcon: "https://cms.gomademo.com/storage/195/01JPA2DHW9XHNASQ93Y8650C7F.png",
                                    items: [
                                        TextBlock(
                                            sectionHighlighted: false, contentBlocks: [
                                                TextContentBlock(title: "List Section - Item 1 - Title 1", blockType: "title", description: nil, image: nil, video: nil, buttonURL: nil, buttonText: nil, buttonTarget: nil, bulletedListItems: nil),
                                                TextContentBlock(title: nil, blockType: "description", description: "List Section - Item 1 - Title 1", image: nil, video: nil, buttonURL: nil, buttonText: nil, buttonTarget: nil, bulletedListItems: nil),
                                                TextContentBlock(title: nil, blockType: "image", description: nil, image: "https://cms.gomademo.com/storage/196/01JPA2DJ2J8PWJ9W7WE059Y5H5.png", video: nil, buttonURL: nil, buttonText: nil, buttonTarget: nil, bulletedListItems: nil),
                                                TextContentBlock(title: nil, blockType: "video", description: nil, image: nil, video: "https://cms.gomademo.com/storage/197/01JPA2DJ3KAKRSR82M0QJBDKMG.mp4", buttonURL: nil, buttonText: nil, buttonTarget: nil, bulletedListItems: nil),
                                                TextContentBlock(title: nil, blockType: "button", description: nil, image: nil, video: nil, buttonURL: "https://www.google.com", buttonText: "List Section - Item 1 - Button 1", buttonTarget: "_blank", bulletedListItems: nil),
                                                TextContentBlock(title: nil, blockType: "bulleted_list", description: nil, image: nil, video: nil, buttonURL: nil, buttonText: nil, buttonTarget: nil, bulletedListItems: [
                                                    BulletedListItem(text: "List Section - Item 1 - Bullet list"),
                                                    BulletedListItem(text: "List Section - Item 1 - Bullet list"),
                                                    BulletedListItem(text: "List Section - Item 1 - Bullet list")
                                                ])
                                            ],
                                        itemIcon: nil
                                        )
                                    ]
                                )
                            )
                        ],
                        terms: [
                            TermItem(label: "term 1", sortOrder: 1),
                            TermItem(label: "term 2", sortOrder: 2),
                            TermItem(label: "term 3", sortOrder: 3),
                            TermItem(label: "term 4", sortOrder: 4)
                        ]
                    )
                )
            ]
        
        self.promotions = promotions
        
        self.isLoadingPublisher.send(false)
    }
    
    func viewModel(forIndex index: Int) -> PromotionCellViewModel? {
        guard
            let promotion = self.promotions[safe: index]
        else {
            return nil
        }

        if let promotionCellViewModel = self.promotionsCacheCellViewModel[promotion.id] {
            return promotionCellViewModel
        }
        else {
            
            let promotionCellViewModel = PromotionCellViewModel(promotionInfo: promotion)
            self.promotionsCacheCellViewModel[promotion.id] = promotionCellViewModel
            return promotionCellViewModel
        }
    }
}

class PromotionsViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    
    private var viewModel: PromotionsViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(viewModel: PromotionsViewModel) {

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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(PromotionTableViewCell.self, forCellReuseIdentifier: PromotionTableViewCell.identifier)
        
        self.bind(toViewModel: self.viewModel)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isRootModal {
            self.backButton.setImage(UIImage(named: "arrow_close_icon"), for: .normal)
        }
        
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.tableView.backgroundColor = .clear
        
        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray

    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: PromotionsViewModel) {
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                
                if isLoading {
                    self?.showLoading()
                }
                else {
                    self?.hideLoading()
                    self?.tableView.reloadData()
                }
            })
            .store(in: &cancellables)
    }

    
    // MARK: Functions
    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }
    
    private func openPromotionDetail(promotion: PromotionInfo) {
        
        let promotionDetailViewModel = PromotionDetailViewModel(promotion: promotion)
        
        let promotionDetailViewController = PromotionDetailViewController(viewModel: promotionDetailViewModel)
        
        self.navigationController?.pushViewController(promotionDetailViewController, animated: true)
    }
    
    // MARK: Actions
    @objc private func didTapBackButton() {
        
        if self.isRootModal {
            self.presentingViewController?.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PromotionsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.promotions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: PromotionTableViewCell.identifier, for: indexPath) as? PromotionTableViewCell,
            let cellViewModel = self.viewModel.viewModel(forIndex: indexPath.row)
        else {
            fatalError("TipsTableViewCell not found")
        }
        
        cell.configure(viewModel: cellViewModel)
        
        cell.didTapPromotionAction = { [weak self] in
            self?.openPromotionDetail(promotion: cellViewModel.promotionInfo)
        }
        
        return cell
        
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
}

extension PromotionsViewController {

    private static func createTopSafeAreaView() -> UIView {
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
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .center
        titleLabel.text = localized("promotions")
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }
    
    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.allowsSelection = false
        return tableView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        
        self.view.addSubview(self.tableView)

        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 46),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 44),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),
            
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.navigationView.bottomAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
