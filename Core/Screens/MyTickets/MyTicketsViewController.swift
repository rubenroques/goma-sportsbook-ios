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
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    private let refreshControl = UIRefreshControl()
    private var shouldShowCenterLoadingView = false
    private var viewModel: MyTicketsViewModel

    private var cancellables = Set<AnyCancellable>()

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingSpinnerViewController.startAnimating()
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingSpinnerViewController.stopAnimating()
            }
        }
    }

    var reloadAllMyTickets: (() -> Void)?

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
        print("MyTicketsViewController.deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.noBetsButton.isHidden = true

        self.emptyBaseView.isHidden = true

        self.ticketsTableView.delegate = self.viewModel
        self.ticketsTableView.dataSource = self.viewModel
        self.ticketsTableView.register(MyTicketTableViewCell.nib, forCellReuseIdentifier: MyTicketTableViewCell.identifier)
        self.ticketsTableView.register(LoadingMoreTableViewCell.nib, forCellReuseIdentifier: LoadingMoreTableViewCell.identifier)
        self.ticketsTableView.separatorStyle = .none

        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.ticketsTableView.addSubview(self.refreshControl)

        self.firstTextFieldLabel.text = localized("no_tickets_here")
        self.secondTextFieldLabel.text = localized("second_empty_no_bets")

        self.loadingView.alpha = 0.0
        self.loadingView.stopAnimating()
        self.loadingBaseView.isHidden = true
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        self.view.bringSubviewToFront(self.loadingBaseView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.viewModel.isLoadingTickets
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if !isLoading {
                    self?.loadingIndicatorView.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    self?.shouldShowCenterLoadingView = false
                }
                else if self?.shouldShowCenterLoadingView ?? false {
                    self?.loadingIndicatorView.startAnimating()
                }
            })
            .store(in: &cancellables)
        
        self.viewModel.listStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] listStatePublisher in

                switch listStatePublisher {
                case .loading:
                    self?.isLoading = true
                    self?.emptyBaseView.isHidden = true
                case .empty:
                    self?.isLoading = false
                    self?.emptyBaseView.isHidden = false
                case .noUserFoundError:
                    self?.isLoading = false
                    self?.emptyBaseView.isHidden = false
                case .serverError:
                    self?.isLoading = false
                    self?.emptyBaseView.isHidden = false
                case .loaded:
                    self?.isLoading = false
                    self?.emptyBaseView.isHidden = true
                   
                    self?.ticketsTableView.reloadData()
                }
            })
            .store(in: &self.cancellables)

        Publishers.CombineLatest(Env.userSessionStore.userProfilePublisher, self.viewModel.isTicketsEmptyPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfile, isTicketsEmpty in

                if userProfile == nil {
                    self?.emptyBaseView.isHidden = false
                    self?.firstTextFieldLabel.text = localized("not_logged_in")
                    self?.secondTextFieldLabel.text = localized("need_login_tickets")
                    self?.noBetsButton.setTitle(localized("login"), for: .normal)
                    self?.noBetsButton.isHidden = false
                    self?.noBetsImage.image = UIImage(named: "my_tickets_logged_off_icon")
                }
                else {
                    self?.emptyBaseView.isHidden = !isTicketsEmpty
                    self?.firstTextFieldLabel.text = localized("no_tickets_here")
                    self?.secondTextFieldLabel.text = localized("second_empty_no_bets")
                    self?.noBetsImage.image = UIImage(named: "my_tickets_empty_icon")
                }

            })
            .store(in: &cancellables)

        self.viewModel.reloadTableViewAction = { [weak self] in
            print("RELOAD TICKET TABLE!")
            self?.ticketsTableView.reloadData()
        }

        self.viewModel.redrawTableViewAction = { [weak self] withScroll in
//            // Use CATransaction to detect animation from table updates
//            CATransaction.begin()
//
//            CATransaction.setCompletionBlock({
//                if withScroll {
//                    self?.scrollDown()
//                }
//            })
//
//            self?.ticketsTableView.beginUpdates()
//            self?.ticketsTableView.endUpdates()
//
//      <      CATransaction.commit()
            print("REDRAW TICKET CELL UNUSED!")

            self?.ticketsTableView.beginUpdates()
            self?.ticketsTableView.endUpdates()

        }

        self.viewModel.updateCellAtIndexPath = { [weak self] cellIndexPath in
//            self?.ticketsTableView.reloadRows(at: [cellIndexPath], with: .automatic)
            print("REDRAW TICKET CELL!")
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

        self.viewModel.clickedBetTokenPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] token in
                if token != "" {
                    self?.shareBet()
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)

        self.viewModel.requestAlertAction = { [weak self] cashoutReoffer, betId in

            self?.showCashoutAlert(cashoutReoffer: cashoutReoffer, betId: betId)
        }

        self.viewModel.requestPartialAlertAction = { [weak self] cashoutReoffer, betId in

            self?.showCashoutAlert(cashoutReoffer: cashoutReoffer, betId: betId)
        }

        self.viewModel.showCashoutSuspendedAction = { [weak self] in
            self?.showSimpleAlert(title: localized("cashout_error"), message: localized("cashout_no_longer_available"))
        }

        self.viewModel.showCashoutState = { [weak self] alertType, text in
            self?.reloadAllMyTickets?()
            self?.showCashoutState(alertType: alertType, text: text)
        }

        self.viewModel.shouldShowCashbackInfo = { [weak self] in
            self?.showCashbackInfo()
        }

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
        self.shouldShowCenterLoadingView = true
        self.viewModel.refresh()
    }
    
    private func shareBet() {

        //          let metadata = LPLinkMetadata()
        //          let urlMobile = TargetVariables.clientBaseUrl
        //
        //          if let gameSnapshot = self.viewModel.clickedCellSnapshot, let betStatus = self.viewModel.clickedBetStatus {
        //
        //              if betStatus == "OPEN" {
        //                  let betToken = self.viewModel.clickedBetTokenPublisher.value
        //                  let matchUrl = URL(string: "\(urlMobile)/bet/\(betToken)")
        //                  metadata.url = matchUrl
        //                  metadata.originalURL = metadata.url
        //              }
        //
        //              let imageProvider = NSItemProvider(object: gameSnapshot)
        //              metadata.imageProvider = imageProvider
        //              metadata.title = localized("look_bet_made")
        //          }
        //
        //          let metadataItemSource = LinkPresentationItemSource(metaData: metadata)
        //
        //          if let betStatus = self.viewModel.clickedBetStatus, betStatus == "OPEN" {
        //              let shareActivityViewController = UIActivityViewController(activityItems: [metadataItemSource, self.viewModel.clickedCellSnapshot],
        //                                                   applicationActivities: nil)
        //              if let popoverController = shareActivityViewController.popoverPresentationController {
        //                  popoverController.sourceView = self.view
        //                  popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        //                  popoverController.permittedArrowDirections = []
        //              }
        //              self.present(shareActivityViewController, animated: true, completion: nil)
        //          }
        //          else {
        //              let shareActivityViewController = UIActivityViewController(activityItems: [self.viewModel.clickedCellSnapshot],
        //                                                   applicationActivities: nil)
        //              if let popoverController = shareActivityViewController.popoverPresentationController {
        //                  popoverController.sourceView = self.view
        //                  popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        //                  popoverController.permittedArrowDirections = []
        //              }
        //              self.present(shareActivityViewController, animated: true, completion: nil)
        //          }
        let clickedShareTicketInfo = ClickedShareTicketInfo(snapshot: self.viewModel.clickedCellSnapshot,
                                                            betId: self.viewModel.clickedBetId,
                                                            betStatus: self.viewModel.clickedBetStatus,
                                                            betToken: self.viewModel.clickedBetTokenPublisher.value,
                                                            ticket: self.viewModel.clickedBetHistory)

        let shareTicketChoiceViewModel = ShareTicketChoiceViewModel(clickedShareTicketInfo: clickedShareTicketInfo)

        let shareTicketChoiceViewController = ShareTicketChoiceViewController(viewModel: shareTicketChoiceViewModel)

        self.present(shareTicketChoiceViewController, animated: true, completion: nil)

    }

    private func showCashoutAlert(cashoutReoffer: String, betId: String) {

        let message = localized("cashout_reoffer_warning_text").replacingFirstOccurrence(of: "{cashoutReofferValue}", with: cashoutReoffer)
            .replacingFirstOccurrence(of: "{currencySymbol}", with: "\(Env.userSessionStore.userProfilePublisher.value?.currency ?? "€")")

        let alert = UIAlertController(title: localized("cashout_reoffer_warning_title"),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            if let cellViewModel = self?.viewModel.cachedViewModels[betId] {
                cellViewModel.requestPartialCashout()
            }
        }))

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }

//    private func showPartialCashoutAlert(cashoutReoffer: String, betId: String) {
//
//        let message = localized("cashout_reoffer_warning_text").replacingFirstOccurrence(of: "{cashoutReofferValue}", with: cashoutReoffer)
//            .replacingFirstOccurrence(of: "{currencySymbol}", with: "€")
//
//        let alert = UIAlertController(title: localized("cashout_reoffer_warning_title"),
//                                      message: message,
//                                      preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
//
//            if let cellViewModel = self?.viewModel.cachedViewModels[betId] {
//                cellViewModel.requestPartialCashout()
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//
//    }

    private func showCashoutState(alertType: AlertType, text: String) {

        let alertView = GenericAlertView()

        alertView.configure(alertType: alertType, text: text)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            alertView.alpha = 1
        }, completion: { _ in
        })

        alertView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(alertView)

        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            alertView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                alertView.alpha = 0
            }, completion: { _ in
                alertView.removeFromSuperview()
            })
        }

        self.view.bringSubviewToFront(alertView)

    }

    private func showCashbackInfo() {

        let cashbackInfoViewController = CashbackInfoViewController()

        self.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
    }

    private func scrollDown() {

        let scrollPosition = self.ticketsTableView.contentOffset.y

        let bottomOffset = self.ticketsTableView.contentSize.height - self.ticketsTableView.bounds.size.height

        var newScrollPosition = scrollPosition + 120

        if newScrollPosition > bottomOffset {
            newScrollPosition = bottomOffset
        }

        let scrollPoint = CGPoint(x: 0, y: newScrollPosition)

        self.ticketsTableView.setContentOffset(scrollPoint, animated: true)
    }

}

extension MyTicketsViewController {
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
}
