//
//  IdentificationDocsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/06/2023.
//

import UIKit
import Combine
import ServicesProvider
import IdensicMobileSDK
import CryptoKit

class IdentificationDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []

    var identificationDocuments: [DocumentInfo] = []
    var proofAddressDocuments: [DocumentInfo] = []

    var hasLoadedDocumentTypes: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedUserDocuments: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasDocumentsProcessed: CurrentValueSubject<Bool, Never> = .init(false)

    var sumsubAccessTokenPublisher: CurrentValueSubject<String, Never> = .init("")

    var shouldReloadData: (() -> Void)?

    let dateFormatter = DateFormatter()

    init() {
        self.setupPublishers()

        self.getDocumentTypes()

    }

    func getSumsubAccessToken(levelName: String) {

        self.isLoadingPublisher.send(true)

        let userId = Env.userSessionStore.userProfilePublisher.value?.username ?? ""

        Env.servicesProvider.sumsubDataProvider?.getSumsubAccessToken(userId: userId, levelName: levelName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SUMSUB ACCESS TOKEN ERROR: \(error)")

                    self?.isLoadingPublisher.send(false)

                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] accessTokenResponse in
                print("SUMSUB ACCESS TOKEN RESPONSE: \(accessTokenResponse)")

                if let accessToken = accessTokenResponse.token {
                    self?.sumsubAccessTokenPublisher.send(accessToken)
                }

                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)

    }

    func getSumSubDocuments() {

        self.isLoadingPublisher.send(true)
        self.hasLoadedUserDocuments.send(false)
        self.hasDocumentsProcessed.send(false)

        let userId = Env.userSessionStore.userProfilePublisher.value?.username ?? ""

        Env.servicesProvider.sumsubDataProvider?.getApplicantData(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SUMSUB DATA ERROR: \(error)")

                    self?.isLoadingPublisher.send(false)

                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] applicantDataResponse in
                print("SUMSUB DATA RESPONSE: \(applicantDataResponse)")

                if let requiredDocumentTypes = self?.requiredDocumentTypes {
                    self?.processSumsubDocuments(documentTypes: requiredDocumentTypes, applicantDataResponse: applicantDataResponse)
                }

                self?.getUserDocuments()

            })
            .store(in: &cancellables)
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
                    $0.documentTypeGroup == .identityCard  ||
                    $0.documentTypeGroup == .residenceId ||
                    $0.documentTypeGroup == .drivingLicense ||
                    $0.documentTypeGroup == .passport ||
                    $0.documentTypeGroup == .proofOfAddress
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.hasLoadedDocumentTypes.send(true)

                self?.getSumSubDocuments()
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

                let userDocuments = userDocumentsResponse.userDocuments

                if let requiredDocumentTypes = self?.requiredDocumentTypes {
                    self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
                }

            })
            .store(in: &cancellables)
    }

    private func clearDocumentsData() {
        self.documents = []
        self.identificationDocuments = []
        self.proofAddressDocuments = []

    }

    private func processSumsubDocuments(documentTypes: [DocumentType], applicantDataResponse: ApplicantDataResponse) {

        self.clearDocumentsData()

        var documentFilesInfo = [DocumentFileInfo]()

        if let docTypes = applicantDataResponse.info?.applicantDocs {

            for docType in docTypes {

                let docId = docType.docType

                let docTypeGroup = DocumentTypeGroup(externalCode: docId)

                let docName = docTypeGroup?.codeName ?? ""

                var docStatus = FileState.pendingApproved

                var retry: Bool = true

                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
                var uploadDate: Date? = nil

                // Check documents state
                if let levelName = applicantDataResponse.reviewData?.levelName,
                   let reviewStatus = applicantDataResponse.reviewData?.reviewStatus,
                   let docTypeGroup = docTypeGroup {

                    // Doc in same level group
                    if levelName == docTypeGroup.levelName {

                        uploadDate = self.dateFormatter.date(from: applicantDataResponse.reviewData?.createDate ?? "")

                        if reviewStatus == "completed" {
                            if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                               reviewResult == "RED" {
                                docStatus = .rejected

                                if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                    retry = reviewRejectType == "RETRY" ? true : false
                                }
                            }
                            else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                    reviewResult == "GREEN" {
                                docStatus = .approved

                                retry = false
                            }
                        }
                        else if reviewStatus == "init" {
                            if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                               reviewResult == "RED" {
                                docStatus = .rejected

                                if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                    retry = reviewRejectType == "RETRY" ? true : false
                                }
                            }
                            else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                    reviewResult == "GREEN" {
                                docStatus = .incomplete

                                retry = true
                            }
                        }
                        else {
                            docStatus = .pendingApproved
                            retry = false
                        }
                    }
                    else {
                        if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                           reviewResult == "RED" {
                            docStatus = .rejected

                            if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                retry = reviewRejectType == "RETRY" ? true : false
                            }
                        }
                        else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                reviewResult == "GREEN" {
                            docStatus = .approved

                            retry = false
                        }
                    }

                }

                let docFileInfo = DocumentFileInfo(id: docId, name: docName, status: docStatus, uploadDate: uploadDate, retry: retry, documentTypeGroup: docTypeGroup ?? .none)

                documentFilesInfo.append(docFileInfo)
            }
        }

        // Associate docFileInfos to documentTypes
        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            if let documentTypeGroup = documentType.documentTypeGroup {

                let mappedDocumentTypeGroup = ServiceProviderModelMapper.documentTypeGroup(fromServiceProviderDocumentTypeGroup: documentTypeGroup)

                let uploadedFiles = documentFilesInfo.filter( {
                    $0.documentTypeGroup == mappedDocumentTypeGroup
                })

                let documentInfo = DocumentInfo(id: documentType.documentType,
                                                typeName: documentTypeCode?.codeName ?? "",
                                                status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                uploadedFiles: uploadedFiles,
                                                typeGroup: mappedDocumentTypeGroup)

                self.documents.append(documentInfo)

            }
            else {

                let uploadedFiles = documentFilesInfo

                let documentInfo = DocumentInfo(id: documentType.documentType,
                                                typeName: documentTypeCode?.codeName ?? "",
                                                status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                uploadedFiles: uploadedFiles)

                self.documents.append(documentInfo)
            }
        }

        let identificationDocuments = self.documents.filter({
            $0.typeGroup == .identityCard ||
            $0.typeGroup == .residenceId ||
            $0.typeGroup == .drivingLicense ||
            $0.typeGroup == .passport
        })
        self.identificationDocuments = identificationDocuments

        let proofAddress = self.documents.filter({
            $0.typeGroup == .proofAddress
        })
        self.proofAddressDocuments = proofAddress

    }

    private func processDocuments(documentTypes: [DocumentType], userDocuments: [UserDocument]) {

        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            if let documentTypeGroup = documentType.documentTypeGroup {

                let mappedDocumentTypeGroup = ServiceProviderModelMapper.documentTypeGroup(fromServiceProviderDocumentTypeGroup: documentTypeGroup)

                let uploadedFiles = userDocuments.filter({
                    $0.documentType == documentType.documentType
                }).map({ userDocument -> DocumentFileInfo in

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)

                    return DocumentFileInfo(id: userDocument.documentType,
                                            name: userDocument.fileName,
                                            status: userDocumentStatus ?? .pendingApproved,
                                            uploadDate: uploadDate ?? Date(),
                                            documentTypeGroup: mappedDocumentTypeGroup)
                })

                var existingDocumentInfo: DocumentInfo?

                for document in self.documents {
                    if let typeGroup = document.typeGroup,
                       typeGroup == mappedDocumentTypeGroup {
                        existingDocumentInfo = document
                    }
                }

                if let existingDocumentInfo {
                    var documentInfoIndex = self.documents.firstIndex(where: {
                        $0.id == existingDocumentInfo.id
                    })

                    if let index = documentInfoIndex {
                        var documentFileInfo = self.documents[index]

                        documentFileInfo.uploadedFiles.append(contentsOf: uploadedFiles)

                        self.documents[index] = documentFileInfo

                    }
                }
                else {
                    let documentInfo = DocumentInfo(id: documentType.documentType,
                                                    typeName: documentTypeCode?.codeName ?? "",
                                                    status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                    uploadedFiles: uploadedFiles,
                                                    typeGroup: mappedDocumentTypeGroup)

                    self.documents.append(documentInfo)
                }

            }
            else {

                let uploadedFiles = userDocuments.filter({
                    $0.documentType == documentType.documentType
                }).map({ userDocument -> DocumentFileInfo in

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)

                    return DocumentFileInfo(id: userDocument.documentType,
                                            name: userDocument.fileName,
                                            status: userDocumentStatus ?? .pendingApproved,
                                            uploadDate: uploadDate ?? Date(),
                                            documentTypeGroup: .none)
                })

                var existingDocumentInfo: DocumentInfo?

                for document in self.documents {
                    if document.id == documentType.documentType  {
                        existingDocumentInfo = document
                    }
                }

                if let existingDocumentInfo {
                    var documentInfoIndex = self.documents.firstIndex(where: {
                        $0.id == existingDocumentInfo.id
                    })

                    if let index = documentInfoIndex {
                        var documentFileInfo = self.documents[index]

                        documentFileInfo.uploadedFiles.append(contentsOf: uploadedFiles)

                        self.documents[index] = documentFileInfo

                    }
                }
                else {
                    let documentInfo = DocumentInfo(id: documentType.documentType,
                                                    typeName: documentTypeCode?.codeName ?? "",
                                                    status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                    uploadedFiles: uploadedFiles)

                    self.documents.append(documentInfo)
                }

            }
        }

        let identificationDocuments = self.documents.filter({
            $0.typeGroup == .identityCard ||
            $0.typeGroup == .residenceId ||
            $0.typeGroup == .drivingLicense ||
            $0.typeGroup == .passport
        })
        self.identificationDocuments = identificationDocuments

        let proofAddress = self.documents.filter({
            $0.typeGroup == .proofAddress

        })
        self.proofAddressDocuments = proofAddress

        self.isLoadingPublisher.send(false)
        self.hasLoadedUserDocuments.send(true)
        self.hasDocumentsProcessed.send(true)
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
    private lazy var identificationBottomStackView: UIStackView = Self.createIdentificationBottomStackView()
    private lazy var idAddDocBaseView: UIView = Self.createIdAddDocBaseView()
    private lazy var idAddDocView: UIView = Self.createIdAddDocView()
    private lazy var idAddDocTitleLabel: UILabel = Self.createIdAddDocTitleLabel()
    private lazy var idAddDocIconImageView: UIImageView = Self.createIdAddDocIconImageView()

    private lazy var idBottomStackViewBottomConstraint: NSLayoutConstraint = Self.createIdBottomStackViewBottomConstraint()
    private lazy var idAddDocBottomConstraint: NSLayoutConstraint = Self.createIdAddDocBottomConstraint()

    private lazy var proofAddressBaseView: UIView = Self.createProofAddressBaseView()
    private lazy var proofAddressTopStackView: UIStackView = Self.createProofAddressTopStackView()
    private lazy var proofAddressTitleLabel: UILabel = Self.createProofAddressTitleLabel()
    private lazy var proofAddressSubtitleLabel: UILabel = Self.createProofAddressSubtitleLabel()
    private lazy var proofAddressBottomStackView: UIStackView = Self.createProofAddressBottomStackView()
    private lazy var proofAddDocBaseView: UIView = Self.createProofAddDocBaseView()
    private lazy var proofAddDocView: UIView = Self.createProofAddDocView()
    private lazy var proofAddDocTitleLabel: UILabel = Self.createProofAddDocTitleLabel()
    private lazy var proofAddDocIconImageView: UIImageView = Self.createProofAddDocIconImageView()

    private lazy var proofBottomStackViewBottomConstraint: NSLayoutConstraint = Self.createProofBottomStackViewBottomConstraint()
    private lazy var proofAddDocBottomConstraint: NSLayoutConstraint = Self.createProofAddDocBottomConstraint()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: IdentificationDocsViewModel

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var canAddIdentificationDocs: Bool = true {
        didSet {
            self.idAddDocBaseView.isHidden = !canAddIdentificationDocs

            self.idBottomStackViewBottomConstraint.isActive = !canAddIdentificationDocs
            self.idAddDocBottomConstraint.isActive = canAddIdentificationDocs

            self.identificationBaseView.setNeedsLayout()
            self.identificationBaseView.layoutIfNeeded()
        }
    }

    var canAddProofDocs: Bool = true {
        didSet {
            self.proofBottomStackViewBottomConstraint.isActive = !canAddProofDocs
            self.proofAddDocBottomConstraint.isActive = canAddProofDocs

            self.proofAddDocBaseView.isHidden = !canAddProofDocs

            self.proofAddressBaseView.setNeedsLayout()
            self.proofAddressBaseView.layoutIfNeeded()
        }
    }

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

        let idAddDocTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapIdAddDoc))
        self.idAddDocBaseView.addGestureRecognizer(idAddDocTap)

        let proofAddDocTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapProofAddDoc))
        self.proofAddDocBaseView.addGestureRecognizer(proofAddDocTap)

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

        self.idAddDocBaseView.backgroundColor = .clear

        self.idAddDocView.backgroundColor = .clear

        self.idAddDocTitleLabel.textColor = UIColor.App.highlightPrimary

        self.idAddDocIconImageView.backgroundColor = .clear
        self.idAddDocIconImageView.setTintColor(color: UIColor.App.highlightPrimary)

        self.proofAddressBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.proofAddressTopStackView.backgroundColor = .clear

        self.proofAddressTitleLabel.textColor = UIColor.App.textPrimary

        self.proofAddressSubtitleLabel.textColor = UIColor.App.textSecondary

        self.proofAddDocBaseView.backgroundColor = .clear

        self.proofAddDocView.backgroundColor = .clear

        self.proofAddDocTitleLabel.textColor = UIColor.App.highlightPrimary

        self.proofAddDocIconImageView.backgroundColor = .clear
        self.proofAddDocIconImageView.setTintColor(color: UIColor.App.highlightPrimary)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: IdentificationDocsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading

            })
            .store(in: &cancellables)

        viewModel.sumsubAccessTokenPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue:  { [weak self] accessToken in
                if accessToken != "" {
                    self?.showSumsub(accessToken: accessToken)
                }
            })
            .store(in: &cancellables)

        viewModel.hasDocumentsProcessed
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isProcessed in

                if isProcessed {

                        if let identificationDocuments = self?.viewModel.identificationDocuments {

                            var hasUploadedDocuments = false

                            for identificationDocument in identificationDocuments {
                                if identificationDocument.uploadedFiles.isNotEmpty {
                                    hasUploadedDocuments = true
                                    break
                                }
                            }

                            self?.identificationSubtitleLabel.isHidden = hasUploadedDocuments
                        }

                        if let proofAddressDocuments = self?.viewModel.proofAddressDocuments {

                            var hasUploadedDocuments = false

                            if let proofAddressDocument = proofAddressDocuments.first,
                               proofAddressDocument.uploadedFiles.isNotEmpty {
                                hasUploadedDocuments = true
                            }

                            self?.proofAddressSubtitleLabel.isHidden = hasUploadedDocuments

                        }

                        if let documents = self?.viewModel.documents {
                            self?.setupDocumentStateViews(documentsInfo: documents)

                        }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Action
    @objc func didTapIdAddDoc() {
        print("ADD ID DOC")

        self.viewModel.getSumsubAccessToken(levelName: "ID Verifiication")
//        let manualUploadDocumentViewModel = ManualUploadsDocumentsViewModel()
//
//        let manualUploadDocumentViewController = ManualUploadDocumentsViewController(viewModel: manualUploadDocumentViewModel)
//
//        self.navigationController?.pushViewController(manualUploadDocumentViewController, animated: true)
    }

    @objc func didTapProofAddDoc() {
        print("ADD PROOF DOC")
        //self.viewModel.getSumsubAccessToken(levelName: "POA Verification")
        let manualUploadDocumentViewModel = ManualUploadsDocumentsViewModel(documentTypeCode: .proofAddress)

        let manualUploadDocumentViewController = ManualUploadDocumentsViewController(viewModel: manualUploadDocumentViewModel)

        self.navigationController?.pushViewController(manualUploadDocumentViewController, animated: true)
    }

    // MARK: Functions
    private func showSumsub(accessToken: String) {

        let sdk = SNSMobileSDK(
            accessToken: accessToken
        )

        guard sdk.isReady else {
            print("Initialization failed: " + sdk.verboseStatus)
            return
        }

        // TODO: Check token expiration
//        sdk.tokenExpirationHandler { (onComplete) in
//            self.viewModel.getSumsubAccessToken()
//
//            self.viewModel.
//            { (newToken) in
//                onComplete(newToken)
//            }
//        }

        // Verification handler
        sdk.verificationHandler { (isApproved) in
            print("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }

        // Dismiss handler
        sdk.dismissHandler { (sdk, mainVC) in
            mainVC.dismiss(animated: true, completion: nil)

            self.viewModel.getSumSubDocuments()
        }

        self.present(sdk.mainVC, animated: true, completion: nil)

    }
    private func setupDocumentStateViews(documentsInfo: [DocumentInfo]) {

        self.identificationBottomStackView.removeAllArrangedSubviews()
        self.proofAddressBottomStackView.removeAllArrangedSubviews()

        let identityDocuments = self.viewModel.identificationDocuments

        var mostRecentIdentityDocument: DocumentFileInfo?

        for identityDocument in identityDocuments {

            for identityFileInfo in identityDocument.uploadedFiles {
                
                let documentStateView = DocumentStateView()

                documentStateView.configure(documentFileInfo: identityFileInfo)

                self.identificationBottomStackView.addArrangedSubview(documentStateView)

                if let documentDate = identityFileInfo.uploadDate {
                    if let recentDocument = mostRecentIdentityDocument {
                        if let recentDocumentDate = recentDocument.uploadDate,
                           documentDate > recentDocumentDate {
                            mostRecentIdentityDocument = identityFileInfo
                        }
                    }
                    else {
                        mostRecentIdentityDocument = identityFileInfo
                    }
                }
                else {
                    mostRecentIdentityDocument = identityFileInfo
                }

            }
        }

        if let currentDocument = mostRecentIdentityDocument {

            if let canRetry = currentDocument.retry {
                self.canAddIdentificationDocs = canRetry
            }
            else {
                if currentDocument.status == .approved || currentDocument.status == .pendingApproved {
                    self.canAddIdentificationDocs = false
                }
                else {
                    self.canAddIdentificationDocs = true
                }
            }

        }

        if let proofAddressFilesInfo = self.viewModel.proofAddressDocuments.first?.uploadedFiles {

            var mostRecentProofDocument: DocumentFileInfo?

            for proofFileInfo in proofAddressFilesInfo {

                let documentStateView = DocumentStateView()

                documentStateView.configure(documentFileInfo: proofFileInfo)

                self.proofAddressBottomStackView.addArrangedSubview(documentStateView)

                if let documentDate = proofFileInfo.uploadDate {
                    if let recentDocument = mostRecentProofDocument {
                        if let recentDocumentDate = recentDocument.uploadDate,
                           documentDate > recentDocumentDate {
                            mostRecentProofDocument = proofFileInfo
                        }
                    }
                    else {
                        mostRecentProofDocument = proofFileInfo
                    }
                }
                else {
                    mostRecentProofDocument = proofFileInfo
                }
            }

            if let currentDocument = mostRecentProofDocument {

                if let canRetry = currentDocument.retry {
                    self.canAddProofDocs = canRetry
                }
                else {
                    if currentDocument.status == .approved || currentDocument.status == .pendingApproved {
                        self.canAddProofDocs = false
                    }
                    else {
                        self.canAddProofDocs = true
                    }
                }

            }

        }

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
        titleLabel.text = localized("id_card_or_residence_id")
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createIdentificationBottomStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createIdAddDocBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIdAddDocView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIdAddDocTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_documents")
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createIdAddDocIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "add_document_icon")
        return imageView
    }

    private static func createProofAddressBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProofAddressTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createProofAddressTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("proof_of_address")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createProofAddressSubtitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("driving_licence_or_passport")
        titleLabel.font = AppFont.with(type: .bold, size: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        return titleLabel
    }

    private static func createProofAddressBottomStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createProofAddDocBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProofAddDocView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProofAddDocTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("add_documents")
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createProofAddDocIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "add_document_icon")
        return imageView
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
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
    private static func createIdBottomStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createIdAddDocBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createProofBottomStackViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createProofAddDocBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.identificationBaseView)

        self.identificationBaseView.addSubview(self.identificationTopStackView)

        self.identificationTopStackView.addArrangedSubview(self.identificationTitleLabel)
        self.identificationTopStackView.addArrangedSubview(self.identificationSubtitleLabel)

        self.identificationBaseView.addSubview(self.identificationBottomStackView)

        self.identificationBaseView.addSubview(self.idAddDocBaseView)

        self.idAddDocBaseView.addSubview(self.idAddDocView)

        self.idAddDocView.addSubview(self.idAddDocTitleLabel)
        self.idAddDocView.addSubview(self.idAddDocIconImageView)

        self.contentBaseView.addSubview(self.proofAddressBaseView)

        self.proofAddressBaseView.addSubview(self.proofAddressTopStackView)

        self.proofAddressTopStackView.addArrangedSubview(self.proofAddressTitleLabel)
        self.proofAddressTopStackView.addArrangedSubview(self.proofAddressSubtitleLabel)

        self.proofAddressBaseView.addSubview(self.proofAddressBottomStackView)

        self.proofAddressBaseView.addSubview(self.proofAddDocBaseView)

        self.proofAddDocBaseView.addSubview(self.proofAddDocView)

        self.proofAddDocView.addSubview(self.proofAddDocTitleLabel)
        self.proofAddDocView.addSubview(self.proofAddDocIconImageView)

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

        // Identification Card
        NSLayoutConstraint.activate([
            self.identificationBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.identificationBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.identificationBaseView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 20),

            self.identificationTopStackView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor, constant: 14),
            self.identificationTopStackView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor, constant: -14),
            self.identificationTopStackView.topAnchor.constraint(equalTo: self.identificationBaseView.topAnchor, constant: 20),

            self.identificationBottomStackView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor, constant: 14),
            self.identificationBottomStackView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor, constant: -14),
            self.identificationBottomStackView.topAnchor.constraint(equalTo: self.identificationTopStackView.bottomAnchor, constant: 5),

            self.idAddDocBaseView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor, constant: 14),
            self.idAddDocBaseView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor, constant: -14),
            self.idAddDocBaseView.topAnchor.constraint(equalTo: self.identificationBottomStackView.bottomAnchor, constant: 5),
            self.idAddDocBaseView.heightAnchor.constraint(equalToConstant: 30),

            self.idAddDocView.centerXAnchor.constraint(equalTo: self.idAddDocBaseView.centerXAnchor),
            self.idAddDocView.bottomAnchor.constraint(equalTo: self.idAddDocBaseView.bottomAnchor),

            self.idAddDocTitleLabel.leadingAnchor.constraint(equalTo: self.idAddDocView.leadingAnchor),
            self.idAddDocTitleLabel.topAnchor.constraint(equalTo: self.idAddDocView.topAnchor, constant: 10),
            self.idAddDocTitleLabel.bottomAnchor.constraint(equalTo: self.idAddDocView.bottomAnchor, constant: -5),

            self.idAddDocIconImageView.leadingAnchor.constraint(equalTo: self.idAddDocTitleLabel.trailingAnchor, constant: 5),
            self.idAddDocIconImageView.trailingAnchor.constraint(equalTo: self.idAddDocView.trailingAnchor),
            self.idAddDocIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.idAddDocIconImageView.heightAnchor.constraint(equalTo: self.idAddDocIconImageView.widthAnchor),
            self.idAddDocIconImageView.centerYAnchor.constraint(equalTo: self.idAddDocTitleLabel.centerYAnchor)

        ])

        // Proof Address
        NSLayoutConstraint.activate([
            self.proofAddressBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.proofAddressBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.proofAddressBaseView.topAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: 20),
            self.proofAddressBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),

            self.proofAddressTopStackView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddressTopStackView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddressTopStackView.topAnchor.constraint(equalTo: self.proofAddressBaseView.topAnchor, constant: 20),

            self.proofAddressBottomStackView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddressBottomStackView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddressBottomStackView.topAnchor.constraint(equalTo: self.proofAddressTopStackView.bottomAnchor, constant: 5),

            self.proofAddDocBaseView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddDocBaseView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddDocBaseView.topAnchor.constraint(equalTo: self.proofAddressBottomStackView.bottomAnchor, constant: 5),
            self.proofAddDocBaseView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20),
            self.proofAddDocBaseView.heightAnchor.constraint(equalToConstant: 30),

            self.proofAddDocView.centerXAnchor.constraint(equalTo: self.proofAddDocBaseView.centerXAnchor),
            self.proofAddDocView.bottomAnchor.constraint(equalTo: self.proofAddDocBaseView.bottomAnchor),

            self.proofAddDocTitleLabel.leadingAnchor.constraint(equalTo: self.proofAddDocView.leadingAnchor),
            self.proofAddDocTitleLabel.topAnchor.constraint(equalTo: self.proofAddDocView.topAnchor, constant: 10),
            self.proofAddDocTitleLabel.bottomAnchor.constraint(equalTo: self.proofAddDocView.bottomAnchor, constant: -5),

            self.proofAddDocIconImageView.leadingAnchor.constraint(equalTo: self.proofAddDocTitleLabel.trailingAnchor, constant: 5),
            self.proofAddDocIconImageView.trailingAnchor.constraint(equalTo: self.proofAddDocView.trailingAnchor),
            self.proofAddDocIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.proofAddDocIconImageView.heightAnchor.constraint(equalTo: self.proofAddDocIconImageView.widthAnchor),
            self.proofAddDocIconImageView.centerYAnchor.constraint(equalTo: self.proofAddDocTitleLabel.centerYAnchor)
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

        self.idBottomStackViewBottomConstraint = self.identificationBottomStackView.bottomAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: -20)
        self.idBottomStackViewBottomConstraint.isActive = false

        self.idAddDocBottomConstraint = self.idAddDocBaseView.bottomAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: -20)
        self.idAddDocBottomConstraint.isActive = true

        self.proofBottomStackViewBottomConstraint = self.proofAddressBottomStackView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20)
        self.proofBottomStackViewBottomConstraint.isActive = false

        self.proofAddDocBottomConstraint = self.proofAddDocBaseView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20)
        self.proofAddDocBottomConstraint.isActive = true
    }
}
