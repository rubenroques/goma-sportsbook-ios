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
    let supportedTypes = ["com.apple.iwork.pages.pages",
                          "com.apple.iwork.numbers.numbers",
                          "com.apple.iwork.keynote.key",
                          "public.image",
                          "com.apple.application",
                          "public.item",
                          "public.data",
                          "public.content",
                          "public.audiovisual-content",
                          "public.movie",
                          "public.audiovisual-content",
                          "public.video", "public.audio",
                          "public.text", "public.data",
                          "public.zip-archive",
                          "com.pkware.zip-archive",
                          "public.composite-content",
                          "public.text"]

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isFileUploaded: CurrentValueSubject<Bool, Never> = .init(false)

    var documentTypeCode: DocumentTypeCode

    var shouldShowAlert: ((AlertType, String) -> Void)?
    var shouldShowSuccessScreen: (() -> Void)?

    init(documentTypeCode: DocumentTypeCode) {
        self.documentTypeCode = documentTypeCode
    }

    func addPaymentInformation(rib: String) {

        self.isLoadingPublisher.send(true)

        let fieldsInfo = """
                        {
                        "IBAN":"\(rib)"
                        }
                        """

        Env.servicesProvider.addPaymentInformation(type: "BANK", fields: fieldsInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("ADD PAYMENT ERROR: \(error)")
                    self?.shouldShowAlert?(.error, localized("upload_iban_error_message"))
                    self?.isLoadingPublisher.send(false)
                }
            }, receiveValue: { [weak self] addPaymentResponse in

                self?.shouldShowAlert?(.success, localized("upload_complete_message"))
                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)
    }

    func uploadFile(documentType: String, file: Data, fileName: String) {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.uploadUserDocument(documentType: documentType, file: file, fileName: fileName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("UPLOAD FILE ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.shouldShowAlert?(.error, message)
                        self?.isFileUploaded.send(false)
                        self?.isLoadingPublisher.send(false)
                    default:
                        ()
                    }
                }
            }, receiveValue: { [weak self] uploadFileResponse in
                print("UPLOAD FILE RESPONSE: \(uploadFileResponse)")

                if self?.documentTypeCode == .ibanProof {
                    self?.isFileUploaded.send(true)
                }
                else {
                    self?.isLoadingPublisher.send(false)
                }
            })
            .store(in: &cancellables)
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

    private lazy var topSectionStackView: UIStackView = Self.createTopSectionStackView()

    private lazy var documentTypeBaseView: UIView = Self.createDocumentTypeBaseView()
    private lazy var documentTypeTitleLabel: UILabel = Self.createDocumentTypeTitleLabel()
    private lazy var documentTypeStackView: UIStackView = Self.createDocumentTypeStackView()

    private lazy var ribInputBaseView: UIView = Self.createRibInputBaseView()
    private lazy var ribInputTitleLabel: UILabel = Self.createRibInputTitleLabel()
    private lazy var ribNumberHeaderTextFieldView: HeaderTextFieldView = Self.createRibNumberHeaderTextFieldView()
    private lazy var ribInputStackView: UIStackView = Self.createRibInputStackView()
    private lazy var invalidIbanView: UIView = Self.createInvalidIbanView()
    private lazy var invalidIbanIconImageView: UIImageView = Self.createInvalidIbanIconImageView()
    private lazy var invalidIbanLabel: UILabel = Self.createInvalidIbanLabel()

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

    var selectedDocs: [DocumentTypeGroup: [SelectedDoc]] = [:]

    var currentDoc: CurrentDoc?

    var isIbanValid: CurrentValueSubject<Bool, Never> = .init(false)

    var showInvalidIban: Bool = false {
        didSet {
            self.invalidIbanView.isHidden = !showInvalidIban
        }
    }

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

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .primaryActionTriggered)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.canSendDocuments = false

        self.showInvalidIban = false

        self.setupUploadLayout()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.documentTypeBaseView.layer.cornerRadius = CornerRadius.card

        self.ribInputBaseView.layer.cornerRadius = CornerRadius.card

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

        self.topSectionStackView.backgroundColor = .clear

        self.ribInputBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.ribInputTitleLabel.textColor = UIColor.App.textPrimary

        self.ribNumberHeaderTextFieldView.setViewColor(UIColor.App.inputBackground)
        self.ribNumberHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.ribNumberHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.invalidIbanView.backgroundColor = .clear

        self.invalidIbanIconImageView.backgroundColor = .clear

        self.invalidIbanLabel.textColor = UIColor.App.inputError

        self.documentTypeBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.documentTypeTitleLabel.textColor = UIColor.App.textPrimary

        self.documentTypeStackView.backgroundColor = .clear

        self.documentUploadsStackView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.sendButton)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: Functions
    private func setupUploadLayout() {

        switch self.viewModel.documentTypeCode {
        case .identification:
            self.documentTypeBaseView.isHidden = false
            self.ribInputBaseView.isHidden = true
            self.setupDocumentTypesSelector()
        case .proofAddress:
            self.documentTypeBaseView.isHidden = true
            self.ribInputBaseView.isHidden = true
            self.setupDocumentUploadViews(documentTypeGroups: [.proofAddress])
        case .ibanProof:
            self.documentTypeBaseView.isHidden = true
            self.ribInputBaseView.isHidden = false
            self.setupDocumentUploadViews(documentTypeGroups: [.rib])
        case .others:
            self.documentTypeBaseView.isHidden = true
            self.ribInputBaseView.isHidden = true
            self.setupDocumentUploadViews(documentTypeGroups: [.other])
        }
    }

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

            if documentTypeGroup == .identityCard ||
                documentTypeGroup == .residenceId ||
                documentTypeGroup == .drivingLicense ||
                documentTypeGroup == .passport {
                uploadDocumentsInformationView.isMultiUpload = true
            }
            else {
                uploadDocumentsInformationView.isMultiUpload = false
            }

            if self.viewModel.documentTypeCode == .identification,
               documentTypeGroup == documentTypeGroups.first {
                uploadDocumentsInformationView.isHidden = false
            }
            else {
                uploadDocumentsInformationView.isHidden = false
            }

        }

        self.setupDocumentInformationViewCallbacks()

    }

    private func setupDocumentInformationViewCallbacks() {

        for documentInformationView in self.documentUploadsInfoViews.values {

            documentInformationView.tappedFrontDocumentAction = { [weak self] documentTypeGroup in
                self?.currentDoc = CurrentDoc(documentTypeGroup: documentTypeGroup, docSide: .front)

                self?.openFile()
            }

            documentInformationView.tappedBackDocumentAction = { [weak self] documentTypeGroup in
                self?.currentDoc = CurrentDoc(documentTypeGroup: documentTypeGroup, docSide: .back)

                self?.openFile()
            }

            documentInformationView.tappedRemoveFrontDocumentAction = { [weak self] documentTypeGroup in

                if let selectedDocs = self?.selectedDocs[documentTypeGroup] {

                    let filteredSelectedDocs = selectedDocs.filter({
                        $0.docSide != .front
                    })

                    self?.selectedDocs[documentTypeGroup] = filteredSelectedDocs

                    documentInformationView.removeFrontDoc()

                    self?.checkSendDocument()
                }
            }

            documentInformationView.tappedRemoveBackDocumentAction = { [weak self] documentTypeGroup in

                if let selectedDocs = self?.selectedDocs[documentTypeGroup] {

                    let filteredSelectedDocs = selectedDocs.filter({
                        $0.docSide != .back
                    })

                    self?.selectedDocs[documentTypeGroup] = filteredSelectedDocs

                    documentInformationView.removeBackDoc()

                    self?.checkSendDocument()
                }
            }
        }

    }

    private func checkSendDocument() {

        switch self.viewModel.documentTypeCode {
        case .identification:
            ()
        case .proofAddress:
            ()
        case .ibanProof:
            if let selectedDocs = self.selectedDocs[.rib] {
                if selectedDocs.contains(where: {
                    $0.docSide == .front
                }) && self.isIbanValid.value == true {
                    self.canSendDocuments = true
                }
                else {
                    self.canSendDocuments = false
                }
            }
        case .others:
            ()
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

    private func openFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: self.viewModel.supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        self.present(documentPicker, animated: true, completion: nil)
    }

    private func setupFilePicked(fileName: String, fileData: Data) {

        if let currentDoc = self.currentDoc,
           let documentInfoView = self.documentUploadsInfoViews[currentDoc.documentTypeGroup] {

            switch currentDoc.docSide {
            case .front:
                documentInfoView.setFrontDocSelected(fileName: fileName)
                let selectedDoc = SelectedDoc(name: fileName, fileData: fileData, docSide: .front)

                if let selectedDocs = self.selectedDocs[currentDoc.documentTypeGroup] {
                    self.selectedDocs[currentDoc.documentTypeGroup]?.append(selectedDoc)
                }
                else {
                    self.selectedDocs[currentDoc.documentTypeGroup] = [selectedDoc]
                }

            case .back:
                documentInfoView.setBackDocSelected(fileName: fileName)
                let selectedDoc = SelectedDoc(name: fileName, fileData: fileData, docSide: .back)

                if let selectedDocs = self.selectedDocs[currentDoc.documentTypeGroup] {
                    self.selectedDocs[currentDoc.documentTypeGroup]?.append(selectedDoc)
                }
                else {
                    self.selectedDocs[currentDoc.documentTypeGroup] = [selectedDoc]
                }
            }

            self.checkSendDocument()
        }
    }

    private func validateIBANFormat(ibanValue: String) {

        let pattern = "^[A-Z]{2}[A-Z0-9]{14,29}$"
        if let regex = try? NSRegularExpression(pattern: pattern) {

            let range = NSRange(location: 0, length: ibanValue.utf16.count)

            if regex.firstMatch(in: ibanValue, options: [], range: range) != nil {
                self.ribNumberHeaderTextFieldView.showBorderState(state: .hidden)
                self.showInvalidIban = false
                self.isIbanValid.send(true)
            }
            else {
                self.ribNumberHeaderTextFieldView.showBorderState(state: .error)
                self.showInvalidIban = true
                self.isIbanValid.send(false)
            }
        }
    }

    private func showAlert(alertType: AlertType, text: String) {

        switch alertType {
        case .success:
            let alert = UIAlertController(title: localized("upload_complete"),
                                          message: text,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                //self?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            }))

            self.present(alert, animated: true, completion: nil)
        case .error:
            let alert = UIAlertController(title: localized("upload_error"),
                                          message: text,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

    }

    private func setupPublishers() {

        self.ribNumberHeaderTextFieldView.textPublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] textValue in
                if let textValue {

                    if textValue != "" {
                        self?.validateIBANFormat(ibanValue: textValue)
                    }
                    else {
                        self?.ribNumberHeaderTextFieldView.showBorderState(state: .hidden)
                        self?.showInvalidIban = false
                        self?.isIbanValid.send(false)
                    }

                    self?.ribInputBaseView.setNeedsLayout()
                    self?.ribInputBaseView.layoutIfNeeded()
                }
            })
            .store(in: &cancellables)

        self.isIbanValid
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isIbanValid in

                self?.checkSendDocument()
            })
            .store(in: &cancellables)
    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: ManualUploadsDocumentsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading

            })
            .store(in: &cancellables)

        viewModel.shouldShowAlert = { [weak self] alertType, text in
            self?.showAlert(alertType: alertType, text: text)
        }

        viewModel.isFileUploaded
            .sink(receiveValue: { [weak self] isFileUploaded in

                switch viewModel.documentTypeCode {
                case .ibanProof:
                    if isFileUploaded {

                        let ribNumber = self?.ribNumberHeaderTextFieldView.text ?? ""

                        self?.viewModel.addPaymentInformation(rib: ribNumber)
                    }
                default:
                    ()
                }
            })
            .store(in: &cancellables)

    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSendButton() {
        switch self.viewModel.documentTypeCode {
        case .ibanProof:
            if let currentDoc = self.currentDoc,
               let selectedDoc = self.selectedDocs[currentDoc.documentTypeGroup]?.first {

                self.viewModel.uploadFile(documentType: currentDoc.documentTypeGroup.code, file: selectedDoc.fileData, fileName: selectedDoc.name)
            }
        default:
            ()
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.ribNumberHeaderTextFieldView.resignFirstResponder()

    }
}

extension ManualUploadDocumentsViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        let fileUrl = urls[0]
        let fileName = urls[0].lastPathComponent
        var fileSize = 0.0

        do {

            let attribute = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                fileSize = size.doubleValue / 1000000.0
            }

            if fileSize > 10.0 {
                self.showSimpleAlert(title: localized("max_file_size_exceeded"), message: localized("max_file_size_exceeded_message"))
            }
            else {
                let fileData = try Data(contentsOf: fileUrl)

                self.setupFilePicked(fileName: fileName, fileData: fileData)
            }
        }
        catch {
            print("No data")
        }

    }

     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
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

    private static func createTopSectionStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createRibInputBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRibInputTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("rib_number")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }

    private static func createRibInputStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }

    private static func createRibNumberHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setPlaceholderText(localized("rib"))
        headerTextFieldView.setKeyboardType(.default)
        return headerTextFieldView
    }

    private static func createInvalidIbanView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createInvalidIbanIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "error_input_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createInvalidIbanLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("iban_invalid")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
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

        self.contentBaseView.addSubview(self.topSectionStackView)

        self.topSectionStackView.addArrangedSubview(self.documentTypeBaseView)

        self.documentTypeBaseView.addSubview(self.documentTypeTitleLabel)
        self.documentTypeBaseView.addSubview(self.documentTypeStackView)

        self.topSectionStackView.addArrangedSubview(self.ribInputBaseView)

        self.ribInputBaseView.addSubview(self.ribInputTitleLabel)
        self.ribInputBaseView.addSubview(self.ribNumberHeaderTextFieldView)
        self.ribInputBaseView.addSubview(self.ribInputStackView)

        self.ribInputStackView.addArrangedSubview(self.invalidIbanView)

        self.invalidIbanView.addSubview(self.invalidIbanIconImageView)
        self.invalidIbanView.addSubview(self.invalidIbanLabel)

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
            self.topSectionStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.topSectionStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.topSectionStackView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 20),

            self.ribInputBaseView.leadingAnchor.constraint(equalTo: self.topSectionStackView.leadingAnchor),
            self.ribInputBaseView.trailingAnchor.constraint(equalTo: self.topSectionStackView.trailingAnchor),

            self.ribInputTitleLabel.leadingAnchor.constraint(equalTo: self.ribInputBaseView.leadingAnchor, constant: 14),
            self.ribInputTitleLabel.trailingAnchor.constraint(equalTo: self.ribInputBaseView.trailingAnchor, constant: -14),
            self.ribInputTitleLabel.topAnchor.constraint(equalTo: self.ribInputBaseView.topAnchor, constant: 18),

            self.ribNumberHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.ribInputBaseView.leadingAnchor, constant: 14),
            self.ribNumberHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.ribInputBaseView.trailingAnchor, constant: -14),
            self.ribNumberHeaderTextFieldView.topAnchor.constraint(equalTo: self.ribInputTitleLabel.bottomAnchor, constant: 14),
            self.ribNumberHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.ribInputStackView.leadingAnchor.constraint(equalTo: self.ribNumberHeaderTextFieldView.leadingAnchor),
            self.ribInputStackView.trailingAnchor.constraint(equalTo: self.ribNumberHeaderTextFieldView.trailingAnchor),
            self.ribInputStackView.topAnchor.constraint(equalTo: self.ribNumberHeaderTextFieldView.bottomAnchor, constant: -12),
            self.ribInputStackView.bottomAnchor.constraint(equalTo: self.ribInputBaseView.bottomAnchor, constant: -14),

            self.invalidIbanView.leadingAnchor.constraint(equalTo: self.ribInputStackView.leadingAnchor),
            self.invalidIbanView.trailingAnchor.constraint(equalTo: self.ribInputStackView.trailingAnchor),
//            self.invalidIbanView.topAnchor.constraint(equalTo: self.ribNumberHeaderTextFieldView.bottomAnchor, constant: -12),
//            self.invalidIbanView.bottomAnchor.constraint(equalTo: self.ribInputBaseView.bottomAnchor, constant: -14),

            self.invalidIbanIconImageView.leadingAnchor.constraint(equalTo: self.invalidIbanView.leadingAnchor),
            self.invalidIbanIconImageView.topAnchor.constraint(equalTo: self.invalidIbanView.topAnchor, constant: 2),
            self.invalidIbanIconImageView.widthAnchor.constraint(equalToConstant: 22),
            self.invalidIbanIconImageView.heightAnchor.constraint(equalTo: self.invalidIbanIconImageView.widthAnchor),

            self.invalidIbanLabel.leadingAnchor.constraint(equalTo: self.invalidIbanIconImageView.trailingAnchor, constant: 4),
            self.invalidIbanLabel.topAnchor.constraint(equalTo: self.invalidIbanIconImageView.topAnchor),
            self.invalidIbanLabel.trailingAnchor.constraint(equalTo: self.invalidIbanView.trailingAnchor),
            self.invalidIbanLabel.bottomAnchor.constraint(equalTo: self.invalidIbanView.bottomAnchor, constant: -4),

            self.documentTypeBaseView.leadingAnchor.constraint(equalTo: self.topSectionStackView.leadingAnchor),
            self.documentTypeBaseView.trailingAnchor.constraint(equalTo: self.topSectionStackView.trailingAnchor),

            self.documentTypeTitleLabel.leadingAnchor.constraint(equalTo: self.documentTypeBaseView.leadingAnchor, constant: 17),
            self.documentTypeTitleLabel.trailingAnchor.constraint(equalTo: self.documentTypeBaseView.trailingAnchor, constant: -17),
            self.documentTypeTitleLabel.topAnchor.constraint(equalTo: self.documentTypeBaseView.topAnchor, constant: 19),

            self.documentTypeStackView.leadingAnchor.constraint(equalTo: self.documentTypeBaseView.leadingAnchor, constant: 17),
            self.documentTypeStackView.trailingAnchor.constraint(equalTo: self.documentTypeBaseView.trailingAnchor, constant: -17),
            self.documentTypeStackView.topAnchor.constraint(equalTo: self.documentTypeTitleLabel.bottomAnchor, constant: 20),
            self.documentTypeStackView.bottomAnchor.constraint(equalTo: self.documentTypeBaseView.bottomAnchor, constant: -20),

            self.documentUploadsStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 14),
            self.documentUploadsStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -14),
            self.documentUploadsStackView.topAnchor.constraint(equalTo: self.topSectionStackView.bottomAnchor, constant: 25),
            self.documentUploadsStackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20),
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

    }
}

enum DocSide {
    case front
    case back
}

struct SelectedDoc {
    let name: String
    let fileData: Data
    let docSide: DocSide
}

struct CurrentDoc {
    let documentTypeGroup: DocumentTypeGroup
    let docSide: DocSide
}
