//
//  BonusViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/03/2022.
//

import UIKit
import Combine

class BonusViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var bonusSegmentedControlBaseView: UIView = Self.createBonusSegmentedBaseView()
    private lazy var bonusSegmentedControl: UISegmentedControl = Self.createBonusSegmentedControl()
    private lazy var promoCodeBaseView: UIView = Self.createPromoCodeBaseView()
    private lazy var promoCodeStackView: UIStackView = Self.createPromoCodeStackView()
    private lazy var promoCodeLabel: UILabel = Self.createPromoCodeLabel()
    private lazy var promoCodeTextFieldView: ActionTextFieldView = Self.createPromoCodeTextFieldView()
    private lazy var promoCodeLineSeparatorView: UIView = Self.createPromoCodeLineSeparatorView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var emptyStateView: UIView = Self.createEmptyStateView()
    private lazy var emptyStateImageView: UIImageView = Self.createEmptyStateImageView()
    private lazy var emptyStateLabel: UILabel = Self.createEmptyStateLabel()
    private lazy var loadingScreenBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: BonusViewModel

    var isPromoCodeViewHidden: Bool = false {
        didSet {
            if isPromoCodeViewHidden {
                self.promoCodeBaseView.isHidden = true
            }
            else {
                self.promoCodeBaseView.isHidden = false
            }
        }
    }

    var isEmptyState: Bool = false {
        didSet {
            if isEmptyState {
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
            }
            else {
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingScreenBaseView.isHidden = false
            }
            else {
                self.loadingScreenBaseView.isHidden = true
            }
        }
    }

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = BonusViewModel()
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

        self.bind(toViewModel: self.viewModel)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.bonusSegmentedControl.addTarget(self, action: #selector(didChangeSegmentValue), for: .valueChanged)

        self.promoCodeTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                if text != "" {
                    self?.promoCodeTextFieldView.isActionDisabled = false
                }
                else {
                    self?.promoCodeTextFieldView.isActionDisabled = true
                }
            })
            .store(in: &cancellables)

        self.promoCodeTextFieldView.didTapButtonAction = { [weak self] in
            print("APPLY BONUS!")
            let bonusCode = self?.promoCodeTextFieldView.getTextFieldValue() ?? ""
            self?.applyBonus(bonusCode: bonusCode)
        }

    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.bonusSegmentedControlBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.bonusSegmentedControl.selectedSegmentTintColor = UIColor.App.highlightPrimary
        self.bonusSegmentedControl.backgroundColor = UIColor.App.backgroundTertiary

        self.promoCodeStackView.backgroundColor = .clear

        self.promoCodeBaseView.backgroundColor = .clear

        self.promoCodeLabel.textColor = UIColor.App.textPrimary

        self.promoCodeLineSeparatorView.backgroundColor = UIColor.App.buttonTextDisablePrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingScreenBaseView.backgroundColor = UIColor.App.backgroundPrimary
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: BonusViewModel) {

        viewModel.bonusListTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bonusType in
                switch bonusType {
                case .available:
                    self?.isPromoCodeViewHidden = false
                    self?.isEmptyState = false

                case .active:
                    self?.isPromoCodeViewHidden = true
                    if let bonusActiveEmptyState = self?.viewModel.isBonusActiveEmptyPublisher.value {
                        self?.isEmptyState = bonusActiveEmptyState
                    }
                    
                case .history:
                    self?.isPromoCodeViewHidden = true
                    if let bonuHistoryEmptyState = self?.viewModel.isBonusHistoryEmptyPublisher.value {
                        self?.isEmptyState = bonuHistoryEmptyState
                    }

                }

                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        viewModel.shouldReloadData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(viewModel.isBonusApplicableLoading, viewModel.isBonusClaimableLoading)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { isApplicableLoading, isClaimableLoading in
                if isApplicableLoading && isClaimableLoading {
                    self.isLoading = true
                }
                else {
                    self.isLoading = false
                    self.tableView.reloadData()
                }

            })
            .store(in: &cancellables)

        viewModel.requestBonusDetail = { [weak self] bonus in
            self?.showBonusDetail(bonus: bonus)
            //self?.viewModel.updateDataSources()
        }

        viewModel.requestApplyBonus = { [weak self] bonus in
            let bonusCode = bonus.code
            self?.applyBonus(bonusCode: bonusCode)
        }

    }

    private func showBonusDetail(bonus: EveryMatrix.ApplicableBonus) {
        let bonusDetailViewController = BonusDetailViewController(bonus: bonus)
        self.navigationController?.pushViewController(bonusDetailViewController, animated: true)
    }

    private func applyBonus(bonusCode: String) {
        Env.everyMatrixClient.applyBonus(bonusCode: bonusCode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("APPLY BONUS ERROR: \(error)")
                    let errorString = "\(error)"
                    if errorString.lowercased().contains("invalid") {
                        self.showAlert(type: .error, text: localized("invalid_bonus_code"))
                    }
                    else {
                        self.showAlert(type: .error, text: localized("error_bonus_code"))
                    }

                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] bonusResponse in
                print("APPLY BONUS: \(bonusResponse)")
                self?.viewModel.updateDataSources()
            })
            .store(in: &cancellables)
    }

    func showAlert(type: EditAlertView.AlertState, text: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if text != "" {
            popup.setAlertText(text)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            popup.alpha = 1
        }, completion: { _ in
        })
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                popup.alpha = 0
            }, completion: { _ in
                popup.removeFromSuperview()
            })
        }
        self.view.bringSubviewToFront(popup)
    }

}

//
// MARK: TableView Protocols
extension BonusViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections(in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAt: indexPath)
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return self.viewModel.tableView(tableView, viewForHeaderInSection: section)
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.viewModel.tableView(tableView, heightForHeaderInSection: section)
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return self.viewModel.tableView(tableView, estimatedHeightForHeaderInSection: section)
//    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }

}

//
// MARK: - Actions
//
extension BonusViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.viewModel.setBonusType(.available)
        case 1:
            self.viewModel.setBonusType(.active)
        case 2:
            self.viewModel.setBonusType(.history)
        default:
            ()
        }
    }

    @objc func didTapBackground() {
        self.promoCodeTextFieldView.resignFirstResponder()
    }
}

//
// MARK: Subviews initialization and setup
//
extension BonusViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bonus")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createBonusSegmentedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBonusSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: [localized("available"), localized("active"), localized("history")])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .selected)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary.withAlphaComponent(0.5)
        ], for: .disabled)
        return segmentedControl

    }

    private static func createPromoCodeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        return stackView
    }

    private static func createPromoCodeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPromoCodeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = localized("add_promo_code")
        return label
    }

    private static func createPromoCodeTextFieldView() -> ActionTextFieldView {
        let textFieldView = ActionTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.setPlaceholderText(placeholder: localized("bonus_code"))
        textFieldView.setActionButtonTitle(title: localized("add"))
        return textFieldView
    }

    private static func createPromoCodeLineSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }

    private static func createEmptyStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createEmptyStateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.image = UIImage(named: "no_content_icon")
        return imageView
    }

    private static func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no_bonus")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = AppFont.with(type: .bold, size: 22)
        return label
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.bonusSegmentedControlBaseView)
        self.bonusSegmentedControlBaseView.addSubview(self.bonusSegmentedControl)

        self.view.addSubview(self.promoCodeStackView)

        self.promoCodeStackView.addArrangedSubview(self.promoCodeBaseView)

        self.promoCodeBaseView.addSubview(self.promoCodeLabel)
        self.promoCodeBaseView.addSubview(self.promoCodeTextFieldView)
        self.promoCodeBaseView.addSubview(self.promoCodeLineSeparatorView)

        self.view.addSubview(self.tableView)

        self.view.addSubview(self.emptyStateView)

        self.emptyStateView.addSubview(self.emptyStateImageView)
        self.emptyStateView.addSubview(self.emptyStateLabel)

        self.view.addSubview(self.loadingScreenBaseView)

        self.loadingScreenBaseView.addSubview(self.activityIndicatorView)

        tableView.register(BonusAvailableTableViewCell.self, forCellReuseIdentifier: BonusAvailableTableViewCell.identifier)
        tableView.register(BonusActiveTableViewCell.self, forCellReuseIdentifier: BonusActiveTableViewCell.identifier)
        tableView.register(BonusHistoryTableViewCell.self, forCellReuseIdentifier: BonusHistoryTableViewCell.identifier)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.isEmptyState = false
        self.isLoading = false

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(backgroundTapGesture)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 0),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Segmented view
        NSLayoutConstraint.activate([
            self.bonusSegmentedControlBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bonusSegmentedControlBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bonusSegmentedControlBaseView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 8),
            self.bonusSegmentedControlBaseView.heightAnchor.constraint(equalToConstant: 40),

            self.bonusSegmentedControl.leadingAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.leadingAnchor, constant: 30),
            self.bonusSegmentedControl.trailingAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.trailingAnchor, constant: -30),
            self.bonusSegmentedControl.heightAnchor.constraint(equalToConstant: 30),
            self.bonusSegmentedControl.centerYAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.centerYAnchor)
        ])

        // Promo code view
        NSLayoutConstraint.activate([
            self.promoCodeStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.promoCodeStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.promoCodeStackView.topAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.bottomAnchor, constant: 16),

            self.promoCodeBaseView.leadingAnchor.constraint(equalTo: self.promoCodeStackView.leadingAnchor),
            self.promoCodeBaseView.trailingAnchor.constraint(equalTo: self.promoCodeStackView.trailingAnchor),

            self.promoCodeLabel.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeLabel.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeLabel.topAnchor.constraint(equalTo: self.promoCodeBaseView.topAnchor, constant: 8),

            self.promoCodeTextFieldView.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeTextFieldView.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeTextFieldView.topAnchor.constraint(equalTo: self.promoCodeLabel.bottomAnchor, constant: 8),
            self.promoCodeTextFieldView.bottomAnchor.constraint(equalTo: self.promoCodeLineSeparatorView.topAnchor, constant: -20),

            self.promoCodeLineSeparatorView.leadingAnchor.constraint(equalTo: self.promoCodeBaseView.leadingAnchor, constant: 30),
            self.promoCodeLineSeparatorView.trailingAnchor.constraint(equalTo: self.promoCodeBaseView.trailingAnchor, constant: -30),
            self.promoCodeLineSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.promoCodeLineSeparatorView.bottomAnchor.constraint(equalTo: self.promoCodeBaseView.bottomAnchor),
        ])

        // Table view
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.promoCodeStackView.bottomAnchor, constant: 16),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Empty State View
        NSLayoutConstraint.activate([
            self.emptyStateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.emptyStateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.emptyStateView.topAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.bottomAnchor, constant: 8),
            self.emptyStateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.emptyStateImageView.topAnchor.constraint(equalTo: self.emptyStateView.topAnchor, constant: 80),
            self.emptyStateImageView.centerXAnchor.constraint(equalTo: self.emptyStateView.centerXAnchor),
            self.emptyStateImageView.widthAnchor.constraint(equalToConstant: 110),
            self.emptyStateImageView.heightAnchor.constraint(equalToConstant: 110),

            self.emptyStateLabel.leadingAnchor.constraint(equalTo: self.emptyStateView.leadingAnchor, constant: 30),
            self.emptyStateLabel.trailingAnchor.constraint(equalTo: self.emptyStateView.trailingAnchor, constant: -30),
            self.emptyStateLabel.topAnchor.constraint(equalTo: self.emptyStateImageView.bottomAnchor, constant: 20)

        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingScreenBaseView.topAnchor.constraint(equalTo: self.bonusSegmentedControlBaseView.bottomAnchor),
            self.loadingScreenBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingScreenBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingScreenBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingScreenBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingScreenBaseView.centerYAnchor)
        ])

    }

}
