//
//  MyTicketsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/12/2021.
//

import UIKit
import Combine
import LinkPresentation

class MyTicketsViewController: UIViewController {

    @IBOutlet private var ticketTypesCollectionView: UICollectionView!
    @IBOutlet private var ticketTypesSeparatorLineView: UIView!
    @IBOutlet private var ticketsTableView: UITableView!

    @IBOutlet private weak var emptyBaseView: UIView!
    @IBOutlet private weak var firstTextFieldLabel: UILabel!
    @IBOutlet private weak var secondTextFieldLabel: UILabel!
    @IBOutlet private weak var noBetsButton: UIButton!
    @IBOutlet private weak var noBetsImage: UIImageView!

    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView!

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    private let refreshControl = UIRefreshControl()
    private var shouldShowCenterLoadingView = true
    private var viewModel: MyTicketsViewModel

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.viewModel = MyTicketsViewModel()
        
        super.init(nibName: "MyTicketsViewController", bundle: nil)

        self.title = localized("my_bets")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingBaseView.isHidden = true
        self.emptyBaseView.isHidden = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.ticketTypesCollectionView.collectionViewLayout = flowLayout
        self.ticketTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.ticketTypesCollectionView.showsVerticalScrollIndicator = false
        self.ticketTypesCollectionView.showsHorizontalScrollIndicator = false
        self.ticketTypesCollectionView.alwaysBounceHorizontal = true
        self.ticketTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.ticketTypesCollectionView.delegate = self
        self.ticketTypesCollectionView.dataSource = self

        //
        //
        self.ticketsTableView.delegate = self.viewModel
        self.ticketsTableView.dataSource = self.viewModel
        self.ticketsTableView.register(MyTicketTableViewCell.nib, forCellReuseIdentifier: MyTicketTableViewCell.identifier)
        self.ticketsTableView.separatorStyle = .none

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.ticketsTableView.addSubview(self.refreshControl)

        self.view.bringSubviewToFront(self.loadingBaseView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if !isLoading {
                    self?.loadingIndicatorView.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    self?.shouldShowCenterLoadingView = true
                }
                else if self?.shouldShowCenterLoadingView ?? false {
                    self?.loadingIndicatorView.startAnimating()
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(Env.userSessionStore.userSessionPublisher, self.viewModel.isTicketsEmptyPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userSession, isTicketsEmpty in

                if userSession == nil {
                    self?.emptyBaseView.isHidden = false
                    self?.firstTextFieldLabel.text = localized("empty_no_login")
                    self?.secondTextFieldLabel.text = localized("second_empty_no_login")
                    self?.noBetsButton.setTitle(localized("login"), for: .normal)
                    self?.noBetsButton.isHidden = false
                    self?.noBetsImage.image = UIImage(named: "no_internet_icon")
                }
                else {
                    self?.emptyBaseView.isHidden = !isTicketsEmpty
                }
            })
            .store(in: &cancellables)

        self.viewModel.reloadTableViewAction = { [weak self] in
            self?.ticketsTableView.reloadData()
        }

        self.viewModel.redrawTableViewAction = { [weak self] in
            self?.ticketsTableView.beginUpdates()
            self?.ticketsTableView.endUpdates()
        }

        self.viewModel.requestShareActivityView = { [weak self] image, betId in
            self?.viewModel.clickedCellSnapshot = image
            self?.viewModel.clickedBetId = betId
            self?.shareBet()
        }

        Env.betslipManager.newBetsPlacedPublisher
            .sink { [weak self] in
                self?.viewModel.refresh()
            }
            .store(in: &cancellables)

        self.setupWithTheme()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
   }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        self.ticketTypesCollectionView.backgroundColor = UIColor.App.mainBackground

        self.ticketTypesSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.ticketTypesSeparatorLineView.alpha = 0.5

        self.ticketsTableView.backgroundColor = UIColor.App.contentBackground
        self.ticketsTableView.backgroundView?.backgroundColor = UIColor.App.contentBackground

        self.emptyBaseView.backgroundColor = UIColor.App.mainBackground
        self.firstTextFieldLabel.textColor = UIColor.App.headingMain
        self.secondTextFieldLabel.textColor = UIColor.App.headingMain

    }

    @objc func refresh() {
        self.shouldShowCenterLoadingView = false
        self.viewModel.refresh()
    }

    private func shareBet() {
        let share = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }

}

extension MyTicketsViewController {
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
}

extension MyTicketsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
        case MyTicketsViewModel.MyTicketsType.opened.rawValue :
            cell.setupWithTitle(localized("opened"))
        case MyTicketsViewModel.MyTicketsType.resolved.rawValue:
            cell.setupWithTitle(localized("resolved"))
        case MyTicketsViewModel.MyTicketsType.won.rawValue:
            cell.setupWithTitle(localized("won"))
        default:
            ()
        }

        if self.viewModel.isTicketsTypeSelected(forIndex: indexPath.row) {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.row {
        case MyTicketsViewModel.MyTicketsType.opened.rawValue:
            self.viewModel.setMyTicketsType(.opened)
        case MyTicketsViewModel.MyTicketsType.resolved.rawValue:
            self.viewModel.setMyTicketsType(.resolved)
        case MyTicketsViewModel.MyTicketsType.won.rawValue:
            self.viewModel.setMyTicketsType(.won)
        default:
            ()
        }

        self.ticketTypesCollectionView.reloadData()
        
        self.ticketTypesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

extension MyTicketsViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()

        if let gameSnapshot = self.viewModel.clickedCellSnapshot,
            let betId = self.viewModel.clickedBetId,
            let matchUrl = URL(string: "https://sportsbook.gomagaming.com/mobile/bet/\(betId)") {

            let imageProvider = NSItemProvider(object: gameSnapshot)
            metadata.imageProvider = imageProvider
            metadata.url = matchUrl
            metadata.originalURL = metadata.url
            metadata.title = localized("look_bet_made")
        }

        return metadata

    }
}
