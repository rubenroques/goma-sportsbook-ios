//
//  UploadDocumentsInformationView.swift
//  Sportsbook
//
//  Created by André Lascas on 09/06/2023.
//

import UIKit

class UploadDocumentsInformationView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var uploadInfoLabel: UILabel = Self.createUploadInfoLabel()
    private lazy var cornersInfoLabel: UILabel = Self.createCornersInfoLabel()
    private lazy var typesInfoLabel: UILabel = Self.createTypesInfoLabel()
    private lazy var sizeInfoLabel: UILabel = Self.createSizeInfoLabel()
    private lazy var uploadStackView: UIStackView = Self.createUploadStackView()

    private lazy var frontDocumentBaseView: UIView = Self.createFrontDocumentBaseView()
    private lazy var frontDocumentStackView: UIStackView = Self.createFrontDocumentStackView()

    private lazy var frontPrePickView: UIView = Self.createFrontPrePickView()
    private lazy var frontPrePickImageView: UIImageView = Self.createFrontPrePickImageView()
    private lazy var frontPrePickTitleLabel: UILabel = Self.createFrontPrePickTitleLabel()

    private lazy var frontPickedView: UIView = Self.createFrontPickedView()
    private lazy var frontPickedTitleLabel: UILabel = Self.createFrontPickedTitleLabel()
    private lazy var frontPickedRemoveButton: UIButton = Self.createFrontPickedRemoveButton()

    private lazy var backDocumentBaseView: UIView = Self.createBackDocumentBaseView()
    private lazy var backDocumentStackView: UIStackView = Self.createBackDocumentStackView()

    private lazy var backPrePickView: UIView = Self.createBackPrePickView()
    private lazy var backPrePickImageView: UIImageView = Self.createBackPrePickImageView()
    private lazy var backPrePickTitleLabel: UILabel = Self.createBackPrePickTitleLabel()

    private lazy var backPickedView: UIView = Self.createBackPickedView()
    private lazy var backPickedTitleLabel: UILabel = Self.createBackPickedTitleLabel()
    private lazy var backPickedRemoveButton: UIButton = Self.createBackPickedRemoveButton()

    var documentTypeGroup: DocumentTypeGroup?
    
    var isMultiUpload: Bool = false {
        didSet {
            self.backDocumentBaseView.isHidden = !isMultiUpload

            self.uploadInfoLabel.text = isMultiUpload ? "- \(localized("upload_front_and_back"))" : "- \(localized("upload_front_document"))"
        }
    }

    var dashedSublayer: CALayer?

    var frontDocumentUploadState: DocumentUploadState = .preUpload {
        didSet {
            switch frontDocumentUploadState {
            case .preUpload:
                self.frontPrePickView.isHidden = false
                self.frontPickedView.isHidden = true
            case .uploaded:
                self.frontPrePickView.isHidden = true
                self.frontPickedView.isHidden = false
            default:
                ()
            }
        }
    }

    var backDocumentUploadState: DocumentUploadState = .preUpload {
        didSet {
            switch backDocumentUploadState {
            case .preUpload:
                self.backPrePickView.isHidden = false
                self.backPickedView.isHidden = true
            case .uploaded:
                self.backPrePickView.isHidden = true
                self.backPickedView.isHidden = false
            default:
                ()
            }
        }
    }

    var tappedFrontDocumentAction: ((DocumentTypeGroup) -> Void)?
    var tappedBackDocumentAction: ((DocumentTypeGroup) -> Void)?
    var tappedRemoveFrontDocumentAction: ((DocumentTypeGroup) -> Void)?
    var tappedRemoveBackDocumentAction: ((DocumentTypeGroup) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.card

//        let dashedBorder = self.frontPrePickView.addLineDashedStroke(pattern: [4, 4], radius: CornerRadius.headerInput, color: UIColor.App.separatorLine.cgColor)
//        self.frontPrePickView.layer.addSublayer(dashedBorder)
//        self.dashedSublayer = dashedBorder

        self.frontPrePickView.layer.borderWidth = 1
        self.frontPrePickView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.frontPrePickView.layer.cornerRadius = CornerRadius.card

        self.frontPickedView.layer.borderWidth = 1
        self.frontPickedView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.frontPickedView.layer.cornerRadius = CornerRadius.card

        self.backPrePickView.layer.borderWidth = 1
        self.backPrePickView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.backPrePickView.layer.cornerRadius = CornerRadius.card

        self.backPickedView.layer.borderWidth = 1
        self.backPickedView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.backPickedView.layer.cornerRadius = CornerRadius.card

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.uploadInfoLabel.textColor = UIColor.App.textSecondary

        self.cornersInfoLabel.textColor = UIColor.App.textSecondary

        self.typesInfoLabel.textColor = UIColor.App.textSecondary

        self.sizeInfoLabel.textColor = UIColor.App.textSecondary

        self.uploadStackView.backgroundColor = .clear

        self.frontDocumentBaseView.backgroundColor = .clear

        self.frontPrePickView.backgroundColor = .clear

        self.frontPickedView.backgroundColor = .clear

        self.backDocumentBaseView.backgroundColor = .clear

        self.backPrePickView.backgroundColor = .clear

        self.backPickedView.backgroundColor = .clear

    }

    private func commonInit() {

        self.frontDocumentUploadState = .preUpload

        self.backDocumentUploadState = .preUpload

        let frontDocumentTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapFrontDocument))
        self.frontPrePickView.addGestureRecognizer(frontDocumentTap)

        self.frontPickedRemoveButton.addTarget(self, action: #selector(self.didTapRemoveFrontDocument), for: .primaryActionTriggered)

        let backDocumentTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapBackDocument))
        self.backPrePickView.addGestureRecognizer(backDocumentTap)

        self.backPickedRemoveButton.addTarget(self, action: #selector(self.didTapRemoveBackDocument), for: .primaryActionTriggered)
    }

    func setupBackground(color: UIColor) {
        self.containerView.backgroundColor = color
    }

    func setFrontDocSelected(fileName: String) {
        self.frontPickedTitleLabel.text = fileName
        self.frontDocumentUploadState = .uploaded

    }

    func setBackDocSelected(fileName: String) {
        self.backPickedTitleLabel.text = fileName
        self.backDocumentUploadState = .uploaded

    }

    func removeFrontDoc() {
        self.frontPickedTitleLabel.text = ""
        self.frontDocumentUploadState = .preUpload

    }

    func removeBackDoc() {
        self.backPickedTitleLabel.text = ""
        self.backDocumentUploadState = .preUpload

    }

    @objc private func didTapFrontDocument() {
        print("TAPPED FRONT DOC UPLOAD")
        if let documentTypeGroup = self.documentTypeGroup {
            self.tappedFrontDocumentAction?(documentTypeGroup)
        }
    }

    @objc private func didTapRemoveFrontDocument() {
        print("REMOVE FRONT DOCUMENT")
        if let documentTypeGroup = self.documentTypeGroup {
            self.tappedRemoveFrontDocumentAction?(documentTypeGroup)
        }
    }

    @objc private func didTapBackDocument() {
        print("TAPPED FRONT DOC UPLOAD")
        if let documentTypeGroup = self.documentTypeGroup {
            self.tappedBackDocumentAction?(documentTypeGroup)
        }
    }

    @objc private func didTapRemoveBackDocument() {
        print("REMOVE BACK DOCUMENT")
        if let documentTypeGroup = self.documentTypeGroup {
            self.tappedRemoveBackDocumentAction?(documentTypeGroup)
        }
    }

}

extension UploadDocumentsInformationView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = localized("upload_information")
        return label
    }

    private static func createUploadInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.text = "- \(localized("upload_front_and_back"))"
        return label
    }

    private static func createCornersInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.text = "- \(localized("all_four_corners"))"
        return label
    }

    private static func createTypesInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.text = "- \(localized("allowed_file_types").replacingFirstOccurrence(of: "{allowedFileTypes}", with: "png, jpg, pdf"))"
        return label
    }

    private static func createSizeInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 10)
        label.text = "- \(localized("max_size")) 10MB"
        return label
    }

    private static func createUploadStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createFrontDocumentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFrontDocumentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }

    private static func createFrontPrePickView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFrontPrePickImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "upload_file_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createFrontPrePickTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.text = "Upload (Front)"
        return label
    }

    private static func createFrontPickedView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFrontPickedTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.text = "File name"
        return label
    }

    private static func createFrontPickedRemoveButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "trash_icon"), for: .normal)
        return button
    }

    private static func createBackDocumentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackDocumentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }

    private static func createBackPrePickView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackPrePickImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "upload_file_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createBackPrePickTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.text = "Upload (Back)"
        return label
    }

    private static func createBackPickedView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackPickedTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.text = "File name"
        return label
    }

    private static func createBackPickedRemoveButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "trash_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.uploadInfoLabel)
        self.containerView.addSubview(self.cornersInfoLabel)
        self.containerView.addSubview(self.typesInfoLabel)
        self.containerView.addSubview(self.sizeInfoLabel)
        self.containerView.addSubview(self.uploadStackView)

        self.uploadStackView.addArrangedSubview(self.frontDocumentBaseView)

        self.frontDocumentBaseView.addSubview(self.frontDocumentStackView)

        self.frontDocumentStackView.addArrangedSubview(self.frontPrePickView)

        self.frontPrePickView.addSubview(self.frontPrePickImageView)
        self.frontPrePickView.addSubview(self.frontPrePickTitleLabel)

        self.frontDocumentStackView.addArrangedSubview(self.frontPickedView)

        self.frontPickedView.addSubview(self.frontPickedTitleLabel)
        self.frontPickedView.addSubview(self.frontPickedRemoveButton)

        self.uploadStackView.addArrangedSubview(self.backDocumentBaseView)

        self.backDocumentBaseView.addSubview(self.backDocumentStackView)

        self.backDocumentStackView.addArrangedSubview(self.backPrePickView)

        self.backPrePickView.addSubview(self.backPrePickImageView)
        self.backPrePickView.addSubview(self.backPrePickTitleLabel)

        self.backDocumentStackView.addArrangedSubview(self.backPickedView)

        self.backPickedView.addSubview(self.backPickedTitleLabel)
        self.backPickedView.addSubview(self.backPickedRemoveButton)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 17),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -17),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 17),

            self.uploadInfoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.uploadInfoLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.uploadInfoLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 9),

            self.cornersInfoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.cornersInfoLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.cornersInfoLabel.topAnchor.constraint(equalTo: self.uploadInfoLabel.bottomAnchor, constant: 8),

            self.typesInfoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.typesInfoLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.typesInfoLabel.topAnchor.constraint(equalTo: self.cornersInfoLabel.bottomAnchor, constant: 8),

            self.sizeInfoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.sizeInfoLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.sizeInfoLabel.topAnchor.constraint(equalTo: self.typesInfoLabel.bottomAnchor, constant: 8),

            self.uploadStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 17),
            self.uploadStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -17),
            self.uploadStackView.topAnchor.constraint(equalTo: self.sizeInfoLabel.bottomAnchor, constant: 15),
            self.uploadStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -25)

        ])

        // Front Document Views
        NSLayoutConstraint.activate([
            self.frontDocumentBaseView.leadingAnchor.constraint(equalTo: self.uploadStackView.leadingAnchor),
            self.frontDocumentBaseView.trailingAnchor.constraint(equalTo: self.uploadStackView.trailingAnchor),
            self.frontDocumentBaseView.heightAnchor.constraint(equalToConstant: 56),

            self.frontDocumentStackView.leadingAnchor.constraint(equalTo: self.frontDocumentBaseView.leadingAnchor),
            self.frontDocumentStackView.trailingAnchor.constraint(equalTo: self.frontDocumentBaseView.trailingAnchor),
            self.frontDocumentStackView.topAnchor.constraint(equalTo: self.frontDocumentBaseView.topAnchor),
            self.frontDocumentStackView.bottomAnchor.constraint(equalTo: self.frontDocumentBaseView.bottomAnchor),

            self.frontPrePickImageView.leadingAnchor.constraint(equalTo: self.frontPrePickView.leadingAnchor, constant: 14),
            self.frontPrePickImageView.topAnchor.constraint(equalTo: self.frontPrePickView.topAnchor, constant: 12),
            self.frontPrePickImageView.bottomAnchor.constraint(equalTo: self.frontPrePickView.bottomAnchor, constant: -12),
            self.frontPrePickImageView.widthAnchor.constraint(equalToConstant: 32),
            self.frontPrePickImageView.heightAnchor.constraint(equalTo: self.frontPrePickImageView.widthAnchor),

            self.frontPrePickTitleLabel.leadingAnchor.constraint(equalTo: self.frontPrePickImageView.trailingAnchor, constant: 9),
            self.frontPrePickTitleLabel.trailingAnchor.constraint(equalTo: self.frontPrePickView.trailingAnchor, constant: -14),
            self.frontPrePickTitleLabel.centerYAnchor.constraint(equalTo: self.frontPrePickImageView.centerYAnchor),

            self.frontPickedTitleLabel.leadingAnchor.constraint(equalTo: self.frontPickedView.leadingAnchor, constant: 14),
            self.frontPickedTitleLabel.topAnchor.constraint(equalTo: self.frontPickedView.topAnchor, constant: 20),
            self.frontPickedTitleLabel.bottomAnchor.constraint(equalTo: self.frontPickedView.bottomAnchor, constant: -20),

            self.frontPickedRemoveButton.trailingAnchor.constraint(equalTo: self.frontPickedView.trailingAnchor, constant: -14),
            self.frontPickedRemoveButton.leadingAnchor.constraint(equalTo: self.frontPickedTitleLabel.trailingAnchor, constant: 8),
            self.frontPickedRemoveButton.widthAnchor.constraint(equalToConstant: 40),
            self.frontPickedRemoveButton.heightAnchor.constraint(equalTo: self.frontPickedRemoveButton.widthAnchor),
            self.frontPickedRemoveButton.centerYAnchor.constraint(equalTo: self.frontPickedView.centerYAnchor)
        ])

        // Back Document Views
        NSLayoutConstraint.activate([
            self.backDocumentBaseView.leadingAnchor.constraint(equalTo: self.uploadStackView.leadingAnchor),
            self.backDocumentBaseView.trailingAnchor.constraint(equalTo: self.uploadStackView.trailingAnchor),
            self.backDocumentBaseView.heightAnchor.constraint(equalToConstant: 56),

            self.backDocumentStackView.leadingAnchor.constraint(equalTo: self.backDocumentBaseView.leadingAnchor),
            self.backDocumentStackView.trailingAnchor.constraint(equalTo: self.backDocumentBaseView.trailingAnchor),
            self.backDocumentStackView.topAnchor.constraint(equalTo: self.backDocumentBaseView.topAnchor),
            self.backDocumentStackView.bottomAnchor.constraint(equalTo: self.backDocumentBaseView.bottomAnchor),

            self.backPrePickImageView.leadingAnchor.constraint(equalTo: self.backPrePickView.leadingAnchor, constant: 14),
            self.backPrePickImageView.topAnchor.constraint(equalTo: self.backPrePickView.topAnchor, constant: 12),
            self.backPrePickImageView.bottomAnchor.constraint(equalTo: self.backPrePickView.bottomAnchor, constant: -12),
            self.backPrePickImageView.widthAnchor.constraint(equalToConstant: 32),
            self.backPrePickImageView.heightAnchor.constraint(equalTo: self.backPrePickImageView.widthAnchor),

            self.backPrePickTitleLabel.leadingAnchor.constraint(equalTo: self.backPrePickImageView.trailingAnchor, constant: 9),
            self.backPrePickTitleLabel.trailingAnchor.constraint(equalTo: self.backPrePickView.trailingAnchor, constant: -14),
            self.backPrePickTitleLabel.centerYAnchor.constraint(equalTo: self.backPrePickImageView.centerYAnchor),

            self.backPickedTitleLabel.leadingAnchor.constraint(equalTo: self.backPickedView.leadingAnchor, constant: 14),
            self.backPickedTitleLabel.topAnchor.constraint(equalTo: self.backPickedView.topAnchor, constant: 20),
            self.backPickedTitleLabel.bottomAnchor.constraint(equalTo: self.backPickedView.bottomAnchor, constant: -20),

            self.backPickedRemoveButton.trailingAnchor.constraint(equalTo: self.backPickedView.trailingAnchor, constant: -14),
            self.backPickedRemoveButton.leadingAnchor.constraint(equalTo: self.backPickedTitleLabel.trailingAnchor, constant: 8),
            self.backPickedRemoveButton.widthAnchor.constraint(equalToConstant: 40),
            self.backPickedRemoveButton.heightAnchor.constraint(equalTo: self.backPickedRemoveButton.widthAnchor),
            self.backPickedRemoveButton.centerYAnchor.constraint(equalTo: self.backPickedView.centerYAnchor)
        ])

    }
}
