//
//  UploadDocumentTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 12/01/2023.
//

import UIKit
import Combine

enum DocumentState {
    case notReceived
    case inProgress
    case validated

    var statusName: String {
        switch self {
        case .notReceived:
            return "Not Received"
        case .inProgress:
            return "In Progress"
        case .validated:
            return "Validated"
        }
    }
}

class UploadDocumentCellViewModel {

    // MARK: Public Properties
    var id: String
    var documentState: DocumentState
    var documentTypeName: String
    var documentUploadedName: String?
    var uploadValue: CurrentValueSubject<Float, Never> = .init(0)
    var shouldStartUpload: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and Cycle
    init(documentInfo: DocumentInfo) {
        self.id = documentInfo.id
        self.documentTypeName = documentInfo.typeName
        self.documentState = documentInfo.status

        self.documentUploadedName = documentInfo.uploadedFileName
        
    }

    func startUpload(file: String) {

        self.documentUploadedName = file

        self.shouldStartUpload.send(true)

        self.uploadValue.send(0)

        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let progress = 33.0/100
            self.uploadValue.send(Float(progress))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let progress = 66.0/100
            self.uploadValue.send(Float(progress))

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let progress = 100.0/100
            self.uploadValue.send(Float(progress))

        }
    }
}

class UploadDocumentTableViewCell: UITableViewCell {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    private lazy var uploadAreaView: UIView = Self.createUploadAreaView()
    private lazy var fileStatusImageView: UIImageView = Self.createFileStatusImageView()
    private lazy var fileTitleStackView: UIStackView = Self.createFileTitleStackView()
    private lazy var fileTitleLabel: UILabel = Self.createFileTitleLabel()
    private lazy var fileStatusIconBaseView: UIView = Self.createFileStatusIconBaseView()
    private lazy var fileStatusIconImageView: UIImageView = Self.createFileStatusIconImageView()
    private lazy var fileInfoStackView: UIStackView = Self.createFileInfoStackView()

    private lazy var preUploadView: UIView = Self.createPreUploadView()
    private lazy var allowedTypesLabel: UILabel = Self.createAllowedTypesLabel()
    private lazy var maxSizeLabel: UILabel = Self.createMaxSizeLabel()

    private lazy var uploadView: UIView = Self.createUploadView()
    private lazy var uploadTitleLabel: UILabel = Self.createUploadTitleLabel()
    private lazy var uploadProgressView: UIProgressView = Self.createUploadProgressView()

    private lazy var postUploadView: UIView = Self.createPostUploadView()
    private lazy var postUploadTitleLabel: UILabel = Self.createPostUploadTitleLabel()

    private var viewModel: UploadDocumentCellViewModel?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var shouldSelectFile: ((String) -> Void)?

    // MARK: Public properties
    var finishedUploading: Bool = false {
        didSet {
            self.fileStatusIconBaseView.isHidden = !finishedUploading

            if finishedUploading {
                self.uploadProgressView.progressTintColor = UIColor.App.alertSuccess
            }
            else {
                self.uploadProgressView.progressTintColor = UIColor.App.alertWarning
            }
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""

        self.statusLabel.text = ""

        self.finishedUploading = false

        self.preUploadView.isHidden = false

        self.uploadView.isHidden = true

        self.postUploadView.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.card

        self.statusView.layer.cornerRadius = CornerRadius.headerInput

        self.uploadAreaView.layer.cornerRadius = CornerRadius.headerInput

    }

    private func commonInit() {

        self.finishedUploading = false

        self.preUploadView.isHidden = false

        self.uploadView.isHidden = true

        self.postUploadView.isHidden = true

        let testUploadTap = UITapGestureRecognizer(target: self, action: #selector(self.testTapUploadAction))
        self.uploadAreaView.addGestureRecognizer(testUploadTap)
    }

    private func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.statusView.backgroundColor = UIColor.App.bubblesPrimary

        self.statusLabel.textColor = UIColor.App.buttonTextPrimary

        self.uploadAreaView.backgroundColor = .clear

        self.fileStatusImageView.backgroundColor = .clear

        self.fileTitleStackView.backgroundColor = .clear

        self.fileTitleLabel.textColor = UIColor.App.textPrimary

        self.fileStatusIconBaseView.backgroundColor = .clear

        self.fileStatusIconImageView.backgroundColor = .clear

        self.fileInfoStackView.backgroundColor = .clear

        self.preUploadView.backgroundColor = .clear

        self.allowedTypesLabel.textColor = UIColor.App.textPrimary

        self.maxSizeLabel.textColor = UIColor.App.textPrimary

        self.uploadView.backgroundColor = .clear

        self.uploadTitleLabel.textColor = UIColor.App.textSecondary

        self.uploadProgressView.trackTintColor = UIColor.App.buttonBackgroundSecondary

        self.uploadProgressView.progressTintColor = UIColor.App.alertWarning

        self.postUploadView.backgroundColor = .clear

        self.postUploadTitleLabel.textColor = UIColor.App.textPrimary
    }

    func configure(withViewModel viewModel: UploadDocumentCellViewModel) {

        self.viewModel = viewModel

        self.setupDocumentState()

        // Simulate upload
        viewModel.uploadValue
            .sink(receiveValue: { [weak self] uploadValue in

                self?.uploadProgressView.progress = uploadValue
                self?.uploadTitleLabel.text = "Upload \(Int(uploadValue*100))%..."

                if uploadValue == 1 {
                    self?.uploadTitleLabel.text = "Upload completed"
                    self?.finishedUploading = true
                }
            })
            .store(in: &cancellables)

        viewModel.shouldStartUpload
            .sink(receiveValue: { [weak self] shouldStartUpload in
                if shouldStartUpload {
                    self?.finishedUploading = false

                    self?.preUploadView.isHidden = true
                    self?.uploadView.isHidden = false
                    self?.postUploadView.isHidden = true

                    if let documentName = self?.viewModel?.documentUploadedName {
                        self?.fileTitleLabel.text = documentName
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func setupDocumentState() {

        if let viewModel = self.viewModel {

            switch viewModel.documentState {
            case .notReceived:
                self.statusView.backgroundColor = UIColor.App.alertError
                self.preUploadView.isHidden = false
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = true

            case .inProgress:
                self.statusView.backgroundColor = UIColor.App.bubblesPrimary
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = false

                self.fileStatusImageView.image = UIImage(named: "upload_done_icon")

                self.postUploadTitleLabel.text = "Waiting for confirmation"
            case .validated:
                self.statusView.backgroundColor = UIColor.App.alertSuccess
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = false

                self.fileStatusImageView.image = UIImage(named: "upload_done_icon")

                self.postUploadTitleLabel.text = "Document approved"

            }

            self.titleLabel.text = viewModel.documentTypeName

            self.statusLabel.text = viewModel.documentState.statusName

            if let fileUploadedName = viewModel.documentUploadedName {
                self.fileTitleLabel.text = fileUploadedName
            }

        }
    }

    // MARK: Action
    @objc func testTapUploadAction() {

        if let viewModel = self.viewModel
            {
            if viewModel.documentState == .notReceived {
                self.shouldSelectFile?(viewModel.id)
            }
        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension UploadDocumentTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Document Title"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Status"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createUploadAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.App.separatorLine.cgColor
        return view
    }

    private static func createFileStatusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "upload_file_icon")
        return imageView
    }

    private static func createFileTitleStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }

    private static func createFileTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upload Document"
        label.font = AppFont.with(type: .bold, size: 17)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createFileStatusIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }

    private static func createFileStatusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "upload_check_icon")
        return imageView
    }

    private static func createFileInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }

    private static func createPreUploadView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAllowedTypesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allowed file types: png, jpg, pdf"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createMaxSizeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Max. size: 10MB"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createUploadView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUploadTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upload 0%..."
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createUploadProgressView() -> UIProgressView {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 1
        return progressView
    }

    private static func createPostUploadView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPostUploadTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upload Status"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.statusView)

        self.statusView.addSubview(self.statusLabel)

        self.containerView.addSubview(self.uploadAreaView)

        self.uploadAreaView.addSubview(self.fileStatusImageView)

        self.uploadAreaView.addSubview(self.fileTitleStackView)

        self.fileTitleStackView.addArrangedSubview(self.fileTitleLabel)
        self.fileTitleStackView.addArrangedSubview(self.fileStatusIconBaseView)

        self.fileStatusIconBaseView.addSubview(self.fileStatusIconImageView)

        self.uploadAreaView.addSubview(self.fileInfoStackView)

        self.fileInfoStackView.addArrangedSubview(self.preUploadView)

        self.preUploadView.addSubview(self.allowedTypesLabel)
        self.preUploadView.addSubview(self.maxSizeLabel)

        self.fileInfoStackView.addArrangedSubview(self.uploadView)

        self.uploadView.addSubview(self.uploadTitleLabel)
        self.uploadView.addSubview(self.uploadProgressView)

        self.fileInfoStackView.addArrangedSubview(self.postUploadView)

        self.postUploadView.addSubview(self.postUploadTitleLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.5),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 19),

            self.statusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.statusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 10),
            self.statusView.heightAnchor.constraint(equalToConstant: 18),
            self.statusView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

            self.statusLabel.leadingAnchor.constraint(equalTo: self.statusView.leadingAnchor, constant: 5),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.statusView.trailingAnchor, constant: -5),
            self.statusLabel.centerXAnchor.constraint(equalTo: self.statusView.centerXAnchor),
            self.statusLabel.centerYAnchor.constraint(equalTo: self.statusView.centerYAnchor),

            self.uploadAreaView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.uploadAreaView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.uploadAreaView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 14),
            self.uploadAreaView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -25)
        ])

        // Upload Area View

        NSLayoutConstraint.activate([
            self.fileStatusImageView.leadingAnchor.constraint(equalTo: self.uploadAreaView.leadingAnchor, constant: 15),
            self.fileStatusImageView.topAnchor.constraint(equalTo: self.uploadAreaView.topAnchor, constant: 15),
            self.fileStatusImageView.widthAnchor.constraint(equalToConstant: 32),
            self.fileStatusImageView.heightAnchor.constraint(equalTo: self.fileStatusImageView.widthAnchor),

            self.fileTitleStackView.leadingAnchor.constraint(equalTo: self.fileStatusImageView.trailingAnchor, constant: 8),
            self.fileTitleStackView.trailingAnchor.constraint(equalTo: self.uploadAreaView.trailingAnchor, constant: -15),
            self.fileTitleStackView.centerYAnchor.constraint(equalTo: self.fileStatusImageView.centerYAnchor),

            self.fileStatusIconBaseView.heightAnchor.constraint(equalToConstant: 16),
            self.fileStatusIconBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),

            self.fileStatusIconImageView.leadingAnchor.constraint(equalTo: self.fileStatusIconBaseView.leadingAnchor),
            self.fileStatusIconImageView.centerYAnchor.constraint(equalTo: self.fileStatusIconBaseView.centerYAnchor),
            self.fileStatusIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.fileStatusIconImageView.heightAnchor.constraint(equalTo: self.fileStatusIconImageView.heightAnchor),

            self.fileInfoStackView.leadingAnchor.constraint(equalTo: self.uploadAreaView.leadingAnchor, constant: 15),
            self.fileInfoStackView.trailingAnchor.constraint(equalTo: self.uploadAreaView.trailingAnchor, constant: -15),
            self.fileInfoStackView.topAnchor.constraint(equalTo: self.fileStatusImageView.bottomAnchor, constant: 5),
            self.fileInfoStackView.bottomAnchor.constraint(equalTo: self.uploadAreaView.bottomAnchor, constant: -15)
        ])

        // PreUpload View
        NSLayoutConstraint.activate([
            self.preUploadView.leadingAnchor.constraint(equalTo: self.fileInfoStackView.leadingAnchor, constant: 40),
            self.preUploadView.trailingAnchor.constraint(equalTo: self.fileInfoStackView.trailingAnchor),

            self.allowedTypesLabel.leadingAnchor.constraint(equalTo: self.preUploadView.leadingAnchor),
            self.allowedTypesLabel.trailingAnchor.constraint(equalTo: self.preUploadView.trailingAnchor),
            self.allowedTypesLabel.topAnchor.constraint(equalTo: self.preUploadView.topAnchor),

            self.maxSizeLabel.leadingAnchor.constraint(equalTo: self.preUploadView.leadingAnchor),
            self.maxSizeLabel.trailingAnchor.constraint(equalTo: self.preUploadView.trailingAnchor),
            self.maxSizeLabel.topAnchor.constraint(equalTo: self.allowedTypesLabel.bottomAnchor, constant: 8),
            self.maxSizeLabel.bottomAnchor.constraint(equalTo: self.preUploadView.bottomAnchor)
        ])

        // Upload View
        NSLayoutConstraint.activate([
            self.uploadView.leadingAnchor.constraint(equalTo: self.fileInfoStackView.leadingAnchor),
            self.uploadView.trailingAnchor.constraint(equalTo: self.fileInfoStackView.trailingAnchor),

            self.uploadTitleLabel.leadingAnchor.constraint(equalTo: self.uploadView.leadingAnchor),
            self.uploadTitleLabel.trailingAnchor.constraint(equalTo: self.uploadView.trailingAnchor),
            self.uploadTitleLabel.topAnchor.constraint(equalTo: self.uploadView.topAnchor, constant: 2),

            self.uploadProgressView.leadingAnchor.constraint(equalTo: self.uploadView.leadingAnchor),
            self.uploadProgressView.trailingAnchor.constraint(equalTo: self.uploadView.trailingAnchor),
            self.uploadProgressView.topAnchor.constraint(equalTo: self.uploadTitleLabel.bottomAnchor, constant: 4),
            self.uploadProgressView.bottomAnchor.constraint(equalTo: self.uploadView.bottomAnchor, constant: -2)
        ])

        // Post Upload View
        NSLayoutConstraint.activate([
            self.postUploadView.leadingAnchor.constraint(equalTo: self.fileInfoStackView.leadingAnchor, constant: 40),
            self.postUploadView.trailingAnchor.constraint(equalTo: self.fileInfoStackView.trailingAnchor),

            self.postUploadTitleLabel.leadingAnchor.constraint(equalTo: self.postUploadView.leadingAnchor),
            self.postUploadTitleLabel.trailingAnchor.constraint(equalTo: self.postUploadView.trailingAnchor),
            self.postUploadTitleLabel.topAnchor.constraint(equalTo: self.postUploadView.topAnchor),
            self.postUploadTitleLabel.bottomAnchor.constraint(equalTo: self.postUploadView.bottomAnchor)
        ])
    }
}
