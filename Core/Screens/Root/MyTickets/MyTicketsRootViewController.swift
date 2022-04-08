//
//  MyTicketsRootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 08/04/2022.
//

import UIKit
import Combine

class MyTicketsRootViewModel {

    var selectedTicketTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int) {
        self.startTabIndex = startTabIndex
        self.selectedTicketTypeIndexPublisher.send(startTabIndex)
    }

    func selectTicketType(atIndex index: Int) {
        self.selectedTicketTypeIndexPublisher.send(index)
    }

}

class MyTicketsRootViewController: UIViewController {

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var ticketTypesCollectionView: UICollectionView = Self.createTicketTypesCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()

    private var ticketTypePagedViewController: UIPageViewController

    private var ticketTypesViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: MyTicketsRootViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: MyTicketsRootViewModel) {
        self.viewModel = viewModel

        self.ticketTypePagedViewController  = UIPageViewController(transitionStyle: .scroll,
                                                                   navigationOrientation: .horizontal,
                                                                   options: nil)

        super.init(nibName: nil, bundle: nil)

        self.title = localized("my_bets")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.ticketTypesViewControllers = [
            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .opened)),
            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .resolved)),
            MyTicketsViewController(viewModel: MyTicketsViewModel(myTicketType: .won))
        ]

        self.ticketTypePagedViewController.delegate = self
        self.ticketTypePagedViewController.dataSource = self

        self.ticketTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.ticketTypesCollectionView.delegate = self
        self.ticketTypesCollectionView.dataSource = self

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
        self.ticketTypesCollectionView.backgroundColor = UIColor.App.backgroundSecondary
   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: MyTicketsRootViewModel) {

        self.viewModel.selectedTicketTypeIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

    }

    // MARK: - Convenience
    func reloadCollectionView() {
        self.ticketTypesCollectionView.reloadData()
    }

    func scrollToViewController(atIndex index: Int) {
        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.ticketTypesViewControllers[safe: index] {
                self.ticketTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .forward,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }
        else {
            if let selectedViewController = self.ticketTypesViewControllers[safe: index] {
                self.ticketTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .reverse,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
    }

}

extension MyTicketsRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectTicketType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectTicketType(atIndex: index)

        self.ticketTypesCollectionView.reloadData()
        self.ticketTypesCollectionView.layoutIfNeeded()
        self.ticketTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = ticketTypesViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return ticketTypesViewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = ticketTypesViewControllers.firstIndex(of: viewController) {
            if index < ticketTypesViewControllers.count - 1 {
                return ticketTypesViewControllers[index + 1]
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
           let index = ticketTypesViewControllers.firstIndex(of: currentViewController) {
            self.selectTicketType(atIndex: index)
        }
        else {
            self.selectTicketType(atIndex: 0)
        }
    }

}

extension MyTicketsRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupWithTitle("Open")
        case 1:
            cell.setupWithTitle("Resolved")
        case 2:
            cell.setupWithTitle("Won")
        default:
            ()
        }

        if let index = self.viewModel.selectedTicketTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.viewModel.selectedTicketTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.viewModel.selectedTicketTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

extension MyTicketsRootViewController {

    private static func createTopBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketTypesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)

        return collectionView
    }

    private static func createPagesBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.topBaseView.addSubview(self.ticketTypesCollectionView)

        self.view.addSubview(self.topBaseView)
        self.view.addSubview(self.pagesBaseView)

        self.addChildViewController(self.ticketTypePagedViewController, toView: self.pagesBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),
        ])

        NSLayoutConstraint.activate([
            self.ticketTypesCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.ticketTypesCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.ticketTypesCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.ticketTypesCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

    }
}
