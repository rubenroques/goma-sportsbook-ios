//
//  TipsRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/09/2022.
//

import UIKit

class TipsRootViewController: UIViewController {

    // MARK: Private properties
    private lazy var containerBaseView: UIView = Self.createContainerView()

    private var tabViewController: TabularViewController
    private var viewControllerTabDataSource: TitleTabularDataSource
    private var viewControllers: [UIViewController] = []

    private var tipsViewController: TipsViewController
    private var rankingsViewController: RankingsViewController

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()

    // MARK: Public Properties
    var didTapBetslipButtonAction: (() -> Void)?
    var didTapChatButtonAction: (() -> Void)?
    var shouldShowUserProfile: ((UserBasicInfo) -> Void)?

    // MARK: - Lifetime and Cycle
    init() {

        self.tipsViewController = TipsViewController()
        self.rankingsViewController = RankingsViewController()

        self.viewControllers = [self.tipsViewController, self.rankingsViewController]
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

        self.setupWithTheme()

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }

        self.floatingShortcutsView.didTapChatButtonAction = { [weak self] in
            self?.didTapChatView()
        }

        self.tipsViewController.shouldShowBetslip = { [weak self] in
            self?.didTapBetslipView()
        }

        self.tipsViewController.shouldShowUserProfile = { [weak self] userBasicInfo in
            self?.shouldShowUserProfile?(userBasicInfo)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.tabViewController.sliderBarColor = UIColor.App.highlightSecondary
        self.tabViewController.barColor = UIColor.App.backgroundPrimary
        self.tabViewController.textColor = UIColor.App.textPrimary
        self.tabViewController.separatorBarColor = UIColor.App.separatorLine

        self.containerBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Actions
    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }

    @objc func didTapChatView() {
        self.didTapChatButtonAction?()
    }

}

extension TipsRootViewController: UIGestureRecognizerDelegate {

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

extension TipsRootViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFloatingShortcutsView() -> FloatingShortcutsView {
        let floatingShortcutsView = FloatingShortcutsView()
        floatingShortcutsView.translatesAutoresizingMaskIntoConstraints = false
        return floatingShortcutsView
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerBaseView)

        self.view.addSubview(self.floatingShortcutsView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.containerBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])
    }
}
