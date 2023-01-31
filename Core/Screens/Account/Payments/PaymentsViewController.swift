//
//  PaymentsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/01/2023.
//

import UIKit
import Combine
import ServicesProvider
import Adyen
import AdyenDropIn
import AdyenActions
import AdyenComponents

class PaymentsViewModel {

    private var cancellables = Set<AnyCancellable>()

    var clientKey: String?
    var paymentMethodsResponse: SimplePaymentMethodsResponse?

    var shouldShowPaymentDropIn: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        //self.processDepositResponse()
        self.getPayments()
    }

    private func processDepositResponse() {

        Env.servicesProvider.processDeposit(paymentMethod: "ADYEN_IDEAL", amount: 5.0, option: "DROP_IN")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PROCESS DEPOSIT RESPONSE ERROR: \(error)")
                }
            }, receiveValue: { [weak self] processDepositResponse in
                print("PROCESS DEPOSIT RESPONSE: \(processDepositResponse)")

                self?.clientKey = processDepositResponse.clientKey

            })
            .store(in: &cancellables)

    }

    private func getPayments() {

        Env.servicesProvider.getPayments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENTS RESPONSE ERROR: \(error)")
                }
            }, receiveValue: { [weak self] paymentsResponse in
                print("PAYMENTS RESPONSE: \(paymentsResponse)")

                self?.paymentMethodsResponse = paymentsResponse

                self?.shouldShowPaymentDropIn.send(true)

            })
            .store(in: &cancellables)
    }
}

class PaymentsViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var containerView: UIView = Self.createContainerView()
//    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
//    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    private var viewModel: PaymentsViewModel

    var dropInComponent: DropInComponent?
    // MARK: Public Properties
//    var isLoading: Bool = false {
//        didSet {
//            if isLoading {
//                self.loadingBaseView.isHidden = false
//                self.loadingActivityIndicatorView.startAnimating()
//            }
//            else {
//                self.loadingBaseView.isHidden = true
//                self.loadingActivityIndicatorView.stopAnimating()
//            }
//        }
//    }

    // MARK: - Lifetime and Cycle
    init(viewModel: PaymentsViewModel) {

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

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    private func setupPaymentDropIn(paymentMethodsResponse: ServicesProvider.SimplePaymentMethodsResponse) {
        if let apiContext = try? APIContext(environment: Adyen.Environment.test, clientKey: "test_HNOW5H423JB7JEJYVXMQF655YAT7M5IB") {

            let configuration = DropInComponent.Configuration()

            if let paymentResponseData = try? JSONEncoder().encode(paymentMethodsResponse),

                let paymentMethods = try? JSONDecoder().decode(PaymentMethods.self, from: paymentResponseData) {

                // Optional. In this example, the Pay button will display 10 EUR.
                let payment = Payment(amount: Amount(value: 1000, currencyCode: "EUR"), countryCode: "PT")

                let dropInComponent = DropInComponent(paymentMethods: paymentMethods, context: AdyenContext(apiContext: apiContext, payment: payment))

                dropInComponent.delegate = self

                // Keep the Drop-in instance to avoid it being destroyed after the function is executed.
                self.dropInComponent = dropInComponent

                present(dropInComponent.viewController, animated: true)
            }

        }
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: PaymentsViewModel) {

        viewModel.shouldShowPaymentDropIn
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShow in
                if shouldShow {
                    if let paymentsMethodResponse = viewModel.paymentMethodsResponse {
                        self?.setupPaymentDropIn(paymentMethodsResponse: paymentsMethodResponse)
                    }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}

extension PaymentsViewController: DropInComponentDelegate {
    func didSubmit(_ data: Adyen.PaymentComponentData, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT SUBMIT")
    }

    func didFail(with error: Error, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL: \(error)")

        dropInComponent.viewController.dismiss(animated: true)

    }

    func didProvide(_ data: Adyen.ActionComponentData, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT PROVIDE: \(data)")

    }

    func didComplete(from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT COMPLETE")

    }

    func didFail(with error: Error, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL 2: \(error)")

    }

    func didFail(with error: Error, from dropInComponent: Adyen.AnyDropInComponent) {

        print("PAYMENT FAIL FULL: \(error)")

        dropInComponent.viewController.dismiss(animated: true)

    }

}

extension PaymentsViewController {

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

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .bold, size: 24)
        titleLabel.textAlignment = .center
        titleLabel.text = localized("payments")
        return titleLabel
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

//    private static func createLoadingBaseView() -> UIView {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }
//
//    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
//        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
//        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicatorView.hidesWhenStopped = true
//        activityIndicatorView.stopAnimating()
//        return activityIndicatorView
//    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.closeButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.containerView)

//        self.view.addSubview(self.loadingBaseView)
//        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

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

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 40),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -40),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -30),
            self.closeButton.heightAnchor.constraint(equalToConstant: 44),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)
        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])

        // Loading view
//        NSLayoutConstraint.activate([
//
//            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
//            self.loadingBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
//            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
//
//            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
//            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor)
//        ])

    }
}
