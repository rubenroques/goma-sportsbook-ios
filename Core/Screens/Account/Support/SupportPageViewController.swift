//
//  SupportPageViewController.swift
//  ShowcaseProd
//
//  Created by Teresa on 01/06/2022.
//

import UIKit
import Combine
import WebKit

class SupportPageViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var backButtonBaseView: UIView = Self.createBackButtonBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var anonymousFieldsView: UIView = Self.createAnonymousFieldsView()
    private lazy var firstNameHeaderTextFieldView: HeaderTextFieldView = Self.createFirstNameHeaderTextFieldView()
    private lazy var lastNameHeaderTextFieldView: HeaderTextFieldView = Self.createLastNameHeaderTextFieldView()
    private lazy var emailHeaderTextFieldView: HeaderTextFieldView = Self.createEmailHeaderTextFieldView()
    private lazy var subjectTypeSelectionView: TitleDropdownView = Self.createSubjectTypeSelectionView()
    private lazy var subjectTextField: HeaderTextFieldView = Self.createSubjectTextField()
    private lazy var descriptionView: UIView = Self.createDescriptionBaseView()
    private lazy var descriptionPlaceholderLabel: UILabel = Self.createDescriptionPlaceholderLabel()
    private lazy var descriptionTextView: UITextView = Self.createDescriptionTextView()
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var sendButton: UIButton = Self.createSendButton()

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
//        let js = "document.getElementsByClassName('.sc-htpNat')[0].addEventListener('click', function(){ window.webkit.messageHandlers.clickListener.postMessage('Do something'); })"
        let js = """
        document.addEventListener('click', function(evt) {
        var tagClicked = document.elementFromPoint(evt.clientX, evt.clientY);
        window.webkit.messageHandlers.clickListener.postMessage(tagClicked.outerHTML.toString());
        })
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)

        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "clickListener")

        let webview = WKWebView(frame: .zero, configuration: config)
        webview.translatesAutoresizingMaskIntoConstraints = false

        return webview
    }()

    // Constraints
    private lazy var anonymousViewTopConstraint: NSLayoutConstraint = Self.createAnonymousViewTopConstraint()
    private lazy var subjectViewTopConstraint: NSLayoutConstraint = Self.createSubjectViewTopConstraint()
    private lazy var webViewWidthConstraint: NSLayoutConstraint = Self.createWebViewWidthConstraint()
    private lazy var webViewHeightConstraint: NSLayoutConstraint = Self.createWebViewHeightConstraint()
    private lazy var webViewLeadingConstraint: NSLayoutConstraint = Self.createWebViewLeadingConstraint()
    private lazy var webViewTopConstraint: NSLayoutConstraint = Self.createWebViewTopConstraint()

    private let viewModel: SupportPageViewModel
    var cancellables = Set<AnyCancellable>()

    var isAnonymous: Bool = false {
        didSet {
            self.anonymousFieldsView.isHidden = !isAnonymous
            self.subjectViewTopConstraint.isActive = !isAnonymous
            self.anonymousViewTopConstraint.isActive = isAnonymous
        }
    }

    var hasSupportDetails: CurrentValueSubject<Bool, Never> = .init(false)
   
    // MARK: - Lifetime and Cycle
    init(viewModel: SupportPageViewModel) {
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
        self.commonInit()

        self.bind(toViewModel: self.viewModel)

        if Env.userSessionStore.isUserLogged() {
            self.isAnonymous = false
        }
        else {
            self.isAnonymous = true
        }

        self.webView.navigationDelegate = self
        
        let zendeskSupportFile = "zendesk_support.html"
        let fileStringSplit = zendeskSupportFile.components(separatedBy: ".")

        let filePath = Bundle.main.path(forResource: fileStringSplit[0], ofType: fileStringSplit[1])
        let contentData = FileManager.default.contents(atPath: filePath!)

        if let htmlTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String {

            let bundleUrl = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1])

            self.webView.loadHTMLString(htmlTemplate, baseURL: bundleUrl)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    func commonInit() {
        self.descriptionTextView.delegate = self
        
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        let tapBackButtonGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackButton))
        self.backButtonBaseView.addGestureRecognizer(tapBackButtonGestureRecognizer)
        
        let tapBackgroundGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.baseView.addGestureRecognizer(tapBackgroundGestureRecognizer)
        
        self.sendButton.isUserInteractionEnabled = true
        let tapSendButton = UITapGestureRecognizer(target: self, action: #selector(self.didTapSend))
        self.sendButton.addGestureRecognizer(tapSendButton)
        StyleHelper.styleButton(button: self.sendButton)

        if Env.userSessionStore.isUserLogged() {
            Publishers.CombineLatest(self.subjectTextField.textPublisher, self.descriptionTextView.textPublisher)
                .map { subjectText, descriptionViewText in
                    if subjectText?.isNotEmpty ?? false && descriptionViewText?.isNotEmpty ?? false {

                        return true
                    }

                    return false
                }
                .assign(to: \.isEnabled, on: self.sendButton)
                .store(in: &self.cancellables)
        }
        else {
            Publishers.CombineLatest(self.subjectTextField.textPublisher, self.descriptionTextView.textPublisher)
                .sink(receiveValue: { [weak self] subjectText, descriptionText in

                    if subjectText != "" && descriptionText != "" {
                        self?.hasSupportDetails.send(true)
                    }
                    else {
                        self?.hasSupportDetails.send(false)
                    }
                })
                .store(in: &self.cancellables)

            Publishers.CombineLatest4(self.hasSupportDetails,
                                      self.firstNameHeaderTextFieldView.textPublisher,
                                      self.lastNameHeaderTextFieldView.textPublisher,
                                      self.emailHeaderTextFieldView.textPublisher)
                .map { hasSuportDetails, firstNameText, lastNameText, emailText in
                    if hasSuportDetails && firstNameText?.isNotEmpty ?? false && lastNameText?.isNotEmpty ?? false && emailText?.isNotEmpty ?? false {

                        return true
                    }

                    return false
                }
                .assign(to: \.isEnabled, on: self.sendButton)
                .store(in: &self.cancellables)
        }

    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.anonymousFieldsView.backgroundColor = .clear

        self.firstNameHeaderTextFieldView.backgroundColor = .clear
        self.firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.textSecondary)
        self.firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        self.firstNameHeaderTextFieldView.setSecureField(false)
        self.firstNameHeaderTextFieldView.textField.font = AppFont.with(type: .semibold, size: 15)
        self.firstNameHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        self.firstNameHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.lastNameHeaderTextFieldView.backgroundColor = .clear
        self.lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.textSecondary)
        self.lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        self.lastNameHeaderTextFieldView.setSecureField(false)
        self.lastNameHeaderTextFieldView.textField.font = AppFont.with(type: .semibold, size: 15)
        self.lastNameHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        self.lastNameHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.emailHeaderTextFieldView.backgroundColor = .clear
        self.emailHeaderTextFieldView.setHeaderLabelColor(UIColor.App.textSecondary)
        self.emailHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        self.emailHeaderTextFieldView.setSecureField(false)
        self.emailHeaderTextFieldView.textField.font = AppFont.with(type: .semibold, size: 15)
        self.emailHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        self.emailHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.subjectTypeSelectionView.setViewColor(UIColor.App.backgroundPrimary)
        self.subjectTypeSelectionView.setViewBorderColor(UIColor.App.inputTextTitle)
        
        self.subjectTextField.backgroundColor = .clear
        self.subjectTextField.setHeaderLabelColor(UIColor.App.textSecondary)
        self.subjectTextField.setTextFieldColor(UIColor.App.textPrimary)
        self.subjectTextField.setSecureField(false)
        self.subjectTextField.textField.font = AppFont.with(type: .semibold, size: 15)
        self.subjectTextField.setViewColor(UIColor.App.backgroundPrimary)
        self.subjectTextField.setViewBorderColor(UIColor.App.inputTextTitle)
        
        self.descriptionView.backgroundColor = UIColor.App.backgroundPrimary
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor.App.inputTextTitle.cgColor
        
        self.descriptionTextView.backgroundColor = .clear
        self.descriptionPlaceholderLabel.backgroundColor = .clear
        self.descriptionPlaceholderLabel.textColor = UIColor.App.textSecondary
        self.descriptionTextView.textColor = UIColor.App.textPrimary
        
        self.backButtonBaseView.backgroundColor = .clear

        self.webView.isOpaque = false
        self.webView.backgroundColor = .clear
        self.webView.scrollView.backgroundColor = UIColor.clear

    }

    // MARK: Binding
    private func bind(toViewModel viewModel: SupportPageViewModel) {

        viewModel.supportResponseAction = { [weak self] withSuccess, message in

            if withSuccess {
                self?.didTapBackButton()
            }
            else {
                if let message {
                    self?.showSimpleAlert(title: localized("error"), message: message)
                }
            }

        }

    }
    
    // MARK: - Actions
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.firstNameHeaderTextFieldView.resignFirstResponder()
        self.lastNameHeaderTextFieldView.resignFirstResponder()
        self.emailHeaderTextFieldView.resignFirstResponder()
        self.subjectTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        
    }
    
    @objc func didTapSend() {

        if Env.userSessionStore.isUserLogged() {

            let subjectType = self.subjectTypeSelectionView.text
            let subjectText = self.subjectTextField.text

            let title = "\(subjectType) - \(subjectText)"

            self.viewModel.sendEmail(title: title, message: self.descriptionTextView.text)
        }
        else {
            let subjectType = self.subjectTypeSelectionView.text
            let subjectText = self.subjectTextField.text

            let title = "\(subjectType) - \(subjectText)"

            self.viewModel.sendEmail(title: title,
                                     message: self.descriptionTextView.text,
                                     firstName: self.firstNameHeaderTextFieldView.text,
                                     lastName: self.lastNameHeaderTextFieldView.text,
                                     email: self.emailHeaderTextFieldView.text)
        }

    }

}

extension SupportPageViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("STARTING LOADING ZENDESK")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("FINISHED LOADING ZENDESK")

    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("FAILED LOADING ZENDESK")

    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension SupportPageViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createBackButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createNavigationBaseView() -> UIView {
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
    
    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("support")
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createAnonymousFieldsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFirstNameHeaderTextFieldView() -> HeaderTextFieldView {
        let textField = HeaderTextFieldView()
        textField.setPlaceholderText(localized("first_name"))
        return textField
    }

    private static func createLastNameHeaderTextFieldView() -> HeaderTextFieldView {
        let textField = HeaderTextFieldView()
        textField.setPlaceholderText(localized("last_name"))
        return textField
    }

    private static func createEmailHeaderTextFieldView() -> HeaderTextFieldView {
        let textField = HeaderTextFieldView()
        textField.setPlaceholderText(localized("email"))
        textField.keyboardType = .emailAddress
        return textField
    }

    private static func createSubjectTypeSelectionView() -> TitleDropdownView {
        let dropDownSelectionView = TitleDropdownView()
        dropDownSelectionView.translatesAutoresizingMaskIntoConstraints = false
        dropDownSelectionView.setTitle(localized("request_concerns"))
        dropDownSelectionView.setSelectionPicker([localized("register"),
                                                  localized("my_account"),
                                                  localized("bonus_and_promotions"),
                                                  localized("deposits"),
                                                  localized("withdraws"),
                                                  localized("responsible_gaming_title"),
                                                  localized("betting_rules"),
                                                  localized("other")])
        return dropDownSelectionView
    }
    
    private static func createDescriptionPlaceholderLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = localized("description")
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private static func createSubjectTextField() -> HeaderTextFieldView {
        let subjectTextField = HeaderTextFieldView()
        subjectTextField.setPlaceholderText(localized("subject"))
     
        return subjectTextField
    }
    
    private static func createDescriptionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDescriptionTextView() -> UITextView {
        let descriptionTextView = UITextView()
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.isEditable = true
        descriptionTextView.font = AppFont.with(type: .regular, size: 15)
        descriptionTextView.text = localized("")
        descriptionTextView.textAlignment = .left
        
        return descriptionTextView
    }
    
    private static func createSendButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitle("Send", for: .disabled)
        sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        sendButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        sendButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        sendButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        
        return sendButton
    }

    private static func createWebView() -> WKWebView {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false

        return webView
    }

    private static func createAnonymousViewTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createSubjectViewTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    private static func createWebViewWidthConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createWebViewHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createWebViewLeadingConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createWebViewTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private func setupSubviews() {

        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButtonBaseView)
        
        self.backButtonBaseView.addSubview(self.backButton)
        
        self.descriptionView.addSubview(self.descriptionPlaceholderLabel)
        self.descriptionView.addSubview(self.descriptionTextView)

        self.baseView.addSubview(self.anonymousFieldsView)

        self.anonymousFieldsView.addSubview(self.firstNameHeaderTextFieldView)
        self.anonymousFieldsView.addSubview(self.lastNameHeaderTextFieldView)
        self.anonymousFieldsView.addSubview(self.emailHeaderTextFieldView)

        self.baseView.addSubview(self.subjectTypeSelectionView)
        self.baseView.addSubview(self.subjectTextField)
        self.baseView.addSubview(self.descriptionView)
        self.baseView.addSubview(self.sendButton)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.baseView)
        self.view.addSubview(self.navigationBaseView)

        self.view.addSubview(self.webView)

        self.initConstraints()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            
            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.backButtonBaseView.centerYAnchor),

            self.backButtonBaseView.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 27),
            self.backButtonBaseView.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButtonBaseView.heightAnchor.constraint(equalToConstant: 20),
            self.backButtonBaseView.widthAnchor.constraint(equalToConstant: 20),
        ])
        
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.anonymousFieldsView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 15),
            self.anonymousFieldsView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -15),
            self.anonymousFieldsView.bottomAnchor.constraint(equalTo: self.subjectTypeSelectionView.topAnchor, constant: 0),

            self.firstNameHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.anonymousFieldsView.leadingAnchor, constant: 15),
            self.firstNameHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.anonymousFieldsView.centerXAnchor, constant: -4),
            self.firstNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 90),
            self.firstNameHeaderTextFieldView.topAnchor.constraint(equalTo: self.anonymousFieldsView.topAnchor, constant: 10),

            self.lastNameHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.anonymousFieldsView.centerXAnchor, constant: 4),
            self.lastNameHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.anonymousFieldsView.trailingAnchor, constant: -15),
            self.lastNameHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 90),
            self.lastNameHeaderTextFieldView.topAnchor.constraint(equalTo: self.firstNameHeaderTextFieldView.topAnchor),

            self.emailHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.anonymousFieldsView.leadingAnchor, constant: 15),
            self.emailHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.anonymousFieldsView.trailingAnchor, constant: -15),
            self.emailHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 90),
            self.emailHeaderTextFieldView.topAnchor.constraint(equalTo: self.firstNameHeaderTextFieldView.bottomAnchor, constant: 10),
            self.emailHeaderTextFieldView.bottomAnchor.constraint(equalTo: self.anonymousFieldsView.bottomAnchor, constant: -10),

            self.subjectTypeSelectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 28),
            self.subjectTypeSelectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -28),
            //self.subjectTypeSelectionView.heightAnchor.constraint(equalToConstant: 90),
            
            self.subjectTextField.topAnchor.constraint(equalTo: self.subjectTypeSelectionView.bottomAnchor, constant: 30),
            self.subjectTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 28),
            self.subjectTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -28),
            self.subjectTextField.heightAnchor.constraint(equalToConstant: 90),
            
            self.sendButton.heightAnchor.constraint(equalToConstant: 51),
            self.sendButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 28),
            self.sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -28),
            self.sendButton.topAnchor.constraint(equalTo: self.descriptionView.bottomAnchor, constant: 23),
        ])
        
        NSLayoutConstraint.activate([
            self.descriptionView.topAnchor.constraint(equalTo: self.subjectTextField.bottomAnchor, constant: 10),
            self.descriptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 28),
            self.descriptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -28),
            self.descriptionView.heightAnchor.constraint(equalToConstant: 274),
            
            self.descriptionPlaceholderLabel.topAnchor.constraint(equalTo: self.descriptionView.topAnchor, constant: 15),
            self.descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: self.descriptionView.leadingAnchor, constant: 18),
            self.descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: self.descriptionView.trailingAnchor, constant: -8),
            self.descriptionPlaceholderLabel.bottomAnchor.constraint(equalTo: self.descriptionTextView.topAnchor),
            
            self.descriptionTextView.topAnchor.constraint(equalTo: self.descriptionView.topAnchor, constant: 32),
            self.descriptionTextView.leadingAnchor.constraint(equalTo: self.descriptionView.leadingAnchor, constant: 16),
            self.descriptionTextView.trailingAnchor.constraint(equalTo: self.descriptionView.trailingAnchor, constant: -17),
            self.descriptionTextView.bottomAnchor.constraint(equalTo: self.descriptionView.bottomAnchor, constant: -53),
            
        ])

        NSLayoutConstraint.activate([
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        self.webViewWidthConstraint = self.webView.widthAnchor.constraint(equalToConstant: 100)
        self.webViewWidthConstraint.isActive = true

        self.webViewHeightConstraint = self.webView.heightAnchor.constraint(equalToConstant: 100)
        self.webViewHeightConstraint.isActive = true

        self.webViewLeadingConstraint = self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        self.webViewLeadingConstraint.isActive = false

        self.webViewTopConstraint = self.webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        self.webViewTopConstraint.isActive = false

        self.anonymousViewTopConstraint = self.anonymousFieldsView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30)
        self.anonymousViewTopConstraint.isActive = false

        self.subjectViewTopConstraint = self.subjectTypeSelectionView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30)
        self.subjectViewTopConstraint.isActive = true
        
    }

}

extension SupportPageViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor.App.textPrimary.cgColor
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1

        if descriptionTextView.text == "" {
            self.descriptionView.layer.borderColor = UIColor.App.inputTextTitle.cgColor
        }
        else {
            self.descriptionView.layer.borderColor = UIColor.App.textPrimary.cgColor
        }
        
    }

}

extension SupportPageViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if "\(message.body)".contains("sc-vrqbdz-5 eQUhzA") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
                    self.webViewWidthConstraint.isActive = true
                    self.webViewHeightConstraint.isActive = true
                    self.webViewLeadingConstraint.isActive = false
                    self.webViewTopConstraint.isActive = false
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }

        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0.25, options: UIView.AnimationOptions.curveEaseOut) {
                self.webViewWidthConstraint.isActive = false
                self.webViewHeightConstraint.isActive = false
                self.webViewLeadingConstraint.isActive = true
                self.webViewTopConstraint.isActive = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }

    }
}
