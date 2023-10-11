//
//  ReferralQRCodeViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 14/07/2023.
//

import UIKit
import CoreImage

class ReferralQRCodeViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var qrCodeImageView: UIImageView = Self.createQRCodeImageView()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    // MARK: - Lifetime and Cycle
    init() {
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

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        // QR Code for url
        if let url = URL(string: "\(TargetVariables.clientBaseUrl)") {
            if let qrCodeImage = generateQRCodeImageFromURL(for: url, size: CGSize(width: 200, height: 200)) {

                self.qrCodeImageView.image = qrCodeImage
            } else {
                print("Failed to generate QR code image from URL")
            }
        }

        // QR Code for text
//        if let qrCodeImage = generateQRCodeImageFromText(from: "Betsson.FR", size: CGSize(width: 200, height: 200)) {
//
//            self.qrCodeImageView.image = qrCodeImage
//        }
//        else {
//            print("Failed to generate QR code image from text")
//        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor(hex: 0x111619, alpha: 0.8)

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.highlightPrimary

        self.descriptionLabel.textColor = UIColor.App.textPrimary

        self.qrCodeImageView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.closeButton)

    }

    // MARK: Functions
    func generateQRCodeImageFromURL(for url: URL, size: CGSize) -> UIImage? {
        // Convert URL to string
        let urlString = url.absoluteString

        // Create QR code filter
        guard let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        // Set input data as URL string
        guard let data = urlString.data(using: .utf8) else {
            return nil
        }
        qrCodeFilter.setValue(data, forKey: "inputMessage")

        // Set input correction level (optional)
        qrCodeFilter.setValue("M", forKey: "inputCorrectionLevel")

        // Generate QR code image
        guard let qrCodeImage = qrCodeFilter.outputImage else {
            return nil
        }

        // Scale the image to the desired size
        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let scaledImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        let qrCodeUIImage = UIImage(cgImage: cgImage)

        return qrCodeUIImage
    }

    func generateQRCodeImageFromText(from text: String, size: CGSize) -> UIImage? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }

        // Create QR code filter
        guard let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        // Set input data
        qrCodeFilter.setValue(data, forKey: "inputMessage")

        // Set input correction level (optional)
        qrCodeFilter.setValue("M", forKey: "inputCorrectionLevel")

        // Generate QR code image
        guard let qrCodeImage = qrCodeFilter.outputImage else {
            return nil
        }

        // Scale the image to the desired size
        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let scaledImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        let qrCodeUIImage = UIImage(cgImage: cgImage)

        return qrCodeUIImage
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}

extension ReferralQRCodeViewController {
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

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("qr_code")
        label.font = AppFont.with(type: .bold, size: 18)
        label.numberOfLines = 0
        return label
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("qr_code_description")
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    private static func createQRCodeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.layer.cornerRadius = CornerRadius.button
        button.contentEdgeInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 30.0)
        return button
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.containerView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)
        self.containerView.addSubview(self.qrCodeImageView)
        self.containerView.addSubview(self.closeButton)

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

        // Container view
        NSLayoutConstraint.activate([

            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            self.containerView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor, constant: 80)
        ])

        // Top info
        NSLayoutConstraint.activate([

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 40),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),

            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),

            self.qrCodeImageView.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 30),
            self.qrCodeImageView.widthAnchor.constraint(equalToConstant: 200),
            self.qrCodeImageView.heightAnchor.constraint(equalTo: self.qrCodeImageView.widthAnchor),
            self.qrCodeImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),

            self.closeButton.topAnchor.constraint(equalTo: self.qrCodeImageView.bottomAnchor, constant: 30),
            self.closeButton.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.closeButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -30)
        ])

    }
}
