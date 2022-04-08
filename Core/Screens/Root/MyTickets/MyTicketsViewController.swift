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

    @IBOutlet private weak var ticketsTableView: UITableView!

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

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
            }
        }
    }

    init(viewModel: MyTicketsViewModel = MyTicketsViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: "MyTicketsViewController", bundle: nil)

        self.title = localized("my_bets")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("MyTicketsViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.noBetsButton.isHidden = true

        self.emptyBaseView.isHidden = true

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

        self.viewModel.requestShareActivityView = { [weak self] image, betId, betStatus in
            self?.isLoading = true
            self?.viewModel.clickedCellSnapshot = image
            self?.viewModel.clickedBetId = betId
            self?.viewModel.clickedBetStatus = betStatus
            self?.viewModel.getSharedBetTokens()
        }

        self.viewModel.tappedMatchDetail = { [weak self] matchId in
           
            let matchViewModel = MatchDetailsViewModel(matchId: matchId)
           
            let matchDetailsViewController = MatchDetailsViewController(viewModel: matchViewModel)
            self?.navigationController?.pushViewController(matchDetailsViewController, animated: true)
            
        }
        
        Env.betslipManager.newBetsPlacedPublisher
            .sink { [weak self] in
                self?.viewModel.refresh()
            }
            .store(in: &cancellables)

        self.viewModel.clickedBetTokenPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] token in
                if token != "" {
                    self?.shareBet()
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)

        self.isLoading = false

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
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.ticketsTableView.backgroundColor = UIColor.App.backgroundPrimary
        self.ticketsTableView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.emptyBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.firstTextFieldLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldLabel.textColor = UIColor.App.textPrimary
        
        self.noBetsButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        StyleHelper.styleButton(button: self.noBetsButton)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

    }

    @objc func refresh() {
        self.shouldShowCenterLoadingView = false
        self.viewModel.refresh()
    }
    
      private func shareBet() {

          let metadata = LPLinkMetadata()
          let urlMobile = Env.urlMobileShares

          if let gameSnapshot = self.viewModel.clickedCellSnapshot, let betStatus = self.viewModel.clickedBetStatus {

              if betStatus == "OPEN" {
                  let betToken = self.viewModel.clickedBetTokenPublisher.value
                  let matchUrl = URL(string: "\(urlMobile)/bet/\(betToken)")
                  metadata.url = matchUrl
                  metadata.originalURL = metadata.url
              }

              let imageProvider = NSItemProvider(object: gameSnapshot)
              metadata.imageProvider = imageProvider
              metadata.title = localized("look_bet_made")
          }

          let metadataItemSource = LinkPresentationItemSource(metaData: metadata)

          if let betStatus = self.viewModel.clickedBetStatus, betStatus == "OPEN" {
              let share = UIActivityViewController(activityItems: [metadataItemSource, self.viewModel.clickedCellSnapshot], applicationActivities: nil)
              present(share, animated: true, completion: nil)
          }
          else {
              let share = UIActivityViewController(activityItems: [self.viewModel.clickedCellSnapshot], applicationActivities: nil)
              present(share, animated: true, completion: nil)
          }

          self.isLoading = false
    }
//
//    @IBAction private func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {
//
//        switch segmentControl.selectedSegmentIndex {
//        case 0:
//            self.viewModel.setMyTicketsType(.opened)
//        case 1:
//            self.viewModel.setMyTicketsType(.resolved)
//        case 2:
//            self.viewModel.setMyTicketsType(.won)
//        default:
//            ()
//        }
//
//    }

}

extension MyTicketsViewController {
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
}
