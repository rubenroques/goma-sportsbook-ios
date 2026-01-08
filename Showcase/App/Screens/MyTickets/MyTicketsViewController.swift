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
    
    private lazy var shareLoadingOverlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true
        return overlayView
    }()
    
    private lazy var shareLoadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
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
        // print("MyTicketsViewController.deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup fonts
        self.firstTextFieldLabel.font = AppFont.with(type: .heavy, size: 20)
        self.secondTextFieldLabel.font = AppFont.with(type: .heavy, size: 14)
        
        self.noBetsButton.isHidden = true
        self.emptyBaseView.isHidden = true
        
        self.ticketsTableView.delegate = self.viewModel
        self.ticketsTableView.dataSource = self.viewModel
        self.ticketsTableView.register(MyTicketTableViewCell.self, forCellReuseIdentifier: MyTicketTableViewCell.identifier)
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
            print("REDRAW TICKET CELL UNUSED!")
            
            self?.ticketsTableView.beginUpdates()
            self?.ticketsTableView.endUpdates()
            
        }
        
        self.viewModel.updateCellAtIndexPath = { [weak self] cellIndexPath in
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
//            self?.reloadAllMyTickets?()
            self?.showCashoutState(alertType: alertType, text: text)
        }
        
        self.viewModel.shouldShowCashbackInfo = { [weak self] in
            self?.showCashbackInfo()
        }
        
        self.isLoading = false
        
        // Setup share loading overlay
        self.setupShareLoadingOverlay()
        
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
        guard let betHistoryEntry = self.viewModel.clickedBetHistory else { return }
        
        self.showShareLoadingOverlay()
        
        let brandedShareView = BrandedTicketShareView()
        self.view.insertSubview(brandedShareView, at: 0)
        
        NSLayoutConstraint.activate([
            brandedShareView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -10),
            brandedShareView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            brandedShareView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        
        // Configure with bet data
        let viewModel = MyTicketCellViewModel(ticket: betHistoryEntry, allowedCashback: false)
        brandedShareView.configure(withBetHistoryEntry: betHistoryEntry,
                                   countryCodes: [],
                                   viewModel: viewModel,
                                   grantedWinBoost: nil,
                                   betShareToken: "\(betHistoryEntry.betslipId ?? 0)")
        
        brandedShareView.setNeedsLayout()
        brandedShareView.layoutIfNeeded()

        brandedShareView.setOnViewReady { [weak self] in
            self?.hideShareLoadingOverlay()
            
            brandedShareView.setNeedsLayout()
            brandedShareView.layoutIfNeeded()
            
            if let shareContent = brandedShareView.generateShareContent() {
                self?.presentShareActivityViewController(with: shareContent)
            }

            brandedShareView.removeFromSuperview()
        }
    }
    
    private func setupShareLoadingOverlay() {
        self.shareLoadingOverlayView.addSubview(self.shareLoadingActivityIndicator)
        self.view.addSubview(self.shareLoadingOverlayView)
        
        NSLayoutConstraint.activate([
            self.shareLoadingOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.shareLoadingOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.shareLoadingOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.shareLoadingOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.shareLoadingActivityIndicator.centerXAnchor.constraint(equalTo: self.shareLoadingOverlayView.centerXAnchor),
            self.shareLoadingActivityIndicator.centerYAnchor.constraint(equalTo: self.shareLoadingOverlayView.centerYAnchor)
        ])
    }
    
    private func showShareLoadingOverlay() {
        self.shareLoadingOverlayView.isHidden = false
        self.shareLoadingActivityIndicator.startAnimating()
    }
    
    private func hideShareLoadingOverlay() {
        self.shareLoadingOverlayView.isHidden = true
        self.shareLoadingActivityIndicator.stopAnimating()
    }
    
    private func presentShareActivityViewController(with shareContent: ShareContent) {
        let activityViewController = UIActivityViewController(activityItems: shareContent.activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
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

