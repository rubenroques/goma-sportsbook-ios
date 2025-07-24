//
//  DocumentsRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/06/2023.
//

import UIKit
import Combine

class DocumentsRootViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    private lazy var kycStatusBaseView: UIView = Self.createKycStatusBaseView()
    private lazy var kycStatusTitleLabel: UILabel = Self.createKycStatusTitleLabel()
    private lazy var kycStatusView: UIView = Self.createKycStatusView()
    private lazy var kycStatusLabel: UILabel = Self.createKycStatusLabel()
    private lazy var topBaseView: UIView = Self.createTopBaseView()
    private lazy var documentTypesCollectionView: UICollectionView = Self.createDocumentTypesCollectionView()
    private lazy var pagesBaseView: UIView = Self.createPagesBaseView()

    private var documentTypePagedViewController: UIPageViewController

    private var documentTypesViewControllers = [UIViewController]()
    private var currentPageViewControllerIndex: Int = 0

    private var cancellables = Set<AnyCancellable>()

    var viewModel: DocumentsRootViewModel

    var isModalScreen: Bool = true {
        didSet {
            self.backButton.isHidden = isModalScreen
            self.closeButton.isHidden = !isModalScreen
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: DocumentsRootViewModel) {
        self.viewModel = viewModel

        self.documentTypePagedViewController  = UIPageViewController(transitionStyle: .scroll,
                                                                   navigationOrientation: .horizontal,
                                                                   options: nil)

        super.init(nibName: nil, bundle: nil)

        self.title = localized("documents")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.documentTypesViewControllers = [
            IdentificationDocsViewController(viewModel: IdentificationDocsViewModel()),
            RibDocsViewController(viewModel: RibDocsViewModel()),
            ExtraDocsViewController(viewModel: ExtraDocsViewModel()),
        ]

        self.documentTypePagedViewController.delegate = self
        self.documentTypePagedViewController.dataSource = self

        self.documentTypesCollectionView.register(ListTypeIconCollectionViewCell.self,
                                       forCellWithReuseIdentifier: ListTypeIconCollectionViewCell.identifier)

        self.documentTypesCollectionView.delegate = self
        self.documentTypesCollectionView.dataSource = self

        self.backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(self.didTapCloseButton), for: .primaryActionTriggered)

        self.reloadCollectionView()
        self.bind(toViewModel: self.viewModel)

        self.isModalScreen = self.isRootModal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.kycStatusBaseView.layer.cornerRadius = CornerRadius.card

        self.kycStatusView.layer.cornerRadius = CornerRadius.headerInput
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationBaseView.backgroundColor = .clear

        self.backButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.closeButton.backgroundColor = .clear

        self.kycStatusBaseView.backgroundColor = UIColor.App.borderDrop

        self.kycStatusTitleLabel.textColor = UIColor.App.textSecondary

        self.kycStatusLabel.textColor = UIColor.App.buttonTextPrimary

        self.documentTypesCollectionView.backgroundColor = UIColor.App.navPills

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: DocumentsRootViewModel) {

        viewModel.kycStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] kycStatus in
                if let kycStatus = kycStatus {
                    switch kycStatus {
                    case .request:
                        self?.kycStatusLabel.text = kycStatus.statusName
                        self?.kycStatusView.backgroundColor = UIColor.App.alertError
                    case .passConditional:
                        self?.kycStatusLabel.text = kycStatus.statusName
                        self?.kycStatusView.backgroundColor = UIColor.App.alertWarning
                    case .pass:
                        self?.kycStatusLabel.text = kycStatus.statusName
                        self?.kycStatusView.backgroundColor = UIColor.App.alertSuccess
                    }
                }
                else {
                    self?.kycStatusLabel.text = ""
                }

                self?.viewModel.kycStatus = kycStatus

                self?.documentTypesCollectionView.reloadData()
            })
            .store(in: &cancellables)

        self.viewModel.selectedDocumentTypeIndexPublisher
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
        self.documentTypesCollectionView.reloadData()
    }

    func scrollToViewController(atIndex index: Int) {
        let previousIndex = self.currentPageViewControllerIndex
        if index > previousIndex {
            if let selectedViewController = self.documentTypesViewControllers[safe: index] {
                self.documentTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .forward,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }
        else {
            if let selectedViewController = self.documentTypesViewControllers[safe: index] {
                self.documentTypePagedViewController.setViewControllers([selectedViewController],
                                                                        direction: .reverse,
                                                                        animated: true,
                                                                        completion: nil)
            }
        }

        self.currentPageViewControllerIndex = index
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}

extension DocumentsRootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func selectDocumentType(atIndex index: Int, animated: Bool = true) {
        self.viewModel.selectDocumentType(atIndex: index)

        self.documentTypesCollectionView.reloadData()
        self.documentTypesCollectionView.layoutIfNeeded()
        self.documentTypesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = documentTypesViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return documentTypesViewControllers[index - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = documentTypesViewControllers.firstIndex(of: viewController) {
            if index < documentTypesViewControllers.count - 1 {
                return documentTypesViewControllers[index + 1]
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
           let index = documentTypesViewControllers.firstIndex(of: currentViewController) {
            self.selectDocumentType(atIndex: index)
        }
        else {
            self.selectDocumentType(atIndex: 0)
        }
    }

}

extension DocumentsRootViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(ListTypeIconCollectionViewCell.self, indexPath: indexPath)
        else {
            fatalError()
        }

        switch indexPath.row {
        case 0:
            cell.setupInfo(title: localized("identification_docs"))
        case 1:
            if let kycStatus = self.viewModel.kycStatus {
                if kycStatus == .request {
                    cell.setupInfo(title: localized("rib"), iconName: "lock_icon")
                }
                else {
                    cell.setupInfo(title: localized("rib"))

                }
            }
            else {
                cell.setupInfo(title: localized("rib"))
            }
        case 2:
            if let kycStatus = self.viewModel.kycStatus {
                if kycStatus == .request {
                    cell.setupInfo(title: localized("extra_docs"), iconName: "lock_icon")
                }
                else {
                    cell.setupInfo(title: localized("extra_docs"))
                }
            }
            else {
                cell.setupInfo(title: localized("extra_docs"))
            }
        default:
            ()
        }

        if let index = self.viewModel.selectedDocumentTypeIndexPublisher.value, index == indexPath.row {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let previousSelectionValue = self.viewModel.selectedDocumentTypeIndexPublisher.value ?? -1

        if indexPath.row != previousSelectionValue {
            self.viewModel.selectedDocumentTypeIndexPublisher.send(indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

}

extension DocumentsRootViewController: UIGestureRecognizerDelegate {

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

extension DocumentsRootViewController {

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
        titleLabel.text = localized("documents")
        titleLabel.font = AppFont.with(type: .bold, size: 18)
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

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createKycStatusBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createKycStatusTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("kyc_account_status")
        titleLabel.font = AppFont.with(type: .bold, size: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createKycStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createKycStatusLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("kyc_account_status")
        titleLabel.font = AppFont.with(type: .bold, size: 11)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createTopBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDocumentTypesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }

    private static func createPagesBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)

        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButton)
        self.navigationBaseView.addSubview(self.closeButton)

        self.view.addSubview(self.kycStatusBaseView)

        self.kycStatusBaseView.addSubview(self.kycStatusTitleLabel)
        self.kycStatusBaseView.addSubview(self.kycStatusView)

        self.kycStatusView.addSubview(self.kycStatusLabel)

        self.view.addSubview(self.topBaseView)

        self.topBaseView.addSubview(self.documentTypesCollectionView)

        self.view.addSubview(self.pagesBaseView)

        self.addChildViewController(self.documentTypePagedViewController, toView: self.pagesBaseView)

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

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationBaseView.trailingAnchor, constant: -14),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // KYC Status
        NSLayoutConstraint.activate([
            self.kycStatusBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 14),
            self.kycStatusBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -14),
            self.kycStatusBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor, constant: 10),

            self.kycStatusTitleLabel.leadingAnchor.constraint(equalTo: self.kycStatusBaseView.leadingAnchor, constant: 20),
            self.kycStatusTitleLabel.topAnchor.constraint(equalTo: self.kycStatusBaseView.topAnchor, constant: 20),
            self.kycStatusTitleLabel.bottomAnchor.constraint(equalTo: self.kycStatusBaseView.bottomAnchor, constant: -20),

            self.kycStatusView.trailingAnchor.constraint(equalTo: self.kycStatusBaseView.trailingAnchor, constant: -20),
            self.kycStatusView.centerYAnchor.constraint(equalTo: self.kycStatusBaseView.centerYAnchor),

            self.kycStatusLabel.leadingAnchor.constraint(equalTo: self.kycStatusView.leadingAnchor, constant: 7),
            self.kycStatusLabel.trailingAnchor.constraint(equalTo: self.kycStatusView.trailingAnchor, constant: -7),
            self.kycStatusLabel.topAnchor.constraint(equalTo: self.kycStatusView.topAnchor, constant: 4),
            self.kycStatusLabel.bottomAnchor.constraint(equalTo: self.kycStatusView.bottomAnchor, constant: -4)
        ])

        NSLayoutConstraint.activate([
            self.topBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBaseView.topAnchor.constraint(equalTo: self.kycStatusBaseView.bottomAnchor, constant: 20),
            self.topBaseView.heightAnchor.constraint(equalToConstant: 70),
        ])

        NSLayoutConstraint.activate([
            self.documentTypesCollectionView.leadingAnchor.constraint(equalTo: self.topBaseView.leadingAnchor),
            self.documentTypesCollectionView.trailingAnchor.constraint(equalTo: self.topBaseView.trailingAnchor),
            self.documentTypesCollectionView.topAnchor.constraint(equalTo: self.topBaseView.topAnchor),
            self.documentTypesCollectionView.bottomAnchor.constraint(equalTo: self.topBaseView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.pagesBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagesBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagesBaseView.topAnchor.constraint(equalTo: self.topBaseView.bottomAnchor),
            self.pagesBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

    }
}
