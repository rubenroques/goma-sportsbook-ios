//
//  BettingHistoryRootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 27/04/2022.
//

import UIKit
import Combine

class BettingHistoryRootViewModel {

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
            return localized("open")
        case 1:
            return localized("resolved")
        case 2:
            return localized("won")
        case 3:
            return localized("cashout")
        default:
            return ""
        }
        
    }

}

class BettingHistoryRootViewController: UIViewController {

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var shortcutsCollectionView: UICollectionView = Self.createShortcutsCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()
    
    private lazy var filterBaseView: UIView = Self.createSimpleView()
    private lazy var filtersButtonImage: UIImageView = Self.createFilterImageView()
    private lazy var filtersCountLabel: UILabel = Self.createFiltersCountLabel()

    private lazy var noLoginBaseView: UIView = Self.createNoLoginBaseView()
    private lazy var noLoginImageView: UIImageView = Self.createNoLoginImageView()
    private lazy var noLoginTitleLabel: UILabel = Self.createNoLoginTitleLabel()
    private lazy var noLoginSubtitleLabel: UILabel = Self.createNoLoginSubtitleLabel()
    private lazy var noLoginButton: UIButton = Self.createNoLoginButton()

    private var pagedViewController: UIPageViewController

    private var viewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: BettingHistoryRootViewModel
    private var filterViewModel: FilterHistoryViewModel = FilterHistoryViewModel()
    var filterPublisher: CurrentValueSubject<FilterHistoryViewModel.FilterValue, Never> = .init(.past30Days)
    
    private var filterHistoryViewController = FilterHistoryViewController()
    var startTimeFilter = Date()
    var endTimeFilter = Date()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: BettingHistoryRootViewModel = BettingHistoryRootViewModel()) {
        self.viewModel = viewModel

        self.pagedViewController = UIPageViewController(transitionStyle: .scroll,
                                                                   navigationOrientation: .horizontal,
                                                                   options: nil)

        super.init(nibName: nil, bundle: nil)

        self.title = localized("betting") 
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
                case .past30Days:
                    self?.filtersCountLabel.isHidden = true
                default:
                    self?.filtersCountLabel.isHidden = false
                }

                if let viewControllers = self?.viewControllers {
                    if viewControllers.isEmpty {
                        self?.viewControllers = [
                            BettingHistoryViewController(viewModel: BettingHistoryViewModel(bettingTicketsType: .opened, filterApplied: filterApplied)),
                            BettingHistoryViewController(viewModel: BettingHistoryViewModel(bettingTicketsType: .resolved, filterApplied: filterApplied)),
                            BettingHistoryViewController(viewModel: BettingHistoryViewModel(bettingTicketsType: .won, filterApplied: filterApplied)),
                            BettingHistoryViewController(viewModel: BettingHistoryViewModel(bettingTicketsType: .cashout, filterApplied: filterApplied)),
                        ]
                    }
                    else {
                        for viewController in viewControllers {
                            let bettingHistoryViewController = viewController as? BettingHistoryViewController

                            bettingHistoryViewController?.reloadDataWithFilter(newFilter: filterApplied)
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
        self.filterBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        filtersCountLabel.isHidden = true
        self.view.bringSubviewToFront(self.filtersCountLabel)
        
        self.noLoginButton.addTarget(self, action: #selector(didTapLoginButton), for: .primaryActionTriggered)

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
        self.shortcutsCollectionView.backgroundColor = UIColor.App.navPills

        self.noLoginBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.noLoginTitleLabel.textColor = UIColor.App.textPrimary
        self.noLoginSubtitleLabel.textColor = UIColor.App.textPrimary

        self.filterBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.filtersCountLabel.backgroundColor = UIColor.App.highlightSecondary
        
        StyleHelper.styleButton(button: self.noLoginButton)
   }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        self.topBaseView.layer.masksToBounds = true
//        self.topBaseView.clipsToBounds = true

        self.filterBaseView.layer.cornerRadius = self.filterBaseView.frame.height / 2
        self.filterBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        self.filterBaseView.layer.masksToBounds = true

        self.filtersCountLabel.layer.cornerRadius = self.filtersCountLabel.frame.width/2

    }
    // MARK: - Bindings
    private func bind(toViewModel viewModel: BettingHistoryRootViewModel) {

        self.viewModel.selectedIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

        Env.userSessionStore.userProfileStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .anonymous:
                    self?.showNoLoginView()
                case .logged:
                    self?.hideNoLoginView()
                }
            }
            .store(in: &cancellables)
    }

    @objc func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @objc func didTapFilterAction(sender: UITapGestureRecognizer) {
         self.present(self.filterHistoryViewController, animated: true, completion: nil)
         self.startTimeFilter = self.filterHistoryViewController.viewModel.startTimeFilterPublisher.value
         self.endTimeFilter = self.filterHistoryViewController.viewModel.endTimeFilterPublisher.value
         
        self.filterHistoryViewController.didSelectFilterAction = { [weak self ] opt in
            self?.filterPublisher.send(opt)
            
        }
    }

    // MARK: - Convenience
    func showNoLoginView() {
        self.noLoginBaseView.isHidden = false
    }

    func hideNoLoginView() {
        self.noLoginBaseView.isHidden = true
    }

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

extension BettingHistoryRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

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

extension BettingHistoryRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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

extension BettingHistoryRootViewController {

    private static func createTopBaseView() -> UIView {
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
        label.text = localized("not_logged_in")
        label.numberOfLines = 2
        return label
    }

    private static func createNoLoginSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("need_login_tickets")
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

    private func setupSubviews() {

        self.topBaseView.addSubview(self.shortcutsCollectionView)
        self.topBaseView.addSubview(self.filterBaseView)
        self.filterBaseView.addSubview(self.filtersButtonImage)
        self.topBaseView.addSubview(self.filtersCountLabel)

        self.view.addSubview(self.topBaseView)
        self.view.addSubview(self.pagesBaseView)

        self.noLoginBaseView.addSubview(self.noLoginTitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginSubtitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginImageView)
        self.noLoginBaseView.addSubview(self.noLoginButton)

        self.view.addSubview(self.noLoginBaseView)

        self.noLoginBaseView.isHidden = true

        self.addChildViewController(self.pagedViewController, toView: self.pagesBaseView)

        self.initConstraints()
        // NOTE: Force layout pending
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),
            
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
            self.filtersButtonImage.centerYAnchor.constraint(equalTo: self.filterBaseView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            self.shortcutsCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.shortcutsCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.shortcutsCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.shortcutsCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

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
