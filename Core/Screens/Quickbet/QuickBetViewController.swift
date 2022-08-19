//
//  QuickBetViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 19/08/2022.
//

import UIKit
import Combine

class QuickBetViewModel {

    // MARK: Private Properties
    private var bettingTicket: BettingTicket
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var oddValuePublisher: CurrentValueSubject<String, Never> = .init("")

    init(bettingTicket: BettingTicket) {
        self.bettingTicket = bettingTicket

        self.setupPublishers()
    }

    private func setupPublishers() {

        let newOddValue = Double(floor(self.bettingTicket.value * 100)/100)

        self.oddValuePublisher.value = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
    }

    func getOutcome() -> String {
        return bettingTicket.outcomeDescription
    }

    func getMarket() -> String {
        return bettingTicket.marketDescription
    }

    func getMatch() -> String {
        return bettingTicket.matchDescription
    }

}

class QuickBetViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var outcomeLabel: UILabel = Self.createOutcomeLabel()
    private lazy var oddBaseView: UIView = Self.createOddBaseView()
    private lazy var oddValueLabel: UILabel = Self.createOddValueLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var separatorView: UIView = Self.createSeparatorView()
    private lazy var marketLabel: UILabel = Self.createMarketLabel()
    private lazy var matchLabel: UILabel = Self.createMatchLabel()
    private lazy var returnLabel: UILabel = Self.createReturnLabel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: QuickBetViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: QuickBetViewModel) {
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

        self.bind(toViewModel: self.viewModel)

        self.configureTicketInfo()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.view
        self.containerView.layer.masksToBounds = true

        self.oddBaseView.layer.cornerRadius = 3

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.5)

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.outcomeLabel.textColor = UIColor.App.textPrimary

        self.oddBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.oddValueLabel.textColor = UIColor.App.textPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.marketLabel.textColor = UIColor.App.textPrimary

        self.matchLabel.textColor = UIColor.App.textPrimary

        self.returnLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: QuickBetViewModel) {

        viewModel.oddValuePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] oddValue in
                self?.oddValueLabel.text = oddValue
            })
            .store(in: &cancellables)
    }

    // MARK: Functions

    private func configureTicketInfo() {

        self.outcomeLabel.text = self.viewModel.getOutcome()

        self.marketLabel.text = self.viewModel.getMarket()

        self.matchLabel.text = self.viewModel.getMatch()
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }

}

extension QuickBetViewController {
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

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createOutcomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Outcome"
        label.font = AppFont.with(type: .bold, size: 15)
        return label
    }

    private static func createOddBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }

    private static func createOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-_--"
        label.font = AppFont.with(type: .bold, size: 15)
        return label
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "small_close_cross_light_icon"), for: .normal)
        return button
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMarketLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Market"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match"
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createReturnLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("return")): "
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.containerView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.containerView.addSubview(self.outcomeLabel)

        self.containerView.addSubview(self.oddBaseView)

        self.oddBaseView.addSubview(self.oddValueLabel)

        self.containerView.addSubview(self.closeButton)

        self.containerView.addSubview(self.separatorView)

        self.containerView.addSubview(self.marketLabel)

        self.containerView.addSubview(self.matchLabel)

        self.containerView.addSubview(self.returnLabel)

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

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 9),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -9),
            self.containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 220)
        ])

        // Top info
        NSLayoutConstraint.activate([

            self.outcomeLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.outcomeLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.outcomeLabel.trailingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: 10),

            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.closeButton.centerYAnchor.constraint(equalTo: self.outcomeLabel.centerYAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),

            self.oddBaseView.trailingAnchor.constraint(equalTo: self.closeButton.leadingAnchor, constant: -5),
            self.oddBaseView.centerYAnchor.constraint(equalTo: self.outcomeLabel.centerYAnchor),
            self.oddBaseView.heightAnchor.constraint(equalToConstant: 25),

            self.oddValueLabel.leadingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: 8),
            self.oddValueLabel.trailingAnchor.constraint(equalTo: self.oddBaseView.trailingAnchor, constant: -8),
            self.oddValueLabel.centerYAnchor.constraint(equalTo: self.oddBaseView.centerYAnchor),

            self.separatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.separatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorView.topAnchor.constraint(equalTo: self.outcomeLabel.bottomAnchor, constant: 12)
        ])

        // Middle info
        NSLayoutConstraint.activate([
            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.marketLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.marketLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 12),

            self.matchLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.matchLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.matchLabel.topAnchor.constraint(equalTo: self.marketLabel.bottomAnchor, constant: 5),

            self.returnLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.returnLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.returnLabel.topAnchor.constraint(equalTo: self.matchLabel.bottomAnchor, constant: 5)
        ])

    }
}
