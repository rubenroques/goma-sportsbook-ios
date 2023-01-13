//
//  UploadDocumentsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 12/01/2023.
//

import UIKit
import Combine

class UploadDocumentsViewModel {

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

    var selectedUploadDocumentCellId: String?

    var cachedCellViewModels: [String: UploadDocumentCellViewModel] = [:]

    var documents: [DocumentInfo] = []

    var shouldReloadData: (() -> Void)?

    init() {

        // TEST
        let documentInfo1 = DocumentInfo(id: "1", typeName: "Identification", status: .notReceived)

        let documentInfo2 = DocumentInfo(id: "2", typeName: "Proof of address", status: .inProgress, uploadedFileName: "proof_address_test.pdf")

        let documentInfo3 = DocumentInfo(id: "3", typeName: "Bank Note", status: .validated, uploadedFileName: "bank_note.pdf")

        documents.append(documentInfo1)
        documents.append(documentInfo2)
        documents.append(documentInfo3)

        self.shouldReloadData?()

    }

}

class UploadDocumentsViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    private var viewModel: UploadDocumentsViewModel

    // MARK: Public Properties
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

    var shouldUploadFile: ((String) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: UploadDocumentsViewModel) {

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

        self.tableView.register(UploadDocumentTableViewCell.self,
                                forCellReuseIdentifier: UploadDocumentTableViewCell.identifier)

        self.tableView.alwaysBounceVertical = false

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.isLoading = false

        self.bind(toViewModel: self.viewModel)

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

        self.navigationView.backgroundColor = .clear

        self.closeButton.backgroundColor = .clear

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.continueButton)

    }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: UploadDocumentsViewModel) {

        viewModel.shouldReloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func openFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: self.viewModel.supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true, completion: nil)
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }

    @objc func didTapContinueButton() {
        print("CONTINUE")
    }
}

extension UploadDocumentsViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileUrl = urls[0].lastPathComponent

        if let cellId = self.viewModel.selectedUploadDocumentCellId {

            if let cellViewModel = self.viewModel.cachedCellViewModels[cellId] {
                cellViewModel.startUpload(file: fileUrl)
            }

        }

    }

     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UploadDocumentsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueCellType(UploadDocumentTableViewCell.self),
              let documentInfo = self.viewModel.documents[safe: indexPath.row]
        else {
            fatalError()
        }
        if let cellViewModel = self.viewModel.cachedCellViewModels[documentInfo.id] {

            cell.configure(withViewModel: cellViewModel)

            cell.shouldSelectFile = { [weak self] documentId in
                self?.viewModel.selectedUploadDocumentCellId = documentId
                self?.openFile()
            }
        }
        else {
            let cellViewModel = UploadDocumentCellViewModel(documentInfo: documentInfo)

            self.viewModel.cachedCellViewModels[documentInfo.id] = cellViewModel

            cell.configure(withViewModel: cellViewModel)

            cell.shouldSelectFile = { [weak self] documentId in
                self?.viewModel.selectedUploadDocumentCellId = documentId
                self?.openFile()
            }

        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 170

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.01

    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

}

extension UploadDocumentsViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .bold, size: 30)
        titleLabel.textAlignment = .left
        titleLabel.text = localized("upload_documents")
        return titleLabel
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("continue_"), for: .normal)
        return button
    }

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createSelectFileDocumentPickerView() -> DocumentPickerView {
        let pickerView = DocumentPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
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

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.closeButton)
        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.tableView)

        self.containerView.addSubview(self.continueButton)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -30),
            self.closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 50),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),
            self.continueButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -40)
        ])

        // Tableview
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.tableView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.tableView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.tableView.bottomAnchor.constraint(equalTo: self.continueButton.topAnchor, constant: -15)
        ])

        // Loading view
        NSLayoutConstraint.activate([

            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor)
        ])

    }
}

struct DocumentInfo {
    var id: String
    var typeName: String
    var status: DocumentState
    var uploadedFileName: String?
}
