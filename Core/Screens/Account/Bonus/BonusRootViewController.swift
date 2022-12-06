//
//  BonusRootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/04/2022.
//

import UIKit
import Combine

class BonusRootViewModel {

    var selectedBonusTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int = 0) {
        self.startTabIndex = startTabIndex
        self.selectedBonusTypeIndexPublisher.send(startTabIndex)
    }

    func selectBonusType(atIndex index: Int) {
        self.selectedBonusTypeIndexPublisher.send(index)
    }

}

class BonusRootViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var bonusTypesCollectionView: UICollectionView = Self.createBonusTypesCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()

    private lazy var noLoginBaseView: UIView = Self.createNoLoginBaseView()
    private lazy var noLoginImageView: UIImageView = Self.createNoLoginImageView()
    private lazy var noLoginTitleLabel: UILabel = Self.createNoLoginTitleLabel()
    private lazy var noLoginSubtitleLabel: UILabel = Self.createNoLoginSubtitleLabel()
    private lazy var noLoginButton: UIButton = Self.createNoLoginButton()

    private var bonusTypePagedViewController: UIPageViewController

    private var bonusTypesViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var viewModel: BonusRootViewModel

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: BonusRootViewModel) {
        self.viewModel = viewModel

        self.bonusTypePagedViewController  = UIPageViewController(transitionStyle: .scroll,
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

        self.bonusTypesViewControllers = [
            BonusViewController(viewModel: BonusViewModel(bonusListType: .available)),
            BonusViewController(viewModel: BonusViewModel(bonusListType: .active)),
            BonusViewController(viewModel: BonusViewModel(bonusListType: .history)),
        ]

        self.bonusTypePagedViewController.delegate = self
        self.bonusTypePagedViewController.dataSource = self

        self.bonusTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)

        self.bonusTypesCollectionView.delegate = self
        self.bonusTypesCollectionView.dataSource = self

        self.noLoginButton.addTarget(self, action: #selector(self.didTapLoginButton), for: .primaryActionTriggered)

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)

        self.reloadCollectionView()
        self.bind(toViewModel: self.viewModel)
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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.bonusTypesCollectionView.backgroundColor = UIColor.App.backgroundSecondary

        self.noLoginBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.noLoginTitleLabel.textColor = UIColor.App.textPrimary
        self.noLoginSubtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.noLoginButton)
   }


    // MARK: - Bindings
    private func bind(toViewModel viewModel: BonusRootViewModel) {

        self.viewModel.selectedBonusTypeIndexPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newIndex in
                self?.reloadCollectionView()
                self?.scrollToViewController(atIndex: newIndex)
            }
            .store(in: &cancellables)

        Env.userSessionStore.userSessionStatusPublisher
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

    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Convenience
    func showNoLoginView() {
        self.noLoginBaseView.isHidden = false
    }

    func hideNoLoginView() {
        self.noLoginBaseView.isHidden = true
    }

    func reloadCollectionView() {
        self.bonusTypesCollectionView.reloadData()
    }

    func scrollToViewController(atIndex index: Int) {
        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.bonusTypesViewControllers[safe: index] {
                self.bonusTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .forward,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }
        else {
            if let selectedViewController = self.bonusTypesViewControllers[safe: index] {
                self.bonusTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .reverse,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
    }

}

extension BonusRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectBonusType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectBonusType(atIndex: index)

        self.bonusTypesCollectionView.reloadData()
        self.bonusTypesCollectionView.layoutIfNeeded()
        self.bonusTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = bonusTypesViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return bonusTypesViewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = bonusTypesViewControllers.firstIndex(of: viewController) {
            if index < bonusTypesViewControllers.count - 1 {
                return bonusTypesViewControllers[index + 1]
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
           let index = bonusTypesViewControllers.firstIndex(of: currentViewController) {
            self.selectBonusType(atIndex: index)
        }
        else {
            self.selectBonusType(atIndex: 0)
        }
    }

}

extension BonusRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
            cell.setupWithTitle(localized("available"))
        case 1:
            cell.setupWithTitle(localized("active"))
        case 2:
            cell.setupWithTitle(localized("history"))
        default:
            ()
        }

        if let index = self.viewModel.selectedBonusTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.viewModel.selectedBonusTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.viewModel.selectedBonusTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

extension BonusRootViewController: UIGestureRecognizerDelegate {

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

extension BonusRootViewController {


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
        titleLabel.text = localized("bonus")
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
        label.text = localized("empty_no_login")
        label.numberOfLines = 2
        return label
    }

    private static func createNoLoginSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("second_empty_no_login")
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

    private static func createBonusTypesCollectionView() -> UICollectionView {
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

        // Add subviews to self.view or each other
        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButton)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)

        self.topBaseView.addSubview(self.bonusTypesCollectionView)

        self.view.addSubview(self.topBaseView)
        self.view.addSubview(self.pagesBaseView)

        self.noLoginBaseView.addSubview(self.noLoginTitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginSubtitleLabel)
        self.noLoginBaseView.addSubview(self.noLoginImageView)
        self.noLoginBaseView.addSubview(self.noLoginButton)

        self.view.addSubview(self.noLoginBaseView)

        self.noLoginBaseView.isHidden = true

        self.addChildViewController(self.bonusTypePagedViewController, toView: self.pagesBaseView)

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
            self.navigationBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 44),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),
        ])

        NSLayoutConstraint.activate([
            self.bonusTypesCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.bonusTypesCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.bonusTypesCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.bonusTypesCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor)
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
            self.noLoginBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
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

