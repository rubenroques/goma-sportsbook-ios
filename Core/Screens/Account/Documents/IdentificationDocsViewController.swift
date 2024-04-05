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

class IdentificationDocsViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var identificationBaseView: UIView = Self.createIdentificationBaseView()
    private lazy var identificationDisabledView: UIView = Self.createIdentificationDisabledView()
    private lazy var identificationTopStackView: UIStackView = Self.createIdentificationTopStackView()
    private lazy var identificationTitleLabel: UILabel = Self.createIdentificationTitleLabel()
    private lazy var identificationSubtitleLabel: UILabel = Self.createIdentificationSubtitleLabel()
    private lazy var identificationBottomStackView: UIStackView = Self.createIdentificationBottomStackView()
    private lazy var idAddDocBaseView: UIView = Self.createIdAddDocBaseView()
    private lazy var idAddDocView: UIView = Self.createIdAddDocView()
    private lazy var idAddDocTitleLabel: UILabel = Self.createIdAddDocTitleLabel()
    private lazy var idAddDocIconImageView: UIImageView = Self.createIdAddDocIconImageView()

    private lazy var idWarningView: BetslipErrorView = Self.createIdWarningView()

    private lazy var idBottomStackViewBottomConstraint: NSLayoutConstraint = Self.createIdBottomStackViewBottomConstraint()
    private lazy var idAddDocBottomConstraint: NSLayoutConstraint = Self.createIdAddDocBottomConstraint()
    private lazy var idWarningBottomConstraint: NSLayoutConstraint = Self.createIdWarningBottomConstraint()

    private lazy var proofAddressBaseView: UIView = Self.createProofAddressBaseView()
    private lazy var proofAddressDisabledView: UIView = Self.createProofAddressDisabledView()
    private lazy var proofAddressTopStackView: UIStackView = Self.createProofAddressTopStackView()
    private lazy var proofAddressTitleLabel: UILabel = Self.createProofAddressTitleLabel()
    private lazy var proofAddressSubtitleLabel: UILabel = Self.createProofAddressSubtitleLabel()
    private lazy var proofAddressBottomStackView: UIStackView = Self.createProofAddressBottomStackView()
    private lazy var proofAddDocBaseView: UIView = Self.createProofAddDocBaseView()
    private lazy var proofAddDocView: UIView = Self.createProofAddDocView()
    private lazy var proofAddDocTitleLabel: UILabel = Self.createProofAddDocTitleLabel()
    private lazy var proofAddDocIconImageView: UIImageView = Self.createProofAddDocIconImageView()

    private lazy var proofWarningView: BetslipErrorView = Self.createIdWarningView()

    private lazy var proofBottomStackViewBottomConstraint: NSLayoutConstraint = Self.createProofBottomStackViewBottomConstraint()
    private lazy var proofAddDocBottomConstraint: NSLayoutConstraint = Self.createProofAddDocBottomConstraint()
    private lazy var proofWarningBottomConstraint: NSLayoutConstraint = Self.createProofWarningBottomConstraint()

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

    var showIdentityWarning: Bool = false {
        didSet {
            self.idWarningView.isHidden = !showIdentityWarning
            self.canAddIdentificationDocs = !showIdentityWarning

            self.idBottomStackViewBottomConstraint.isActive = !showIdentityWarning
            self.idWarningBottomConstraint.isActive = showIdentityWarning

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

    var showProofWarning: Bool = false {
        didSet {
            self.proofWarningView.isHidden = !showProofWarning
            self.canAddProofDocs = !showProofWarning

            self.proofBottomStackViewBottomConstraint.isActive = !showProofWarning
            self.proofWarningBottomConstraint.isActive = showProofWarning

            self.proofAddressBaseView.setNeedsLayout()
            self.proofAddressBaseView.layoutIfNeeded()
        }
    }
    
    var isIdentityDisabled: Bool = true {
        didSet {
            self.identificationDisabledView.isHidden = !isIdentityDisabled
            self.identificationBaseView.isUserInteractionEnabled = !isIdentityDisabled
        }
    }

    var isProofOfAddressDisabled: Bool = true {
        didSet {
            self.proofAddressDisabledView.isHidden = !isProofOfAddressDisabled
            self.proofAddressBaseView.isUserInteractionEnabled = !isProofOfAddressDisabled
        }
    }

    var totalIdentificationTriesCount: Int = 0
    var totalProofAddressTriesCount: Int = 0

    var hasShownContinueProcessAlert: Bool = false

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

        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.identificationBaseView.layer.cornerRadius = CornerRadius.card
        
        self.identificationDisabledView.layer.cornerRadius = CornerRadius.card

        self.proofAddressBaseView.layer.cornerRadius = CornerRadius.card

        self.proofAddressDisabledView.layer.cornerRadius = CornerRadius.card
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
        
        self.identificationDisabledView.backgroundColor = UIColor.App.backgroundSecondary.withAlphaComponent(0.7)

        self.identificationTopStackView.backgroundColor = .clear

        self.identificationTitleLabel.textColor = UIColor.App.textPrimary

        self.identificationSubtitleLabel.textColor = UIColor.App.textSecondary

        self.idAddDocBaseView.backgroundColor = .clear

        self.idAddDocView.backgroundColor = .clear

        self.idAddDocTitleLabel.textColor = UIColor.App.highlightPrimary

        self.idAddDocIconImageView.backgroundColor = .clear
        self.idAddDocIconImageView.setTintColor(color: UIColor.App.highlightPrimary)

        self.proofAddressBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.proofAddressDisabledView.backgroundColor = UIColor.App.backgroundSecondary.withAlphaComponent(0.7)

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
                    
                    if viewModel.hasSanction {
                        self?.isIdentityDisabled = true
                    }
                    else {
                        self?.isIdentityDisabled = false
                    }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Action
    @objc func didTapIdAddDoc() {

        if self.totalIdentificationTriesCount <= 10 {
            self.viewModel.generateDocumentTypeToken(docType: "IDENTITY_CARD")

        }
        else {
            
            let multipleFilesRequired = self.viewModel.requiredDocumentTypes.filter({
                $0.documentTypeGroup == .identityCard ||
                $0.documentTypeGroup == .passport ||
                $0.documentTypeGroup == .drivingLicense ||
                $0.documentTypeGroup == .residenceId
            }).first?.multipleFileRequired
            
            let manualUploadDocumentViewModel = ManualUploadsDocumentsViewModel(documentTypeCode: .identification)
            
            manualUploadDocumentViewModel.isMultipleFileRequired = multipleFilesRequired ?? false

            let manualUploadDocumentViewController = ManualUploadDocumentsViewController(viewModel: manualUploadDocumentViewModel)

            manualUploadDocumentViewController.shouldRefreshDocuments = { [weak self] in
                self?.viewModel.refreshDocuments()
            }

            self.navigationController?.pushViewController(manualUploadDocumentViewController, animated: true)
        }

    }

    @objc func didTapProofAddDoc() {

        if self.totalProofAddressTriesCount <= 10 {

            self.viewModel.generateDocumentTypeToken(docType: "POA_CARD")

        }
        else {
            let manualUploadDocumentViewModel = ManualUploadsDocumentsViewModel(documentTypeCode: .proofAddress)

            let manualUploadDocumentViewController = ManualUploadDocumentsViewController(viewModel: manualUploadDocumentViewModel)

            manualUploadDocumentViewController.shouldRefreshDocuments = { [weak self] in
                self?.viewModel.refreshDocuments()
            }

            self.navigationController?.pushViewController(manualUploadDocumentViewController, animated: true)
        }
    }

    @objc func handleRefreshControl() {

        self.viewModel.refreshDocuments()

       DispatchQueue.main.async {
          self.scrollView.refreshControl?.endRefreshing()
       }
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

            self.viewModel.checkDocumentationData()
        }

        sdk.onEvent { (sdk, event) in

            switch event.eventType {

            case .applicantLoaded:
                if let event = event as? SNSEventApplicantLoaded {
                    print("onEvent: Applicant [\(event.applicantId)] has been loaded")
                }

            case .stepInitiated:
                if let event = event as? SNSEventStepInitiated {
                    print("onEvent: Step \(event.idDocSetType) has been initiated")
                }

            case .stepCompleted:
                if let event = event as? SNSEventStepCompleted {
                    print("onEvent: Step \(event.idDocSetType) has been \(event.isCancelled ? "cancelled" : "fulfilled")")

                    if event.idDocSetType == "IDENTITY" && !event.isCancelled {

                        sdk.mainVC.dismiss(animated: true)

                        self.viewModel.checkDocumentationData()

                    }

                }

            case .analytics:
                if let event = event as? SNSEventAnalytics {
                    print("onEvent: Analytics event [\(event.eventName)] has occured with payload=\(event.eventPayload ?? [:])")
                }

            @unknown default:
                print("onEvent: eventType=\(event.description(for: event.eventType)) payload=\(event.payload)")
            }

        }

        sdk.onStatusDidChange { (sdk, prevStatus) in

            print("onStatusDidChange: [\(sdk.description(for: prevStatus))] -> [\(sdk.description(for: sdk.status))]")

            switch sdk.status {

            case .ready:
                // Technically .ready couldn't ever be passed here, since the callback has been set after `status` became .ready
                break

            case .failed:
                print("failReason: [\(sdk.description(for: sdk.failReason))] - \(sdk.verboseStatus)")

            case .initial:
                print("No verification steps are passed yet")

            case .incomplete:
                print("Some but not all of the verification steps have been passed over")

            case .pending:
                print("Verification is pending")

            case .temporarilyDeclined:
                print("Applicant has been temporarily declined")

            case .finallyRejected:
                print("Applicant has been finally rejected")
                self.viewModel.checkDocumentationData()

            case .approved:
                print("Applicant has been approved")
                self.viewModel.checkDocumentationData()

            case .actionCompleted:
                print("Applicant action has been completed")
            }
        }

        self.present(sdk.mainVC, animated: true, completion: nil)

    }
    private func setupDocumentStateViews(documentsInfo: [DocumentInfo]) {

        self.identificationBottomStackView.removeAllArrangedSubviews()
        self.proofAddressBottomStackView.removeAllArrangedSubviews()

        let identityDocuments = self.viewModel.identificationDocuments

        var mostRecentIdentityDocument: DocumentFileInfo?
        var sumsubIdentityDocument: DocumentFileInfo?
        var hasApprovedIdentityDocuments = false

        for identityDocument in identityDocuments {

            for (index, identityFileInfo) in identityDocument.uploadedFiles.enumerated() {
                
                let documentStateView = DocumentStateView()

                documentStateView.configure(documentFileInfo: identityFileInfo)

//                if index != identityDocument.uploadedFiles.count - 1 {
//                    documentStateView.hasSeparator = true
//                }
//                else {
//                    documentStateView.hasSeparator = false
//                }

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

                if identityFileInfo.status == .approved {
                    hasApprovedIdentityDocuments = true
                }

                if let totalRetries = identityFileInfo.totalRetries {
                    self.totalIdentificationTriesCount = totalRetries
                    sumsubIdentityDocument = identityFileInfo
                }
            }

        }

        if let sumsubDoc = sumsubIdentityDocument {

            let retries = self.totalIdentificationTriesCount
            let canRetry = sumsubDoc.retry ?? true
            let moderationComment = sumsubDoc.moderationComment

            if sumsubDoc.status == .rejected && moderationComment != nil && retries < 11 && hasApprovedIdentityDocuments {
                self.idWarningView.setDescription(description: moderationComment ?? localized("error"))
                self.showIdentityWarning = true
            }
            else if retries > 10 {
                if hasApprovedIdentityDocuments {
                    self.canAddIdentificationDocs = false
                    self.isProofOfAddressDisabled = false
                }
                else {
                    self.canAddIdentificationDocs = true
                    self.isProofOfAddressDisabled = true
                }
            }
            else {
                if canRetry {
                    self.canAddIdentificationDocs = true
                    self.isProofOfAddressDisabled = true
                }
                // If identity doc is not approved and retry is set to false
                else if !canRetry && !hasApprovedIdentityDocuments {
                    self.canAddIdentificationDocs = false
                    self.isProofOfAddressDisabled = true
                }
                else {
                    self.canAddIdentificationDocs = false
                    self.isProofOfAddressDisabled = false
                }

            }

        }
        else {
            if hasApprovedIdentityDocuments {
                self.canAddIdentificationDocs = false
                self.isProofOfAddressDisabled = false
            }
            else {
                self.canAddIdentificationDocs = true
                self.isProofOfAddressDisabled = true
            }
        }

//        if let currentDocument = mostRecentIdentityDocument {
//
//            if let canRetry = currentDocument.retry {
//                self.canAddIdentificationDocs = canRetry
//
//                if !canRetry && currentDocument.status == .approved {
//                    self.isProofOfAddressDisabled = false
//                }
//                else {
//                    self.isProofOfAddressDisabled = true
//                }
//            }
//            else {
//                if currentDocument.status == .approved {
//                    self.canAddIdentificationDocs = false
//                    self.isProofOfAddressDisabled = false
//                }
//                else if currentDocument.status == .pendingApproved {
//                    self.canAddIdentificationDocs = false
//                    self.isProofOfAddressDisabled = true
//                }
//                else {
//                    self.canAddIdentificationDocs = true
//                    self.isProofOfAddressDisabled = true
//                }
//            }
//
//        }
//        else {
//            self.isProofOfAddressDisabled = true
//        }

        if let proofAddressFilesInfo = self.viewModel.proofAddressDocuments.first?.uploadedFiles {

            var mostRecentProofDocument: DocumentFileInfo?
            var sumsubProofDocument: DocumentFileInfo?
            var hasApprovedProofDocuments = false

            for (index, proofFileInfo) in proofAddressFilesInfo.enumerated() {

                let documentStateView = DocumentStateView()

                documentStateView.configure(documentFileInfo: proofFileInfo)

//                if index != proofAddressFilesInfo.count - 1 {
//                    documentStateView.hasSeparator = true
//                }
//                else {
//                    documentStateView.hasSeparator = false
//                }

                self.proofAddressBottomStackView.addArrangedSubview(documentStateView)

                if proofAddressFilesInfo.contains(where: {
                    $0.id == "POA"
                }) {
                    if proofFileInfo.id == "POA" {
                        mostRecentProofDocument = proofFileInfo
                    }
                }
                else {
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

                    if proofFileInfo.status == .approved {
                        hasApprovedProofDocuments = true
                    }

                    if let totalRetries = proofFileInfo.totalRetries {
                        if self.totalIdentificationTriesCount >= 11 {
                            self.totalProofAddressTriesCount = self.totalIdentificationTriesCount
                        }
                        else {
                            self.totalProofAddressTriesCount = totalRetries

                        }
                        sumsubProofDocument = proofFileInfo
                    }
                }
            }

            if let sumsubDoc = sumsubProofDocument {

                let retries = self.totalProofAddressTriesCount
                let canRetry = sumsubDoc.retry ?? true
                let moderationComment = sumsubDoc.moderationComment

                if sumsubDoc.status == .rejected && moderationComment != nil && retries < 11 && hasApprovedProofDocuments {
                    self.proofWarningView.setDescription(description: moderationComment ?? localized("error"))
                    self.showProofWarning = true
                }
                else if retries > 10 {
                    if hasApprovedProofDocuments {
                        self.canAddProofDocs = false
                    }
                    else {
                        self.canAddProofDocs = true
                    }
                }
                else {
                    if canRetry {
                        self.canAddProofDocs = true
                    }
                    else {
                        self.canAddProofDocs = false
                    }

                }
            }
            else {
                if hasApprovedProofDocuments {
                    self.canAddProofDocs = false
                }
                else {
                    self.canAddProofDocs = true
                }
            }

//            if let currentDocument = mostRecentProofDocument {
//
//                if let canRetry = currentDocument.retry {
//                    self.canAddProofDocs = canRetry
//                }
//                else {
//                    if currentDocument.status == .approved || currentDocument.status == .pendingApproved {
//                        self.canAddProofDocs = false
//                    }
//                    else {
//                        self.canAddProofDocs = true
//                    }
//                }
//
//            }

        }

        // Check to show continue process alert
        if !self.isProofOfAddressDisabled,
           let uploadedProofAddressDocs = self.viewModel.proofAddressDocuments.first?.uploadedFiles,
           uploadedProofAddressDocs.isEmpty,
           !self.hasShownContinueProcessAlert {

            if let currentDocumentLevelStatus = self.viewModel.currentDocumentLevelStatus {

                if (currentDocumentLevelStatus.levelName == .identificationLevel && currentDocumentLevelStatus.status == .completed) || currentDocumentLevelStatus.levelName == .poaLevel {

                    self.showContinueProcessAlert()

                }
            }

        }

    }

    private func showContinueProcessAlert() {

        let alert = UIAlertController(title: localized("identity_docs_approved_title"),
                                      message: localized("identity_docs_approved_text"),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            self?.viewModel.generateDocumentTypeToken(docType: "POA_CARD")

            self?.hasShownContinueProcessAlert = true

        }))

        self.present(alert, animated: true, completion: nil)

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
    
    private static func createIdentificationDisabledView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIdentificationTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
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

    private static func createIdWarningView() -> BetslipErrorView {
        let errorView = BetslipErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.setDescription(description: localized("error"))
        errorView.isHidden = true
        return errorView
    }

    private static func createProofAddressBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProofAddressDisabledView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProofAddressTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
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

    private static func createProofWarningView() -> BetslipErrorView {
        let errorView = BetslipErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.setDescription(description: localized("error"))
        errorView.isHidden = true
        return errorView
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

    private static func createIdWarningBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createProofWarningBottomConstraint() -> NSLayoutConstraint {
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

        self.identificationBaseView.addSubview(self.idWarningView)
        
        self.identificationBaseView.addSubview(self.identificationDisabledView)

        self.contentBaseView.addSubview(self.proofAddressBaseView)

        self.proofAddressBaseView.addSubview(self.proofAddressTopStackView)

        self.proofAddressTopStackView.addArrangedSubview(self.proofAddressTitleLabel)
        self.proofAddressTopStackView.addArrangedSubview(self.proofAddressSubtitleLabel)

        self.proofAddressBaseView.addSubview(self.proofAddressBottomStackView)

        self.proofAddressBaseView.addSubview(self.proofAddDocBaseView)

        self.proofAddDocBaseView.addSubview(self.proofAddDocView)

        self.proofAddDocView.addSubview(self.proofAddDocTitleLabel)
        self.proofAddDocView.addSubview(self.proofAddDocIconImageView)

        self.proofAddressBaseView.addSubview(self.proofWarningView)

        self.proofAddressBaseView.addSubview(self.proofAddressDisabledView)

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
            
            self.identificationDisabledView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor),
            self.identificationDisabledView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor),
            self.identificationDisabledView.topAnchor.constraint(equalTo: self.identificationBaseView.topAnchor),
            self.identificationDisabledView.bottomAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor),

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
            self.idAddDocIconImageView.centerYAnchor.constraint(equalTo: self.idAddDocTitleLabel.centerYAnchor),

            self.idWarningView.leadingAnchor.constraint(equalTo: self.identificationBaseView.leadingAnchor),
            self.idWarningView.trailingAnchor.constraint(equalTo: self.identificationBaseView.trailingAnchor),
            self.idWarningView.topAnchor.constraint(equalTo: self.identificationBottomStackView.bottomAnchor, constant: 5)

        ])

        // Proof Address
        NSLayoutConstraint.activate([
            self.proofAddressBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.proofAddressBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.proofAddressBaseView.topAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: 20),
            self.proofAddressBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),

            self.proofAddressDisabledView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor),
            self.proofAddressDisabledView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor),
            self.proofAddressDisabledView.topAnchor.constraint(equalTo: self.proofAddressBaseView.topAnchor),
            self.proofAddressDisabledView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor),

            self.proofAddressTopStackView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddressTopStackView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddressTopStackView.topAnchor.constraint(equalTo: self.proofAddressBaseView.topAnchor, constant: 20),

            self.proofAddressBottomStackView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddressBottomStackView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddressBottomStackView.topAnchor.constraint(equalTo: self.proofAddressTopStackView.bottomAnchor, constant: 5),

            self.proofAddDocBaseView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor, constant: 14),
            self.proofAddDocBaseView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor, constant: -14),
            self.proofAddDocBaseView.topAnchor.constraint(equalTo: self.proofAddressBottomStackView.bottomAnchor, constant: 5),
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
            self.proofAddDocIconImageView.centerYAnchor.constraint(equalTo: self.proofAddDocTitleLabel.centerYAnchor),

            self.proofWarningView.leadingAnchor.constraint(equalTo: self.proofAddressBaseView.leadingAnchor),
            self.proofWarningView.trailingAnchor.constraint(equalTo: self.proofAddressBaseView.trailingAnchor),
            self.proofWarningView.topAnchor.constraint(equalTo: self.proofAddressBottomStackView.bottomAnchor, constant: 5),
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

        self.idWarningBottomConstraint = self.idWarningView.bottomAnchor.constraint(equalTo: self.identificationBaseView.bottomAnchor, constant: -20)
        self.idWarningBottomConstraint.isActive = false

        self.proofBottomStackViewBottomConstraint = self.proofAddressBottomStackView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20)
        self.proofBottomStackViewBottomConstraint.isActive = false

        self.proofAddDocBottomConstraint = self.proofAddDocBaseView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20)
        self.proofAddDocBottomConstraint.isActive = true

        self.proofWarningBottomConstraint = self.proofWarningView.bottomAnchor.constraint(equalTo: self.proofAddressBaseView.bottomAnchor, constant: -20)
        self.proofWarningBottomConstraint.isActive = false
    }
}
