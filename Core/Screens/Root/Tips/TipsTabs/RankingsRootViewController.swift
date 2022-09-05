//
//  RankingsRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/09/2022.
//

import UIKit
import Combine

class RankingsRootViewModel {

    var selectedIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int = 0) {
        self.startTabIndex = startTabIndex
        self.selectedIndexPublisher.send(startTabIndex)
    }

    func selectTicketType(atIndex index: Int) {
        self.selectedIndexPublisher.send(index)
    }

    func numberOfShortcutsSections() -> Int {
        return 1
    }

    func numberOfShortcuts(forSection section: Int) -> Int {
        return 4
    }

    func shortcutTitle(forIndex index: Int) -> String {
        switch index {
        case 0:
            return "All"
        case 1:
            return "Top Tipsters"
        case 2:
            return "Friends"
        case 3:
            return "Following"
        default:
            return ""
        }
    }

}

class RankingsRootViewController: UIViewController {

    // MARK: Private properties
    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var shortcutsCollectionView: UICollectionView = Self.createShortcutsCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()

    private lazy var noLoginBaseView: UIView = Self.createNoLoginBaseView()
    private lazy var noLoginImageView: UIImageView = Self.createNoLoginImageView()
    private lazy var noLoginTitleLabel: UILabel = Self.createNoLoginTitleLabel()
    private lazy var noLoginSubtitleLabel: UILabel = Self.createNoLoginSubtitleLabel()
    private lazy var noLoginButton: UIButton = Self.createNoLoginButton()

    private var pagedViewController: UIPageViewController
    private var viewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: RankingsRootViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var hasLogin: Bool = true {
        didSet {
            self.noLoginBaseView.isHidden = hasLogin
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: RankingsRootViewModel = RankingsRootViewModel()) {
        self.viewModel = viewModel

        self.pagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                        navigationOrientation: .horizontal,
                                                        options: nil)

        super.init(nibName: nil, bundle: nil)

        self.title = "Rankings"

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.viewControllers = [
            RankingsViewController(viewModel: RankingsViewModel(rankingsType: .all)),
            RankingsViewController(viewModel: RankingsViewModel(rankingsType: .topTipsters)),
            RankingsViewController(viewModel: RankingsViewModel(rankingsType: .friends)),
            RankingsViewController(viewModel: RankingsViewModel(rankingsType: .followers))
        ]

        self.pagedViewController.delegate = self
        self.pagedViewController.dataSource = self

        self.shortcutsCollectionView.register(ListTypeCollectionViewCell.nib,
                                              forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.shortcutsCollectionView.delegate = self
        self.shortcutsCollectionView.dataSource = self

        self.noLoginButton.addTarget(self, action: #selector(didTapLoginButton), for: .primaryActionTriggered)

        self.hasLogin = true

        self.reloadCollectionView()
        self.bind(toViewModel: self.viewModel)
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.shortcutsCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.noLoginBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.noLoginTitleLabel.textColor = UIColor.App.textPrimary
        self.noLoginSubtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.noLoginButton)
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: RankingsRootViewModel) {

        self.viewModel.selectedIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

        Env.everyMatrixClient.userSessionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .anonymous:
                    self?.hasLogin = false
                case .logged:
                    self?.hasLogin = true
                }
            }
            .store(in: &cancellables)
    }

    // MARK: Actions
    @objc func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    // MARK: Functions
    func reloadCollectionView() {
        self.shortcutsCollectionView.reloadData()
    }

    func scrollToViewController(atIndex index: Int) {
        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.viewControllers[safe: index] {
                self.pagedViewController.setViewControllers([selectedViewController],
                                                            direction: .forward,
                                                            animated: true,
                                                            completion: nil)
            }
        }
        else {
            if let selectedViewController = self.viewControllers[safe: index] {
                self.pagedViewController.setViewControllers([selectedViewController],
                                                            direction: .reverse,
                                                            animated: true,
                                                            completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
    }

}

extension RankingsRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectTicketType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectTicketType(atIndex: index)

        self.shortcutsCollectionView.reloadData()
        self.shortcutsCollectionView.layoutIfNeeded()
        self.shortcutsCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return viewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController) {
            if index < viewControllers.count - 1 {
                return viewControllers[index + 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if !completed {
            return
        }

        if let currentViewController = pageViewController.viewControllers?.first,
           let index = viewControllers.firstIndex(of: currentViewController) {
            self.selectTicketType(atIndex: index)
        }
        else {
            self.selectTicketType(atIndex: 0)
        }
    }

}

extension RankingsRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfShortcutsSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfShortcuts(forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        cell.setupWithTitle(self.viewModel.shortcutTitle(forIndex: indexPath.row))
        if let index = self.viewModel.selectedIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.viewModel.selectedIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.viewModel.selectedIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

extension RankingsRootViewController {

    private static func createTopBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShortcutsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return collectionView
    }

    private static func createPagesBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNoLoginBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNoLoginImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no_internet_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createNoLoginTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("empty_no_login")
        label.numberOfLines = 2
        return label
    }

    private static func createNoLoginSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_login_rankings")
        label.numberOfLines = 2
        return label
    }

    private static func createNoLoginButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("login"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topBaseView)

        self.topBaseView.addSubview(self.shortcutsCollectionView)

        self.view.addSubview(self.pagesBaseView)

        self.view.addSubview(self.noLoginBaseView)

        self.noLoginBaseView.addSubview(self.noLoginTitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginSubtitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginImageView)
        self.noLoginBaseView.addSubview(self.noLoginButton)

        self.addChildViewController(self.pagedViewController, toView: self.pagesBaseView)

        self.initConstraints()

    }

    private func initConstraints() {

        // Top shortcuts
        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.shortcutsCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.shortcutsCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.shortcutsCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.shortcutsCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor)
        ])

        // View controllers view
        NSLayoutConstraint.activate([
            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // No login views
        NSLayoutConstraint.activate([
            self.noLoginBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.noLoginBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.noLoginBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.noLoginBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.noLoginTitleLabel.centerXAnchor.constraint(equalTo: self.noLoginBaseView.centerXAnchor),
            self.noLoginTitleLabel.leadingAnchor.constraint(equalTo: self.noLoginBaseView.leadingAnchor, constant: 24),

            self.noLoginSubtitleLabel.topAnchor.constraint(equalTo: self.noLoginBaseView.centerYAnchor),
            self.noLoginSubtitleLabel.centerXAnchor.constraint(equalTo: self.noLoginBaseView.centerXAnchor),
            self.noLoginSubtitleLabel.topAnchor.constraint(equalTo: self.noLoginTitleLabel.bottomAnchor, constant: 20),
            self.noLoginSubtitleLabel.leadingAnchor.constraint(equalTo: self.noLoginBaseView.leadingAnchor, constant: 24),

            self.noLoginButton.centerXAnchor.constraint(equalTo: self.noLoginBaseView.centerXAnchor),
            self.noLoginButton.leadingAnchor.constraint(equalTo: self.noLoginBaseView.leadingAnchor, constant: 30),
            self.noLoginButton.heightAnchor.constraint(equalToConstant: 50),
            self.noLoginButton.topAnchor.constraint(equalTo: self.noLoginSubtitleLabel.bottomAnchor, constant: 40),

            self.noLoginImageView.centerXAnchor.constraint(equalTo: self.noLoginBaseView.centerXAnchor),
            self.noLoginImageView.widthAnchor.constraint(equalTo: self.noLoginImageView.heightAnchor),
            self.noLoginImageView.widthAnchor.constraint(equalToConstant: 160),
            self.noLoginImageView.bottomAnchor.constraint(equalTo: self.noLoginTitleLabel.topAnchor, constant: -36)
        ])

    }
}
