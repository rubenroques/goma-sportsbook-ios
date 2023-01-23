//
//  DocumentView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/01/2023.
//

import UIKit
import Combine

enum DocumentUploadState {
    case preUpload
    case uploading
    case uploaded
    case documentReceived
    case addAnother
}

class DocumentView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var uploadStateStackView: UIStackView = Self.createUploadStateStackView()

    private lazy var preUploadView: UIView = Self.createPreUploadView()
    private lazy var fileStatusImageView: UIImageView = Self.createFileStatusImageView()
    private lazy var fileTitleLabel: UILabel = Self.createFileTitleLabel()
    private lazy var allowedTypesLabel: UILabel = Self.createAllowedTypesLabel()
    private lazy var maxSizeLabel: UILabel = Self.createMaxSizeLabel()

    private lazy var uploadView: UIView = Self.createUploadView()
    private lazy var uploadTitleLabel: UILabel = Self.createUploadTitleLabel()
    private lazy var uploadProgressTitleLabel: UILabel = Self.createUploadProgressTitleLabel()
    private lazy var uploadProgressView: UIProgressView = Self.createUploadProgressView()

    private lazy var postUploadView: UIView = Self.createPostUploadView()
    private lazy var postUploadTitleLabel: UILabel = Self.createPostUploadTitleLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    
    private lazy var addAnotherBaseView: UIView = Self.createAddAnotherBaseView()
    private lazy var addAnotherView: UIView = Self.createAddAnotherView()
    private lazy var addAnotherTitleLabel: UILabel = Self.createAddAnotherTitleLabel()
    private lazy var addAnotherIconImageView: UIImageView = Self.createAddAnotherIconImageView()

    // MARK: Public Properties
    var documentUploadState: DocumentUploadState = .preUpload {
        didSet {
            switch documentUploadState {
            case .preUpload:
                self.preUploadView.isHidden = false
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = true
                self.addAnotherBaseView.isHidden = true
                self.containerView.layer.borderWidth = 1
            case .uploading:
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = false
                self.postUploadView.isHidden = true
                self.addAnotherBaseView.isHidden = true
                self.containerView.layer.borderWidth = 1
            case .uploaded:
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = false
                self.addAnotherBaseView.isHidden = true
                self.containerView.layer.borderWidth = 1
            case .documentReceived:
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = false
                self.addAnotherBaseView.isHidden = true
                self.containerView.layer.borderWidth = 1
            case .addAnother:
                self.preUploadView.isHidden = true
                self.uploadView.isHidden = true
                self.postUploadView.isHidden = true
                self.addAnotherBaseView.isHidden = false
                self.containerView.layer.borderWidth = 0
            }
        }
    }

    var uploadValue: Float = 0 {
        didSet {
            self.uploadProgressView.progress = uploadValue
            self.uploadProgressTitleLabel.text = "Upload \(Int(uploadValue*100))%..."

            if uploadValue == 1 {
//                self.uploadView.isHidden = true
//                self.postUploadView.isHidden = false
                self.documentUploadState = .uploaded

                self.postUploadTitleLabel.text = self.uploadTitleLabel.text

                self.statusLabel.text = "Pending Approved"
                self.statusView.backgroundColor = UIColor.App.statsAway
                
                self.finishedUploading?()
            }
        }
    }
    var shouldStartUpload: Bool = false {
        didSet {
            if shouldStartUpload {
                self.documentUploadState = .uploading
                self.shouldRedrawView?()
            }
        }
    }

    var shouldSelectFile: ((String) -> Void)?
    var finishedUploading: (() -> Void)?
    var shouldRedrawView: (() -> Void)?
    
    var documentInfo: DocumentInfo?

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

        let testUploadTap = UITapGestureRecognizer(target: self, action: #selector(self.testTapUploadAction))
        self.preUploadView.addGestureRecognizer(testUploadTap)

        let addAnotherTap = UITapGestureRecognizer(target: self, action: #selector(self.testTapUploadAction))

        self.addAnotherBaseView.addGestureRecognizer(addAnotherTap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.headerInput

        self.statusView.layer.cornerRadius = CornerRadius.headerInput

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.uploadStateStackView.backgroundColor = .clear

        self.preUploadView.backgroundColor = .clear

        self.fileStatusImageView.backgroundColor = .clear

        self.fileTitleLabel.textColor = UIColor.App.textPrimary

        self.allowedTypesLabel.textColor = UIColor.App.textSecondary

        self.maxSizeLabel.textColor = UIColor.App.textSecondary

        self.uploadView.backgroundColor = .clear

        self.uploadTitleLabel.textColor = UIColor.App.textPrimary

        self.uploadProgressTitleLabel.textColor = UIColor.App.textSecondary

        self.uploadProgressView.trackTintColor = UIColor.App.buttonBackgroundSecondary

        self.uploadProgressView.progressTintColor = UIColor.App.alertWarning

        self.postUploadView.backgroundColor = .clear

        self.postUploadTitleLabel.textColor = UIColor.App.textPrimary

        self.statusView.backgroundColor = UIColor.App.bubblesPrimary

        self.statusLabel.textColor = UIColor.App.buttonTextPrimary

        self.addAnotherBaseView.backgroundColor = .clear

        self.addAnotherView.backgroundColor = .clear

        self.addAnotherTitleLabel.textColor = UIColor.App.textSecondary

        self.addAnotherIconImageView.backgroundColor = .clear
    }

    // MARK: Functions
    func configure(documentInfo: DocumentInfo, fileUploaded: DocumentFileInfo? = nil , isOptionalUpload: Bool = false) {
        self.documentInfo = documentInfo

        if !isOptionalUpload {
            switch documentInfo.status {
            case .notReceived:
                self.documentUploadState = .preUpload
            case .received:
                self.documentUploadState = .documentReceived

                if let fileUploaded {
                    self.postUploadTitleLabel.text = fileUploaded.name

                    self.setupFileUploadedState(fileState: fileUploaded.status)
                }
            }
        }
        else {
            self.documentUploadState = .addAnother
        }
    }

    func startUpload(file: String) {

        self.uploadTitleLabel.text = file

        self.shouldStartUpload = true

        self.uploadValue = 0

        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let progress = 33.0/100
            self.uploadValue = Float(progress)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let progress = 66.0/100
            self.uploadValue = Float(progress)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let progress = 100.0/100
            self.uploadValue = Float(progress)
        }
    }

    private func setupFileUploadedState(fileState: FileState) {

        switch fileState {
        case .pendingApproved:
            self.statusView.backgroundColor = UIColor.App.statsAway
        case .approved:
            self.statusView.backgroundColor = UIColor.App.alertSuccess
        case .failed:
            self.statusView.backgroundColor = UIColor.App.alertError
        }

        self.statusLabel.text = fileState.statusName

    }

    // MARK: Action
    @objc func testTapUploadAction() {

        if self.documentUploadState == .preUpload || self.documentUploadState == .addAnother,
           let documentInfo = self.documentInfo {
            self.shouldSelectFile?(documentInfo.id)
        }

    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension DocumentView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.App.separatorLine.cgColor
        return view
    }

    private static func createUploadStateStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }

    private static func createPreUploadView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFileStatusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "upload_file_icon")
        return imageView
    }

    private static func createFileTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upload Document"
        label.font = AppFont.with(type: .bold, size: 17)
        return label
    }

    private static func createAllowedTypesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allowed file types: png, jpg, pdf"
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createMaxSizeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Max. size: 10MB"
        label.font = AppFont.with(type: .bold, size: 10)
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
        label.text = "File Name"
        label.font = AppFont.with(type: .bold, size: 17)
        return label
    }

    private static func createUploadProgressTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Uplaoding 0%..."
        label.font = AppFont.with(type: .bold, size: 12)
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
        label.text = "File Name"
        label.font = AppFont.with(type: .bold, size: 17)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

    private static func createAddAnotherBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddAnotherView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAddAnotherTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add another"
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private static func createAddAnotherIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "add_document_icon")
        return imageView
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.uploadStateStackView)

        self.uploadStateStackView.addArrangedSubview(self.preUploadView)
        self.uploadStateStackView.addArrangedSubview(self.uploadView)
        self.uploadStateStackView.addArrangedSubview(self.postUploadView)
        self.uploadStateStackView.addArrangedSubview(self.addAnotherBaseView)

        self.preUploadView.addSubview(self.fileStatusImageView)
        self.preUploadView.addSubview(self.fileTitleLabel)
        self.preUploadView.addSubview(self.allowedTypesLabel)
        self.preUploadView.addSubview(self.maxSizeLabel)

        self.uploadView.addSubview(self.uploadTitleLabel)
        self.uploadView.addSubview(self.uploadProgressTitleLabel)
        self.uploadView.addSubview(self.uploadProgressView)

        self.postUploadView.addSubview(self.postUploadTitleLabel)
        self.postUploadView.addSubview(self.statusView)
        self.statusView.addSubview(self.statusLabel)

        self.addAnotherBaseView.addSubview(self.addAnotherView)

        self.addAnotherView.addSubview(self.addAnotherTitleLabel)
        self.addAnotherView.addSubview(self.addAnotherIconImageView)

        self.initConstraints()
        
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.uploadStateStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.uploadStateStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.uploadStateStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.uploadStateStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.preUploadView.leadingAnchor.constraint(equalTo: self.uploadStateStackView.leadingAnchor),
            self.preUploadView.trailingAnchor.constraint(equalTo: self.uploadStateStackView.trailingAnchor),

            self.uploadView.leadingAnchor.constraint(equalTo: self.uploadStateStackView.leadingAnchor),
            self.uploadView.trailingAnchor.constraint(equalTo: self.uploadStateStackView.trailingAnchor),

            self.postUploadView.leadingAnchor.constraint(equalTo: self.uploadStateStackView.leadingAnchor),
            self.postUploadView.trailingAnchor.constraint(equalTo: self.uploadStateStackView.trailingAnchor),

            self.addAnotherBaseView.leadingAnchor.constraint(equalTo: self.uploadStateStackView.leadingAnchor),
            self.addAnotherBaseView.trailingAnchor.constraint(equalTo: self.uploadStateStackView.trailingAnchor)
        ])

        // Pre upload View
        NSLayoutConstraint.activate([
            self.fileStatusImageView.leadingAnchor.constraint(equalTo: self.preUploadView.leadingAnchor, constant: 15),
            self.fileStatusImageView.topAnchor.constraint(equalTo: self.preUploadView.topAnchor, constant: 15),
            self.fileStatusImageView.widthAnchor.constraint(equalToConstant: 32),
            self.fileStatusImageView.heightAnchor.constraint(equalTo: self.fileStatusImageView.widthAnchor),

            self.fileTitleLabel.leadingAnchor.constraint(equalTo: self.fileStatusImageView.trailingAnchor, constant: 10),
            self.fileTitleLabel.topAnchor.constraint(equalTo: self.fileStatusImageView.topAnchor),
            self.fileTitleLabel.trailingAnchor.constraint(equalTo: self.preUploadView.trailingAnchor, constant: -15),

            self.allowedTypesLabel.leadingAnchor.constraint(equalTo: self.fileTitleLabel.leadingAnchor),
            self.allowedTypesLabel.topAnchor.constraint(equalTo: self.fileTitleLabel.bottomAnchor, constant: 8),
            self.allowedTypesLabel.trailingAnchor.constraint(equalTo: self.preUploadView.trailingAnchor, constant: -15),

            self.maxSizeLabel.leadingAnchor.constraint(equalTo: self.fileTitleLabel.leadingAnchor),
            self.maxSizeLabel.topAnchor.constraint(equalTo: self.allowedTypesLabel.bottomAnchor, constant: 8),
            self.maxSizeLabel.trailingAnchor.constraint(equalTo: self.preUploadView.trailingAnchor, constant: -15),
            self.maxSizeLabel.bottomAnchor.constraint(equalTo: self.preUploadView.bottomAnchor, constant: -13)
        ])

        // Uploading View
        NSLayoutConstraint.activate([
            self.uploadTitleLabel.leadingAnchor.constraint(equalTo: self.uploadView.leadingAnchor, constant: 15),
            self.uploadTitleLabel.topAnchor.constraint(equalTo: self.uploadView.topAnchor, constant: 13),
            self.uploadTitleLabel.trailingAnchor.constraint(equalTo: self.uploadView.trailingAnchor, constant: -15),

            self.uploadProgressTitleLabel.leadingAnchor.constraint(equalTo: self.uploadTitleLabel.leadingAnchor),
            self.uploadProgressTitleLabel.trailingAnchor.constraint(equalTo: self.uploadTitleLabel.trailingAnchor),
            self.uploadProgressTitleLabel.topAnchor.constraint(equalTo: self.uploadTitleLabel.bottomAnchor, constant: 16),

            self.uploadProgressView.leadingAnchor.constraint(equalTo: self.uploadTitleLabel.leadingAnchor),
            self.uploadProgressView.trailingAnchor.constraint(equalTo: self.uploadTitleLabel.trailingAnchor),
            self.uploadProgressView.topAnchor.constraint(equalTo: self.uploadProgressTitleLabel.bottomAnchor, constant: 4),
            self.uploadProgressView.bottomAnchor.constraint(equalTo: self.uploadView.bottomAnchor, constant: -13)
        ])

        // Post Upload View
        NSLayoutConstraint.activate([
            self.postUploadTitleLabel.leadingAnchor.constraint(equalTo: self.postUploadView.leadingAnchor, constant: 15),
            self.postUploadTitleLabel.topAnchor.constraint(equalTo: self.postUploadView.topAnchor, constant: 18),
            self.postUploadTitleLabel.bottomAnchor.constraint(equalTo: self.postUploadView.bottomAnchor, constant: -18),

            //self.statusView.leadingAnchor.constraint(equalTo: self.postUploadTitleLabel.trailingAnchor, constant: 4),
            self.statusView.trailingAnchor.constraint(equalTo: self.postUploadView.trailingAnchor, constant: -15),
            self.statusView.centerYAnchor.constraint(equalTo: self.postUploadTitleLabel.centerYAnchor),

            self.statusLabel.leadingAnchor.constraint(equalTo: self.statusView.leadingAnchor, constant: 4),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.statusView.trailingAnchor, constant: -4),
            self.statusLabel.topAnchor.constraint(equalTo: self.statusView.topAnchor, constant: 4),
            self.statusLabel.bottomAnchor.constraint(equalTo: self.statusView.bottomAnchor, constant: -4)
        ])

        // Add Another View
        NSLayoutConstraint.activate([
            self.addAnotherBaseView.heightAnchor.constraint(equalToConstant: 30),

            self.addAnotherView.centerXAnchor.constraint(equalTo: self.addAnotherBaseView.centerXAnchor),
            self.addAnotherView.bottomAnchor.constraint(equalTo: self.addAnotherBaseView.bottomAnchor),

            self.addAnotherTitleLabel.leadingAnchor.constraint(equalTo: self.addAnotherView.leadingAnchor),
            self.addAnotherTitleLabel.topAnchor.constraint(equalTo: self.addAnotherView.topAnchor, constant: 10),
            self.addAnotherTitleLabel.bottomAnchor.constraint(equalTo: self.addAnotherView.bottomAnchor, constant: -5),

            self.addAnotherIconImageView.leadingAnchor.constraint(equalTo: self.addAnotherTitleLabel.trailingAnchor, constant: 5),
            self.addAnotherIconImageView.trailingAnchor.constraint(equalTo: self.addAnotherView.trailingAnchor),
            self.addAnotherIconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.addAnotherIconImageView.heightAnchor.constraint(equalTo: self.addAnotherIconImageView.widthAnchor),
            self.addAnotherIconImageView.centerYAnchor.constraint(equalTo: self.addAnotherTitleLabel.centerYAnchor)
        ])
    }
}
