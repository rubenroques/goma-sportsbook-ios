//
//  ManualUploadDocumentsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 07/06/2023.
//

import UIKit
import Combine

class ManualUploadsDocumentsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {

    }
}

class ManualUploadDocumentsViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationTitleLabel = Self.createNavigationTitleLabel()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var sendButton: UIButton = Self.createSendButton()

    private lazy var documentTypeBaseView: UIView = Self.createDocumentTypeBaseView()
    private lazy var documentTypeTitleLabel: UILabel = Self.createDocumentTypeTitleLabel()
    private lazy var documentTypeStackView: UIStackView = Self.createDocumentTypeStackView()

    private lazy var documentUploadsStackView: UIStackView = Self.createDocumentUploadsStackView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    private var cardOptionRadioViews = [CardOptionRadioView]()

    var viewModel: ManualUploadsDocumentsViewModel

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var canSendDocuments: Bool = false {
        didSet {
            self.sendButton.isEnabled = canSendDocuments
        }
    }

    var documentUploadsInfoViews: [DocumentTypeGroup: UploadDocumentsInformationView] = [:]

    // MARK: - Lifetime and Cycle
    init(viewModel: ManualUploadsDocumentsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupDocumentTypesSelector()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.canSendDocuments = false

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.documentTypeBaseView.layer.cornerRadius = CornerRadius.card

        for view in self.cardOptionRadioViews {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
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

        self.navigationView.backgroundColor = .clear

        self.backButton.backgroundColor = .clear

        self.navigationTitleLabel.textColor = UIColor.App.textPrimary

        self.documentTypeBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.documentTypeTitleLabel.textColor = UIColor.App.textPrimary

        self.documentTypeStackView.backgroundColor = .clear

        self.documentUploadsStackView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.sendButton)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: Functions
    private func setupDocumentTypesSelector() {

        let identityCardView = CardOptionRadioView()
        identityCardView.setChecked(true)
        identityCardView.setTitle(title: localized("identity_card"))
        identityCardView.hasSeparator = true

        let residenceIdCardView = CardOptionRadioView()
        residenceIdCardView.setChecked(false)
        residenceIdCardView.setTitle(title: localized("residence_id"))
        residenceIdCardView.hasSeparator = true

        let drivingLicenceCardView = CardOptionRadioView()
        drivingLicenceCardView.setChecked(false)
        drivingLicenceCardView.setTitle(title: localized("driving_licence"))
        drivingLicenceCardView.hasSeparator = true

        let passportCardView = CardOptionRadioView()
        passportCardView.setChecked(false)
        passportCardView.setTitle(title: localized("passport"))

        self.cardOptionRadioViews.append(identityCardView)
        self.cardOptionRadioViews.append(residenceIdCardView)
        self.cardOptionRadioViews.append(drivingLicenceCardView)
        self.cardOptionRadioViews.append(passportCardView)

        identityCardView.didTapView = { [weak self] isChecked in

            if isChecked {
                residenceIdCardView.isChecked = false
                drivingLicenceCardView.isChecked = false
                passportCardView.isChecked = false

                self?.checkUploadDocumentInfoViewToShow(documentTypeGroup: .identityCard)

            }
        }

        residenceIdCardView.didTapView = { [weak self] isChecked in

            if isChecked {
                identityCardView.isChecked = false
                drivingLicenceCardView.isChecked = false
                passportCardView.isChecked = false

                self?.checkUploadDocumentInfoViewToShow(documentTypeGroup: .residenceId)

            }
        }

        drivingLicenceCardView.didTapView = { [weak self] isChecked in

            if isChecked {
                identityCardView.isChecked = false
                residenceIdCardView.isChecked = false
                passportCardView.isChecked = false

                self?.checkUploadDocumentInfoViewToShow(documentTypeGroup: .drivingLicense)

            }
        }

        passportCardView.didTapView = { [weak self] isChecked in

            if isChecked {
                identityCardView.isChecked = false
                residenceIdCardView.isChecked = false
                drivingLicenceCardView.isChecked = false

                self?.checkUploadDocumentInfoViewToShow(documentTypeGroup: .passport)

            }
        }

        self.documentTypeStackView.addArrangedSubview(identityCardView)
        self.documentTypeStackView.addArrangedSubview(residenceIdCardView)
        self.documentTypeStackView.addArrangedSubview(drivingLicenceCardView)
        self.documentTypeStackView.addArrangedSubview(passportCardView)

        self.contentBaseView.setNeedsLayout()
        self.contentBaseView.layoutIfNeeded()

        self.setupDocumentUploadViews(documentTypeGroups: [.identityCard, .residenceId, .drivingLicense, .passport])
    }

    private func setupDocumentUploadViews(documentTypeGroups: [DocumentTypeGroup]) {

        for documentTypeGroup in documentTypeGroups {

            let uploadDocumentsInformationView = UploadDocumentsInformationView()

            uploadDocumentsInformationView.documentTypeGroup = documentTypeGroup

            documentUploadsInfoViews[documentTypeGroup] = uploadDocumentsInformationView

            uploadDocumentsInformationView.setNeedsLayout()
            uploadDocumentsInformationView.layoutIfNeeded()

            self.documentUploadsStackView.addArrangedSubview(uploadDocumentsInformationView)

            if documentTypeGroup == documentTypeGroups.first {
                uploadDocumentsInformationView.isHidden = false
                uploadDocumentsInformationView.isMultiUpload = true
            }
            else {
                uploadDocumentsInformationView.isHidden = true
                uploadDocumentsInformationView.isMultiUpload = false

            }

        }

    }

    private func checkUploadDocumentInfoViewToShow(documentTypeGroup: DocumentTypeGroup) {

        let documentUploadsInfoView = self.documentUploadsInfoViews

        for (key, documentUploadsInfoView) in documentUploadsInfoView {

            if key == documentTypeGroup {
                documentUploadsInfoView.isHidden = false
            }
            else {
                documentUploadsInfoView.isHidden = true
            }
        }

    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: ManualUploadsDocumentsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading

            })
            .store(in: &cancellables)

    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ManualUploadDocumentsViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
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

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("upload_documents")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
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

    private static func createDocumentTypeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDocumentTypeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("choose_type_identification")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createDocumentTypeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }

    private static func createDocumentUploadsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createSendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("send"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        return button
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
    private static func createExtraTopStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createExtraAddDocBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.navigationTitleLabel)

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.documentTypeBaseView)
        self.documentTypeBaseView.addSubview(self.documentTypeTitleLabel)
        self.documentTypeBaseView.addSubview(self.documentTypeStackView)

        self.contentBaseView.addSubview(self.documentUploadsStackView)

        self.containerView.addSubview(self.sendButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()

        self.contentBaseView.setNeedsLayout()
        self.contentBaseView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.navigationView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 18),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.heightAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 50),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -50),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.scrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.sendButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.sendButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.sendButton.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 10),
            self.sendButton.heightAnchor.constraint(equalToConstant: 50),
            self.sendButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
        ])

        // Content base view
        NSLayoutConstraint.activate([
            self.documentTypeBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.documentTypeBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.documentTypeBaseView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 20),

            self.documentTypeTitleLabel.leadingAnchor.constraint(equalTo: self.documentTypeBaseView.leadingAnchor, constant: 17),
            self.documentTypeTitleLabel.trailingAnchor.constraint(equalTo: self.documentTypeBaseView.trailingAnchor, constant: -17),
            self.documentTypeTitleLabel.topAnchor.constraint(equalTo: self.documentTypeBaseView.topAnchor, constant: 19),

            self.documentTypeStackView.leadingAnchor.constraint(equalTo: self.documentTypeBaseView.leadingAnchor, constant: 17),
            self.documentTypeStackView.trailingAnchor.constraint(equalTo: self.documentTypeBaseView.trailingAnchor, constant: -17),
            self.documentTypeStackView.topAnchor.constraint(equalTo: self.documentTypeTitleLabel.bottomAnchor, constant: 20),
            self.documentTypeStackView.bottomAnchor.constraint(equalTo: self.documentTypeBaseView.bottomAnchor, constant: -20),

            self.documentUploadsStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.documentUploadsStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.documentUploadsStackView.topAnchor.constraint(equalTo: self.documentTypeBaseView.bottomAnchor, constant: 25),
            self.documentUploadsStackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),
        ])

    }
}
