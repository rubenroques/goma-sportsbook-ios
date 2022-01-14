//
//  BetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class BetslipViewController: UIViewController {

    @IBOutlet private weak var topSafeAreaView: UIView!
    @IBOutlet private weak var navigationBarView: UIView!

    @IBOutlet private weak var accountInfoBaseView: UIView!
    @IBOutlet private weak var accountValueBaseView: UIView!
    @IBOutlet private weak var accountValuePlusView: UIView!
    @IBOutlet private weak var accountValueLabel: UILabel!

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var tabsBaseView: UIView!

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource

    private var preSubmissionBetslipViewController: PreSubmissionBetslipViewController
    private var myTicketsViewController: MyTicketsViewController

    private var viewControllers: [UIViewController] = []

    private var cancellables = Set<AnyCancellable>()

    var willDismissAction: (() -> Void)?

    init() {
        preSubmissionBetslipViewController = PreSubmissionBetslipViewController()

        myTicketsViewController = MyTicketsViewController()
        viewControllers = [preSubmissionBetslipViewController, myTicketsViewController]
        
        viewControllerTabDataSource = TitleTabularDataSource(with: viewControllers)
        tabViewController = TabularViewController(dataSource: viewControllerTabDataSource)

        super.init(nibName: "BetslipViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true

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

        self.accountInfoBaseView.clipsToBounds = true
        self.accountValuePlusView.clipsToBounds = true

        let tapAccountValue = UITapGestureRecognizer(target: self, action: #selector(self.didTapAccountValue(_:)))
        self.accountInfoBaseView.addGestureRecognizer(tapAccountValue)

        self.accountValueLabel.text = "Loading"

        preSubmissionBetslipViewController.betPlacedAction = { [weak self] betPlacedDetails in
            self?.showBetPlacedScreen(withBetPlacedDetails: betPlacedDetails)
        }
       
        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .map({ CurrencyFormater.defaultFormat.string(from: NSNumber(value: $0)) ?? "-.--€"})
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.accountValueLabel.text = value
            }
            .store(in: &cancellables)

        Env.userSessionStore.forceWalletUpdate()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.accountInfoBaseView.layer.cornerRadius = 5
        self.accountValuePlusView.layer.cornerRadius = 5
    }

    func setupWithTheme() {

        self.topSafeAreaView.backgroundColor = UIColor.App.mainBackground
        self.navigationBarView.backgroundColor = UIColor.App.mainBackground
        self.tabsBaseView.backgroundColor = UIColor.App.mainBackground

        self.accountInfoBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.accountValueBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.accountValuePlusView.backgroundColor = UIColor.App.mainTint
        self.accountValueLabel.textColor = UIColor.App.headingMain

        self.tabViewController.sliderBarColor = UIColor.App.mainTint
        self.tabViewController.barColor = UIColor.App.mainBackground
        self.tabViewController.textColor = .white
    }

    @objc func didTapAccountValue(_ sender: UITapGestureRecognizer) {
        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let depositViewController = DepositViewController()

            self.navigationController?.pushViewController(depositViewController, animated: true)
        }
        else {
            let alert = UIAlertController(title: localized("Profile Incomplete"),
                                          message: "Please complete your profile before you can make deposits.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction private func didTapCancelButton() {
        self.willDismissAction?()
        self.dismiss(animated: true, completion: nil)
    }

    func showBetPlacedScreen(withBetPlacedDetails betPlacedDetailsArray: [BetPlacedDetails]) {

        var errorCode: String?
        var errorMessage: String?
        var errorBetPlaced: BetPlacedDetails?

        for betPlaced in betPlacedDetailsArray {
            if let errorCodeValue = betPlaced.response.errorCode {
                errorCode = errorCodeValue
                errorMessage = betPlaced.response.errorMessage
                errorBetPlaced = betPlaced
                break
            }
        }

        if errorCode != nil {
            let message = errorMessage != nil ? errorMessage! : "Error placing Bet."

            if let betPlaced = errorBetPlaced {
                Env.betslipManager.addBetPlacedDetailsError(betPlacedDetails: [betPlaced])
            }
            return
        }

        Logger.log("Bet placed without erros. Will show feedback screen.")

        let betSubmissionSuccessViewController = BetSubmissionSuccessViewController(betPlacedDetailsArray: betPlacedDetailsArray)
        betSubmissionSuccessViewController.willDismissAction = self.willDismissAction

        self.navigationController?.pushViewController(betSubmissionSuccessViewController, animated: true)
    }

}
