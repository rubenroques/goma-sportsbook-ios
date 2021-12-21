//
//  MyTicketsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/12/2021.
//

import UIKit
import Combine

class MyTicketsViewController: UIViewController {

    @IBOutlet private var ticketTypesCollectionView: UICollectionView!
    @IBOutlet private var ticketTypesSeparatorLineView: UIView!
    @IBOutlet private var ticketsTableView: UITableView!

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()

    private lazy var betslipButtonView: UIView = {
        var betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        var iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }()
    private lazy var betslipCountLabel: UILabel = {
        var betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = .white
        betslipCountLabel.backgroundColor = UIColor.App.alertError
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        NSLayoutConstraint.activate([
            betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            betslipCountLabel.widthAnchor.constraint(equalTo: betslipCountLabel.heightAnchor),
        ])
        return betslipCountLabel
    }()

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    private var viewModel: MyTicketsViewModel

    private var cancellables = Set<AnyCancellable>()

    var didTapBetslipButtonAction: (() -> Void)?

    init() {
        self.viewModel = MyTicketsViewModel()


        super.init(nibName: "MyTicketsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingBaseView.isHidden = true

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.scrollDirection = .horizontal
        self.ticketTypesCollectionView.collectionViewLayout = flowLayout
        self.ticketTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.ticketTypesCollectionView.showsVerticalScrollIndicator = false
        self.ticketTypesCollectionView.showsHorizontalScrollIndicator = false
        self.ticketTypesCollectionView.alwaysBounceHorizontal = true
        self.ticketTypesCollectionView.register(ListTypeCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: ListTypeCollectionViewCell.identifier)
        self.ticketTypesCollectionView.delegate = self
        self.ticketTypesCollectionView.dataSource = self

        //
        //
        self.ticketsTableView.delegate = self.viewModel
        self.ticketsTableView.dataSource = self.viewModel
        self.ticketsTableView.register(MyTicketTableViewCell.nib, forCellReuseIdentifier: MyTicketTableViewCell.identifier)
        self.ticketsTableView.separatorStyle = .none

        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.ticketsTableView.addSubview(self.refreshControl)

        //
        //
        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.view.addSubview(self.betslipButtonView)
        self.betslipCountLabel.isHidden = true

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12)
        ])

        self.view.bringSubviewToFront(self.loadingBaseView)

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        betslipButtonView.addGestureRecognizer(tapBetslipView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        self.viewModel.isLoading
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicatorView.startAnimating()
                }
                else {
                    self?.loadingIndicatorView.stopAnimating()
                }
            })
            .store(in: &cancellables)

        self.viewModel.reloadTableViewAction = { [weak self] in
            self?.ticketsTableView.reloadData()
        }

        self.connectPublishers()
        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        self.ticketTypesCollectionView.backgroundColor = UIColor.App.contentBackground

        self.ticketTypesSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.ticketTypesSeparatorLineView.alpha = 0.5

        self.ticketsTableView.backgroundColor = UIColor.App.contentBackground
        self.ticketsTableView.backgroundView?.backgroundColor = UIColor.App.contentBackground

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.mainTint

    }

    func connectPublishers() {

        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in
                if betslipValue == 0 {
                    self?.betslipCountLabel.isHidden = true
                }
                else {
                    self?.betslipCountLabel.text = "\(betslipValue)"
                    self?.betslipCountLabel.isHidden = false
                }
            })
            .store(in: &cancellables)

    }

    @objc func didTapBetslipView() {
        self.didTapBetslipButtonAction?()
    }


    @objc func refresh() {
        self.viewModel.refresh()
    }

}

extension MyTicketsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
            cell.setupWithTitle("Resolved")
        case 1:
            cell.setupWithTitle("Opened")
        case 2:
            cell.setupWithTitle("Won")
        default:
            ()
        }

        if self.viewModel.isTicketsTypeSelected(forIndex: indexPath.row) {
            cell.setSelectedType(true)
        }
        else {
            cell.setSelectedType(false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.row {
        case 0:
            self.viewModel.setMyTicketsType(.resolved)
        case 1:
            self.viewModel.setMyTicketsType(.opened)
        case 2:
            self.viewModel.setMyTicketsType(.won)
        default:
            ()
        }

        self.ticketTypesCollectionView.reloadData()
        self.ticketTypesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}
