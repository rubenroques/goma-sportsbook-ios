//
//  MyTicketsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/12/2021.
//

import UIKit
import Combine

class MyTicketsViewController: UIViewController {

    @IBOutlet private weak var myBetsSegmentedControlBaseView: UIView!
    @IBOutlet private weak var myBetsSegmentedControl: UISegmentedControl!
    
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
        self.myBetsSegmentedControlBaseView.isHidden = false
        self.myBetsSegmentedControlBaseView.backgroundColor = .systemPink
        self.loadingBaseView.isHidden = true
        self.emptyBaseView.isHidden = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
      
       
            self.myBetsSegmentedControl.selectedSegmentIndex = 0
            self.viewModel.setMyTicketsType(.resolved)
            //self.didChangeSegmentValue(self.myBetsSegmentedControl)
        
        
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
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.ticketsTableView.backgroundColor = UIColor.App.backgroundPrimary
        self.ticketsTableView.backgroundView?.backgroundColor = UIColor.App.backgroundCards

        self.emptyBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.firstTextFieldLabel.textColor = UIColor.App.textPrimary
        self.secondTextFieldLabel.textColor = UIColor.App.textPrimary
        
        self.noBetsButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
        
        self.myBetsSegmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .selected)
        self.myBetsSegmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .normal)
        self.myBetsSegmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary.withAlphaComponent(0.5)
        ], for: .disabled)

        self.myBetsSegmentedControl.selectedSegmentTintColor = UIColor.App.highlightPrimary

      

        self.myBetsSegmentedControlBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.myBetsSegmentedControl.backgroundColor = UIColor.App.backgroundTertiary

    }

    @objc func refresh() {
        self.shouldShowCenterLoadingView = false
        self.viewModel.refresh()
    }
    
    @IBAction private func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.viewModel.setMyTicketsType(.resolved)
 
        case 1:
            self.viewModel.setMyTicketsType(.opened)
        case 2:
            self.viewModel.setMyTicketsType(.won)
        default:
            ()
        }

    }

}

extension MyTicketsViewController {
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
}
