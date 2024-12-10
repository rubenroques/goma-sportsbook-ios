//
//  BetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class BetslipViewController: UIViewController {

    enum StartScreen {
        case bets
        case sharedBet(String)
        case myTickets(MyTicketsType, String)
    }

    @IBOutlet private weak var topSafeAreaView: UIView!
    @IBOutlet private weak var navigationBarView: UIView!

    @IBOutlet private weak var accountInfoBaseView: UIView!
    @IBOutlet private weak var accountValueBaseView: UIView!
    @IBOutlet private weak var accountValuePlusView: UIView!
    @IBOutlet private weak var accountValueLabel: UILabel!
    @IBOutlet private weak var accountPlusImageView: UIImageView!

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var tabsBaseView: UIView!
    @IBOutlet private weak var betsLabel: UILabel!
    
    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource

    private var preSubmissionBetslipViewController: PreSubmissionBetslipViewController
    private var myTicketsRootViewController: MyTicketsRootViewController

    private var viewControllers: [UIViewController] = []

    private var cancellables = Set<AnyCancellable>()

    var willDismissAction: (() -> Void)?

    var startScreen: StartScreen

    init(startScreen: StartScreen = .bets) {

        self.startScreen = startScreen
        
        switch startScreen {
        case .sharedBet(_):
            ()
        default:
            if Env.betslipManager.bettingTicketsPublisher.value.isEmpty {
                self.startScreen = .myTickets(.opened, "")
            }
        }

        switch self.startScreen {
        case .myTickets(let type, _):
            switch type {
            case .opened, .won:
                self.myTicketsRootViewController = MyTicketsRootViewController(viewModel: MyTicketsRootViewModel(startTabIndex: 0))
            case .resolved:
                self.myTicketsRootViewController = MyTicketsRootViewController(viewModel: MyTicketsRootViewModel(startTabIndex: 1))
            }
        default:
            self.myTicketsRootViewController = MyTicketsRootViewController(viewModel: MyTicketsRootViewModel(startTabIndex: 0))
        }

        switch self.startScreen {
        case .sharedBet(let token):
            self.preSubmissionBetslipViewController = PreSubmissionBetslipViewController(viewModel: PreSubmissionBetslipViewModel(sharedBetToken: token))
        default:
            self.preSubmissionBetslipViewController = PreSubmissionBetslipViewController(viewModel: PreSubmissionBetslipViewModel())
        }

        self.viewControllers = [self.preSubmissionBetslipViewController, self.myTicketsRootViewController]

        self.viewControllerTabDataSource = TitleTabularDataSource(with: self.viewControllers)

        switch self.startScreen {
        case .bets, .sharedBet:
            self.viewControllerTabDataSource.initialPage = 0
        case .myTickets:
            self.viewControllerTabDataSource.initialPage = 1
        }

        self.tabViewController = TabularViewController(dataSource: viewControllerTabDataSource)

        super.init(nibName: "BetslipViewController", bundle: nil)
    }

    deinit {
        print("BetslipViewController deinit")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = false

        self.addChild(tabViewController)
        self.tabsBaseView.addSubview(tabViewController.view)
        self.tabViewController.view.translatesAutoresizingMaskIntoConstraints = false
        tabsBaseView.addSubview(self.tabViewController.view)
        NSLayoutConstraint.activate([
            tabsBaseView.leadingAnchor.constraint(equalTo: self.tabViewController.view.leadingAnchor),
            tabsBaseView.trailingAnchor.constraint(equalTo: self.tabViewController.view.trailingAnchor),
            tabsBaseView.topAnchor.constraint(equalTo: self.tabViewController.view.topAnchor),
            tabsBaseView.bottomAnchor.constraint(equalTo: self.tabViewController.view.bottomAnchor),
        ])
        self.tabViewController.didMove(toParent: self)

        self.tabViewController.textFont = AppFont.with(type: .bold, size: 16)
        self.tabViewController.setBarDistribution(.parent)

        self.betsLabel.text = localized("bets")

        self.accountValueLabel.font = AppFont.with(type: .bold, size: 14)
        self.betsLabel.font = AppFont.with(type: .heavy, size: 20)

        //
        //
        self.closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.closeButton.setTitle(localized("close"), for: .normal)

        //
        //
        self.accountInfoBaseView.isHidden = true
        self.accountValueLabel.text = localized("loading")

        self.accountInfoBaseView.clipsToBounds = true
        self.accountValuePlusView.clipsToBounds = true
        self.accountInfoBaseView.layer.cornerRadius = CornerRadius.view
        self.accountInfoBaseView.layer.masksToBounds = true
        self.accountInfoBaseView.isUserInteractionEnabled = true

        self.accountValuePlusView.layer.cornerRadius = CornerRadius.squareView
        self.accountValuePlusView.layer.masksToBounds = true

        let tapAccountValue = UITapGestureRecognizer(target: self, action: #selector(self.didTapAccountValue(_:)))
        self.accountInfoBaseView.addGestureRecognizer(tapAccountValue)

        //
        //
        preSubmissionBetslipViewController.betPlacedAction = { [weak self] betPlacedDetails, cashbackResultValue, usedCashback in
            self?.showBetPlacedScreen(withBetPlacedDetails: betPlacedDetails, withCashbackResultValue: cashbackResultValue, usedCashback: usedCashback)
        }

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.accountInfoBaseView.isHidden = false
                }
                else {
                    self?.accountInfoBaseView.isHidden = true
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.refreshUserWallet()

        self.setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    func setupWithTheme() {

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationBarView.backgroundColor = UIColor.App.backgroundPrimary
        self.tabsBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.accountInfoBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueBaseView.backgroundColor = .clear
        self.accountValuePlusView.backgroundColor = UIColor.App.highlightSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        
        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

        self.closeButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        self.betsLabel.textColor = UIColor.App.textPrimary
        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    @objc func didTapAccountValue(_ sender: UITapGestureRecognizer) {
        if let isUserProfileComplete = Env.userSessionStore.isUserProfileComplete {
            if isUserProfileComplete {

                let depositViewController = DepositViewController()

                let navigationViewController = Router.navigationController(with: depositViewController)

                depositViewController.shouldRefreshUserWallet = { [weak self] in
                    Env.userSessionStore.refreshUserWallet()
                }

                self.present(navigationViewController, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: localized("profile_incomplete"),
                                              message: localized("profile_incomplete_2"),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            // No logged-in user
        }
    }

    @IBAction private func didTapCancelButton() {
        self.willDismissAction?()
        self.dismiss(animated: true, completion: { [weak self] in
            self?.willDismissAction?()
        })
    }

    func showBetPlacedScreen(withBetPlacedDetails betPlacedDetailsArray: [BetPlacedDetails], withCashbackResultValue cashbackResultValue: Double? = nil, usedCashback: Bool) {

        Logger.log("Bet placed without erros. Will show feedback screen.")
        
        let betTickets = Env.betslipManager.getBettingTickets()

        let betSubmissionSuccessViewController = BetSubmissionSuccessViewController(betPlacedDetailsArray: betPlacedDetailsArray,
                                                                                    cashbackResultValue: cashbackResultValue,
                                                                                    usedCashback: usedCashback,
        bettingTickets: betTickets)
        
        betSubmissionSuccessViewController.willDismissAction = self.willDismissAction

        self.navigationController?.pushViewController(betSubmissionSuccessViewController, animated: true)
    }

}
