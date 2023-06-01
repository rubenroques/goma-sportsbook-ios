//
//  IdentificationDocsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/06/2023.
//

import UIKit
import Combine
import ServicesProvider

class IdentificationDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []

    var hasLoadedDocumentTypes: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedUserDocuments: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldReloadData: (() -> Void)?

    init() {
        self.setupPublishers()

        self.getDocumentTypes()

    }

    private func setupPublishers() {

        Publishers.CombineLatest(self.hasLoadedDocumentTypes, self.hasLoadedUserDocuments)
            .sink(receiveValue: { [weak self] hasLoadedDocumentTypes, hasLoadedUserDocuments in
                if hasLoadedDocumentTypes && hasLoadedUserDocuments {
                    self?.isLoadingPublisher.send(false)
                    self?.shouldReloadData?()
                }
            })
            .store(in: &cancellables)
    }

    private func getDocumentTypes() {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.getDocumentTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] documentTypesResponse in

                let requiredDocumentTypes = documentTypesResponse.documentTypes.filter({
                    $0.documentType == "IDENTITY_CARD" || $0.documentType == "RESIDENCE_ID" || $0.documentType == "DRIVING_LICENCE" || $0.documentType == "PASSPORT"
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.hasLoadedDocumentTypes.send(true)

                self?.getUserDocuments()
            })
            .store(in: &cancellables)
    }

    private func getUserDocuments() {

        Env.servicesProvider.getUserDocuments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] userDocumentsResponse in

                print("USER DOCUMENTS RESPONSE: \(userDocumentsResponse)")

                let userDocuments = userDocumentsResponse.userDocuments

                if let requiredDocumentTypes = self?.requiredDocumentTypes {
                    self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
                }

            })
            .store(in: &cancellables)
    }

    private func processDocuments(documentTypes: [DocumentType], userDocuments: [UserDocument]) {

        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            let uploadedFiles = userDocuments.filter({
                $0.documentType == documentType.documentType
            }).map({ userDocument -> DocumentFileInfo in

                let userDocumentStatus = FileState(code: userDocument.status)

                return DocumentFileInfo(id: userDocument.documentType, name: userDocument.fileName, status: userDocumentStatus ?? .pendingApproved)
            })

            let documentInfo = DocumentInfo(id: documentType.documentType,
                                            typeName: documentTypeCode?.codeName ?? "",
                                            status: uploadedFiles.isEmpty ? .notReceived : .received,
                                            uploadedFiles: uploadedFiles)

            self.documents.append(documentInfo)
        }

        self.isLoadingPublisher.send(false)
        self.shouldReloadData?()
    }
}

class IdentificationDocsViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var identificationBaseView: UIView = Self.createIdentificationBaseView()
    private lazy var identificationTopStackView: UIStackView = Self.createIdentificationTopStackView()
    private lazy var identificationTitleLabel: UILabel = Self.createIdentificationTitleLabel()
    private lazy var identificationSubtitleLabel: UILabel = Self.createIdentificationSubtitleLabel()

    private lazy var proofAddressBaseView: UIView = Self.createProofAddressBaseView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: IdentificationDocsViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: IdentificationDocsViewModel) {
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

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.identificationBaseView.layer.cornerRadius = CornerRadius.card

        self.proofAddressBaseView.layer.cornerRadius = CornerRadius.card


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

        self.identificationBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.identificationTopStackView.backgroundColor = .clear

        self.identificationTitleLabel.textColor = UIColor.App.textPrimary

        self.identificationSubtitleLabel.textColor = UIColor.App.textSecondary

        self.proofAddressBaseView.backgroundColor = UIColor.App.backgroundSecondary

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: IdentificationDocsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                if !isLoading,
                   let documents = self?.viewModel.documents {
                    self?.identificationSubtitleLabel.isHidden = documents.isNotEmpty
                }
            })
            .store(in: &cancellables)
    }
}

extension IdentificationDocsViewController {

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

    private static func createIdentificationBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIdentificationTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createIdentificationTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("identification")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createIdentificationSubtitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("id_card_residence_id")
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createProofAddressBaseView() -> UIView {
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

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.identificationBaseView)

        self.identificationBaseView.addSubview(self.identificationTopStackView)

        self.identificationTopStackView.addArrangedSubview(self.identificationTitleLabel)
        self.identificationTopStackView.addArrangedSubview(self.identificationSubtitleLabel)

        self.contentBaseView.addSubview(self.proofAddressBaseView)

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
            self.contentBaseView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.identificationBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.identificationBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.identificationBaseView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 20),

            self.identificationTopStackView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor, constant: 14),
            self.identificationTopStackView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor, constant: -14),
            self.identificationTopStackView.topAnchor.constraint(equalTo: self.identificationBaseView.topAnchor, constant: 20),
            self.identificationTopStackView.bottomAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: -20),

            self.proofAddressBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.proofAddressBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.proofAddressBaseView.topAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: 20),
            self.proofAddressBaseView.heightAnchor.constraint(equalToConstant: 200),
            self.proofAddressBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20)

        ])

    }
}
