//
//  TipsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 05/09/2022.
//

import UIKit
import Combine

class TipsViewModel {

    enum TipsType: Int {
        case all = 0
        case topTips = 1
        case friends = 2
        case followers = 3
    }

    var tipsPublisher: CurrentValueSubject<[FeaturedTip], Never> = .init([])
    var tipsType: TipsType = .all

    init(tipsType: TipsType) {
        self.tipsType = tipsType
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        return self.tipsPublisher.value.count
    }
}

class TipsViewController: UIViewController {

    // MARK: Private properties
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    private lazy var emptyStateBaseView: UIView = Self.createEmptyStateBaseView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var emptyStateSecondaryLabel: UILabel = Self.createEmptyStateSecondaryLabel()

    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: TipsViewModel
    private var filterSelectedOption: Int = 0

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
                self.loadingActivityIndicatorView.startAnimating()
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingActivityIndicatorView.stopAnimating()
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            self.emptyStateBaseView.isHidden = !isEmptyState
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: TipsViewModel = TipsViewModel(tipsType: .all)) {
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

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.identifier)

        self.tableView.isHidden = false
        self.emptyStateBaseView.isHidden = true

        self.isLoading = false

        self.isEmptyState = true
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

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.emptyStateLabel.textColor = UIColor.App.textPrimary
        self.emptyStateSecondaryLabel.textColor = UIColor.App.textPrimary

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray

    }

}

//
// MARK: - TableView Protocols
//
extension TipsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension TipsViewController {

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.allowsSelection = false
        return tableView
    }

    private static func createEmptyStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "no_content_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "There’s no tips here!"
        return label
    }

    private static func createEmptyStateSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "There are no tips currently to be displayed."
        return label
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.emptyStateBaseView)
        self.view.addSubview(self.loadingBaseView)

        self.emptyStateBaseView.addSubview(self.emptyStateImageView)
        self.emptyStateBaseView.addSubview(self.emptyStateLabel)
        self.emptyStateBaseView.addSubview(self.emptyStateSecondaryLabel)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emptyStateBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.emptyStateBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 24),

            self.emptyStateSecondaryLabel.centerYAnchor.constraint(equalTo: self.emptyStateBaseView.centerYAnchor),

            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),

            self.emptyStateSecondaryLabel.centerXAnchor.constraint(equalTo: self.emptyStateBaseView.centerXAnchor),
            self.emptyStateSecondaryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.emptyStateSecondaryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.emptyStateSecondaryLabel.topAnchor.constraint(equalTo: self.emptyStateLabel.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
