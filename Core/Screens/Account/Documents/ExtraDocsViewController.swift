//
//  ExtraDocsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 07/06/2023.
//

import UIKit
import Combine
import ServicesProvider

class ExtraDocsViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var lockTitleBaseView: UIView = Self.createLockTitleBaseView()
    private lazy var lockTitleLabel: UILabel = Self.createLockTitleLabel()
    private lazy var lockContainerView: UIView = Self.createLockContainerView()
    private lazy var lockIconImageView: UIImageView = Self.createLockIconImageView()

    private lazy var extraDocumentBaseView: UIView = Self.createExtraDocumentBaseView()
    private lazy var extraDocumentTitleLabel: UILabel = Self.createExtraDocumentTitleLabel()
    private lazy var extraDocumentTopStackView: UIStackView = Self.createExtraDocumentTopStackView()
    private lazy var extraAddDocBaseView: UIView = Self.createExtraAddDocBaseView()
    private lazy var extraAddDocView: UIView = Self.createExtraAddDocView()
    private lazy var extraAddDocTitleLabel: UILabel = Self.createExtraAddDocTitleLabel()
    private lazy var extraAddDocIconImageView: UIImageView = Self.createExtraAddDocIconImageView()

    private lazy var extraTopStackViewBottomConstraint: NSLayoutConstraint = Self.createExtraTopStackViewBottomConstraint()
    private lazy var extraAddDocBottomConstraint: NSLayoutConstraint = Self.createExtraAddDocBottomConstraint()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: ExtraDocsViewModel

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

    var canAddExtraDocs: Bool = true {
        didSet {
            self.extraAddDocBaseView.isHidden = !canAddExtraDocs

            self.extraTopStackViewBottomConstraint.isActive = !canAddExtraDocs
            self.extraAddDocBottomConstraint.isActive = canAddExtraDocs

            self.extraDocumentBaseView.setNeedsLayout()
            self.extraDocumentBaseView.layoutIfNeeded()
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: ExtraDocsViewModel) {
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

        self.bind(toViewModel: self.viewModel)

        self.isLocked = false

        self.canAddExtraDocs = true

        let extraAddDocTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapExtraAddDoc))
        self.extraAddDocBaseView.addGestureRecognizer(extraAddDocTap)

        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.extraDocumentBaseView.layer.cornerRadius = CornerRadius.card

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

        self.extraDocumentBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.extraDocumentTitleLabel.textColor = UIColor.App.textPrimary

        self.extraDocumentTopStackView.backgroundColor = .clear

        self.extraAddDocBaseView.backgroundColor = .clear

        self.extraAddDocView.backgroundColor = .clear

        self.extraAddDocTitleLabel.textColor = UIColor.App.highlightPrimary

        self.extraAddDocIconImageView.backgroundColor = .clear
        self.extraAddDocIconImageView.setTintColor(color: UIColor.App.highlightPrimary)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: ExtraDocsViewModel) {

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

        viewModel.hasDocumentsProcessed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isProcessed in

                if isProcessed {

                    if let documents = self?.viewModel.documents {
                        self?.setupDocumentStateViews(documentsInfo: documents)

                    }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupDocumentStateViews(documentsInfo: [DocumentInfo]) {

        self.extraDocumentTopStackView.removeAllArrangedSubviews()

        if let documentsFileInfo = self.viewModel.documents.first?.uploadedFiles {

            var mostRecentDocument: DocumentFileInfo?

            for uploadedFile in documentsFileInfo {

                let documentStateView = DocumentStateView()

                documentStateView.configure(documentFileInfo: uploadedFile)

                self.extraDocumentTopStackView.addArrangedSubview(documentStateView)

                if let documentDate = uploadedFile.uploadDate {
                    if let recentDocument = mostRecentDocument {
                        if let recentDocumentDate = recentDocument.uploadDate,
                           documentDate > recentDocumentDate {
                            mostRecentDocument = uploadedFile
                        }
                    }
                    else {
                        mostRecentDocument = uploadedFile
                    }
                }
            }

            if let currentDocument = mostRecentDocument {

                if currentDocument.status == .approved || currentDocument.status == .pendingApproved {
                    self.canAddExtraDocs = false
                }
                else {
                    self.canAddExtraDocs = true
                }
            }

        }

    }

    // MARK: Action
    @objc func didTapExtraAddDoc() {
        print("ADD EXTRA DOC")

        let manualUploadDocViewModel = ManualUploadsDocumentsViewModel(documentTypeCode: .others)

        let manualUploadDocViewController = ManualUploadDocumentsViewController(viewModel: manualUploadDocViewModel)

        manualUploadDocViewController.shouldRefreshDocuments = { [weak self] in
            self?.viewModel.refreshDocuments()
        }

        self.navigationController?.pushViewController(manualUploadDocViewController, animated: true)
    }

    @objc func handleRefreshControl() {

        self.viewModel.refreshDocuments()

       DispatchQueue.main.async {
          self.scrollView.refreshControl?.endRefreshing()
       }
    }
}

extension ExtraDocsViewController {

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
        label.text = localized("docs_need_validation_before_others")
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

    private static func createExtraDocumentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createExtraDocumentTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("additional_documents")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createExtraDocumentTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createExtraAddDocBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createExtraAddDocView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createExtraAddDocTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_documents")
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createExtraAddDocIconImageView() -> UIImageView {
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

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.topStackView)

        self.topStackView.addArrangedSubview(self.lockTitleBaseView)

        self.lockTitleBaseView.addSubview(self.lockTitleLabel)

        self.contentBaseView.addSubview(self.extraDocumentBaseView)

        self.extraDocumentBaseView.addSubview(self.extraDocumentTitleLabel)
        self.extraDocumentBaseView.addSubview(self.extraDocumentTopStackView)

        self.extraDocumentBaseView.addSubview(self.extraAddDocBaseView)

        self.extraAddDocBaseView.addSubview(self.extraAddDocView)

        self.extraAddDocView.addSubview(self.extraAddDocTitleLabel)
        self.extraAddDocView.addSubview(self.extraAddDocIconImageView)

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

        ])

        // Extra Document View
        NSLayoutConstraint.activate([
            self.extraDocumentBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.extraDocumentBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.extraDocumentBaseView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 23),
            self.extraDocumentBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),

            self.extraDocumentTitleLabel.leadingAnchor.constraint(equalTo: self.extraDocumentBaseView.leadingAnchor, constant: 14),
            self.extraDocumentTitleLabel.trailingAnchor.constraint(equalTo: self.extraDocumentBaseView.trailingAnchor, constant: -14),
            self.extraDocumentTitleLabel.topAnchor.constraint(equalTo: self.extraDocumentBaseView.topAnchor, constant: 17),

            self.extraDocumentTopStackView.leadingAnchor.constraint(equalTo: self.extraDocumentBaseView.leadingAnchor, constant: 14),
            self.extraDocumentTopStackView.trailingAnchor.constraint(equalTo: self.extraDocumentBaseView.trailingAnchor),
            self.extraDocumentTopStackView.topAnchor.constraint(equalTo: self.extraDocumentTitleLabel.bottomAnchor, constant: 4),

            self.extraAddDocBaseView.leadingAnchor.constraint(equalTo: self.extraDocumentBaseView.leadingAnchor, constant: 14),
            self.extraAddDocBaseView.trailingAnchor.constraint(equalTo: self.extraDocumentBaseView.trailingAnchor, constant: -14),
            self.extraAddDocBaseView.topAnchor.constraint(equalTo: self.extraDocumentTopStackView.bottomAnchor, constant: 4),
            self.extraAddDocBaseView.heightAnchor.constraint(equalToConstant: 30),

            self.extraAddDocView.centerXAnchor.constraint(equalTo: self.extraAddDocBaseView.centerXAnchor),
            self.extraAddDocView.bottomAnchor.constraint(equalTo: self.extraAddDocBaseView.bottomAnchor),

            self.extraAddDocTitleLabel.leadingAnchor.constraint(equalTo: self.extraAddDocView.leadingAnchor),
            self.extraAddDocTitleLabel.topAnchor.constraint(equalTo: self.extraAddDocView.topAnchor, constant: 10),
            self.extraAddDocTitleLabel.bottomAnchor.constraint(equalTo: self.extraAddDocView.bottomAnchor, constant: -5),

            self.extraAddDocIconImageView.leadingAnchor.constraint(equalTo: self.extraAddDocTitleLabel.trailingAnchor, constant: 5),
            self.extraAddDocIconImageView.trailingAnchor.constraint(equalTo: self.extraAddDocView.trailingAnchor),
            self.extraAddDocIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.extraAddDocIconImageView.heightAnchor.constraint(equalTo: self.extraAddDocIconImageView.widthAnchor),
            self.extraAddDocIconImageView.centerYAnchor.constraint(equalTo: self.extraAddDocTitleLabel.centerYAnchor)
        ])

        // Lock View
        NSLayoutConstraint.activate([
            self.lockContainerView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.lockContainerView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.lockContainerView.topAnchor.constraint(equalTo: self.topStackView.topAnchor),
            self.lockContainerView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),

            self.lockIconImageView.widthAnchor.constraint(equalToConstant: 83),
            self.lockIconImageView.heightAnchor.constraint(equalTo: self.lockIconImageView.widthAnchor),
            self.lockIconImageView.topAnchor.constraint(equalTo: self.lockContainerView.topAnchor, constant: 84),
            self.lockIconImageView.centerXAnchor.constraint(equalTo: self.lockContainerView.centerXAnchor)
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

        self.extraTopStackViewBottomConstraint = self.extraDocumentTopStackView.bottomAnchor.constraint(equalTo: self.extraDocumentBaseView.bottomAnchor, constant: -20)
        self.extraTopStackViewBottomConstraint.isActive = false

        self.extraAddDocBottomConstraint = self.extraAddDocBaseView.bottomAnchor.constraint(equalTo: self.extraDocumentBaseView.bottomAnchor, constant: -20)
        self.extraAddDocBottomConstraint.isActive = true

    }
}
