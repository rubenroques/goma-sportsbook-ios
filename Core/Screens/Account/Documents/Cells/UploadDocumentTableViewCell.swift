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
    case received

//    var statusName: String {
//        switch self {
//        case .notReceived:
//            return "Not Received"
//        case .inProgress:
//            return "In Progress"
//        case .validated:
//            return "Validated"
//        }
//    }
}

class UploadDocumentCellViewModel {

    // MARK: Public Properties
    var id: String
    var documentInfo: DocumentInfo
    var documentState: DocumentState
    var documentTypeName: String
    var documentUploadedName: String?
    var uploadValue: CurrentValueSubject<Float, Never> = .init(0)
    var shouldStartUpload: CurrentValueSubject<Bool, Never> = .init(false)

    var cachedDocumentViews: [DocumentView] = []

    // MARK: Lifetime and Cycle
    init(documentInfo: DocumentInfo) {
        self.id = documentInfo.id
        self.documentInfo = documentInfo
        self.documentTypeName = documentInfo.typeName
        self.documentState = documentInfo.status

        //self.documentUploadedName = documentInfo.uploadedFileName
        
    }

    func startUpload(file: String) {

        self.documentUploadedName = file

        for cachedDocumentView in self.cachedDocumentViews {
            if cachedDocumentView.documentUploadState == .preUpload || cachedDocumentView.documentUploadState == .addAnother {
                cachedDocumentView.startUpload(file: file)
            }
        }

//        self.shouldStartUpload.send(true)
//
//        self.uploadValue.send(0)
//
//        // Simulate upload
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let progress = 33.0/100
//            self.uploadValue.send(Float(progress))
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let progress = 66.0/100
//            self.uploadValue.send(Float(progress))
//
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            let progress = 100.0/100
//            self.uploadValue.send(Float(progress))
//
//        }
    }
}

class UploadDocumentTableViewCell: UITableViewCell {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var statusView: UIView = Self.createStatusView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    //private lazy var uploadAreaView: UIView = Self.createUploadAreaView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var viewModel: UploadDocumentCellViewModel?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var shouldSelectFile: ((String) -> Void)?

    // MARK: Public properties
    var finishedUploading: (() -> Void)?
    var shouldRedrawViews: (() -> Void)?

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

        self.stackView.removeAllArrangedSubviews()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.card

        self.statusView.layer.cornerRadius = CornerRadius.headerInput

    }

    private func commonInit() {

    }

    private func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.statusView.backgroundColor = UIColor.App.bubblesPrimary

        self.statusLabel.textColor = UIColor.App.buttonTextPrimary

        //self.uploadAreaView.backgroundColor = .clear

        self.stackView.backgroundColor = .clear
    }

    func configure(withViewModel viewModel: UploadDocumentCellViewModel) {

        self.viewModel = viewModel

        self.setupDocumentState()

        if let documentView = viewModel.cachedDocumentViews.filter({
            $0.documentInfo?.id == viewModel.documentInfo.id
        }).first {
            self.stackView.addArrangedSubview(documentView)

            if documentView.documentUploadState == .uploaded {
                self.showAddAnotherView()
            }
        }
        else {
            if viewModel.documentInfo.uploadedFiles.isEmpty {
                let documentView = DocumentView()
                documentView.configure(documentInfo: viewModel.documentInfo)

                documentView.shouldSelectFile = { [weak self] documentId in
                    self?.shouldSelectFile?(documentId)
                }

                documentView.finishedUploading = { [weak self] in
                    self?.showAddAnotherView()
                    self?.finishedUploading?()
                }

                documentView.shouldRedrawView = { [weak self] in
                    self?.shouldRedrawViews?()
                }

                viewModel.cachedDocumentViews.append(documentView)

                self.stackView.addArrangedSubview(documentView)
            }
            else {
                var addAnotherFileEnabled = false

                for uploadedFile in viewModel.documentInfo.uploadedFiles {

                    let documentView = DocumentView()
                    documentView.configure(documentInfo: viewModel.documentInfo, fileUploaded: uploadedFile)

                    documentView.shouldSelectFile = { [weak self] documentId in
                        self?.shouldSelectFile?(documentId)
                    }

                    documentView.finishedUploading = { [weak self] in
                        self?.showAddAnotherView()
                        self?.finishedUploading?()
                    }

                    documentView.shouldRedrawView = { [weak self] in
                        self?.shouldRedrawViews?()
                    }

                    viewModel.cachedDocumentViews.append(documentView)

                    self.stackView.addArrangedSubview(documentView)

                    if uploadedFile.status == .pendingApproved || uploadedFile.status == .failed {
                        addAnotherFileEnabled = true
                    }
                }

                if addAnotherFileEnabled {
                    self.showAddAnotherView()
                }
            }
        }

    }

    private func showAddAnotherView() {

        //let addAnotherDocumentView = AddAnotherDocumentView()

//        addAnotherDocumentView.shouldAddNewDocument = { [weak self] in
////            guard let self = self else {return}
//
//            self?.stackView.removeArrangedSubviewCompletely(addAnotherDocumentView)
//
//            let documentView = DocumentView()
//            if let viewModel = self?.viewModel {
//
//                documentView.configure(documentInfo: viewModel.documentInfo)
//
//                documentView.shouldSelectFile = { [weak self] documentId in
//                    self?.shouldSelectFile?(documentId)
//                }
//
//                documentView.finishedUploading = { [weak self] in
//                    self?.showAddAnotherView()
//                    self?.finishedUploading?()
//                }
//
//                viewModel.cachedDocumentViews.append(documentView)
//
//                self?.stackView.addArrangedSubview(documentView)
//
//                self?.shouldRedrawViews?()
//            }
//
//        }
        if let viewModel = self.viewModel {

            let documentView = DocumentView()
            documentView.configure(documentInfo: viewModel.documentInfo, isOptionalUpload: true)

            documentView.shouldSelectFile = { [weak self] documentId in
                self?.shouldSelectFile?(documentId)
            }

            documentView.finishedUploading = { [weak self] in
                self?.showAddAnotherView()
                self?.finishedUploading?()
            }

            documentView.shouldRedrawView = { [weak self] in
                self?.shouldRedrawViews?()
            }

            viewModel.cachedDocumentViews.append(documentView)

            self.stackView.addArrangedSubview(documentView)
        }

    }

    private func setupDocumentState() {

        if let viewModel = self.viewModel {

//            switch viewModel.documentState {
//            case .notReceived:
//                self.statusView.backgroundColor = UIColor.App.alertError
//
//            case .inProgress:
//                self.statusView.backgroundColor = UIColor.App.bubblesPrimary
//
//            case .validated:
//                self.statusView.backgroundColor = UIColor.App.alertSuccess
//
//            }

            self.titleLabel.text = viewModel.documentTypeName

            //self.statusLabel.text = viewModel.documentState.statusName

        }
    }

    // MARK: Action

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

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.stackView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12.5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12.5),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 19),

            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 14),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -25)

        ])
    }
}
