//
//  SupportPageViewController.swift
//  ShowcaseProd
//
//  Created by Teresa on 01/06/2022.
//

import UIKit
import Combine

class SupportPageViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var backButtonBaseView: UIView = Self.createBackButtonBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subjectTextField: HeaderTextFieldView = Self.createSubjectTextField()
    private lazy var descriptionView: UIView = Self.createDescriptionBaseView()
    private lazy var descriptionPlaceholderLabel: UILabel = Self.createDescriptionPlaceholderLabel()
    private lazy var descriptionTextView: UITextView = Self.createDescriptionTextView()
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var sendButton: UIButton = Self.createSendButton()
   
    private let viewModel: SupportPageViewModel
    var cancellables = Set<AnyCancellable>()
   
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

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.subjectTextField.backgroundColor = .clear
        self.subjectTextField.setHeaderLabelColor(UIColor.App.textSecondary)
        self.subjectTextField.setTextFieldColor(UIColor.App.textPrimary)
        self.subjectTextField.setSecureField(false)
        self.subjectTextField.textField.font = AppFont.with(type: .semibold, size: 15)
        self.subjectTextField.headerLabel.backgroundColor = UIColor.App.backgroundCards
        self.subjectTextField.setViewColor(UIColor.App.backgroundCards)
        
        self.descriptionView.backgroundColor = UIColor.App.backgroundCards
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
        
        self.descriptionTextView.backgroundColor = .clear
        self.descriptionPlaceholderLabel.backgroundColor = .clear
        self.descriptionPlaceholderLabel.textColor = UIColor.App.textSecondary
        self.descriptionTextView.textColor = UIColor.App.backgroundOdds
        
        self.backButtonBaseView.backgroundColor = .clear
        
    }
    
    // MARK: - Actions
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.subjectTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        
    }
    
    @objc func didTapSend() {
  
        self.viewModel.sendEmail(title: self.subjectTextField.text, message: self.descriptionTextView.text)
        self.viewModel.supportResponseAction = { [weak self] withSuccess in
            
            if withSuccess {
                self?.showAlert(title: localized("supportSuccessTitle"), subtitle: localized("supportSuccessSubtitle"), buttonText: "OK", backAction: true)
                self?.didTapBackButton()
                
            }
            else {
                self?.showAlert(title: localized("supportErrorTitle"), subtitle: localized("supportErrorSubtitle"), buttonText: "OK", backAction: false)
            }
            
        }
    }

    func showAlert(title: String, subtitle: String, buttonText: String, backAction: Bool) {
        if backAction {
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: {( action:UIAlertAction!) in
                self.didTapBackButton()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
      
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
    
    private func setupSubviews() {

        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButtonBaseView)
        
        self.backButtonBaseView.addSubview(self.backButton)
        
        self.descriptionView.addSubview(self.descriptionPlaceholderLabel)
        self.descriptionView.addSubview(self.descriptionTextView)
        
        self.baseView.addSubview(self.subjectTextField)
        self.baseView.addSubview(self.descriptionView)
        self.baseView.addSubview(self.sendButton)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.baseView)
        self.view.addSubview(self.navigationBaseView)

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
            
            self.subjectTextField.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30),
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
        
    }

}

extension SupportPageViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("BEGIN EDIT")
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor.App.textPrimary.cgColor
        
        self.descriptionTextView.textColor =  UIColor.App.textPrimary
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end EDIT")
        self.descriptionView.layer.cornerRadius = CornerRadius.headerInput
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor.App.backgroundPrimary.cgColor
        
        self.descriptionTextView.textColor =  UIColor.App.backgroundOdds
    }

}
