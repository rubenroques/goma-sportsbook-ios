//
//  SocialUserQRCodeViewController.swift
//  MultiBet
//
//  Created by André Lascas on 14/11/2024.
//

import UIKit
import Combine

enum QRCodeAlert {
    case success(username: String)
    case error
}

class SocialUserQRCodeViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    var friendCodeInvalidPublisher: PassthroughSubject<Void, Never> = .init()
    var didAddFriend: ((QRCodeAlert) -> Void)?
    
    init() {
        
    }
    
    func searchFriendFromQRCode(code: String) {
        
        Env.servicesProvider.searchUserWithCode(code: code)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SEARCH FRIEND ERROR: \(error)")
//                    self?.didAddFriend?(.invalid)
                    self?.friendCodeInvalidPublisher.send()
                case .finished:
                    print("SEARCH FRIEND FINISHED")
                }

            }, receiveValue: { [weak self] searchUser in
                print("SEARCH FRIEND GOMA: \(searchUser)")

                self?.addFriendFromId(id: "\(searchUser.id)", username: searchUser.username)

                
            })
            .store(in: &cancellables)
        
    }
    
    func addFriendFromId(id: String, username: String) {
        
        Env.servicesProvider.addFriends(userIds: [id])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND ERROR: \(error)")
                    self?.didAddFriend?(.error)
                case .finished:
                    print("ADD FRIEND FINISHED")
                }

            }, receiveValue: { [weak self] addFriendResponse in
                print("ADD FRIEND GOMA: \(addFriendResponse)")
                
                self?.didAddFriend?(.success(username: username))
            })
            .store(in: &cancellables)
    
    }
    
    func processQRCode(code: String) {
        let pattern = "/friend-code/([A-Z0-9]+)"
        let regex = try? NSRegularExpression(pattern: pattern)

        if let match = regex?.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)) {
            if let range = Range(match.range(at: 1), in: code) {
                let extractedCode = String(code[range])
                self.searchFriendFromQRCode(code: extractedCode)
            }
        }
        else {
//            self.didAddFriend?(.invalid)
            self.friendCodeInvalidPublisher.send()
        }
    }
}

class SocialUserQRCodeViewController: UIViewController {
    
    // MARK: Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var qrCodeImageView: UIImageView = Self.createQRCodeImageView()
    private lazy var qrCodeTitleLabel: UILabel = Self.createQRCodeTitleLabel()
    private lazy var qrCodeSubtitleLabel: UILabel = Self.createQRCodeSubtitleLabel()
    private lazy var shareButton: UIButton = Self.createShareButton()
    private lazy var scanFriendBaseView: UIView = Self.createScanFriendBaseView()
    private lazy var scanFriendTitleLabel: UILabel = Self.createScanFriendTitleLabel()
    private lazy var scanFriendIconView: UIView = Self.createScanFriendIconView()
    private lazy var scanFriendImageView: UIImageView = Self.createScanFriendImageView()
    private lazy var scanFriendSubtitleLabel: UILabel = Self.createScanFriendSubtitleLabel()
    
    private let viewModel: SocialUserQRCodeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var chatListNeedsReload: (() -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: SocialUserQRCodeViewModel) {
        
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
        
        // QR Code for url
        if let userCode = Env.userSessionStore.userProfilePublisher.value?.godfatherCode,
           let url = URL(string: "\(TargetVariables.clientBaseUrl)/en/friend-code/\(userCode)") {
            if let qrCodeImage = self.generateQRCodeImageFromURL(for: url, size: CGSize(width: 200, height: 200)) {

                self.qrCodeImageView.image = qrCodeImage
            } else {
                print("Failed to generate QR code image from URL")
            }
        }

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        
        self.shareButton.addTarget(self, action: #selector(didTapShareCodeButton), for: .primaryActionTriggered)

        let scanQRCodeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScanQRCode))
        self.scanFriendIconView.addGestureRecognizer(scanQRCodeGesture)
        
        self.bind(toViewModel: self.viewModel)

    }
    
    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        self.scanFriendIconView.layer.cornerRadius = CornerRadius.button

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundSecondary

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.navigationView.backgroundColor = UIColor.App.backgroundSecondary

        self.backButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.qrCodeImageView.backgroundColor = .clear
        
        self.qrCodeTitleLabel.textColor = UIColor.App.highlightTertiary
        
        self.qrCodeSubtitleLabel.textColor = UIColor.App.textPrimary
        
        StyleHelper.styleButtonWithTheme(button: self.shareButton,
                                         titleColor: UIColor.App.buttonTextPrimary,
                                         titleDisabledColor: UIColor.App.buttonTextPrimary,
                                         backgroundColor: UIColor.App.buttonBackgroundPrimary,
                                         backgroundHighlightedColor: UIColor.App.buttonBackgroundPrimary)
        
        self.scanFriendBaseView.backgroundColor = .clear

        self.scanFriendTitleLabel.textColor = UIColor.App.textSecondary
        
        self.scanFriendIconView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.scanFriendImageView.backgroundColor = .clear
        
        self.scanFriendSubtitleLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: SocialUserQRCodeViewModel) {
        
        viewModel.didAddFriend = { [weak self] qrCodeAlert in
            
            self?.showAlert(qrCodeAlert: qrCodeAlert)
        }
        
        viewModel.friendCodeInvalidPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.showInvalidCodeAlert()
            })
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    private func showAlert(qrCodeAlert: QRCodeAlert) {
        
        print("View hierarchy check: isViewLoaded = \(self.isViewLoaded), window = \(self.view.window != nil)")

        switch qrCodeAlert {
        case .success(let username):
            
            self.chatListNeedsReload?()
            
            let successCodeAlert = UIAlertController(title: localized("success"),
                                                     message: localized("user_has_received_friend_request").replacingFirstOccurrence(of: "{username}", with: username),
                                                       preferredStyle: UIAlertController.Style.alert)

            successCodeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(successCodeAlert, animated: true, completion: nil)
        case .error:
            let errorFriendAlert = UIAlertController(title: localized("friend_added_error"),
                                                       message: localized("friend_added_message_error"),
                                                       preferredStyle: UIAlertController.Style.alert)

            errorFriendAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

            self.present(errorFriendAlert, animated: true, completion: nil)
//        case .invalid:
//            let invalidCodeAlert = UIAlertController(title: localized("invalid_code"),
//                                                       message: localized("invalid_code_message"),
//                                                       preferredStyle: UIAlertController.Style.alert)
//
//            invalidCodeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))
//
//            self.present(invalidCodeAlert, animated: true, completion: nil)
        }
    }
    
    private func showInvalidCodeAlert() {
        let invalidCodeAlert = UIAlertController(title: localized("invalid_code"),
                                                   message: localized("invalid_code_message"),
                                                   preferredStyle: UIAlertController.Style.alert)

        invalidCodeAlert.addAction(UIAlertAction(title: localized("ok"), style: .default))

        self.present(invalidCodeAlert, animated: true, completion: nil)
    }
    
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
    
    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareCodeButton() {
        
        let renderer = UIGraphicsImageRenderer(size: self.qrCodeImageView.bounds.size)
        let image = renderer.image { _ in
            self.qrCodeImageView.drawHierarchy(in: self.qrCodeImageView.bounds, afterScreenUpdates: true)
        }
        
        let text = "Add me as your friend in Goma Demo!"
        
        let shareActivityViewController = UIActivityViewController(activityItems: [text, image],
                                                                   applicationActivities: nil)
        if let popoverController = shareActivityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(shareActivityViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapScanQRCode() {
        let scannerVC = QRScannerViewController()
        let navigationController = UINavigationController(rootViewController: scannerVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        scannerVC.didScanQRCode = { [weak self] code in
            print("SCANNED: \(code)")
            self?.viewModel.processQRCode(code: code)
        }
        
        present(navigationController, animated: true)
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension SocialUserQRCodeViewController {
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

    private static func createBackButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = localized("add_friend")
        return label
    }
    
    private static func createQRCodeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createQRCodeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        label.text = localized("this_is_your_qr_code")
        return label
    }
    
    private static func createQRCodeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.text = localized("share_it_with_a_friend_so_they_can_add_you")
        return label
    }
    
    private static func createShareButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("share_it"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
        return button
    }

    private static func createScanFriendBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScanFriendTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.text = localized("someone_sent_you_a_code_instead")
        return label
    }
    
    private static func createScanFriendIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createScanFriendImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "scan_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createScanFriendSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        label.text = localized("read_qr_code")
        return label
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)
        
        self.view.addSubview(self.qrCodeImageView)
        self.view.addSubview(self.qrCodeTitleLabel)
        self.view.addSubview(self.qrCodeSubtitleLabel)
        self.view.addSubview(self.shareButton)
        
        self.view.addSubview(self.scanFriendBaseView)

        self.scanFriendBaseView.addSubview(self.scanFriendTitleLabel)
        
        self.scanFriendBaseView.addSubview(self.scanFriendIconView)
        
        self.scanFriendIconView.addSubview(self.scanFriendImageView)
        
        self.scanFriendBaseView.addSubview(self.scanFriendSubtitleLabel)
        
        self.view.addSubview(self.bottomSafeAreaView)

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

        // Navigation View
        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.heightAnchor.constraint(equalTo: self.navigationView.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 0),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor)

        ])

        // Content
        NSLayoutConstraint.activate([
            self.qrCodeImageView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20),
            self.qrCodeImageView.widthAnchor.constraint(equalToConstant: 250),
            self.qrCodeImageView.heightAnchor.constraint(equalTo: self.qrCodeImageView.widthAnchor),
            self.qrCodeImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            self.qrCodeTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.qrCodeTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.qrCodeTitleLabel.topAnchor.constraint(equalTo: self.qrCodeImageView.bottomAnchor, constant: 15),
            
            self.qrCodeSubtitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.qrCodeSubtitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.qrCodeSubtitleLabel.topAnchor.constraint(equalTo: self.qrCodeTitleLabel.bottomAnchor, constant: 4),
            
            self.shareButton.heightAnchor.constraint(equalToConstant: 30),
            self.shareButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.shareButton.topAnchor.constraint(equalTo: self.qrCodeSubtitleLabel.bottomAnchor, constant: 15),
            
        ])

        // Add Friend Button View
        NSLayoutConstraint.activate([
            self.scanFriendBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scanFriendBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scanFriendBaseView.topAnchor.constraint(greaterThanOrEqualTo: self.shareButton.bottomAnchor, constant: 20),
            self.scanFriendBaseView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            
            self.scanFriendTitleLabel.leadingAnchor.constraint(equalTo: self.scanFriendBaseView.leadingAnchor, constant: 15),
            self.scanFriendTitleLabel.trailingAnchor.constraint(equalTo: self.scanFriendBaseView.trailingAnchor, constant: -15),
            self.scanFriendTitleLabel.topAnchor.constraint(equalTo: self.scanFriendBaseView.topAnchor, constant: 2),
            
            self.scanFriendIconView.topAnchor.constraint(equalTo: self.scanFriendTitleLabel.bottomAnchor, constant: 15),
            self.scanFriendIconView.widthAnchor.constraint(equalToConstant: 55),
            self.scanFriendIconView.heightAnchor.constraint(equalTo: self.scanFriendIconView.widthAnchor),
            self.scanFriendIconView.centerXAnchor.constraint(equalTo: self.scanFriendBaseView.centerXAnchor),
            
            self.scanFriendImageView.centerXAnchor.constraint(equalTo: self.scanFriendIconView.centerXAnchor),
            self.scanFriendImageView.centerYAnchor.constraint(equalTo: self.scanFriendIconView.centerYAnchor),
            self.scanFriendImageView.widthAnchor.constraint(equalToConstant: 32),
            self.scanFriendImageView.heightAnchor.constraint(equalTo: self.scanFriendImageView.widthAnchor),
            
            self.scanFriendSubtitleLabel.leadingAnchor.constraint(equalTo: self.scanFriendBaseView.leadingAnchor, constant: 15),
            self.scanFriendSubtitleLabel.trailingAnchor.constraint(equalTo: self.scanFriendBaseView.trailingAnchor, constant: -15),
            self.scanFriendSubtitleLabel.topAnchor.constraint(equalTo: self.scanFriendIconView.bottomAnchor, constant: 8),
            self.scanFriendSubtitleLabel.bottomAnchor.constraint(equalTo: self.scanFriendBaseView.bottomAnchor, constant: -15)
            
        ])

    }
}
