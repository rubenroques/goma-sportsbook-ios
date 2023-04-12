//
//  IBANProofViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/03/2023.
//

import UIKit
import Combine
import ServicesProvider

class IBANProofViewController: UIViewController {

    // MARK: Private Properties
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var ibanHeaderTextFieldView: HeaderTextFieldView = Self.createIbanHeaderTextFieldView()
    private lazy var invalidIbanView: UIView = Self.createInvalidIbanView()
    private lazy var invalidIbanIconImageView: UIImageView = Self.createInvalidIbanIconImageView()
    private lazy var invalidIbanLabel: UILabel = Self.createInvalidIbanLabel()
    private lazy var tableView: UITableView = Self.createTableView()
    private lazy var nextButton: UIButton = Self.createNextButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: IBANProofViewModel

    var isDocumentUploaded: CurrentValueSubject<Bool, Never> = .init(false)
    var isIbanValid: CurrentValueSubject<Bool, Never> = .init(false)

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

    var showInvalidIban: Bool = false {
        didSet {
            self.invalidIbanView.isHidden = !showInvalidIban

        }
    }

    // MARK: Lifetime and Cycle
    init(viewModel: IBANProofViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("IBANProofViewController deinit called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)

        self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .primaryActionTriggered)
        self.nextButton.isEnabled = false

        self.bind(toViewModel: self.viewModel)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(UploadDocumentTableViewCell.self,
                                forCellReuseIdentifier: UploadDocumentTableViewCell.identifier)

        self.tableView.alwaysBounceVertical = false

        self.showInvalidIban = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.cancelButton.tintColor = UIColor.App.highlightPrimary
        self.cancelButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.navigationTitleLabel.textColor = UIColor.App.textPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.ibanHeaderTextFieldView.backgroundColor = .clear
        self.ibanHeaderTextFieldView.setPlaceholderColor(UIColor.App.textSecondary)
        self.ibanHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)

        self.invalidIbanView.backgroundColor = .clear

        self.invalidIbanIconImageView.backgroundColor = .clear

        self.invalidIbanLabel.textColor = UIColor.App.inputError

        self.tableView.backgroundColor = UIColor.App.backgroundPrimary

        self.nextButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.nextButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.nextButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)
        self.nextButton.layer.cornerRadius = CornerRadius.button
        self.nextButton.layer.masksToBounds = true
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: IBANProofViewModel) {

        viewModel.shouldReloadData = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.showErrorAlertTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] errorAlertType in

                if let errorAlertType = errorAlertType {
                    self?.showErrorAlert(errorType: errorAlertType)
                }

            })
            .store(in: &cancellables)

        self.ibanHeaderTextFieldView.textPublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] textValue in
                if let textValue {

                    if textValue != "" {
                        self?.validateIBANFormat(ibanValue: textValue)
                    }
                    else {
                        self?.ibanHeaderTextFieldView.showBorderState(state: .hidden)
                        self?.showInvalidIban = false
                        self?.isIbanValid.send(false)
                    }
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.isDocumentUploaded, self.isIbanValid)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isDocumentUploaded, isIbanValid in

                if isDocumentUploaded && isIbanValid {
                    self?.nextButton.isEnabled = true
                }
                else {
                    self?.nextButton.isEnabled = false
                }
            })
            .store(in: &cancellables)


        viewModel.shouldShowAlert = { [weak self] alertType, text in
            self?.showAlert(alertType: alertType, text: text)
        }
    }

    private func showAlert(alertType: AlertType, text: String) {

        switch alertType {
        case .success:
            let alert = UIAlertController(title: localized("iban_success"),
                                          message: text,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                self?.dismiss(animated: true)
            }))

            self.present(alert, animated: true, completion: nil)
        case .error:
            let alert = UIAlertController(title: localized("iban_error"),
                                          message: text,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

    }

    private func validateIBANFormat(ibanValue: String) {

        let pattern = "^[A-Z]{2}[0-9]{14,29}$"
        if let regex = try? NSRegularExpression(pattern: pattern) {

            let range = NSRange(location: 0, length: ibanValue.utf16.count)

            if regex.firstMatch(in: ibanValue, options: [], range: range) != nil {
                self.ibanHeaderTextFieldView.showBorderState(state: .hidden)
                self.showInvalidIban = false
                self.isIbanValid.send(true)
            }
            else {
                self.ibanHeaderTextFieldView.showBorderState(state: .error)
                self.showInvalidIban = true
                self.isIbanValid.send(false)
            }
        }
    }

    private func showErrorAlert(errorType: BalanceErrorType) {
        var errorTitle = ""
        var errorMessage = ""

        switch errorType {
        case .wallet:
            errorTitle = localized("wallet_error")
            errorMessage = localized("wallet_error_message")
        case .withdraw:
            errorTitle = localized("withdraw_error")
            errorMessage = localized("withdraw_error_message")
        case .error(let message):
            errorTitle = localized("withdrawal_error")
            errorMessage = message
        default:
            ()
        }

        let alert = UIAlertController(title: errorTitle,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showSuccessScreen() {

        let withdrawSuccessViewController = WithdrawSuccessViewController()

        withdrawSuccessViewController.configureInfo(title: localized("withdrawal_request_sent_title"), message: localized("withdrawal_request_sent_text"))

        self.navigationController?.pushViewController(withdrawSuccessViewController, animated: true)

    }

    private func openFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: self.viewModel.supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true, completion: nil)
    }

    private func reloadData() {
        self.tableView.beginUpdates()
        self.tableView.setNeedsDisplay()
        self.tableView.endUpdates()

    }

    // MARK: Actions
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }

    @objc private func didTapNextButton() {

        let iban = self.ibanHeaderTextFieldView.text

        self.viewModel.addPaymentInformation(iban: iban)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.ibanHeaderTextFieldView.resignFirstResponder()

    }
}

extension IBANProofViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
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

                if let cellId = self.viewModel.selectedUploadDocumentCellId {

                    if let cellViewModel = self.viewModel.cachedCellViewModels[cellId] {
                        cellViewModel.startUpload(fileName: fileName, fileData: fileData)
                    }

                }
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

extension IBANProofViewController: UITableViewDataSource, UITableViewDelegate {

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

            cell.isSingleDocument = true

            cell.shouldSelectFile = { [weak self] documentId in
                self?.viewModel.selectedUploadDocumentCellId = documentId
                self?.openFile()
            }

            cell.finishedUploading = { [weak self] in

                self?.reloadData()
            }

            cell.shouldRedrawViews = { [weak self] in

                self?.reloadData()
            }

            cell.shouldShowUploadingError = { [weak self] message in
                self?.showSimpleAlert(title: "Upload Error", message: message)
            }
        }
        else {
            let cellViewModel = UploadDocumentCellViewModel(documentInfo: documentInfo)

            self.viewModel.cachedCellViewModels[documentInfo.id] = cellViewModel

            cell.configure(withViewModel: cellViewModel)

            cell.isSingleDocument = true

            cell.shouldSelectFile = { [weak self] documentId in
                self?.viewModel.selectedUploadDocumentCellId = documentId
                self?.openFile()
            }

            cell.finishedUploading = { [weak self] in

                self?.isDocumentUploaded.send(true)
                self?.reloadData()
            }

            cell.shouldRedrawViews = { [weak self] in

                self?.reloadData()
            }

            cell.shouldShowUploadingError = { [weak self] message in
                self?.showSimpleAlert(title: "Upload Error", message: message)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return 300

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

//
// MARK: Subviews initialization and setup
//
extension IBANProofViewController {

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

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        return button
    }

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("withdraw")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("iban_confirm_message")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createIbanHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setPlaceholderText(localized("iban"))
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

    private static func createTableView() -> UITableView {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }

    private static func createNextButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("next"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        StyleHelper.styleButton(button: button)
        return button
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
        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.navigationView)

        self.navigationView.addSubview(self.navigationTitleLabel)
        self.navigationView.addSubview(self.cancelButton)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.ibanHeaderTextFieldView)

        self.containerView.addSubview(self.invalidIbanView)

        self.invalidIbanView.addSubview(self.invalidIbanIconImageView)
        self.invalidIbanView.addSubview(self.invalidIbanLabel)

        self.containerView.addSubview(self.tableView)

        self.containerView.addSubview(self.nextButton)

        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Navigation view
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.cancelButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -30),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 44),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 40),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -40),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

        ])

        // Content
        NSLayoutConstraint.activate([

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 38),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -38),
            self.titleLabel.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 40),

            self.ibanHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.ibanHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.ibanHeaderTextFieldView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 50),
            self.ibanHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.invalidIbanView.leadingAnchor.constraint(equalTo: self.ibanHeaderTextFieldView.leadingAnchor),
            self.invalidIbanView.trailingAnchor.constraint(equalTo: self.ibanHeaderTextFieldView.trailingAnchor),
            self.invalidIbanView.topAnchor.constraint(equalTo: self.ibanHeaderTextFieldView.bottomAnchor, constant: -12),

            self.invalidIbanIconImageView.leadingAnchor.constraint(equalTo: self.invalidIbanView.leadingAnchor),
            self.invalidIbanIconImageView.topAnchor.constraint(equalTo: self.invalidIbanView.topAnchor, constant: 2),
            self.invalidIbanIconImageView.widthAnchor.constraint(equalToConstant: 22),
            self.invalidIbanIconImageView.heightAnchor.constraint(equalTo: self.invalidIbanIconImageView.widthAnchor),

            self.invalidIbanLabel.leadingAnchor.constraint(equalTo: self.invalidIbanIconImageView.trailingAnchor, constant: 4),
            self.invalidIbanLabel.topAnchor.constraint(equalTo: self.invalidIbanIconImageView.topAnchor),
            self.invalidIbanLabel.trailingAnchor.constraint(equalTo: self.invalidIbanView.trailingAnchor),
            self.invalidIbanLabel.bottomAnchor.constraint(equalTo: self.invalidIbanView.bottomAnchor, constant: -4),

            self.tableView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.tableView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.tableView.topAnchor.constraint(equalTo: self.ibanHeaderTextFieldView.bottomAnchor, constant: 30),
            self.tableView.bottomAnchor.constraint(equalTo: self.nextButton.topAnchor, constant: -15),

            self.nextButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 25),
            self.nextButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.nextButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -34),
            self.nextButton.heightAnchor.constraint(equalToConstant: 50)
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
