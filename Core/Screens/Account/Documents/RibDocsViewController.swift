//
//  RibDocsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/06/2023.
//

import UIKit
import Combine

class RibDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var isLocked: CurrentValueSubject<Bool, Never> = .init(false)

    var kycStatusPublisher: AnyPublisher<KnowYourCustomerStatus?, Never> {
        return Env.userSessionStore.userKnowYourCustomerStatusPublisher.eraseToAnyPublisher()
    }

    init() {

        self.getKYCStatus()
    }

    private func getKYCStatus() {
        Env.userSessionStore.refreshProfile()
    }

}
class RibDocsViewController: UIViewController {
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var topStackView: UIStackView = Self.createTopStackView()

    private lazy var lockTitleBaseView: UIView = Self.createLockTitleBaseView()
    private lazy var lockTitleLabel: UILabel = Self.createLockTitleLabel()
    private lazy var lockContainerView: UIView = Self.createLockContainerView()
    private lazy var lockIconImageView: UIImageView = Self.createLockIconImageView()

    private lazy var ribNumberBaseView: UIView = Self.createRibNumberBaseView()
    private lazy var ribNumberLabel: UILabel = Self.createRibNumberLabel()
    private lazy var ribNumberHeaderTextFieldView: HeaderTextFieldView = Self.createRibNumberHeaderTextFieldView()

    private lazy var ribDocumentBaseView: UIView = Self.createRibDocumentBaseView()
    private lazy var ribDocumentTitleLabel: UILabel = Self.createRibDocumentTitleLabel()
    private lazy var ribDocumentTopStackView: UIStackView = Self.createRibDocumentTopStackView()
    private lazy var ribAddDocBaseView: UIView = Self.createRibAddDocBaseView()
    private lazy var ribAddDocView: UIView = Self.createRibAddDocView()
    private lazy var ribAddDocTitleLabel: UILabel = Self.createRibAddDocTitleLabel()
    private lazy var ribAddDocIconImageView: UIImageView = Self.createRibAddDocIconImageView()

    private lazy var ribTopStackViewBottomConstraint: NSLayoutConstraint = Self.createRibTopStackViewBottomConstraint()
    private lazy var ribAddDocBottomConstraint: NSLayoutConstraint = Self.createRibAddDocBottomConstraint()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: RibDocsViewModel

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var isLocked: Bool = false {
        didSet {
            self.lockTitleBaseView.isHidden = !isLocked
            self.lockContainerView.isHidden = !isLocked
        }
    }

    var canAddRibDocs: Bool = true {
        didSet {
            self.ribAddDocBaseView.isHidden = !canAddRibDocs

            self.ribTopStackViewBottomConstraint.isActive = !canAddRibDocs
            self.ribAddDocBottomConstraint.isActive = canAddRibDocs

            self.ribDocumentBaseView.setNeedsLayout()
            self.ribDocumentBaseView.layoutIfNeeded()
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: RibDocsViewModel) {
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

        self.ribNumberHeaderTextFieldView.setPlaceholderText(localized("rib_number"))
        self.ribNumberHeaderTextFieldView.setKeyboardType(.decimalPad)

        self.bind(toViewModel: self.viewModel)

        self.isLocked = false

        let ribAddDocTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapRibAddDoc))
        self.ribAddDocBaseView.addGestureRecognizer(ribAddDocTap)

        let tapBackgroundGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.contentBaseView.addGestureRecognizer(tapBackgroundGestureRecognizer)

        self.canAddRibDocs = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.ribNumberBaseView.layer.cornerRadius = CornerRadius.card

        self.ribDocumentBaseView.layer.cornerRadius = CornerRadius.card

    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.scrollView.backgroundColor = .clear

        self.contentBaseView.backgroundColor = .clear

        self.topStackView.backgroundColor = .clear

        self.lockTitleBaseView.backgroundColor = .clear

        self.lockTitleLabel.textColor = UIColor.App.textSecondary

        self.lockContainerView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

        self.lockIconImageView.backgroundColor = .clear

        self.ribNumberBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.ribNumberLabel.textColor = UIColor.App.textPrimary

        self.ribNumberHeaderTextFieldView.setViewColor(UIColor.App.inputBackground)
        self.ribNumberHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.ribNumberHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.ribDocumentBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.ribDocumentTopStackView.backgroundColor = .clear

        self.ribDocumentTitleLabel.textColor = UIColor.App.textPrimary

        self.ribAddDocBaseView.backgroundColor = .clear

        self.ribAddDocView.backgroundColor = .clear

        self.ribAddDocTitleLabel.textColor = UIColor.App.highlightPrimary

        self.ribAddDocIconImageView.backgroundColor = .clear
        self.ribAddDocIconImageView.setTintColor(color: UIColor.App.highlightPrimary)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: RibDocsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading

            })
            .store(in: &cancellables)

        viewModel.kycStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] kycStatus in

                switch kycStatus {
                case .request:
                    self?.isLocked = true
                default:
                    self?.isLocked = false
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Action
    @objc func didTapRibAddDoc() {
        print("ADD RIB DOC")
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.ribNumberHeaderTextFieldView.resignFirstResponder()

    }

}

extension RibDocsViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }

    private static func createLockTitleBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLockTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("locked_rib_message")
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createLockContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLockIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "lock_blue_icon")
        return imageView
    }

    private static func createRibNumberBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRibNumberLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("rib_number")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }

    private static func createRibNumberHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createRibDocumentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRibDocumentTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("rib_document")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createRibDocumentTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createRibAddDocBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRibAddDocView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRibAddDocTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_documents")
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createRibAddDocIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "add_document_icon")
        return imageView
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

    // Constraints
    private static func createRibTopStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createRibAddDocBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.topStackView)

        self.topStackView.addArrangedSubview(self.lockTitleBaseView)

        self.lockTitleBaseView.addSubview(self.lockTitleLabel)

        self.topStackView.addArrangedSubview(self.ribNumberBaseView)

        self.ribNumberBaseView.addSubview(self.ribNumberLabel)
        self.ribNumberBaseView.addSubview(self.ribNumberHeaderTextFieldView)

        self.contentBaseView.addSubview(self.ribDocumentBaseView)

        self.ribDocumentBaseView.addSubview(self.ribDocumentTitleLabel)
        self.ribDocumentBaseView.addSubview(self.ribDocumentTopStackView)

        self.ribDocumentBaseView.addSubview(self.ribAddDocBaseView)

        self.ribAddDocBaseView.addSubview(self.ribAddDocView)

        self.ribAddDocView.addSubview(self.ribAddDocTitleLabel)
        self.ribAddDocView.addSubview(self.ribAddDocIconImageView)

        self.contentBaseView.addSubview(self.lockContainerView)

        self.lockContainerView.addSubview(self.lockIconImageView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Top stackview
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.topStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.topStackView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 12),

            self.lockTitleLabel.leadingAnchor.constraint(equalTo: self.lockTitleBaseView.leadingAnchor, constant: 52),
            self.lockTitleLabel.trailingAnchor.constraint(equalTo: self.lockTitleBaseView.trailingAnchor, constant: -52),
            self.lockTitleLabel.topAnchor.constraint(equalTo: self.lockTitleBaseView.topAnchor, constant: 8),
            self.lockTitleLabel.bottomAnchor.constraint(equalTo: self.lockTitleBaseView.bottomAnchor, constant: -8),

            self.ribNumberLabel.leadingAnchor.constraint(equalTo: self.ribNumberBaseView.leadingAnchor, constant: 14),
            self.ribNumberLabel.trailingAnchor.constraint(equalTo: self.ribNumberBaseView.trailingAnchor, constant: -14),
            self.ribNumberLabel.topAnchor.constraint(equalTo: self.ribNumberBaseView.topAnchor, constant: 18),

            self.ribNumberHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.ribNumberBaseView.leadingAnchor, constant: 14),
            self.ribNumberHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.ribNumberBaseView.trailingAnchor, constant: -14),
            self.ribNumberHeaderTextFieldView.topAnchor.constraint(equalTo: self.ribNumberLabel.bottomAnchor, constant: 14),
            self.ribNumberHeaderTextFieldView.bottomAnchor.constraint(equalTo: self.ribNumberBaseView.bottomAnchor),
            self.ribNumberHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80)

        ])

        // RIB Document View
        NSLayoutConstraint.activate([
            self.ribDocumentBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.ribDocumentBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.ribDocumentBaseView.topAnchor.constraint(equalTo: self.ribNumberBaseView.bottomAnchor, constant: 23),
            self.ribDocumentBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),

            self.ribDocumentTitleLabel.leadingAnchor.constraint(equalTo: self.ribDocumentBaseView.leadingAnchor, constant: 14),
            self.ribDocumentTitleLabel.trailingAnchor.constraint(equalTo: self.ribDocumentBaseView.trailingAnchor, constant: -14),
            self.ribDocumentTitleLabel.topAnchor.constraint(equalTo: self.ribDocumentBaseView.topAnchor, constant: 17),

            self.ribDocumentTopStackView.leadingAnchor.constraint(equalTo: self.ribDocumentBaseView.leadingAnchor, constant: 14),
            self.ribDocumentTopStackView.trailingAnchor.constraint(equalTo: self.ribDocumentBaseView.trailingAnchor),
            self.ribDocumentTopStackView.topAnchor.constraint(equalTo: self.ribDocumentTitleLabel.bottomAnchor, constant: 4),

            self.ribAddDocBaseView.leadingAnchor.constraint(equalTo: self.ribDocumentBaseView.leadingAnchor, constant: 14),
            self.ribAddDocBaseView.trailingAnchor.constraint(equalTo: self.ribDocumentBaseView.trailingAnchor, constant: -14),
            self.ribAddDocBaseView.topAnchor.constraint(equalTo: self.ribDocumentTopStackView.bottomAnchor, constant: 4),
            self.ribAddDocBaseView.heightAnchor.constraint(equalToConstant: 30),

            self.ribAddDocView.centerXAnchor.constraint(equalTo: self.ribAddDocBaseView.centerXAnchor),
            self.ribAddDocView.bottomAnchor.constraint(equalTo: self.ribAddDocBaseView.bottomAnchor),

            self.ribAddDocTitleLabel.leadingAnchor.constraint(equalTo: self.ribAddDocView.leadingAnchor),
            self.ribAddDocTitleLabel.topAnchor.constraint(equalTo: self.ribAddDocView.topAnchor, constant: 10),
            self.ribAddDocTitleLabel.bottomAnchor.constraint(equalTo: self.ribAddDocView.bottomAnchor, constant: -5),

            self.ribAddDocIconImageView.leadingAnchor.constraint(equalTo: self.ribAddDocTitleLabel.trailingAnchor, constant: 5),
            self.ribAddDocIconImageView.trailingAnchor.constraint(equalTo: self.ribAddDocView.trailingAnchor),
            self.ribAddDocIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.ribAddDocIconImageView.heightAnchor.constraint(equalTo: self.ribAddDocIconImageView.widthAnchor),
            self.ribAddDocIconImageView.centerYAnchor.constraint(equalTo: self.ribAddDocTitleLabel.centerYAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

        //Lock View
        NSLayoutConstraint.activate([
            self.lockContainerView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.lockContainerView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.lockContainerView.topAnchor.constraint(equalTo: self.ribNumberBaseView.topAnchor),
            self.lockContainerView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),

            self.lockIconImageView.widthAnchor.constraint(equalToConstant: 83),
            self.lockIconImageView.heightAnchor.constraint(equalTo: self.lockIconImageView.widthAnchor),
            self.lockIconImageView.topAnchor.constraint(equalTo: self.lockContainerView.topAnchor, constant: 84),
            self.lockIconImageView.centerXAnchor.constraint(equalTo: self.lockContainerView.centerXAnchor)
        ])

        self.ribTopStackViewBottomConstraint = self.ribDocumentTopStackView.bottomAnchor.constraint(equalTo: self.ribDocumentBaseView.bottomAnchor, constant: -20)
        self.ribTopStackViewBottomConstraint.isActive = false

        self.ribAddDocBottomConstraint = self.ribAddDocBaseView.bottomAnchor.constraint(equalTo: self.ribDocumentBaseView.bottomAnchor, constant: -20)
        self.ribAddDocBottomConstraint.isActive = true
    }
}
