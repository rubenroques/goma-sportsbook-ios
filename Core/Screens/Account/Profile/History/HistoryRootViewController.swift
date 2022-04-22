//
//  HistoryRootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/04/2022.
//

import UIKit
import Combine

class HistoryRootViewController : UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerBaseView: UIView = Self.createContainerView()

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource
    private var viewControllers: [UIViewController] = []

    private var transactionsHistoryViewController: HistoryViewController
    private var bettingHistoryViewController: HistoryViewController

    // MARK: - Lifetime and Cycle
    init() {

        self.transactionsHistoryViewController = HistoryViewController(viewModel: HistoryViewModel(listType: .transactions))
        self.bettingHistoryViewController = HistoryViewController(viewModel: HistoryViewModel(listType: .bettings))

        self.viewControllers = [self.transactionsHistoryViewController, self.bettingHistoryViewController]
        self.viewControllerTabDataSource = TitleTabularDataSource(with: viewControllers)

        self.viewControllerTabDataSource.initialPage = 0

        self.tabViewController = TabularViewController(dataSource: viewControllerTabDataSource)

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()

        self.addChildViewController(tabViewController, toView: self.containerBaseView)
        self.tabViewController.textFont = AppFont.with(type: .bold, size: 16)
        self.tabViewController.setBarDistribution(.parent)

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)

        self.setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.containerBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HistoryRootViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension HistoryRootViewController {

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
        titleLabel.text = localized("history")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButton)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.containerBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 44),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.containerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.containerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
}

