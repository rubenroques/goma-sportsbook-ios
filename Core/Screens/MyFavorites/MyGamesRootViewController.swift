//
//  MyGamesRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/08/2023.
//

import UIKit
import Combine

class MyGamesRootViewController: UIViewController {

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var shortcutsCollectionView: UICollectionView = Self.createShortcutsCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()
    private lazy var filterBaseView: UIView = Self.createSimpleView()
    private lazy var filtersButtonImage: UIImageView = Self.createFilterImageView()
    private lazy var filtersCountLabel: UILabel = Self.createFiltersCountLabel()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var floatingShortcutsView: FloatingShortcutsView = Self.createFloatingShortcutsView()

    private var pagedViewController: UIPageViewController

    private var viewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: MyGamesRootViewModel

    private var cancellables = Set<AnyCancellable>()

    // Filter
    private var filterFavoritesViewController = FilterFavoritesViewController()
    var filterPublisher: CurrentValueSubject<FilterFavoritesValue, Never> = .init(.time)

    // MARK: - Lifetime and Cycle
    init(viewModel: MyGamesRootViewModel) {
        self.viewModel = MyGamesRootViewModel()

        self.pagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                        navigationOrientation: .horizontal,
                                                        options: nil)

        super.init(nibName: nil, bundle: nil)

        self.title = localized("my_games")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.filterPublisher
            .sink { [weak self] filterApplied in

                switch filterApplied {
                case .time:
                    self?.filtersCountLabel.isHidden = true
                default:
                    self?.filtersCountLabel.isHidden = false
                }

                if let viewControllers = self?.viewControllers {
                    if viewControllers.isEmpty {

                        let allMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .all)
                        let allMyGamesViewController = MyGamesViewController(viewModel: allMyGamesViewModel)

                        let liveMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .live)
                        let liveMyGamesViewController = MyGamesViewController(viewModel: liveMyGamesViewModel)

                        let todayMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .today)
                        let todayMyGamesViewController = MyGamesViewController(viewModel: todayMyGamesViewModel)

                        let tomorrowMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .tomorrow)
                        let tomorrowMyGamesViewController = MyGamesViewController(viewModel: tomorrowMyGamesViewModel)

                        let thisWeekMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .thisWeek)
                        let thisWeekMyGamesViewController = MyGamesViewController(viewModel: thisWeekMyGamesViewModel)

                        let nextWeekMyGamesViewModel = MyGamesViewModel(myGamesTypeList: .nextWeek)
                        let nextWeekMyGamesViewController = MyGamesViewController(viewModel: nextWeekMyGamesViewModel)

                        self?.viewControllers = [
                            allMyGamesViewController,
                            liveMyGamesViewController,
                            todayMyGamesViewController,
                            tomorrowMyGamesViewController,
                            thisWeekMyGamesViewController,
                            nextWeekMyGamesViewController
                        ]
                    }
                    else {
                        for viewController in viewControllers {
                            let myGamesViewController = viewController as? MyGamesViewController

                            myGamesViewController?.reloadDataWithFilter(newFilter: filterApplied)
                        }
                    }
                }

                self?.reloadCollectionView()

            }
            .store(in: &cancellables)

        self.pagedViewController.delegate = self
        self.pagedViewController.dataSource = self

        self.shortcutsCollectionView.register(ListTypeCollectionViewCell.self,
                                              forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.shortcutsCollectionView.delegate = self
        self.shortcutsCollectionView.dataSource = self

        let tapFilterGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFilterAction))
        self.filterBaseView.addGestureRecognizer(tapFilterGesture)
        self.filterBaseView.isUserInteractionEnabled = true

        filtersCountLabel.isHidden = true
        self.view.bringSubviewToFront(self.filtersCountLabel)

        self.reloadCollectionView()
        self.bind(toViewModel: self.viewModel)

        self.floatingShortcutsView.didTapBetslipButtonAction = { [weak self] in
            self?.didTapBetslipView()
        }

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }

                for viewController in self.viewControllers {
                    if let viewController = viewController as? MyGamesViewController {

                        if let currentVCIndex = self.viewModel.selectedIndexPublisher.value {

                            if currentVCIndex != viewController.viewModel.myGamesTypeList.index {
                                
                                viewController.reloadData()

                            }
                        }
                    }
                }
            })
            .store(in: &cancellables)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.filterBaseView.layer.cornerRadius = self.filterBaseView.frame.height / 2
        self.filterBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        self.filterBaseView.layer.masksToBounds = true

        self.filtersCountLabel.layer.cornerRadius = self.filtersCountLabel.frame.width/2

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.shortcutsCollectionView.backgroundColor = UIColor.App.navPills

        self.filterBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary

        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: MyGamesRootViewModel) {

        self.viewModel.selectedIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

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

    func setInitialPage(index: Int) {
        self.viewModel.selectedIndexPublisher.send(index)
    }

    func openBetslipModal() {
        let betslipViewModel = BetslipViewModel()
        
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)

        betslipViewController.willDismissAction = { [weak self] in
            guard let self = self else { return }

            for viewController in self.viewControllers {
                if let viewController = viewController as? MyGamesViewController {
                    viewController.reloadData()
                }
            }

        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    // MARK: Actions
    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {

        self.filterFavoritesViewController.didSelectFilterAction = { [weak self ] filterOption in
            self?.filterPublisher.send(filterOption)
        }

        self.present(self.filterFavoritesViewController, animated: true, completion: nil)

    }

    @objc func didTapBetslipView() {
        self.openBetslipModal()
    }
}

extension MyGamesRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectGamesType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectGamesType(atIndex: index)

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
            self.selectGamesType(atIndex: index)
        }
        else {
            self.selectGamesType(atIndex: 0)
        }
    }

}

extension MyGamesRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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

extension MyGamesRootViewController {

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

    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFilterImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = UIImage(named: "match_filters_icons")

        return imageView
    }

    private static func createFiltersCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10.0)
        label.layer.masksToBounds = true
        label.text = "1"
        label.textAlignment = .center
        return label
    }

    private static func createBottomSafeAreaView() -> UIView {
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

        self.topBaseView.addSubview(self.shortcutsCollectionView)
        self.topBaseView.addSubview(self.filterBaseView)
        self.filterBaseView.addSubview(self.filtersButtonImage)
        self.topBaseView.addSubview(self.filtersCountLabel)

        self.view.addSubview(self.topBaseView)
        self.view.addSubview(self.pagesBaseView)

        self.addChildViewController(self.pagedViewController, toView: self.pagesBaseView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.view.addSubview(self.floatingShortcutsView)

        self.initConstraints()

        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),
        ])

        NSLayoutConstraint.activate([
            self.shortcutsCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.shortcutsCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.shortcutsCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.shortcutsCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),

            self.filterBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.heightAnchor.constraint(equalToConstant: 40),
            self.filterBaseView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.filterBaseView.centerYAnchor.constraint(equalTo: self.shortcutsCollectionView.centerYAnchor),

            self.filtersCountLabel.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor, constant: -6),
            self.filtersCountLabel.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor, constant: -6),
            self.filtersCountLabel.widthAnchor.constraint(equalToConstant: 16),
            self.filtersCountLabel.heightAnchor.constraint(equalTo: self.filtersCountLabel.widthAnchor),

            self.filtersButtonImage.bottomAnchor.constraint(equalTo: self.filterBaseView.bottomAnchor, constant: -8),
            self.filtersButtonImage.topAnchor.constraint(equalTo: self.filterBaseView.topAnchor, constant: 8),
            self.filtersButtonImage.trailingAnchor.constraint(equalTo: self.filterBaseView.trailingAnchor, constant: -6),
            self.filtersButtonImage.centerYAnchor.constraint(equalTo: self.filterBaseView.centerYAnchor),

        ])

        NSLayoutConstraint.activate([
            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor)
        ])

        // Betslip
        NSLayoutConstraint.activate([
            self.floatingShortcutsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.floatingShortcutsView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])

    }
}
